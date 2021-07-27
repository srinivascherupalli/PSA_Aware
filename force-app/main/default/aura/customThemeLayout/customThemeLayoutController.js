({
    doInit : function(component, event, helper) {
        var screen_height = document.documentElement.clientHeight;
        var screen_width = document.documentElement.clientWidth;
        if ( screen_width > 1024 ) {
        	screen_height = screen_height - 218;
        } else if ( screen_width > 767 ) {
        	screen_height = screen_height - 188;
        } else if ( screen_width > 319 ) {
        	screen_height = screen_height - 112;
        }
		        
        component.set("v.screenHeight", screen_height);
        
        var page_location_url = window.location.href;
        if (page_location_url == 'https://psastaging-my-psa.cs75.force.com/s/') {
            page_location_url = 'https://my.psa.org.au/s/';
        }
        
        component.set("v.cdURL", page_location_url);
        
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
                component.set("v.isSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    openSidebar:function(component, event, helper) {
        var cmpTarget = component.find('cdSidebar');
        $A.util.toggleClass(cmpTarget, 'cd-sidebar-open');
    },
    closeSidebar:function(component, event, helper) {
        var cmpTarget = component.find('cdSidebar');
        $A.util.removeClass(cmpTarget, 'cd-sidebar-open');
    },
    onClickMenuHome:function(component, event, helper) {
        var cmpTarget = component.find('cdMenuHome');
        $A.util.addClass(cmpTarget, 'active');
        
        var cmpTarget = component.find('cdMenuMyCPD');
        $A.util.removeClass(cmpTarget, 'active');
        var cmpTarget = component.find('cdMenuMyCT');
        $A.util.removeClass(cmpTarget, 'active');
        var cmpTarget = component.find('cdMenuBC');
        $A.util.removeClass(cmpTarget, 'active');
        var cmpTarget = component.find('cdMenuMyInvoices');
        $A.util.removeClass(cmpTarget, 'active');
    },
    onClickMenuMyCPD:function(component, event, helper) {
        var cmpTarget = component.find('cdMenuMyCPD');
        $A.util.addClass(cmpTarget, 'active');
        
        var cmpTarget = component.find('cdMenuHome');
        $A.util.removeClass(cmpTarget, 'active');
        var cmpTarget = component.find('cdMenuMyCT');
        $A.util.removeClass(cmpTarget, 'active');
        var cmpTarget = component.find('cdMenuBC');
        $A.util.removeClass(cmpTarget, 'active');
        var cmpTarget = component.find('cdMenuMyInvoices');
        $A.util.removeClass(cmpTarget, 'active');
    },
    onClickMenuMyCT:function(component, event, helper) {
        var cmpTarget = component.find('cdMenuMyCT');
        $A.util.addClass(cmpTarget, 'active');
        
        var cmpTarget = component.find('cdMenuHome');
        $A.util.removeClass(cmpTarget, 'active');
        var cmpTarget = component.find('cdMenuMyCPD');
        $A.util.removeClass(cmpTarget, 'active');
        var cmpTarget = component.find('cdMenuBC');
        $A.util.removeClass(cmpTarget, 'active');
        var cmpTarget = component.find('cdMenuMyInvoices');
        $A.util.removeClass(cmpTarget, 'active');
    },
    onClickMenuBC:function(component, event, helper) {
        var cmpTarget = component.find('cdMenuBC');
        $A.util.addClass(cmpTarget, 'active');
        
        var cmpTarget = component.find('cdMenuHome');
        $A.util.removeClass(cmpTarget, 'active');
        var cmpTarget = component.find('cdMenuMyCT');
        $A.util.removeClass(cmpTarget, 'active');
        var cmpTarget = component.find('cdMenuMyCPD');
        $A.util.removeClass(cmpTarget, 'active');
        var cmpTarget = component.find('cdMenuMyInvoices');
        $A.util.removeClass(cmpTarget, 'active');
    },
    onClickMenuMyInvoices:function(component, event, helper) {
        var cmpTarget = component.find('cdMenuMyInvoices');
        $A.util.addClass(cmpTarget, 'active');
        
        var cmpTarget = component.find('cdMenuHome');
        $A.util.removeClass(cmpTarget, 'active');
        var cmpTarget = component.find('cdMenuMyCT');
        $A.util.removeClass(cmpTarget, 'active');
        var cmpTarget = component.find('cdMenuMyCPD');
        $A.util.removeClass(cmpTarget, 'active');
        var cmpTarget = component.find('cdMenuBC');
        $A.util.removeClass(cmpTarget, 'active');
    }
})