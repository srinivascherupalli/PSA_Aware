({
	doInit : function(component, event, helper) {
		
        var Id = component.get( "v.recordId" );    
        
        var action = component.get('c.getSalesforceBaseUrl ');
        action.setCallback(this, function(a) {  
            var res = a.getReturnValue();  
                console.log( res+'/apex/PaymentPage?oppId='+Id );
            	window.location.replace( res+'/apex/PaymentPage?oppId='+Id );
        });    
        $A.enqueueAction(action); 
       /* var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/PaymentPage?oppId='+Id"
        });
        urlEvent.fire();*/
       
	}
})