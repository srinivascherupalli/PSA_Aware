({
    init : function( cmp, event, helper ) {
        helper.getPicklistOption( cmp, 'AS_Highest_Completed_Education__c', 'Enrolment_Form__c', 'schoolLevel' );
        helper.getPicklistOption( cmp, 'ASQualification_Type__c', 'Qualification__c', 'qualificationType' );
        helper.getPicklistOption( cmp, 'AS_Study_Reason__c', 'Enrolment_Form__c', 'studyreason' );
        helper.getPicklistOption( cmp, 'ASQualification_Level__c', 'Qualification__c', 'qualificationLevel' );

        helper.getCurrentQualification( cmp );
        helper.getCurrentEnrolment( cmp );

        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
    },

    saveRecord : function( cmp, event, helper ) {
        var toastEvent = $A.get("e.force:showToast");
        var allValid = cmp.find('education-field').reduce(function (validSoFar, inputCmp) {
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
            helper.saveChanges( cmp, false );
        }

    },

    saveSendLink : function( cmp, event, helper ) {
        var toastEvent = $A.get("e.force:showToast");
        var allValid = cmp.find('education-field').reduce(function (validSoFar, inputCmp) {
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
            helper.saveChanges( cmp, true );
        }
    },

    addItem : function( cmp, event, helper ) {

        var qualInfo = cmp.get("v.qualification");

        var obj = {
            'Id' : null,
            'Name' : '',
            'ASQualification_Name__c' : '',
            'ASQualification_Type__c' : '',
            'ASQualification_Level__c' : ''
        };

        qualInfo.push( obj );

        cmp.set("v.qualification", qualInfo);
    },

    removeItem : function( cmp, event, helper ) {

        try {

            // remove item
            var id = event.getSource().get( 'v.id' );
            var q =  cmp.get("v.qualification");
            var d = cmp.get("v.tobedeleted");
            
            var sfId = q[id].Id;
            if ( typeof sfId != 'undefined' &&  sfId != '' && sfId != null ) {
                d.push( sfId );
            }

            // remove item by index
            q.splice(id, 1); 
            cmp.set("v.qualification", q);

        } catch( e ) {
            console.log( e );
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