({
  doInit: function doInit(component, event, helper) {
    var urlParams = helper.parseUrlParameters();
    var filterData = {
      categoryFilter: [],
      deliveryFilter: [],
      TypeFilter: [],
      TargetFilter: []
    };
    var selectedCategoryList = [];
    var selectedTypeList = [];

    if (typeof urlParams["filter"] !== "undefined") {
      urlParams["filter"].forEach(function (item) {
        var _item$split = item.split(":"),
          key = _item$split[0],
          value = _item$split[1];

        filterData[key + "Filter"].push(value);

        if (key === "category") {
          selectedCategoryList.push(value);
        } else {
          selectedTypeList.push(value);
        }
      });
    }

    if (selectedTypeList.length) {
      component.set("v.showClearTypeButton", true);
      component.set("v.selectedTypeList", selectedTypeList);
    }

    if (selectedCategoryList.length) {
      component.set("v.showClearTopicButton", true);
      component.set("v.selectedTopicList", selectedCategoryList);
    }

    component.set(
      "v.showClearAllButton",
      selectedTypeList.length || selectedCategoryList.length
    );
    helper.getData(component, filterData);
  },
  handleCheckboxGroupChange: function handleCheckboxGroupChange(
    component,
    event,
    helper
  ) {
    var type = event.getSource().get("v.name");
    var selectedValueLengths = helper.getSelectedValueLength(component);
    component.set(
      "v.showClear" + type + "Button",
      selectedValueLengths[type] > 0
    );
    component.set("v.showClearAllButton", selectedValueLengths.Total > 0);
    helper.getData(component);
  },
  handleClearSectionClick: function handleClearSectionClick(
    component,
    event,
    helper
  ) {
    var type = event.getSource().get("v.name");
    component.set("v.selected" + type + "List", []);
    component.set("v.showClear" + type + "Button", false);
    var selectedValueLengths = helper.getSelectedValueLength(component);
    component.set("v.showClearAllButton", selectedValueLengths.Total > 0);
    helper.getData(component);
  },
  handleClearAllClick: function handleClearAllClick(component, event, helper) {
    component.set("v.selectedTopicList", []);
    component.set("v.showClearTopicButton", false);
    component.set("v.selectedTypeList", []);
    component.set("v.showClearTypeButton", false);
    component.set("v.selectedRoleList", []);
    component.set("v.showClearRoleButton", false);
    component.set("v.showClearAllButton", false);
    helper.getData(component);
  },
  onChange: function onChange(component, event, helper) {
    component.set("v.sortBy", component.find("select").get("v.value"));
    helper.sortData(component);
  },
  handleShowMoreClick: function handleShowMoreClick(component, event) {
    var type = event.getSource().get("v.name");
    component.set("v.showFull" + type + "List", true);
  },
  handleMobileRefineTriggerClick: function handleMobileRefineTriggerClick(
    component
  ) {
    var filter = component.find("filterWrapper");
    $A.util.toggleClass(filter, "show");
  }
});