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
      pageValue = "goals";
    }

    if (typeof record_id == "undefined") {
      record_id = "";
    }

    if (record_id) {
      component.set("v.selectedCPDYear", record_id);
    }

    component.set("v.hasBeenEdited", false);
    component.set("v.selectedItem", "goals");
    component.set("v.selectedTab", "planned"); //var record_id = '';

    var action = component.get("c.allCPDPlanmethod");
    action.setParams({
      recordId: record_id
    });
    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        component.set("v.selectedItem", pageValue);
        var resultData = response.getReturnValue();
        component.set("v.cpdPlanData", resultData);
        var planid = resultData["cpdPlanRecordID"];
          if (record_id) {
      		component.set("v.selectedCPDYear", record_id);
    	}else{
              component.set("v.selectedCPDYear", planid);
          }
        var maincpd = [];
        maincpd = resultData["currentCPDInfo"];
        component.set("v.mainCPDData", maincpd);
        component.set("v.recordId", maincpd.Id);
        var cpdMap = resultData["mapOfCPD"];
        component.set("v.cpdMap", cpdMap);
        var listCpd = resultData["listofCPD"];
        component.set("v.cpdList", listCpd);
        var maincpd = component.get("v.mainCPDData"); //var allSummary=maincpd["CPD_Learning_Summaries__r"];

        var attachment = resultData["getPlanAttachment"];
        component.set("v.planAttachment", attachment); // summary list

        var allSummary = resultData["getActivities"];
        var attachments = resultData["getPlanAttachments"];
        component.set("v.planAttachments", attachments);
        var searchKey = "Planned";
        var searchKey2 = "Not Started";
        var searchKey3 = "In Progress";
        var searchKey4 = "Complete";
        var planneddata = allSummary.filter(function (word) {
          return (
            word.Status__c.toLowerCase().indexOf(searchKey.toLowerCase()) > -1
          );
        });
        component.set("v.plannedSummary", planneddata);
        var enrolleddata = allSummary.filter(function (word) {
          return (
            word.Status__c.toLowerCase().indexOf(searchKey2.toLowerCase()) > -1
          );
        });
        component.set("v.enrolledSummary", enrolleddata);
        var progressdata = allSummary.filter(function (word) {
          return (
            word.Status__c.toLowerCase().indexOf(searchKey3.toLowerCase()) > -1
          );
        });
        component.set("v.progressSummary", progressdata);
        var completedata = allSummary.filter(function (word) {
          return (
            word.Status__c.toLowerCase().indexOf(searchKey4.toLowerCase()) > -1
          );
        });
        component.set("v.completedSummary", completedata);
        component.set("v.completedSummaryNumber", completedata.length);
        var completeAndSelectedData = completedata.filter(function (word) {
          return word.AsSummary_Plan__c == 'true';
        });
        component.set(
          "v.completedSelectedNumber",
          completeAndSelectedData.length
        );
        var completeAndReflectedData = completedata.filter(function (word) {
          return word.AS_Reflections__c == null;
        });
        component.set(
          "v.completedReflectedNumber",
          completeAndReflectedData.length
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
        console.log("Error: " + response.getError()[0].message);
      }
    });
    $A.enqueueAction(action);
  },
  onChange: function onChange(component, event) {
    var id = event.getSource().get("v.value");
    var pageVal = component.get("v.selectedItem");
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: "/s/mycpdyear?page=" + pageVal + "&id=" + id
    });
    urlEvent.fire();
  },
  goalClick: function goalClick(component) {
    var record_id = component.get("v.recordId");
    var urlEvent = $A.get("e.force:navigateToURL");
    var page = "goals";

    if (record_id == "") {
      urlEvent.setParams({
        url: "/s/mycpdyear?page=" + page
      });
    } else {
      urlEvent.setParams({
        url: "/s/mycpdyear?page=" + page + "&id=" + record_id
      });
    }

    urlEvent.fire();
  },
  planClick: function planClick(component) {
    var record_id = component.get("v.recordId");
    var urlEvent = $A.get("e.force:navigateToURL");
    var page = "Plan";

    if (record_id == "") {
      urlEvent.setParams({
        url: "/s/mycpdyear?page=" + page
      });
    } else {
      urlEvent.setParams({
        url: "/s/mycpdyear?page=" + page + "&id=" + record_id
      });
    }

    urlEvent.fire();
  },
  learnClick: function learnClick(component) {
    var record_id = component.get("v.recordId");
    var urlEvent = $A.get("e.force:navigateToURL");
    var page = "Learn";

    if (record_id == "") {
      urlEvent.setParams({
        url: "/s/mycpdyear?page=" + page
      });
    } else {
      urlEvent.setParams({
        url: "/s/mycpdyear?page=" + page + "&id=" + record_id
      });
    }

    urlEvent.fire();
  },
  recordClick: function recordClick(component) {
    var record_id = component.get("v.recordId");
    var urlEvent = $A.get("e.force:navigateToURL");
    var page = "Self-Record";

    if (record_id == "") {
      urlEvent.setParams({
        url: "/s/mycpdyear?page=" + page
      });
    } else {
      urlEvent.setParams({
        url: "/s/mycpdyear?page=" + page + "&id=" + record_id
      });
    }

    urlEvent.fire();
  },
  reflectClick: function reflectClick(component) {
    var record_id = component.get("v.recordId");
    var urlEvent = $A.get("e.force:navigateToURL");
    var page = "Reflect";

    if (record_id == "") {
      urlEvent.setParams({
        url: "/s/mycpdyear?page=" + page
      });
    } else {
      urlEvent.setParams({
        url: "/s/mycpdyear?page=" + page + "&id=" + record_id
      });
    }

    urlEvent.fire();
  },
  reportClick: function reportClick(component) {
    var record_id = component.get("v.recordId");
    var urlEvent = $A.get("e.force:navigateToURL");
    var page = "Report";

    if (record_id == "") {
      urlEvent.setParams({
        url: "/s/mycpdyear?page=" + page
      });
    } else {
      urlEvent.setParams({
        url: "/s/mycpdyear?page=" + page + "&id=" + record_id
      });
    }

    urlEvent.fire();
  }
});