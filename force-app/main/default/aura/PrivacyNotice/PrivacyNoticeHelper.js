({
    getAgreeField : function(cmp, event) {

        var agreefield = cmp.get('c.getEnrolmentField');
        
        var enrolId = cmp.get('v.enrolId');

        agreefield.setParams({
            'enrolId' : enrolId
        });

        agreefield.setCallback( this, function(res) {

            var status = res.getState();
            var reval = res.getReturnValue();

            if(status === "SUCCESS") {
                var istrue = reval.AS_agree_privacy_notice__c;
                cmp.set('v.agree', istrue.toString() );
                cmp.set('v.showNextBtn', istrue );
                cmp.set('v.status', reval.Enrolment_Status__c );
            } else {
                console.log( 'err', reval);
            }

        } );

        $A.enqueueAction(agreefield);
    },
    updateEnrolField : function(cmp, event ) {

        var istrue = event.getSource().get('v.value');
        var enrolid = cmp.get('v.enrolId');

        var toastEvent = $A.get("e.force:showToast");

        var func = cmp.get('c.updateEnrolmentField');

        var obj = {
            'AS_agree_privacy_notice__c' : Boolean( istrue[0] )
        }

        func.setParams({
            'enrolId' : enrolid,
            'obj' : JSON.stringify( obj )
        });

        func.setCallback( this, function(res) {
            var status = res.getState();
            var reval = res.getReturnValue();

            if(status === "SUCCESS") {

                cmp.set('v.showNextBtn', Boolean( istrue[0] ) );

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
    }
})