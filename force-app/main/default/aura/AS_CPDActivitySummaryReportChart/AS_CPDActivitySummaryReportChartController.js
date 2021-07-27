({
    /*doInit : function(component, event, helper){
        var action = component.get('c.renderChart');
        action.setCallback(this,function(result){
            component.set('v.displayChart',result.getReturnValue());
            console.log(result.getReturnValue());
        });
        $A.enqueueAction(action);
    },*/
    init : function ( component, event, helper ){
        var action = component.get("c.cpdIsMember");
        action.setCallback(this, function(response) {
            var res = response.getReturnValue();
            component.set('v.isMember',res);
        }); 
        $A.enqueueAction(action);
    },
    AS_PsaAction : function(component, event, helper) {

		component.set("v.ready", true);
        helper.AS_psaChart(component);
        
	}
})