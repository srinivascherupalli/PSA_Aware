({
    
    getPicklistOption : function(cmp,picklistname) {
        var getpicklistVal = cmp.get("c.getPicklistValue");
        
        getpicklistVal.setParams({
            "fieldname": picklistname,
            "objectname": 'Enrolment_Form__c'
        });
        
        getpicklistVal.setCallback(this,function(response){
            var status = response.getState();
            if(status === "SUCCESS"){
                
                var picklistVariable;
                if(picklistname === 'AS_Employment_State__c') picklistVariable = cmp.get("v.employmentState");
                if(picklistname === 'AS_Employment_Status__c') picklistVariable = cmp.get("v.employmentStatus");
                if(picklistname === 'Recent_Occupation__c') picklistVariable = cmp.get("v.recentOccupation");
                if(picklistname === 'Industry__c') picklistVariable = cmp.get("v.industry");
                
                var qresult = response.getReturnValue();
                if(qresult.length > 0){
                    for(var key in qresult) { 
                        picklistVariable.push(qresult[key]);
                    }
                    if(picklistname === 'AS_Employment_State__c') cmp.set("v.employmentState", picklistVariable);
                    if(picklistname === 'AS_Employment_Status__c') cmp.set("v.employmentStatus", picklistVariable);
                    if(picklistname === 'Recent_Occupation__c') cmp.set("v.recentOccupation", picklistVariable);
                    if(picklistname === 'Industry__c') cmp.set("v.industry", picklistVariable);
                }
            }
            cmp.set("v.showSpinner", false);
        });
        $A.enqueueAction(getpicklistVal);
    },
    
    getEnrolmentRecord : function(cmp) {
        var recordID = cmp.get("v.recordIdEnrol");
        cmp.set("v.showSpinner", true);
        
        var enrolInfo = cmp.get("c.getEnrolmentInfo");
        
        enrolInfo.setParams({
            "recordID": recordID
        });
        
        enrolInfo.setCallback(this,function(response){
            var status = response.getState();
            if(status === "SUCCESS"){
                var qresult = response.getReturnValue();
                if(qresult != null){
                    var arrkeys = Object.keys( qresult );
                    for( var x = 0, newArr = {}; x < arrkeys.length; x++ ) {
                        if( typeof qresult[arrkeys[x]] == 'boolean' ) {
                            newArr[arrkeys[x]] = ( qresult[arrkeys[x]] ) ? 'true' : 'false';
                        } else {
                            newArr[arrkeys[x]] = qresult[arrkeys[x]];
                        }
                    }

                    cmp.set('v.defaultindustry', ( typeof newArr.Industry__c != 'undefined' ) ? newArr.Industry__c : 'Health Care and Social Assistance' );
                    cmp.set("v.enrolment",newArr);
                }
            }
            cmp.set("v.showSpinner", false);
        });
        $A.enqueueAction(enrolInfo);
    },
    
    saveEnrolmentRecord : function(cmp, sendmelink) {
        
        cmp.set("v.showSpinner", true);
        var toastEvent = $A.get("e.force:showToast");
        
        var enrolInfo = cmp.get("v.enrolment");

        enrolInfo.Industry__c = cmp.get('v.defaultindustry');

        var recordaccId = cmp.get("v.recordaccId");
        var recordIdEnrol = cmp.get("v.recordIdEnrol");
        
        var saveEnrolInfo = cmp.get("c.saveEnrolmentInfo");
        
        saveEnrolInfo.setParams({
            "enrolRecord": enrolInfo,
            "enrolmentID": recordIdEnrol,
            "recordAccID": recordaccId,
            "sendmelink": sendmelink
        });
        
        saveEnrolInfo.setCallback(this,function(response){
            var status = response.getState();
        
            if(status === "SUCCESS"){
                var qresult = response.getReturnValue();
                if(qresult != null){

                    if( sendmelink ) {
                        cmp.set('v.showSpinner', false );
                        toastEvent.setParams({
                            "title": "Success!",
                            "type" : 'success',
                            "message": "Email has been sent!"
                        });
                        toastEvent.fire();
                        
                    } else {
                        this.callNextStep( cmp, true );
                    }
                    
                }else{
                    cmp.set("v.showSpinner", false);
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : 'error',
                        "message": "Enrolment Object is null!"
                    });
                    toastEvent.fire();
                }
            }else{
                cmp.set("v.showSpinner", false);
                toastEvent.setParams({
                    "title": "Error!",
                    "type" : 'error',
                    "message": "Failed to save Enrolment information!"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(saveEnrolInfo);
    },

    callNextStep :function(cmp, iscompleted) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");

        var nextStep = 'step8';

        if( iscompleted ) {
            nextStep = 'step8 - completed';
        }

        cmpEvent.setParams({
            enrolmentStep : nextStep
        });
        cmpEvent.fire();
    },

    backCallback: function( cmp ) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
        cmpEvent.setParams({
            enrolmentStep : "step6"});
        cmpEvent.fire();
    },
})