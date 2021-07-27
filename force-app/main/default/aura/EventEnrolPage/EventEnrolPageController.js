({
	doInit: function(component, event, helper) {
        var a = component.get("v.proceed");
        //console.log(a);
        var trainingplanId = helper.getParameterByName(component , event, 'id');
        var track = helper.getParameterByName(component , event, 'track');

        var track = helper.getParameterByName(component , event, 'track');
        if ( typeof track != 'undefined' && track != null ) {
            component.set( 'v.checkTextAgree', 'I agree to the Cancellation and Refund Policy' );
        }

        var action = component.get("c.getTrainingPlanType");
        //console.log('trainingplanId: '+trainingplanId);
        //console.log( 'track ' + track );
        //console.log( 'track ' + typeof track );
        action.setParams({
            trainingplanId: trainingplanId,
            isTrack : track
        });
        action.setCallback(this,function(response){
                    //console.log('events ',response.getReturnValue());
                if (response.getState() === "SUCCESS"){
                    var events = response.getReturnValue();
                    component.set("v.free", events);
                }
            }
        );
        $A.enqueueAction(action);
        helper.getEventList(component, event, trainingplanId, track);
        helper.getLearning(component, event, trainingplanId, track);
        helper.getType(component, event, trainingplanId, track);
        helper.getIcon(component , event, trainingplanId, track);
        helper.getUrl(component , event);
        helper.isGuestAccess(component ,event)
    },
    proceedPayment: function(component, event, helper) {

        var track = helper.getParameterByName(component , event, 'track');
        if ( typeof track != 'undefined' && track != null ) {
            var learnId = helper.getParameterByName(component , event, 'learning');
            helper.eventEnrolCreate( component, event, learnId );
        } else {
            var trainingplanId = helper.getParameterByName(component , event, 'id');
            var netid = helper.getParameterByName(component , event, 'netid');
            var url = component.get("v.url");
            url = url+ 'apex/EventEnrolComplete?id='+trainingplanId+'&netid='+netid;//%3Fid='+trainingplanId+'&p=reg';
            window.open(url,"_self");
        }


        /*var agreed = component.get("v.agreed");
        component.set("v.canProceed", false);
       
        if(agreed == true){
            
            var tpEvent = component.get("v.eventId");
            var tpId = component.get("v.trainingId");
            var trainingplanId = helper.getParameterByName(component , event, 'id');
            var url = 'http://alphasys-psa.cs57.force.com/EventEnrolComplete?id='+trainingplanId;//%3Fid='+trainingplanId+'&p=reg';
            
            console.log('evntId: '+tpId);
            console.log('trainingId: '+tpEvent);
            var action = component.get("c.passEvt");
            action.setParams({
                tpId: tpId,
                tpEvent: tpEvent
            });
            $A.enqueueAction(action);
            window.open(url,"_self");
        }
        else alert("Please check that you have agreed to the Terms and Conditions of Registration before confirming your registration.");*/
        
        //window.location = url;
    },
    /*function(component, event, helper) {
        var trainingplanId = helper.getParameterByName(component , event, 'id');
        var url = window.location.origin;
        url = url+'/s/sfdcpage/%2Fapex%2FTrainingPlanDetail%3Fid='+trainingplanId+'?p=reg';
        console.log(url);
        location.href = url;
        location.reload(true);
        //window.location.reload(true);
    },*/
    selectLearning: function(component, event, helper) {
        var learningEl = event.currentTarget,
            learningId = learningEl.dataset.id;
        	//$A.util.addClass(learningId, 'slds-event--active');
        var Elements = component.find('learns');
        
        ////component.set("v.proceed", false);
        for (var i = 0; i < Elements.length; i++) {
            var val = Elements[i].getElement().getAttribute('data-id');
            if(val == learningId){
                $A.util.addClass(Elements[i], 'slds-event--active');
            }
        }

        var action = component.get("c.getEvents");

        //helper.getParameterByName(component, event, 'id'),
        var trainingplanId = component.get('v.trainLearning.' + learningId );

        //console.log('trainingplanId: '+trainingplanId);
        //console.log( 'learningId', learningId );

        action.setParams({
            trainingplanId: trainingplanId,
            learningId : learningId
        });
        action.setCallback(this,function(response){
                    //console.log('events ',response.getReturnValue());
                if (response.getState() === "SUCCESS"){
                    var events = response.getReturnValue();
                   	
                    events = helper.genVarietyOfDateFromEvents(events);
                    component.set("{!v.events}", events);
                }
            }
        );
        component.set("{!v.learningId}", learningId);
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.modalShow", true);
            }), 350
        );
        $A.enqueueAction(action);
    },
    eventSelectDeselect: function(component, event, helper) {
        var eventEl = event.currentTarget,
            eventId = eventEl.dataset.id,
            eventlearn = eventEl.dataset.learning,
            //trainingPlanId = helper.getParameterByName(component, event, 'id'),
            trainingPlanId = component.get('v.trainLearning.' + eventlearn ),
            isEventActive = eventEl.classList.contains('slds-event--active');

            //console.log( 'trainging plan', trainingPlanId );
            //console.log( 'eventId', eventId );
            //console.log( 'learning', eventEl.dataset.learning )

        if (eventEl.classList.contains('slds-event--soldout')) {
            return;
        }

        if (isEventActive) {
            /** If event was active before clicked again **/
            eventEl.classList.remove('slds-event--active');

            helper.resetVars(component);
        } else {
            /** If event was not active before clicked again **/
            if (trainingPlanId) {
                var action = component.get('c.getTrainingPlan');
                
                action.setParams({
                    trainingplanId: trainingPlanId
                });
                
                action.setCallback(this, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        //console.log(response.getReturnValue());
                        component.set('{!v.trainingPlan}', response.getReturnValue());
                    }
                });
                
                $A.enqueueAction(action);
            } else {
                component.set('{!v.trainingPlan}', {});
            }
            
            component.set("v.trainingId", trainingPlanId);
            component.set('v.eventId', eventId);
            component.set("v.canProceed", true);

            var siblingEvents = document.querySelectorAll('.slds-event--active');

            if (siblingEvents.length) {
                for (var i = 0; i < siblingEvents.length; i++) {
                    siblingEvents[i].classList.remove('slds-event--active');
                }
            }
            eventEl.classList.add('slds-event--active');
            helper.getEvent(component , event, eventId);
            helper.getPrice(component , event, trainingPlanId);
        }
    },
    eventSelected: function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var evntId = selectedItem.dataset.id;
        //console.log('evntId: '+evntId);
        var index = selectedItem.dataset.value;
        var action = component.get("c.getTrainingPlan");
        var trainingplanId = helper.getParameterByName(component , event, 'id');

        selectedItem.classList.add('slds-event__active');
        component.set("v.eventId", evntId);
        component.set("v.trainingId", trainingplanId);
        component.set('v.canProceed', true);
        action.setParams({
            trainingplanId: trainingplanId
        });
        action.setCallback(this,function(response){
                    //console.log('trainingplan ',response.getReturnValue());
                if (response.getState() === "SUCCESS"){
                   // component.set("v.trainingplan",response.getReturnValue());
                }
            }
        );
        helper.getEvent(component , event, evntId);
        $A.enqueueAction(action);
    },
    proceedToEventDetails: function(component, event, helper) {
        var isGuest=component.get('v.isGuest');
        console.log('isguest'+isGuest);
        if(isGuest==true){
            
			       //window.history.go(-1);
			 component.set("v.LoginModal",true); 
        }
        else{

        var btn = ( typeof event.target != 'undefined' ) ? event.target : event.currentTarget;
        var learnId = component.get("v.learningId");
        var trainingplanId = component.get("v.trainingId");
        var events = component.get("v.trainingplan");
        //console.log('lalala',trainingplanId);
        var action = component.get("c.getTrainingPlan");
		action.setParams({
            trainingplanId: trainingplanId
        });
        action.setCallback(this,function(response){
                    //console.log('trainingplan ',response.getReturnValue());
                if (response.getState() === "SUCCESS"){
                    component.set("v.trainingplan",response.getReturnValue());
                }
            }
        );
        
        
        if (btn.classList.contains('slds-button_brand') && btn.dataset.id != "") {
        	component.set("v.attend", true);
        }
        $A.enqueueAction(action);
        }
    },
    backToLearningList: function(component, event, helper) {
        var learns = component.get("v.activeLearns");
        component.set("v.canProceed", false);
        
        component.set("v.attend", false);
        component.set("v.modalShow", false);
        
        window.setTimeout(
            $A.getCallback(function() {
                var learns = component.get("v.activeLearns");
                var res = learns.split(",");
                var Elements = component.find('learns');
                
                for (var a = 0; a < res.length; a++) {
                    for (var i = 0; i < Elements.length; i++) {
                        var val = Elements[i].getElement().getAttribute('data-id');
                        if(val == res[a]){
                            $A.util.addClass(Elements[i], 'slds-event--active slds-event--disable');
                        }
                    }
                }
                var Element1 = component.find('select');
                //console.log('Element1 '+Element1);
                //console.log('Element1.length '+Element1.length);
                //console.log( 'res', res );
                if ( typeof Element1.length == 'undefined' ) {
                    for (var a = 0; a < res.length; a++) {
                        var val = Element1.get('v.value');
                        if(val == res[a]){
                        //console.log('igit')
                            Element1.set("v.checked", 'true');
                        }
                    }
                } else {
                    for (var a = 0; a < res.length; a++) {
                        for (var i = 0; i < Element1.length; i++) {
                            var val = Element1[i].get('v.value');
                           // console.log('value ',Element1[i]);
                            if(val == res[a]){
                                Element1[i].set("v.checked", true);
                            }
                        }
                    }
                }
            }), 50
        );
    },
    backToEventList: function(component, event, helper) {
        helper.resetVars(component);
        component.set("v.attend", false);
    },
    confirm : function(component, event, helper) {
        //console.log('learningCont: '+component.get('v.learnOnlyOne'));
        var learnCount = component.get('v.learnOnlyOne');
        var learningId = component.get('v.learningId');
        var agreed = component.get("v.agreed");
        component.set("v.canProceed", false);
        
        var learns = component.get("v.activeLearns");
        if(learns == 'true') component.set("v.activeLearns",learningId);
        else component.set("v.activeLearns",learns+','+learningId);
        
        if(agreed == true){
            if(learnCount == true) {
                //console.log('aaaa');  
                var tpEvent = component.get("v.eventId");
                var tpId = component.get("v.trainingId");
                //console.log('evntId: '+tpEvent);
                //console.log('trainingId: '+tpId);
                var action = component.get("c.passEvt");
                action.setParams({
                    tpId: tpId,
                    tpEvent: tpEvent,
                    trackId: null
                });
                action.setCallback(this,function(response){
                    var track = helper.getParameterByName(component , event, 'track');

                    var status = response.getState();
                    if( status === "SUCCESS" ) {
                        if ( typeof track != 'undefined' && track != null ) {
                            var learnId = helper.getParameterByName(component , event, 'learning');
                            //console.log( 'learnId', learnId )
                            helper.eventEnrolCreate( component, event, learnId );
                        } else {
                            var trainingplanId = helper.getParameterByName(component , event, 'id'); 
                            var netid = helper.getParameterByName(component , event, 'netid');
                            //alert('controller: ' + netid);
                            var url = component.get("v.url");
                            url = url + 'apex/EventEnrolComplete?id='+trainingplanId+'&netid='+netid;//%3Fid='+trainingplanId+'&p=reg';
                            window.open(url,"_self");
                        }
                    } else {
                        //console.log( 'attendee create error', response.getError() );
                    }
                });
                $A.enqueueAction(action);
            }
            else{
                var tpEvent = component.get("v.eventId");
                var tpId = component.get("v.trainingId");
                var trackId = helper.getParameterByName(component , event, 'trackId');
                // var learnId = helper.getParameterByName(component , event, 'learning');
                
                /*console.log( 'trackId', trackId );
                console.log('evntId: '+tpId);
                console.log('trainingId: '+tpEvent);*/
                var action = component.get("c.passEvt");
                action.setParams({
                    tpId: tpId,
                    tpEvent: tpEvent,
                    trackId: trackId
                });
                action.setCallback(this,function(response){
                    //console.log( response.getState() );
                    //console.log( response.getError() );
                });
                $A.enqueueAction(action);
                component.set("v.modalShow", false);
                component.set("v.attend", false);
                var lCountTotal = component.get("v.learnCountTotal");
                var lCount = component.get("v.learnCount");
                
                //console.log('lCountTotal: ',lCountTotal);
                //console.log('lCount: ',lCount);
                
                if(lCount != 0 && (lCountTotal - 1) == lCount){
                    component.set("v.proceed", false);
                }
                else if(lCount == 0){
                    component.set('v.learnCount', 1);
                }
                else if(lCount != 0 && lCountTotal != lCount){
                	component.set('v.learnCount', lCount+1);
                }
                window.setTimeout(
                    $A.getCallback(function() {
                        var learns = component.get("v.activeLearns");
                        var res = learns.split(",");
                        var Elements = component.find('learns');
                        //console.log('res ',res);
                        for (var a = 0; a < res.length; a++) {
                            for (var i = 0; i < Elements.length; i++) {
                                var val = Elements[i].getElement().getAttribute('data-id');
                                if(val == res[a]){
                                    $A.util.addClass(Elements[i], 'slds-event--active slds-event--disable');
                                }
                            }
                        }
                        
                        var Element1 = component.find('select');
                        /*console.log('Element1 '+Element1);
                        console.log('Element1.length '+Element1.length);
                        console.log( 'res', res );*/
                        if ( typeof Element1.length == 'undefined' ) {
                            for (var a = 0; a < res.length; a++) {
                                var val = Element1.get('v.value');
                                if(val == res[a]){
                                    Element1.set("v.checked", true);
                                }
                            }
                        } else {
                            for (var a = 0; a < res.length; a++) {
                                for (var i = 0; i < Element1.length; i++) {
                                    var val = Element1[i].get('v.value');
                                    //console.log('value ',Element1[i]);
                                    if(val == res[a]){
                                        Element1[i].set("v.checked", true);
                                    }
                                }
                            }
                        }

                    }), 50
                );
            }
        }
        else alert("Please check that you have agreed to the Terms and Conditions of Registration before confirming your registration.");
    },
    //proceedToPayment: function(component, event, helper) {
        //var agreed = component.get("v.agreed");
        //if(agreed == true){
            /*var tpEvent = component.get("v.eventId");
            var tpId = component.get("v.trainingId");
            console.log('evntId: '+tpId);
            console.log('trainingId: '+tpEvent);
            var action = component.get("c.passEvt");
            action.setParams({
                tpId: tpId,
                tpEvent: tpEvent
            });*/
            //$A.enqueueAction(action);
            //window.history.go(-1);
       // }
        //else alert("Please check that you have agreed to the Terms and Conditions of Registration before confirming your registration.");
        //location.reload();
   // },
    close: function(component, event, helper){
        window.history.go(-1);
    },
    goToRegister : function(cmp, event, helper){
        //'https://psa-my-psa.cs114.force.com/CommunitiesSelfReg';
        console.log('inside register');
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        var selfRegURL = baseURL + "/CommunitiesSelfReg";
        console.log('Navigating to register' + selfRegURL);

        window.location.href = selfRegURL;

        /* 
        cmp.find("navService").navigate({
            type: "standard__webPage",
            attributes: {
                url: selfRegURL
            }
        }); */
    },
    onCheck: function(cmp, evt) {
		var checkCmp = cmp.find("checked");
        cmp.set("v.agreed", checkCmp.get("v.value"));
	 },
})