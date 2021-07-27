({
    doInit: function(component, event, helper) {
        var selectedPackage = component.get("v.selectedPackage");
        console.log(selectedPackage);
       // var frequency = component.get("v.frequency");
        var frequency=sessionStorage.getItem("frequency");
        if(frequency=='annual'){
            frequency='annually';
        }
        component.set("v.isLoading", true);
        component.set("v.frequency", frequency);
        var quoteid = component.get("v.quoteId");
        if(quoteid==null){
            component.set("v.isLoading", false);
            component.set("v.isError", true);
        }
        else{
            window.setTimeout(
                $A.getCallback(function() {
                    helper.wait(component, event);
                }), 10000
            );
        }
    },

	handleButtonClick: function(component, event, helper) {
        var screenName = event && event.getParam ?  event.getParam("screenName") : undefined;
        var fromCMP =  event && event.getParam ? event.getParam('from') : undefined;
        if(fromCMP && fromCMP == 'CMP') return;

        if(!screenName) screenName = 'screen5';

        if (helper.isValid(component)) {
            helper.confirmPayment(component, screenName);
        }
    },

    handleBackButtonClick: function(compoennt, event, helper) {
        scrollTo({ top: 0, behavior: 'smooth' });
        // Trigger event to handle screen validation
        var navEvent = $A.get("e.c:PSA_NavigationEvent");
        navEvent.setParams({ screenName: 'screen3', "from" : 'CMP' });
        navEvent.fire();
    },

    checkCardNumber: function(component,event,helper){
        if(component.isValid()){
            
            if (typeof $.payform == 'undefined') return false;
            
            var cardnumber = component.get('v.cardNumber');
            
            var ccnum = cardnumber.replace(/\s/g, '');
            var cardType = $.payform.parseCardType(ccnum);
            var cardLengthToCheck = cardType == 'amex' ? 15 : 16;
            
            helper.setCardIndicator(component, cardType);
            
            var acceptCardType = true;
            var availableMethodsLowerCase = component.get('v.Gateway.ChargentBase__Available_Card_Types__c');
            if (!$A.util.isEmpty(cardType)) {
                if (!$A.util.isEmpty(component.get("v.Gateway"))) {
                    if (availableMethodsLowerCase)
                        availableMethodsLowerCase = availableMethodsLowerCase.toLowerCase();
                    else
                        availableMethodsLowerCase = '';
                    
                    if (cardType == 'amex')
                        acceptCardType = availableMethodsLowerCase.indexOf('american express') != -1;
                    else if (cardType == 'maestro')
                        acceptCardType = availableMethodsLowerCase.indexOf('uk maestro') != -1;
                    else if (cardType == 'jcb')
                        acceptCardType = availableMethodsLowerCase.indexOf('jcb card') != -1;
                    else if (cardType == 'dinersclub')
                        acceptCardType = availableMethodsLowerCase.indexOf('diners club') != -1;
                    else
                        acceptCardType = availableMethodsLowerCase.indexOf(cardType) != -1;
                }                
            } 
            
            if (!acceptCardType) {
                $A.util.addClass(component.find('card-number-form-element'), 'slds-has-error');
                $A.util.removeClass(component.find('card-error-message'), 'noDisplay');
            } else {
                $A.util.removeClass(component.find('card-number-form-element'), 'slds-has-error');
                $A.util.addClass(component.find('card-error-message'), 'noDisplay');
            }
            
            if (cardType == 'amex' && ccnum.length >= cardLengthToCheck) {
                helper.validateCCNumber(component,ccnum);
            }else{
                $A.util.addClass(component.find('cardwarningmsg'), 'invalidCardInfo');
            }
        }
    },
    setCardIndicator: function (component, cardType) {
        var cardIndicator_Token = component.find('svgSpan-Token');
		var cardTypeName = this.getPayFormCardType(cardType);
        component.set("v.cardTypeName",cardTypeName);
        if (cardType) {
            $A.util.addClass(component.find('svgSpan-Token'), 'cardIcon');
            if (cardIndicator_Token) cardIndicator_Token.getElement().innerHTML = "<img class='slds-button__icon slds-button__icon--large slds-button__icon--right' src='/resource/1608129181000/ChargentBase__AppFrontier_Assets/svg/" + cardType + ".svg' alt='" + cardType + "' style='height: 2.6rem;position: static;width: 3rem;display: block;'/>";
        } else {
            if (cardIndicator_Token) cardIndicator_Token.getElement().innerHTML = "";
        }

    },
    checkCVVNumber: function(component,event,helper){
        helper.validateCVC(component);
    },
    handleCardNumberChange : function (component, event, helper) {
        //Set expiration date in Credit Card form with MM/YY format
        component.set('v.cardNumber', helper.cc_format(component.get('v.cardNumber')));
    },
    handleExpirationDateChange : function (component, event, helper) {
        //Set expiration date in Credit Card form with MM/YY format
        component.set('v.cardExpirationDate', helper.date_format(component.get('v.cardExpirationDate')));
    },

    handleSameAsContact: function(component, event, helper) {
        var profileDetail = component.get("v.profileDetail");
        component.set("v.billingAddress", profileDetail.address1);
        component.set("v.billingCity", profileDetail.city);
        component.set("v.billingState", profileDetail.state);
        component.set("v.billingZip", profileDetail.postalCode);
        component.set("v.billingCountry", profileDetail.country);
    }
})