({
    doInit: function(component, event, helper) {
        var selectedPackage = component.get("v.selectedPackage");
        if (!$A.util.isEmpty(selectedPackage) && selectedPackage.product) {
            component.set("v.selectedProductId", selectedPackage.product.Id);
        }
        component.set("v.sessionId", 'sess' + Math.floor(10000000 + Math.random() * 90000000));
        console.log(component.get("v.sessionId"));
        sessionStorage.setItem("sessionId", component.get("v.sessionId"));
        var frequency = component.get("v.frequency");
        sessionStorage.setItem("frequency", frequency);
        sessionStorage.setItem("isAutoRenew", component.get("v.isAutoRenew"));
        helper.getProducts(component, event, $A.util.isEmpty(selectedPackage));
        component.set("v.displayfrequency", component.get("v.frequency"));
    },

    handleFrequencyChange: function(component, event, helper) {
        component.set("v.selectedPackage", {});
        helper.getProducts(component, event, true);
        var frequency = component.get("v.frequency");
        var displayfrequency = frequency;
        if (frequency == "annual") {
            displayfrequency = "annually";
        }
        component.set("v.displayfrequency", displayfrequency);
        sessionStorage.setItem("frequency", frequency);
    },

    handleButtonClick: function(component, event, helper) {

        component.set("v.isError", false);

        var screenName = event && event.getParam ? event.getParam("screenName") : undefined;
        screenName = screenName ? screenName : 'screen3';
        var fromCMP = event && event.getParam ? event.getParam('from') : undefined;
        if (fromCMP && fromCMP == 'CMP' || screenName == 'screen4') return;

        if (screenName != 'screen1') {
            // Trigger event to handle screen validation
            if ($A.util.isEmpty(component.get("v.selectedProductId"))) {
                helper.showToast('Warning!', 'error', 2000, 'Please select your membership package.');
                return;
            } else if (!component.get("v.chkTerms") || !component.get("v.chkPSACoding")) {
                helper.showToast('Warning!', 'error', 2000, 'Please read and accept terms & conditions.');
                return;
            } else if (!component.get("v.isAutoRenew") && (component.get("v.frequency") == 'monthly' || component.get("v.frequency") == 'quarterly')) {
                helper.showToast('Warning!', 'error', 2000, 'Monthly and Quarterly payments require agreement to auto-renewal. If you would like to receive a request to renew your membership in the future, please select the Annual payment option.');
                return;
            } else {
                var availablePackages = component.get("v.actualAvailablePackages");
                var selectedProductId = component.get("v.selectedProductId");

                var selectedList = [];

                availablePackages.forEach(function(pkg) {
                    if (pkg.product.Id === selectedProductId) {
                        selectedList.push(pkg);

                    }
                });

                /* var premiumBundle = component.get("v.premiumBundle");
                if(selectedList.length>0 && premiumBundle !=null){
                    premiumBundle.forEach(function(itm,idx){
                       selectedList.push(itm);
                    });
                    //selectedList.push(premiumBundle);
                } */

                var selectedList = JSON.parse(JSON.stringify(selectedList));
                component.set('v.selectedList', selectedList);
                component.set('v.productName', selectedList[0].product.Name);

                /* scrollTo({ top: 0, behavior: 'smooth' });
                var navEvent = $A.get("e.c:PSA_NavigationEvent");
                navEvent.setParams({ screenName, "from" : 'CMP' });
                navEvent.fire(); */
                //helper.selectedProduct(component, event, selectedList);

                helper.selectedProduct2(component, event, selectedList);

            }
        } else {

            scrollTo({ top: 0, behavior: 'smooth' });
            var navEvent = $A.get("e.c:PSA_NavigationEvent");
            navEvent.setParams({ screenName, "from": 'CMP' });
            navEvent.fire();
        }
    },

    handleQuoteId: function(component, event, helper) {
        var qid = component.get('v.quoteId');
        var check = component.get("v.quoteLinesInProgress");
        if (qid != null && !check) {
            helper.createQuoteLines2(component, event);
        }
    },

    handleBackButton: function(component, event) {
        var navEvent = $A.get("e.c:PSA_NavigationEvent");
        navEvent.setParams({ screenName: 'screen1', "from": 'CMP' });
        navEvent.fire();
    },

    handleSelectPackage: function(component, event, helper) {
        var indx = event.target.name;
        var availablePackages = component.get("v.availablePackages");
        if (typeof parseInt(indx) == 'number') {
            component.set("v.selectedPackage", availablePackages[parseInt(indx)]);
            component.set("v.selectedProductId", availablePackages[parseInt(indx)].product.Id);
            component.set('v.productName', availablePackages[parseInt(indx)].product.Name);
            helper.getPremiumBundle(component, event);
        }

    },

    termchanged: function(component, event) {
        component.set("v.chkTerms", document.getElementById("psa-checkbox-1").checked);
        console.log(component.get("v.chkTerms"));
    },

    psaCodechanged: function(component, event) {
        component.set("v.chkPSACoding", document.getElementById("psa-checkbox-2").checked);
        console.log(component.get("v.chkPSACoding"));
    },
    psaAutoRenewchanged: function(component, event) {
        component.set("v.isAutoRenew", document.getElementById("psa-checkbox-3").checked);
        sessionStorage.setItem("isAutoRenew", component.get("v.isAutoRenew"));
        console.log(component.get("v.isAutoRenew"));
    },
})