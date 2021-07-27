({
    getEvents : function( component, helper ) {
        component.set('v.showSpinner', true );
        var action = component.get("c.loadEvents");
        action.setParams({ "EnrollmentId": component.get('v.EnrollmentId') });
        
        action.setCallback(this, function(response) {
            var status = response.getState();
            var res = response.getReturnValue();

            var objectVar = {
                'UnitName':'',
                'EventSession':''
            };

            var objectArray = [];
            var objIndex = 0; 
            for (var key in res ) {
                objectVar = {};

                objectVar['UnitName'] = res[key][0].learningPackageUnit.AS_Unit__r.Name;
                objectVar['Group'] =  key;

                if( res[key].length > 1 ){
                    objectVar['InputType'] = 'radio';
                } else {
                    objectVar['InputType'] = 'checkbox';
                } 
 
                objectVar['EventSession'] =  res[key];
                
                this.genVarietyOfDateFromEvents( res[key] );
                 
                objectArray.push(objectVar);
 
            }   
            /* Updated Juniel PRI - 198 */
            if( objectArray.length > 0 ) {
                component.set( "v.EventUnits" , objectArray  );
                component.set('v.showSpinner', false );
            } else {
                console.log('skitp redirect to step11');
                helper.callNextStep( component, 'step11' );
            }
            
        }); 
        $A.enqueueAction(action);

    },
    genVarietyOfDateFromEvents: function(EventUnits) {

        /* format date and time */
        for (var i = 0; i < EventUnits.length; i++) {

            var events = EventUnits[i].eventSession;
       
            var sd = events.AS_Start_Date__c,
                ed = events.AS_End_Date__c,
                st = events.AS_Start_Time__c,
                et = events.AS_End_Time__c;


            events.singleDayOfSD = this.formatDate(sd, 'd');
            events.dayOfSD = this.formatDate(sd, 'dd');
            events.dayOfWeekSD = this.formatDate(sd, 'EEE');
            events.monthOfSD = this.formatDate(sd, 'MMMM');
            events.singleDayEndOfSD = this.formatDate(ed, 'd');
            events.dayEndOfSD = this.formatDate(ed, 'dd');
            events.dayOfEndWeekSD = this.formatDate(ed, 'EEE');
            events.monthOfEndSD = this.formatDate(ed, 'MMMM');
            events.yearOfSD = this.formatDate(sd, 'YYYY');
            events.yearOfED = this.formatDate(ed, 'YYYY');
            events.st = this.formatTime(st, 'h:mm a');
            events.et = this.formatTime(et, 'h:mm a');
            
            if (events.Space_Remaining__c <= 0) { 
                events.space = 'soldout';
            } else if (events.AS_Total_Capacity__c && this.calcRemainingPercentage(events.Space_Remaining__c, events.AS_Total_Capacity__c) <= 25) {
                events.space = 'almost_soldout'
            } else {
                events.space = 'available'
            }
       
        }  

        //console.log( {events} ); 

       //return events;
    },
    calcRemainingPercentage: function(remaining, total) {
        return remaining / total * 100;
    },
    formatDate: function(date, format) {
        return date ? $A.localizationService.formatDate(date, format) : '';
    },
    formatTime: function(time, format) {
        return time ? $A.localizationService.formatTime(time, 'h:mm a') : '';
    },
    // Updated Juniel PRI-198
    // saveProcess: function( comp , maps, enrolId, isEmail, helper ){
    //     console.log('saveProcess', saveProcess );
    //     cmp.set('v.showSpinner', true );

    //     var action = comp.get("c.createAttendeeFromSession");
    //     action.setParams({ "params": maps });  
        
    //     action.setCallback(this, function(response) {
    //         //Updated Juniel - PRI-198
    //         var status = response.getState();
    //         console.log('status saveProcess', status);
    //         if( status === "SUCCESS" ) {
    //         // alert('Save!!');
    //             helper.callNextStep( comp, 'step11' );
    //         } else {
    //             console.log('err');
    //         }

    //         cmp.set('v.showSpinner', false );
    //     });  

    //     $A.enqueueAction(action);

    // },
    /* Juniel PRI - 198 */
    callNextStep :function(cmp , step, iscompleted ) {
        var cmpEvent = cmp.getEvent("Enrolment_Event");
        var cmpEvent = $A.get("e.c:EnrolmentActiveStep");

        if( iscompleted ) {
            step = 'step11 - completed';
        }

        cmpEvent.setParams({
            enrolmentStep : step });
        cmpEvent.fire();
    },

    deleteCallback : function( cmp, helper ) {

        var toastEvent = $A.get("e.force:showToast");
        var recordIdEnrol = cmp.get("v.EnrollmentId");

        var func = cmp.get("c.deleteEnrolment");
        
        func.setParams({
            "enrolId": recordIdEnrol
        });

        func.setCallback(this,function(response){
            var status = response.getState();

            if( status === "SUCCESS" ) {
                var qresult = response.getReturnValue();    

                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": qresult
                });
                toastEvent.fire();

                window.location.href = window.location.origin + '/s/my-enrolments';

                //cmp.set('v.showSpinner', false );
            } else {
                console.log('err', err );
            }

        });
        $A.enqueueAction(func);

    }
    
})