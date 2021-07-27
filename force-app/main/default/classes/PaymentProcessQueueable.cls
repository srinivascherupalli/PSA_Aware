public without sharing class PaymentProcessQueueable implements Queueable,Database.AllowsCallouts, Database.Batchable<sObject>
{
    private blng__Invoice__c invoice;
    private string paymentDetails;
    private list<PSAUtils.returnProductAura> products;
    private string productName;
    private ID accountId;
    private string sessionId;
    private string quoteId;
    private string givenQuoteId;
    private string givenInvoiceId;
    private boolean isPaymentProcess;
    private boolean isPaymentProcessForQuote;
    private integer methodIndex;
    private String paramX;
    private Date startDate;
    private Boolean isparent;
    
	public PaymentProcessQueueable(string paymentDetails, string invoiceId)
    {
        this.paymentDetails = paymentDetails;
        invoice = [select Id from blng__Invoice__c where Id = :invoiceId];
        isPaymentProcess = true;
        isPaymentProcessForQuote = false;
    }

    public PaymentProcessQueueable(string paymentDetails, string qtId, Boolean isPaymentForQuote)
    {
        this.paymentDetails = paymentDetails;
        system.debug('######### quoteId ' + qtId);
        this.givenQuoteId = qtId;
        isPaymentProcess = true;
        isPaymentProcessForQuote = isPaymentForQuote;
    }

    public PaymentProcessQueueable(string qtId, string invoiceId, Integer mthdIndex)
    {
        system.debug('###### adding invoice to Payment.this.givenQuoteId: '+this.givenQuoteId + ' this.givenInvoiceId: '+givenInvoiceId+ ' ,mthdIndex: '+mthdIndex );
        this.givenInvoiceId = invoiceId;
        this.givenQuoteId = qtId;
        this.isPaymentProcess = false;
        this.methodIndex = mthdIndex;
    }
    
    public PaymentProcessQueueable(string qtId)
    {
        Id objId = qtId;
        Schema.SObjectType sobjectType = objId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        if(sobjectName.equalsIgnoreCase('Contract')){
            paramX = qtId; // Store contractId
            isPaymentProcess = false;
            methodIndex = 5;
        }
        else{
            quoteId = qtId;
            isPaymentProcess = false;
            methodIndex = 3;
        }
    }
    
    public PaymentProcessQueueable(string prodName, string accId, string sessId)
    {
        //system.debug('######### productJSON ' + productJSON);
        //products = (list<PSAUtils.returnProductAura>)JSON.deserialize(productJSON, list<PSAUtils.returnProductAura>.class);
        productName = prodName;
        accountId = accId;
        sessionId = sessId;
        isPaymentProcess = false;
        methodIndex = 1;
    }
    
     
    public PaymentProcessQueueable(string productJSON, string qtId, string payFrequency, boolean isPayProcess)
    {
        system.debug('######### productJSON ' + productJSON);
        products = (list<PSAUtils.returnProductAura>)JSON.deserialize(productJSON, list<PSAUtils.returnProductAura>.class);
		quoteId = qtId;
        isPaymentProcess = isPayProcess;
        paramX = payFrequency;
    }

    public PaymentProcessQueueable(String sDate, string qtId, string param1,String parent, String idx)
    {
        startDate = (sDate!=null)?Date.valueOf(sDate):null;
		quoteId = qtId;
        paramX = param1; //if idx=3, this is the qli parent id else payment freq
        isparent = Boolean.valueOf(parent);
        methodIndex = 2;
        if(idx=='3'){
            methodIndex = 3;
        }
    }
    
   public Database.QueryLocator start(Database.BatchableContext BC)
   {
      	return Database.getQueryLocator('select Id from SBQQ__Quote__c where Id=:quoteId');
   }
    
   public void execute(Database.BatchableContext BC, List<sObject> scope)
   {
       //PSA_MemberShipController.createOpportunity(productName, accountId, sessionId);
       if(methodIndex == 2){
            PSA_MemberShipController.addPremiumInsuranceInternal(startDate, quoteId, paramX, isparent);
       }
       else if(methodIndex == 3){
            PSA_MemberShipController.updatePremiumQlisInternal(quoteId, paramX);
       }
       else{
           PSA_MemberShipController.createQuoteLinesInternal(products, quoteId, paramX);
       }
   }    
    
    public void execute(QueueableContext context)
    {
        if (isPaymentProcess)
        {
            if(!isPaymentProcessForQuote)
            {
                PSAUtils.PaymentResponse resp = PSAUtils.ProcessPaymentInternal(this.paymentDetails,
                                                                                 invoice.Id);
                system.debug('##### Response ' + resp);
                Map<String, Object> fieldMap = (Map<String, Object>)JSON.deserializeUntyped(this.paymentDetails);
                
                map<string, object> mapResponse = new map<string, object>{
                                    'response' => resp,
                                    'accountId' => fieldMap.get('accountId')
                };
                    
                invoice.GuestUserPaymentResponse__c = JSON.serialize(mapResponse);
                update invoice;
                
                system.debug('##### Successfully updated opp with response ');
            }
            else 
            {
                PSAUtils.PaymentResponse resp = PSAUtils.ProcessPaymentInternalForQuote(this.paymentDetails,
                                                                                 this.givenQuoteId);
                system.debug('##### Response ' + resp);
                Map<String, Object> fieldMap = (Map<String, Object>)JSON.deserializeUntyped(this.paymentDetails);
                
                map<string, object> mapResponse = new map<string, object>{
                                    'response' => resp,
                                    'accountId' => fieldMap.get('accountId')
                };
                SBQQ__Quote__c q = new SBQQ__Quote__c();
                q.Id = this.givenQuoteId;
                q.GuestUserPaymentResponse__c = JSON.serialize(mapResponse);
                update q;
                //invoice.GuestUserPaymentResponse__c = JSON.serialize(mapResponse);
                //update invoice;
                
                system.debug('##### Successfully updated opp with response ');
            }
            
        }
        else
        {
            
                if (methodIndex == 1)
                {
                    PSA_MemberShipController.createOpportunity(productName, accountId, sessionId);
                }
                else if (methodIndex == 2){
                    PSA_MemberShipController.addPremiumInsuranceInternal(startDate, quoteId, paramX, isparent);
                }
                else if (methodIndex == 5){
                    PSA_MemberShipController.createAmendmentQuoteInternal(paramX);
                }
                else if(methodIndex == 4)
                {
                    system.debug('###### adding invoice to Payment.this.givenQuoteId: '+this.givenQuoteId + ' this.givenInvoiceId: '+givenInvoiceId );
                    List<blng__Payment__c> payments =[SELECT ID, Invoice_Line__c, blng__Invoice__c,InvoiceID__c,Quote__c FROM blng__Payment__c WHERE Quote__c= :this.givenQuoteId Order By CreatedDate Desc];
                    if(payments != null && payments.size() > 0)
                    {
                            blng__Payment__c payment = payments[0];

                            // if(string.isBlank(payment.blng__Invoice__c))
                            // {
                            //     payment.blng__Invoice__c=this.givenInvoiceId;    
                            // }                            
                            payment.InvoiceID__c=this.givenInvoiceId;
                            payment.Invoice_Line__c= !Test.isRunningTest() || PSA_RenewalScreenContollerTest.invLineDummy == null ? PSAUtils.getInv(this.givenInvoiceId)[0].id : PSA_RenewalScreenContollerTest.invLineDummy.Id; //by default link to the 1st invoiceline
                            update payment;
                    }
                }
                else
                {
                    PSA_MemberShipController.createOrderInternal(quoteId);
                }
            
            
        }
    }
   public void finish(Database.BatchableContext BC){
   }    
}