({
  saveGoal: function saveGoal(component, event, helper) {
    var goalCmp = component.find("goalsText");
    var save_action = component.get("c.updateGoal");
    save_action.setParams({
      cpdGoals: goalCmp.get("v.value"),
      key: goalCmp.get("v.name")
    });
    save_action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Success!",
          message: "CPD Goal Saved.",
          type: "success"
        });
        toastEvent.fire();
        window.setTimeout(function () {
          $A.get("e.force:refreshView").fire();
        }, 2000);
      } else {
        console.log("status failed");
      }
    });
    $A.enqueueAction(save_action);
  }
});