({
    helperMethod : function() {

    },
    getPicklistOption : function( cmp, picklistname, objname, plistvar ) {
        cmp.set("v.showSpinner", true);
        var getpicklistVal = cmp.get("c.getPicklistValue");

        getpicklistVal.setParams({
            "fieldname": picklistname,
            "objectname": objname
        });

        getpicklistVal.setCallback(this,function(response){
            var status = response.getState();
            if( status === "SUCCESS" ) {
                var qresult = response.getReturnValue();
                cmp.set( 'v.' + plistvar, qresult );
            }
        });
        $A.enqueueAction(getpicklistVal);
    },

    getCurrentEnrolment: function( cmp ) {

        var recordID = cmp.get("v.recordIdEnrol");
        var enrolInfo = cmp.get("c.getEnrolmentInfo");

        enrolInfo.setParams({
            "recordID": recordID
        });

        enrolInfo.setCallback(this,function(response){
            var status = response.getState();
            if( status === "SUCCESS" ) {
                var qresult = response.getReturnValue();
                
                if(qresult != null){
                    var arrkeys = Object.keys( qresult );
                    for( var x = 0, newArr = {}; x < arrkeys.length; x++ ) {
                        if( typeof qresult[arrkeys[x]] == 'boolean' ) {
                            if( arrkeys[x] == 'AS_No_Previous_Qualifications__c') {
                                newArr[arrkeys[x]] = ( qresult[arrkeys[x]] ) ? 'false' : 'true';
                            } else {
                                newArr[arrkeys[x]] = ( qresult[arrkeys[x]] ) ? 'true' : 'false';
                            }
                           
                        } else {
                            newArr[arrkeys[x]] = qresult[arrkeys[x]];
                        }
                    }
                   
                }
                console.log( 'newArr', newArr );
                cmp.set("v.enrolment",newArr);
            }
            cmp.set("v.showSpinner", false);
        });
        $A.enqueueAction(enrolInfo);
    },

    getCurrentQualification: function( cmp ) {

        var QualificationInfo = cmp.get("c.getQualificationInfo");

        var recordID = cmp.get("v.recordIdEnrol");

        QualificationInfo.setParams({
            "enrolId": recordID
        });

        QualificationInfo.setCallback(this,function(response){
            var status = response.getState();
            if( status === "SUCCESS" ) {
                var qresult = response.getReturnValue(); 
                if(qresult != null){
                   cmp.set("v.qualification",qresult);
                }
            }
            cmp.set("v.showSpinner", false);
        });
        $A.enqueueAction(QualificationInfo);
    },

    saveChanges : function( cmp, sendmelink ) {
        var toastEvent = $A.get("e.force:showToast");
        cmp.set("v.showSpinner", true);

        var enrolInfo = cmp.get("v.enrolment");
        var qualInfo = cmp.get("v.qualification");
        var accId = cmp.get("v.recordId");
        var enrolId = cmp.get("v.recordIdEnrol");

        enrolInfo.AS_No_Previous_Qualifications__c = ( enrolInfo.AS_No_Previous_Qualifications__c == 'false' ) ? 'true' : 'false';

        console.log( 'enrolInfo.AS_No_Previous_Qualifications__c', enrolInfo.AS_No_Previous_Qualifications__c );

        var saveChanges = cmp.get("c.saveChanges");

        saveChanges.setParams({
            "enrolId": enrolId,
            "enrolRecord" : enrolInfo,
            "qualRecord" : qualInfo,
            "accId" : accId,
            "sendmelink" : sendmelink
        });

        saveChanges.setCallback( this, function( response ) {
            var status = response.getState();
            if( status === "SUCCESS" ) {
                var rBody = response.getReturnValue();
                console.log( 'rBody', rBody );

                // delete qualifaction
                var qualids = cmp.get("v.tobedeleted");
                this.deleteQualification( cmp, qualids );
                
                cmp.set("v.showSpinner", false);

                if( sendmelink ) {
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : 'success',
                        "message": "Email has been sent!"
                    });
                    toastEvent.fire();
                } else {
                    this.callNextStep( cmp );
                }
            } else {
                cmp.set("v.showSpinner", false);
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : 'error',
                    "message": "Please fill up the required fields!"
                });
                toastEvent.fire();
                console.log( response.getError() );
            }
        });
        $A.enqueueAction( saveChanges );

    },

    deleteQualification : function( cmp, tobedeleted ) {

        try {
            
            var deleteQual = cmp.get("c.deleteQualification");

            deleteQual.setParams({
                "qualIds": tobedeleted
            });

            deleteQual.setCallback( this, function( response ) {
                var status = response.getState();
                if( status === "SUCCESS" ) {
                    var rBody = response.getReturnValue();
                    console.log( 'success', rBody );
                } else {
                    console.log( 'error', response.getError() );
                }

            });
            
            $A.enqueueAction( deleteQual );

        } catch ( e ) {
            console.log( 'exception !!!!', e )
        }

    },

    callNextStep :function(cmp) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
        cmpEvent.setParams({
            enrolmentStep : "step7"});
        cmpEvent.fire();
    },

    backCallback: function( cmp ) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
        cmpEvent.setParams({
            enrolmentStep : "step5"});
        cmpEvent.fire();
    },

})