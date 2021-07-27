({
	createRenewalOpp : function(component, event, helper) {
		var Id = component.get( "v.recordId" );
		var action = component.get('c.createRenewalOppViaButton');
		action.setParams({"memSubscriptionId":Id});
	                        
		action.setCallback(this, function(a) {  
			var res = a.getReturnValue();  
			console.log(res.isSuccess);
			
			if(res.isSuccess == false) {
				component.set("v.hasErrors", true);
				component.set("v.messageError", res.ErrorMessage);
			} else {
				try {
					$A.get('e.force:refreshView').fire();
					$A.get("e.force:closeQuickAction").fire();
				} catch (e) {
					// code block below is added for closing visual force page
					var forClose = $A.get("e.c:AsCloseTheWindow");
					forClose.setParams({"recordId":Id });
				    forClose.fire();
				    
				} 
			}
			
	
		}); 
		$A.enqueueAction(action); 
	},
	
	cancel : function(component, event, helper) {
		var Id = component.get( "v.recordId" );
		console.log('close in controller');
		try {
			$A.get("e.force:closeQuickAction").fire();
		} catch (e) {
			// code block below is added for closing visual force page
			var forClose = $A.get("e.c:AsCloseTheWindow");
			forClose.setParams({"recordId":Id });
		    forClose.fire();
		    
		} 
        
    }
})