({
  openForm: function openForm(component, event, helper) {
    component.set("v.openForm", true);
  },
  handleOnSuccess: function handleOnSuccess(component, event, helper) {
    component.set("v.openForm", false);
    component.set("v.formSubmitted", true);
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: "Success!",
      message: "A new self recorded CPD activity has been recorded.",
      type: "success"
    });
    toastEvent.fire();
    component.find("field").forEach(function (f) {
      f.reset();
    });
    window.setTimeout(function () {
      location.reload();
    }, 2000);
  }
});