({
	getPicklistOption : function(cmp,picklistname,objname) {

        var getpicklistVal = cmp.get("c.getPicklistValue");

        getpicklistVal.setParams({
            "fieldname": picklistname,
            "objectname": objname
        });

        getpicklistVal.setCallback(this,function(response){
            var status = response.getState();

            if(status === "SUCCESS"){

                var picklistVariable;

                if(picklistname === 'Gender__pc') picklistVariable = cmp.get("v.gender");

                var qresult = response.getReturnValue();

                if(qresult.length > 0){

                    for(var key in qresult) { 
                        picklistVariable.push(qresult[key]);
                    }
                    if(picklistname === 'Gender__pc') cmp.set("v.gender", picklistVariable);
                }
            }
        });
        $A.enqueueAction(getpicklistVal);
    },

    getEnrolmentStateList : function( cmp, fieldname, objname ) {

        var func = cmp.get("c.getPicklistValue");

        func.setParams({
            "fieldname": fieldname,
            "objectname": objname
        });

        func.setCallback( this, function(response){

            var status = response.getState();
            var reval = response.getReturnValue();

            if(status === "SUCCESS"){

                cmp.set('v.enrolmentlist', reval );
            }
        });

        $A.enqueueAction(func);

    },

    getPicklistOptionSalutation : function(cmp,picklistname,objname) {

        var getpicklistVal = cmp.get("c.getPicklistValue");

        getpicklistVal.setParams({
            "fieldname": picklistname,
            "objectname": objname
        });

        getpicklistVal.setCallback(this,function(res){
            var status = res.getState();
            var qresult = res.getReturnValue();
            if(status === "SUCCESS"){
                cmp.set('v.salutation', qresult );
            }
        });
        $A.enqueueAction(getpicklistVal);
    },

    getAccRecord : function(cmp) {
        var recordID = cmp.get("v.recordId");

        var enrolInfo = cmp.get("c.getAccountInfo");

        enrolInfo.setParams({
            "recordID": recordID
        });

        enrolInfo.setCallback(this,function(response){
            var status = response.getState();

            if(status === "SUCCESS"){

                var qresult = response.getReturnValue();

                if( qresult != null ){

                    cmp.set("v.account",qresult);

                    if(qresult.AS_Unique_Student_Identifier__c === null || qresult.AS_Unique_Student_Identifier__c === undefined ){
                        cmp.set("v.disabledUSI", false);
                    } else {
                        cmp.set("v.disabledUSI", true);
                    }
                }
            }
        });
        $A.enqueueAction(enrolInfo);
    },

    getEnrolmentRecord : function(cmp) {
        var recordID = cmp.get("v.recordIdEnrol");
        var enrolInfo = cmp.get("c.getEnrolmentInfo");

        enrolInfo.setParams({
            "recordID": recordID
        });

        enrolInfo.setCallback(this,function(response){
            var status = response.getState();

            if(status === "SUCCESS"){

                var qresult = response.getReturnValue();

                if( qresult.Enrolment_Status__c === 'Draft' ) {
                    cmp.set("v.enrolDraf",false);
                }

                var account = cmp.get('v.account');

                if( qresult.AS_Unique_Student_Identifier__c != undefined || qresult.Enrolment_Status__c != 'Draft' ){
                    cmp.set("v.disabledUSI", true);
                }

                qresult.AS_Title__c = ( typeof qresult.AS_Title__c == 'undefined' ) ? ( typeof account.PersonTitle == 'undefined' ) ? '' : account.PersonTitle : qresult.AS_Title__c;
                qresult.AS_Given_Name__c = ( typeof qresult.AS_Given_Name__c == 'undefined' ) ? ( typeof account.FirstName == 'undefined' ) ? '' : account.FirstName : qresult.AS_Given_Name__c;
                qresult.AS_Surname__c = ( typeof qresult.AS_Surname__c == 'undefined' ) ? ( typeof account.LastName == 'undefined' ) ? '' :  account.LastName : qresult.AS_Surname__c;
                qresult.AS_second_given_name__c = ( typeof qresult.AS_second_given_name__c == 'undefined' ) ? ( typeof account.AS_Middle_Name__pc == 'undefined' ) ? '' : account.AS_Middle_Name__pc : qresult.AS_second_given_name__c;
                qresult.AS_Preferred_Name__c = ( typeof qresult.AS_Preferred_Name__c == 'undefined' ) ? ( typeof account.PSA_Preferred_Name__c == 'undefined' ) ? '' : account.PSA_Preferred_Name__c : qresult.AS_Preferred_Name__c;
                qresult.AS_Date_of_Birth__c = ( typeof qresult.AS_Date_of_Birth__c == 'undefined' ) ? ( typeof account.PersonBirthdate == 'undefined' ) ? '' : account.PersonBirthdate : qresult.AS_Date_of_Birth__c;
                qresult.AS_Gender__c = ( typeof qresult.AS_Gender__c == 'undefined' ) ? ( typeof account.Gender__pc == 'undefined' ) ? '' : account.Gender__pc : qresult.AS_Gender__c;
                qresult.AS_Home_Phone__c = ( typeof qresult.AS_Home_Phone__c == 'undefined' ) ? ( typeof account.PersonHomePhone == 'undefined' ) ? '' : account.PersonHomePhone : qresult.AS_Home_Phone__c;
                qresult.AS_Work_Phone__c = ( typeof qresult.AS_Work_Phone__c == 'undefined' ) ? ( typeof account.AS_Work_Phone__pc == 'undefined' ) ? '' : account.AS_Work_Phone__pc : qresult.AS_Work_Phone__c;
                qresult.AS_Mobile_Phone__c = ( typeof qresult.AS_Mobile_Phone__c == 'undefined' ) ? ( typeof account.PersonMobilePhone == 'undefined' ) ? '' : account.PersonMobilePhone : qresult.AS_Mobile_Phone__c;
                qresult.AS_Email__c = ( typeof qresult.AS_Email__c == 'undefined' ) ? ( typeof account.PersonEmail == 'undefined' ) ? '' : account.PersonEmail : qresult.AS_Email__c;
                qresult.AS_Primary_Street__c = ( typeof qresult.AS_Primary_Street__c == 'undefined' ) ? ( typeof account.BillingStreet == 'undefined' ) ? '' :  account.BillingStreet : qresult.AS_Primary_Street__c;
                qresult.AS_Primary_Suburb_Town__c = ( typeof qresult.AS_Primary_Suburb_Town__c == 'undefined' ) ? ( typeof account.BillingCity == 'undefined' ) ? '' : account.BillingCity : qresult.AS_Primary_Suburb_Town__c;
                qresult.AS_Primary_State__c = ( typeof qresult.AS_Primary_State__c == 'undefined' ) ? ( typeof account.BillingState == 'undefined' ) ? '' :  account.BillingState : qresult.AS_Primary_State__c;
                qresult.AS_Primary_Postcode__c = ( typeof qresult.AS_Primary_Postcode__c == 'undefined' ) ? ( typeof account.BillingPostalCode == 'undefined' ) ? '' : account.BillingPostalCode : qresult.AS_Primary_Postcode__c;
                qresult.AS_Alternate_Street__c = ( typeof qresult.AS_Alternate_Street__c == 'undefined' ) ? ( typeof account.ShippingStreet == 'undefined' ) ? '' : account.ShippingStreet : qresult.AS_Alternate_Street__c;
                qresult.AS_Alternate_Suburb__c = ( typeof qresult.AS_Alternate_Suburb__c == 'undefined' ) ? ( typeof account.ShippingCity == 'undefined' ) ? '' :  account.ShippingCity : qresult.AS_Alternate_Suburb__c;
                qresult.AS_Alternate_State__c = ( typeof qresult.AS_Alternate_State__c == 'undefined' ) ? ( typeof account.ShippingState == 'undefined' ) ? '' :  account.ShippingState : qresult.AS_Alternate_State__c;
                qresult.AS_Alternate_Postcode__c = ( typeof qresult.AS_Alternate_Postcode__c == 'undefined' ) ? ( typeof account.ShippingPostalCode == 'undefined' ) ? '' :  account.ShippingPostalCode : qresult.AS_Alternate_Postcode__c;
                qresult.AS_Unique_Student_Identifier__c = ( typeof qresult.AS_Unique_Student_Identifier__c == 'undefined' ) ? ( typeof account.AS_Unique_Student_Identifier__c == 'undefined' ) ? '' :  account.AS_Unique_Student_Identifier__c : qresult.AS_Unique_Student_Identifier__c;
                qresult.AS_VSN__c = ( typeof qresult.AS_VSN__c == 'undefined' ) ? ( typeof account.AS_VSN__c == 'undefined' ) ? '' :  account.AS_VSN__c : qresult.AS_VSN__c;

                qresult.AS_Enrollment_State__c = ( typeof qresult.AS_Enrollment_State__c == 'undefined' ) ? ( typeof account.PersonMailingState == 'undefined' ) ? '' : account.PersonMailingState : qresult.AS_Enrollment_State__c;

                qresult.AS_Unique_Student_Identifier__c = ( typeof qresult.AS_Unique_Student_Identifier__c == 'undefined' ) ? ( typeof account.AS_Unique_Student_Identifier__pc == 'undefined' ) ? '' : account.AS_Unique_Student_Identifier__pc : qresult.AS_Unique_Student_Identifier__c;

                qresult.AS_VSN__c = ( typeof qresult.AS_VSN__c == 'undefined' ) ? ( typeof account.AS_VSN__pc == 'undefined' ) ? '' : account.AS_VSN__pc : qresult.AS_VSN__c;
                

                console.log('qresult', qresult );

                console.log('account', account );
                cmp.set( "v.enrolment", qresult );

                cmp.set('v.showSpinner', false );
            }
        });
        $A.enqueueAction(enrolInfo);
    },

    saveEnrolmentRecord : function( cmp, helper, isEmail ) {
        //this method is use to save enrolment record
        var toastEvent = $A.get("e.force:showToast");

        var enrolInfo = cmp.get("v.enrolment");
        var recordId = cmp.get("v.recordId");
        var recordIdEnrol = cmp.get("v.recordIdEnrol");

        var saveEnrolInfo = cmp.get("c.saveEnrolmentInfo");

        console.log( 'enrolInfo', enrolInfo );

        saveEnrolInfo.setParams({
            "enrolRecord": enrolInfo,
            "enrolmentID": recordIdEnrol,
            "isEmail": isEmail
        });

        saveEnrolInfo.setCallback(this,function(response){
            var status = response.getState();
            var qresult = response.getReturnValue();

            if(status === "SUCCESS"){
                
                if( isEmail ) {
                    
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : 'success',
                        "message": "Email has been sent"
                    });
                    toastEvent.fire();
                } else {
                    helper.callNextStep(cmp, true);
                }
                cmp.set("v.showSpinner", false);
            }else{

                toastEvent.setParams({
                    "title": "Error!",
                    "type" : 'error',
                    "message": "Failed to save Enrolment information!"
                });
                toastEvent.fire();

                cmp.set("v.showSpinner", false);
            }
            
        });
        $A.enqueueAction(saveEnrolInfo);
    },

    updateSecondGivenName : function( cmp ) {
   
        var func = cmp.get('c.updateEnrolmentInfo');

        var secondgivenname = cmp.find('secondgivenname').get('v.value');

        var recordId = cmp.get('v.recordIdEnrol');

        var obj = {
            'AS_second_given_name__c' : secondgivenname
        }

        func.setParams({
            'enrolmentID' : recordId,
            'enrolRecord' : JSON.stringify( obj )
        });

        func.setCallback(this,function( res ){
            var status = res.getState();
            var qresult = res.getReturnValue();

            if( status === "SUCCESS" ){
                
            }
        });
        $A.enqueueAction(func);
    },

    callNextStep :function(cmp , iscompleted ) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");

        var nextstep = ( iscompleted ) ? 'step4 - completed' : 'step4' ;

        cmpEvent.setParams({
            enrolmentStep : nextstep});
        cmpEvent.fire();
    },

    saveandContinue : function( cmp, event, isEmail ) {
    }
})