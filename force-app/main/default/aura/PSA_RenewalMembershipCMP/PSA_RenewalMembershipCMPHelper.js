({
	fetchPaymentDetails:  function(component, event) {
        //console.log("test1");
      //  console.log(component.get("v.invoiceRecord").blng__Account__c)


        this.apexRequest(component,  'fetchPaymentDetails', {
            invoiceId: component.get('v.invoiceId')/* ,
            accountId: component.get("v.invoiceRecord").blng__Account__c */
        })
        .then(function(response) {
            var { invLines , billingAccount } = response;   
            if(invLines && invLines.length > 0)         
                component.set("v.invLine", invLines[0]);
                component.set("v.invLinePrice", invLines);
                var membershipNames = invLines.map(function(value) {
                    return value.Name;
                  });
                  membershipNames = JSON.stringify(membershipNames).replace(/\[|]|"|"/g,"").replace(',',', ');
                  component.set("v.membershipNames", membershipNames);

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
        this.apexRequest(component,  'postInvoice', {
            invoiceId: component.get('v.invoiceId'),
        })
        .then($A.getCallback(function(response) {
            
            scrollTo({ top: 0, behavior: 'smooth' });
            // Trigger event to handle screen validation
            var navEvent = $A.get("e.c:PSA_NavigationEvent");
            navEvent.setParams({ screenName, "from" : 'CMP' });
            navEvent.fire();
            
        }))
        .catch(error => console.log(error));       
        
    }
})