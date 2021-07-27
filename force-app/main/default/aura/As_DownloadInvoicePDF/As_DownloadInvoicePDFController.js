({
    
    CheckOrder : function(component, event, helper) {
        
        var Id = component.get( "v.recordId" );
        var action = component.get("c.CheckOrderStatus");
        action.setParams({
            "recIDdraft": Id
        });
        action.setCallback(this, function(response){
            var idstate = response.getState();
            if (idstate === "SUCCESS") {
                
                //var id = response.getReturnValue();
                if(response.getReturnValue() != null && response.getReturnValue() === 'Activated'){
                    helper.viewPDF(component);
                }else{
                    component.set('v.ErrorMessage', 'Sorry cannot process this record because the Order status is Draft!');
                }
            }
            else {
                component.set('v.ErrorMessage', 'Sorry something went wrong when processing the Order record');
            }
        });
        $A.enqueueAction(action);   
        
    },
    
    closeModal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    }
})