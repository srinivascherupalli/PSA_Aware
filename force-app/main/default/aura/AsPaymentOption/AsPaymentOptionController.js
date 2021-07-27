({
    doInit : function(component, event, helper) {
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
        component.set("v.showSpinner", true);
        helper.getRecrods( component , function( res  ){

            console.log( res );  
            component.set('v.learningPackageName',res['learningPackageName']);    
            component.set('v.productIdVcode',res['prodIdFOrVcode']);    
            component.set( 'v.priceBooksList' , res['priceBookRecordList'] );
            var resPBE = res['priceBookRecordList'];
            var resUnitPrice = resPBE.unitPrice;
            //iver
            // if (res['oppAmount'] != null) {
            //     component.set( 'v.oppAmount' , res['oppAmount'] );
            //     console.log( 'oppAmount is '+res['oppAmount'] );
            // } else {
            //     component.set( 'v.oppAmount' , resUnitPrice );
            // }
            
            component.set( 'v.enrolmentStatus' , res['enrolmentStatus'] );
            component.set( 'v.fundedPosition' , res['fundedPosition'] );
            component.set( 'v.fundEligible' , res['fundEligible'] );
            component.set( 'v.oppId' , res['oppId'] );
            console.log('OppId ' + res['oppId'] + '\nAmount: '+ res['oppInfoAmount']);
            

             //iver - check if opp id, then return value undergoes with certain conditions
             if ( res['oppId'] != null ) { 
                //set enrolment status as pending
                var pricebookList = res['priceBookRecordList'];
                helper.unitPrice = res['oppAmount'];
                console.log('Amount if not null: '+helper.unitPrice);
                
                if ( res['fundedPosition'] ) {
                    console.log('Oppid is: '+res['oppId']+'\nRedirect is true because funded position: '+res['fundedPosition']);
                    helper.updateEnrolToPending( component, function ( getRet) {
                        if (getRet == "Enrolment updated!") {
                            var cmpEvent = component.getEvent("Enrolment_Event");
                            var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
                            cmpEvent.setParams({
                            enrolmentStep : "step14"});
                            cmpEvent.fire();
                        }
                    });
                    
                } else if ( res['fundEligible'] ) {
                    console.log('Oppid is: '+res['oppId']+'\nRedirect is true because funded eligible: '+res['fundEligible']);
                    helper.updateEnrolToPending( component, function ( getRet) {
                        if (getRet == "Enrolment updated!") {
                            var cmpEvent = component.getEvent("Enrolment_Event");
                            var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
                            cmpEvent.setParams({
                            enrolmentStep : "step14"});
                            cmpEvent.fire();
                        }
                    });
                } else if ( helper.unitPrice == 0 ) {
                    helper.updateEnrolToPendingpayment( component, function ( getRet) {
                        if (getRet == "Enrolment updated!") {
                            var cmpEvent = component.getEvent("Enrolment_Event");
                            var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
                            cmpEvent.setParams({
                            enrolmentStep : "step14"});
                            cmpEvent.fire();
                        }
                    });
                } else {
                    //component.set("v.showSpinner", false);
                    component.set("v.showSpinner", false);
                    component.set( 'v.oppId' , res['oppId'] );
                    helper.createdOppId = res['oppId'];
                    console.log('OppId is '+helper.createdOppId+' but both funded position and eligible is false');

                    //hide multiple and show single
                    component.set("v.showMultipleOptions", false);
                    var OppAmnt = component.set( 'v.oppAmount' , res['oppAmount'] );
                    //getOppInfo
                    var unitPriceFormat = helper.currencyFormat(parseFloat( res['oppInfoAmount'] ));
                    component.set( 'v.oppInfoAmount' , unitPriceFormat );
                    component.set( 'v.oppInfopBook2Id' , res['oppInfopBook2Id'] );
                    component.set( 'v.oppInfopBook2IdName' , res['oppInfopBook2IdName'] );
                    var getBNameEntry = component.get( 'v.oppInfopBook2IdName' );

                    if ( res['oppInfopBook2IdName'] != 'One-off payment') {
                        component.set( 'v.setVoucherDisable' , true );
                        console.log('voucher code disabled.Available for one-off payment only');
                    } else {
                        component.set( 'v.setVoucherDisable' , false );
                        console.log('Enter voucher code for One-off payment');
                    }

                    console.log('Unit price: '+unitPriceFormat);
                }

            } else {
                component.set("v.showSpinner", true);

                if ( res['fundedPosition'] ) {
                    console.log('Oppid is: null\nRedirect is true because funded position: '+res['fundedPosition']);
                    helper.updateEnrolToPendingAndCreateOpp( component, function ( getRet) {
                        if (getRet == "Updated Successfully") {
                            var cmpEvent = component.getEvent("Enrolment_Event");
                            var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
                            cmpEvent.setParams({
                            enrolmentStep : "step14"});
                            cmpEvent.fire();
                        }
                    });
                    
                } else if ( res['fundEligible'] ) {
                    console.log('Oppid is: null\nRedirect is true because funded eligible: '+res['fundEligible']);
                    helper.updateEnrolToPendingAndCreateOpp( component, function ( getRet) {
                        if (getRet == "Updated Successfully") {
                            var cmpEvent = component.getEvent("Enrolment_Event");
                            var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
                            cmpEvent.setParams({
                            enrolmentStep : "step14"});
                            cmpEvent.fire();
                        }
                    });
                } else {

                    component.set("v.showSpinner", false);
                    var pricebookList = res['priceBookRecordList'];
                    var getEnrStat = component.get('v.enrolmentStatus');
                    console.log('status '+ getEnrStat);
                    // if( getEnrStat == 'Draft'){ 
                    //     component.set( 'v.setDisableInput' , false ); 
                    // } else if( getEnrStat == 'Pending Payment'){ 
                    //     component.set( 'v.setDisableInput' , false ); 
                    // } else {
                    //     component.set( 'v.setDisableInput' , true );
                    // }

                        for( var i = 0 ; i < pricebookList.length ; i++ ){
                            var res = pricebookList[i];
                            if( res.isOnceOff  ){
                                var unitPriceCurrencyFormat = helper.currencyFormat(parseFloat( res.unitPrice ));
                                var priceBookName = res.priceBookName;
                                //iver
                                helper.selectedPriceBookId = res.priceBookId;
                                helper.unitPrice = res.unitPrice;
                                helper.priceBookName = res.priceBookName;

                                console.log('helper pbID: '+ helper.selectedPriceBookId);
                                console.log('helper unitPrice: '+ helper.unitPrice);
                                console.log('helper pbName: '+ helper.priceBookName);

                                component.set( 'v.unitPriceSlect' , unitPriceCurrencyFormat ); 
                                var getEnrStat = component.get('v.enrolmentStatus');
                                console.log('status '+ getEnrStat);
                                if( getEnrStat == 'Draft'){ 

                                    if( priceBookName == 'One-off payment'   ){
                                        component.set( 'v.setVoucherDisable' , false );
                                    } else {
                                        component.set( 'v.setVoucherDisable' , true );
                                    }
                                    
                                } else if( getEnrStat == 'Pending Payment'){ 

                                    if( priceBookName == 'One-off payment'   ){
                                        component.set( 'v.setVoucherDisable' , false );
                                    } else {
                                        component.set( 'v.setVoucherDisable' , true );
                                    }

                                } else {
                                    component.set( 'v.setDisableInput' , true );
                                    component.set( 'v.setVoucherDisable' , true );
                                }
                            } else {
                                
                                // helper.selectedPriceBookId = res.priceBookId;
                                // helper.unitPrice = res.unitPrice;
                                // helper.priceBookName = res.priceBookName;

                                // console.log('helper pbID: '+ helper.selectedPriceBookId);
                                // console.log('helper unitPrice: '+ helper.unitPrice);
                                // console.log('helper pbName: '+ helper.priceBookName);
                                console.log('other pricebook here ');
            
                            }
                        }
                } // checkpoint else if opp == null
             }  
        });

    },
    selectPriceBook : function(component, event, helper) {

        var createdOppo = helper.createdOppId;
       
        if (!createdOppo == null) {

            console.log('cannot select pricebook ');
            console.log('opp created: '+createdOppo);
            component.set( 'v.setDisableInput' , true );
            component.set( 'v.setVoucherDisable' , true );

        } else {
            console.log('Enrolment status on select: '+component.get('v.enrolmentStatus'));
            var unitPrice = event.currentTarget.getAttribute("data-unitprice"); 
            var priceBookName = event.currentTarget.getAttribute("data-pricebookname");
            var priceBookId = event.currentTarget.getAttribute("data-priceBookId");
            var unitPriceCurrencyFormat = helper.currencyFormat(parseFloat(unitPrice));

            component.set( 'v.unitPriceSlect' , unitPriceCurrencyFormat ); 
            //iver
            console.log('priceBookName '+priceBookName+'\nunitPrice '+unitPrice+'\nPriceBookId '+priceBookId);
            helper.selectedPriceBookId = priceBookId;
            helper.unitPrice = unitPrice;
            helper.priceBookName = priceBookName;
            //stat
            var getEnrStat = component.get('v.enrolmentStatus');

            if( getEnrStat == 'Draft'){ 
                
                if( priceBookName == 'One-off payment'   ){
                    component.set( 'v.setVoucherDisable' , false );
                    var vcode = document.getElementById("VoucherCodeId").value;
                    helper.vCodeContainer = vcode;
                } else {
                    component.set( 'v.setVoucherDisable' , true );
                    document.getElementById("VoucherCodeId").value = '';
                    helper.vCodeContainer = '';
                    helper.isVCodeValidated = false;
                }

            } else if( getEnrStat == 'Pending Payment'){ 
                
                if( priceBookName == 'One-off payment'   ){
                    component.set( 'v.setVoucherDisable' , false );
                    var vcode = document.getElementById("VoucherCodeId").value;
                    helper.vCodeContainer = vcode;

                } else {
                    component.set( 'v.setVoucherDisable' , true );
                    document.getElementById("VoucherCodeId").value = '';
                    helper.vCodeContainer = '';
                    helper.isVCodeValidated = false;
                } 
            } else {
                component.set( 'v.setDisableInput' , true );
                component.set( 'v.setVoucherDisable' , true );
                
            }
        }
    },
    cancelcallback : function( cmp, event, helper ){
        cmp.set("v.showSpinner", true);
        
        var enrolId = cmp.get("v.enrollmentId");
        var deleteEnrol = cmp.get("c.deleteEnrolment");

        deleteEnrol.setParams({
            "enrolId": enrolId
        });

        deleteEnrol.setCallback( this, function( response ) {
            var status = response.getState();
            if( status === "SUCCESS" ) {
                var rBody = response.getReturnValue();
                window.location.href = window.location.origin + '/s/my-enrolments';
            } else {
                console.log( response.getError() );
            }
            cmp.set("v.showSpinner", false);
        });
        $A.enqueueAction( deleteEnrol );

    },

    backCallback: function( cmp, event, helper ) {
        helper.backCallback( cmp );
    },
    
    saveNEmail: function( cmp, event, helper ){
        cmp.set("v.showSpinner", true);
        var toastEvent = $A.get("e.force:showToast");
        // Object selectedUnitIdMap , Id learningPackage , Id EnrollmentId
        var action = cmp.get("c.updateEnrollment");
        //var saveAndEmail = 'saveAndEmail';
        
        action.setParams({ "EnrollmentId": cmp.get('v.enrollmentId')
                          , "acctId": cmp.get('v.accountId')
                          //, "saveChanges" : saveAndEmail
                         });
        
        action.setCallback(this, function(response) {
            var status = response.getState();
            if( status === "SUCCESS" ) {
                var rBody = response.getReturnValue();
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Email has been sent"
                });
                toastEvent.fire();
                console.log( 'rBody', rBody );
                cmp.set("v.showSpinner", false);
                //helper.callNextStep( cmp );
            } else {
                cmp.set("v.showSpinner", false);
                // toastEvent.setParams({
                //     "title": "Error!",
                //     "type" : 'error',
                //     "message": "Please fill up the required fields!"
                // });
                // toastEvent.fire();
                console.log( response.getError() );
            }
        });
        $A.enqueueAction(action);
         
    },

    continueWithPayment: function( component, event, helper ){
        
        var voucherCode = document.getElementById("VoucherCodeId").value; 
        var oppId = component.get("v.oppId");
        console.log('createdComp Opp '+ oppId);
        console.log('Voucher code for opp '+ voucherCode);

        //get validated vcode boolean = true?
        var isVCodeVal = helper.isVCodeValidated;
        console.log('is vcode validated? '+ isVCodeVal);

        //get validated vcode
        var vCodeCont = helper.vCodeContainer;
        console.log('current vcode '+ vCodeCont);

        if (helper.createdOppId != null ){
            var createdOppID = helper.createdOppId;
            console.log('created Opp '+ createdOppID);
        } else {
            console.log('No created Opp');
        }

        var priceBookId = helper.selectedPriceBookId;
        var priceBookName = helper.priceBookName;
        var unitPrice = helper.unitPrice;

        console.log ('PriceBookId ' + priceBookId+'\nPriceBookName '+ priceBookName+'\nUnit Price '+unitPrice);
        //get current product
        var prod2Id = component.get("v.productIdVcode");
        console.log('prod2Id '+prod2Id);
        //create opportunity if null
        if ( oppId == null ) {

            if (isVCodeVal == true && vCodeCont != null ) {
                
                console.log('true and validated ');
                var createOppLineItems = component.get("c.createOppLineItems");
                createOppLineItems.setParams({ "EnrollmentId": component.get('v.enrollmentId')
                                                 ,"acctId": component.get('v.accountId')
                                                 ,"priceBookId": priceBookId
                                                 ,"unitPrice": unitPrice
                                                 ,"vCode": vCodeCont
                                                });

                 createOppLineItems.setCallback(this, function(response) {
                    var status = response.getState();
                    
                    console.log( ' status of Opportunity creation ',status );

                    if( status === "SUCCESS" ) {
                       
                        var rBody = response.getReturnValue();
                        console.log( 'Created Opp and Enrolment stat', rBody );
                        
                        var oppId = rBody.OpportunityId;
                        var fundedPosition = rBody.fundedPosition;
                        var fundedEligible= rBody.fundedEligible;
                        var oppId = rBody.OpportunityId;
                        var opAmount = rBody.OpportunityAmount;
                        console.log("Created opp: "+ oppId);
                        console.log("OppAmount: "+ opAmount);
                        component.set("v.oppId", oppId);
                        helper.createdOppId = oppId;
                        //helper.refreshComponent( cmp );
                        component.set("v.showSpinner", false);

                        if (fundedPosition || fundedEligible) {
                            component.set("v.showSpinner", false);
                            console.log('Next page dapat ky '+'\nFundedPosition '+fundedPosition+'\nfundedEligible '+fundedEligible);
                            var cmpEvent = component.getEvent("Enrolment_Event");
                            var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
                            cmpEvent.setParams({
                            enrolmentStep : "step14 - completed"});
                            cmpEvent.fire();
                        } else if ( opAmount <= 0 ) {
                            component.set("v.showSpinner", false);
                            console.log('Next page dapat ky '+'\nOppAmount is: '+opAmount);
                            var cmpEvent = component.getEvent("Enrolment_Event");
                            var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
                            cmpEvent.setParams({
                            enrolmentStep : "step14 - completed"});
                            cmpEvent.fire();
                        } else {
                            component.set("v.showSpinner", true);
                            //call payment page if not funded
                            window.location.href = window.location.origin +'/apex/PaymentPage?oppId='+oppId+'&isPSAEnrolment=1';
                        }
                        //helper.callNextStep( cmp );
                    } else {
                        component.set("v.showSpinner", false);
                        //window.location.href = window.location.origin +'/apex/PaymentPage?oppId='+oppId+'&isPSAEnrolment=1';
                        // toastEvent.setParams({
                        //     "title": "Error!",
                        //     "type" : 'error',
                        //     "message": "Please fill up the required fields!"
                        // });
                        // toastEvent.fire();
                        console.log('Response error: '+ response.getError() );
                    }
                });
                $A.enqueueAction(createOppLineItems);

            } else {

                console.log('sulod ');
                var createOppOnEnrolment = component.get("c.createOppOnEnrolment");
                createOppOnEnrolment.setParams({ "EnrollmentId": component.get('v.enrollmentId')
                                                 ,"acctId": component.get('v.accountId')
                                                 ,"priceBookId": priceBookId
                                                 ,"unitPrice": unitPrice
                                                });

                createOppOnEnrolment.setCallback(this, function(response) {
                    var status = response.getState();
                    
                    console.log( ' status of Opportunity creation ',status );

                    if( status === "SUCCESS" ) {
                       
                        var rBody = response.getReturnValue();
                        console.log( 'Created Opp and Enrolment stat', rBody );
                        
                        var oppId = rBody.OpportunityId;
                        var fundedPosition = rBody.fundedPosition;
                        var fundedEligible= rBody.fundedEligible;
                        var oppId = rBody.OpportunityId;
                        console.log("Created opp: "+ oppId);
                        component.set("v.oppId", oppId);
                        helper.createdOppId = oppId;
                        //helper.refreshComponent( cmp );
                        component.set("v.showSpinner", false);

                        if (fundedPosition || fundedEligible) {
                            component.set("v.showSpinner", false);
                            console.log('Next page dapat ky '+'\nFundedPosition '+fundedPosition+'\nfundedEligible '+fundedEligible);
                            var cmpEvent = component.getEvent("Enrolment_Event");
                            var cmpEvent = $A.get("e.c:EnrolmentActiveStep");
                            cmpEvent.setParams({
                            enrolmentStep : "step14"});
                            cmpEvent.fire();
                        } else {
                            component.set("v.showSpinner", true);
                            //call payment page if not funded
                            window.location.href = window.location.origin +'/apex/PaymentPage?oppId='+oppId+'&isPSAEnrolment=1';
                        }
                        //helper.callNextStep( cmp );
                    } else {
                        component.set("v.showSpinner", false);
                        //window.location.href = window.location.origin +'/apex/PaymentPage?oppId='+oppId+'&isPSAEnrolment=1';
                        // toastEvent.setParams({
                        //     "title": "Error!",
                        //     "type" : 'error',
                        //     "message": "Please fill up the required fields!"
                        // });
                        // toastEvent.fire();
                        console.log('Response error: '+ response.getError() );
                    }
                });
                $A.enqueueAction(createOppOnEnrolment);
                //$A.get("e.force:refreshView").fire();
            }
        } else {

            if (unitPrice > 0){

                helper.updateEnrolToPendingpayment( component, function ( getRet) {
                    if (getRet == "Enrolment updated!") {
                        window.location.href = window.location.origin +'/apex/PaymentPage?oppId='+oppId+'&isPSAEnrolment=1';
                    }
                });

               
                //window.location = window.location.origin +'/'+'village'+'/' + 'AsAttendessListPdf' +'?id='+ helper.getUrlVar('recId');
            } else {
                //window.location.href = window.location.origin +'/apex/PaymentPage?oppId='+oppId+'&isPSAEnrolment=1';
                console.log('Amount is not higher than expected.');
            }
        } 
    },

    ValidateVoucher: function( component, event, helper ) {
        component.set("v.showSpinner", true);
        var getProdId = component.get('v.productIdVcode');
        var voucherCode = document.getElementById("VoucherCodeId").value; 
        console.log("Vcode: "+voucherCode);
        console.log("Productid: "+getProdId);
        var toastEvent = $A.get("e.force:showToast");

        var validateVoucher = component.get("c.validateVoucherCode");
        validateVoucher.setParams({
                                     "vCode": voucherCode,
                                     "prodId" : getProdId
                                    });

        validateVoucher.setCallback(this, function(response) { 

            var status = response.getState();
            var getRetmsg = response.getReturnValue();
                    
            console.log( 'check stat: ',status );
            console.log( 'Get return value: ',getRetmsg );

            if( status === "SUCCESS" ) {
                component.set("v.showSpinner", false);
                if(getRetmsg == 'Voucher is available and ready to use') {

                    console.log('Valid: '+getRetmsg);
                    toastEvent.setParams({
                        "title": "Valid",
                        "type": "success",
                        "message": getRetmsg
                    });
                    toastEvent.fire();
                    helper.isVCodeValidated = true;
                    var vcode = document.getElementById("VoucherCodeId").value;
                    helper.vCodeContainer = vcode;

                } else if (getRetmsg == 'Voucher code has expired and no longer valid') {
                    console.log('Error: '+getRetmsg);
                    toastEvent.setParams({
                        "title": "Expired!",
                        "type": "warning",
                        "message": getRetmsg
                    });
                    toastEvent.fire();
                    helper.isVCodeValidated = false;
                    helper.vCodeContainer = '';
                    document.getElementById("VoucherCodeId").value = ''; 
                } else if ( getRetmsg == 'Voucher code has already been used' ) {
                    console.log('Error: '+getRetmsg);
                    toastEvent.setParams({
                        "title": "Invalid!",
                        "type": "warning",
                        "message": getRetmsg
                    });
                    toastEvent.fire();
                    helper.isVCodeValidated = false;
                    helper.vCodeContainer = '';
                    document.getElementById("VoucherCodeId").value = ''; 
                } else if ( getRetmsg == 'Cannot validate an empty field' ) {
                    console.log('Error: '+getRetmsg);
                    toastEvent.setParams({
                        "title": "Invalid!",
                        "type": "warning",
                        "message": getRetmsg
                    });
                    toastEvent.fire();
                    helper.isVCodeValidated = false;
                    helper.vCodeContainer = '';
                    document.getElementById("VoucherCodeId").value = ''; 
                } else {
                    console.log('Error: '+getRetmsg);
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": getRetmsg
                    });
                    toastEvent.fire();
                    helper.isVCodeValidated = false;
                    helper.vCodeContainer = '';
                    document.getElementById("VoucherCodeId").value = ''; 
                }
            } else {
                component.set("v.showSpinner", false);
                console.log('Response error: '+ response.getError() );
                console.log('Error: '+getRetmsg);
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": getRetmsg
                });
                toastEvent.fire();
                helper.isVCodeValidated = false;
                helper.vCodeContainer = '';
                document.getElementById("VoucherCodeId").value = ''; 
            }
        });
        $A.enqueueAction(validateVoucher);
    }
})