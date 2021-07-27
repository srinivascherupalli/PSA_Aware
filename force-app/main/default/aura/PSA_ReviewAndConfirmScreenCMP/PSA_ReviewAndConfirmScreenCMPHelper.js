({
    handlePayment: function(component, event) {
        console.log(JSON.stringify(component.get("v.billingInfo")));

/*         console.log(component.get("v.sessionId"));
        console.log(component.get("v.invoiceId")); */

        this.apexRequest(component,  'ProcessPaymentForGivenQuote', {
            paymentdetails: JSON.stringify(component.get("v.billingInfo")),
            quoteId: component.get("v.quoteId")
            /* sessionId: sessionStorage.getItem("sessionId") */
        })
        .then(this.withCallback(component, this.handlePaymentResponse))
        .catch(this.withCallback(component, this.handlePaymentError));
    },
    
    handlePaymentResponse:  function(component, event) {
        var that=this;
        component.set("v.isLoading",true);
        this.apexRequest(component,  'CheckPaymentProcessByQuoteId', {
            quoteId: component.get("v.quoteId"),
            sessionId: sessionStorage.getItem("sessionId")
        })
        .then(function(response){
            console.log('CheckPaymentProcessRes ', response)
            if(response){
                var t=that;
                console.log('CheckPaymentProcess ', response)
                //component.set("v.paymentStatus","Success")
                component.set("v.isLoading",true);
                window.setTimeout(
                    $A.getCallback(function() {
                        t.createOrder(component, event);
                    }),1000
                );
                component.set("v.callCount",0);
            }else{
                console.log('CheckPaymentProcess fail');
                component.set("v.isLoading",true);
                var count=component.get("v.callCount");
                var t=that;
                window.setTimeout(
                    $A.getCallback(function() {
                        if(count<=10){
                            t.handlePaymentResponse(component, event);
                            }else{
                                component.set("v.isLoading",false);
                                component.set('v.paymentStatus','Fail');
                            }
                            component.set("v.callCount",count+=1);
                        
                    }), 3000
                );

            }

        })
        .catch(function(e){
            console.log('error '+ JSON.stringify(e));
            component.set('v.paymentStatus','Fail');
            component.set('v.isLoading', false);
        });

    },
    
    handlePaymentError: function (component, error) {
        //Log error
        console.log(error);
        
        //TODO: Custom Label
/*         this.showToast('Payment!',
                          'error',
                           1000,
                          'Your payment has been rejected.'); */
        component.set('v.paymentStatus','Fail');
        component.set('v.isLoading', false);
    },

    createOrder: function(component, event) {
        var that=this;
        this.apexRequest(component, 'createOrder' , {
            quoteId: component.get("v.quoteId")
        })
        .then(function(response){
            if(response){
            console.log('response3 ', response);
            }else{
                console.log('create order')
            }
            component.set("v.isLoading",true);
            var t=that;
            window.setTimeout(
                $A.getCallback(function() {
                    t.getOrderId(component, event);
                }),1000
            );

        }).catch(function(e){
            console.log('error '+ JSON.stringify(e));
            component.set("v.isLoading",false);
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
                    component.set("v.isLoading",true);
                    window.setTimeout(
                        $A.getCallback(function() {
                            t.getInvoiceId(component, event);
                        }),1000
                    );
                    component.set("v.callCount",0);
            }else{
                component.set("v.isLoading",true);
                console.log('getOrderId fail');
                var t=that;
                var count=component.get("v.callCount");
                window.setTimeout(
                    $A.getCallback(function() {
                        if(count<=10){
                        t.getOrderId(component, event);
                        }else{
                            component.set("v.isLoading",false);
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
            component.set("v.isLoading",false);
            component.set("v.paymentStatus","Fail");

        });
    },

    getInvoiceId: function(component, event) {
        var that=this;
        var isAutoRenew=component.get("v.isAutoRenew");
       // isAutoRenew=isAutoRenew.toString();
       // sessionStorage.setItem("sessionId", component.get("v.sessionId"));
        var productName=component.get('v.productName');
        this.apexRequest(component, 'getInvoiceId' , {
            orderId:  component.get('v.orderId'),
            optOutforRenewal: isAutoRenew,
            isStudentPackage: productName=='Student'? true:false,
            sessionId: sessionStorage.getItem("sessionId")
        })
        .then(function(response){
            console.log('getInvoiceIdRes ', response)
            if(response){
                var t=that;
                console.log('invoiceId ', response)
                component.set('v.invoiceId',response);
                component.set("v.isLoading",true);
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
                component.set("v.isLoading",true);
                console.log('invoiceId fail');
                var t=that;
                var count=component.get("v.callCount");
                window.setTimeout(
                    $A.getCallback(function() {
                        if(count<=10){
                        t.getInvoiceId(component, event);
                        }else{
                            component.set("v.isLoading",false);
                            component.set("v.paymentStatus","Fail");
                        }
                        component.set("v.callCount",count+=1);
                    }), 3000
                );

            }

        })
        .catch(function(e){
            console.log('error '+ JSON.stringify(e));
            component.set("v.isLoading",false);
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
            component.set("v.isLoading",false);
            // sessionStorage.setItem("invoiceId", response);
            component.set("v.paymentStatus","Success")
        })
        .catch(function(e){
            console.log('error '+ JSON.stringify(e));
            component.set("v.isLoading",false);
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
            component.set("v.isLoading",false);
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