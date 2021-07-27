({
    viewPDF : function(component) {
        
        //var urler = URL.getSalesforceBaseUrl();
		//var urler = URL.getCurrentRequestUrl();//It returns the page/community/instacne the request was fired.
        var Id = component.get( "v.recordId" );
        var action = component.get("c.addinvoicePDF");
        
        action.setParams({"recID":Id});
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
              
                window.open("/servlet/servlet.FileDownload?file="+response.getReturnValue());
                this.Deleteatthelper(component,response.getReturnValue());
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
            else {
                 component.set('v.ErrorMessage', 'Sorry something went wrong when processing this record');
                //console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
        
    },
    
    Deleteatthelper : function(component,AttachmentId) {
        
         var action = component.get("c.Deleteattachment");
         action.setParams({delattchId:AttachmentId});
         action.setCallback(this, function(response) {
         var state = response.getState();
        });
        // Send action off to be executed
        $A.enqueueAction(action);
        
    }
})