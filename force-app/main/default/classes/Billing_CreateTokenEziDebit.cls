public class Billing_CreateTokenEziDebit
{
  /**/
  //final static string Memstatus = 'Expired';      
    
    @InvocableMethod(label='CreateTokenEzidebit' description='CreateTokenEzidebit.')
    public static void ExpireAccounts(list<blng__PaymentMethod__c> paymentmethod) 
    {
        system.debug('qqqqqqq ' +paymentmethod[0].id);
        GenerateTokenEzi(paymentmethod[0].id);
    }
  
      @future(callout=true)
  public static void GenerateTokenEzi(String paymentmethodid)   
  {
        blng.TransactionParameter transactionParameter = new blng.TransactionParameter();
        map<string, blng.TransactionParameter> mapTrans = new map<string, blng.TransactionParameter>();
        
        blng__PaymentMethod__c paymentMethod =   [SELECT CustomCrCardNumber__c, blng__Account__c,blng__Active__c,blng__AutoPay__c,blng__BankAccountName__c,blng__BankAccountNumber__c,blng__BankAccountType__c,blng__BankName__c,blng__BankRoutingCode__c,blng__BillingAddress__c,blng__BillingCity__c,blng__BillingCompany__c,blng__BillingCountry__c,blng__BillingEmail__c,blng__BillingFax__c,blng__BillingFirstName__c,blng__BillingLastName__c,blng__BillingPhone__c,blng__BillingStateProvince__c,blng__BillingStreet__c,blng__BillingZipPostal__c,blng__CardBIN__c,blng__CardExpirationMonth__c,blng__CardExpirationYear__c,blng__CardLastFour__c,blng__CardNumber__c,blng__CardType__c,blng__CVV__c,blng__GatewayResponse__c,blng__GLRule__c,blng__GLTreatment__c,blng__LegalEntity__c,blng__Nameoncard__c,blng__NickName__c,blng__Notes__c,blng__PaymentGatewayToken__c,blng__PaymentGateway__c,blng__PaymentType__c,blng__StreetAddress2__c,Id,IsDeleted,Name FROM blng__PaymentMethod__c WHERE Id =: paymentmethodid];        

        //It can be updated to read the payment gateway id from the payment method above if different gateways are needed paymentMethod.blng__PaymentGateway__c or paymentMethod.blng__PaymentGateway__c.id
        blng__PaymentGateway__c gateway =  [SELECT blng__Active__c,blng__Default__c,blng__GatewayType__c,blng__Notes__c,ChrgntBllng__Chargent_Gateway__c,Id,IsDeleted,Name FROM blng__PaymentGateway__c WHERE Id = 'a5Y1s000000Il0AEAS'];

        //workaround as the apex anonymous can't pass an encrypted credit card field
        System.debug('card number before' + paymentMethod.blng__CardNumber__c);
        paymentMethod.blng__CardNumber__c = paymentMethod.CustomCrCardNumber__c;

        transactionParameter.setPaymentMethod(paymentMethod);
        
        transactionParameter.setGateWay(gateway);
        //transactionParameter.setAmount('100.00');
        //System.debug('card number1:' + transactionParameter.getCardNumber());
        //transactionParameter.setCardNumber('4987654321098769');
        //transactionParameter.setLastName('Test1151');
        //System.debug('card number2:' + transactionParameter.getCardNumber());
        //System.debug('getLastName:' + transactionParameter.getLastName());
      //  transactionParameter.setLastName('number2');
      //System.debug('getLastName:' + transactionParameter.getLastName());
        //System.debug('TransParam:' + transactionParameter);
        mapTrans.put('key1', transactionParameter);
        
                Map<String, blng.TransactionResult> transResults = ChrgntBllng.ChargentGatewayAPI.generateToken(mapTrans);
                
System.debug('transaction result:' + transResults.get('key1').getPaymentToken());

//System.debug('pay meth token1:' + paymentMethod.blng__PaymentGatewayToken__c);
//paymentMethod.CustomGatewayToken__c = transResults.get('key1').getPaymentToken();
//paymentMethod.blng__PaymentGatewayToken__c= transResults.get('key1').getPaymentToken();
//System.debug('pay meth token2:' + paymentMethod.blng__PaymentGatewayToken__c);
//update paymentMethod;
System.debug('pay meth token3:' + paymentMethod.blng__PaymentGatewayToken__c);

        if(transResults.get('key1').getPaymentToken()!= null)
        {
           //Since this is a future method the payment method can't be updated at the same time, so storing temporary the token in their parent Account
           account acc=[select id, AccCustomGatewayToken__c from account WHERE id=: paymentMethod.blng__Account__c];
           acc.AccCustomGatewayToken__c = transResults.get('key1').getPaymentToken();
           update acc;
           System.debug('Acc payment token: ' +acc.AccCustomGatewayToken__c);
         }       
        
        else
        {
           blng__ErrorLog__c errorlog = new blng__ErrorLog__c();
           errorlog.blng__ErrorCode__c = transResults.get('key1').getResponseStatus();
           errorlog.blng__ErrorName__c = 'Token Generation Failure';
           errorlog.Name = 'Token Generation Failure';
           //errorlog.blng__ReferenceId__c = payment.blng__PaymentDescription__c;
           errorlog.blng__Account__c = paymentMethod.blng__Account__c;
           //errorlog.blng__Summary__c = transResults.get('key1').getResponseMessage();
           errorlog.blng__FullErrorLog__c = transResults.get('key1').getResponseMessage();
           errorlog.blng__ErrorOrigin__c = 'Ezidebit';
           //errorlog.blng__Transaction__c =  transactionInstance.id;
           //errorlog.blng__Payment__c = payment.id;
           errorlog.blng__PaymentMethod__c = paymentMethod.id;
           
           insert errorlog;                   
           
           System.debug('inserted error log: ' +transResults.get('key1').getResponseMessage());
        }   

System.debug(transResults);
    //    System.debug('token:' + transResults.getPaymentToken());

       }

}