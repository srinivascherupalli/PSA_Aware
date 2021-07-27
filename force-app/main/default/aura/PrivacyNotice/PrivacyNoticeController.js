({
    init : function(cmp, event, helper) {
        helper.getAgreeField( cmp, event );
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
    },
    agreeCallback : function(cmp, event, helper) {
        helper.updateEnrolField( cmp, event );
    },
    backCallback :function(cmp, event, helper) {

        cmp.set('v.showSpinner', true );

        var cmpEvent = cmp.getEvent("Enrolment_Event");
            cmpEvent = $A.get("e.c:EnrolmentActiveStep");

        setTimeout( function() {
            cmpEvent.setParams({
                enrolmentStep : "step1 - back"
            });
            cmpEvent.fire();
        }, 1000 );
        
    },
    cancelFunc : function(cmp, event, helper) {

        cmp.set('v.showSpinner', true );

        var enrolId = cmp.get('v.enrolId');

        var toastEvent = $A.get("e.force:showToast");

        var func = cmp.get( 'c.deleteEnrolment' );

        func.setParams({
            'enrolId' : enrolId
        });

        func.setCallback( this, function(res) {

            var status = res.getState();
            var reval = res.getReturnValue();

            console.log( reval );

            if(status === "SUCCESS") {


                toastEvent.setParams({
                    "title": "Succes!",
                    "type" : 'success',
                    "message": reval
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

        } );

        $A.enqueueAction(func);
    },
    nextCallback : function(cmp, event, helper) {

        cmp.set('v.showSpinner', true );

        var cmpEvent = cmp.getEvent("Enrolment_Event");
            cmpEvent = $A.get("e.c:EnrolmentActiveStep");

        setTimeout( function() {
            cmpEvent.setParams({
                enrolmentStep : "step3 - completed"
            });
            cmpEvent.fire();
        }, 1000 );
    }
})