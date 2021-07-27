({
  openModel: function openModel(component, event, helper) {
    component.set("v.modalId", event.getSource().get("v.value"));
    component.set("v.isModalOpen", true);
  },
  closeModel: function closeModel(component, event, helper) {
    // Set isModalOpen attribute to false
    component.set("v.isModalOpen", false);
  },
  saveGoal: function saveGoal(component, event, helper) {
    var goalCmp = component.find("refText");
    var save_action = component.get("c.updateReflection");
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
          message: "Reflection saved.",
          type: "success"
        });
        toastEvent.fire();
        component.set("v.isModalOpen", false);
        component.set("v.refAdded", true);
        window.setTimeout(function () {
          $A.get("e.force:refreshView").fire();
        }, 2000);
      } else {
        console.log("status failed");
      }
    });
    $A.enqueueAction(save_action);
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