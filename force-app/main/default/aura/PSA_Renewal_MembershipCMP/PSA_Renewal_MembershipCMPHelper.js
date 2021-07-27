({
	fetchPaymentDetails:  function(component, event) {
        //console.log("test1");
      //  console.log(component.get("v.invoiceRecord").blng__Account__c)
      var queryString = window.location.search;
      var urlParams = new URLSearchParams(queryString);
      var quoteId = urlParams.get('quoteId');
      component.set("v.quoteId",quoteId);

      console.log(component.get('v.quoteId'));
        this.apexRequest(component,  'fetchPaymentDetailsForQuote', {
            quoteId: component.get('v.quoteId')/* ,
            accountId: component.get("v.invoiceRecord").blng__Account__c */
        })
        .then(function(response) {
            console.log('invLine ', response);
            var invLines  = response;   
            if(invLines && invLines.length > 0)         
                component.set("v.invLine", invLines[0]);
                component.set("v.invLinePrice", invLines);
                var membershipNames = invLines.map(function(value) {
                    return value.SBQQ__ProductName__c;
                  });
                membershipNames = JSON.stringify(membershipNames).replace(/\[|]|"|"/g,"").replace(',',', ');
                component.set("v.membershipNames", membershipNames);


                component.set("v.frequency", invLines[0].SBQQ__BillingFrequency__c);
                component.set("v.selectedPackage", invLines[0]);
                component.set("v.accountId", invLines[0].SBQQ__Quote__r.SBQQ__Account__c);
                component.set("v.profileDetail", invLines[0].SBQQ__Quote__r.SBQQ__Account__r.PersonMailingAddress);
                component.set("v.startDate", invLines[0].SBQQ__Quote__r.SBQQ__StartDate__c);

                let paymentAmount = 0.00;
                let freq = invLines[0].SBQQ__BillingFrequency__c;
                let quoteTotal = invLines[0].SBQQ__NetTotal__c;
                if(freq=='Annual'){
                    paymentAmount = quoteTotal;
                }
                else if(freq=='Quarterly'){
                    paymentAmount = quoteTotal/4;
                }
                else if(freq=='Monthly'){
                    paymentAmount = quoteTotal/12;
                }

                paymentAmount = Math.round((paymentAmount + Number.EPSILON) * 100) / 100;
                component.set("v.paymentAmount", paymentAmount);
                
                console.log(JSON.stringify(invLines));
        })
        .catch(error => console.log(error));

        console.log("test");

    },
    
    handleValidation: function(component, event, screenName) {
        scrollTo({ top: 0, behavior: 'smooth' });
        // Trigger event to handle screen validation
        var navEvent = $A.get("e.c:PSA_NavigationEvent");
        navEvent.setParams({ screenName, "from" : 'CMP' });
        navEvent.fire();
        
        var accepted = false;
/*         this.apexRequest(component,  'postInvoice', {
            quoteId: component.get('v.quoteId'),
        })
        .then($A.getCallback(function(response) {
            
            scrollTo({ top: 0, behavior: 'smooth' });
            // Trigger event to handle screen validation
            var navEvent = $A.get("e.c:PSA_NavigationEvent");
            navEvent.setParams({ screenName, "from" : 'CMP' });
            navEvent.fire();
            
        }))
        .catch(error => console.log(error));    */    
        
    }
})