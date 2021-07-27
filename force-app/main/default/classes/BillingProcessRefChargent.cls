public class BillingProcessRefChargent{
    //Apex properties or variables

    //public Id owner {get; set;}
    public Id paymentId { get; set; }
    public blng__Payment__c payment { get; set; }
    public Double amountField { get; set; }
    public Double balanceField { get; set; }
    public Double refundField { get; set; }

    //constructor to get the Payment record fields and values
    public BillingProcessRefChargent(ApexPages.StandardController controller) {
    payment =  (blng__Payment__c) controller.getRecord();
    paymentId = payment.Id;
    amountField = payment.blng__Amount__c;
    balanceField = payment.blng__Balance__c;
    refundField = payment.blng__Refunds__c;
    
    System.debug('The payment record: ' + payment);
    //owner = cas.OwnerId;
    }

    //Method that is called from the Visual Force page action attribute to process the Refund once it has been confirmed
    public PageReference BillingProcessRefundChargent() {
    
    //to check first if the amount has been unallocated from the invoice line and if no Refunds have been made for this payment already
    //if(amountField == balanceField && refundField == 0)
    
    //to check first if there is any Balance to be refunded in the Payment record (unallocated)
    if(balanceField > 0 && balanceField <= amountField)
    {
        System.debug('Payment Id: ' + paymentId);
        
        //build your code logic here
        blng.TransactionParameter transactionParameter = new blng.TransactionParameter();
        map<string, blng.TransactionParameter> mapTrans = new map<string, blng.TransactionParameter>();
        
        //Retrieve the fields based on the Payment record selected from the detail page
        blng__Payment__c payment = [SELECT blng__Account__c,blng__AllocatedtoDebitNoteLines__c,blng__AllocatedtoInvoiceLines__c,blng__AllocatedtoInvoices__c,blng__AllocationStatus__c,blng__Allocations__c,blng__Amount__c,blng__Balance__c,blng__BankAccountName__c,blng__BankAccountNumber__c,blng__BankAccountType__c,blng__BankName__c,blng__BankRoutingCode__c,blng__BaseCurrencyAmount__c,blng__BaseCurrencyFXDate__c,blng__BaseCurrencyFXRate__c,blng__BaseCurrency__c,blng__BillingFinanceBook__c,blng__BillingFinancePeriod__c,blng__CardCodeResponse__c,blng__CardExpirationMonth__c,blng__CardExpirationYear__c,blng__CardType__c,blng__CheckDate__c,blng__CheckNumber__c,blng__FinancePeriod__c,blng__GatewayID__c,blng__GLRule__c,blng__GLTreatment__c,blng__ImpactAmount__c,blng__Invoice__c,blng__LegalEntity__c,blng__Notes__c,blng__PaidBy__c,blng__PaymentAuthorization__c,blng__PaymentDate__c,blng__PaymentDescription__c,blng__PaymentGatewayToken__c,blng__PaymentGateway__c,blng__PaymentMethod__c,blng__PaymentMode__c,blng__PaymentType__c,blng__RefundsAllocations__c,blng__RefundsUnallocations__c,blng__Refunds__c,blng__RequestCreditCardNumber__c,blng__RequestTypeOfPayment__c,blng__Status__c,blng__Transaction__c,blng__UnallocatedfromDebitNoteLines__c,blng__UnallocatedfromInvoiceLines__c,blng__UnallocatedfromInvoices__c,blng__Unallocations__c,Id,IsDeleted,Name FROM blng__Payment__c WHERE Id =: paymentId];  

        blng__PaymentTransaction__c transactionInstance = [SELECT blng__Account__c,blng__Amount__c,blng__Authorization__c,blng__AVSResponseCode__c,blng__AVSZip__c,blng__BankAccountName__c,blng__BankAccountNumber__c,blng__BankAccountType__c,blng__BankName__c,blng__BankRoutingCode__c,blng__CardCodeResponse__c,blng__CardExpirationMonth__c,blng__CardExpirationYear__c,blng__CardType__c,blng__ExceptionMessage__c,blng__GatewayDate__c,blng__GatewayID__c,blng__GatewayRequest__c,blng__GatewayResponse__c,blng__GatewayStatus__c,blng__IsPaymentProcessedSuccessfully__c,blng__Notes__c,blng__PaymentGateway__c,blng__PaymentMethod__c,blng__PaymentRun__c,blng__ReasonCode__c,blng__RequestCreditCardNumber__c,blng__RequestInvoice__c,blng__RequestTransactionType__c,blng__RequestTypeOfPayment__c,blng__ResponseCode__c,blng__ResponseMessage__c,blng__ResponseStatus__c,blng__Response__c,blng__SourceTransactionId__c,blng__Status__c,blng__Transaction__c,blng__Type__c,Id,IsDeleted,Name,OwnerId FROM blng__PaymentTransaction__c where Id =: payment.blng__Transaction__c];   
        
        blng__PaymentMethod__c paymentMethod = [SELECT blng__Account__c,blng__Active__c,blng__AutoPay__c,blng__BankAccountName__c,blng__BankAccountNumber__c,blng__BankAccountType__c,blng__BankName__c,blng__BankRoutingCode__c,blng__BillingAddress__c,blng__BillingCity__c,blng__BillingCompany__c,blng__BillingCountry__c,blng__BillingEmail__c,blng__BillingFax__c,blng__BillingFirstName__c,blng__BillingLastName__c,blng__BillingPhone__c,blng__BillingStateProvince__c,blng__BillingStreet__c,blng__BillingZipPostal__c,blng__CardBIN__c,blng__CardExpirationMonth__c,blng__CardExpirationYear__c,blng__CardLastFour__c,blng__CardNumber__c,blng__CardType__c,blng__CVV__c,blng__GatewayResponse__c,blng__GLRule__c,blng__GLTreatment__c,blng__LegalEntity__c,blng__Nameoncard__c,blng__NickName__c,blng__Notes__c,blng__PaymentGatewayToken__c,blng__PaymentGateway__c,blng__PaymentType__c,blng__StreetAddress2__c,Cr_Card_Expiration_Date__c,CustomCrCardNumber__c,CustomGatewayToken__c,Id,IsDeleted,Name FROM blng__PaymentMethod__c where Id =: payment.blng__PaymentMethod__c];
              
        blng__PaymentGateway__c gateway =  [SELECT blng__Active__c,blng__Default__c,blng__GatewayType__c,blng__Notes__c,ChrgntBllng__Chargent_Gateway__c,Id,IsDeleted,Name FROM blng__PaymentGateway__c WHERE Id =: payment.blng__PaymentGateway__c];
        
        Account acc =  [SELECT Id FROM Account where Id =: payment.blng__Account__c];

        //It copies the needed Ezidebit transaction id from the Payment to the Transaction to recognise the charge transaction bank id
        //This is currently to fix the Chargent Bug where the wrong Id is passed for the Refund
        transactionInstance.blng__GatewayID__c = payment.blng__GatewayID__c;
    
        //Sets the different records and objects to the Billing Transaction Parameter
        transactionParameter.setPayment(payment);
        
        transactionParameter.setTransaction(transactionInstance);
        
        transactionParameter.setPaymentMethod(paymentMethod);
        
        transactionParameter.setGateWay(gateway);
        
        transactionParameter.setAccount(acc);
        
        //Before setting the amount, the value needs to be converted from decimal to String
        //String amount1 = String.valueOf(transactionInstance.blng__Amount__c);
        //Adjustment to read and refund the Balance left in Payment record
        String amount1 = String.valueOf(payment.blng__Balance__c);
        
        transactionParameter.setAmount(amount1);        
        
        //Puts the Billing Transaction Parameter into a map, as needed in the parameter of the function
        mapTrans.put('key1', transactionParameter);
        
        System.debug('transaction result0:' + mapTrans.get('key1'));

        //Function to call the Chargent API to Refund Transaction    
        Map<String, blng.TransactionResult> transResults = ChrgntBllng.ChargentGatewayAPI.refundTransaction(mapTrans);
                   
        System.debug('transaction result 2 key1: ' + mapTrans.get('key1'));
        System.debug('transaction result 2 RefundResultText: ' + mapTrans.get('key1').getResponseValueByKey().get('RefundResultText'));        
        System.debug('transaction result 2 RefundPaymentID: ' + mapTrans.get('key1').getResponseValueByKey().get('RefundPaymentID'));        
        System.debug('transaction result 2 AuthCode: ' + mapTrans.get('key1').getResponseValueByKey().get('AuthCode'));                
        System.debug('transaction result 2 DebugString: ' + mapTrans.get('key1').getResponseValueByKey().get('DebugString'));        
                
        //String refundResText = mapTrans.get('key1').getResponseValueByKey().get('RefundResultText');
        //String refundPayId= mapTrans.get('key1').getResponseValueByKey().get('RefundPaymentID');
        String AuthCodeId= mapTrans.get('key1').getResponseValueByKey().get('AuthCode');        
        String DebugStringResult = mapTrans.get('key1').getResponseValueByKey().get('DebugString');     
        
        //To extract the substrings from the Debug field from the XML tags to verify if successful
            String refundPayId = '';
            String refundResText = '';
        
        //To verify first if the DebugString is not null, otherwise the below function will fail        
        if(!String.isBlank(DebugStringResult))
        {
            refundPayId = DebugStringResult.substringBetween('<RefundPaymentID>', '</RefundPaymentID>');
            System.debug('refundPayId: ' + refundPayId );

            refundResText = DebugStringResult.substringBetween('<RefundResultText>', '</RefundResultText>');
            System.debug('refundResText: ' + refundResText);
        }
                
        System.debug('transresults2:' + transResults);
        
        //Storing the result of the call to see if it was successful
        //Boolean refundSuccess = transResults.get('key1').getIsSuccess();        

        //If the result of the Refund is succesful, create the Refund and Refund Line Payment records associated with the Payment        
        //The RefundResultText returned is Approved and the RefundPaymentID is different than null,
        if (refundResText == 'Approved' && refundPayId != '')
        {

            //To create the Refund record associated with this processed Refund
            blng__Refund__c refund1 = new blng__Refund__c();
            refund1.blng__Account__c = transactionParameter.getAccount().id;
            //The check number will be the transaction id of the original payment from Ezidebit
            refund1.blng__CheckNumber__c = payment.blng__PaymentDescription__c;
            //Any description for the Refund
            refund1.blng__Notes__c = 'Refund processed from original payment: ' + payment.blng__GatewayID__c + ' Status: ' + refundResText + ' Ezidebit Id: ' + refundPayId;
            //To add the returned XML to the description of the Refund
            refund1.blng__RefundDescription__c = DebugStringResult;
            refund1.blng__PaymentGatewayTransactionID__c = payment.blng__PaymentDescription__c;
            refund1.blng__RefundDate__c = date.today();
            //External Refund Type can only be created manually
            refund1.blng__RefundMode__c = 'External';
            refund1.blng__RefundPaymentMethod__c = transactionParameter.getPaymentMethod().id;
            //Payment type can be Cr Card, Bank Transfer, cash, etc.
            refund1.blng__RefundType__c = paymentMethod.blng__PaymentType__c;

            //Refund needs to be created as Draft first, so a Refund Line can be created and associated with this Refund
            refund1.blng__Status__c = 'Draft';
                        
            //These fields are formula fields updated from the Refund Line
            //refund1.blng__Amount__c = transactionParameter.getAmount();
            //refund1.blng__RefundedfromPayments__c = transactionParameter.getAmount();
     
            //To create the Refund in draft mode
            insert refund1;
            
            //To create the Refund Line Payment record associated with this processed Refund                        
            blng__RefundLinePayment__c refLinePay = new blng__RefundLinePayment__c();
            //The amount needs to be converted from String to decimal value before its stored in the field
            refLinePay.blng__Amount__c = decimal.valueOf(transactionParameter.getAmount());            
            refLinePay.blng__Payment__c = transactionParameter.getPayment().id;
            //External Refund Type can only be created manually
            refLinePay.blng__PaymentMode__c = 'External';
            //To associate this Refund Line Payment with the above created Refund
            refLinePay.blng__Refund__c = refund1.id;
            //refLinePay.Name (Refund Line Number) - Auto
            refLinePay.blng__RefundLineDate__c =  date.today();
            //Refund Line Payment needs to be created as Draft, as it can't be posted until its associated Refund is posted first and then this field is updated automatically
            refLinePay.blng__Status__c = 'Draft';
            refLinePay.blng__Type__c = 'Allocation';
            //Description
            refLinePay.blng__Notes__c = 'Refund Line for Payment: ' + transactionParameter.getPayment().id;
           
           //Creates the Refund Line Payment
           insert refLinePay;      
           
           //Once the Refund Line Payment associated record has been created, the status in the Refund can be updated to Posted
           refund1.blng__Status__c = 'Posted';
           
           //Update the Refund, so it's status is changed from Draft to Posted and this will also update its amount and the Refund Line Payment status
           update refund1;      
        }
        
       //If the result of the Refund is NOT successful, create an Error Log record in the associated payment record
        else
        {

           blng__ErrorLog__c errorlog = new blng__ErrorLog__c();
           errorlog.blng__ErrorCode__c = transResults.get('key1').getResponseStatus();
           errorlog.blng__ErrorName__c = 'Refund Failure: ' + payment.blng__GatewayID__c;
           errorlog.Name = 'Refund - ' + transResults.get('key1').getResponseStatus();
           errorlog.blng__ReferenceId__c = payment.blng__PaymentDescription__c;
           errorlog.blng__Account__c = acc.id;
           errorlog.blng__Summary__c = transResults.get('key1').getResponseMessage();
           errorlog.blng__FullErrorLog__c = DebugStringResult;
           errorlog.blng__ErrorOrigin__c = 'Ezidebit';
           errorlog.blng__Transaction__c =  transactionInstance.id;
           errorlog.blng__Payment__c = payment.id;
           
           insert errorlog;           
           
        }                      
        
        //End Logic here
        // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Record submited successfully'));
       PageReference pageRef = new PageReference('/'+paymentId);
        pageRef.setRedirect(true);
       return pageRef; //Returns to the case page
       }
       //end If to check the balance
       
       else
       {
            //First validation: the Balance is either zero or greater than the total amount in the payment
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'The Payment Balance to be refunded must be greater than zero and less or equal than the Payment Amount - Click Cancel to go back to the payment record and use the Allocations button to adjust the Payment balance');
            ApexPages.addMessage(myMsg);
            // PageReference pageRef = new PageReference('/'+paymentId);
             //pageRef.setRedirect(false);
           return null;
       }
       
    }
    
        //Function to return to the payment record if the operation is cancelled: the cancel button is clicked
        public PageReference CancelRefund() 
        {
           PageReference pageRef = new PageReference('/'+paymentId);
           pageRef.setRedirect(true);
           return pageRef; //Returns to the case page        
        }
}