({
    fetchPaymentDetails:  function(component, event) {
        this.apexRequest(component,  'fetchPaymentDetails', {
            invoiceId: component.get('v.invoiceId')/* ,
            accountId: component.get("v.invoiceRecord").blng__Account__c */
        })
        .then(function(response) {
            console.log(response)
            var { invLines , billingAccount } = response;
            component.set("v.billingAccount", invLines);

            var invoice = invLines[0].blng__Invoice__r;

            console.log(component.get("v.billingAccount"));
            component.set("v.product_Name",invLines[0].Name);
            component.set("v.frequency",invLines[0].blng__BillingFrequency__c);
            console.log(component.get("v.product_Name"));
            var payment = {
                tax: invoice.blng__TaxAmount__c,
                discount: 0,
                subtotal: invoice.blng__Subtotal__c,
                total: invoice.blng__TotalAmount__c
            };
            console.log(payment)
            component.set("v.payment", payment);
        })
        .then(this.withCallback(component, this.getGatewayDetail))
        .then(this.withCallback(component, this.SetupDetails))
        .catch(error => console.log(error));
    },

    getGatewayDetail: function(component, event, helper) {
        var that=this;
        this.apexRequest(component, 'fetchGateways')
        .then(function(response) {
            if(response.length > 0){
                console.log(response[0])
                component.set('v.Gateway',response[0]);
                that.billingPaymentGateway(component, event, helper,response[0].Id);
            }
        })
        .catch(error => console.log(error));

    },

    billingPaymentGateway: function(component, event, helper, gatewayId) {
        console.log(gatewayId)
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
        var invoiceId = component.get('v.invoiceId');
        var accountId = component.get('v.billingAccount')[0].blng__Invoice__r.blng__Account__c;
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
            amount: payAmount,
            accountId: accountId
        };

        component.set("v.billingInfo", billingInfo);
        component.set('v.isLoading', false);
        
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
    },

})