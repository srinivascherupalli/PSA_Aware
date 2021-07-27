({
    buttonHandler : function(component, event, helper){
        var _lastButtonPushed = component.get("v.lastButtonPushed");
        console.log(_lastButtonPushed);
        
        if(_lastButtonPushed == 'recoverButton'){
            helper.failedPayments_recover(component, event, helper);
            helper.closeModal(component, event, helper);
        }
        
        else if(_lastButtonPushed == 'deactivateButton'){
            helper.paymentSource_deactivate(component, event, helper);
            helper.closeModal(component, event, helper);
        }
    },
    
    
    showModal : function(component, event, helper){
        var _buttonId = event.getSource().getLocalId();
        $A.util.removeClass(component.find('confirmationModal'), 'slds-hide');
        $A.util.addClass(component.find('confirmationModal'), 'slds-show');
        
        component.set('v.loadingBool', 'true');
        component.set("v.lastButtonPushed", _buttonId);
        
        if(_buttonId == "recoverButton"){
            document.getElementById("modal-content-id-1").innerHTML = 'Set Failed Payments as \'Failed but recovered?\''; 
        }
        
        else if(_buttonId == "deactivateButton"){
            document.getElementById("modal-content-id-1").innerHTML = 'Deactivate this Payment Source?';
        }
    },
    
    
    closeModal : function(component, event, helper){
        $A.util.removeClass(component.find('confirmationModal'), 'slds-show');
        $A.util.addClass(component.find('confirmationModal'), 'slds-hide');
        component.set('v.loadingBool', 'false');
    },
    
})