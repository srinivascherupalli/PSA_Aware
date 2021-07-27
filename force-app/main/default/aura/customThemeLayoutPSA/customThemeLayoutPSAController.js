({
  doInit: function doInit(component, event, helper) {
    var screen_height = document.documentElement.clientHeight;
    var screen_width = document.documentElement.clientWidth;
      var nAgt = window.navigator.userAgent;
    var verOffset;
     if(((verOffset=nAgt.indexOf("Trident"))!=-1) ){
 		var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
          title: "Warning!",
          message: "Your web browser (Internet Explorer) is not fully supported by this site. For the best user experience we recommend Chrome or Firefox",
          type: "Warning"
        });
        toastEvent.fire();
	}

    if (screen_width > 1024) {
      screen_height = screen_height - 218;
    } else if (screen_width > 767) {
      screen_height = screen_height - 188;
    } else if (screen_width > 319) {
      screen_height = screen_height - 112;
    }

    component.set("v.screenHeight", screen_height); //https://psastaging-my-psa.cs75.force.com/s/

    var page_location_url = window.location.href; //CPD Sandbox

    if (
      page_location_url == "https://cpd-my-psa.cs73.force.com/s/" ||
      page_location_url ==
        "https://cpd-my-psa.cs73.force.com/s/myeducation?page=NotStarted" ||
      page_location_url ==
        "https://cpd-my-psa.cs73.force.com/s/myeducation?page=InProgress" ||
      page_location_url ==
        "https://cpd-my-psa.cs73.force.com/s/myeducation?page=Completed" ||
      page_location_url == "https://cpd-my-psa.cs73.force.com/s/myeducation" ||
      page_location_url == "https://cpd-my-psa.cs73.force.com/s/mycpdyear" ||
      page_location_url ==
        "https://cpd-my-psa.cs73.force.com/s/mycpdyear?page=Plan" ||
      page_location_url ==
        "https://cpd-my-psa.cs73.force.com/s/mycpdyear?page=Learn" ||
      page_location_url ==
        "https://cpd-my-psa.cs73.force.com/s/mycpdyear?page=Self-Record" ||
      page_location_url ==
        "https://cpd-my-psa.cs73.force.com/s/mycpdyear?page=Reflect" ||
      page_location_url ==
        "https://cpd-my-psa.cs73.force.com/s/mycpdyear?page=Report"
    ) {
      page_location_url = "https://my.psa.org.au/s/";
    } //UAT Sandbox

    if (
      page_location_url == "https://psa-my-psa.cs117.force.com/s/" ||
      page_location_url == "https://psa-my-psa.cs117.force.com/s/mycpdyear" ||
      page_location_url ==
        "https://psa-my-psa.cs117.force.com/s/mycpdyear?page=Plan" ||
      page_location_url ==
        "https://psa-my-psa.cs117.force.com/s/myeducation?page=NotStarted" ||
      page_location_url ==
        "https://psa-my-psa.cs117.force.com/s/myeducation?page=InProgress" ||
      page_location_url ==
        "https://psa-my-psa.cs117.force.com/s/myeducation?page=Completed" ||
      page_location_url == "https://psa-my-psa.cs117.force.com/s/myeducation" ||
      page_location_url ==
        "https://psa-my-psa.cs117.force.com/s/mycpdyear?page=Learn" ||
      page_location_url ==
        "https://psa-my-psa.cs117.force.com/s/mycpdyear?page=Self-Record" ||
      page_location_url ==
        "https://psa-my-psa.cs117.force.com/s/mycpdyear?page=Reflect" ||
      page_location_url ==
        "https://psa-my-psa.cs117.force.com/s/mycpdyear?page=Report"
    ) {
      page_location_url = "https://my.psa.org.au/s/";
    } //Production org

    if (
      page_location_url == "https://my.psa.org.au/s/mycpdyear" ||
      page_location_url == "https://my.psa.org.au/s/mycpdyear?page=Plan" ||
      page_location_url == "https://my.psa.org.au/s/mycpdyear?page=Learn" ||
      page_location_url ==
        "https://my.psa.org.au/s/mycpdyear?page=Self-Record" ||
      page_location_url ==
        "https://my.psa.org.au/s/myeducation?page=NotStarted" ||
      page_location_url ==
        "https://my.psa.org.au/s/myeducation?page=InProgress" ||
      page_location_url ==
        "https://my.psa.org.au/s/myeducation?page=Completed" ||
      page_location_url == "https://pmy.psa.org.au/s/myeducation" ||
      page_location_url == "https://my.psa.org.au/s/mycpdyear?page=Reflect" ||
      page_location_url == "https://my.psa.org.au/s/mycpdyear?page=Report"
    ) {
      page_location_url = "https://my.psa.org.au/s/";
    }

    component.set("v.cdURL", page_location_url);
    var action = component.get("c.fetchUser");
    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        component.set("v.userInfo", storeResponse);
        component.set("v.isSpinner", false);
      }
    });
    $A.enqueueAction(action);
  },
  onClickMobile: function onClickMobile(component, event, helper) {
    var id = event.target.dataset.menuItemId;

    if (id) {
      var cmpTarget = component.find("navWrapper");
      var cmpMTarget = component.find("mobileWrapper");
      $A.util.toggleClass(cmpTarget, "navWrapper--active");
      $A.util.toggleClass(cmpMTarget, "mobileWrapper--active");
      component.getSuper().navigate(id);
    }
  },
  openSidebar: function openSidebar(component, event, helper) {
    var cmpTarget = component.find("navWrapper");
    var cmpMTarget = component.find("mobileWrapper");
    $A.util.toggleClass(cmpTarget, "navWrapper--active");
    $A.util.toggleClass(cmpMTarget, "mobileWrapper--active");
  },
  closeSidebar: function closeSidebar(component, event, helper) {
    var cmpTarget = component.find("navWrapper");
    var cmpMTarget = component.find("mobileWrapper");
    $A.util.toggleClass(cmpTarget, "navWrapper--active");
    $A.util.toggleClass(cmpMTarget, "mobileWrapper--active");
  },
  onClickMenuHome: function onClickMenuHome(component, event, helper) {
    var cmpTarget = component.find("cdMenuHome");
    $A.util.addClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuMyCPD");
    $A.util.removeClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuMyCT");
    $A.util.removeClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuBC");
    $A.util.removeClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuMyInvoices");
    $A.util.removeClass(cmpTarget, "active");
  },
  onClickMenuMyCPD: function onClickMenuMyCPD(component, event, helper) {
    var cmpTarget = component.find("cdMenuMyCPD");
    $A.util.addClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuHome");
    $A.util.removeClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuMyCT");
    $A.util.removeClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuBC");
    $A.util.removeClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuMyInvoices");
    $A.util.removeClass(cmpTarget, "active");
  },
  onClickMenuMyCT: function onClickMenuMyCT(component, event, helper) {
    var cmpTarget = component.find("cdMenuMyCT");
    $A.util.addClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuHome");
    $A.util.removeClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuMyCPD");
    $A.util.removeClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuBC");
    $A.util.removeClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuMyInvoices");
    $A.util.removeClass(cmpTarget, "active");
  },
  onClickMenuBC: function onClickMenuBC(component, event, helper) {
    var cmpTarget = component.find("cdMenuBC");
    $A.util.addClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuHome");
    $A.util.removeClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuMyCT");
    $A.util.removeClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuMyCPD");
    $A.util.removeClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuMyInvoices");
    $A.util.removeClass(cmpTarget, "active");
  },
  onClickMenuMyInvoices: function onClickMenuMyInvoices(
    component,
    event,
    helper
  ) {
    var cmpTarget = component.find("cdMenuMyInvoices");
    $A.util.addClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuHome");
    $A.util.removeClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuMyCT");
    $A.util.removeClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuMyCPD");
    $A.util.removeClass(cmpTarget, "active");
    var cmpTarget = component.find("cdMenuBC");
    $A.util.removeClass(cmpTarget, "active");
  }
});