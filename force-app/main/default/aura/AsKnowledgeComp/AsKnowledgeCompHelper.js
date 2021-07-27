({
	getUrl : function(component,callback){
		var action = component.get('c.fetchit');
		action.setCallback(this, function(a) {
			callback(  a.getReturnValue() );
		}); 
		$A.enqueueAction(action); 
	}  
})