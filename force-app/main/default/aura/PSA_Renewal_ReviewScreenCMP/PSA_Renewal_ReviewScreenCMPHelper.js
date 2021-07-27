({
    fetchPaymentDetails:  function(component, event) {
        
        this.apexRequest(component,  'fetchPaymentDetailsForQuote', {
            quoteId: component.get('v.quoteId')/* ,
            accountId: component.get("v.invoiceRecord").blng__Account__c */
        })
        .then(function(response) {
            var invLines = response;   
            if(invLines && invLines.length > 0)  
            component.set("v.invLinePrice", invLines);       
                component.set("v.invLine", invLines[0]);
                var invoice = invLines[0].SBQQ__Quote__r;
                component.set("v.product_Name",invLines[0].SBQQ__ProductName__c);
                component.set("v.frequency",invLines[0].SBQQ__BillingFrequency__c);

                var payment = {
                    tax: 0,
                    discount: invoice.SBQQ__TotalCustomerDiscountAmount__c,
                    subtotal: invoice.SBQQ__ListAmount__c,
                    total: invoice.SBQQ__RegularAmount__c
                };
                component.set("v.payment", payment);
                console.log(payment);
        })
        .catch(error => console.log(error));
    },

    handlePayment: function(component, event) {
        component.set('v.isLoading', true);
        component.set('v.isLoadingMsg', true);
        console.log(component.get('v.quoteId'))
        console.log(JSON.stringify(component.get("v.billingInfo")))
       // if(component.get("v.currentUser.Profile.Name")){
            this.apexRequest(component,  'ProcessPaymentForQuoteRenewal', {
                quoteId: component.get('v.quoteId'),
                paymentdetails: JSON.stringify(component.get("v.billingInfo"))
            })
            .then(this.withCallback(component, this.handlePollPayment))
            .catch(this.withCallback(component, this.handlePaymentError));

       /*  }else{
            this.apexRequest(component,  'ProcessPaymentForQuote', {
                quoteId: component.get('v.quoteId'),
                paymentdetails: JSON.stringify(component.get("v.billingInfo"))
            })
            .then(this.withCallback(component, this.handlePollPayment))
            .catch(this.withCallback(component, this.handlePaymentError));
        } */

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

/*     handleButtonPoll: function(component, event) {
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
        
    }, */

    handlePaymentError: function (component, error) {
        //Log error
        console.log(error);
        
        //TODO: Custom Label
        component.set('v.paymentStatus','Fail');
        component.set('v.isLoading', false);
        component.set('v.isLoadingMsg', false);
    },

    handlePollPayment: function(component) {

    var that=this;
    var paymentStatus = component.get('v.paymentStatus');
  //  if(paymentStatus!='Success'){
    this.apexRequest(component, 'CheckPaymentProcessByQuoteIdForRenewal' , {
        quoteId: component.get("v.quoteId")
    })
    .then(function(response){
        console.log('getOrderIdResponse2 ', response)
        if(response){
            if(response.isSuccess){
                document.body.scrollTop = 0; // For Safari
                document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
                component.set('v.isLoading', true);
                component.set('v.isLoadingMsg', true);
                var t=that;
                window.setTimeout(
                    $A.getCallback(function() {
                        t.createOrder(component, event);
                    }),1000
                );
                component.set("v.callCount",0);
            }else if(response.isSuccess=='false'){
                component.set('v.paymentStatus','Fail');
                component.set('v.isLoading', false);
                component.set('v.isLoadingMsg', false);
            }

        }else{
            component.set('v.isLoading', true);
            component.set('v.isLoadingMsg', true);
            console.log('CheckPaymentProcess fail');
            var t=that;
            var count=component.get("v.callCount");
            window.setTimeout(
                $A.getCallback(function() {
                    if(count<=10){
                    t.handlePollPayment(component, event);
                    }else{
                        component.set('v.isLoading', false);
                        component.set('v.isLoadingMsg', false);
                        component.set("v.paymentStatus","Fail");
                    }
                    component.set("v.callCount",count+=1);
                }),3000
            );

        }

    })
    .catch(function(e){

        console.log('error '+ JSON.stringify(e));
        component.set('v.isLoading', false);
        component.set('v.isLoadingMsg', false);
        component.set("v.paymentStatus","Fail");

    });
    //}
    },

    createOrder: function(component, event) {
        var that=this;
        this.apexRequest(component, 'createRenewalOrderForRenew' , {
            quoteId: component.get("v.quoteId")
        })
        .then(function(response){
            if(response){
            console.log('createOrder ', response);
            }else{
                console.log('create order')
            }
            component.set('v.isLoading', true);
            component.set('v.isLoadingMsg', true);
            var t=that;
            window.setTimeout(
                $A.getCallback(function() {
                    t.getOrderId(component, event);
                }),1000
            );

        }).catch(function(e){
            console.log('error '+ JSON.stringify(e));
            component.set('v.isLoading', false);
            component.set('v.isLoadingMsg', false);
            component.set("v.paymentStatus","Fail");

        });

    },

    getOrderId: function(component, event) {
        var that=this;
        this.apexRequest(component, 'getOrderId' , {
            quoteId: component.get("v.quoteId")
        })
        .then(function(response){
            console.log('getOrderIdResponse2 ', response)
            if(response){
                console.log('getOrderId ', response)
                component.set('v.orderId',response);
                var t=that;
                component.set('v.isLoading', true);
                component.set('v.isLoadingMsg', true);
                    window.setTimeout(
                        $A.getCallback(function() {
                            t.getInvoiceId(component, event);
                        }),1000
                    );
                    component.set("v.callCount",0);
            }else{
                component.set('v.isLoading', true);
                component.set('v.isLoadingMsg', true);
                console.log('getOrderId fail');
                var t=that;
                var count=component.get("v.callCount");
                window.setTimeout(
                    $A.getCallback(function() {
                        if(count<=10){
                        t.getOrderId(component, event);
                        }else{
                            component.set('v.isLoading', false);
                            component.set('v.isLoadingMsg', false);
                            component.set("v.paymentStatus","Fail");
                        }
                        component.set("v.callCount",count+=1);
                    }),3000
                );
                //that.getOrderId(component, event);

            }

        })
        .catch(function(e){

            console.log('error '+ JSON.stringify(e));
            component.set('v.isLoading', false);
            component.set('v.isLoadingMsg', false);
            component.set("v.paymentStatus","Fail");

        });
    },

    getInvoiceId: function(component, event) {
        var that=this;
        var isAutoRenew=false;
        component.set("v.sessionId", 'sess'+Math.floor(10000000 + Math.random() * 90000000));
       // isAutoRenew=isAutoRenew.toString();
       // sessionStorage.setItem("sessionId", component.get("v.sessionId"));
        var productName=component.get('v.productName');
        this.apexRequest(component, 'getInvoiceId' , {
            orderId:  component.get('v.orderId'),
            optOutforRenewal: isAutoRenew,
            isStudentPackage: false,
            sessionId: component.get("v.sessionId")
        })
        .then(function(response){
            console.log('getInvoiceIdRes ', response)
            if(response){
                var t=that;
                console.log('invoiceId ', response)
                component.set('v.invoiceId',response);
                component.set('v.isLoading', true);
                component.set('v.isLoadingMsg', true);
               // sessionStorage.setItem("invoiceId", response);
              // component.set("v.paymentStatus","Success")
                window.setTimeout(
                    $A.getCallback(function() {
                        t.updatePaymentWithInvoiceId(component, event);
                    }),1000
                );
                component.set("v.callCount",0);
                //that.PageNavigation(component, event);
                
            }else{
                component.set('v.isLoading', true);
                component.set('v.isLoadingMsg', true);
                console.log('invoiceId fail');
                var t=that;
                var count=component.get("v.callCount");
                window.setTimeout(
                    $A.getCallback(function() {
                        if(count<=10){
                        t.getInvoiceId(component, event);
                        }else{
                            component.set('v.isLoading', false);
                            component.set('v.isLoadingMsg', false);
                            component.set("v.paymentStatus","Fail");
                        }
                        component.set("v.callCount",count+=1);
                    }), 3000
                );

            }

        })
        .catch(function(e){
            console.log('error '+ JSON.stringify(e));
            component.set('v.isLoading', false);
            component.set('v.isLoadingMsg', false);
            component.set("v.paymentStatus","Fail");
        });

    },

    updatePaymentWithInvoiceId: function(component, event) {

        this.apexRequest(component, 'updatePaymentWithInvoiceId' , {
            quoteId:  component.get('v.quoteId'),
            invoiceId: component.get('v.invoiceId')
        })
        .then(function(response){
            console.log('updatePaymentWithInvoiceIdRes ', response)
            component.set('v.isLoading', false);
            component.set('v.isLoadingMsg', false);
            // sessionStorage.setItem("invoiceId", response);
            component.set("v.paymentStatus","Success")
        })
        .catch(function(e){
            console.log('error '+ JSON.stringify(e));
            component.set('v.isLoading', false);
            component.set('v.isLoadingMsg', false);
            component.set("v.paymentStatus","Fail");
        });
        
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