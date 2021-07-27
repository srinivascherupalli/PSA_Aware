({
    getFieldsAccount : function( cmp, event ) {

        var accountId = cmp.get('v.accountId');

        var getFieldCallback = cmp.get( 'c.getAccountFields' );

        getFieldCallback.setParams({
            'recordID' : accountId
        });

        getFieldCallback.setCallback( this, function(response) {

            var state = response.getState();
            var fieldval = response.getReturnValue();
            if( state === 'SUCCESS' ) {
                
               var otherenglish = fieldval.AS_BG_Speaks_Languages_Other_Than_Englis__pc;
               var auscitizen = fieldval.AS_Australian_Citizen__pc;

                fieldval.AS_BG_Speaks_Languages_Other_Than_Englis__pc = otherenglish.toString(); 
                fieldval.AS_Australian_Citizen__pc = auscitizen.toString();

                if( typeof fieldval.AS_Country_of_Birth__pc != 'undefined' ) {

                    cmp.set('v.othercountry', ( fieldval.AS_Country_of_Birth__pc == 'Australia' ) ? fieldval.AS_Country_of_Birth__pc : 'Other' );
                } else {
                    cmp.set('v.othercountry', 'Australia' );
                }

                cmp.set('v.account', ( fieldval ) );
            } else {
                console.log('error', returnvar);
            }
        } );

        $A.enqueueAction(getFieldCallback);

    },
    getFieldsEnrolment  : function( cmp, event ) {

        var enrolId = cmp.get('v.enrolId');

        var func = cmp.get( 'c.getEnrolmentInfo' );

        func.setParams({
            'recordID' : enrolId
        });

        func.setCallback( this, function(response) {

            var state = response.getState();
            var fieldval = response.getReturnValue();

            if( state === 'SUCCESS' ) {
                var otherenglish = fieldval.AS_BG_Speaks_Languages_Other_Than_Englis__c;
                var auscitizen = fieldval.AS_Australian_Citizen__c;
 
                fieldval.AS_BG_Speaks_Languages_Other_Than_Englis__c = otherenglish.toString(); 
                fieldval.AS_Australian_Citizen__c = auscitizen.toString();

                if( typeof fieldval.AS_Country_of_Birth__c != 'undefined' ) {

                    cmp.set('v.othercountry', ( fieldval.AS_Country_of_Birth__c == 'Australia' ) ? fieldval.AS_Country_of_Birth__c : 'Other' );
                } else {
                    cmp.set('v.othercountry', 'Australia' );
                }

                cmp.set('v.enrolment', fieldval );

                cmp.set('v.showSpinner', false );
            } else {
                console.log('error', returnvar);
            }
        } );

        $A.enqueueAction(func);

    },
    getFieldPicklist : function( cmp, event ) {
    
        var allFields = [
            'AS_Aboriginal_Torres_Strait_Islander__pc',
            'AS_disability_type__c',
        ];

        for( var x = 0, fieldval = [], newArr = []; x < allFields.length; x++ ) {
            this.PickListValCallback( cmp, allFields[x] );
        }
    },
    PickListValCallback : function( cmp, fieldname ) {

        var fielValue = cmp.get('c.getPickListValue'); 

        fielValue.setParams({
            'fieldname' : fieldname,
            'objectname'  : 'Account'
        });

        fielValue.setCallback( this, function(response) {

            var state = response.getState();
            var fieldval = response.getReturnValue();

            if( state === 'SUCCESS' ) {
                for( var y = 0, thisArr = [] ,arrNew = []; y < fieldval.length; y++ ) {
                    thisArr[y] = {
                        'label' : fieldval[y],
                        'value' : fieldval[y]
                    }
                }
                arrNew = Object.assign( [], thisArr );

                cmp.set( 'v.' + fieldname, arrNew );

            } else {
                console.log('error', returnvar);
            }
        } );

        $A.enqueueAction(fielValue);
    },
    updatecallback : function( cmp, helper, isEmail ) {

        var account = cmp.get('v.account');

        var enrolment = cmp.get('v.enrolment');

        var enrolid = cmp.get('v.enrolId');
        var othercountry = 'Australia';

        try{

            othercountry = cmp.find('othercountryid').get('v.value');
        } catch( err ) {}

        var toastEvent = $A.get("e.force:showToast");

        if( typeof othercountry == 'undefined' ) {

            enrolment.AS_Country_of_Birth__c = (  typeof enrolment.AS_Country_of_Birth__c == 'undefined' ) ? account.AS_Country_of_Birth__pc : enrolment.AS_Country_of_Birth__c;

        } else {

            enrolment.AS_Country_of_Birth__c = othercountry;
        }

        enrolment.AS_City_of_Birth__c = (  typeof enrolment.AS_City_of_Birth__c == 'undefined' ) ? account.AS_City_of_Birth__pc : enrolment.AS_City_of_Birth__c;

        enrolment.AS_Languages_spoken_other_than_English__c = (  typeof enrolment.AS_Languages_spoken_other_than_English__c == 'undefined' ) ? account.AS_Languages_spoken_other_than_English__pc : enrolment.AS_Languages_spoken_other_than_English__c;

        enrolment.AS_Australian_Citizen__c = (  typeof enrolment.AS_Australian_Citizen__c == 'undefined' ) ? ( account.AS_Australian_Citizen__pc == 'true' ) ? true : false : ( enrolment.AS_Australian_Citizen__c == 'true' ) ? true : false;

        enrolment.AS_Aboriginal_or_Torres_Strait_Islander__c = (  typeof enrolment.AS_Aboriginal_or_Torres_Strait_Islander__c == 'undefined' ) ? account.AS_Aboriginal_Torres_Strait_Islander__pc : enrolment.AS_Aboriginal_or_Torres_Strait_Islander__c;

        enrolment.AS_BG_Speaks_Languages_Other_Than_Englis__c = (  typeof enrolment.AS_BG_Speaks_Languages_Other_Than_Englis__c == 'undefined' ) ? ( account.AS_BG_Speaks_Languages_Other_Than_Englis__pc == 'true' ) ? true : false : ( enrolment.AS_BG_Speaks_Languages_Other_Than_Englis__c == 'true' ) ? true : false;

        var func = cmp.get('c.updateEnrolmentInfo');

        func.setParams({
            'recordID' : enrolid,
            'obj'  : enrolment,
            'isEmail' : isEmail
        });

        func.setCallback( this, function(response) {

            var state = response.getState();
            var fieldval = response.getReturnValue();

            if( state === 'SUCCESS' ) {

                if( isEmail ) {
                    
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "success",
                        "message": 'Email has been sent!'
                    });
                    toastEvent.fire();
                } else {
                    helper.callNextStep(cmp, true);
                }

                cmp.set('v.showSpinner', false );
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
    
    callNextStep :function(cmp, iscompleted ) {
      
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");

        var nextstep = ( iscompleted ) ? 'step5 - completed' : 'step5';

        cmpEvent.setParams({
            enrolmentStep : nextstep});
        cmpEvent.fire();
    }
})