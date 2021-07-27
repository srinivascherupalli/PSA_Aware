({
    init: function( cmp, event, helper ) {

        cmp.set("v.showSpinner", true);
        helper.getFieldPicklist( cmp, event );
        helper.getFieldsAccount( cmp, event );
        helper.getFieldsEnrolment( cmp, event );

        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
    },

    backFunc : function( cmp, event, helper ) {
        cmp.set('v.showSpinner', true );

        var cmpEvent = cmp.getEvent("Enrolment_Event");
            cmpEvent = $A.get("e.c:EnrolmentActiveStep");

        setTimeout( function() {
            cmpEvent.setParams({
                enrolmentStep : "step3 - back"
            });
            cmpEvent.fire();
        }, 1000 );
    },

    emailFunc : function( cmp, event, helper ) {
        cmp.set('v.showSpinner', true );
        helper.updatecallback( cmp, helper, true );
    },

    saveFunc : function( cmp, event, helper ) {

        cmp.set("v.showSpinner", true);

        helper.updatecallback( cmp, helper, false );
    },

    speakChange: function( cmp, event, helper ) {
        cmp.set('v.otherlanguageif', ( event.getParam('value') == 'true' ) ? true : false ); 
    },
    

    cancelFunc : function( cmp, event, helper ) {

        cmp.set('v.showSpinner', true );

        var toastEvent = $A.get("e.force:showToast");
        var enrolId = cmp.get("v.enrolId");

        var delEnrol = cmp.get("c.deleteEnrolment");

        delEnrol.setParams({
            "enrolId": enrolId
        });

        delEnrol.setCallback(this,function(response){
            var status = response.getState();

            if( status === "SUCCESS" ) {
                var qresult = response.getReturnValue();    

                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": qresult
                });
                toastEvent.fire();

                cmp.set('v.showSpinner', false );

                window.location.href = window.location.origin + '/s/my-enrolments';
            } else {
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",
                    "message": "Error occured, please try again later or contact administrator!"
                });
                toastEvent.fire();

                cmp.set('v.showSpinner', false );
            }

        });
        $A.enqueueAction(delEnrol);
    }
})