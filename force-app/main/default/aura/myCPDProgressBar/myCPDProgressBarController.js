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

    var action = component.get("c.allCPDPlanmethod");
    action.setParams({
      recordId: record_id
    });
    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        var resultData = response.getReturnValue();
        component.set("v.cpdPlanData", resultData);
        var maincpd = [];
        maincpd = resultData["currentCPDInfo"];
        component.set("v.mainCPDData", maincpd);
        var maincpd = component.get("v.mainCPDData");
        var acr = resultData["AccConRelation"];
        component.set("v.accountContactRelation", acr);
        var course = resultData["course"];
        component.set("v.isCourse", course);
      } else {
        console.log("state failed");
      }
    });
    $A.enqueueAction(action);
  }
});