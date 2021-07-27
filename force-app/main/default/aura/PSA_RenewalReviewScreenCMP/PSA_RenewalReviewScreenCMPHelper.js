({
    fetchPaymentDetails:  function(component, event) {
        
        this.apexRequest(component,  'fetchPaymentDetails', {
            invoiceId: component.get('v.invoiceId')/* ,
            accountId: component.get("v.invoiceRecord").blng__Account__c */
        })
        .then(function(response) {
            var { invLines , billingAccount } = response;   
            if(invLines && invLines.length > 0)  
            component.set("v.invLinePrice", invLines);       
                component.set("v.invLine", invLines[0]);
                var invoice = invLines[0].blng__Invoice__r;
				component.set("v.product_Name",invLines[0].Name);
            	component.set("v.frequency",invLines[0].blng__BillingFrequency__c);

                var payment = {
                    tax: invoice.blng__TaxAmount__c,
                    discount: 0,
                    subtotal: invoice.blng__Subtotal__c,
                    total: invoice.blng__TotalAmount__c
                };
                component.set("v.payment", payment);
                console.log(payment);
        })
        .catch(error => console.log(error));
    },

    handlePayment: function(component, event) {
        component.set('v.isLoading', true);
        component.set('v.isLoadingMsg', true);
        if(component.get("v.currentUser.Profile.Name")){
            this.apexRequest(component,  'ProcessPayment', {
                invoiceId: component.get('v.invoiceId'),
                paymentdetails: JSON.stringify(component.get("v.billingInfo"))
            })
            .then(this.withCallback(component, this.handlePaymentResponse))
            .catch(this.withCallback(component, this.handlePaymentError));

        }else{
            this.apexRequest(component,  'ProcessPayment', {
                invoiceId: component.get('v.invoiceId'),
                paymentdetails: JSON.stringify(component.get("v.billingInfo"))
            })
            .then(this.withCallback(component, this.handlePaymentResponse))
            .catch(this.withCallback(component, this.handleButtonPoll));
        }

    },
    
    handlePaymentResponse:  function(component, response) {
        console.log(response);
        
        if(response.isSuccess){
            component.set('v.paymentStatus','Success');
            document.body.scrollTop = 0; // For Safari
            document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
        }else{
            component.set('v.paymentStatus','Fail');
        }
        component.set('v.isLoading', false);
        component.set('v.isLoadingMsg', false);
    },

    handleButtonPoll: function(component, event) {
        component.set('v.isLoading', true);
        component.set('v.isLoadingMsg', true);
        var timesRun = component.get('v.pollingCount');
        var that=this;

    
        window.setInterval(
                    $A.getCallback(function() {
                    var paymentStatus = component.get('v.paymentStatus');
                    var paymentStatusCall = true;
                    console.log(paymentStatus)
                    if(paymentStatus!='Success' && paymentStatusCall){
                    timesRun = component.get('v.pollingCount');
                    timesRun = timesRun + 1;
                    component.set('v.pollingCount',timesRun);
                    if(timesRun <= 10){
                        console.log("timesRun ", timesRun)
                        that.handlePollPayment(component);
                    }else{
                        component.set('v.paymentStatus','Fail');
                        paymentStatusCall = false;
                        component.set('v.isLoading', false);
                        component.set('v.isLoadingMsg', false);
                    }
                }
                    
                }),5000);  
        
    },

    handlePaymentError: function (component, error) {
        //Log error
        console.log(error);
        
        //TODO: Custom Label
        component.set('v.paymentStatus','Fail');
        component.set('v.isLoading', false);
        component.set('v.isLoadingMsg', false);
    },

    handlePollPayment: function(component) {
        //var pollingCount=component.get('v.pollingCount');
        var that=this;
        var paymentStatus = component.get('v.paymentStatus');
        var action = component.get("c.CheckPaymentProcess");
        if(paymentStatus!='Success'){
        action.setParams({
            invoiceId: component.get('v.invoiceId')
        });
        
        action.setCallback(this, function(response) {
      //      pollingCount += 1;
            var data=response.getReturnValue();
/*             component.set('v.pollingCount',pollingCount);
            console.log("pollingCount ", pollingCount) */
            console.log("paymentVal ", data)
           // if(pollingCount<10){
                if(data){
                    if(data.isSuccess){
                        component.set('v.paymentStatus','Success');
                        document.body.scrollTop = 0; // For Safari
                        document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
                        component.set('v.isLoading', false);
                        component.set('v.isLoadingMsg', false);
                        //pollingCount=0;
                        //component.set('v.pollingCount',pollingCount);
                    }else if(data.isSuccess=='false'){
                        component.set('v.paymentStatus','Fail');
                        component.set('v.isLoading', false);
                        component.set('v.isLoadingMsg', false);
                        //pollingCount=0;
                        //component.set('v.pollingCount',pollingCount);
                    }
                }
           /*  }else{
                component.set('v.paymentStatus','Fail');
                component.set('v.isLoading', false);
                component.set('v.isLoadingMsg', false);
            } */
        });
        $A.enqueueAction(action);
    }
        /* this.apexRequest(component,  'CheckPaymentProcess', {
            invoiceId: component.get('v.invoiceId')
        })
        .then(function(response) {
            pollingCount += 1;
            component.set('v.pollingCount',pollingCount);
            console.log("pollingCount ", pollingCount)
            console.log("paymentVal ", response)
            if(pollingCount<10){
                if(response!=null){
                    if(response.isSuccess){
                        component.set('v.paymentStatus','Success');
                        document.body.scrollTop = 0; // For Safari
                        document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
                        component.set('v.isLoading', false);
                        component.set('v.isLoadingMsg', false);
                        pollingCount=10;
                        component.set('v.pollingCount',pollingCount);
                    }else if(response.isSuccess=='false'){
                        component.set('v.paymentStatus','Fail');
                        component.set('v.isLoading', false);
                        component.set('v.isLoadingMsg', false);
                        pollingCount=10;
                        component.set('v.pollingCount',pollingCount);
                    }
                }else{
                    that.handlePollPayment(component);
                }
            }else{
                component.set('v.paymentStatus','Fail');
                component.set('v.isLoading', false);
                component.set('v.isLoadingMsg', false);
            }
        }); */
    },

    setUpDetails: function(component) {
        var billinginfo = component.get("v.billingInfo");
        try {
            //console.log(console.log(JSON.stringify(billinginfo)));
            if(!billinginfo.paymentMethod) return;

            var cardNumber = billinginfo.paymentMethod.cardPaymentMethod.cardNumber;
            cardNumber = cardNumber.substring(cardNumber.length - 4);
            component.set("v.cardNumber", cardNumber);

            var cardType = this.getPayFormCardType(billinginfo.paymentMethod.cardPaymentMethod.cardType);

            var cardIndicator_Token = component.find('svgSpan-Token');
            console.log(component.find('svgSpan-Token').getElement())
            if (cardType) {
                $A.util.addClass(component.find('svgSpan-Token'), 'cardIcon');

                if (cardIndicator_Token) 
                $A.createComponents([
                    ["aura:html",{ 
                        tag: "img",
                        HTMLAttributes: { 
                            "id": "icon-img",
                            "class": "slds-button__icon slds-button__icon--large slds-button__icon--right",
                            "src": "/resource/1608129181000/ChargentBase__AppFrontier_Assets/svg/" + cardType + ".svg",
                            "alt" : cardType,
                            "style": 'height: 2.6rem;position: static;width: 3rem;margin-right: 5px;'
                            }
                    }],
                    ["aura:unescapedHtml",{
                        value: cardNumber
                    }]
                    ],
                     function(compo){
                          var container = component.find('svgSpan-Token');
                          if (container.isValid()) {
                              var body = container.get("v.body");
                              body.push(compo[0]);
                              body.push(compo[1]);
                              container.set("v.body", body);
                          }
                     }
                );
            
            } 

            var address = Object.assign({}, billinginfo.paymentMethod.address);;
            address.name = billinginfo.paymentMethod.cardPaymentMethod.cardHolderName;
            
            component.set("v.Address", address);
        } catch(error) {console.log(error)}
    },

    getPayFormCardType: function (cardType) {
        if (cardType == 'American Express')
            return 'amex';
        if (cardType == 'UK Maestro')
            return 'maestro';
        if (cardType == 'JCB Card')
            return 'jcb';
        if (cardType == 'Diners Club')
            return 'dinersclub';
        if (cardType == 'Mastercard')
            return 'mastercard';
        if (cardType == 'Visa')
            return 'visa';
        if (cardType == 'Discover')
            return 'discover';
        return '';
    }
})