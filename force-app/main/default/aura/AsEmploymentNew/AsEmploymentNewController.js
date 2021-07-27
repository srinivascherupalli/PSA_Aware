({
    doinit : function(cmp, event, helper) {
        var recordID = cmp.get("v.recordId");
        var recordEnrolID = cmp.get("v.recordIdEnrol");
        
        helper.getPicklistOption(cmp,'AS_Employment_State__c','Enrolment_Form__c');
        helper.getPicklistOption(cmp,'AS_Employment_Status__c','Enrolment_Form__c');
        helper.getPicklistOption(cmp,'Recent_Occupation__c','Enrolment_Form__c');
        helper.getPicklistOption(cmp,'Industry__c','Enrolment_Form__c');
        helper.getEnrolmentRecord(cmp);

        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
    },
    
    saveRecord: function(cmp,event, helper){

        var toastEvent = $A.get("e.force:showToast");
        var allValid = cmp.find('page7-field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if(  !allValid ) {
            toastEvent.setParams({
                "title": "Error!",
                "type" : 'error',
                "message": "Please fill up the required fields!"
            });
            toastEvent.fire();
            //alert("Please fill up the required fields!");
        } else {
            helper.saveEnrolmentRecord(cmp, false);
        }
        
    },
    
    saveEmailLink: function(cmp,event, helper){
        var toastEvent = $A.get("e.force:showToast");
        var allValid = cmp.find('page7-field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if(  !allValid ) {
            toastEvent.setParams({
                "title": "Error!",
                "type" : 'error',
                "message": "Please fill up the required fields!"
            });
            toastEvent.fire();
            //alert("Please fill up the required fields!");
        } else {
            helper.saveEnrolmentRecord(cmp, true);
        }
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
    }
})