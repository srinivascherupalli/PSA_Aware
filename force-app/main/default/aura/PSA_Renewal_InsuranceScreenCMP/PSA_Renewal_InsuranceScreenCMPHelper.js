({
    INSURANCECONFIG : '{"product":{"pcode":["MEMSTU","MEMGRD"],"frequency":[{"freq":"Annual","insproducts":["INS - PRE Annual - Student & Grad","INS - GST Annual - Student & Grad","INS - STAD Annual - Student & Grad","INS - ADF Annual - Student & Grad","INS - ADFGST Annual - Student & Grad"]},{"freq":"Quarterly","insproducts":["INS - PRE Quarterly - Student & Grad","INS - GST Quarterly - Student & Grad","INS - STAD Quarterly - Student & Grad","INS - ADF Quarterly - Student & Grad","INS - ADFGST Quarterly - Student & Grad"]},{"freq":"Monthly","insproducts":["INS - PRE Monthly - Student & Grad","INS - GST Monthly - Student & Grad","INS - STAD Monthly - Student & Grad","INS - ADF Monthly - Student & Grad","INS - ADFGST Monthly - Student & Grad"]}]},"state":[{"name":["SA"],"config":{"product":{"pcode":["MEMESS","MEMADV","MEMPRO"],"frequency":[{"freq":"Annual","insproducts":["INS - PRE Annual - NonStudent","INS - GST Annual - NonStudent","INS - STAD Annual - NonStudent | SA","INS - ADF Annual - NonStudent","INS - ADFGST Annual - NonStudent"]},{"freq":"Quarterly","insproducts":["INS - PRE Quarterly NonStudent","INS - GST Quarterly - NonStudent","INS - STAD Quarterly - NonStudent | SA","INS - ADF Quarterly NonStudent","INS - ADFGST Quarterly NonStudent"]},{"freq":"Monthly","insproducts":["INS - PRE Monthly NonStudent","INS - GST Monthly - NonStudent","INS - STAD Monthly - NonStudent | SA","INS - ADF Monthly NonStudent","INS - ADFGST Monthly NonStudent"]}]}}},{"name":["ACT"],"config":{"product":{"pcode":["MEMESS","MEMADV","MEMPRO"],"frequency":[{"freq":"Annual","insproducts":["INS - PRE Annual - NonStudent","INS - GST Annual - NonStudent","INS - STAD Annual - NonStudent | ACT","INS - ADF Annual - NonStudent","INS - ADFGST Annual - NonStudent"]},{"freq":"Quarterly","insproducts":["INS - PRE Quarterly NonStudent","INS - GST Quarterly - NonStudent","INS - STAD Quarterly - NonStudent | ACT","INS - ADF Quarterly NonStudent","INS - ADFGST Quarterly NonStudent"]},{"freq":"Monthly","insproducts":["INS - PRE Monthly NonStudent","INS - GST Monthly - NonStudent","INS - STAD Monthly - NonStudent | ACT","INS - ADF Monthly NonStudent","INS - ADFGST Monthly NonStudent"]}]}}},{"name":["NSW","QLD"],"config":{"product":{"pcode":["MEMESS","MEMADV","MEMPRO"],"frequency":[{"freq":"Annual","insproducts":["INS - PRE Annual - NonStudent","INS - GST Annual - NonStudent","INS - STAD Annual - NonStudent | NSW & QLD","INS - ADF Annual - NonStudent","INS - ADFGST Annual - NonStudent"]},{"freq":"Quarterly","insproducts":["INS - PRE Quarterly NonStudent","INS - GST Quarterly - NonStudent","INS - STAD Quarterly - NonStudent | NSW & QLD","INS - ADF Quarterly NonStudent","INS - ADFGST Quarterly NonStudent"]},{"freq":"Monthly","insproducts":["INS - PRE Monthly NonStudent","INS - GST Monthly - NonStudent","INS - STAD Monthly - NonStudent | NSW & QLD","INS - ADF Monthly NonStudent","INS - ADFGST Monthly NonStudent"]}]}}},{"name":["NT","TAS","VIC","WA"],"config":{"product":{"pcode":["MEMESS","MEMADV","MEMPRO"],"frequency":[{"freq":"Annual","insproducts":["INS - PRE Annual - NonStudent","INS - GST Annual - NonStudent","INS - STAD Annual - NonStudent | NT, TAS, VIC & WA","INS - ADF Annual - NonStudent","INS - ADFGST Annual - NonStudent"]},{"freq":"Quarterly","insproducts":["INS - PRE Quarterly NonStudent","INS - GST Quarterly - NonStudent","INS - STAD Quarterly - NonStudent | NT, TAS, VIC & WA","INS - ADF Quarterly NonStudent","INS - ADFGST Quarterly NonStudent"]},{"freq":"Monthly","insproducts":["INS - PRE Monthly NonStudent","INS - GST Monthly - NonStudent","INS - STAD Monthly - NonStudent | NT, TAS, VIC & WA","INS - ADF Monthly NonStudent","INS - ADFGST Monthly NonStudent"]}]}}}]}',

    selectedProduct: function(component, event) {
        var that=this;
        var navEvent = $A.get("e.c:PSA_NavigationEvent");

        var productName=component.get('v.productName');
        if(productName=='Student'){
            navEvent.setParams({ screenName: 'screen3', "from" : 'CMP' });
        }else{
            navEvent.setParams({ screenName: 'screen2', "from" : 'CMP' });
        }
        component.set("v.navObj",navEvent)

        var sDate=component.get("v.startDate");

        that.apexRequest(component, 'addPremiumInsurance' , {
            startDate: sDate,
            quoteId: component.get("v.quoteId"),
            paymentFrequency: component.get("v.frequency"),
            parentOnly: true
        })
        .then(function(response){
            var t=that;
            console.log('addPremiumInsurance ', response)
            component.set("v.isLoading",true);
            window.setTimeout(
                $A.getCallback(function() {
                    t.getPremiumParentCompleteionFlag(component, event);
                }),1000
            );
            component.set("v.callCount",0);
        })
        .catch(function(e){
            console.log('error '+ JSON.stringify(e));
            component.set("v.isLoading",false);
            component.set("v.isError", true);
        });

    },

    getQuoteDetails: function(component, event) {
        var that=this;

        this.apexRequest(component, 'getQuoteDetailsById' , {
            quoteId: component.get("v.quoteId")
        })
        .then(function(response){
            console.log('getQuoteDetails ', response)
            if(response!=null){
                var t=that;
                component.set("v.isLoading",true);
                component.set("v.callCount",0);
                
            }else{
                component.set("v.isLoading",true);
                console.log('getQuoteDetails polling');
                var t=that;
                var count=component.get("v.callCount");
                window.setTimeout(
                    $A.getCallback(function() {
                        if(count<=10){
                            t.getQuoteDetails(component, event);
                        }else{
                            component.set("v.isLoading",false);
                            component.set("v.isError", true);
                        }
                        component.set("v.callCount",count+=1);
                    }), 3000
                );

            }

        })
        .catch(function(e){

            console.log('error '+ JSON.stringify(e));
            component.set("v.isLoading",false);
            component.set("v.isError", true);

        });
    },

    getPremiumPricing: function(component, event) {
        var that=this;
        let bundlelist = component.get("v.premiumBundleList");
        var input = new Array();
        bundlelist.forEach(function(item){
            input.push(item);
        });
        this.apexRequest(component, 'getPremiumListPrice' , {
            productNames: input
        })
        .then(function(response){
            console.log('premium product: ', response)
            if(response!=null){
                var resObj = JSON.parse(response);
                let totalcost = 0.00;
                resObj.forEach(function(item){
                    let listprice = item.ListPrice__c;
                    let pcode = item.productcode__c;

                    if(pcode == "INS - PRE"){
                        component.set("v.premium",listprice);
                    }
                    else if(pcode == "INS - GST"){
                        component.set("v.premiumGst",listprice);
                    }
                    else if(pcode == "INS - STAD"){
                        component.set("v.stampDuty",listprice);
                    }
                    else if(pcode == "INS - ADF"){
                        component.set("v.adminFee",listprice);
                    }
                    else if(pcode == "INS - ADFGST"){
                        component.set("v.adminFeeGst",listprice);
                    }
                    totalcost += listprice;
                });

                component.set("v.totalCost",totalcost);
            }

        })
        .catch(function(e){
            console.log('error '+ JSON.stringify(e));
            component.set("v.isLoading",false);
            component.set("v.isError", true);

        });
    },
    
    getPremiumProduct: function(component, event) {
        var that=this;
        this.apexRequest(component, 'getPremiumProduct' , {
            accountId: component.get("v.accountId"),
            sessionId: component.get("v.sessionId")
        })
        .then(function(response){
            console.log('premium product: ', response)
            if(response){
                var t=that;
                component.set("v.premium",response);
            }

        })
        .catch(function(e){

            console.log('error '+ JSON.stringify(e));
            component.set("v.isLoading",false);
            component.set("v.isError", true);

        });
    },

    getPremiumParentCompleteionFlag: function(component, event) {
        var that=this;

        this.apexRequest(component, 'getQuoteLinesPremiumParent' , {
            quoteId: component.get("v.quoteId")
        })
        .then(function(response){
            console.log('getPremiumParentCompleteionFlag ', response)
            if(response!=null){
                var t=that;
                component.set("v.isLoading",true);
                component.set("v.callCount",0);
                window.setTimeout(
                    $A.getCallback(function() {
                        t.updatePremiumOptions(component, event, response);
                    }), 300
                );
            }else{
                component.set("v.isLoading",true);
                console.log('getPremiumParentCompleteionFlag polling');
                var t=that;
                var count=component.get("v.callCount");
                window.setTimeout(
                    $A.getCallback(function() {
                        if(count<=10){
                            t.getPremiumParentCompleteionFlag(component, event);
                        }else{
                            component.set("v.isLoading",false);
                            component.set("v.isError", true);
                        }
                        component.set("v.callCount",count+=1);
                    }), 3000
                );

            }

        })
        .catch(function(e){

            console.log('error '+ JSON.stringify(e));
            component.set("v.isLoading",false);
            component.set("v.isError", true);

        });
    },

    updatePremiumOptions: function(component, event, parentid) {
        var that=this;

        var sDate=component.get("v.startDate");

        this.apexRequest(component, 'createPremiumQLIOptions' , {
            startDate: sDate,
            quoteId: component.get("v.quoteId"),
            parentId: parentid
        })
        .then(function(response){
            var t=that;
            console.log('updatePremiumOptions ', response);

            component.set("v.isLoading",true);
            var resultStr = response;
            component.set("v.prodJSON", resultStr);
            component.set("v.callCount",0);
            window.setTimeout(
                $A.getCallback(function() {
                    t.checkPremiumQLIOptions(component,event,resultStr);
                }), 1000
            );
        })
        .catch(function(e){
            console.log('error '+ JSON.stringify(e));
            component.set("v.isLoading",false);
            component.set("v.isError", true);
        });

    },

    checkPremiumQLIOptions: function(component, event, prodJSON) {
        var that=this;
        var prodJSONVal=component.get("v.prodJSON");
        console.log('prodJSONVal ', prodJSONVal);

        this.apexRequest(component, 'getPremiumQliOptionStatus' , {
            quoteId: component.get("v.quoteId"),
            optionsStr: prodJSONVal
        })
        .then(function(response){
            console.log('checkPremiumQLIOptions ', response)
            if(response>0){
                var t=that;
                component.set("v.isLoading",true);
                component.set("v.callCount",0);
                t.PageNavigation(component, event);
            }else{
                component.set("v.isLoading",true);
                console.log('checkPremiumQLIOptions polling');
                var t=that;
                var count=component.get("v.callCount");
                window.setTimeout(
                    $A.getCallback(function() {
                        if(count<=20){
                            t.checkPremiumQLIOptions(component, event);
                        }else{
                            component.set("v.isLoading",false);
                            component.set("v.isError", true);
                        }
                        component.set("v.callCount",count+=1);
                    }), 3000
                );

            }

        })
        .catch(function(e){

            console.log('error '+ JSON.stringify(e));
            component.set("v.isLoading",false);
            component.set("v.isError", true);

        });
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
            component.set("v.isError", true);

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
                            component.set("v.isError", true);
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
            component.set("v.isError", true);

        });
    },

    getInvoiceId: function(component, event) {
        var that=this;
        var isAutoRenew=component.get("v.isAutoRenew");
       // isAutoRenew=isAutoRenew.toString();
        sessionStorage.setItem("sessionId", component.get("v.sessionId"));
        var productName=component.get('v.productName');
        this.apexRequest(component, 'getInvoiceId' , {
            orderId:  component.get('v.orderId'),
            optOutforRenewal: isAutoRenew,
            isStudentPackage: productName=='Student'? true:false,
            sessionId: component.get("v.sessionId")
        })
        .then(function(response){
            console.log('getInvoiceIdRes ', response)
            if(response){
                var t=that;
                console.log('invoiceId ', response)
                component.set('v.invoiceId',response);
                sessionStorage.setItem("invoiceId", response);
                component.set("v.isLoading",false);
                component.set("v.callCount",0);
                that.PageNavigation(component, event);
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
                            component.set("v.isError", true);
                        }
                        component.set("v.callCount",count+=1);
                    }), 3000
                );

            }

        })
        .catch(function(e){
            console.log('error '+ JSON.stringify(e));
            component.set("v.isLoading",false);
            component.set("v.isError", true);
        });

    },

    deletePremiumInsuranceOnDateChange: function(component, event) {
        var that=this;
        this.apexRequest(component, 'deletePremiumInsurance' , {
            quoteId: component.get("v.quoteId")
        })
        .then(function(response){
            if(response){
                var t=that;
                component.set("v.isLoading",false);
            }else{
                component.set("v.isLoading",false);
                component.set("v.isError", true);
            }


        })
        .catch(function(e){
            console.log('error '+ JSON.stringify(e));
            component.set("v.isLoading",false);
            component.set("v.isError", true);
        });

    },

    deletePremiumInsurance: function(component, event) {
        var that=this;
        this.apexRequest(component, 'deletePremiumInsurance' , {
            quoteId: component.get("v.quoteId")
        })
        .then(function(response){
            if(response){
                var t=that;
                component.set("v.isLoading",false);
                        that.PageNavigation(component, event);
            }else{
                component.set("v.isLoading",false);
                component.set("v.isError", true);
            }


        })
        .catch(function(e){
            console.log('error '+ JSON.stringify(e));
            component.set("v.isLoading",false);
            component.set("v.isError", true);
        });

    },

    getStartDate: function(component, event) {
        var that=this;
        this.apexRequest(component, 'getPremiumInsuranceStartDate' , {
            quoteId: component.get("v.quoteId")
        })
        .then(function(response){
            if(response){
                var t=that;
                debugger;
                console.log('StartDate '+ response);
                component.set("v.isLoading",false);
                component.set("v.startDate",response);
                component.set("v.isStartDateAvailable",true);
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
                  
                    component.set("v.renewalDate", dt);
                    
                    component.set("v.isValidDate",true);
                }else{
                    component.set("v.isValidDate",false);
                }
                window.setTimeout(
                    $A.getCallback(function() {
                        t.getPremiumPricing(component, event);
                    }), 1000
                );
                
            }else{
                component.set("v.isStartDateAvailable",false);
                component.set("v.startDate",'');
                component.set("v.isLoading",false);
                component.set("v.isValidDate",false);
               // component.set("v.isError", true);
            }


        })
        .catch(function(e){
            console.log('error '+ JSON.stringify(e));
            component.set("v.isLoading",false);
            component.set("v.isError", true);
        });
    },

    PageNavigation: function(component, event) {

        scrollTo({ top: 0, behavior: 'smooth' });
        var navEvent=component.get("v.navObj")
        navEvent.fire();

    }

})