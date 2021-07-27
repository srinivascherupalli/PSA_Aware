({
	init: function(cmp, event, helper) {
        cmp.set('v.showSpinner',true );
        helper.getPicklistOption(cmp,'Gender__pc','Account');
        helper.getEnrolmentStateList(cmp,'AS_Enrollment_State__c','Enrolment_Form__c');
        helper.getPicklistOptionSalutation(cmp,'Salutation','Account');
		helper.getAccRecord(cmp);
        helper.getEnrolmentRecord(cmp);
        
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
    },

    editRecord: function(cmp, event, helper){
        cmp.set('v.openEditModal', true);
    },

    closeModal: function(cmp, event, helper) {
        cmp.set("v.openEditModal", false);
        cmp.set('v.refresh', true);
    },

    backCallback : function(cmp, event, helper) {
        cmp.set('v.showSpinner', true );

        var cmpEvent = cmp.getEvent("Enrolment_Event");
            cmpEvent = $A.get("e.c:EnrolmentActiveStep");

        setTimeout( function() {
            cmpEvent.setParams({
                enrolmentStep : "step2 - back"
            });
            cmpEvent.fire();
        }, 1000 );
    },

    saveFunc: function( cmp, event, helper) {

        var allValid = cmp.find('slds-field-validate-1').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if(  !allValid ) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type" : 'error',
                "message": "Please fill up the required fields!"
            });
            toastEvent.fire();
        } else {
            cmp.set("v.openEditModal", false);
        } 
    },

    
    emailFunc : function( cmp, event, helper){

        cmp.set('v.showSpinner', true );

        var account = cmp.get('v.account');

        var enrolment = cmp.get('v.enrolment');

       
        var allValid = cmp.find('slds-field-validate').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if(  !allValid ) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type" : 'error',
                "message": "Please fill up the required fields!"
            });
            toastEvent.fire();

            cmp.set('v.showSpinner', false );

        } else {

            helper.saveEnrolmentRecord( cmp, helper, true );
        } 
        
    },

    saveRecordEnrol:function(cmp, event, helper){

        cmp.set('v.showSpinner', true );

        var account = cmp.get('v.account');

        var enrolment = cmp.get('v.enrolment');

        //var toastEvent = $A.get("e.force:showToast");
        var allValid = cmp.find('slds-field-validate').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if(  !allValid ) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type" : 'error',
                "message": "Please fill up the required fields!"
            });
            toastEvent.fire();

            cmp.set('v.showSpinner', false );
        } else {

            helper.saveEnrolmentRecord( cmp, helper, false );
        }
    },

    cancelAction:function(cmp, event, helper){

        cmp.set('v.showSpinner', true );

        var toastEvent = $A.get("e.force:showToast");
        var recordIdEnrol = cmp.get("v.recordIdEnrol");

        var delEnrol = cmp.get("c.delEnrolmentInfo");

        delEnrol.setParams({
            "enrolId": recordIdEnrol
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
            }

        });
        $A.enqueueAction(delEnrol);

    },

    showDiffPostalAdd:function( cmp, event, helper){
        var capturedCheckboxVal = event.getSource().get('v.checked');
        var enrolment = cmp.get('v.enrolment');
        var account = cmp.get('v.account');

        cmp.set('v.diffPostalAddress', ( ! capturedCheckboxVal ) ? true : false );

        enrolment.AS_same_as_above__c = capturedCheckboxVal;

        var altershippingstreet =  ( typeof enrolment.AS_Primary_Street__c == 'undefined' ) ? account.BillingStreet : enrolment.AS_Primary_Street__c;
        var altershippingcity =  ( typeof enrolment.AS_Primary_Suburb_Town__c == 'undefined' ) ? account.BillingCity : enrolment.AS_Primary_Suburb_Town__c;
        var altershippingstate =  ( typeof enrolment.AS_Primary_State__c == 'undefined' ) ? account.BillingState : enrolment.AS_Primary_State__c;
        var alterpostalcode =  ( typeof enrolment.AS_Primary_Postcode__c == 'undefined' ) ? account.BillingPostalCode : enrolment.AS_Primary_Postcode__c;

        for( var x = 0, y = cmp.find('slds-field-validate'); x < y.length; x++ ) {
            
            if( y[x].get('v.name') == 'alterpropertyname' ) {
                y[x].set('v.value', ( capturedCheckboxVal ) ? enrolment.AS_Primary_Property_name__c : '' );
            }

            if( y[x].get('v.name') == 'alterunitdetails' ) {
                y[x].set('v.value', ( capturedCheckboxVal ) ? enrolment.AS_Primary_Unit_details__c : '' );
            }

            if( y[x].get('v.name') == 'alterstreetnumber' ) {
                y[x].set('v.value', ( capturedCheckboxVal ) ? enrolment.AS_Primary_Street_Number__c : '' );
            }

            if( y[x].get('v.name') == 'altershippingstreet' ) {
                y[x].set('v.value', ( capturedCheckboxVal ) ? altershippingstreet : '' );
            }

            if( y[x].get('v.name') == 'altershippingcity' ) {
                y[x].set('v.value', ( capturedCheckboxVal ) ? altershippingcity : '' );
            }

            if( y[x].get('v.name') == 'altershippingstate' ) {
                y[x].set('v.value', ( capturedCheckboxVal ) ? altershippingstate : '' );
            }

            if( y[x].get('v.name') == 'alterpostalcode' ) {
                y[x].set('v.value', ( capturedCheckboxVal ) ? alterpostalcode : '' );
            }
        }
    },

    changeEnrolState : function(cmp, event, helper) {
        var enrolstate = cmp.get('v.enrolment');
        enrolstate.AS_Enrollment_State__c =  event.getSource().get('v.value');
    },
})