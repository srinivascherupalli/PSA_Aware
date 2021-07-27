({
    getProducts: function(component, event, init) {

        console.log(sessionStorage.getItem('accountId'));
        component.set("v.accountId", sessionStorage.getItem('accountId'))
        console.log(component.get("v.frequency"))
        this.apexRequest(component, 'getMemberShipProductPackages', {
                frequency: component.get("v.frequency"),
                accountId: sessionStorage.getItem('accountId')
            })
            .then(function(response) {
                console.log('response ', JSON.stringify(response))
                component.set("v.actualAvailablePackages", JSON.parse(JSON.stringify(response)));
                var frequency = component.get("v.frequency");
                var availablePackages = []
                response.forEach(function(entry) {
                    console.log(entry);
                    if (frequency == 'quarterly') {
                        entry.listprice = (entry.listprice / 4).toFixed(2);
                        entry.netprice = (entry.netprice / 4).toFixed(2);
                    } else if (frequency == 'monthly') {
                        entry.listprice = (entry.listprice / 12).toFixed(2);
                        entry.netprice = (entry.netprice / 12).toFixed(2);
                    } else {
                        entry.listprice = (entry.listprice).toFixed(2);
                        entry.netprice = (entry.netprice).toFixed(2);
                    }

                    if (typeof entry.inclusions != 'undefined' && entry.inclusions != null) {
                        entry.inclusions = entry.inclusions.split("\r\n");
                    }
                    availablePackages.push(entry);
                });

                //Sorting the list to display the records in price increment order
                availablePackages.sort(function(a, b) {
                    return a.netprice - b.netprice
                });


                component.set("v.availablePackages", availablePackages);
                component.set("v.selectedPackage", {});
                component.set("v.selectedProductId", '');
                if (response.length > 0) {
                    /*f(init) {
                        component.set("v.selectedProductId", response[0].product.Id);
                        component.set("v.selectedPackage", response[0]);
                    }*/
                    var colsize = response.length;
                    component.set("v.colsize", parseInt(12 / colsize));
                }
            })
            .catch(this.withCallback(component, this.handleError));



    },

    handleError: function(component, errors) {
        console.log(errors);
        this.handleErrors(component, null, errors);
    },

    selectedProduct2: function(component, event, selectedList) {
        var that = this;
        component.set("v.isLoading", true);
        var navEvent = $A.get("e.c:PSA_NavigationEvent");
        navEvent.setParams({ screenName: 'screen3', "from": 'CMP' });
        component.set("v.navObj", navEvent);
        console.log('Called selectedProduct2');
        that.apexRequest(component, 'productSelection', {
                productName: component.get("v.productName"),
                accountId: component.get("v.accountId"),
                sessionId: component.get("v.sessionId")
            })
            .then(function(response) {
                window.setTimeout(
                    $A.getCallback(function() {
                        that.getQuoteId2(component, event);
                    }), 300
                );
            })
            .catch(function(e) {
                console.log('error ' + JSON.stringify(e));
                component.set("v.isLoading", false);
                component.set("v.isError", true);
            });
    },

    getQuoteId2: function(component, event) {
        var that = this;
        console.log('Called getQuoteId2');
        //component.set('v.quoteId', null);
        that.apexRequest(component, 'getQuoteId', {
                accountId: component.get("v.accountId"),
                sessionId: component.get("v.sessionId")
            })
            .then(function(response) {
                //var that = self;
                console.log('getQuoteIdresponse2 ', response)
                if (response != null) {
                    component.set("v.isLoading", false);
                    component.set('v.quoteId', response);
                    sessionStorage.setItem('quoteId', response);
                } else {
                    component.set("v.isLoading", true);
                    window.setTimeout(
                        $A.getCallback(function() {
                            that.getQuoteId2(component, event);
                        }), 1000
                    );
                }

            })
            .catch(function(e) {
                console.log('Unknown Error>>>>>>');
                component.set("v.isLoading", false);
                component.set("v.isError", true);
            });
    },

    createQuoteLines2: function(component, event) {
        var self = this;
        console.log('Called createQuoteLines2');

        var qid = component.get("v.quoteId");
        component.set("v.quoteLinesInProgress", true);
        component.set("v.isLoading", true);
        let selProds = [];
        let prodlist = component.get('v.selectedList');

        prodlist.forEach(function(elm, id) {
            if (elm.inclusions != null) {
                elm.inclusions = null;
            }
            selProds.push(elm);
        });
        self.apexRequest(component, 'createQuoteLines', {
                productsJSON: JSON.stringify(selProds),
                quoteId: qid,
                paymentFrequency: component.get("v.frequency")
            })
            .then(function(response) {
                var t = self;
                console.log('createQuoteLines ', response);
                component.set("v.isLoading", true);
                window.setTimeout(
                    $A.getCallback(function() {
                        t.getQuoteLinesCompleteionFlag2(component, event);
                    }), 300
                );
            })
            .catch(function(e) {
                console.log('error ' + JSON.stringify(e));
                component.set("v.isLoading", false);
                component.set("v.isError", true);
                component.set("v.quoteLinesInProgress", false);
            });
    },

    getQuoteLinesCompleteionFlag2: function(component, event) {
        var that = this;
        console.log('Called getQuoteLinesCompleteionFlag2');
        that.apexRequest(component, 'getQuoteLinesCompleteionFlag', {
                quoteId: component.get("v.quoteId")
            })
            .then(function(response) {
                console.log('getQuoteLinesCompleteionFlag2 Res ', response)
                var t = that;
                if (response) {
                    component.set("v.isLoading", false);
                    component.set("v.quoteLinesInProgress", false);
                    t.PageNavigation(component, event);
                } else {
                    component.set("v.isLoading", true);
                    console.log('getQuoteLinesCompleteionFlag2 polling');
                    var count = component.get("v.callCount");
                    window.setTimeout(
                        $A.getCallback(function() {
                            if (count <= 10) {
                                t.getQuoteLinesCompleteionFlag2(component, event);
                            } else {
                                component.set("v.isLoading", false);
                                component.set("v.isError", true);
                            }
                            component.set("v.callCount", count += 1);
                        }), 3000
                    );

                }

            })
            .catch(function(e) {
                console.log('error ' + JSON.stringify(e));
                component.set("v.isLoading", false);
                component.set("v.isError", true);
                component.set("v.quoteLinesInProgress", false);
            });
    },

    selectedProduct: function(component, event, selectedList) {
        var that = this;
        var navEvent = $A.get("e.c:PSA_NavigationEvent");
        var productName = component.get('v.productName');
        if (productName == 'Student') {
            navEvent.setParams({ screenName: 'screen3', "from": 'CMP' });
        } else {
            navEvent.setParams({ screenName: 'screen3', "from": 'CMP' });
        }
        component.set("v.navObj", navEvent)
        console.log(navEvent)
        console.log(component.get("v.sessionId"));
        this.apexRequest(component, 'productSelection', {
                productName: component.get("v.productName"),
                accountId: component.get("v.accountId"),
                sessionId: component.get("v.sessionId")
            })
            .then(function(response) {
                console.log('response1 ', response);
                component.set("v.isLoading", true);
                //that.getQuoteId(component, event);

                var t = that;
                window.setTimeout(
                    $A.getCallback(function() {
                        t.getQuoteId(component, event);
                    }), 1000
                );

            })
            .catch(function(e) {
                var selectedList = component.get('v.selectedList');
                // this.selectedProduct(component, event, selectedList);
                console.log('error ' + JSON.stringify(e));
                component.set("v.isLoading", false);
                component.set("v.isError", true);
                //helper.showToast('Warning!', 'error', 2000, 'Please try again later.');
            });
    },

    getPremiumBundle: function(component, event) {
        var that = this;
        this.apexRequest(component, 'getPremiumBundleProduct', {
                accountId: component.get("v.accountId"),
                sessionId: component.get("v.sessionId")
            })
            .then(function(response) {
                console.log('premium bundle: ', response);
                if (response) {
                    var t = that;
                    if (response != null) {
                        component.set("v.premiumBundle", JSON.parse(response));
                    } else {
                        console.log('No premium bundle found.');
                        component.set("v.isLoading", false);
                        component.set("v.isError", true);
                    }
                }
            })
            .catch(function(e) {
                console.log('error ' + JSON.stringify(e));
                component.set("v.isLoading", false);
                component.set("v.isError", true);

            });
    },

    createQuoteLines: function(component, event) {
        var that = this;
        this.apexRequest(component, 'createQuoteLines', {
                productsJSON: JSON.stringify(component.get('v.selectedList')),
                quoteId: component.get("v.quoteId"),
                paymentFrequency: component.get("v.frequency")
            })
            .then(function(response) {
                var t = that;
                console.log('createQuoteLines ', response)
                component.set("v.isLoading", true);
                window.setTimeout(
                    $A.getCallback(function() {
                        t.getQuoteLinesCompleteionFlag(component, event);
                    }), 1000
                );
                component.set("v.callCount", 0);
            })
            .catch(function(e) {
                console.log('error ' + JSON.stringify(e));
                component.set("v.isLoading", false);
                component.set("v.isError", true);
            });
    },

    getQuoteLinesCompleteionFlag: function(component, event) {
        var that = this;
        this.apexRequest(component, 'getQuoteLinesCompleteionFlag', {
                quoteId: component.get("v.quoteId")
            })
            .then(function(response) {
                console.log('getQuoteLinesCompleteionFlagRes ', response)
                if (response) {
                    var t = that;
                    component.set("v.isLoading", true);
                    var productName = component.get('v.productName');
                    if (productName == 'Student') {
                        window.setTimeout(
                            $A.getCallback(function() {
                                t.createOrder(component, event);
                            }), 1000
                        );
                    } else {
                        that.PageNavigation(component, event);
                    }
                    component.set("v.callCount", 0);

                } else {
                    component.set("v.isLoading", true);
                    console.log('getQuoteLinesCompleteionFlag fail');
                    var t = that;
                    var count = component.get("v.callCount");
                    window.setTimeout(
                        $A.getCallback(function() {
                            if (count <= 10) {
                                t.getQuoteLinesCompleteionFlag(component, event);
                            } else {
                                component.set("v.isLoading", false);
                                component.set("v.isError", true);
                            }
                            component.set("v.callCount", count += 1);
                        }), 3000
                    );

                }

            })
            .catch(function(e) {

                console.log('error ' + JSON.stringify(e));
                component.set("v.isLoading", false);
                component.set("v.isError", true);

            });
    },

    getQuoteId: function(component, event) {
        var that = this;
        this.apexRequest(component, 'getQuoteId', {
                accountId: component.get("v.accountId"),
                sessionId: component.get("v.sessionId")
            })
            .then(function(response) {
                console.log('getQuoteIdresponse2 ', response)
                if (response) {
                    var t = that;
                    console.log('getQuoteId ', response)
                    component.set('v.quoteId', response);
                    sessionStorage.setItem('quoteId', response);
                    component.set("v.isLoading", true);
                    window.setTimeout(
                        $A.getCallback(function() {
                            t.createQuoteLines(component, event);
                        }), 1000
                    );
                    component.set("v.callCount", 0);
                } else {
                    component.set("v.isLoading", true);
                    console.log('getQuoteId fail');
                    var t = that;
                    var count = component.get("v.callCount");
                    window.setTimeout(
                        $A.getCallback(function() {
                            if (count <= 10) {
                                t.getQuoteId(component, event);
                            } else {
                                component.set("v.isLoading", false);
                                component.set("v.isError", true);
                            }
                            component.set("v.callCount", count += 1);
                        }), 3000
                    );

                }

            })
            .catch(function(e) {

                console.log('error ' + JSON.stringify(e));
                component.set("v.isLoading", false);
                component.set("v.isError", true);

            });
    },

    createOrder: function(component, event) {
        var that = this;
        this.apexRequest(component, 'createOrder', {
                quoteId: component.get("v.quoteId")
            })
            .then(function(response) {
                if (response) {
                    console.log('response3 ', response);
                } else {
                    console.log('create order')
                }
                component.set("v.isLoading", true);
                var t = that;
                window.setTimeout(
                    $A.getCallback(function() {
                        t.getOrderId(component, event);
                    }), 1000
                );

            }).catch(function(e) {
                console.log('error ' + JSON.stringify(e));
                component.set("v.isLoading", false);
                component.set("v.isError", true);

            });

    },

    getOrderId: function(component, event) {
        var that = this;
        this.apexRequest(component, 'getOrderId', {
                quoteId: component.get("v.quoteId")
            })
            .then(function(response) {
                console.log('getOrderIdResponse2 ', response)
                if (response) {
                    console.log('getOrderId ', response)
                    component.set('v.orderId', response);
                    var t = that;
                    component.set("v.isLoading", true);
                    window.setTimeout(
                        $A.getCallback(function() {
                            t.getInvoiceId(component, event);
                        }), 1000
                    );
                    component.set("v.callCount", 0);
                } else {
                    component.set("v.isLoading", true);
                    console.log('getOrderId fail');
                    var t = that;
                    var count = component.get("v.callCount");
                    window.setTimeout(
                        $A.getCallback(function() {
                            if (count <= 10) {
                                t.getOrderId(component, event);
                            } else {
                                component.set("v.isLoading", false);
                                component.set("v.isError", true);
                            }
                            component.set("v.callCount", count += 1);
                        }), 3000
                    );
                    //that.getOrderId(component, event);

                }

            })
            .catch(function(e) {

                console.log('error ' + JSON.stringify(e));
                component.set("v.isLoading", false);
                component.set("v.isError", true);

            });
    },

    getInvoiceId: function(component, event) {
        var that = this;
        var isAutoRenew = component.get("v.isAutoRenew");
        // isAutoRenew=isAutoRenew.toString();
        sessionStorage.setItem("sessionId", component.get("v.sessionId"));
        var productName = component.get('v.productName');
        this.apexRequest(component, 'getInvoiceId', {
                orderId: component.get('v.orderId'),
                optOutforRenewal: isAutoRenew,
                isStudentPackage: productName == 'Student' ? true : false,
                sessionId: component.get("v.sessionId")
            })
            .then(function(response) {
                console.log('getInvoiceIdRes ', response)
                if (response) {
                    var t = that;
                    console.log('invoiceId ', response)
                    component.set('v.invoiceId', response);
                    sessionStorage.setItem("invoiceId", response);
                    component.set("v.callCount", 0);
                    that.PageNavigation(component, event);

                } else {
                    component.set("v.isLoading", true);
                    console.log('invoiceId fail');
                    var t = that;
                    var count = component.get("v.callCount");
                    window.setTimeout(
                        $A.getCallback(function() {
                            if (count <= 10) {
                                t.getInvoiceId(component, event);
                            } else {
                                component.set("v.isLoading", false);
                                component.set("v.isError", true);
                            }
                            component.set("v.callCount", count += 1);
                        }), 3000
                    );

                }

            })
            .catch(function(e) {
                console.log('error ' + JSON.stringify(e));
                component.set("v.isLoading", false);
                component.set("v.isError", true);
            });

    },

    PageNavigation: function(component, event) {

        scrollTo({ top: 0, behavior: 'smooth' });
        var navEvent = component.get("v.navObj")
        navEvent.fire();

    }


})