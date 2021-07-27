({
    init : function(cmp, event, helper) {

        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;

        cmp.set("v.showSpinner", true);
        
        helper.getEnrolState(cmp, event);
        setTimeout( function() {
            helper.getAccountEmailOpt(cmp, event);  
        }, 1000 );

    },

    sendmeemail: function( cmp, event, helper ) {
        helper.saveHelper(cmp, true);
    },

    formsubmit : function(cmp, event, helper) {
        helper.saveHelper(cmp, false);
    },

    cancelCallback : function( cmp, event, helper ) {
        
        cmp.set("v.showSpinner", true);
        
        var toastEvent = $A.get("e.force:showToast");
        var enrolId = cmp.get("v.recordIdEnrol");
        var deleteEnrol = cmp.get("c.deleteEnrolment");

        deleteEnrol.setParams({
            "enrolId": enrolId
        });

        deleteEnrol.setCallback( this, function( response ) {
            var status = response.getState();
            if( status === "SUCCESS" ) {
                var rBody = response.getReturnValue();
                window.location.href = window.location.origin + '/s/my-enrolments';
            } else {
                cmp.set("v.showSpinner", false);
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : 'error',
                    "message": "Please fill up the required fields!"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction( deleteEnrol );

    },

    backCallback: function( cmp, event, helper ) {
        helper.backCallback( cmp );
    },

    resetFunc : function( cmp, event, helper ) {
        helper.eraseHelper( cmp, event, helper )
    }

})