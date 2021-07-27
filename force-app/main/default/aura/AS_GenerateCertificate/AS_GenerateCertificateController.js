({
    handleClick : function(component, event) {
        var Id = component.get( "v.recordId" );
		var action = component.get('c.createSubsCertByButton');
        var setparam = {}; 
        //setparam['mString']=[ Id ];
        action.setParams({"subscriptionId":Id});
                            
		action.setCallback(this, function(a) {  
        //var res = a.getReturnValue();  
			console.log('test');
			
        	$A.get("e.force:closeQuickAction").fire();
        	$A.get('e.force:refreshView').fire();

 		});    
		$A.enqueueAction(action); 
    }
})