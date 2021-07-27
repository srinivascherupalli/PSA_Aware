public class PSAUtils 
{
    public class returnProductAura
    {
        @AuraEnabled public product2 product;
        @AuraEnabled public decimal actualprice;
        @AuraEnabled public decimal listprice;
        @AuraEnabled public decimal netprice;  //after tax
        @AuraEnabled public String inclusions;
        @AuraEnabled public String configuredSKU;
        @AuraEnabled public String optionId;
        @AuraEnabled public String optionType;
        @AuraEnabled public Boolean isBundle;
    }
    
    public class PaymentResponse {
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
    }
    
    public class MemberWrapper {
        @AuraEnabled public List<blng__InvoiceLine__c> invLines { get; set; }
        @AuraEnabled public Account billingAccount { get; set; }
    }    
    
    public static HttpResponse makeCallout(string method, string endpointUrl, string body)
    {
        HttpRequest req = new HttpRequest();
        
        if (method == 'PATCH')
        {
            method = 'POST';
            endpointUrl += '?_HttpMethod=PATCH';
        }
        
        req.setEndpoint('callout:GuestUserPayment/services/data/v50.0/' + endpointUrl);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');  
        req.setTimeout(60000);
        if (body != null)
            req.setBody(body);
		Http httpReq = new Http();
        return httpReq.send(req);       
    }
    
    public static PaymentResponse ProcessPayment(string paymentdetails, String invoiceId) {
		 Map<String, Object> fieldMap = (Map<String, Object>)JSON.deserializeUntyped(paymentdetails);
        system.debug(invoiceId+ '  jsonnnn ' + JSON.serialize(fieldMap));
		//paymentdetails = '{"accountId":"0019D00000EiaewQAB","gatewayId":"a649D00000023yXQAQ","amount":10,"paymentMethod":{"firstName":"Muneer Ahmed","lastName":"Shaik","email":"mas@sf.com","saveForFuture":false,"autoPay":false,"paymentType":"Credit Card","address":{"addressLine1":"Address 1","addressLine2":"Address 2","city":"SF","state":"CA","country":"United States","postalCode":"41111"},"cardPaymentMethod":{"cardHolderName":"Muneer Ahmed Shaik","cardType":"Visa","cardNumber":"4111111111111111","cvv":"111","expiryMonth":"4","expiryYear":"2022"}}}';
        //paymentdetails = '{"accountId":"0019D00000EiaewQAB","gatewayId":"a649D00000023yXQAQ","amount":9,"paymentMethod":{"firstName":"Muneer Ahmed","lastName":"Shaik","email":"mas@sf.com","saveForFuture":false,"autoPay":false,"paymentType":"Credit Card","address":{"addressLine1":"Address 1","addressLine2":"Address 2","city":"SF","state":"CA","country":"Australia","postalCode":"2217"},"cardPaymentMethod":{"cardHolderName":"Muneer Ahmed Shaik","cardType":"Visa","cardNumber":"4987654321098769","cvv":"123","expiryMonth":"5","expiryYear":"2021"}}}';

        //Vanita temp code to change the decimal to whole number, comment out after testing
        Object amountWithD =fieldMap.get('amount');

        fieldMap.put('amount',Math.floor((Decimal)amountWithD));

        paymentdetails = JSON.serialize(fieldMap);
        System.debug('ps:-' + paymentdetails);
        //temp code ends here , comment out after testing
        //
        //if (UserInfo.getUserType() != 'Guest')
        //    return ProcessPaymentInternal(paymentdetails, invoiceId);
        //else
        //{
            pushPaymentDetailsToQueue(paymentdetails, invoiceId);
            return null;
        //}
    }  

    public static PaymentResponse ProcessPaymentForQuote(string paymentdetails, String quoteId) {
        Map<String, Object> fieldMap = (Map<String, Object>)JSON.deserializeUntyped(paymentdetails);
       system.debug(quoteId+ '  Asif ' + JSON.serialize(fieldMap));

       Object amountWithD =fieldMap.get('amount');

       fieldMap.put('amount',Math.floor((Decimal)amountWithD));

       paymentdetails = JSON.serialize(fieldMap);
       System.debug('ps:-' + paymentdetails);
        pushPaymentDetailsToQueueForQuote(paymentdetails, quoteId);
        return null;
   }  


   private static void pushPaymentDetailsToQueueForQuote(String paymentdetails, String quoteId)
    {
        // Code for execute anonymous
        string code = 'System.enqueueJob(new PaymentProcessQueueable(\'' + paymentdetails + '\',\'' + quoteId + '\',true));';
        string encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
        makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);
        system.debug('##### successfully pushed payment payload to queue for asych processing');
    }

    private static void pushPaymentDetailsToQueue(String paymentdetails, String invoiceId)
    {
        // Code for execute anonymous
        string code = 'System.enqueueJob(new PaymentProcessQueueable(\'' + paymentdetails + '\',\'' + invoiceId + '\'));';
        string encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
        makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);
        system.debug('##### successfully pushed payment payload to queue for asych processing');
        /*HttpRequest req = new HttpRequest();
        // Use name credential to execute anonymous using tooling api
        req.setEndpoint('callout:GuestUserPayment/services/data/v36.0/tooling/executeAnonymous/?anonymousBody=' + encodedCode);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        
        Http httpReq = new Http();
        httpReq.send(req);*/
    }
	// Main method to process payment. This method will be called synchronously for authenticated user.
	// It will called asynchronously via queueable for a guest user
    public static PaymentResponse ProcessPaymentInternal(String paymentdetails, String invoiceId)
    {
        system.debug('##### paymentdetails '+ paymentdetails);
        string response=  Test.isRunningTest() ? JSON.serialize(PSA_RenewalScreenContollerTest.dummyPaymentRes) : blng.HostedPaymentPageTransactionAPI.chargeTransaction(paymentdetails);
        system.debug('responseCT ' + response);
        BlngResponse  br= (BlngResponse) System.JSON.deserialize(response, BlngResponse.class);
        system.debug('responseeeeee ' + br);

        PaymentResponse pResponse = new PaymentResponse();
        pResponse.isSuccess = false;
        try {
            if (br.isSuccess=='true') {
                blng__Payment__c payment=[SELECT ID, Invoice_Line__c, blng__Invoice__c,InvoiceID__c FROM blng__Payment__c WHERE Id=:br.salesforceResponse.paymentId];
                payment.InvoiceID__c=invoiceId;
                payment.Invoice_Line__c= !Test.isRunningTest() || PSA_RenewalScreenContollerTest.invLineDummy == null ? getInv(invoiceId)[0].id : PSA_RenewalScreenContollerTest.invLineDummy.Id; //by default link to the 1st invoiceline
                update payment;
                pResponse.isSuccess = true;
                pResponse.message = 'Payment made';
            }
            else {
                pResponse.message = 'Failed Payment';
                if(br.gatewayResponse != null) pResponse.message = br.gatewayResponse.responseMessage;
            }
        }
        catch (exception e) {
            pResponse.message = e.getMessage();
        }
        
        return pResponse;
    }
    
    public static PaymentResponse ProcessPaymentInternalForQuote(String paymentdetails, String quoteId)
    {
        system.debug('##### paymentdetails '+ paymentdetails);
        string response=  Test.isRunningTest() ? JSON.serialize(PSA_RenewalScreenContollerTest.dummyPaymentRes) : blng.HostedPaymentPageTransactionAPI.chargeTransaction(paymentdetails);
        system.debug('responseCT ' + response);
        BlngResponse  br= (BlngResponse) System.JSON.deserialize(response, BlngResponse.class);
        system.debug('responseeeeee ' + br);

        PaymentResponse pResponse = new PaymentResponse();
        pResponse.isSuccess = false;
        try {
            if (br.isSuccess=='true') {
                blng__Payment__c payment=[SELECT ID, Invoice_Line__c, blng__Invoice__c,InvoiceID__c FROM blng__Payment__c WHERE Id=:br.salesforceResponse.paymentId];
                payment.Quote__c=quoteId;
                update payment;
                pResponse.isSuccess = true;
                pResponse.message = 'Payment made';
            }
            else 
            {
                blng__Payment__c payment=[SELECT ID, Invoice_Line__c, blng__Invoice__c,InvoiceID__c FROM blng__Payment__c WHERE Id=:br.salesforceResponse.paymentId];
                payment.Quote__c=quoteId;
                update payment;
                pResponse.message = 'Failed Payment';
                if(br.gatewayResponse != null) pResponse.message = br.gatewayResponse.responseMessage;
            }
        }
        catch (exception e) {
            pResponse.message = e.getMessage();
        }
        
        return pResponse;
    } 
    
    public static list<blng__InvoiceLine__c> getInv(String invoiceId) {
        return [SELECT ID, blng__Invoice__r.blng__Account__r.Name, blng__Balance__c, blng__Product__r.Name , blng__StartDate__c
                FROM blng__InvoiceLine__c
                WHERE blng__Invoice__c=:invoiceId and blng__Balance__c>0];
    }    
    
    /*public static PaymentResponse CheckPaymentProcess(String invoiceId)
    {
        blng__Invoice__c invoice = [select Name,GuestUserPaymentResponse__c from blng__Invoice__c where Id = :invoiceId];
        system.debug('#### Name ' + invoice.Name);
        if (!String.isBlank(invoice.GuestUserPaymentResponse__c))
        {
            system.debug('##### Payload ' + invoice.GuestUserPaymentResponse__c);
            // If completed, send the response back to lightning page and clear the response from invoice record
            PaymentResponse payResponse = (PaymentResponse)JSON.deserialize(invoice.GuestUserPaymentResponse__c, PaymentResponse.class);
            invoice.GuestUserPaymentResponse__c = null;
            update invoice;
            
            return payResponse;
        }
        else
        {
            system.debug('#### No payload');
            return null;
        }
    }*/
    
    public static map<string, object> CheckPaymentProcess(String invoiceId)
    {
        blng__Invoice__c invoice = [select Name,GuestUserPaymentResponse__c from blng__Invoice__c where Id = :invoiceId];
        system.debug('#### Name ' + invoice.Name);
        if (!String.isBlank(invoice.GuestUserPaymentResponse__c))
        {
            system.debug('##### Payload ' + invoice.GuestUserPaymentResponse__c);
            // If completed, send the response back to lightning page and clear the response from invoice record
            map<string, object> payload = (map<string, object>)JSON.deserializeUntyped(invoice.GuestUserPaymentResponse__c);
            invoice.GuestUserPaymentResponse__c = null;
            update invoice;
           
            return payload;
        }
        else
        {
            system.debug('#### No payload');
            return null;
        }
    } 
    
    public static map<string, object> CheckPaymentProcessByQuoteId(String quoteId)
    {
        map<string, object> response = new map<string, object>();
        List<SBQQ__Quote__c> quoteRecords = [select Name,GuestUserPaymentResponse__c from SBQQ__Quote__c where Id = :quoteId];
        
        if(quoteRecords != null && !quoteRecords.isEmpty())
        {
            SBQQ__Quote__c quoteRecord = quoteRecords[0];
            if (!String.isBlank(quoteRecord.GuestUserPaymentResponse__c))
            {
                system.debug('##### Payload ' + quoteRecord.GuestUserPaymentResponse__c);
                // If completed, send the response back to lightning page and clear the response from invoice record
                map<string, object> payload = (map<string, object>)JSON.deserializeUntyped(quoteRecord.GuestUserPaymentResponse__c);

                if(payload.containsKey('response'))
                {
                    map<string, object> payloadResponse = (map<string, object>)payload.get('response');
                    if(payloadResponse.containsKey('isSuccess'))
                    {
                        Boolean statusRes = (Boolean)payloadResponse.get('isSuccess');
                        if(statusRes)
                        {
                            response = payload;
                        }
                    }                    
                }
                //quoteRecord.GuestUserPaymentResponse__c = null;
                //update invoice;
            }
        }

        return (response == null || response.isEmpty())  ? null : response;
        
    } 

     public static List<ChargentBase__Gateway__c> fetchGateways() {
        return [
                Select
                    Id,
                    Name,
                    RecordType.Name,
                    ChargentBase__Use_Tokenization__c,
                    ChargentBase__Available_Card_Types__c
                From ChargentBase__Gateway__c
                Where ChargentBase__Active__c = true AND RecordType.Name='Ezidebit'
                AND ChargentBase__Active__c = true
        ];
    }
    
    public static List<blng__PaymentGateway__c> fetchBillingPaymentGateway(Id gatewayId) {
        return [Select Id, Name From blng__PaymentGateway__c Where blng__Active__c = true AND blng__GatewayType__c='Chargent Gateway' AND ChrgntBllng__Chargent_Gateway__c =: gatewayId ];
    }   

    @future(callout = true)
    public static void changeProfile(string accountId){
        Id contactId = [select PersonContactId  FROM account where ID =: accountId].PersonContactId;
        User u=[select id from User where ContactId=:contactId];

        Profile p=[select id from profile where Name='Member Login User'];        

        string body = '{"ProfileId":"'+ p.Id +'"}';
        PSAUtils.makeCallout('PATCH', 'sobjects/User/' + u.Id, body);        
        
    }    
    
}