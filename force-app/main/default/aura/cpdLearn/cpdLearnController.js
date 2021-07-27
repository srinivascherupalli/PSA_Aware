({
  plantabClick: function plantabClick(component) {
    component.set("v.selectedTab", "planned");
  },
  enrollClick: function enrollClick(component) {
    component.set("v.selectedTab", "enrolled");
  },
  progressClick: function progressClick(component) {
    component.set("v.selectedTab", "progress");
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