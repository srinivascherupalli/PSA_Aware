({

    handleClick : function(component, event) {
        var Id = component.get( "v.recordId" );
		var action = component.get('c.createInvoiceByButton');
        var setparam = {}; 
        //setparam['mString']=[ Id ];
        action.setParams({"OrderId":Id});
                            
		action.setCallback(this, function(a) {  
        //var res = a.getReturnValue();  
			//console.log(res);
 		});    
		$A.enqueueAction(action); 
    }
})