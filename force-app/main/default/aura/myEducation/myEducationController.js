({
  doInit: function doInit(component, event, helper) {
    var getUrlParameter = function getUrlParameter(sParam) {
      var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split("&"),
        sParameterName,
        i;

      for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split("=");

        if (sParameterName[0] === sParam) {
          return sParameterName[1] === undefined ? true : sParameterName[1];
        }
      }
    };

    var record_id = getUrlParameter("id");
    var pageValue = getUrlParameter("page");

    if (typeof pageValue == "undefined") {
      pageValue = "NotStarted";
    }

    if (typeof record_id == "undefined") {
      record_id = "";
    }

    component.set("v.selectedItem", "NotStarted");
    var action = component.get("c.allCPDPlanmethod");
    action.setParams({
      recordId: record_id
    });
    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        var resultData = response.getReturnValue();
        component.set("v.cpdPlanData", resultData);
        component.set("v.selectedItem", pageValue);
        var maincpd = [];
        maincpd = resultData["tpAssignmentList"];
        component.set("v.mainCPDData", maincpd); //var allSummary = component.get("v.mainCPDData");

        var allSummary = [];
        allSummary = resultData["tpAssignmentList"];
        var searchKey2 = "Not Started";
        var searchKey3 = "In Progress";
        var searchKey4 = "Complete";
        var enrolleddata = allSummary.filter(function (word) {
          return (
            word.Status__c.toLowerCase().indexOf(searchKey2.toLowerCase()) > -1
          );
        });
        component.set("v.enrolledSummary", enrolleddata);
        component.set("v.notStartedSummaryNumber", enrolleddata.length);
        var progressdata = allSummary.filter(function (word) {
          return (
            word.Status__c.toLowerCase().indexOf(searchKey3.toLowerCase()) > -1
          );
        });
        component.set("v.progressSummary", progressdata);
        component.set("v.ProgressSummaryNumber", progressdata.length);
        var completedata = allSummary.filter(function (word) {
          return (
            word.Status__c.toLowerCase().indexOf(searchKey4.toLowerCase()) > -1
          );
        });
        component.set("v.completedSummary", completedata);
        component.set("v.completedSummaryNumber", completedata.length);
        var completeAndSelectedData = completedata.filter(function (word) {
          return word.AsSummary_Plan__c == true;
        });
        component.set(
          "v.completedSelectedNumber",
          completeAndSelectedData.length
        ); //Image

        var badgeURL =
          '<p><img src="' +
          $A.get("$Resource.PSAFED") +
          "/dist/images/group1-blanklogo.gif" +
          '" alt="credit badge single"></img></p>';
        component.set("v.group1DefaultImage", badgeURL);
        var badgeURL2 =
          '<p><img src="' +
          $A.get("$Resource.PSAFED") +
          "/dist/images/group2-blanklogo.gif" +
          '" alt="credit badge single"></img></p>';
        component.set("v.group2DefaultImage", badgeURL2);
      } else {
        console.log("state failed");
      }
    });
    $A.enqueueAction(action);
  },
  notStartedClick: function notStartedClick(component) {
    // component.set("v.selectedItem", "Not Started");
    var urlEvent = $A.get("e.force:navigateToURL");
    var page = "NotStarted";
    urlEvent.setParams({
      url: "/s/myeducation?page=" + page
    });
    urlEvent.fire();
  },
  progressClick: function progressClick(component) {
    //component.set("v.selectedItem", "In Progress");
    var urlEvent = $A.get("e.force:navigateToURL");
    var page = "InProgress";
    urlEvent.setParams({
      url: "/s/myeducation?page=" + page
    });
    urlEvent.fire();
  },
  completeClick: function completeClick(component) {
    //component.set("v.selectedItem", "Completed");
    var urlEvent = $A.get("e.force:navigateToURL");
    var page = "Completed";
    urlEvent.setParams({
      url: "/s/myeducation?page=" + page
    });
    urlEvent.fire();
  },
  onChange: function onChange(component, event, helper) {
    component.set("v.sortBy", component.find("select").get("v.value"));
    var cards = component.get("v.enrolledSummary");
    cards = cards.sort(helper.sortCards.bind(this, component.get("v.sortBy")));
    component.set("v.enrolledSummary", cards);
  },
  onChangeProgress: function onChangeProgress(component, event, helper) {
    component.set("v.sortBy", component.find("selectProgress").get("v.value"));
    var cards = component.get("v.progressSummary");
    cards = cards.sort(helper.sortCards.bind(this, component.get("v.sortBy")));
    component.set("v.progressSummary", cards);
  },
  onChangecompleted: function onChangecompleted(component, event, helper) {
    component.set("v.sortBy", component.find("selectComplete").get("v.value"));
    var cards = component.get("v.completedSummary");
    cards = cards.sort(helper.sortCards.bind(this, component.get("v.sortBy")));
    component.set("v.completedSummary", cards);
  },
  navigate: function navigate(component, event, helper) {
    var sobjectId = event.currentTarget.id;

    if (sobjectId.indexOf("a11") > -1) {
      //Note a11 is prefix for Plan Record
      var urlEvent = $A.get("e.force:navigateToURL");
      urlEvent.setParams({
        url: "/s/training-plan/" + sobjectId
      });
      urlEvent.fire();
    }

    if (sobjectId.indexOf("a16") > -1) {
      //Note a16 is prefix for Track Record
      var urlEvent = $A.get("e.force:navigateToURL");
      urlEvent.setParams({
        url: "/s/training-track/" + sobjectId
      });
      urlEvent.fire();
    }
  }
});