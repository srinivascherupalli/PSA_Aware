({
    doInit: function(cmp, event, helper){ 

        // Updated by jet
        var accId = helper.getQueryParams( 'accountid' );
        var enrolId = helper.getQueryParams( 'enrolid' );

        cmp.set("v.accountId", accId );
        cmp.set("v.enrolId", enrolId );

        helper.accountfunc( cmp, accId );
        helper.enrolfunc( cmp, enrolId );
        helper.preTrainfunc( cmp, enrolId );

    },
    customhelp : function( cmp, event, helper ) {
        console.log( cmp.get('v.enrolment') );
    },
    handleComponentEvent : function(cmp, event) {
        var cmpStep = event.getParam("enrolmentStep");

        var completed = cmp.get('v.completed');

        var step = cmpStep.split('-');

        var redirectStep = step[0].trim();

        if( step.length > 1 ) {
            if( step[1].trim() == 'completed' ){
                var stepnum = step[0].match(/\d+/)[0];
                    stepnum = 'step' + parseInt( stepnum - 1 );

                cmp.set('v.completed', stepnum );
            }else if( step[1].trim() == 'back' ) {
                if( completed.length > 0 ) {
                    redirectStep = completed;
                }
            }
        }
        console.log( 'redirectStep', redirectStep );
        cmp.set( "v.currentStep", redirectStep );
    },
    nextStep : function(cmp,event,helper){
        cmp.set("v.currentStep", event.getSource().get("v.value"));
    },

    saveTemp:function(cmp,event,helper){
        cmp.set("v.tempModal",false);
        cmp.set("v.currentStep",'step1');
    },

    closeModaltemp:function(cmp,event,helper){
        cmp.set("v.tempModal",false);
    },

    handleStepClick : function(cmp, event, helpe) { 

        var stepval = event.getSource().get('v.value'),
            intstep = stepval.match(/\d+/)[0];

        var enrol = cmp.get('v.enrolment');

        var currentStep = enrol.AS_Enrolment_Stage__c.match(/\d+/)[0];

        if(
          ( parseInt( currentStep ) >= parseInt( intstep ) || parseInt( currentStep ) == 14 ) ||
          ( enrol.Enrolment_Status__c != 'Draft' && 13 >= parseInt( intstep ) )
        ) {
            cmp.set("v.currentStep", stepval );
        } else {

            var toastEvent = $A.get("e.force:showToast");

            toastEvent.setParams({
                "title": "Warning!",
                "type" : 'warning',
                "message": "You're currently unable to proceed to this page"
            });

            toastEvent.fire()

        }
    }
})