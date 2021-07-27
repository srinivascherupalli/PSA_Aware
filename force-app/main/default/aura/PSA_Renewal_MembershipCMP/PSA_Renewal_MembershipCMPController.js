({
    init : function(component, event, helper) {
        console.log('Aura Component Loaded');
        var changeType = event.getParams().changeType;
 
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") { 
            /* handle record load */

            var invoiceRecord = component.get("v.invoiceRecord");
            var payment = {
                tax: invoiceRecord.blng__TaxAmount__c,
                discount: 0,
                subtotal: invoiceRecord.blng__Subtotal__c,
                total: invoiceRecord.blng__TotalAmount__c
            };
            console.log(payment)
            component.set("v.payment", payment);
           
            
        }
        helper.fetchPaymentDetails(component, event);
    },

	recordUpdated: function(component, event, helper) {
       // alert(event.getParams().changeType)
       helper.fetchPaymentDetails(component, event);
        var changeType = event.getParams().changeType;

        console.log(component.get("v.invoiceRecord"))
        console.log(component.get("v.recordLoadError"))
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") { 
            /* handle record load */
            var invoiceRecord = component.get("v.invoiceRecord");
            var payment = {
                tax: invoiceRecord.blng__TaxAmount__c,
                discount: 0,
                subtotal: invoiceRecord.blng__Subtotal__c,
                total: invoiceRecord.blng__TotalAmount__c
            };
            console.log(payment)
            component.set("v.payment", payment);
            
            
        }
        //component.find("forceRecord").reloadRecord();

    },
    
    termsChanged: function(component, event, helper) {
        var sel = event.target.checked;
        
        component.set("v.acceptAndContinue", sel );

        var acceptAndContinue = component.get("v.acceptAndContinue");
        var tcSection = component.find('tcSection');
        if(acceptAndContinue == true){
            $A.util.removeClass(tcSection, 'slds-has-error');
        }else{ 
            $A.util.addClass(tcSection, 'slds-has-error');
        }
    },

    handleButtonClick: function(component, event, helper) {
        
		var acceptAndContinue = component.get("v.acceptAndContinue");
        var tcSection = component.find('tcSection');
        //component.set("v.acceptAndContinue", true);
        if(acceptAndContinue == true){
        	var screenName = event && event.getParam ?  event.getParam("screenName") : undefined;
            screenName = screenName ? screenName : 'screen1b';
            var fromCMP =  event && event.getParam ? event.getParam('from') : undefined;
            if(fromCMP) return;
            helper.handleValidation(component, event, screenName);    
        }else{ 
            $A.util.addClass(tcSection, 'slds-has-error');
            //warning section
        }
        
    }
})