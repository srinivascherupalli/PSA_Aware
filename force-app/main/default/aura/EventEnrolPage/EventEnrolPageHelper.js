({
	getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    getType: function(component, event, trainingplanId, track){
        var action = component.get("c.getAccessType");
        action.setParams({
            trainingplanId: trainingplanId,
            isTrack : track
        });
        action.setCallback(this,function(response){
                if (response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    //console.log( 'types', result );
                    component.set('v.member', result);
                } 
            }
        );
        $A.enqueueAction(action);
    },
    getUrl: function(component, event){
        var action = component.get("c.getUrl");
        
        action.setCallback(this,function(response){
                if (response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    //console.log( 'url', result );
                    component.set('v.url', result);
                }
            }
        );
        $A.enqueueAction(action);
    },
    getEventList: function(component, event, trainingplanId, track) {
      
        var action = component.get("c.getEvnts");
        action.setParams({
            trainingplanId: trainingplanId,
            isTrack : track
        });
        action.setCallback(this,function(response){
                    //console.log('events ',response.getReturnValue());
                if (response.getState() === "SUCCESS"){
                    var events = response.getReturnValue();
                    //console.log(events);
                    if(events.length == 0){
                        component.set('v.hasEvent', false);
                    }
                    events = this.genVarietyOfDateFromEvents(events);
                    //console.log(component.get('v.hasEvent'));

                    //console.log('evnt: ',events);
                    component.set("{!v.events}", events);
                }
            }
        );
        //component.set("v.modalShow", true);
        $A.enqueueAction(action);
    },
    getIcon: function(component, event, trainingplanId, track){
        var action = component.get("c.getIcon");
        action.setParams({
            trainingplanId: trainingplanId,
            isTrack : track
        });
        action.setCallback(this,function(response){
                if (response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    //console.log('Icon: ',result.length);
                    if(result.length != 0){
                        var a = result[0].Eligible_Image__c.split('src="')[1].split('"')[0].replace('&amp;','&');
                        a = a.replace('&amp;','&');
                        //console.log('a: ',a);
                        component.set("{!v.icon}", a);
                    }
                   // component.set("{!v.icon}", result);
                }
            }
        );
        $A.enqueueAction(action);
    },
    getLearning: function(component, event, trainingplanId, track){
        var action = component.get("c.getLearnings");
        action.setParams({
            trainingplanId: trainingplanId,
            isTrack : track
        });
        action.setCallback(this,function(response){
                if (response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    if(result != null && result.learning.length == 1) { 
                        component.set('v.learnOnlyOne', true);
                        component.set('v.modalShow', true);
                    }
					if(result == 0) component.set('v.hasEvent', false);
                    //console.log('learning',result);
                    component.set('v.learnCountTotal', result.learning.length);
                    component.set('v.learnings', result.learning);
                    component.set('v.trainLearning', result.learningTrFinal);
                    
                }
            }
        );
        $A.enqueueAction(action);
    },
    getPrice: function(component, event, trainingplanId) {
        var action = component.get("c.getPrice");
        action.setParams({
            trainingplanId: trainingplanId
        });
        action.setCallback(this,function(response){
                if (response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    var getGST = result.UnitPrice / result.Product2.AS_Taxable_Rate__c;
                    var UnitPrice = (result.UnitPrice - getGST);
                    //console.log("Result Value : " + UnitPrice);
                    
                    component.set('v.priceBookEntry', result);
                }
            }
        );
        $A.enqueueAction(action);
    },
    getEvent: function(component, event, evntId) {
        var action = component.get("c.getEvent");
        action.setParams({
            evntId: evntId
        });
        action.setCallback(this,function(response){
                if (response.getState() === "SUCCESS"){
                    var result = response.getReturnValue(),
                        result = this.genVarietyOfDateFromEvents([result]);

                    component.set('v.event', result[0] ? result[0] : {});
                }
            }
        );
        $A.enqueueAction(action);
    },
    resetVars: function(component) {
    	component.set("v.trainingPlan", {});
        component.set("v.trainingId", null);
        component.set("v.eventId", '');
        component.set("v.canProceed", false);
    },
    genVarietyOfDateFromEvents: function(events) {
        /* format date and time */
        for (var i = 0; i < events.length; i++) {
            var sd = events[i].AS_Start_Date__c,
                ed = events[i].AS_End_Date__c,
                st = events[i].AS_Session_Campaign__r.Start_Time_Text__c,
                et = events[i].AS_Session_Campaign__r.End_Time_Text__c;
                
            
            events[i].singleDayOfSD = this.formatDate(sd, 'd');
            events[i].dayOfSD = this.formatDate(sd, 'dd');
            events[i].dayOfWeekSD = this.formatDate(sd, 'EEE');
            events[i].monthOfSD = this.formatDate(sd, 'MMMM');
            events[i].singleDayEndOfSD = this.formatDate(ed, 'd');
            events[i].dayEndOfSD = this.formatDate(ed, 'dd');
            events[i].dayOfEndWeekSD = this.formatDate(ed, 'EEE');
            events[i].monthOfEndSD = this.formatDate(ed, 'MMMM');
            events[i].yearOfSD = this.formatDate(sd, 'YYYY');
            events[i].yearOfED = this.formatDate(ed, 'YYYY');
            events[i].st = st;
            events[i].et = et;
            /*
            events[i].st = this.formatTime(st, 'h:mm a');
            events[i].et = this.formatTime(et, 'h:mm a');
            */
            
            //if (events[i].Space_Remaining__c) {
                if (events[i].Space_Remaining__c <= 0) {
                    events[i].space = 'soldout';
                } else if (events[i].AS_Total_Capacity__c && this.calcRemainingPercentage(events[i].Space_Remaining__c, events[i].AS_Total_Capacity__c) <= 25) {
                    events[i].space = 'almost_soldout'
                } else {
                    events[i].space = 'available'
                }
            //}
        }

        return events;
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
    isGuestAccess: function(component, event) {
        var action = component.get("c.isGuestUserAccess");
        action.setCallback(this,function(response){
                if (response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    component.set('v.isGuest',result);
                }
            }
        );
        $A.enqueueAction(action);
    },
    
    eventEnrolCreate: function( component, event, learnId ) {
        var action = component.get("c.createEnrolment");
        action.setParams({
            learning : learnId,
        });
        action.setCallback(this,function(response){
            if ( response.getState() == 'SUCCESS' ) {
                var qresult = response.getReturnValue();
                //console.log( qresult );
                window.setTimeout(
                    $A.getCallback(function() {
                        window.open( window.location.origin + '/s/enrolment-form?accountid=' + qresult.AS_Account__c + '&enrolid=' + qresult.Id );
                    }), 0
                );
                window.setTimeout(
                    $A.getCallback(function() {
                        window.history.go(-1);
                    }), 100
                );
            } else {
                console.log( response.getError() );
            }
            
        });
        $A.enqueueAction(action);
    }
})