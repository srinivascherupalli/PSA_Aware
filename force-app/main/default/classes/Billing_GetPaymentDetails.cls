public class Billing_GetPaymentDetails
{
  /**/
    
    @InvocableMethod(label='GetPaymentDetails' description='GetPaymentDetails.')
    public static void ExpireAccounts(list<blng__PaymentTransaction__c> paymentTransaction) 
    {
        if (paymentTransaction.size() > 0)
        {
            for (blng__PaymentTransaction__c p : paymentTransaction)
            {
                system.debug('p.id: ' + p.id);
                GetPaymentDetails(p.id);
            }
        }   
    }
  
  
   @future(callout=true)
  public static void GetPaymentDetails(String paymentTransactionId)   
  {
  blng.TransactionParameter transactionParameter = new blng.TransactionParameter();
        map<string, blng.TransactionParameter> mapTrans = new map<string, blng.TransactionParameter>();
        
        blng__PaymentTransaction__c paymentTransaction =   [SELECT blng__Account__c,blng__Amount__c,blng__Authorization__c,blng__AVSResponseCode__c,blng__AVSZip__c,blng__BankAccountName__c,blng__BankAccountNumber__c,blng__BankAccountType__c,blng__BankName__c,blng__BankRoutingCode__c,blng__CardCodeResponse__c,blng__CardExpirationMonth__c,blng__CardExpirationYear__c,blng__CardType__c,blng__ExceptionMessage__c,blng__GatewayDate__c,blng__GatewayID__c,blng__GatewayRequest__c,blng__GatewayResponse__c,blng__GatewayStatus__c,blng__IsPaymentProcessedSuccessfully__c,blng__Notes__c,blng__PaymentGateway__c,blng__PaymentMethod__c,blng__PaymentRun__c,blng__ReasonCode__c,blng__RequestCreditCardNumber__c,blng__RequestInvoice__c,blng__RequestTransactionType__c,blng__RequestTypeOfPayment__c,blng__ResponseCode__c,blng__ResponseMessage__c,blng__ResponseStatus__c,blng__Response__c,blng__SourceTransactionId__c,blng__Status__c,blng__Transaction__c,blng__Type__c,Id,IsDeleted,Name FROM blng__PaymentTransaction__c WHERE Id =: paymentTransactionId]; 
      
        //blng__PaymentGateway__c gateway =  [SELECT id from blng__PaymentGateway__c where id = 'a5K0l000000zmF5EAI'];
        //To automatically retrieve the Gateway id from the Payment Transaction
        blng__PaymentGateway__c gateway =  [SELECT id from blng__PaymentGateway__c where id =: paymentTransaction.blng__PaymentGateway__c];

        transactionParameter.setTransaction(paymentTransaction);        
        transactionParameter.setGateWay(gateway);

        mapTrans.put('key1', transactionParameter);
        
        //Validation if the transaction gateway id field is null, do not call the API
        if (!String.isBlank(paymentTransaction.blng__GatewayID__c))
        {
            Map<String, blng.TransactionResult> transResults = EziDebitAPI.generatePaymentDetail(mapTrans); 

            System.debug('transaction result:' + transResults.get('key1').getResponseCodeMessage());
            System.debug('transaction  param bank fail reason:' + transactionParameter.getResponseValueByKey().get('BankFailedReason'));
            System.debug('transaction  param bank code:' + transactionParameter.getResponseValueByKey().get('BankReturnCode'));

            //paymentTransaction.blng__ResponseMessage__c = transactionParameter.getResponseValueByKey().get('BankFailedReason');
            //blng__ErrorLogs__r

            if(paymentTransaction.blng__ResponseStatus__c == 'Approved')
            {
               //Retrieve related Salesforce Payment Id for this transaction
               blng__Payment__c billingPayment = [select id from blng__Payment__c WHERE blng__Transaction__c =: transactionParameter.getTransaction().id];
               billingPayment.blng__GatewayID__c =  transactionParameter.getResponseValueByKey().get('PaymentID');
               billingPayment.blng__PaymentDescription__c = transactionParameter.getResponseValueByKey().get('PaymentReference');
               //System.debug('Email: ' + acc.PersonEmail);
               
               
               //Update related Billing Payment Record
               update billingPayment;               
            }
            else
            {
                blng__ErrorLog__c errorlog = new blng__ErrorLog__c();
                errorlog.blng__ErrorCode__c = transactionParameter.getResponseValueByKey().get('BankReturnCode');
                errorlog.blng__ErrorName__c = transactionParameter.getResponseValueByKey().get('BankFailedReason');
                errorlog.Name = transactionParameter.getResponseValueByKey().get('BankFailedReason');      
                errorlog.blng__ReferenceId__c = transactionParameter.getResponseValueByKey().get('PaymentReference');
                errorlog.blng__FullErrorLog__c = transactionParameter.getResponseValueByKey().get('PaymentID');
                errorlog.blng__ErrorOrigin__c = 'Ezidebit';
                errorlog.blng__Transaction__c =  transactionParameter.getTransaction().id;
                   
                //Retrieve email from the account related to the transaction
                account[] acc = [select id, PersonEmail from account WHERE id=: transactionParameter.getTransaction().blng__Account__c];
                if (acc.size() > 0)
                {
                    if(!String.isBlank(acc[0].PersonEmail))
                        errorlog.Email_Error_Log__c =  acc[0].PersonEmail;
                    else
                        errorlog.Email_Error_Log__c = 'administrator@psa.org.au.psa';
                //System.debug('Email: ' + acc.PersonEmail);
                }
                   
                //errorlog.Email_Error_Log__c = paymentTransaction.blng__Account__r.PersonContact.Email;
                //errorlog.Email_Error_Log__c = 'fortino.carbajal@theawaregroup.com.au';
                   
                //Insert new Billing Error Log record
                 insert errorlog;
            }    
        }
        else
        {
            blng__ErrorLog__c errorlog = new blng__ErrorLog__c();
            errorlog.blng__ErrorCode__c = 'Failed';
            errorlog.blng__ErrorName__c = 'Missing Response Gateway ID field';
            errorlog.blng__Transaction__c =  paymentTransaction.id;
            errorlog.Name =  'Missing Response Gateway ID field';
            errorlog.blng__FullErrorLog__c = 'Null or missing Response Gateway ID field in the Payment Transaction Record: ' + paymentTransaction.Name;
            //errorlog.Email_Error_Log__c = paymentTransaction.blng__Account__r.PersonContact.Email;
            //errorlog.Email_Error_Log__c = 'fortino.carbajal@theawaregroup.com.au';
            errorlog.Email_Error_Log__c = 'administrator@psa.org.au.psa';
            
            //Insert new Billing Error Log record
             insert errorlog;
        }


  }

}