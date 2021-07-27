({  

    getCampaigns : function(component) {
        //console.log('h.getCampaigns');
        var _action = component.get('c.GetCampaigns');
        var _showClosed = component.get('v.showClosed');

        _action.setParams({
            showClosed : _showClosed
        });
        
        _action.setCallback(this, function(response) {
            var _state = response.getState();
            var _response = response.getReturnValue();
            
            if(_state === "SUCCESS"){
                var _events = _response;
                _events.unshift({"Name":"Please select an event...", "id":"1"});
                component.set('v.events', _events);             
            }
            
            else{
                alert("GetCampaigns Error: " + _state);
                console.log("GetCampaigns Error: " + _response);
            }   

            return _response;
        });

        $A.enqueueAction(_action); 

        window.setTimeout($A.getCallback(function() {}), 200);
    },


    getCampaignSessions : function(component, _eventId, _showClosed) {
        //console.log('h.getCampaignSessions');
        //console.log(_showClosed);
        //console.log(_eventId);

        var _action = component.get('c.GetCampaignSessions');

        _action.setParams({
            campaignId : _eventId,
            showClosed : _showClosed
        });
        
         _action.setCallback(this, function(response) {
            var _state = response.getState();
            var _response = response.getReturnValue();
            
            if(_state === "SUCCESS"){
                var _eventSessions = _response;
                console.log(_response);

                if(_eventSessions.length > 0){
                    _eventSessions.unshift({"Name":"Please select a session...", "id":"1"});
                    component.set('v.eventSessions', _eventSessions);
                    $A.util.removeClass(component.find('sessionsDiv'), 'slds-hide');
                }

                else{
                    component.set('v.eventSessions', null);
                    $A.util.addClass(component.find('sessionsDiv'), 'slds-hide');
                }
                
            }
            
            else{
                alert("GetCampaignSessions Error: " + _state);
                console.log("GetCampaignSessions Error: " + _response);
                $A.util.addClass(component.find('sessionsDiv'), 'slds-hide');
            }   

            return _response;
        });

        $A.enqueueAction(_action); 

        window.setTimeout($A.getCallback(function() {}), 200);
    },


    getSessionsDetails : function(component, _eventId, _showClosed) {
        //console.log('h.getCampaignSessions');
        //console.log(_showClosed);
        //console.log(_eventId);

        var _action = component.get('c.GetCampaignSessions');

        _action.setParams({
            campaignId : _eventId,
            showClosed : _showClosed
        });
        
         _action.setCallback(this, function(response) {
            var _state = response.getState();
            var _response = response.getReturnValue();
            
            if(_state === "SUCCESS"){
                component.set('v.sessionsDetails', _response);
                console.log(_response);
            }
            
            else{
                alert("getSessionsDetails Error: " + _state);
                console.log("getSessionsDetails Error: " + _response);
                $A.util.addClass(component.find('sessionsDiv'), 'slds-hide');
            }   

            return _response;
        });

        $A.enqueueAction(_action); 

        window.setTimeout($A.getCallback(function() {}), 100);
    },


    getMember : function(component, helper, _psaId){
        var _action = component.get('c.GetMember');

        _action.setParams({
            psaId : _psaId
        });
        
         _action.setCallback(this, function(response) {
            var _state = response.getState();
            var _response = response.getReturnValue();
            
            if(_state === "SUCCESS"){
                component.set('v.member', _response);
                if(_response.Id != null){
                    console.log(_response);
                    console.log(_response.Id);
                    document.getElementById("memberDetails").innerHTML = '<h1 style="font-weight: bold;">Name: '+_response.Account.Name+'('+_response.Account.PSA_PSA_ID__c+')</h1>';
                }

                else{
                    console.log('Contact Not Returned');
                    document.getElementById("memberDetails").innerHTML = '<h1 style="font-weight: bold; color: Red">Error: Member('+_psaId+') Not Found</h1>';
                    component.set('v.idInputValue', '');
                    component.find('psaIDInput').focus();
                }
            }
            
            else{
                alert("getMember Error: " + _state);
                console.log("getMember Error: " + _response);
            }   

            return _response;
        });

        $A.enqueueAction(_action); 

        window.setTimeout($A.getCallback(function() {}), 100);
    },


    saveRFID : function(component, helper, _psaId, _rfidNumber){
        var _action = component.get('c.SaveRFIDNumber');

        _action.setParams({
            psaId : _psaId,
            rfidNumber : _rfidNumber
        });
        
         _action.setCallback(this, function(response) {
            var _state = response.getState();
            var _response = response.getReturnValue();
            
            if(_state === "SUCCESS"){
                console.log(_response);
                if(_response == 'Success'){
                    document.getElementById("memberRFID").innerHTML = '<h1 style="font-weight: bold;">RFID: '+_rfidNumber+'</h1>';
                    document.getElementById("successMessage").innerHTML = '<h1 style="font-weight: bold; color: green">Success!</h1>';
                }
                else if(_response.indexOf('RFID Already Exists') > -1){
                    document.getElementById("memberRFID").innerHTML = '<h1 style="font-weight: bold; color: red">RFID: '+_rfidNumber+'</h1>';
                    document.getElementById("successMessage").innerHTML = '<h1 style="font-weight: bold; color: Red">'+_response+'</h1>';
                }
                
            }
            
            else{
                alert("saveRFID Error: " + _state);
                console.log("saveRFID Error: " + _response);
                document.getElementById("memberRFID").innerHTML = '<h1 style="font-weight: bold; color: red;">RFID: Error</h1>';
            }   

            window.setTimeout($A.getCallback(function() {helper.resetRegistrationInputs(component, helper)}), 3000);
            return _response;
        });

        $A.enqueueAction(_action); 

        window.setTimeout($A.getCallback(function() {}), 100);
    },


    resetRegistrationInputs : function(component, helper){
        document.getElementById("memberRFID").innerHTML = '';
        document.getElementById("successMessage").innerHTML = '';
        document.getElementById("memberDetails").innerHTML = '';
        component.set('v.rfidInputValue', null);
        component.set('v.idInputValue', null);
        component.set('v.member', null);
        component.find('psaIDInput').focus();
    },


    submitScan : function (component, helper, _scanInBool, _psaId, _idNumber, _eventId){
        console.log('h.submitScan');

        document.getElementById("memberWelcome").innerHTML = '<p style="font-weight: bold; color: red">' + "Please Wait..." + '</p>';

        if(_psaId != ''){
            var _action = component.get('c.ProcessScan_psaId');
            console.log('_psaId: '+_psaId);

            _action.setParams({
                "scanIn" : _scanInBool,
                "psaId" : _psaId,
                "campaignId" : _eventId
            });
        }

        else{
            var _action = component.get('c.ProcessScan_ID');
            console.log('_idNumber: ' +_idNumber);

            _action.setParams({
                "scanIn" : _scanInBool,
                "idNumber" : _idNumber,
                "campaignId" : _eventId
            });
        }
        
        
        _action.setCallback(this, function(response) {
            var _state = response.getState();
            var _response = response.getReturnValue();
            
            if(_state === "SUCCESS"){
                var _name = _response.substring(0, _response.indexOf('('));
                console.log(_response);
                
                if(_psaId != '' || _idNumber != ''){
                    if(_response.indexOf('Already') > -1){
                        document.getElementById("memberWelcome").innerHTML = '<p style="font-weight: bold; color: red">' + _response + '</p>';
                        helper.triggerScanOutSound(component);
                    }

                    else if((_response.indexOf('Attending') > -1)&&(_response.indexOf('Already') == -1)){
                        document.getElementById("memberWelcome").innerHTML = '<p style="font-weight: bold;">Welcome, ' + _name + '</p>';
                        helper.triggerScanInSound(component);
                        helper.incrementCounter(component,'v.scanInCount');
                    }

                    else if((_response.indexOf('Scanned OUT') > -1)&&(_response.indexOf('Already') == -1)){
                        document.getElementById("memberWelcome").innerHTML = '<p style="font-weight: bold;">Goodbye, ' + _name + '</p>';
                        helper.triggerScanOutSound(component);
                        helper.incrementCounter(component,'v.scanOutCount');
                    }

                    else{
                        if(_psaId != ''){
                            document.getElementById("memberWelcome").innerHTML = '<p style="font-weight: bold; color: red">PSA ID(' +_psaId+ ') Not Registered</p>';
                        }
                        else{
                            document.getElementById("memberWelcome").innerHTML = '<p style="font-weight: bold; color: red">ID(' +_idNumber+ ')<br/> Not Registered</p>';
                        }
                        
                        helper.triggerScanOutSound(component);
                    }
                }
                component.set("v.timeLastScanned", Date.now());
                window.setTimeout($A.getCallback(function() {}),200);
            }
            
            else{
                alert("submitScan Error: " + _state);
                console.log("submitScan Error: " + _response);
            }   

            console.log('c.scanInput_Submit: spinner hide');
            $A.util.addClass(component.find('spinner'), 'slds-hide');
            window.setTimeout($A.getCallback(function() {}), 200);
            return _response;
        });

        
        $A.enqueueAction(_action); 
    },


    getImageURL : function(component, _eventId){
        //console.log('h.getImageURL');
        var _action = component.get('c.GetImageURL');
        component.set('v.sessionId', 'Please select a session...');

        _action.setParams({"campaignId" : _eventId});

        _action.setCallback(this, function(response) {
            var _state = response.getState();
            var _response = response.getReturnValue();
            
            if(_state === "SUCCESS"){
                if(_response != null){
                    component.set('v.imageURL', _response);
                    $A.util.removeClass(component.find('campaignImage'), 'slds-hide');
                    $A.util.addClass(component.find('PSA_logo'), 'slds-hide');
                }

                else{
                    $A.util.addClass(component.find('campaignImage'), 'slds-hide');
                    component.set('v.imageURL', null);
                } 
                console.log(_response);
            }
            
            else{
                $A.util.addClass(component.find('campaignImage'), 'slds-hide');
                $A.util.removeClass(component.find('PSA_logo'), 'slds-hide');
                component.set('v.imageURL', null);
            }   
            return _response;
        });

        $A.enqueueAction(_action); 

        window.setTimeout($A.getCallback(function() {}), 200);
    },


    inputFocus : function(component){
        console.log('h.inputFocus');
        var _scanTab_IsActive = $A.util.hasClass(component.find('scanTab'), 'slds-is-active');
        var _member = component.get('v.member');

        if(_scanTab_IsActive){
            component.find('scanInput').focus();
        }
        else{
            if(_member == null){
                component.find('psaIDInput').focus();
            }

            else{
                component.find('rfidInput').focus();
            }
        }

        window.setTimeout($A.getCallback(function() {}), 200);
    },


    refreshLists : function(component, helper){
        //console.log('h.refreshLists');
        var _showClosed = component.get('v.showClosed');
        var _eventId = component.get('v.event');
        console.log(_showClosed);
        
        if(_eventId != null){
            helper.getCampaignSessions(component, _eventId, _showClosed);
        }

        else{
            helper.getCampaigns(component);
        }

        window.setTimeout($A.getCallback(function() {}), 200);
    },


    refreshTimer : function(component, helper){
        console.log('h.refreshTimer');
        var _showClosed = component.get('v.showClosed');
        window.setInterval(function() {
            var _sessionId = component.get('v.sessionId');
            var _eventId = component.get('v.event');
            if(_eventId != null){
                helper.getCampaignSessions(component, _eventId, _showClosed);
                component.set('v.sessionId', _sessionId);
            }
            
        }, 900000, component, helper); //15 minutes
    },


    clearMemberWelcomeTimer : function(component, helper){
        console.log('h.clearMemberWelcomeTimer');
        window.setInterval(function() {
            var _timeLastScanned = component.get('v.timeLastScanned');
            
            if(Date.now() - 3500 > _timeLastScanned){
                document.getElementById("memberWelcome").innerHTML = '';
            }
        }, 4000);
    },


    triggerScanInSound : function(component) {
        //console.log('h.triggerScanInSound');
        component.set('v.playInSound',true);      
        setTimeout(function() {
            component.set('v.playInSound',false);
        }, 1500);
        window.setTimeout($A.getCallback(function() {}), 100);
    },    


    triggerScanOutSound : function(component) {
        //console.log('h.triggerScanOutSound');
        component.set('v.playOutSound',true);      
        setTimeout(function() {
            component.set('v.playOutSound',false);
        }, 1500);
        window.setTimeout($A.getCallback(function() {}), 100);
    },   


    incrementCounter : function(component, _counterName){
        console.log('h.incrementCounter');
        component.set(_counterName, (component.get(_counterName) + 1));
        window.setTimeout($A.getCallback(function() {}), 100);
    }
    
})