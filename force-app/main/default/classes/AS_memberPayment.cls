/*
 * Author : WEW
 * Description: use to save and get data for "PaymentPage" VF .
 * Parameter : 
 * Return : 
 */
global class AS_memberPayment {
    
    public static final String GATEWAY_ID = ASPSASettings__c.getInstance().Default_Payment_Gateway_ID__c;

    /*
     * Author : WEW
     * Description: Constructor
     * Parameter : None
     * Return : None
     */
    global AS_memberPayment() {

    }

    /*
     * Author : WEW
     * Description: use to get data for "PaymentPage" VF .
     * Parameter : opportunity Id
     * Return : PaymentWrapper
     */
    @remoteAction
    global static PaymentWrapper paymentAllData(String[] param) {
        Account finalAccount = new Account();
        Contact finalContact = new Contact();
        Id finalPriceBook;
        system.debug('param data from PaymentPage:' + param);
        //  Id finalOppId = (ApexPages.currentPage().getParameters().get('oppID') != null)?ApexPages.currentPage().getParameters().get('oppID'):null;

        /* Update by : JRC  
        Update : I add fields in the query like ff: AS_GST_Component__c,AS_Invoiced_Amount__c
        */
        Opportunity finalOpp = [Select Account.Id, Id, StageName, Name, Pricebook2Id, AS_GST_Component__c, AS_Invoiced_Amount__c, Pricebook2.AS_Frequency__c, Pricebook2.AS_X6_Month_Subscription__c, (Select Id, Name, quantity, UnitPrice, PricebookEntryId, Product2.Name, Description from OpportunityLineItems order by createddate) from Opportunity where Id =: param[0]];

        Set < Id > allProdForTTrackIdSet = new Set < Id > ();
        List < OpportunityLineItem > allOppLineItem = new List < OpportunityLineItem > ();
        for (OpportunityLineItem oppLine: finalOpp.OpportunityLineItems) {
            allOppLineItem.add(oppLine);

            //block added by john 02-21-19 for (#PSA-356)
            allProdForTTrackIdSet.add(oppLine.Product2Id);
        }

        if (finalOpp.Account.Id != null) {
            finalAccount = [Select Id, Name, FirstName, LastName, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet from Account where Id =: finalOpp.Account.Id];
        }
        /*
        if(finalOpp.Contact.Id != null) {
        finalContact = [Select Id,Name,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet from Contact where Id = :finalOpp.Contact.Id];
        } 
        */
        if (finalOpp.Pricebook2Id != null) {
            finalPriceBook = finalOpp.Pricebook2Id;
        }

        //block added by john 02-21-19 for (#PSA-356)
        Boolean showTTrackDiDebit = false;
        for (Training_Track__c trainTrack: [Select AS_Track_Type__c, Id, Name, Product__c from Training_Track__c where Product__c IN: allProdForTTrackIdSet]) {
            if (trainTrack.AS_Track_Type__c == 'Diploma' || trainTrack.AS_Track_Type__c == 'Intern Training Program' || trainTrack.AS_Track_Type__c == 'Qualification') {
                showTTrackDiDebit = true;
            }
        }


        PaymentWrapper payWrap = new PaymentWrapper(finalAccount, finalContact, finalOpp, finalPriceBook, allOppLineItem, showTTrackDiDebit);
        System.debug('finalOpp :' + finalOpp);
        System.debug('payWrap :' + payWrap);
        return payWrap;
    }

    /*
     * Author : WEW
     * Description: get data for coupon code
     * Parameter : None
     * Return : None
     */
    /*
    @RemoteAction 
    global static List<AS_Coupon__c> getDiscount(String[] param) {
    List<AS_Coupon__c> couCode = [Select Id,AS_Discount_Amount__c,AS_Percentage_Discount__c,RecordType.Name from AS_Coupon__c where AS_Code__c = :param[0] AND AS_Expiry_Date__c >= TODAY Limit 1];
    return couCode;
    }
    */

    private static processDataResult chargentPaymentProcess(Opportunity finalOppData, AS_paymentWrapper theFinal){
        Savepoint sp = Database.setSavepoint();
        
        ChargentOrders__ChargentOrder__c ord = new ChargentOrders__ChargentOrder__c();

        ord.ChargentOrders__Payment_Method__c = 'Credit Card';
        ord.ChargentOrders__Account__c = id.valueof(theFinal.ACCOUNTID);
        ord.ChargentOrders__Card_Type__c = theFinal.CARDDETAILS.Card_Type;
        ord.ChargentOrders__Card_Number__c = theFinal.CARDDETAILS.Card_Number;
        ord.ChargentOrders__Card_Expiration_Month__c = theFinal.CARDDETAILS.Card_Expiry_Month;
        ord.ChargentOrders__Card_Expiration_Year__c = theFinal.CARDDETAILS.Card_Expiry_Year;
        ord.ChargentOrders__Gateway__c = GATEWAY_ID;
        ord.ChargentOrders__Subtotal__c = decimal.valueOf(theFinal.SUBTOTAL);
        ord.ChargentOrders__Tax__c = decimal.valueOf(theFinal.SUBTOTAL) * 0.1;
        ord.ChargentOrders__Charge_Amount__c = ord.ChargentOrders__Subtotal__c + ord.ChargentOrders__Tax__c;
        ord.ChargentOrders__Manual_Charge__c = true;
        ord.ChargentOrders__Charge_Date__c = String.valueOf(system.today().month()).leftPad(2, '0');
        ord.ChargentOrders__Payment_Frequency__c = 'Once';
        ord.ChargentOrders__Billing_First_Name__c = finalOppData.Account.FirstName;
        ord.ChargentOrders__Billing_Last_Name__c = finalOppData.Account.LastName;
        ord.ChargentOrders__Billing_Email__c = finalOppData.Account.PersonEmail;

        Database.SaveResult saveChargentOrder = Database.insert(ord, false);
        System.debug('saveChargentOrder :' + saveChargentOrder);

        if(saveChargentOrder.isSuccess()) {
            
            if (finalOppData.Owner.Name.toLowerCase() == 'membership sign up site guest user') {
                finalOppData.OwnerId = AS_commonFunction.ownerId();
            }
            
            finalOppData.Chargent_Order__c = ord.Id;

            update finalOppData;

            if (finalOppData.Account.Owner.Name.toLowerCase() == 'membership sign up site guest user') {
                Account updateAcc = new Account();
                updateAcc.Id = id.valueof(theFinal.ACCOUNTID);
                updateAcc.OwnerId = AS_commonFunction.ownerId();
                update updateAcc;
            }
            
            charge(ord.Id);
            
            processDataResult res = new processDataResult('SUCCESS', 'Thank you. We will process your membership');
            System.debug('Exception HERE 1: ' + res);
            return res;
        }

        else {
            Database.rollback(sp);

            List < Database.Error > err3 = saveChargentOrder.getErrors();
            String errMessage = err3[0].getMessage();
            Integer first = errMessage.indexOf('_EXCEPTION,') + 12;

            if (first >= 12) {
                errMessage = errMessage.Substring(first);
                Integer last = errMessage.indexOf('.');
                errMessage = errMessage.Substring(0, last + 1);
            }

            processDataResult res = new processDataResult('ERROR', errMessage);
            System.debug('Exception HERE 2: ' + res);
            return res;
        }
    }

    /*
     * Author : WEW
     * Description: get all data from the payment page. Account, Opportunity, Credit Card details and etc.
     * Parameter : serialized JSON String
     * Return : None
     */
    @RemoteAction
    global static processDataResult processData(String paymentData) {

        AS_paymentWrapper theFinal = (AS_paymentWrapper) JSON.deserializeStrict(paymentData, AS_paymentWrapper.class);

        //   System.debug('theFinal.ACCOUNTDETAILS.Account_Routing_Number :' + date.valueOf(theFinal.ACCOUNTDETAILS.First_Payment_Date));
        System.debug('FinalData :' + theFinal);

        Id finalPricebookID = Id.valueOf(thefinal.PRICEBOOKID);
        Id finalOpportunityID = Id.valueOf(thefinal.OPPORTUNITYID);
        Id finalAccountID = Id.valueOf(theFinal.ACCOUNTID);

        //Update the pPayment record base on the Opportunity.
        updateAllPpaymentsByOppId(finalOpportunityID);

        Opportunity finalOppData = [Select
            Account.Owner.Name,
            Account.FirstName,
            Account.LastName,
            Account.PersonEmail,
            Account.Id,
            AS_GST_Component__c,
            CloseDate,
            Owner.Name,
            Id, 
            Amount, 
            Name,
            Pricebook2Id,
            Pricebook2.Name,
            Pricebook2.AS_Frequency__c,
            Pricebook2.AS_X6_Month_Subscription__c,
            AS_PSA_Subscription__c,
            AS_Product__c,
            AS_Product__r.Family,
            AS_Product__r.New_Membership_Process__c,
            (Select Id,
                Name,
                PricebookEntryId,
                Product2.Name,
                quantity,
                UnitPrice from OpportunityLineItems
            )
            from
            Opportunity
            where
            Id =: finalOpportunityID
            LIMIT 1
        ];

        //  Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true Limit 1];

        Integer freq;

        // code block below is updated for (#PSA-282)
        /*   if(theFinal.ONCEOFF == true) { // for (#PSA-330)
        freq = 1;
        } else */
        if (finalOppData.Pricebook2.AS_X6_Month_Subscription__c == true) {
            freq = 6;
        } else {
            freq = (finalOppData.Pricebook2.AS_Frequency__c != null) ? Integer.valueOf(finalOppData.Pricebook2.AS_Frequency__c) : 1;
        }
        
        /*Map < Integer, String > mapFreq = new Map < Integer, String > ();
        mapFreq.put(1, 'Annual');
        mapFreq.put(2, 'Semiannual');
        mapFreq.put(4, 'Quarterly');
        mapFreq.put(6, 'Bimonthly'); // this is added for (#PSA-282)
        mapFreq.put(12, 'Monthly');*/

        String payBy = thefinal.PAYBY;

        ASPHPP__PPSettings__c settings = ASPHPP__PPSettings__c.getOrgDefaults();

        Id defaultGateway;
        
        defaultGateway = String.isNotBlank(settings.ASPHPP__Gateway_ID__c) ? Id.valueOf(settings.ASPHPP__Gateway_ID__c) : null;
        ASPHPP__ASPayment_Source__c paySource = new ASPHPP__ASPayment_Source__c();

        if(finalOppData.AS_Product__r.New_Membership_Process__c || finalOppData.AS_Product__r.Family != 'Membership'){
            return chargentPaymentProcess(finalOppData, theFinal);
        }
         
        else {
            Savepoint sp = Database.setSavepoint();
            if (payBy == 'DirectDebit') {
                Id bankRecordTypeId = Schema.SObjectType.ASPHPP__ASPayment_Source__c.getRecordTypeInfosByName().get('Bank Account').getRecordTypeId();

                paySource.recordTypeId = bankRecordTypeId;
                paySource.ASPHPP__Account__c = id.valueof(theFinal.ACCOUNTID); // account name
                paySource.ASPHPP__Account_Name__c = theFinal.ACCOUNTDETAILS.Account_Name; // bank account name
                paySource.ASPHPP__Account_Type__c = theFinal.ACCOUNTDETAILS.Account_Type; // account type
                paySource.ASPHPP__Account_Number__c = theFinal.ACCOUNTDETAILS.Account_Number; // account number
                //    paySource.AS_Bank_Number_Free_Text__c = paySource.ASPHPP__Account_Number__c;  // commented as per peters instruction 2/15/08
                paySource.ASPHPP__Account_BSB__c = theFinal.ACCOUNTDETAILS.Account_Routing_Number; // bsb name

                if (defaultGateway != null) {
                    paySource.ASPHPP__Gateway__c = defaultGateway; // expiry month 
                }

            } 
            else if (payBy == 'CreditCard') {
                Id ccRecordTypeId = Schema.SObjectType.ASPHPP__ASPayment_Source__c.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();

                paySource.recordTypeId = ccRecordTypeId;
                paySource.ASPHPP__Account__c = id.valueof(theFinal.ACCOUNTID); // account
                paySource.ASPHPP__Card_Name__c = theFinal.CARDDETAILS.Name_On_Card; // card name
                paySource.ASPHPP__Credit_Card_Type__c = theFinal.CARDDETAILS.Card_Type; // card type
                paySource.ASPHPP__Card_CCV__c = theFinal.CARDDETAILS.CCV; // ccv
                paySource.ASPHPP__Card_Number__c = theFinal.CARDDETAILS.Card_Number; // card number
                paySource.ASPHPP__Card_Expiry_Month__c = theFinal.CARDDETAILS.Card_Expiry_Month; // card number
                paySource.ASPHPP__Card_Expiry_Year__c = theFinal.CARDDETAILS.Card_Expiry_Year; // expiry month 

                if (defaultGateway != null) {
                    paySource.ASPHPP__Gateway__c = defaultGateway; // expiry month 
                }

                System.debug('No error found' + paySource);
            }
        
            Database.SaveResult savePaySource = Database.insert(paySource, false);
            System.debug('savePaySource :' + savePaySource);

            if (savePaySource.isSuccess()){

                // map to for getting the right frequency from integer starts here
                Map < Integer, String > mapFreq = new Map < Integer, String > ();
                mapFreq.put(1, 'Yearly');
                mapFreq.put(2, 'Every Six Months');
                mapFreq.put(4, 'Quarterly');
                mapFreq.put(6, 'Monthly'); // this is added for (#PSA-282)
                mapFreq.put(12, 'Monthly');
                // map to for getting the right frequency from integer end here
                // add payment Source starts here
                List < ASPHPP__Subscription__c > allPaymentSubscription = new List < ASPHPP__Subscription__c > ();
                //  for(OpportunityLineItem oppLine : finalOppData.OpportunityLineItems) {
                ASPHPP__Subscription__c indiPaymentSubscription = new ASPHPP__Subscription__c();
                indiPaymentSubscription.Name = finalOppData.Name + ' Subscription';
                indiPaymentSubscription.ASPHPP__Amount__c = (finalOppData.Amount + finalOppData.AS_GST_Component__c) / freq;
                indiPaymentSubscription.ASPHPP__Frequency__c = mapFreq.get(freq);
                indiPaymentSubscription.AS_opportunity__c = finalOpportunityID;
                indiPaymentSubscription.ASPHPP__Account__c = paySource.ASPHPP__Account__c;
                indiPaymentSubscription.ASPHPP__Payment_Source__c = paySource.Id; //  this must always have a value
                indiPaymentSubscription.ASPHPP__Gateway__c = paySource.ASPHPP__Gateway__c; //  this must always have a value
                indiPaymentSubscription.AS_Acknowledge_DD_RSA__c = theFinal.ACKNOWLEDGEDBRQSTSRVC; // this code is added for (#PSA-329)
                indiPaymentSubscription.AS_Consent_to_Give_Signature__c = theFinal.CONSENTTOGIVESGNTR; // this code is added for (#PSA-329)

                // code block below is updated for (#PSA-282)
                if (theFinal.ONCEOFF == true) { // for (#PSA-330)
                    indiPaymentSubscription.ASPHPP__End_Date__c = date.today();
                    indiPaymentSubscription.AS_Subscription__c = finalOppData.AS_PSA_Subscription__c;
                } else if (freq == 6) {
                    indiPaymentSubscription.ASPHPP__End_Date__c = finalOppData.CloseDate.addDays(170); // updated from 182 to 170 for (#PSAS-105) 
                } else {
                    indiPaymentSubscription.ASPHPP__End_Date__c = finalOppData.CloseDate.addDays(364);
                }

                if (payBy == 'CreditCard') {
                    indiPaymentSubscription.ASPHPP__Process_First_Payment_Today__c = true;
                    indiPaymentSubscription.ASPHPP__Last_Payment_Date__c = date.today();
                } else {
                    indiPaymentSubscription.ASPHPP__Process_First_Payment_Today__c = true;
                    indiPaymentSubscription.ASPHPP__Next_Payment_Date__c = date.today();
                    //  indiPaymentSubscription.ASPHPP__End_Date__c = date.valueOf(theFinal.ACCOUNTDETAILS.First_Payment_Date).addDays(364);

                }

                allPaymentSubscription.add(indiPaymentSubscription);
                //  }
                System.debug('allPaymentSubscription : ' + allPaymentSubscription);

                insert allPaymentSubscription;
                // add payment Source starts here

                Id ownerUserId;

                Opportunity opp = new Opportunity();
                opp.Id = finalOpportunityID;
                
                if (finalOppData.Owner.Name.toLowerCase() == 'membership sign up site guest user') {
                    opp.OwnerId = AS_commonFunction.ownerId();
                }
                
                //opp.ASPHPP__Payment_Source__c = paySource.Id;
                /*
                if(payBy == 'DirectDebit' && String.isNotBlank(theFinal.ACCOUNTDETAILS.First_Payment_Date)){
                    opp.CloseDate = date.valueOf(theFinal.ACCOUNTDETAILS.First_Payment_Date);
                }
                */

                update opp;

                if (finalOppData.Account.Owner.Name.toLowerCase() == 'membership sign up site guest user') {
                    Account updateAcc = new Account();
                    updateAcc.Id = id.valueof(theFinal.ACCOUNTID);
                    updateAcc.OwnerId = AS_commonFunction.ownerId();
                    update updateAcc;
                }
                
                processDataResult res = new processDataResult('SUCCESS', 'Thank you. We will process your membership');
                System.debug('Exception HERE 1: ' + res);
                return res;
            } 
            else {
                Database.rollback(sp);

                List < Database.Error > err3 = savePaySource.getErrors();
                String errMessage = err3[0].getMessage();
                Integer first = errMessage.indexOf('_EXCEPTION,') + 12;

                if (first >= 12) {
                    errMessage = errMessage.Substring(first);
                    Integer last = errMessage.indexOf('.');
                    errMessage = errMessage.Substring(0, last + 1);
                }
                processDataResult res = new processDataResult('ERROR', errMessage);
                System.debug('Exception HERE 2: ' + res);
                return res;
            }


            /*  } catch(exception e) {
            String errMessage = e.getMessage();
            Integer first = errMessage.indexOf('_EXCEPTION,') + 12;
            errMessage = errMessage.Substring(first); 
            Integer last = errMessage.indexOf('.');
            errMessage = errMessage.Substring(0,last+1); 


            processDataResult res = new processDataResult('ERROR',errMessage);
            System.debug('Exception HERE : ' + res);
            return res;
            } 
            */
        }


        return null;
    }
    
    @future(callout=true)
	public static void charge(Id orderId){
        ChargentOrders.TChargentOperations.TChargentResult result = ChargentOrders.TChargentOperations.ChargeOrder_Click(orderId);
        system.debug(result);
    }

    /*
     * Author : WEW
     * Description: check if payment is successful or not.
     * Parameter : array string
     * Return : ASPHPP__Payment__c 
     */
    @RemoteAction
    //global static ASPHPP__Payment__c checkPaymentStatus(String[] oppData) {
    global static ChargentOrders__Transaction__c checkPaymentStatus(String[] oppData) {
        Id oppId = oppData[0];
        
        List <ChargentOrders__Transaction__c> theOpp = [Select Id, ChargentOrders__Response_Status__c, Name
                                                        FROM ChargentOrders__Transaction__c
                                                        WHERE ChargentOrders__Order__c in 
                                                        (select Chargent_Order__c from Opportunity where Id = :oppId)
                                                        ORDER BY CreatedDate DESC 
                                                        LIMIT 1
                                                       ];
        
        System.debug('Result theOpp : ' + theOpp);
        
        if (theOpp.size() > 0) {
            return theOpp[0];
        } else {
            return null;
        }

        /*List < ASPHPP__Payment__c > theOpp = [Select
            Id,
            Name,
            ASPHPP__PSubscription__r.ASPHPP__Payment_Source__c,
            ASPHPP__Payment_Status__c,
            ASPHPP__PSubscription__c,
            ASPHPP__PSubscription__r.AS_opportunity__c
            FROM
            ASPHPP__Payment__c
            where
            ASPHPP__PSubscription__r.AS_opportunity__c =: oppId
            AND
            As_Is_Payment_Status__c = true
            ORDER BY
            CreatedDate DESC LIMIT 1
        ];
        
        System.debug('Result theOpp : ' + theOpp);
        
        if (theOpp.size() > 0) {
            return theOpp[0];
        } else {
            return null;
        }*/
    } 
 
    /*
     * Author : WEW
     * Description: convert opportunity to close won
     * Parameter : array string
     * Return : ASPHPP__Payment__c 
     */
    @RemoteAction
    global static Opportunity convertToCloseWon(String[] oppData) {
        System.debug('convertToCloseWon was called');
        list < OpportunityStage > oppStageName = [SELECT Id, MasterLabel FROM OpportunityStage WHERE IsClosed = true AND IsWon = true];
        Opportunity opp = new Opportunity();
        opp.Id = Id.valueOf(oppData[0]);
        opp.StageName = oppStageName[0].MasterLabel;
        //opp.Chargent_Processing_Status__c = 'Queued'; 
        update opp;

		
        //updateSubscription(Id.valueOf(oppData[0]));
        

        return opp;
    }
    
    @RemoteAction
    global static Opportunity queueForProcessing(String[] oppData) {
        string oppId = Id.valueOf(oppData[0]);
        Opportunity opp = [select Id, StageName, Chargent_Order__c, Chargent_Order__r.ChargentOrders__Transaction_Total__c, AS_Payment_Amount__c 
            from Opportunity
            where Id = :oppId
            LIMIT 1];
        
        System.debug('queueForProcessing was called');

        opp.AS_Payment_Amount__c = opp.Chargent_Order__r.ChargentOrders__Transaction_Total__c;
        opp.Chargent_Processing_Status__c = 'Queued'; 
        update opp;

        return opp;
    }

    global static void updateSubscription(Id OppId){
        system.debug('updating subscription');
        list < AS_Subscription__c > subscriptionList = new list < AS_Subscription__c > ();
        for (Opportunity getOpp: [  Select
                                        Id,
                                        AS_PSA_Subscription__c
                                    From
                                        Opportunity
                                    WHERE
                                        Id =:OppId
        ]) {
 
            if( getOpp.AS_PSA_Subscription__c != null ){

                AS_Subscription__c upSubscription = new AS_Subscription__c();
                upSubscription.Id = getOpp.AS_PSA_Subscription__c; 
                upSubscription.AS_Auto_Renew__c = true;
                subscriptionList.add(upSubscription);  
                system.debug('updating subscription 2 '+ upSubscription); 

            }

        }

        if (subscriptionList.size() != 0) {
            system.debug('updating subscription 1 '+subscriptionList);
            update subscriptionList; 
        }
    }

    /*
     * Author : WEW
     * Description: process once-off functionality as per ticket (#PSA-330)
     * Parameter : array string
     * Return :  
     */
    @RemoteAction
    global static Boolean successOnceOff(String[] onceOffData) {
        System.debug('successOnceOff was called : ' + onceOffData);
        Id oppId = Id.valueOf(onceOffData[0]);
        Id paySourceId = Id.valueOf(onceOffData[1]);
        Id paySubscriptionId = Id.valueOf(onceOffData[2]);
        Id paymentId = Id.valueOf(onceOffData[3]);

        List < Order > orderList = [Select Id from Order where OpportunityId =: oppId order by createdDate desc limit 1];
        Opportunity theOpp = [Select Id, AS_PSA_Subscription__c, (Select Id from Orders order by createdDate desc) from Opportunity where Id =: oppId];


        // ASPHPP__Payment__c subscription update
        ASPHPP__Payment__c updatePayment = new ASPHPP__Payment__c();
        updatePayment.Id = paymentId;
        updatePayment.ASPHPP__Opportunity__c = oppId;
        updatePayment.AS_Subscription__c = theOpp.AS_PSA_Subscription__c;


        // ASPHPP__Subscription__c subscription update
        ASPHPP__Subscription__c updateSubs = new ASPHPP__Subscription__c();
        updateSubs.Id = paySubscriptionId;
        updateSubs.AS_opportunity__c = oppId;
        updateSubs.AS_Subscription__c = theOpp.AS_PSA_Subscription__c;


        if (theOpp.Orders.size() > 0) {
            updateSubs.AS_Order__c = orderList[0].Id;
            updatePayment.AS_Order__c = orderList[0].Id;
        }

        // membership subscription update
        AS_Subscription__c memSubs = new AS_Subscription__c();
        if (theOpp.AS_PSA_Subscription__c != null) {
            memSubs.Id = theOpp.AS_PSA_Subscription__c;
            memSubs.AS_Payment_Source__c = paySourceId; 
            update memSubs;
        }

        // membership subscription update
        Opportunity updateOpp = new Opportunity();
        updateOpp.Id = oppId;
        updateOpp.ASPHPP__Payment_Source__c = paySourceId;

        updateSubscription(oppId); 
 
        update updateOpp;
        update updateSubs;
        update updatePayment;

        return true;
    }

    /*
     * Author : WEW
     * Description: for adding voucher functionality 
     * Parameter : array string
     * Return :  
     * LastModifiedDate : October 17, 2019
     * LastModifiedBy : Mizpah Ocate
     * ** PSAMOPT-129
     */
    @RemoteAction
    global static Boolean addVoucher(String[] couponData) {
        System.debug('addVoucher was called : ' + couponData);
        
        Id amountRecordTypeId = Schema.SObjectType.AS_Coupon__c.getRecordTypeInfosByName().get('Amount').getRecordTypeId();
        Id percentRecordTypeId = Schema.SObjectType.AS_Coupon__c.getRecordTypeInfosByName().get('Percentage').getRecordTypeId();
        Id oppId = Id.valueOf(couponData[0]);
        Id priceBookId = Id.valueOf(couponData[1]);
        String vCode = couponData[2];
        Id tPlanId = couponData[3];
        
        List<Training_Plan__c> tPlan = [SELECT Id, AS_Product__c FROM Training_Plan__c WHERE Id =: tPlanId AND AS_Product__c != null LIMIT 1];
        
        List < AS_Coupon__c > cou = [SELECT Id, Name,
                                            AS_Discount_Amount__c,
                                            AS_Percentage_Discount__c,
                                            AS_Code__c,
                                            RecordTypeId,
                                     		AS_Product__c,
                                     		AS_Status__c ,
                                     		AS_Generic_Coupon__c,
                                     		Multiple_Use__c
            							FROM AS_Coupon__c
                                     	WHERE AS_Code__c =: vCode
            								AND AS_Status__c = 'Active'
                                            ORDER BY createdDate LIMIT 1 ];
        
        System.debug('Vcode : ' + vCode);
        
        if (cou.size() > 0) {
            Id pricebookIdFinal;
            if (Test.isRunningTest()) {
                pricebookIdFinal = Test.getStandardPricebookId();
            } else {
                Pricebook2 standardPB = [select id from Pricebook2 where isStandard = true Limit 1];
                pricebookIdFinal = standardPB.Id;
            }
            
            ASPSASettings__c couponProdId = ASPSASettings__c.getOrgDefaults();
            Id finalProdId = (couponProdId.AsCouponProductId__c != null ? Id.valueOf(couponProdId.AsCouponProductId__c) : '01tN0000004r9cH');
            Id priEntryCouponId;
            
            // Opportunity
            List < Opportunity > finalOpp = [Select Id, Name, Amount, Coupon__c from Opportunity where Id =: oppId limit 1];
            Double finalOppAmount = (finalOpp[0].Amount != null ? finalOpp[0].Amount : 0);
            Double finalPrice;
            
            // Apply Coupon functionality if TPlan has Product
            if(tPlan.size() > 0) {
                if(cou[0].AS_Generic_Coupon__c == true || tPlan[0].AS_Product__c == cou[0].AS_Product__c) {
                    finalProdId = tPlan[0].AS_Product__c;
                    
                    if (cou[0].RecordTypeId == amountRecordTypeId) {
                        if (finalOppAmount - Math.abs(cou[0].AS_Discount_Amount__c) >= 0) {
                            finalPrice = Math.abs(cou[0].AS_Discount_Amount__c);
                        } else {
                            Double difRes = finalOppAmount - Math.abs(cou[0].AS_Discount_Amount__c);
                            finalPrice = Math.abs(cou[0].AS_Discount_Amount__c) - Math.abs(difRes);
                        }
                    } else if (cou[0].RecordTypeId == percentRecordTypeId) {
                        Double tempPrice = finalOppAmount * (cou[0].AS_Percentage_Discount__c / 100);
                        if (finalOppAmount - tempPrice >= 0) {
                            finalPrice = tempPrice;
                        } else {
                            Double difRes = finalOppAmount - tempPrice;
                            finalPrice = tempPrice - Math.abs(difRes);
                        }
                    }
                    
                    List < PricebookEntry > priEntry = [Select Id, Name from PricebookEntry where Product2Id =: finalProdId AND Pricebook2Id =: priceBookId LIMIT 1];
                    
                    if (priEntry.size() > 0) {
                        priEntryCouponId = priEntry[0].Id;
                    } else {
                        List < PricebookEntry > allcreditNewPriEnt = new List < PricebookEntry > ();
                        
                        PricebookEntry creditNewPriEntSTAN = new PricebookEntry();
                        creditNewPriEntSTAN.Pricebook2Id = pricebookIdFinal;
                        creditNewPriEntSTAN.Product2Id = finalProdId;
                        creditNewPriEntSTAN.UnitPrice = 0;
                        creditNewPriEntSTAN.IsActive = true;
                        allcreditNewPriEnt.add(creditNewPriEntSTAN);
                         
                        PricebookEntry creditNewPriEnt = new PricebookEntry();
                        creditNewPriEnt.Pricebook2Id = priceBookId;
                        creditNewPriEnt.Product2Id = finalProdId;
                        creditNewPriEnt.UnitPrice = 0;
                        creditNewPriEnt.IsActive = true;
                        allcreditNewPriEnt.add(creditNewPriEnt);
                        
                        database.insert(allcreditNewPriEnt, false);
                        
                        priEntryCouponId = allcreditNewPriEnt[1].Id;
                    }
                    
                    OpportunityLineItem indiOppLineItemCoupon = new OpportunityLineItem();
                    indiOppLineItemCoupon.OpportunityId = oppId;
                    indiOppLineItemCoupon.PricebookEntryId = priEntryCouponId;
                    indiOppLineItemCoupon.UnitPrice = -1 * finalPrice;
                    indiOppLineItemCoupon.Description = vCode;
                    indiOppLineItemCoupon.Quantity = 1;
                    
                    System.debug('indiOppLineItemCoupon : ' + indiOppLineItemCoupon);
                    insert indiOppLineItemCoupon;
                    
                    if(!cou[0].Multiple_Use__c){
                        cou[0].AS_Status__c  = 'Used';
                        cou[0].AS_Opportunity__c = finalOpp[0].Id;
                        update cou[0];
                    }
                     finalOpp[0].Coupon__c = cou[0].Id;
                    update finalOpp[0];
                    
                    return true;
                }                
            }

            return false;
        } else {
            return false;
        }
    }

    /* 
     * Author : WEW
     * Description: check if payment failed.If payment fail, update the subscription end date to .
     * Parameter : array string
     * Return : ASPHPP__Payment__c 
     */
    @RemoteAction
    global static ASPHPP__Subscription__c convertSubsEndDate(String[] subsData) {
        System.debug('convertSubsEndDate was called');
        ASPHPP__Subscription__c pSubs = new ASPHPP__Subscription__c();
        pSubs.Id = Id.valueOf(subsData[0]);
        pSubs.ASPHPP__End_Date__c = Date.today();
        System.debug('convertSubsEndDate was called' + pSubs);
        update pSubs;
        return pSubs;
    }



    // wrapper class starts here
    /*
     * Author : WEW
     * Description: wrapper class for membership payment
     * Parameter : None
     * Return : None
     */
    global class PaymentWrapper {
        public Account theAccount {
            get;
            set;
        }
        public Contact theContact {
            get;
            set;
        }
        public Opportunity theOpportunity {
            get;
            set;
        }
        public Id thePricebook {
            get;
            set;
        }
        public List < OpportunityLineItem > theOpportunityLineItem {
            get;
            set;
        }
        public Boolean showTTrackDirectDebit {
            get;
            set;
        }
        public PaymentWrapper(Account acc, Contact con, Opportunity opp, Id priBook, List < OpportunityLineItem > oppLine, Boolean showDiDebit) {
            theAccount = acc;
            theContact = con;
            theOpportunity = opp;
            thePricebook = priBook;
            theOpportunityLineItem = oppLine;
            showTTrackDirectDebit = showDiDebit;
        }
    }

    /*
     * Author : WEW
     * Description: wrapper class for processed data result
     * Parameter : None
     * Return : None
     */
    global class processDataResult {
        public String status {
            get;
            set;
        }
        public String message {
            get;
            set;
        }

        public processDataResult(String sta, String mes) {
            status = sta;
            message = mes;
        }
    }

    /*
    Description : This method will update the related Ppayments record in Opportunity to the As_Is_Payment_Status__c to false.
    */
    public static void updateAllPpaymentsByOppId(Id OppId) {

        List < ASPHPP__Payment__c > updatePaymentList = new list < ASPHPP__Payment__c > ();
        for (ASPHPP__Payment__c resPayment: [Select Id FROM ASPHPP__Payment__c where ASPHPP__PSubscription__r.AS_opportunity__c =: oppId AND As_Is_Payment_Status__c = true]) {
            ASPHPP__Payment__c upPayment = new ASPHPP__Payment__c();
            upPayment.Id = resPayment.Id;
            upPayment.As_Is_Payment_Status__c = false;
            updatePaymentList.add(upPayment);
        }


        if (updatePaymentList.size() != 0) {
            update updatePaymentList;
        }

    }
}