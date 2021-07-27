@isTest
public class PSA_RenewalScreenContollerTest 
{
    public static BlngResponse dummyPaymentRes = new BlngResponse();
    public static blng__InvoiceLine__c invLineDummy;
    
	 @isTest static void postInvoice()
     {
     	//Create admin users
     	List<User> guestUser = TestUtilClass.createUsers(1,'PSA Community Profile');
         Account acc = new Account(FirstName = 'Test', LastName='User');
         insert acc;
         blng__Invoice__c inv = new blng__Invoice__c(blng__InvoiceStatus__c = 'Draft', blng__Account__c = acc.Id);
         insert inv;
         
   		Test.startTest();
    
    	System.runAs(guestUser[0])
        {
			Test.setMock(HttpCalloutMock.class, new RenewalScreenCtrlHttpMock());
            PSA_RenewalScreenContoller.postInvoice(inv.id);
    	}
         
       	PSA_RenewalScreenContoller.postInvoice(inv.id);
        Test.stopTest();
     }
    
     @isTest static void processPayment()
     {
      	//Create admin users
     	List<User> guestUser = TestUtilClass.createUsers(1,'PSA Community Profile');
         Account acc = new Account(FirstName = 'Test', LastName='User');
         insert acc;
         blng__Invoice__c inv = new blng__Invoice__c(blng__InvoiceStatus__c = 'Draft', blng__Account__c = acc.Id);
         insert inv;
         
         blng__InvoiceLine__c invLine = new blng__InvoiceLine__c( blng__Invoice__c = inv.Id, blng__TotalAmount__c = 1000);
         insert invLine;
         
         blng__Payment__c payment = new blng__Payment__c(blng__Invoice__c = inv.Id, blng__Account__c = acc.Id, blng__Amount__c = 100);
         insert payment;
         
        dummyPaymentRes.isSuccess = 'true';
        dummyPaymentRes.salesforceResponse = new BlngResponse.salesforceResponse();
        dummyPaymentRes.salesforceResponse.paymentId = payment.Id;
         
         string paymentdetails = '{"accountId":"0019D00000EiaewQAB","gatewayId":"a649D00000023yXQAQ","amount":10,"paymentMethod":{"firstName":"Muneer Ahmed","lastName":"Shaik","email":"mas@sf.com","saveForFuture":false,"autoPay":false,"paymentType":"Credit Card","address":{"addressLine1":"Address 1","addressLine2":"Address 2","city":"SF","state":"CA","country":"United States","postalCode":"41111"},"cardPaymentMethod":{"cardHolderName":"Muneer Ahmed Shaik","cardType":"Visa","cardNumber":"4111111111111111","cvv":"111","expiryMonth":"4","expiryYear":"2022"}}}';

   		Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new RenewalScreenCtrlHttpMock());
        PSA_RenewalScreenContoller.ProcessPayment(paymentdetails, inv.Id);
         
        System.runAs(guestUser[0])
        {
            PSA_RenewalScreenContoller.ProcessPayment(paymentdetails, inv.Id);
    	}
         
         invLineDummy = invLine;
        PSA_RenewalScreenContoller.ProcessPayment(paymentdetails, inv.Id);
         dummyPaymentRes.isSuccess = 'false';
         PSA_RenewalScreenContoller.ProcessPayment(paymentdetails, inv.Id);
         
    
        Test.stopTest();        
     }
    
    @isTest static void CheckPaymentProcess()
    {
         Account acc = new Account(FirstName = 'Test', LastName='User');
         insert acc;
         blng__Invoice__c inv = new blng__Invoice__c(blng__InvoiceStatus__c = 'Draft', blng__Account__c = acc.Id);
         insert inv;   
        
        Test.startTest();
        PSA_RenewalScreenContoller.CheckPaymentProcess(inv.Id);
        
        map<string, object> mapPayload = new map<string, object>{
            'response' => new PSAUtils.PaymentResponse(),
            'accountId' => acc.Id
        };
        inv.GuestUserPaymentResponse__c = JSON.serialize(mapPayload);
        update inv;
        PSA_RenewalScreenContoller.CheckPaymentProcess(inv.Id);
        Test.stopTest();    
    }
    
    @isTest static void PaymentProcessQueueable()
    {
        string paymentdetails = '{"accountId":"0019D00000EiaewQAB","gatewayId":"a649D00000023yXQAQ","amount":10,"paymentMethod":{"firstName":"Muneer Ahmed","lastName":"Shaik","email":"mas@sf.com","saveForFuture":false,"autoPay":false,"paymentType":"Credit Card","address":{"addressLine1":"Address 1","addressLine2":"Address 2","city":"SF","state":"CA","country":"United States","postalCode":"41111"},"cardPaymentMethod":{"cardHolderName":"Muneer Ahmed Shaik","cardType":"Visa","cardNumber":"4111111111111111","cvv":"111","expiryMonth":"4","expiryYear":"2022"}}}';

         Account acc = new Account(FirstName = 'Test', LastName='User');
         insert acc;
         blng__Invoice__c inv = new blng__Invoice__c(blng__InvoiceStatus__c = 'Draft', blng__Account__c = acc.Id);
         insert inv;
         blng__InvoiceLine__c invLine = new blng__InvoiceLine__c( blng__Invoice__c = inv.Id, blng__TotalAmount__c = 1000);
         insert invLine;
         
         blng__Payment__c payment = new blng__Payment__c(blng__Invoice__c = inv.Id, blng__Account__c = acc.Id, blng__Amount__c = 100);
         insert payment;
        
        dummyPaymentRes.isSuccess = 'true';
        dummyPaymentRes.salesforceResponse = new BlngResponse.salesforceResponse();
        dummyPaymentRes.salesforceResponse.paymentId = payment.Id;
        
        Test.startTest();
        PaymentProcessQueueable payProcessor = new PaymentProcessQueueable(paymentdetails, inv.Id);
 		ID jobID = System.enqueueJob(payProcessor);
        Test.stopTest();              
    }
}