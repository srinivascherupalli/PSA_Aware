({
  handleClick: function handleClick(component, event, helper) {
    var searchText = component.get("v.searchText");
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: "/s/global-search/" + searchText
    });
    urlEvent.fire();
  },
  handleKeyUp: function handleKeyUp(cmp, evt) {
    var isEnterKey = evt.keyCode === 13;

    if (isEnterKey) {
      var queryTerm = cmp.find("mobile-nav-search").get("v.value");
      var urlEvent = $A.get("e.force:navigateToURL");
      urlEvent.setParams({
        url: "/s/global-search/" + queryTerm
      });
      urlEvent.fire();
    }
  }
});