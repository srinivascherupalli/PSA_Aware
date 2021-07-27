({
    doInit : function(component, event, helper) {
        var frequency=component.get("v.frequency");
        if(frequency=='annual'){
            frequency='annually';
        }

        var membership = component.get("v.userMemberhip");
        if(frequency==null){
            component.set("v.frequency",membership.SBQQ__BillingFrequency__c);
        }

        component.set("v.freq",frequency);
        component.set("v.sessionId", 'sess'+Math.floor(10000000 + Math.random() * 90000000));
        sessionStorage.setItem("sessionId", component.get("v.sessionId"));
        console.log(component.get("v.selectedPackage"));
        
        var userprofile = component.get("v.profileDetail");
        if(userprofile!=null){
            var selectedList = component.get("v.selectedPackage");
            var premconf = JSON.parse(helper.INSURANCECONFIG);
            var freq = component.get("v.frequency");
            component.set("v.premiumBundleList",null);
            if(userprofile.country!="Australia"){
                helper.selectedProduct(component, event);
            }
            else{
                var userstate = userprofile.state;
                var selprod = (membership!=null)?membership.productcode__c:selectedList.product.ProductCode;

                var studentpackcodes = premconf.product.pcode;

                studentpackcodes.forEach(function(p,pi){
                    if(selprod.toUpperCase() == p.toUpperCase()){
                        var sfreq = premconf.product.frequency;
                        sfreq.forEach(function(f,fi){
                            let f2 = f.freq;
                            if(freq.toUpperCase() == f2.toUpperCase()){
                                component.set("v.premiumBundleList",f.insproducts);
                            }
                        });
                    }
                });
                let bl = component.get("v.premiumBundleList");
                if(bl == null){
                    var stateArr = premconf.state;
                    stateArr.forEach(function(st,stidx){
                        bl = component.get("v.premiumBundleList");
                        var stArr = st.name;
                        stArr.forEach(function(s,si){
                            if(userstate.toUpperCase() == s.toUpperCase()){
                                var pcodeArr = st.config.product.pcode;
                                var pcodeFreqObj = st.config.product.frequency;
                                pcodeArr.forEach(function(pc,pci){
                                    if(selprod.toUpperCase() == pc.toUpperCase()){
                                        pcodeFreqObj.forEach(function(fr,frid){
                                            let f3 = fr.freq;
                                            if(freq.toUpperCase() == f3.toUpperCase()){
                                                component.set("v.premiumBundleList",fr.insproducts);
                                            }
                                        });
                                    }
                                });
                            }
                        });
                    });
                }
            }
        }

        if(component.get("v.quoteId")!=null){
            helper.getQuoteDetails(component, event);
        }
        //component.set('v.productName', selectedList.product.Name);
    },

    onContinue : function(component, event, helper){

        helper.selectedProduct(component, event);
/*        var navEvent = $A.get("e.c:PSA_NavigationEvent");

       var productName=component.get('v.productName');
       if(productName=='Student'){
           navEvent.setParams({ screenName: 'screen5', "from" : 'CMP' });
       }else{
           navEvent.setParams({ screenName: 'screen4', "from" : 'CMP' });
       }
       component.set("v.navObj",navEvent)
       scrollTo({ top: 0, behavior: 'smooth' });
       var navEvent=component.get("v.navObj")
       navEvent.fire(); */


    },

    signMeUp: function(component, event, helper){
        component.set('v.isSignUp', true);
    },

    cancel: function(component, event, helper){
        component.set('v.isSignUp', false);
    },

    psaCodechanged: function(component, event) {
        component.set("v.chkPSADetails", document.getElementById("psa-checkbox-1").checked );
        console.log(component.get("v.chkPSADetails") ); 
    },

    dateChange: function(component, event, helper) {
        var sDate=component.get("v.startDate");

        if(Date.parse(sDate)){
            var frequency=component.get("v.frequency");
            var dt = new Date(sDate);
            if(frequency=='monthly'){
                dt.setMonth( dt.getMonth() + 1 );
            }else if(frequency=='quarterly'){
                dt.setMonth( dt.getMonth() + 3 );
            }else{
                dt.setMonth( dt.getMonth() + 12 );
            }
            component.set("v.isValidDate",true);
        }else{
            component.set("v.isValidDate",false);
        }

        if(component.get("v.mode")=="amendment"){
            var contractId = component.get("v.contractId");
            if(contractId!=null){
                helper.createAmendment(component,event);
            }
        }
        //Get the insurance premium bundle details
        helper.getPremiumPricing(component, event);
        //component.set("v.premium",'');

    },

    handleBackButton: function(component, event) {
        var navEvent = $A.get("e.c:PSA_NavigationEvent");
        navEvent.setParams({ screenName: 'screen2', "from" : 'CMP' });
        navEvent.fire();
    }
})