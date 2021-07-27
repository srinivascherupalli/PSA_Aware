({
  doInit: function doInit(component, event, helper) {},
  handleClick: function handleClick(component, event, helper) {
    var urlvalue = event.getSource().get("v.value");
    component.set("v.modalWrapper", urlvalue);
    component.set("v.openModal", true);

    if (urlvalue.learning.RecordType.DeveloperName == "Resource") {
      var urllink =
        urlvalue.learning.Current_Published_Version__r.Training_Resource__r
          .Resource_URL__c;
      component.set("v.ifmsrc", urllink);
    } else if (urlvalue.learning.RecordType.DeveloperName == "Moodle") {
      var urllink = urlvalue.learning.AsMoodle_Course_URL__c;
      component.set("v.ifmsrc", urllink);
    } else if (urlvalue.learning.RecordType.DeveloperName == "Event") {
      var urllink = urlvalue.learning.Campaign__r.AS_Event_URL__c;
      component.set("v.ifmsrc", urllink);
    } else {
      var urllink = urlvalue.learning.AsMoodle_Course_URL__c;
      component.set("v.ifmsrc", urllink);
    }
  },
  previousCourseInProgress: function previousCourseInProgress(
    component,
    event,
    helper
  ) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: "Warning",
      message: "Please complete previous course.",
      type: "Error"
    });
    toastEvent.fire();
  },
  closeModel: function closeModel(component, event, helper) {
    // Set isModalOpen attribute to false
    component.set("v.openModal", false);
  }
});