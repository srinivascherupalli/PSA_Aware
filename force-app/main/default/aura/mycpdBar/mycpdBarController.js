({
  onCheck: function onCheck(component, event, helper) {
    var checkCmp = component.find("checkbox");
    var save_action = component.get("c.updateCheck");
    save_action.setParams({
      isAccredite: checkCmp.get("v.value"),
      key: checkCmp.get("v.text")
    });
    save_action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Success!",
          message: "Record Updated.",
          type: "success"
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
  }
});