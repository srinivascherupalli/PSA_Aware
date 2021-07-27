({ 
    UnitsIdObj : {},
    RemainingPackage : 0,
    NumberOfElectives : 0,
    sleep  : function(time) {
 		//return new Promise((resolve) => setTimeout(resolve, time));
    },

    backCallback: function( cmp ) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
        cmpEvent.setParams({
            enrolmentStep : "step8 - back"
        });
        cmpEvent.fire();
    },

    callNextStep :function(cmp , iscompleted ) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
        
        var nextStep =  'step10';

        if( iscompleted ) {
            nextStep = 'step10 - completed';
        }

        cmpEvent.setParams({
            enrolmentStep : nextStep
        });//change to step10 if event is now available
        cmpEvent.fire();
    },

    // enroLLUnit: function (component, lpuID, callback) {
    //     var action = component.get('c.createEnrolledUnits');
    //     console.log('LPUID is get? '+lpuid);
    //     action.setParams({
    //                         "AccountId": component.get('v.accountId'),
    //                         "EnrollmentId": component.get('v.enrollmentId'),
    //                         "lpuID" : lpuID
    //                     });
        
    //     action.setCallback(this, function(a) {  

    //         var res = a.getReturnValue();  
    //         callback( res )
            
    //     });    
    //     $A.enqueueAction(action); 
    // }

})