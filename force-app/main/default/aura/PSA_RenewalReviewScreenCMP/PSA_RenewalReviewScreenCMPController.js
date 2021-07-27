({
    doInit: function(component, event, helper) {
/*         var payment = {
            tax: 39.36,
            discount: 89.83,
            subtotal: 449.17,
            total: 399.20
        };
        component.set("v.payment", payment); */
        //helper.getUserCallback(component)
        helper.setUpDetails(component);
    },

	recordUpdated: function(component, event, helper) {
        helper.fetchPaymentDetails(component, event);
        var changeType = event.getParams().changeType;
 
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") { 
            /* handle record load */

            var invoiceRecord = component.get("v.invoiceRecord");
            var payment = {
                tax: invoiceRecord.Total_Tax__c,
                discount: 0,
                subtotal: invoiceRecord.Subtotal_Calculated__c,
                total: invoiceRecord.blng__TotalAmount__c
            };
            component.set("v.payment", payment);
            helper.fetchPaymentDetails(component, event);
        }
        
    },
    handleTc: function(component, event, helper) {
        var tcCheck = component.find("tcCheck");
        tcCheck.reportValidity();
    },

    handleButtonClick: function(component, event, helper) {
 		helper.handlePayment(component);
        /*if(component.get("v.isReadTerms")) {
            helper.handlePayment(component);
        } else {
            var handleTc = component.get('c.handleTc');
            $A.enqueueAction(handleTc);
        }*/
        
    },

    handleBillingChange: function(component, event, helper) {
        helper.setUpDetails(component);
    },

    handleBackButtonClick: function(compoennt, event, helper) {
        var screenName = event && event.getParam ?  event.getParam("screenName") : undefined;
        var fromCMP =  event && event.getParam ? event.getParam('from') : undefined;
        if(fromCMP && fromCMP == 'CMP') return;

        if(!screenName) screenName = 'screen2';

        scrollTo({ top: 0, behavior: 'smooth' });
        // Trigger event to handle screen validation
        var navEvent = $A.get("e.c:PSA_NavigationEvent");
        navEvent.setParams({ screenName, "from" : 'CMP' });
        navEvent.fire();
    }
})