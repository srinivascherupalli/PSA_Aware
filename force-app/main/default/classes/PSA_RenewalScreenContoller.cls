public without sharing class PSA_RenewalScreenContoller {

    // @AuraEnabled
    // public Static MemberWrapper fetchPaymentDetails(String invoiceId, String accountId) {
    //     MemberWrapper memberWrapper = new MemberWrapper();

    //     String query = 'SELECT ' + String.join(getObjectFields('blng__InvoiceLine__c'), ',') +
    //                     + ', blng__Product__r.Family' +
    //         		   ' FROM blng__InvoiceLine__c WHERE blng__Invoice__c =: invoiceId ';
    //     System.debug('q:- ' + query);
    //     memberWrapper.invLines = Database.query(query);

    //     String accQuery = 'SELECT Name, BillingCity, BillingState, BillingCountry, BillingStreet, BillingPostalCode' +
    //         			  ' FROM Account WHERE Id =: accountId ';
    //     memberWrapper.billingAccount = Database.query(accQuery);
    //     return memberWrapper;
    // }

    @AuraEnabled
    public static String getPremiumProduct(String accountId) {
        String result = null;
        List<Product2> preProduct = [Select Id From Product2 Where ProductCode='INS - PRE' And Isactive=true Limit 1];
        if(preProduct!=null && preProduct.size() > 0)
        {
            string productId = preProduct[0].Id;
            list<SBQQ__ProductOption__c> pos = [Select Id,Name,SBQQ__OptionalSKU__c, SBQQ__ProductName__c,SBQQ__UnitPrice__c,SBQQ__ProductCode__c From SBQQ__ProductOption__c Where SBQQ__ConfiguredSKU__c=:productId];
            result = (pos != null && pos.size()>0)?JSON.serialize(pos):null;
        }
        return result;
    }

    @AuraEnabled
    public static String getPremiumListPrice(list<String> productNames){
        String result = null;        
        if(!productNames.isEmpty()){
            list <ListPrice__c> lp = [SELECT Name, Frequency__c, 
                                    ismember__c,
                                    isStudent__c,
                                    ListPrice__c,
                                    productcode__c, 
                                    aftertax__c,
                                    ActualPrice__c
                                  FROM ListPrice__c
                                  WHERE Name In :productNames ];
            if(!lp.isEmpty()){
                result = JSON.serialize(lp);
            }
        }
        return result;
    }

    @AuraEnabled
    public static String getPremiumBundleProduct(String accountId)
    {
        String result = null;
        list<PSAUtils.returnProductAura> reslist = new list<PSAUtils.returnProductAura>();
        list<Product2> bundleProduct = new list<Product2>();
        bundleProduct = [Select Id, Name, productcode From Product2 Where ProductCode='INS - PRE' And Isactive=true Limit 1];
        
        if(!bundleProduct.isEmpty()){
            
            String prodjson = '{"listprice": 0.00,"netprice": 0.00,"product":{"ProductCode":"' + bundleProduct[0].productcode + '","Id":"' + bundleProduct[0].Id + '","Name": "'+ bundleProduct[0].Name +'"}}';

            PSAUtils.returnProductAura prodStruct = (PSAUtils.returnProductAura) JSON.deserialize(prodjson, PSAUtils.returnProductAura.class);
            prodStruct.isBundle = true;
            prodStruct.configuredSKU = null;
            reslist.add(prodStruct);

            String productId = bundleProduct[0].Id;
            if(productId!=null){

                for(SBQQ__ProductOption__c pos : [Select Id,Name,SBQQ__OptionalSKU__c, SBQQ__ProductName__c,SBQQ__UnitPrice__c,SBQQ__ProductCode__c,SBQQ__Type__c From SBQQ__ProductOption__c Where SBQQ__ConfiguredSKU__c=:productId]){
                    PSAUtils.returnProductAura cons = new PSAUtils.returnProductAura();
                    cons.listprice = pos.SBQQ__UnitPrice__c;
                    cons.netprice = 0.00;
                    cons.isBundle = false;
                    cons.configuredSKU = productId;
                    cons.optionId = pos.Id;
                    cons.optionType = pos.SBQQ__Type__c;
                    Product2 p2 = new Product2();
                    p2.Id = pos.SBQQ__OptionalSKU__c;
                    p2.ProductCode = pos.SBQQ__ProductCode__c;
                    p2.Name = pos.SBQQ__ProductName__c;
                    cons.product = p2;
                    reslist.add(cons);
                }
            }
        
        }

        result = JSON.serialize(reslist);

        return result;
    }

    @AuraEnabled
    public static void createQuoteLines(string productsJSON, string quoteId, string paymentFrequency) 
    {
        system.debug('##### productsJSON ' + productsJSON);
        //string code = 'System.enqueueJob(new PaymentProcessQueueable(\'' + productsJSON + '\',\'' + quoteId + '\',\'' + paymentFrequency + '\',false));';
        string code = 'Database.executeBatch(new PaymentProcessQueueable(\'' + productsJSON + '\',\'' + quoteId + '\',\'' + paymentFrequency + '\',false));';
       	string encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
        PSAUtils.makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);
    }

    @AuraEnabled
    public static void addPremiumInsurance(String startDate, string quoteId, String paymentFrequency, Boolean parentOnly)
    {
        System.debug('##### paymentFrequency ' + paymentFrequency);

        Set<String> productCodes = new Set<String>();

        String prodJSON = PSA_MemberShipController.getPremiumBundleProduct(null, null);

        list<PSAUtils.returnProductAura> products = (list<PSAUtils.returnProductAura>) JSON.deserialize(prodJSON, list<PSAUtils.returnProductAura>.class);

        for (PSAUtils.returnProductAura rp: products){
            if(rp.isBundle)
                productCodes.add(rp.product.ProductCode);
        }

        Integer res = getPremiumQliOptionStatus(quoteId, JSON.serialize(productCodes));

        if(res <= 0){

            String code = 'Database.executeBatch(new PaymentProcessQueueable(\'' + startDate + '\',\'' + quoteId + '\',\'' + paymentFrequency + '\',\'' + String.valueOf(parentOnly) + '\',\'2\'));';

            System.debug('##### code ' + code);
            
            string encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
            PSAUtils.makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);
        }
    }

    @AuraEnabled
    public static Boolean deletePremiumInsurance(string quoteId) 
    {
        system.debug('##### deletePremiumInsurance Method:- ' + quoteId);
        Boolean response = true;
        try 
        {
            List<SBQQ__QuoteLine__c> deleteQuoteLineList = new List<SBQQ__QuoteLine__c>();
            List<String> targetedProductCodes = new List<String>();
            String prodJSON = PSA_MemberShipController.getPremiumBundleProduct(null, null);
            list<PSAUtils.returnProductAura> products = (list<PSAUtils.returnProductAura>) JSON.deserialize(prodJSON, list<PSAUtils.returnProductAura>.class);
            
            for (PSAUtils.returnProductAura rp: products){
                targetedProductCodes.add(rp.product.ProductCode);              
            }

            List<SBQQ__QuoteLine__c> quoteLineList =[Select Id,SBQQ__ProductCode__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteId And SBQQ__ProductCode__c IN : targetedProductCodes] ;
            if(!quoteLineList.isEmpty())
            {                
                delete quoteLineList;
            }
                            
        } 
        catch (Exception ex) 
        {
            response = false;
            system.debug('##### deletePremiumInsurance Method:Failed ' + ex.getMessage());            
        }

        return response;
        
    }    

    @AuraEnabled
    public static Date getPremiumInsuranceStartDate(string quoteId) 
    {
        system.debug('##### getPremiumInsuranceStartDate Method:- ' + quoteId);
        List<SBQQ__QuoteLine__c> quoteLineList =[Select Id, SBQQ__StartDate__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteId And SBQQ__ProductCode__c='INS - PRE'] ;
        if(!quoteLineList.isEmpty())
            return quoteLineList[0].SBQQ__StartDate__c;
        else
            return null;
    }

    @AuraEnabled
    public static String createPremiumQLIOptions(String startDate, string quoteId, string parentId)
    {
        system.debug('##### parentId ' + parentId);
        //string code = 'System.enqueueJob(new PaymentProcessQueueable(\'' + productsJSON + '\',\'' + quoteId + '\',\'' + paymentFrequency + '\',false));';
        Set<String> productCodes = new Set<String>();

        String prodJSON = PSA_MemberShipController.getPremiumBundleProduct(null, null);

        list<PSAUtils.returnProductAura> products = (list<PSAUtils.returnProductAura>) JSON.deserialize(prodJSON, list<PSAUtils.returnProductAura>.class);

        for (PSAUtils.returnProductAura rp: products){
            if(!rp.isBundle)
                productCodes.add(rp.product.ProductCode);
        }

        Integer res = getPremiumQliOptionStatus(quoteId, JSON.serialize(productCodes));

        if(res <= 0){

            String code = 'Database.executeBatch(new PaymentProcessQueueable(\'' + startDate + '\',\'' + quoteId + '\',\'' + parentId + '\',\'false\',\'3\'));';
            String encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
            PSAUtils.makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);
        }

        return JSON.serialize(productCodes);

    }

    @AuraEnabled
    public static list<SBQQ__QuoteLine__c> fetchQuoteLines(String quoteId)
    {
        System.debug('##### fetchQuoteLines ' + quoteId);

        list<SBQQ__QuoteLine__c> qliRecList = new list<SBQQ__QuoteLine__c>();

        qliRecList = [Select Id, SBQQ__ProductName__c, SBQQ__Number__c, SBQQ__ProductCode__c, SBQQ__BillingFrequency__c, blng__BillableUnitPrice__c From SBQQ__QuoteLine__c Where SBQQ__Quote__c = :quoteId order by SBQQ__Number__c desc];

        return qliRecList;
    }

    @AuraEnabled
    public static Integer getPremiumQliOptionStatus(string quoteId, string optionsStr)
    {
        System.debug('##### optionsStr ' + optionsStr);
        Set<String> prodCodes = new Set<String>();
        if(!String.isBlank(optionsStr)){
            prodCodes = (Set<String>) JSON.deserialize(optionsStr, Set<String>.class);
        }

        list<SBQQ__QuoteLine__c> qliRecList = new list<SBQQ__QuoteLine__c>();

        System.debug('##### Query params ' + quoteId);
        System.debug('##### Query params ' + prodCodes);

        qliRecList = [Select Id From SBQQ__QuoteLine__c Where SBQQ__Quote__c = :quoteId And SBQQ__ProductCode__c In :prodCodes];

        return qliRecList.size();
    }

    @AuraEnabled
    public static String getQuoteLinesPremiumParent(string quoteId) 
    {
        system.debug('##### getQuoteLinesCompleteionFlag Method:- ' + quoteId);
        List<SBQQ__QuoteLine__c> quoteLineList =[Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteId And SBQQ__ProductCode__c='INS - PRE'] ;
        if(!quoteLineList.isEmpty())
            return quoteLineList[0].Id;
        else
            return null;
    }
    
    @AuraEnabled
    public static boolean getQuoteLinesCompleteionFlag(string quoteId) 
    {
        system.debug('##### getQuoteLinesCompleteionFlag Method:- ' + quoteId);
        List<SBQQ__QuoteLine__c> quoteLineList =[Select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteId] ;
        if(!quoteLineList.isEmpty())
            return true;       
        else
            return false;
    }

    @AuraEnabled
    public Static MemberWrapper fetchPaymentDetails(String invoiceId) {
        MemberWrapper memberWrapper = new MemberWrapper();

        String query = 'SELECT ' + String.join(getObjectFields('blng__InvoiceLine__c'), ',') +
                        + ', blng__Product__r.Family, blng__BillingFrequency__c, blng__Invoice__r.blng__Account__c,blng__Invoice__r.blng__TaxAmount__c, blng__Invoice__r.blng__Subtotal__c, blng__Invoice__r.blng__TotalAmount__c, blng__Invoice__r.blng__Order__r.TotalAmount ' +
            		   ' FROM blng__InvoiceLine__c WHERE blng__Invoice__c =: invoiceId ';
        System.debug('q:- ' + query);
        memberWrapper.invLines = Database.query(query);

        // String accQuery = 'SELECT Name, BillingCity, BillingState, BillingCountry, BillingStreet, BillingPostalCode' +
        //     			  ' FROM Account WHERE Id =: accountId ';
        // memberWrapper.billingAccount = Database.query(accQuery);
        return memberWrapper;
       
    }

    @AuraEnabled
    public Static List<SBQQ__QuoteLine__c> fetchPaymentDetailsForQuote(String quoteId) {
        //MemberWrapper memberWrapper = new MemberWrapper();

        String query = 'SELECT SBQQ__Quantity__c, SBQQ__ProductName__c, SBQQ__Product__r.productcode, SBQQ__ListPrice__c, SBQQ__ListTotal__c, SBQQ__NetTotal__c, SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__Quote__r.SBQQ__Account__r.PersonMailingAddress' 
                        + ', SBQQ__ProductFamily__c, SBQQ__BillingFrequency__c, SBQQ__Quote__r.SBQQ__Account__c, SBQQ__Quote__r.SBQQ__ListAmount__c, SBQQ__Quote__r.SBQQ__RegularAmount__c, SBQQ__Quote__r.SBQQ__TotalCustomerDiscountAmount__c ' +
            		   ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId ';
        System.debug('q:- ' + query);
        List<SBQQ__QuoteLine__c> response = Database.query(query);

        return response;
       
    }

    @AuraEnabled
    public static PSAUtils.PaymentResponse CheckPaymentProcessByQuoteIdForRenewal(String quoteId)
    {        
        map<string, object> payload = PSAUtils.CheckPaymentProcessByQuoteId(quoteId);
        
        if (payload != null)
        {
            PSAUtils.PaymentResponse pResponse = (PSAUtils.PaymentResponse)JSON.deserialize(JSON.serialize(payload.get('response')), PSAUtils.PaymentResponse.class);           
            return pResponse;
        }
        else
            return null;
    }

    @AuraEnabled
    public static Boolean getQuoteStatus(String invoiceId) {
        if(String.isBlank(invoiceId)) return null;

        blng__Invoice__c inv=[select id, blng__Order__r.SBQQ__Quote__r.SBQQ__Status__c from blng__Invoice__c where Id=: invoiceId];

        if(inv.blng__Order__r.SBQQ__Quote__r.SBQQ__Status__c == 'Draft')
        {
            return true;
        }

        return null;
    }

    @AuraEnabled
    public static string getQuoteStatusByQuoteId(String quoteId) {
        if(String.isBlank(quoteId)) return null;

        List<SBQQ__Quote__c> quotes =[select id, SBQQ__Status__c from SBQQ__Quote__c where Id=: quoteId];

        if(quotes!= null && quotes.size() > 0)
        {
            
            return quotes[0].SBQQ__Status__c;
            
        }
        
        return null;
    }

    @AuraEnabled
    public static string getInvoiceStatus(String invoiceId) {        
		
        system.debug('invoiceId --->>>'+invoiceId);
        
        if(String.isBlank(invoiceId)) return null;

        string status;
        blng__Invoice__c inv=[select id, blng__InvoiceStatus__c, blng__PaymentStatus__c from blng__Invoice__c where Id=: invoiceId];
        
        if(inv.blng__InvoiceStatus__c == 'Posted' && (inv.blng__PaymentStatus__c == 'Partially Paid'  || inv.blng__PaymentStatus__c == 'Unpaid'))
        {
            status =  'Posted';
        }
        else if (inv.blng__InvoiceStatus__c == 'Draft' && (inv.blng__PaymentStatus__c == 'Partially Paid'  || inv.blng__PaymentStatus__c == 'Unpaid'))
        {
            status =  'Draft';
        }
        else {
            status =  'Other';
        }        
        
        return status;
    }

    @AuraEnabled
    public static Boolean postInvoice(String invoiceId) {
        
        if(String.isBlank(invoiceId)) return false;

        if (UserInfo.getUserType() != 'Guest')
        {
            blng__Invoice__c inv=[select id, blng__InvoiceStatus__c,blng__Notes__c,blng__PaymentStatus__c from blng__Invoice__c where Id=: invoiceId];
    
            if (inv.blng__InvoiceStatus__c == 'Draft' && (Test.isRunningTest() || inv.blng__PaymentStatus__c == 'Partially Paid'  || inv.blng__PaymentStatus__c == 'Unpaid'))
            {            
                inv.blng__InvoiceStatus__c='Posted';
                inv.blng__Notes__c = 'Invoice has been accepted by external user';
                update inv;
    
                return true;
            }
            return false;
        }
        else
        {
            HttpResponse resp = PSAUtils.makeCallout('GET', 'query/?q=SELECT+id+FROM+blng__Invoice__c+WHERE+Id=\'' + invoiceId + '\'+AND+blng__InvoiceStatus__c=\'Draft\'+AND+blng__PaymentStatus__c+IN+(\'Partially+Paid\',\'Unpaid\')', null);
            map<string, Object> respObj = (map<string, Object>)JSON.deserializeUntyped(resp.getBody());
            integer recCount = (integer)respObj.get('totalSize');
            if (recCount == 1)
            {
                string body = '{"blng__InvoiceStatus__c":"Posted","blng__Notes__c":"Invoice has been accepted by external user"}';
                HttpResponse updResp = PSAUtils.makeCallout('PATCH', 'sobjects/blng__Invoice__c/' + invoiceId, body);
                return (updResp.getStatusCode() / 200 == 1);
            }
            else
                return false;
        }
    }   
    
    // Method to enable an authenticated user to do process payment for a guest user
    // This method will push the payment details to an apex queueable using execute anonymous
    // with the help of tooling api, as an authenticated user
   /* private static void pushPaymentDetailsToQueue(String paymentdetails, String invoiceId)
    {
        // Code for execute anonymous
        string code = 'System.enqueueJob(new PaymentProcessQueueable(\'' + paymentdetails + '\',\'' + invoiceId + '\'));';
        string encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
        PSAUtils.makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);
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
    }*/
    
    // Method to check if the payment process has been completed for a guest user
    @AuraEnabled
    public static PSAUtils.PaymentResponse CheckPaymentProcess(String invoiceId)
    {
        /*blng__Invoice__c invoice = [select Name,GuestUserPaymentResponse__c from blng__Invoice__c where Id = :invoiceId];
        system.debug('#### Name ' + invoice.Name);
        if (!String.isBlank(invoice.GuestUserPaymentResponse__c))
        {
            system.debug('##### Payload ' + invoice.GuestUserPaymentResponse__c);
            // If completed, send the response back to lightning page and clear the response from invoice record
            PSAUtils.PaymentResponse payResponse = (PSAUtils.PaymentResponse)JSON.deserialize(invoice.GuestUserPaymentResponse__c, PSAUtils.PaymentResponse.class);
            invoice.GuestUserPaymentResponse__c = null;
            update invoice;
            
            return payResponse;
        }
        else
        {
            system.debug('#### No payload');
            return null;
        }*/
        
        map<string, object> payload = PSAUtils.CheckPaymentProcess(invoiceId);
        
        if (payload != null)
        {
            PSAUtils.PaymentResponse pResponse = (PSAUtils.PaymentResponse)JSON.deserialize(JSON.serialize(payload.get('response')), PSAUtils.PaymentResponse.class);           
            return pResponse;
        }
        else
            return null;
    }

    @AuraEnabled
    public static PSAUtils.PaymentResponse CheckPaymentProcessByQuoteId(String quoteId)
    {        
        map<string, object> payload = PSAUtils.CheckPaymentProcessByQuoteId(quoteId);
        
        if (payload != null)
        {
            PSAUtils.PaymentResponse pResponse = (PSAUtils.PaymentResponse)JSON.deserialize(JSON.serialize(payload.get('response')), PSAUtils.PaymentResponse.class);           
            return pResponse;
        }
        else
            return null;
    }

    @AuraEnabled
    public static void createRenewalOrder(string quoteId)
    {
         string code = 'System.enqueueJob(new PaymentProcessQueueable(\'' + quoteId + '\'));';
       	 string encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
         PSAUtils.makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);  
         
    }

    @AuraEnabled
    public static void createRenewalOrderForRenew(string quoteId)
    {
         string code = 'System.enqueueJob(new PaymentProcessQueueable(\'' + quoteId + '\'));';
       	 string encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
         PSAUtils.makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);  
         
    }

    @AuraEnabled
    public static string getOrderId(string quoteId) 
    {
       //code to trigger contract from order
       	List<Order> orderList = [Select Id, SBQQ__Contracted__c, blng__BillNow__c, Status From Order where SBQQ__Quote__r.Id=: quoteId and Status='Activated'];
        if(!orderList.isEmpty())
       	{
           Order updateOrder = orderList[0];
           /*updateOrder.SBQQ__Contracted__c = true;
           update updateOrder;       
            
           return updateOrder.Id;*/
            
          	string body = '{"SBQQ__Contracted__c":true}';
         	PSAUtils.makeCallout('PATCH', 'sobjects/Order/' + updateOrder.Id, body);
            return updateOrder.Id;
       	} 
        else
            return null;
        
    }

    @AuraEnabled
    public static string getInvoiceId(string orderId, boolean optOutforRenewal, boolean isStudentPackage, string sessionId) {

         //code to generate invoice from order and check if contract has been generated
         try
         { 
            List<Contract> contractList = [Select AccountId,SBQQ__Order__c, Status,Auto_Renew__c From Contract where SBQQ__Order__c=: orderId ];
            if( contractList.size() > 0)
            {
               if (!isStudentPackage)
               {
                   Order updateOrderforInvoice  = [Select Id, SBQQ__Contracted__c, blng__BillNow__c, Status From Order where Id=: orderId];            
                   /*updateOrderforInvoice.blng__BillNow__c = true;
                   update updateOrderforInvoice;*/
                    System.debug('updateOrderforInvoice >> '+ JSON.serialize(updateOrderforInvoice));
                    string body = '{"blng__BillNow__c":true}';
                    PSAUtils.makeCallout('PATCH', 'sobjects/Order/' + orderId, body);
       
                   List<blng__Invoice__c> invoiceList = [select id, blng__InvoiceStatus__c, blng__PaymentStatus__c from blng__Invoice__c where blng__Order__c=: orderId ];
                   System.debug('invoiceList >> '+ JSON.serialize(invoiceList));
                   if(invoiceList.size() > 0)
                   {
                       if (invoiceList[0].blng__InvoiceStatus__c == 'Draft' && (Test.isRunningTest() || invoiceList[0].blng__PaymentStatus__c == 'Partially Paid'  || invoiceList[0].blng__PaymentStatus__c == 'Unpaid'))
                       { 
                           blng__Invoice__c updateInvoice =  invoiceList[0];          
                           /*updateInvoice.blng__InvoiceStatus__c='Posted';
                           updateInvoice.blng__Notes__c = 'Invoice has been posted  by membership external user';
                           update updateInvoice;*/
                           
                            body = '{"blng__InvoiceStatus__c":"Posted","blng__Notes__c":"Invoice has been posted  by membership external user"}';
                            PSAUtils.makeCallout('PATCH', 'sobjects/blng__Invoice__c/' + updateInvoice.Id, body);
                       
                            //Activate the contract and update  the contract for auto renewal (opt out yes or no based on user input)
                            Contract cont =  contractList[0];
                            cont.Status = 'Activated';
                            cont.Auto_Renew__c = optOutforRenewal;
                            update cont;                        
               
                           return updateInvoice.Id;
                       }
                   }
               }
               else
               {
                    //Activate the contract and update  the contract for auto renewal (opt out yes or no based on user input)
                    Contract cont =  contractList[0];
                    cont.Status = 'Activated';
                    cont.Auto_Renew__c = !optOutforRenewal;
                    update cont;

                	Account acc = [select Id from Account where Id = :contractList[0].AccountId];
                	acc.Signed_Up__c = true;
                	update acc;
                
                	Opportunity opp =	[Select Id from Opportunity where AccountId=:acc.Id and Sign_Up_Session_Id__c = :sessionId]; 
                	opp.Is_Abandoned__c = false;
                	update opp; 
                   
                   return contractList[0].Id;
               }
            }
           
            return null;

         }
         catch(exception e) {
            return e.getmessage();        
        }         

    }



    @AuraEnabled
    public static void updatePaymentWithInvoiceId(string quoteId, string invoiceId) {
 
        string code = 'System.enqueueJob(new PaymentProcessQueueable(\'' + quoteId + '\',\'' + invoiceId + '\',4));';
        string encodedCode = EncodingUtil.urlEncode(code, 'UTF-8');
        PSAUtils.makeCallout('GET', 'tooling/executeAnonymous/?anonymousBody=' + encodedCode, null);
        system.debug('##### successfully pushed Payment update payload to queue for asych processing');  

    }

    @AuraEnabled
    public static PSAUtils.PaymentResponse ProcessPayment(String paymentdetails, String invoiceId) {
        /*system.debug(invoiceId+ '  jsonnnn ' + paymentdetails);
		//paymentdetails = '{"accountId":"0019D00000EiaewQAB","gatewayId":"a649D00000023yXQAQ","amount":10,"paymentMethod":{"firstName":"Muneer Ahmed","lastName":"Shaik","email":"mas@sf.com","saveForFuture":false,"autoPay":false,"paymentType":"Credit Card","address":{"addressLine1":"Address 1","addressLine2":"Address 2","city":"SF","state":"CA","country":"United States","postalCode":"41111"},"cardPaymentMethod":{"cardHolderName":"Muneer Ahmed Shaik","cardType":"Visa","cardNumber":"4111111111111111","cvv":"111","expiryMonth":"4","expiryYear":"2022"}}}';
        //paymentdetails = '{"accountId":"0019D00000EiaewQAB","gatewayId":"a649D00000023yXQAQ","amount":9,"paymentMethod":{"firstName":"Muneer Ahmed","lastName":"Shaik","email":"mas@sf.com","saveForFuture":false,"autoPay":false,"paymentType":"Credit Card","address":{"addressLine1":"Address 1","addressLine2":"Address 2","city":"SF","state":"CA","country":"Australia","postalCode":"2217"},"cardPaymentMethod":{"cardHolderName":"Muneer Ahmed Shaik","cardType":"Visa","cardNumber":"4987654321098769","cvv":"123","expiryMonth":"5","expiryYear":"2021"}}}';

        //Vanita temp code to change the decimal to whole number, comment out after testing
        Map<String, Object> fieldMap = (Map<String, Object>)JSON.deserializeUntyped(paymentdetails);
        Object amountWithD =fieldMap.get('amount');

        fieldMap.put('amount',Math.floor((Decimal)amountWithD));

        paymentdetails = JSON.serialize(fieldMap);
        System.debug('ps:-' + paymentdetails);
        //temp code ends here , comment out after testing
        //
        if (UserInfo.getUserType() != 'Guest')
            return ProcessPaymentInternal(paymentdetails, invoiceId);
        else
        {
            pushPaymentDetailsToQueue(paymentdetails, invoiceId);
            return null;
        }*/
        return PSAUtils.ProcessPayment(paymentdetails,invoiceId);
    }

    @AuraEnabled
    public static PSAUtils.PaymentResponse ProcessPaymentForQuoteRenewal(String paymentdetails, String quoteId) {
        return PSAUtils.ProcessPaymentForQuote(paymentdetails,quoteId);
    }

    @AuraEnabled
    public static list<blng__InvoiceLine__c> getInv(String IID) {
        /*return [SELECT ID, blng__Invoice__r.blng__Account__r.Name, blng__Balance__c, blng__Product__r.Name , blng__StartDate__c
                FROM blng__InvoiceLine__c
                WHERE blng__Invoice__c=:IID and blng__Balance__c>0];*/
        return PSAUtils.getInv(IID);
    }

    //Ezidebit record details
    @AuraEnabled
    public static List<ChargentBase__Gateway__c> fetchGateways() {
        /*return [
                Select
                    Id,
                    Name,
                    RecordType.Name,
                    ChargentBase__Use_Tokenization__c,
                    ChargentBase__Available_Card_Types__c
                From ChargentBase__Gateway__c
                Where ChargentBase__Active__c = true AND RecordType.Name='Ezidebit'
                AND ChargentBase__Active__c = true
        ];*/
        return PSAUtils.fetchGateways();
    }

    //Billing Payment Gateway > pass the chargent Ezidebit Gateway id (which is chargent base Gateway object record)
    @AuraEnabled
    public static List<blng__PaymentGateway__c> fetchBillingPaymentGateway(Id gatewayId) {
        //return [Select Id, Name From blng__PaymentGateway__c Where blng__Active__c = true AND blng__GatewayType__c='Chargent Gateway' AND ChrgntBllng__Chargent_Gateway__c =: gatewayId ];
    	return PSAUtils.fetchBillingPaymentGateway(gatewayId);
    }

    public static List<String> getObjectFields(String objectName) {
		Map <String, Schema.SObjectField> fieldMap  = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		List<String> fields = new List<String>();
		for(Schema.SObjectField f : fieldMap.values()){
			DescribeFieldResult dfr = f.getDescribe();
			String fName = dfr.getName();
			if(dfr.isAccessible()){
				fields.add(fName);
			}
		}

		return fields;
	}
    
    /*public class PaymentResponse {
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
    }*/

    public class MemberWrapper {
        @AuraEnabled public List<blng__InvoiceLine__c> invLines { get; set; }
        @AuraEnabled public Account billingAccount { get; set; }
    }

    public class UserWrapper {
        @AuraEnabled public String email;
        @AuraEnabled public String password;
        @AuraEnabled public String title;
        @AuraEnabled public String firstnam;
        @AuraEnabled public String lastname;
        @AuraEnabled public String gender;
        @AuraEnabled public Date dobdate;
        @AuraEnabled public String primaryEmail;
        @AuraEnabled public String country;
        @AuraEnabled public String phone;
        @AuraEnabled public String address1;
        @AuraEnabled public String address2;
        @AuraEnabled public String city;
        @AuraEnabled public String postalCode;
        @AuraEnabled public String state;
        @AuraEnabled public String role;
        @AuraEnabled public Boolean sameAsAcountEmail;
        @AuraEnabled public Integer yrofqualification;
        @AuraEnabled public String AHPRA;
        @AuraEnabled public String oversearegistration;
        @AuraEnabled public String hoursworkedperweek;
        @AuraEnabled public Integer yrofgraduation;
        @AuraEnabled public String studentnumber;
    }
}