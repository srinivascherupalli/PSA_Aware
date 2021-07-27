({
    handleClick : function(component, event) {
        var Id = component.get( "v.recordId" );
		var action = component.get('c.transferBookmark');
        var setparam = {}; 
        //setparam['mString']=[ Id ];
        action.setParams({"cpdIdStr":Id});
                            
		action.setCallback(this, function(a) {  
        	$A.get("e.force:closeQuickAction").fire();
 		});    
		$A.enqueueAction(action); 
    }
})