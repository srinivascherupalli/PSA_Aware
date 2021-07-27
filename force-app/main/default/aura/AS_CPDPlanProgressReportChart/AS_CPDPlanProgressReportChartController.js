({
    init : function ( component, event, helper ){
        var action = component.get("c.cpdIsMember");
        action.setCallback(this, function(response) {
            var res = response.getReturnValue();
            component.set('v.isMember',res);
        }); 
        $A.enqueueAction(action);
    }, 
	AS_PsaActionPlan : function(component, event, helper) {
		component.set("v.ready", true);
        helper.AS_psaChartPlan(component);
	}
})