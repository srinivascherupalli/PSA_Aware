({
    doInit: function(component, event, helper) {
        component.set("v.isLoading",false);
        var selectedPackage = component.get("v.selectedPackage");
        console.log(selectedPackage);

        var quoteId=sessionStorage.getItem("quoteId");
        component.set("v.quoteId", quoteId);
        console.log("quoteId " +quoteId);

        var isAutoRenew=sessionStorage.getItem("isAutoRenew");
        component.set("v.isAutoRenew", isAutoRenew);

        component.set("v.productName",selectedPackage.product.Name);
        var frequency=sessionStorage.getItem("frequency");
        if(frequency=='annual'){
            frequency='yearly';
        }
        component.set("v.frequency", frequency);
        if(selectedPackage.product.Name=='Student'){
            component.set("v.paymentStatus","Success");
        }else{

/*             console.log(component.get("v.sessionId"));
            console.log(component.get("v.invoiceId")); */
            var payment = {
                tax: (selectedPackage.listprice/10).toFixed(2),
                discount: 0.00,
                subtotal: selectedPackage.listprice,
                total: selectedPackage.netprice
            };
            component.set("v.payment", payment);
            helper.setUpDetails(component);
        }
    },

    handleTc: function(component, event, helper) {
        var tcCheck = component.find("tcCheck");
        tcCheck.reportValidity();
    },

    handleButtonClick: function(component, event, helper) {
/*         var productName=component.set("v.productName");
        if(productName=='Student'){
            component.set("v.sessionId",sessionStorage.getItem("sessionId"));
            component.set("v.invoiceId",sessionStorage.getItem("invoiceId"));
            helper.handlePayment(component);
        }else{ */
            helper.handlePayment(component); 
/*         }
		helper.createOrder(component); */
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

        if(!screenName) screenName = 'screen3';

        scrollTo({ top: 0, behavior: 'smooth' });
        // Trigger event to handle screen validation
        var navEvent = $A.get("e.c:PSA_NavigationEvent");
        navEvent.setParams({ screenName, "from" : 'CMP' });
        navEvent.fire();
    },
})