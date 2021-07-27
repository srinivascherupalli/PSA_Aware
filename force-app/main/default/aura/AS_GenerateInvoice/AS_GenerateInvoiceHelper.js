({
	 retrieveSessionId: function(component,callback) {
		var action = component.get('c.getSessionId ');
		action.setCallback(this, function(a) {  
        var res = a.getReturnValue();  
			callback(res);
 		});    
		$A.enqueueAction(action); 
	}
})