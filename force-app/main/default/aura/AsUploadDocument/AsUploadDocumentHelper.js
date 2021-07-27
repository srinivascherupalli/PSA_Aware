({
    getdomcumentValues : function(component ,helper, callback) {

        component.set('v.showSpinner', true );

        var action = component.get('c.InitDocumentUpload');
 
        action.setParams({
                            "parentId": component.get("v.parentId")
                        });
        
        action.setCallback(this, function(a) {  

            var res = a.getReturnValue();  
            callback( res )

            component.set('v.showSpinner', false );
            
        });    
        $A.enqueueAction(action); 

    },
    saveChanges : function( cmp , sendmelink  ){
 
        var saveChanges = cmp.get("c.saveChanges");
 
        saveChanges.setParams({
            "enrolId": cmp.get("v.parentId"),
            "sendmelink" : sendmelink
        });

        saveChanges.setCallback( this, function( response ) {
            var status = response.getState();
            if( status === "SUCCESS" ) {
                var rBody = response.getReturnValue();

                cmp.set("v.showSpinner", false);
                this.callNextStep( cmp, true );
                
            } else {
                cmp.set("v.showSpinner", false);
                console.log( response.getError() );
            }
        });
        $A.enqueueAction( saveChanges ); 
 
    },
 	callNextStep :function(cmp, iscompleted ) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");

        var nextstep = "step12";

        if( iscompleted ) {
            nextstep = "step12 - completed";
        }

        cmpEvent.setParams({
            enrolmentStep : nextstep
        });
        cmpEvent.fire();
    },

    backCallback: function( cmp ) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
        cmpEvent.setParams({
            enrolmentStep : "step10 - back"
        });
        cmpEvent.fire();
    },

    getEnrolInfo : function( cmp, helper ) {

        var func = cmp.get("c.getEnrolInfo");

        var enrolId = cmp.get('v.parentId');
        
        func.setParams({
            "recordID": enrolId
        });

        func.setCallback( this, function( res ){
            var status = res.getState();

            if(status === "SUCCESS"){
                var qresult = res.getReturnValue();
                cmp.set('v.EnrollmentStatus', qresult.Enrolment_Status__c );
            }
        });
        $A.enqueueAction(func);
    }
    
})