({
    doInit : function(component, event, helper) {
        var getUrlParameter = function getUrlParameter(sParam) {
            var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                sURLVariables = sPageURL.split('&'),
                sParameterName,
                i;
            
            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('=');
                
                if (sParameterName[0] === sParam) {
                    return sParameterName[1] === undefined ? true : sParameterName[1];
                }
            }
        };
        
        var record_id = getUrlParameter("id");
        if ( typeof record_id == 'undefined' ) {
            record_id = '';
        }
        
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
        
        var action1 = component.get("c.getPlanId");
        action1.setParams({recordId:record_id});
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.planId", response.getReturnValue());
            }
        });
        $A.enqueueAction(action1);
        
        if ( record_id ) {
            component.set("v.planId", record_id);
        }
        
        var action2 = component.get("c.currentCPDTarget");
        action2.setParams({recordId:record_id});
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currentCPDTargetInfo", response.getReturnValue());
            }
        });
        $A.enqueueAction(action2);
        
        var action3 = component.get("c.currentCPDActivitiesSummaryTotal");
        action3.setParams({recordId:record_id});
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currentCPDActivitiesSummaryTotalInfo", response.getReturnValue());
            }
        });
        $A.enqueueAction(action3);
        
        var action4 = component.get("c.currentCPDActivitiesSummaryPercentage");
        action4.setParams({recordId:record_id});
        action4.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currentCPDActivitiesSummaryPercentageInfo", response.getReturnValue());
            }
        });
        $A.enqueueAction(action4);
        
        var action5 = component.get("c.currentCPD");
        action5.setParams({recordId:record_id});
        action5.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currentCPDInfo", response.getReturnValue());
            }
        });
        $A.enqueueAction(action5);
        
        var action6 = component.get("c.getPlans");
        action6.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.plansInfo", response.getReturnValue());
            }
        });
        $A.enqueueAction(action6);
        
        var action7 = component.get("c.getCompleteActivities");
        action7.setParams({recordId:record_id});
        action7.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.completeActivities", response.getReturnValue());
                component.set("v.isSpinner",false);
            }
        });
        $A.enqueueAction(action7);
        
        var action8 = component.get("c.getPlanAttachments");
        action8.setParams({recordId:record_id});
        action8.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.planAttachments", response.getReturnValue());
            }
        });
        $A.enqueueAction(action8);
        
        var action9 = component.get("c.getPlanAttachment");
        action9.setParams({recordId:record_id});
        action9.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.planAttachment", response.getReturnValue());
            }
        });
        $A.enqueueAction(action9);
    },
    onChangePlans : function(component, event, helper) {
        var id = event.getSource().get("v.value");
        window.location.replace("/s/my-cpd-report?id=" + id);
    },
    openModal: function(component, event, helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    closeModal:function(component, event, helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    handleOnSuccess : function(component, event, helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "A new self recorded CPD activity has been recorded.",
            "type": "success"
        });
        toastEvent.fire();
        
        component.find('field').forEach(function(f) {
            f.reset();
        });
        window.setTimeout(function() {
            location.reload();
        }, 2000);
    },
    openModalReflection: function(component, event, helper) {
        var cmpTarget = component.find('modalReflection');
        var cmpBack = component.find('modalBackdropReflection');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
        var data_id = event.currentTarget.getAttribute("data-id");
        component.find("activityid").set("v.value", data_id);
        var action = component.get("c.getReflection");
        action.setParams({recordId:data_id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if ( response.getReturnValue() ) {
                    component.find("reflectionfield").set("v.value", response.getReturnValue());
                    component.find("addorupdateReflection").set("v.label", "Update Reflection");
                } else {
                    component.find("reflectionfield").set("v.value", "");
                    component.find("addorupdateReflection").set("v.label", "Add Reflection");
                }
            }
        });
        $A.enqueueAction(action);
    },
    closeModalReflection:function(component, event, helper) {
        var cmpTarget = component.find('modalReflection');
        var cmpBack = component.find('modalBackdropReflection');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    submitReflection:function(component, event, helper) {
        var reflection = component.find("reflectionfield").get("v.value");
        reflection = reflection.replace(/<\/?[^>]+(>|$)/g, "");
        var activity_id = component.find("activityid").get("v.value");
        var action = component.get("c.addReflection");
        action.setParams({recordId:activity_id,reflectionText:reflection});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var cmpTarget = component.find('modalReflection');
                var cmpBack = component.find('modalBackdropReflection');
                $A.util.removeClass(cmpBack,'slds-backdrop--open');
                $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
                if ( response.getReturnValue() ) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Reflection saved.",
                        "type": "success"
                    });
                    toastEvent.fire();
                    
                    window.setTimeout(function() {
                        var url = window.location.href;
                        url = url.replace(/([&\?]tab=plan*$|tab=plan&|[?&]tab=plan(?=#))/, '');
                        url = url.replace(/([&\?]tab=do*$|tab=do&|[?&]tab=do(?=#))/, '');
                        url = url.replace(/([&\?]tab=record*$|tab=record&|[?&]tab=record(?=#))/, '');
                        url = url.replace(/([&\?]tab=reflect*$|tab=reflect&|[?&]tab=reflect(?=#))/, '');
                        url = url.replace(/([&\?]tab=report*$|tab=report&|[?&]tab=report(?=#))/, '');
                        if (url.indexOf('?') != -1) {
                            window.location = url+'&tab=reflect';
                        } else {
                            window.location = url+'?tab=reflect';
                        }
                    }, 2000);
                }
            }
        });
        $A.enqueueAction(action);
    },
    submitIncludeStatus:function(component, event, helper) {
        var data_id = event.currentTarget.getAttribute("data-id");
        var data_status = event.currentTarget.getAttribute("data-status");
        var action = component.get("c.saveIncludeStatus");
        action.setParams({recordId:data_id,includeStatus:data_status});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                location.reload();
            }
        });
        $A.enqueueAction(action);
    },
    submitCPDPlanReport:function(component, event, helper) {
        var data_id = event.currentTarget.getAttribute("data-id");
        var action = component.get("c.generateCPDPlanReport");
        action.setParams({recordId:data_id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "CPD plan report generated.",
                    "type": "success"
                });
                toastEvent.fire();
                
                window.setTimeout(function() {
                    location.reload();
                }, 4000);
            }
        });
        $A.enqueueAction(action);
    },
    submitAccreditedPharmacist:function(component, event, helper) {
        var data_id = event.currentTarget.getAttribute("data-id");
        var action = component.get("c.setAccreditedPharmacist");
        action.setParams({recordId:data_id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                location.reload();
            }
        });
        $A.enqueueAction(action);
    },
    planOnSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Plan goals saved.",
            "type": "success"
        });
        toastEvent.fire();
    }
})