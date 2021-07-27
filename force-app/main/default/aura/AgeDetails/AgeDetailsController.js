({
    init : function(cmp, event, helper) {
        cmp.set('v.showSpinner', true );
        helper.getAccount( cmp, event );
        helper.getEnrolment( cmp, event );
    },
    ageCallback : function(cmp, event, helper) {
        console.log( cmp.get('v.enrolment') );
        cmp.set('v.showGuardianfields', ( event.getSource().get('v.value') == 'No' ) ? true : false );
    },
    cancelcallback : function(cmp, event, helper) {
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
    emailFunc : function(cmp, event, helper) {
        cmp.set('v.showSpinner', true );
        helper.saveandContinue( cmp, event, true ); 
    },
    saveFunc : function(cmp, event, helper) {
        cmp.set('v.showSpinner', true );
        helper.saveandContinue( cmp, event, false ); 
    }
})