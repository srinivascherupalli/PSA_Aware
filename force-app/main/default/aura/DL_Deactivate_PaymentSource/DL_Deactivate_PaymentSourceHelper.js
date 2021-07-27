({
	paymentSource_deactivate : function(component, event, helper) {
        component.set('v.loadingBool', 'true');
        var _recordID = component.get("v.recordId");
		var _action = component.get('c.deactivatePaymentSource');

        _action.setParams({paymentSource_ID : _recordID});

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
    
    
    failedPayments_recover : function(component, event, helper) {
        component.set('v.loadingBool', 'true');
        var _recordID = component.get('v.recordId');
		var _action = component.get('c.recoverFailedPayments');

        _action.setParams({paymentSource_ID : _recordID});

        _action.setCallback(this, function(response) {
            var _state = response.getState();
            var _response = response.getReturnValue();
            
            if(_state === "SUCCESS"){
                console.log("SUCCESS");
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
})