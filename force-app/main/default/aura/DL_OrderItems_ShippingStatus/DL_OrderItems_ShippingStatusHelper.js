({
	completeOrderItems : function(component, event, helper) {
        component.set('v.loadingBool', 'true');
        var _recordID = component.get("v.recordId");
		var _action = component.get('c.completeOrderItems');

        _action.setParams({order_ID : _recordID});

        _action.setCallback(this, function(response) {
            var _state = response.getState();
            
            if(_state === "SUCCESS"){
                console.log("SUCCESS");
                var _response = response.getReturnValue();
                $A.get('e.force:refreshView').fire();
            }
            
            else{
            }   

            component.set('v.loadingBool', 'false');
            console.log(_response);
        });

        $A.enqueueAction(_action); 
    },
    

    processingOrderItems : function(component, event, helper) {
        component.set('v.loadingBool', 'true');
        var _recordID = component.get("v.recordId");
		var _action = component.get('c.processingOrderItems');

        _action.setParams({order_ID : _recordID});

        _action.setCallback(this, function(response) {
            var _state = response.getState();
            
            if(_state === "SUCCESS"){
                console.log("SUCCESS");
                var _response = response.getReturnValue();
                $A.get('e.force:refreshView').fire();
            }
            
            else{
            }   

            component.set('v.loadingBool', 'false');
            console.log(_response);
        });

        $A.enqueueAction(_action); 
	},
	

	closeModal : function(component, event, helper){
        $A.util.removeClass(component.find('confirmationModal'), 'slds-show');
        $A.util.addClass(component.find('confirmationModal'), 'slds-hide');
        component.set('v.loadingBool', 'false');
    },

    closeModal2 : function(component, event, helper){
        $A.util.removeClass(component.find('confirmationModal2'), 'slds-show');
        $A.util.addClass(component.find('confirmationModal2'), 'slds-hide');
        component.set('v.loadingBool', 'false');
    },
})