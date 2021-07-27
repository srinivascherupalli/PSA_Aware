({
    doInit : function(component, event, helper) {

        helper.getEvents( component, helper );
        
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;

    },
    saveSendLink: function( cmp, event, helper ){

        // Updated by Juniel PRI-198
        //var doms = document.getElementsByClassName("inputSelected");
        var doms = cmp.find('slds-event-selection');
        var enrolId = cmp.get('v.EnrollmentId');
        var parameterMap = {};

  
        for(var i = 0; i < doms.length; i++)
        {
            var elemenDoms = doms[i].getElement();

            if(  elemenDoms.checked ){

                var eventSessionId =  elemenDoms.getAttribute("data-event-session");
                var tplanId = elemenDoms.getAttribute("data-tplan");
                parameterMap[eventSessionId] = tplanId;

            } 
 
        }
  
        var action = cmp.get("c.createAttendeeFromSession");

        action.setParams({ 
            "params": parameterMap,
            "enrolId" : enrolId,
            "sendmelink" : true
        });  
        
        action.setCallback(this, function(response) {
            var status = response.getState();

            if( status === "SUCCESS" ) {

                var toastEvent = $A.get("e.force:showToast");
                
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "Email has been sent"
                });
                toastEvent.fire();
                
            } else {
                console.log('err');
            }

            cmp.set('v.showSpinner', false );
        });  

        $A.enqueueAction(action);

         
    },
  
    saveRecord: function( cmp, event, helper ){

        // Updated by Juniel PRI-198
        cmp.set('v.showSpinner', true );

        var doms = cmp.find('slds-event-selection');
        var enrolId = cmp.get('v.EnrollmentId');
        var parameterMap = {};
  
        for(var i = 0; i < doms.length; i++)
        {
            var elemenDoms = doms[i].getElement();

            if(  elemenDoms.checked ){

                var eventSessionId =  elemenDoms.getAttribute("data-event-session");
                var tplanId = elemenDoms.getAttribute("data-tplan");
                parameterMap[eventSessionId] = tplanId;

            } 
        }

        var action = cmp.get("c.createAttendeeFromSession");

        action.setParams({ 
            "params": parameterMap,
            "enrolId" : enrolId,
            "sendmelink" : false
        });  
        
        action.setCallback(this, function(response) {
            var status = response.getState();

            if( status === "SUCCESS" ) {
                helper.callNextStep( cmp, 'step11', true );
            } else {
                console.log('err');
            }

            cmp.set('v.showSpinner', false );
        });  

        $A.enqueueAction(action);
    },
    cancelcallback : function( cmp, event, helper ){
        cmp.set("v.showSpinner", true);
        
        var enrolId = cmp.get("v.EnrollmentId");
        var deleteEnrol = cmp.get("c.deleteEnrolment");

        deleteEnrol.setParams({
            "enrolId": enrolId
        });

        deleteEnrol.setCallback( this, function( response ) {
            var status = response.getState();
            if( status === "SUCCESS" ) {
                var rBody = response.getReturnValue();
                console.log( 'rBody', rBody );
            } else {
                console.log( response.getError() );
            }
            cmp.set("v.showSpinner", false);
        });
        $A.enqueueAction( deleteEnrol );

    },
    backCallback: function( cmp, event, helper ) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
        cmpEvent.setParams({
            enrolmentStep : "step9 - back"
        });
        cmpEvent.fire();
    },

    cancelCallback : function( cmp, event, helper ) {
        helper.deleteCallback( cmp, helper );
    },

    saveProcess: function( comp , maps, enrolId, isEmail, helper ){
        console.log('saveProcess', saveProcess );
        cmp.set('v.showSpinner', true );

        var action = comp.get("c.createAttendeeFromSession");
        action.setParams({ "params": maps });  
        
        action.setCallback(this, function(response) {
            //Updated Juniel - PRI-198
            var status = response.getState();
            console.log('status saveProcess', status);
            if( status === "SUCCESS" ) {
            // alert('Save!!');
                helper.callNextStep( comp, 'step11' );
            } else {
                console.log('err');
            }

            cmp.set('v.showSpinner', false );
        });  

        $A.enqueueAction(action);

    },
})