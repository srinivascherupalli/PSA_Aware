({
  parseUrlParameters: function parseUrlParameters() {
    var _this = this;

    return window.location.search
      .slice(1)
      .split("&")
      .map(function(p) {
        return p.split("=");
      })
      .reduce(function(obj, pair) {
        var _Object$assign2;

        var _pair$map$map = pair
            .map(_this.formatUriString)
            .map(decodeURIComponent),
          key = _pair$map$map[0],
          value = _pair$map$map[1];

        if (typeof obj[key] !== "undefined") {
          var _Object$assign;

          return Object.assign(
            {},
            obj,
            ((_Object$assign = {}),
            (_Object$assign[key] = obj[key].concat(value)),
            _Object$assign)
          );
        }

        return Object.assign(
          {},
          obj,
          ((_Object$assign2 = {}),
          (_Object$assign2[key] = [value]),
          _Object$assign2)
        );
      }, {});
  },
  formatUriString: function formatUriString(str) {
    return str.replace(/\+/g, "%20");
  },
  capitalise: function capitalise(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
  },
  getData: function getData(component, filterData) {
    component.set("v.loading", true);
    var topOffset = 0;
    var filterWrapper = component.find("filterWrapper").getElement();

    if (filterWrapper !== null) {
      topOffset = filterWrapper.offsetTop - 80;
    }

    window.scrollTo({
      top: topOffset,
      left: 0,
      behavior: "smooth"
    });
    var action = component.get("c.allFilterTrainingPlanmethod");

    if (typeof filterData === "undefined") {
      // typeFilter and deliveryFilter
      // split selectedTypeList
      var typeFilterQuery = [];
      var typeDeliveryQuery = [];
      component.get("v.selectedTypeList").forEach(function(type) {
        if (component.get("v.typeFilter").includes(type)) {
          typeFilterQuery.push(type);
        } else if (component.get("v.deliveryFilter").includes(type)) {
          typeDeliveryQuery.push(type);
        }
      });
      filterData = {
        categoryFilter: component.get("v.selectedTopicList"),
        deliveryFilter: typeDeliveryQuery,
        TypeFilter: typeFilterQuery,
        TargetFilter: component.get("v.selectedRoleList")
      };
    }

    action.setParams(filterData);
    action.setCallback(this, function(response) {
      var SHORTENED_LIST_LENGTH = 14;
      var status = response.getState();

      if (status === "SUCCESS") {
        var resultData = response.getReturnValue();
        var topicList = [];

        for (var i = 0; i < resultData.categorylist.length; i++) {
          topicList.push({
            label: resultData.categorylist[i],
            value: resultData.categorylist[i]
          });
        }

        var topicListShortened = topicList.slice(0, SHORTENED_LIST_LENGTH);
        component.set("v.topicListShortened", topicListShortened);
        component.set("v.topicList", topicList);

        if (topicList.length <= SHORTENED_LIST_LENGTH) {
          component.set("v.showFullTopicList", true);
        }

        var typeList = []; // for API call

        var typeFilter = [];
        var deliveryFilter = [];

        for (var i = 0; i < resultData.filterType.length; i++) {
          typeList.push({
            label: resultData.filterType[i],
            value: resultData.filterType[i]
          });
          typeFilter.push(resultData.filterType[i]);
        }

        for (var i = 0; i < resultData.filterMethod.length; i++) {
          typeList.push({
            label: resultData.filterMethod[i],
            value: resultData.filterMethod[i]
          });
          deliveryFilter.push(resultData.filterMethod[i]);
        }

        typeList.sort(function(a, b) {
          return a.value.localeCompare(b.value);
        });
        var typeListShortened = typeList.slice(0, SHORTENED_LIST_LENGTH);
        component.set("v.typeListShortened", typeListShortened);
        component.set("v.typeList", typeList);
        component.set("v.typeFilter", typeFilter);
        component.set("v.deliveryFilter", deliveryFilter);

        if (typeList.length <= SHORTENED_LIST_LENGTH) {
          component.set("v.showFullTypeList", true);
        }

        var roleValues = [];

        for (var i = 0; i < resultData.filterTargetAudience.length; i++) {
          roleValues.push({
            label: resultData.filterTargetAudience[i],
            value: resultData.filterTargetAudience[i]
          });
        }

        var roleListShortened = roleValues.slice(0, SHORTENED_LIST_LENGTH);
        component.set("v.roleListShortened", roleListShortened);
        component.set("v.roleList", roleValues);

        if (roleValues.length <= SHORTENED_LIST_LENGTH) {
          component.set("v.showFullRoleList", true);
        }

        var dateKeysToFormat = ["accreditationExpiryDate", "datePublished"];
        var cards = []
          .concat(resultData.trainingPlanList, resultData.trainingTrackList)
          .map(function(card) {
            var isTrainingTrack = card.Id.indexOf("a16") > -1;
            var cardData = {
              id: card.Id,
              href: "",
              title: card.Name,
             // group: card.Group__c,
                group: "",
              tag: card.PSA_Marketing_Text__c,
              duration: "",
              deliveryMethod: "",
              deliveryDescription: "",
              thumbnail: "",
              badge: "",
              isCourse: card.Qualification_Card__c == false,
              accreditationExpiryDate: "",
              datePublished: ""
            }; //Badge Image

            if (typeof card.Achievement__r !== "undefined") {
              cardData.badge = card.Achievement__r.Eligible_Image__c;
            } else if (card.Group__c == "Group 1") {
              cardData.badge =
                '<p><img src="' +
                $A.get("$Resource.PSAFED") +
                "/dist/images/group1-blanklogo.gif" +
                '" alt="credit badge single"></img></p>';
            } else if (card.Group__c == "Group 2") {
              cardData.badge =
                '<p><img src="' +
                $A.get("$Resource.PSAFED") +
                "/dist/images/group2-blanklogo.gif" +
                '" alt="credit badge single"></img></p>';
            }
            else if(typeof card.Group__c == "Group 3"){
              cardData.badge= '<p><img src="'+$A.get('$Resource.PSAFED') + '/dist/images/group3-blanklogo.gif'+'" alt="credit badge single"></img></p>';
          }

            if (isTrainingTrack) {
              cardData.href = "/s/training-track/" + card.Id;
                cardData.group = card.PSA_Group__c;
              cardData.duration = card.PSA_Duration_editorial__c;
              cardData.deliveryMethod = card.PSA_Delivery_Method__c;
              cardData.deliveryDescription = card.PSA_Card_Description__c;
              cardData.thumbnail = card.PSA_TT_Tile_Image__c;
              cardData.accreditationExpiryDate =
                card.PSA_Accreditation_Expiry_Date__c;
              cardData.datePublished = card.PSA_Date_Published__c; // default to Start_Date__c

              if (
                typeof cardData.datePublished === "undefined" &&
                card.PSA_Start_Date__c
              ) {
                cardData.datePublished = card.PSA_Start_Date__c;
              } // default to start date 

              if (
                typeof cardData.accreditationExpiryDate === "undefined" &&
                card.PSA_Start_Date__c
              ) {
                var s = card.PSA_Start_Date__c.split("-");
                var expiryDate = new Date(s[2], s[1] - 1, s[0]);
                expiryDate.setFullYear(expiryDate.getFullYear() + 2);
                cardData.accreditationExpiryDate = [
                  expiryDate.getFullYear(),
                  expiryDate.getMonth() + 1,
                  expiryDate.getDate()
                ].join("-");
              } //Badge Image

              if (typeof card.Achievement__r !== "undefined") {
                cardData.badge = card.Achievement__r.Eligible_Image__c;
              } else if (card.PSA_Group__c == "Group 1") {
                cardData.badge =
                  '<p><img src="' +
                  $A.get("$Resource.PSAFED") +
                  "/dist/images/group1-blanklogo.gif" +
                  '" alt="credit badge single"></img></p>';
              } else if (card.PSA_Group__c == "Group 2") {
                cardData.badge =
                  '<p><img src="' +
                  $A.get("$Resource.PSAFED") +
                  "/dist/images/group2-blanklogo.gif" +
                  '" alt="credit badge single"></img></p>';
              }
                else if(typeof card.Group__c == "Group 3"){
              cardData.badge= '<p><img src="'+$A.get('$Resource.PSAFED') + '/dist/images/group3-blanklogo.gif'+'" alt="credit badge single"></img></p>';
          }
            } else {
              cardData.href = "/s/training-plan/" + card.Id;
                cardData.group = card.Group__c;
              cardData.duration = card.Duration_editorial__c;
              cardData.deliveryMethod = card.AS_Delivery_Method__c;
              cardData.deliveryDescription = card.Card_Description__c;
              cardData.thumbnail = card.PSA_TP_Tile_Image__c;
              cardData.accreditationExpiryDate =
                card.AS_Accreditation_expiry_date__c;
              cardData.datePublished = card.Date_Published__c; // default to Start_Date__c

              if (
                typeof cardData.datePublished === "undefined" &&
                card.Start_Date__c
              ) {
                cardData.datePublished = card.Start_Date__c;
              } // default to start date 

              if (
                typeof cardData.accreditationExpiryDate === "undefined" &&
                card.Start_Date__c
              ) {
                var s = card.Start_Date__c.split("-");
                var expiryDate = new Date(s[2], s[1] - 1, s[0]);
                expiryDate.setFullYear(expiryDate.getFullYear() + 2);
                cardData.accreditationExpiryDate = [
                  expiryDate.getFullYear(),
                  expiryDate.getMonth() + 1,
                  expiryDate.getDate()
                ].join("-");
              }
            }

            dateKeysToFormat.forEach(function(key) {
              cardData[key] = new Date(
                $A.localizationService.formatDate(cardData[key], "YYYY/MM/DD")
              );
            });
            return cardData;
          })
          .sort(this.sortCards.bind(this, component.get("v.sortBy")));
        component.set("v.courseList", cards);
        component.set("v.loading", false);
      }
    });
    $A.enqueueAction(action);
  },
  getSelectedValueLength: function getSelectedValueLength(component) {
    var topics = component.get("v.selectedTopicList").length || 0;
    var types = component.get("v.selectedTypeList").length || 0;
    var roles = component.get("v.selectedRoleList").length || 0;
    return {
      Topic: topics,
      Type: types,
      Role: roles,
      Total: topics + types + roles
    };
  },
  sortData: function sortData(component) {
    var cards = component.get("v.courseList");
    cards = cards.sort(this.sortCards.bind(this, component.get("v.sortBy")));
    component.set("v.courseList", cards);
  },
  sortCards: function sortCards(sortType, a, b) {
    switch (sortType) {
      case "az":
        return a.title.toLowerCase().localeCompare(b.title.toLowerCase());

      case "za":
        return b.title.toLowerCase().localeCompare(a.title.toLowerCase());
      case "dpo":
            return a.datePublished - b.datePublished;
      case "dpn":
            return b.datePublished - a.datePublished;

      case "accExDateOtoN":
        return a.accreditationExpiryDate - b.accreditationExpiryDate;

      default:
        console.error("sortType not available", sortType);
        return true;
    }
  }
});