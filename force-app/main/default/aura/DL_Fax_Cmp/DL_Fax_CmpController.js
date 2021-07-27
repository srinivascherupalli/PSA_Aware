({  
    doInit : function(component, event, helper){
        var _individualFax_Div = component.find('individualFax_Div');
        $A.util.removeClass(_individualFax_Div, 'slds-hide');
        helper.resetUI(component);
        var _sendButton = component.find('button_Send');
        _sendButton.set('v.disabled','true');
    },
	
    
    onCheck : function(component, event, helper) {
        var checkValue = component.find('checkBox').get('v.value');
		component.set('v.costApproved', checkValue);
    },
    
    
	handleClick : function(component, event, helper) {
        //console.log("handleClick");
        var _radioGroupValue = component.get('v.value');
        var _waiting_Div = component.find('waiting_Div');
        var _uploadFinished = component.get('v.uploadFinished');
        var _faxSent = component.get('v.faxSent');
        var _costApproved = component.get('v.costApproved');

        if(_radioGroupValue === "option1" ){
           var _faxNumbers = [component.find('individual_fax').get('v.value')];
        }
        
        else if(_radioGroupValue != "option1"){
            var _faxNumbers = component.get('v.faxNumbers');
        };

        
        if(_uploadFinished && !_faxSent && _costApproved && _faxNumbers.length > 0){
            $A.util.removeClass(_waiting_Div, 'slds-hide');
            helper.sendFax(component, _faxNumbers, helper);
        }
        
        else if(_faxSent == true){
            helper.resetUI(component);
        }

        else{
            Console.log("_uploadFinished: " + _uploadFinished);
            Console.log("_faxSent: " + _faxSent);
            Console.log("_costApproved: " + _costApproved);
            Console.log("_faxNumbers.length: " + _faxNumbers.length);
        }

        window.setTimeout($A.getCallback(function() {}), 200); 
	},
    
    
    handleFilesChange : function(component, event, helper){
        console.log("handleFilesChange");
        var files = event.getSource().get("v.files");
        helper.readFile_PDF(component, files[0], helper); 
        window.setTimeout($A.getCallback(function() {}), 800); 
    },

    
    handleListFilesChange : function(component, event, helper){
        console.log("handleListFilesChange");
        var files = event.getSource().get("v.files");
        helper.readFile_List(component, files[0], helper); 
        window.setTimeout($A.getCallback(function() {}), 800); 
	},

    
    itemsChange : function(component, event, helper){
        console.log("itemsChange");
        var	_radioGroup_Value = event.getParam('value');
        var _individualFax_Div = component.find('individualFax_Div');
        var _postCodeFax_Div = component.find('postCodeFax_Div');
        var _costQuote_Div = component.find('costQuote_Div');
        var _listUpload_Div = component.find('listUpload_Div');
        var _state_Div = component.find('state_Div');
        
        document.getElementById("faxNumbersText").innerHTML = ""
        document.getElementById("quoteText").innerHTML =  ""
        
        switch(_radioGroup_Value){
            case "option1":
                console.log("itemsChange:option1");
                helper.resetUI(component);
                $A.util.removeClass(_individualFax_Div, 'slds-hide');
				$A.util.addClass(_postCodeFax_Div, 'slds-hide');
                $A.util.addClass(_costQuote_Div, 'slds-hide');
                $A.util.addClass(_listUpload_Div, 'slds-hide');
                $A.util.addClass(_state_Div, 'slds-hide');
                component.set('v.postCodeRequired', 'false');
                component.set('v.listFileRequired', 'false');
                component.set('v.stateRequired', 'false');
                component.set('v.individualRequired', 'true');
                break;
            case "option2":
                console.log("itemsChange:option2");
                helper.resetUI(component);
                $A.util.addClass(_individualFax_Div, 'slds-hide');
                $A.util.addClass(_listUpload_Div, 'slds-hide');
                $A.util.addClass(_state_Div, 'slds-hide');
				$A.util.removeClass(_postCodeFax_Div, 'slds-hide');
                $A.util.removeClass(_costQuote_Div, 'slds-hide');
                $A.util.removeClass(component.find('buttonQuote_Div'), 'slds-hide');
                component.set('v.individualRequired', 'false');
                component.set('v.listFileRequired', 'false');
                component.set('v.stateRequired', 'false');
                component.set('v.postCodeRequired', 'true');
                break;
            case "option3":
                console.log("itemsChange:option3");
                helper.resetUI(component);
                $A.util.addClass(_individualFax_Div, 'slds-hide');
				$A.util.addClass(_postCodeFax_Div, 'slds-hide');
                $A.util.addClass(_costQuote_Div, 'slds-hide');
                $A.util.addClass(_state_Div, 'slds-hide');
                $A.util.addClass(component.find('buttonQuote_Div'), 'slds-hide');
                $A.util.removeClass(_listUpload_Div, 'slds-hide');
                component.set('v.individualRequired', 'false');
                component.set('v.postCodeRequired', 'false');
                component.set('v.stateRequired', 'false');
                component.set('v.listFileRequired', 'true');
                break;
            case "option4":
                console.log("itemsChange:option4");
                helper.resetUI(component);
                $A.util.addClass(_individualFax_Div, 'slds-hide');
				$A.util.addClass(_postCodeFax_Div, 'slds-hide');
                $A.util.addClass(_costQuote_Div, 'slds-hide');
                $A.util.addClass(_listUpload_Div, 'slds-hide');
                $A.util.removeClass(component.find('buttonQuote_Div'), 'slds-hide');
                $A.util.removeClass(_costQuote_Div, 'slds-hide');
                $A.util.removeClass(_state_Div, 'slds-hide');
                component.set('v.individualRequired', 'false');
                component.set('v.postCodeRequired', 'false');
                component.set('v.listFileRequired', 'false');
                component.set('v.stateRequired', 'true');
                break;
            default:
                break;  
        }; 

        window.setTimeout($A.getCallback(function() {}), 200); 
    },
    
    
	getQuote : function(component, event, helper){
        //console.log("c.getQuote");
        helper.getQuote(component, helper)
        window.setTimeout($A.getCallback(function() {}), 300); 
    },
    
    
    enableSendButton : function(component, event, helper){
        //console.log("c.enableSendButton");
        var _costApproved = component.get('v.costApproved');
        var _uploadFinished = component.get('v.uploadFinished');

        if(_costApproved == true && _uploadFinished == true){
            helper.enableSendButton(component);
        }
        
        else{
            component.find('button_Send').set('v.disabled','true');
        }  
    },


    
})