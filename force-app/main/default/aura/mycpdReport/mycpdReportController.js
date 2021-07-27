({
  onSelection: function onSelection(component, event, helper) {
    var intValue = event.getSource().get("v.value");
    var recordID = event.getSource().get("v.name");
    var save_action = component.get("c.updateSelection");
    save_action.setParams({
      selectedCard: intValue,
      key: recordID
    });
    save_action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Success!",
          message:
            intValue == 1
              ? "Activity has been selected"
              : "Activity has been de-selected",
          type: intValue == 1 ? "success" : "info"
        });
        toastEvent.fire();
        window.setTimeout(function () {
          $A.get("e.force:refreshView").fire();
        }, 1000);
      } else {
        console.log("status failed");
      }
    });
    $A.enqueueAction(save_action);
  },
  submitCPDPlanReport: function submitCPDPlanReport(component, event, helper) {
    console.log("inside");
    var recordID = component.get("v.planId");
    console.log("recordID is" + recordID);
    var action = component.get("c.generateCPDPlanReport");
    action.setParams({
      recordId: recordID
    });
    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        console.log("status success");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Success!",
          message: "CPD plan report generated.",
          type: "success"
        });
        toastEvent.fire();
        window.setTimeout(function () {
          $A.get("e.force:refreshView").fire();
        }, 4000);
      } else {
        console.log("status failed");
      }
    });
    $A.enqueueAction(action);
  },
  navigate: function navigate(component, event, helper) {
    var sobjectId = event.currentTarget.id;
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: "/s/ascpd-learning-summary/" + sobjectId
    });
    urlEvent.fire();
  }
});