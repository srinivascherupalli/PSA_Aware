({
  init : function (cmp,event,hlp) {
    var flow = cmp.find("flowData");
    flow.startFlow("PSA_Membership_Sign_Up");
 
 
        
  },
  handleStatusChange : function (component, event ,hlp) {
	  
	
	  
		 /* if(event.getParam("status") === "NEXT") {
			  hlp.PAGENUMBER = hlp.PAGENUMBER + 1;
			  component.set( 'v.pageNumber', hlp.PAGENUMBER+'' ); 
		  }
		  if(event.getParam("status") === "PREVIOUS") {
			  hlp.PAGENUMBER = hlp.PAGENUMBER - 1;
			  component.set( 'v.pageNumber', hlp.PAGENUMBER+'' );
		  }*/
	 console.log('ssss  ',event);  
	   
      if(event.getParam("status") === "FINISHED") {
          var outputVariables = event.getParam("outputVariables");
          var outputVar;
          for(var i = 0; i < outputVariables.length; i++) {
             outputVar = outputVariables[i];
 
              if( outputVar.name === "OpportunityID" ){
                  var oppId = outputVar.value;
                  var url = location.origin; 
               

                var action = component.get('c.checkIfStudent ');
                var setparam={}; 
                setparam['oppId']	= outputVar.value+'';
                action.setParams(setparam);
                action.setCallback(this, function(a) {  
                    var res = a.getReturnValue();  
              
                    if(res.trim() == 'http://www.psa.org.au/'){
                    	window.location.replace(  res );
                    }else {
                    	window.location.replace( url +''+ res );
                    }
                    
                });
                 
                $A.enqueueAction(action)
                

              }
 
          }
      } else {
		  var outputVariables_nxt  = event.getParam("outputVariables"); 
          var outputVarnxt;
          for(var i = 0; i < outputVariables_nxt.length; i++) {
              outputVarnxt = outputVariables_nxt[i]; 
        
              if( outputVarnxt.name === "OpportunityID" ){
                  if(  outputVarnxt.value != null ){
                      	var oppIdnxt = outputVarnxt.value;
                     	component.set('v.parentId',oppIdnxt);
                        
 	
                  } 
              }
          } 
 
             
        
      }  
  },
     doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
            alert('Please Select a Valid File');
        }
    },
 
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
 
  
})