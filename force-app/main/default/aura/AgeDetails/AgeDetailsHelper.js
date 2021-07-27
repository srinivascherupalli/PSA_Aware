({
    getAccount : function( cmp, event ) {

        var accountId = cmp.get('v.accountId');

        if( accountId == null ) return;

        var func = cmp.get('c.getAccountInfo');

        func.setParams({
            'recordID' : accountId
        });

        func.setCallback( this, function(res) {

            var status = res.getState();

            var reval = res.getReturnValue();

            if(status === "SUCCESS") {

            } else {
                console.log( 'err', res.getError());
            }

        } );

        $A.enqueueAction(func);

    },

    getEnrolment : function( cmp, event ) {

        var enrolId = cmp.get('v.enrolId');

        if( enrolId == null ) return;

        var func = cmp.get('c.getEnrolmentInfo');

        func.setParams({
            'recordID' : enrolId
        });

        func.setCallback( this, function(res) {

            var status = res.getState();

            var reval = res.getReturnValue();

            if(status === "SUCCESS") {

                cmp.set('v.showGuardianfields', ( ! reval.As_over_age__c ) ? true : false );
  
                reval.As_over_age__c = ( reval.As_over_age__c ) ? 'Yes' : 'No';

                cmp.set('v.enrolment', reval );

                cmp.set('v.showSpinner', false );
  
            } else {
                console.log( 'err', reval);
            }

        } );

        $A.enqueueAction(func);

    },
    
    saveandContinue : function( cmp, event, isEmail ) {

        var yesorno = cmp.find('ageradio').get( 'v.value' );

        if( typeof yesorno == 'undefined' ) return;

        var enrolId = cmp.get('v.enrolId');
        
        var toastEvent = $A.get("e.force:showToast");

        var func = cmp.get( 'c.updateEnrolment' );
        var newObj = {};

        if( yesorno === 'No' ) {

            var name = cmp.find('name').get('v.value');
            var phonenumber = cmp.find('phonenumber').get('v.value');
            var emailaddress = cmp.find('emailaddress').get('v.value');

            newObj = {
                'AS_Parent_Guardian_Name__c' : name,
                'AS_Parent_Guardian_Phone_Number__c' : phonenumber,
                'AS_Parent_Guardian_Email__c' : emailaddress,
                'As_over_age__c' : false
            };
        } else {
            newObj = {
                'As_over_age__c' : true
            }
        }

        func.setParams({
            'recordID' : enrolId,
            'objArr' : JSON.stringify( newObj ),
            'isEmail' : isEmail
        });

        func.setCallback( this, function(res) {

            var status = res.getState();

            var reval = res.getReturnValue();

            if(status === "SUCCESS") {

                var cmpEvent = cmp.getEvent("Enrolment_Event");
                var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
                
                if( isEmail ) {

  
                    toastEvent.setParams({
                        "title": "Succes!",
                        "type" : 'success',
                        "message": 'Email has been sent'
                    });

                    toastEvent.fire();
                } else {
                    cmpEvent.setParams({
                        enrolmentStep : "step2 - completed"
                    });
                    cmpEvent.fire();
                }

                cmp.set('v.showSpinner', false );
                
            } else {
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",
                    "message": "Error occured, please try again later or contact administrator!"
                });
                toastEvent.fire();

                console.log('reval', res );

                cmp.set('v.showSpinner', false );
            }

        } );

        $A.enqueueAction(func);
    }
})