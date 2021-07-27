({
    doInit: function(component, event, helper) {

        var Id = component.get( "v.recordId" ); 
        var action = component.get('c.singleArticle');

        action.setParams({"articleId":Id});
        
        action.setCallback(this, function(a) {  

            var res = a.getReturnValue();  
            var r = res[0];
            component.set('v.Type',r.ArticleType+'&' );
            
        });    
        $A.enqueueAction(action); 
 
    }
})