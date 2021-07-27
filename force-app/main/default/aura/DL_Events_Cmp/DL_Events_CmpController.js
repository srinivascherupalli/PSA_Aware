({
	init : function(component, event, helper) {
        console.log('c.init');
        helper.getCampaigns(component);
        component.set('v.session', null);
        component.set('v.event', null);
        component.set('v.imageURL', null); 
        component.set('v.eventMembers', null);
        component.set('v.searchResults', null);
        component.set('v.scanInCount', 0);
        component.set('v.scanOutCount', 0);
        helper.inputFocus(component);
        helper.clearMemberWelcomeTimer(component);
        window.setTimeout($A.getCallback(function() {helper.refreshTimer(component, helper);}), 10000);
    },
    

    eventChange : function(component, event, helper) {
        console.log('c.eventChange');
        var _eventId = component.get('v.event');
        var _showClosed = component.get('v.showClosed');

        if(_eventId == null){
            $A.util.addClass(component.find('campaignImage'), 'slds-hide');
            $A.util.addClass(component.find('sessionsDiv'), 'slds-hide');
            $A.util.removeClass(component.find('eventsDiv'), 'slds-hide');
            $A.util.removeClass(component.find('PSA_logo'), 'slds-hide');
            component.find('eventsTableButton').set('v.disabled', 'true');
        }

        else{
            helper.getImageURL(component, _eventId);
            helper.getCampaignSessions(component, _eventId, _showClosed);
            helper.getSessionsDetails(component, _eventId, 'null');
            helper.inputFocus(component);
            component.find('eventsTableButton').set('v.disabled', 'false');
            $A.util.addClass(component.find('eventsDiv'), 'slds-hide');
        }
    },


    sessionChange : function(component, event, helper) {
        console.log('c.sessionChange');
        var _eventSessions = component.get('v.eventSessions');
        var _sessionId = component.get('v.sessionId');

        if(_sessionId != 'Please select a session...'){
            for(var session in _eventSessions){
                if(_eventSessions[session].Id == _sessionId){
                    component.set('v.sessionName', _eventSessions[session].Name);
                }
            }
    
            var _sessionName = component.get('v.sessionName');
            document.getElementById("sessionNameDiv").innerHTML = '<h1 style="color: black font-weight: bold;">' + _sessionName + '</h1>';
        }

        else{
            document.getElementById("sessionNameDiv").innerHTML = '<h1 style="color: black font-weight: bold;"> Welcome! </h1>';
        }

        helper.inputFocus(component);
    },


    tabClick : function(component, event, helper){
        //console.log('c.tabClick');
        var tabClicked = event.currentTarget.id;

        if(tabClicked == 'tab-scoped-1__item'){//Scan input tab
            $A.util.toggleClass(component.find('scanTab'), 'slds-is-active');
            $A.util.toggleClass(component.find('tab-scoped-1'), 'slds-show');
            $A.util.toggleClass(component.find('tab-scoped-1'), 'slds-hide');
            $A.util.toggleClass(component.find('registerTab'), 'slds-is-active');
            $A.util.toggleClass(component.find('tab-scoped-2'), 'slds-show');
            $A.util.toggleClass(component.find('tab-scoped-2'), 'slds-hide');
            $A.util.removeClass(component.find('sessionNameDiv'), 'slds-hide');
            helper.resetRegistrationInputs(component, helper);
        }

        else if(tabClicked == 'tab-scoped-2__item'){//Member search tab
            $A.util.toggleClass(component.find('scanTab'), 'slds-is-active');
            $A.util.toggleClass(component.find('tab-scoped-1'), 'slds-show');
            $A.util.toggleClass(component.find('tab-scoped-1'), 'slds-hide');
            $A.util.toggleClass(component.find('registerTab'), 'slds-is-active');
            $A.util.toggleClass(component.find('tab-scoped-2'), 'slds-show');
            $A.util.toggleClass(component.find('tab-scoped-2'), 'slds-hide');
            $A.util.addClass(component.find('sessionNameDiv'), 'slds-hide');
        }

        window.setTimeout($A.getCallback(function() {helper.inputFocus(component);}), 200);
    },


    buttonClick : function(component, event, helper){
        //console.log('c.buttonClick');
        var _switchID = event.currentTarget.id;

        if(_switchID == 'outSwitch'){
            $A.util.addClass(component.find('outSwitch'), 'activeSwitch');
            $A.util.removeClass(component.find('inSwitch'), 'activeSwitch');
            component.set('v.scanInBool',false);
        }

        else if(_switchID == 'inSwitch'){
            $A.util.removeClass(component.find('outSwitch'), 'activeSwitch');
            $A.util.addClass(component.find('inSwitch'), 'activeSwitch');
            component.set('v.scanInBool',true);
        }

        helper.inputFocus(component);
    },


    processInput : function(component, event, helper){
        var _psaId = component.find('psaIDInput').get('v.value');
        var _eventId = component.get('v.event');
        var _rfidNumber = component.find('rfidInput').get('v.value');
        var _member = component.get('v.member');

        if(event.which === 13){ //If key press == 'Enter'
            if(_psaId != null){
                console.log(_psaId);
                helper.getMember(component, helper, _psaId);

                if(_rfidNumber != null){
                    console.log(_rfidNumber);
                    if(_rfidNumber.length > 6){
                        helper.saveRFID(component, helper, _psaId, _rfidNumber);
                    }

                    else{
                        document.getElementById("memberRFID").innerHTML = '<h1 style="font-weight: bold; color: Red">Error: RFID('+_rfidNumber+') Too Short</h1>';
                        component.set('v.rfidInputValue', '');
                    }
                    
                }

                else{
                    component.find('rfidInput').focus();
                }
            }

            else{
                component.find('psaIDInput').focus();
            }
        }
    },


    scanInput_Submit : function(component, event, helper){
        console.log('c.scanInput_Submit');
        var _scanInBool = component.get('v.scanInBool');
        var _scanInput = component.get('v.scanInputValue');
        var _eventId = component.get('v.event');
        var _sessionId = component.get('v.sessionId');

        $A.util.removeClass(component.find('scanInput'), 'inputError');

        if(event.which === 13){ //If key press == 'Enter'
            if(_eventId !== null){
                if(_sessionId != 'Please select a session...' && _sessionId != ''){
                    if(_scanInput.length == 6){
                        helper.submitScan(component, helper, _scanInBool, _scanInput, '', _sessionId);
                    }

                    else if(_scanInput.length > 6){
                        helper.submitScan(component, helper, _scanInBool, '', _scanInput, _sessionId);
                    }
        
                    else{
                        document.getElementById("memberWelcome").innerHTML = '<p style="color: red; font-weight: bold;"> Error: ' + _scanInput + ' Invalid </p>';
                    }
                }

                else{
                    if(_scanInput.length == 6){
                        helper.submitScan(component, helper, _scanInBool, _scanInput, '', _eventId);
                    }

                    else if(_scanInput.length > 6){
                        helper.submitScan(component, helper, _scanInBool, '', _scanInput, _eventId);
                    }
        
                    else{
                        document.getElementById("memberWelcome").innerHTML = '<p style="color: red; font-weight: bold;"> Error: ' + _scanInput + ' Invalid </p>';
                    }
                }

            }

            component.set('v.scanInputValue', '');
            helper.inputFocus(component);
        }

        
        window.setTimeout($A.getCallback(function() {}), 100);
        console.log('c.scanInput_Submit: spinner show');
        $A.util.removeClass(component.find('spinner'), 'slds-hide');
    },


    toggleSettings : function(component, event, helper){
        //console.log('c.toggleSettings');
        $A.util.toggleClass(component.find('settings'), 'slds-hide');

        var w = window,
        d = document,
        e = d.documentElement,
        g = d.getElementsByTagName('body')[0],
        x = w.innerWidth || e.clientWidth || g.clientWidth,
        y = w.innerHeight|| e.clientHeight|| g.clientHeight;

        d.getElementById("screenInfo").innerHTML = '<p> Screen Size: ' + x +' x '+ y + '</p>';
        helper.inputFocus(component);
    },


    toggleEventsTable : function(component, event, helper){
        //console.log('c.toggleEventsTable');
        $A.util.toggleClass(component.find('eventsTable'), 'slds-hide');
        var _showClosed = 'null';
        var _eventId = component.get('v.event');
        console.log(_eventId);
        
        if(!$A.util.hasClass(component.find('eventsTable'), 'slds-hide') && _eventId != null){ 
            helper.getSessionsDetails(component, _eventId, _showClosed);
            var _eventSessions = component.get('v.sessionsDetails');
            var _date = "";

            document.getElementById("eventsTable_Div").innerHTML = ''; 

            for(var i = 0; i < _eventSessions.length; i++){
                var _currentDate = _eventSessions[i].StartDate.substring(8,10)+'/'+_eventSessions[i].StartDate.substring(5,7)+'/'+_eventSessions[i].StartDate.substring(0,4);
                if(_currentDate != _date){
                    _date = _currentDate;
                    document.getElementById("eventsTable_Div").innerHTML += 
                    '<div class="slds-col slds-size_1-of-1 slds-p-around_small slds-align_absolute-center"><h1 style="color: black; font-weight: bold; text-decoration: underline; margin-bottom: -20px">' + 
                        _currentDate+
                    '</h1></div>';
                }

                document.getElementById("eventsTable_Div").innerHTML += 
                    '<div class="slds-col slds-size_1-of-1 slds-p-around_small slds-align_absolute-center"><h1 style="color: black;">' + 
                        _eventSessions[i].Name+
                    '</h1></div>';
            }
        }
        helper.inputFocus(component);
    },


    showClosed_Change : function(component, event, helper){
        //console.log('c.showClosed_Change');
        helper.refreshLists(component, helper);
    },


    inputFocus : function(component){
        console.log('c.inputFocus');
        var _scanTab_IsActive = $A.util.hasClass(component.find('scanTab'), 'slds-is-active');

        if(_scanTab_IsActive){
            component.find('scanInput').focus();
        }

        window.setTimeout($A.getCallback(function() {}), 200);
    },


})