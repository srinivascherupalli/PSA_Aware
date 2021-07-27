({
	doInit : function(component, event, helper) {
        var record_id = '';
        
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
        
        var action1 = component.get("c.getAccountContactRelation");
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.accountContactRelation", storeResponse);
            }
        });
        $A.enqueueAction(action1);
        
        var action2 = component.get("c.hasCourse");
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.isCourse", storeResponse);
            }
        });
        $A.enqueueAction(action2);
        
        var action3 = component.get("c.currentCPDTarget");
        action3.setParams({recordId:record_id});
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currentCPDTargetInfo", response.getReturnValue());
            }
        });
        $A.enqueueAction(action3);
        
        var action4 = component.get("c.currentCPDActivitiesSummaryTotal");
        action4.setParams({recordId:record_id});
        action4.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currentCPDActivitiesSummaryTotalInfo", response.getReturnValue());
            }
        });
        $A.enqueueAction(action4);
        
        var action5 = component.get("c.currentCPDActivitiesSummaryPercentage");
        action5.setParams({recordId:record_id});
        action5.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currentCPDActivitiesSummaryPercentageInfo", response.getReturnValue());
            }
        });
        $A.enqueueAction(action5);
        
        var action6 = component.get("c.currentCPD");
        action6.setParams({recordId:record_id});
        action6.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currentCPDInfo", response.getReturnValue());
            }
        });
        $A.enqueueAction(action6);
	}
})