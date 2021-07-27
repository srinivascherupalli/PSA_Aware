({
    resetUI : function(component){
        //console.log("resetUI");
		component.set('v.iconName','utility:share_file');
        component.set('v.buttonLabel','Send');
        component.set('v.fileDataURL',null);
        component.set('v.fileName',null);
        component.set('v.listFileName',null);
        component.find('individual_fax').set('v.value', null);
        component.set('v.faxNumbers', null);
        component.set('v.faxSent',false);
        component.set('v.HideSpinner',true);
        component.set('v.stateValue',[]);
        component.set('v.uploadFinished',false);
        component.set('v.costApproved',false);
        component.find('checkBox').set('v.value',false);
        component.find('button_Send').set('v.disabled','true'); 
        component.find('postcode_fax').set('v.value',null);
        $A.util.addClass(component.find('pdf_Div'), 'slds-hide');
        $A.util.addClass(component.find('csv_Div'), 'slds-hide');
        $A.util.addClass(component.find('waiting_Div'), 'slds-hide');
        $A.util.addClass(component.find('approved_Div'), 'slds-hide');
        $A.util.addClass(component.find('quoteText_Div'), 'slds-hide');
        $A.util.addClass(component.find('refresh_Div'), 'slds-hide');
        $A.util.addClass(component.find('faxNumbers_Div'), 'slds-hide');
        $A.util.addClass(component.find('buttonQuote_Div'), 'slds-hide');
        $A.util.addClass(component.find('state_Div'), 'slds-hide');
        if(component.get('v.value') === "option2"){
            $A.util.removeClass(component.find('buttonQuote_Div'), 'slds-hide');
        }

    },
    
    
    checkValid : function(component, name){
        component.reportValidity();
        //console.log("checkValid:"+name+":"+component.checkValidity());
        return component.checkValidity();
    },
    
    
	sendFax : function(component, _faxNumbers, helper) {
        //console.log("sendFax");
        var _base64Data = component.get('v.fileDataURL').match(/,(.*)$/)[1];
		var _action = component.get('c.sendFaxProxy');
        var _waiting_Div = component.find('waiting_Div');
        var _fileName = component.get('v.fileName');
        var _costCode = component.find('costCode').get('v.value');

        _action.setParams({
            "faxNumbers" : _faxNumbers,
            "fileName": _fileName,
            "base64Data": encodeURIComponent(_base64Data),
            "costCode": _costCode
        });
        
        _action.setCallback(this, function(response) {
            var _state = response.getState();
            var _response = response.getReturnValue();
            
            if(_response === "SUCCESS"){
                console.log("sendFax: " + _response);
                component.set('v.faxSent',true);
                component.set('v.iconName','utility:check');
                component.set('v.buttonLabel','Success!');
                $A.util.addClass(_waiting_Div, 'slds-hide');
            }

            else if(_response === "INSUFFICIENT CREDITS"){
                alert("Error: Insufficient Fax Credits. Contact IT.");
                this.resetUI(component);
            }
            
            else if(_response === "NOT BUSINESS HOURS"){
                alert("Error: Faxes Can only be sent 9am-5pm Mon-Sat. See www.legislation.gov.au/Details/F2011L00668 for more details.");
                this.resetUI(component);
            }
            
            else{
                alert("Send Fax Error: " + _response)
                $A.util.addClass(_waiting_Div, 'slds-hide');
            }   

            return _response;
        });
        
        if(_fileName.length <= 30){
            $A.enqueueAction(_action); 
        }
        
        else if(_fileName.length > 30){
            return alert("Error: File name is too long")
        }
  
        window.setTimeout($A.getCallback(function() {}), 400);
    },

    
    readFile_PDF: function(component, _file, helper) {
        //console.log("readFile_PDF");
        var _pdf_Div = component.find('pdf_Div');
        var enableSendButton = component.get('c.enableSendButton');
        
        if(!_file) return;
        if(!_file.type.match("application/pdf")) {
  			return alert('File must be a PDF');
        }
        if(_file.name.length > 30){
            return alert('Error: File name too long');
        }
        
        var _reader = new FileReader();
        
        _reader.onloadend = function() {
            var _dataURL = _reader.result;
            //var _base64Data = _dataURL.match(/,(.*)$/)[1];
            
            component.set('v.fileDataURL', _dataURL);
            component.set('v.fileName', _file.name);
			component.set('v.uploadFinished', true);
            
            $A.util.removeClass(_pdf_Div, 'slds-hide');

            if(component.get('v.value') === "option1"){
                component.set('v.costApproved', true);
            }
            
            window.setTimeout($A.getCallback(function() {}), 400);
            
            if(component.get('v.costApproved')){
                $A.enqueueAction(enableSendButton);
            }
        };
        
        _reader.readAsDataURL(_file);
        
        this.checkValid(component.find('file_Uploader'), 'file_Uploader');
    },
    

    readFile_List: function(component, _file, helper) {
        //console.log("readFile_List");
        var _csv_Div = component.find('csv_Div');
        var _filteredFaxNumbers = [];
        
        if(!_file) return;
        if(!_file.type.match("application/vnd.ms-excel")) {
  			return alert('File must be a CSV');
        }
        
        var _reader = new FileReader();

        _reader.onloadend = function() {
            var _list = _reader.result;
            var _faxNumbers = _list.split('\n');

            _faxNumbers.forEach(function(faxNumber) {
                faxNumber = faxNumber.replace(")","");
                faxNumber = faxNumber.replace("(","");
                faxNumber = faxNumber.replace("-","");
                faxNumber = faxNumber.replace(/\s/g, "");
                
                if(_filteredFaxNumbers.indexOf(faxNumber) < 0) {
                    _filteredFaxNumbers.push(faxNumber);
                }
            });

            _filteredFaxNumbers = _filteredFaxNumbers.filter(function (faxNumber) {
                return faxNumber.length > 7;
            });

            component.set('v.faxNumbers', _filteredFaxNumbers);
            component.set('v.faxNumbersLength', component.get('v.faxNumbers').length);

            component.set('v.listFileName', _file.name);
            
            $A.util.removeClass(_csv_Div, 'slds-hide');

            window.setTimeout($A.getCallback(function() {}), 400);
        };

        _reader.readAsText(_file, "UTF-8");

        helper.getQuote(component, helper);

        this.checkValid(component.find('listFile_Uploader'), 'listFile_Uploader');
	},

    
    getFaxNumbers : function(component, _postCodes, callback){
        //console.log("getFaxNumbers");
        this.showWaiting(component);
        var _action = component.get('c.getFaxNumbers');
        _action.setParams({postCodes : _postCodes});
        
        _action.setCallback(this, function(response) {
                var _state = response.getState();
                var _response = response.getReturnValue();
            	var _faxNumbers = String(_response).split(",");
            
                if(_state === "SUCCESS"){
                    if(_faxNumbers[0] == "PostCode Error"){
                        alert("Error:PostCode Error");
                    }
                    
                    else{
                        component.set('v.faxNumbers', _faxNumbers);
                        component.set('v.faxNumbersLength', component.get('v.faxNumbers').length);
                        //console.log("v.faxNumbersLength: " + component.get("v.faxNumbersLength"));
                    }
                }
                
                else if(_state === "INCOMPLETE") {
                    alert("getFaxNumbers:INCOMPLETE");
                }
    
                else if(_state === "ERROR") {
                    alert("ERROR: "+ _response);
                    //console.log("getFaxNumbers:ERROR: " + _response);
                }
            
            window.setTimeout($A.getCallback(function() {}), 100);
            return _faxNumbers;
         });
         
        $A.enqueueAction(_action);	
        window.setTimeout($A.getCallback(function() {}), 100);
    },


    getQuote : function(component, helper){
        console.log("h.getQuote");
        var _postcode_fax = component.find('postcode_fax');
        var _states_CheckBoxGroup = component.find('states_CheckBoxGroup');

        var _radioGroupValue = component.get('v.value');

        if( _postcode_fax.get('v.value').includes(",") && _postcode_fax.get('v.value').includes("-")){
            alert("PostCodes cannot contain both ',' and '-'");
        }

        else if(helper.checkValid(_states_CheckBoxGroup, '_states_CheckBoxGroup')){
            var _states = component.find('states_CheckBoxGroup').get('v.value');
            var _states_String = "";
            
            for(var i = 0; i < _states.length; i++){
                _states_String += _states[i]+'_';
            }

            _states_String = _states_String.substring(0,_states_String.length -1);

            console.log(_states_String);
            helper.getFaxNumbers(component, _states_String);

            window.setTimeout($A.getCallback(function() {
                var size = component.get('v.faxNumbersLength');
            
                var cost = function(size){
                    var total = size * 0.125;
                    total = total.toFixed(2)
                    return (total > 0.99) ? "$"+total.toString() : total.toString()+"c"; 
                };
                
                $A.util.addClass(component.find('buttonQuote_Div'), 'slds-hide');
                $A.util.removeClass(component.find('refresh_Div'), 'slds-hide');
                $A.util.removeClass(component.find('approved_Div'), 'slds-hide');
                $A.util.removeClass(component.find('quoteText_Div'), 'slds-hide');
                $A.util.removeClass(component.find('faxNumbers_Div'), 'slds-hide');
                
                document.getElementById("faxNumbersText").innerHTML = "<p>Fax Numbers: "+size+"</p>"
                document.getElementById("quoteText").innerHTML =  "<p>Estimated cost: "+cost(size)+" </p>"

                if(component.get('v.costApproved') == 'true' && component.get('v.uploadFinished') == 'true'){
                   helper.enableSendButton(component);
                }

                helper.hideWaiting(component);
            }), 2000);

        }
 
   		else if(helper.checkValid(_postcode_fax, '_postcode_fax')){
            helper.getFaxNumbers(component, _postcode_fax.get('v.value'));

            window.setTimeout($A.getCallback(function() {
                var size = component.get('v.faxNumbersLength');
            
                var cost = function(size){
                    var total = size * 0.12;
                    total = total.toFixed(2)
                    return (total > 0.99) ? "$"+total.toString() : total.toString()+"c"; 
                };
                
                $A.util.addClass(component.find('buttonQuote_Div'), 'slds-hide');
                $A.util.removeClass(component.find('refresh_Div'), 'slds-hide');
                $A.util.removeClass(component.find('approved_Div'), 'slds-hide');
                $A.util.removeClass(component.find('quoteText_Div'), 'slds-hide');
                $A.util.removeClass(component.find('faxNumbers_Div'), 'slds-hide');
                
                document.getElementById("faxNumbersText").innerHTML = "<p>Fax Numbers: "+size+"</p>"
                document.getElementById("quoteText").innerHTML =  "<p>Estimated cost: "+cost(size)+" </p>"

                if(component.get('v.costApproved') == 'true' && component.get('v.uploadFinished') == 'true'){
                   helper.enableSendButton(component);
                }

                helper.hideWaiting(component);
            }), 2000);
        }

        else if(_radioGroupValue === "option3"){

            window.setTimeout($A.getCallback(function() {
                var size = component.get('v.faxNumbersLength');
            
                var cost = function(size){
                    var total = size * 0.12;
                    total = total.toFixed(2)
                    return (total > 0.99) ? "$"+total.toString() : total.toString()+"c"; 
                };
                
                $A.util.addClass(component.find('buttonQuote_Div'), 'slds-hide');
                $A.util.removeClass(component.find('refresh_Div'), 'slds-hide');
                $A.util.removeClass(component.find('approved_Div'), 'slds-hide');
                $A.util.removeClass(component.find('costQuote_Div'), 'slds-hide');
                $A.util.removeClass(component.find('quoteText_Div'), 'slds-hide');
                $A.util.removeClass(component.find('faxNumbers_Div'), 'slds-hide');
                $A.util.addClass(component.find('buttonQuote_Div'), 'slds-hide');
                
                document.getElementById("faxNumbersText").innerHTML = "<p>Fax Numbers: "+size+"</p>"
                document.getElementById("quoteText").innerHTML =  "<p>Estimated cost: "+cost(size)+" </p>"

                if(component.get('v.costApproved') == 'true' && component.get('v.uploadFinished') == 'true'){
                   helper.enableSendButton(component);
                }

                helper.hideWaiting(component);
            }), 2000);
        }

        window.setTimeout($A.getCallback(function() {}),200);
        console.log(component.get('v.faxNumbers'));
    },
    
    
    enableSendButton : function(component){
        console.log("h.enableSendButton");
        var _radioGroupValue = component.get('v.value');
        var _costCode = component.find('costCode');
        var _costApproved = component.get('v.costApproved');
        var _uploadFinished = component.get('v.uploadFinished');
        var _file_Uploader = component.find('file_Uploader');

        if(_radioGroupValue === "option1" ){
           var _faxNumbers = [component.find('individual_fax').get('v.value')];
        }
        
        else if(_radioGroupValue != "option1"){
            var _faxNumbers = component.get('v.faxNumbers');
        }

        this.checkValid(_file_Uploader, '_file_Uploader');

        if(_faxNumbers.length > 0 && this.checkValid(_costCode, '_costCode') && _costApproved && _uploadFinished){
            var _sendButton = component.find('button_Send');
            _sendButton.set('v.disabled','false');
            console.log(_faxNumbers);
        }
    },


    showWaiting: function(component, helper) {
        component.set("v.showSpinner", true);
    },


    hideWaiting: function(component, helper) {
        component.set("v.showSpinner", false);
        window.setTimeout($A.getCallback(function() {}), 300); 
    },

})