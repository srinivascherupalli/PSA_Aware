({
    wait: function(component, event){
        var self = this;
        self.getQuoteDetails(component,event);
        $A.get('e.force:refreshView').fire();
    },

    getQuoteDetails: function(component, event) {
        var that=this;
        component.set("v.payment", null);
        that.apexRequest(component,  'fetchQuoteDetails', {
            quoteId : component.get("v.quoteId")
        })
        .then(function(response) {
            var t = that;
            console.log("Quote response ", response);
            if(response!=null){
            
                component.set("v.quoteObj", response);
                let packageTotal = (response.SBQ_Subtotal_Calculated__c)+ (response.SBQ_Total_GST__c);
                let prodname = null;
                /*
                    Below is the code which adds Billable Unit Price (blng__BillableUnitPrice__c) for all line items to calculate payment total. (Has been changed based on feedback on total calulations from quote fields)
                    Apex method : fetchQuoteLines
                */
                /* response.forEach(function(qli){
                    packageTotal += qli.blng__BillableUnitPrice__c;
                    if(qli.SBQQ__ProductCode__c.indexOf('INS')<0){
                        prodname = qli.SBQQ__ProductName__c;
                    }
                })
                var payment = {
                    tax: (packageTotal/10).toFixed(2),
                    discount: 0.00,
                    subtotal: packageTotal - ((packageTotal/10).toFixed(2)),
                    total: packageTotal
                }; */
                var payment = {
                    tax: (response.SBQ_Total_GST__c).toFixed(2),
                    discount: 0.00,
                    subtotal: (response.SBQ_Subtotal_Calculated__c).toFixed(2),
                    total: packageTotal.toFixed(2)
                };
                component.set("v.payment", payment);
                component.set("v.productName", prodname);
                that.getQuoteLines(component, event);
                $A.get('e.force:refreshView').fire();
            }
            else{
                console.log('Cannot get quote details');
                component.set("v.isLoading", false);
                component.set("v.isError", true);
            }
        })
        .catch(error => console.log(error));
    },

    getQuoteLines: function(component, event) {
        var that=this;
        that.apexRequest(component,  'fetchQuoteLines', {
            quoteId : component.get("v.quoteId")
        })
        .then(function(response2) {
            console.log("Quote line response ", response2);
            component.set("v.quoteLinesObj",response2);
            that.getGatewayDetail(component, event);
            $A.get('e.force:refreshView').fire();
        })
        .catch(error => console.log(error));
    },
    
    getGatewayDetail: function(component, event) {
        var that=this;
        this.apexRequest(component, 'fetchGateways')
        .then(function(response) {
            if(response.length > 0){
                console.log(response[0])
                component.set('v.Gateway',response[0]);
                var t=that;
                window.setTimeout(
                    $A.getCallback(function() {
                        t.billingPaymentGateway(component,event,response[0].Id);
                    }), 3000
                );
            }
        })
        .catch(error => console.log(error));
    },

    billingPaymentGateway: function(component, event, gatewayId) {
        console.log(gatewayId)
/*         var action = component.get("c.fetchBillingPaymentGateway");
        action.setParams ({
            "gatewayId" : gatewayId
        });
        action.setCallback(this, function(response) {
            console.log("response ", response[0].Id);
            component.set("v.gatewayId", response[0].Id);
        });
        $A.enqueueAction(action);  */
        this.apexRequest(component,  'fetchBillingPaymentGateway', {
            gatewayId : gatewayId
        })
        .then(function(response) {
            console.log("response ", response[0].Id);
            component.set("v.gatewayId", response[0].Id);

        })
        .catch(error => console.log(error));

    },

    //UTILITY METHODS
    cc_format: function (value) {
        return this.tokenizer(value, 4, ' ');
    },
    date_format: function (value) {
        return this.tokenizer(value, 2, '/');
    },
    tokenizer: function (value, length, joiner) {
        var min = length;
        var max = Math.pow(length, 2);
        var matchRegex = new RegExp('\\d{' + min  + ',' + max + '}', 'g');
        //
        var v = value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
        var matches = v.match(matchRegex);
        var match = matches && matches[0] || '';
        var parts = [];
        //
        for (var i = 0, len = match.length; i < len; i+= length) {
            parts.push(match.substring(i, i+ length))
        }
        //
        return (parts.length ? parts.join(joiner) : value);
    },

    setCardIndicator: function (component, cardType) {
        var cardIndicator_Token = component.find('svgSpan-Token');
		var cardTypeName = this.getPayFormCardType(cardType);
        component.set("v.cardTypeName",cardTypeName);
        if (cardType) {
            $A.util.addClass(component.find('svgSpan-Token'), 'cardIcon');
            if (cardIndicator_Token) cardIndicator_Token.getElement().innerHTML = "<img class='slds-button__icon slds-button__icon--large slds-button__icon--right' src='/resource/1614204384000/ChargentBase__AppFrontier_Assets/svg/" + cardType + ".svg' alt='" + cardType + "' style='height: 2.6rem;position: static;width: 3rem;display: block;'/>";
        } else {
            if (cardIndicator_Token) cardIndicator_Token.getElement().innerHTML = "";
        }

    },

    validateCCNumber: function (component,ccnum) {
        var t = $.payform.validateCardNumber(ccnum);

        if (!t) {
            $A.util.addClass(component.find('card-number-form-element'), 'slds-has-error');
            $A.util.removeClass(component.find('cardwarningmsg'), 'invalidCardInfo');
        } else {
            $A.util.removeClass(component.find('card-number-form-element'), 'slds-has-error');
            $A.util.addClass(component.find('cardwarningmsg'), 'invalidCardInfo');
        }
    },
    validateCVC: function (component) {

        if (typeof $.payform == 'undefined') return false;

        var cvcNum = component.get('v.cvvNumber');
        if(!cvcNum) return;
        var cardnumber = component.get('v.cardNumber');
        var ccnum = cardnumber.replace(/\s/g, '');
        cvcNum = cvcNum.replace(/\s/g, '');
        var cardType = $.payform.parseCardType(ccnum);
        var cvcValid = $.payform.validateCardCVC(cvcNum, cardType);

        if (cardType == 'amex' && cvcNum.length < 4 && cvcNum.length != 0) cvcValid = false;

        if (cvcValid) {
            if (cvcNum.length > 0) {
                $A.util.removeClass(component.find('cvv-number-form-element'), 'slds-has-error');
            	$A.util.addClass(component.find('cvvwarningmsg'), 'invalidCVV');
                return true;
            }
        } else {
            if (cvcNum.length > 0) {
                $A.util.addClass(component.find('cvv-number-form-element'), 'slds-has-error');
                $A.util.removeClass(component.find('cvvwarningmsg'), 'invalidCVV');
            }else{
                $A.util.removeClass(component.find('cvv-number-form-element'), 'slds-has-error');
            	$A.util.addClass(component.find('cvvwarningmsg'), 'invalidCVV');
            }
            return false;
        }
        return cvcValid;
    },
    getPayFormCardType: function (cardType) {
        if (cardType == 'amex')
            return 'American Express';
        if (cardType == 'maestro')
            return 'UK Maestro';
        if (cardType == 'jcb')
            return 'JCB Card';
        if (cardType == 'dinersclub')
            return 'Diners Club';
        if (cardType == 'mastercard')
            return 'Mastercard';
        if (cardType == 'visa')
            return 'Visa';
        if (cardType == 'discover')
            return 'Discover';
    },

    isValid : function (component) {
        var isExpirationDateValid = false;
        var invalidCardNumber = true;
        var isCVVValid = true;

        //Get expiration_date field
        var expirationDateField = component.find('fields').filter(function (field) {
            return field.get('v.name') == 'card_Exparation_date';
        })[0];
        //Validate expiration_date
        if(expirationDateField != undefined && expirationDateField != null
           && !$A.util.isEmpty(expirationDateField.get('v.value'))) {
            var expirationMonth = expirationDateField.get('v.value').split('/')[0];
            var expirationYear = expirationDateField.get('v.value').split('/')[1];
            var today = new Date();

            if(expirationYear == today.getFullYear().toString().slice(-2) && expirationMonth >= today.getMonth()+1) {
                isExpirationDateValid = true;
                expirationDateField.setCustomValidity('');
            } else if (expirationYear > today.getFullYear().toString().slice(-2)) {
                isExpirationDateValid = true;
                expirationDateField.setCustomValidity('');
            } else {
                isExpirationDateValid = false;
                expirationDateField.focus();
                //TODO: Custom Label
                expirationDateField.setCustomValidity('Enter a valid Expiration Date');
            }
            expirationDateField.reportValidity();
        }

        // validate card number
        var cardNumberField = component.find('fields').filter(function (field) {
            return field.get('v.name') == 'card_Number';
        })[0];

        if(cardNumberField != undefined && cardNumberField != null
           && !$A.util.isEmpty(cardNumberField.get('v.value'))) {

            var cardnumber = component.get('v.cardNumber');
            var ccnum = cardnumber.replace(/\s/g, '');

            var t = $.payform.validateCardNumber(ccnum);

            if(!t){
                invalidCardNumber = false;
            }
            this.validateCCNumber(component,ccnum);
        }

        //validate CVV Number
        isCVVValid = this.validateCVC(component);

        //Validate form has all required fields and are valid
        var allFieldsValid = component.find('fields').reduce(function (validSoFar, field) {
            field.reportValidity();
            var isValid = (
                field.getValidity
                ? field.getValidity().valid
                : field.checkValidity()
            );
            if (validSoFar && !isValid) {
                field.focus();
            } else {
                field.setCustomValidity("");
            }
            return validSoFar && isValid;
        }, true);

        return allFieldsValid && isExpirationDateValid && invalidCardNumber && isCVVValid;

    },

    confirmPayment: function(component, screenName) {
        
        component.set('v.isLoading', true);
        //Get values from Credit Card Form        
        var accountId = component.get('v.accountId');
        var billingAddress = component.get('v.billingAddress');
        var billingCity = component.get('v.billingCity');
        var billingState = component.get('v.billingState');
        var billingZip = component.get('v.billingZip');
        var billingCountry = component.get('v.billingCountry');
        var payAmount = component.get("v.payment").total;

        var firtname = component.get("v.firstName");
        var lastname = component.get("v.lastName");
        var cardHolderName = firtname + ' ' + lastname;
        var cardNumber = component.get('v.cardNumber').replace(/\s/g, '');
        var expirationDate = component.get('v.cardExpirationDate').split('/');
        var cardType = component.get("v.cardTypeName");
        var cvvNumber = component.get("v.cvvNumber");
        var gatewayId=component.get("v.gatewayId");
        console.log(expirationDate[0]);
        console.log(expirationDate[1]);

        var billingInfo = {
            paymentMethod: {
                paymentType : 'Credit Card',
                lastName: lastname,
                firstName: firtname,
                email: null,
                saveForFuture:false,
                autoPay:false,
                cardPaymentMethod : {
                    expiryYear: '20' + expirationDate[1],
                    expiryMonth: expirationDate[0],
                    cvv: cvvNumber,
                    cardType: cardType,
                    cardNumber: cardNumber,
                    cardHolderName: cardHolderName
                },
                address : {
                    state: billingState,
                    postalCode: billingZip,
                    country: billingCountry,
                    city: billingCity,
                    addressLine2: '',
                    addressLine1: billingAddress
                }
            },
            gatewayId: gatewayId,
            amount: parseFloat(payAmount),
            accountId: accountId
        };

        component.set("v.billingInfo", billingInfo);
        component.set('v.isLoading', false);
        console.log('billing ',  Object.values(component.get("v.billingInfo")));
        console.log('billing2 ',  billingInfo);
        scrollTo({ top: 0, behavior: 'smooth' });
        // Trigger event to handle screen validation
        var navEvent = $A.get("e.c:PSA_NavigationEvent");
        navEvent.setParams({ screenName, "from" : 'CMP' });
        navEvent.fire();
    },

    SetupDetails: function(component, event, helper) {
        var billingInfo = component.get("v.billingInfo");
        console.log(billingInfo)
        if(!billingInfo || !billingInfo.paymentMethod) return;

        //Get values from Credit Card Form
        component.set('v.billingAddress', billingInfo.paymentMethod.address.addressLine1);
        component.set('v.billingCity', billingInfo.paymentMethod.address.city);
        component.set('v.billingState', billingInfo.paymentMethod.address.state);
        component.set('v.billingZip', billingInfo.paymentMethod.address.postalCode);
        component.set('v.billingCountry', billingInfo.paymentMethod.address.country);
        component.set('v.firstName', billingInfo.paymentMethod.firstName);
        component.set('v.lastName', billingInfo.paymentMethod.lastName);
        component.set('v.cardNumber', billingInfo.paymentMethod.cardPaymentMethod.cardNumber);
        component.set('v.cvvNumber', billingInfo.paymentMethod.cardPaymentMethod.cvv);
        component.set('v.cvvNumber', billingInfo.paymentMethod.cardPaymentMethod.cvv);

        var expiryYear = billingInfo.paymentMethod.cardPaymentMethod.expiryYear;
        var expiryMonth = billingInfo.paymentMethod.cardPaymentMethod.expiryMonth;
        var expirationDate = ( expiryMonth > 9 ? '' + expiryMonth : expiryMonth) + expiryYear.toString().substr(-2);
        component.set('v.cardExpirationDate', expirationDate);
    }
})