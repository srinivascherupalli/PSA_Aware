({
    getRecrods : function(component , callback) {

        var action = component.get('c.InitPaymentPage');
 
        action.setParams({
                            "AccountId": component.get('v.accountId'),
                            "EnrollmentId": component.get('v.enrollmentId')
                        });
        
        action.setCallback(this, function(a) {  

            var res = a.getReturnValue();  
            callback( res )
            
        });    
        $A.enqueueAction(action); 
 
    },
    currencyFormat: function( num ){
        return '$' + num.toFixed(2).replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,')
    },
    
    backCallback: function( cmp ) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
        cmpEvent.setParams({
            enrolmentStep : "step12 - back"});
        cmpEvent.fire();
    },

    callNextStep :function(cmp) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
        cmpEvent.setParams({
            enrolmentStep : "step14"});
        cmpEvent.fire();
    },

    createdOppId: '',

    selectedPriceBookId: 0,
    unitPrice: 0,
    priceBookName: '',
    //update enrolment status to pending payment if opportunity is created via continue with payment
    updateEnrolToPendingpayment: function (component, callres) {

        var updateEnrToPendingPayment = component.get("c.updateEnrollmentToPendingPayment");
        updateEnrToPendingPayment.setParams({ "EnrollmentId": component.get('v.enrollmentId')
                                            ,"acctId": component.get('v.accountId')
                                        });
        updateEnrToPendingPayment.setCallback(this, function(response) {
            var getStat = response.getState();
            var getRet = response.getReturnValue();
            //console.log('Enrolment: return'+getRet);
            callres(getRet);
           
            });
        $A.enqueueAction(updateEnrToPendingPayment);
    },
    //update enrolment,status to pending if funded
    updateEnrolToPending: function (component, callres) {

        var updateEnrToPending = component.get("c.updateEnrollmentToPending");
        updateEnrToPending.setParams({ "EnrollmentId": component.get('v.enrollmentId')
                                            ,"acctId": component.get('v.accountId')
                                        });
        updateEnrToPending.setCallback(this, function(response) {
            var getStat = response.getState();
            var getRet = response.getReturnValue();
            //console.log('Enrolment: return'+getRet);
            callres(getRet);
           
            });
        $A.enqueueAction( updateEnrToPending );
    },
    
    updateEnrolToPendingAndCreateOpp: function (component, callres) {

        var updateEnrToPendingAndCreateOpp = component.get("c.updateEnrollmentToPendingAndCreateOpp");
        updateEnrToPendingAndCreateOpp.setParams({ "EnrollmentId": component.get('v.enrollmentId')
                                            ,"acctId": component.get('v.accountId')
                                        });
        updateEnrToPendingAndCreateOpp.setCallback(this, function(response) {
            var getStat = response.getState();
            var getRet = response.getReturnValue();
            //console.log('Enrolment: return'+getRet);
            callres(getRet);
           
            });
        $A.enqueueAction( updateEnrToPendingAndCreateOpp );
    },

    isVCodeValidated: false ,
    vCodeContainer:'' ,

 
})