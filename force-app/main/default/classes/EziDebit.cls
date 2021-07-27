public class EziDebit
{
    // 
    // ============================================================================
    // CONSTANT 
    // ============================================================================
        // EziDebit Endpoint URL Sandbox
        private static final String EZI_DEBIT_ENDPOINT_URL_SANDBOX = 'https://api.demo.ezidebit.com.au/v3-5/pci';

        // EziDebit Endpoint URL Production
        private static final String EZI_DEBIT_ENDPOINT_URL_PRODUCTION = '';

        private static final String ACCEPT = 'ACCEPT';
        private static final String REJECT = 'REJECT';
        private static final String PENDING = 'PENDING';
        private static final String SUCCESS = 'SUCCESS';
        private static final String FAILURE = 'FAILURE';
        private static final String DECISION = 'decision';
        private static final String SUBSCRIPTIONID = 'subscriptionID';
        private static final String REASONCODE = 'reasonCode';
        private static final String REQUEST_ID = 'requestID';
        private static final String INVALID_FIELD = 'invalidField';
        private static final String PAYMENTTYPE_CREDITCARD = 'Credit Card';
        private static final String PAYMENTTYPE_ACH = 'ACH';
        private static final String TEST_REQUEST_BODY_CYBER_SOURCE = '';
        private static final String GENERATE_TOKEN = 'generateToken ';
        //Fortino 2021-04-02
        private static final String GENERATE_TOKEN_CRCARD = 'generateTokenCrCard ';
        private static final String REFUND_TRANSACTION_WEB = 'refundTransactionWeb ';
        private static final String GENERATE_PAYMENT_DETAIL = 'generatePaymentDetail';
        
        private static final String POPULATE_GENERATE_TOKEN = 'populateTransactionResultForToken ';
        
        //Fortino 2021-02-16
        private static final String POPULATE_GENERATE_PAYDETAILS = 'populateTransactionResultForPayDetails ';
                
        private static final String AUTHORIZE_TRANSACTION = 'authorizeTransaction ';
        private static final String POPULATE_AUTHORIZE_TRANSACTION = 'populateTransactionResultForAuthorize ';
        private static final String CHARGE_TRANSACTION = 'chargeTransaction ';
        private static final String POPULATE_CHARGE_TRANSACTION = 'populateTransactionResultForCharge ';
        private static final String VOID_TRANSACTION = 'voidTransaction ';
        private static final String POPULATE_VOID_TRANSACTION = 'populateTransactionResultForVoid ';
        private static final String REFUND_TRANSACTION = 'refundTransaction ';
        
        private static final String POPULATE_REFUND_TRANSACTION = 'populateTransactionResultForRefund ';
    
        private static EziDebit eziDebitInstance;

    
    public static EziDebit getInstance() 
    {
        if (NULL == eziDebitInstance) 
        {
            eziDebitInstance = new EziDebit();
        }
        return eziDebitInstance;
    }

//Fortino 2021-02-10
    public Map<String, blng.TransactionResult> generatePaymentDetail(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)
    {
        try
        {
            System.debug('Inside generatePaymentDetail');
            if(!mapOfTransactionParameterById.IsEmpty())
            {
                System.debug('Inside If');
                EziDebitUtils.getInstance().generatePaymentDetailXML(mapOfTransactionParameterById.Values());
                for(blng.TransactionParameter transactionParameterToProcess : mapOfTransactionParameterById.Values())
                {
                    try
                    {  
                        //sendHttpRequest.setTokenisationHeader('100-753-606@WEB_ADMIN', 'Shiv@1234');
                        
                        HttpService sendHttpRequest = HttpService.getInstance();
                        sendHttpRequest.addHeader('Content-type', 'text/xml');
                        sendHttpRequest.addHeader('SOAPAction', 'https://px.ezidebit.com.au/INonPCIService/GetPaymentDetail');
                        //sendHttpRequest.setAuthorizationHeader(transactionParameterToProcess.getGateWay().MerchantId__c,transactionParameterToProcess.getGateWay().TransactionSecurityKey__c);
                        //sendHttpRequest.setAuthorizationHeader('241F14E6-9094-48E3-55B6-7D21CAA5E7A5','Shiv@1234');
                        sendHttpRequest.setAuthorizationHeader('59984E22-9ED0-4832-1ACA-593E7A6E2E21', '100-765-592@WEB_ADMIN');
                        System.debug('auth header');
                        sendHttpRequest.post('https://api.demo.ezidebit.com.au/v3-5/nonpci',transactionParameterToProcess.getRequestBody());
                        System.debug('requestBody:-' + transactionParameterToProcess.getRequestBody());
                        transactionParameterToProcess.mapOfResponseValueByKey.putAll(EziDebitUtils.getElements(sendHttpRequest.getResponse().getBodyDocument().getRootElement()));
                    }
                    catch (Exception e) 
                    {
                        transactionParameterToProcess.transactionResult.setIsSuccess(false);
                        transactionParameterToProcess.transactionResult.setError(e.getMessage());
                    }    
                }    
                 
            } 
            return populateTransactionResultForPayDetails(mapOfTransactionParameterById);
        }
        catch (Exception e) 
        {
            throw e; 
        }    
    }


//Fortino 2021-02-05
    public Map<String, blng.TransactionResult> refundTransactionWeb(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)
    {
        try
        {
            System.debug('Inside Generate Token');
            if(!mapOfTransactionParameterById.IsEmpty())
            {
                System.debug('Inside If');
                EziDebitUtils.getInstance().generateRefundXML(mapOfTransactionParameterById.Values());
                for(blng.TransactionParameter transactionParameterToProcess : mapOfTransactionParameterById.Values())
                {
                    try
                    {  
                        //sendHttpRequest.setTokenisationHeader('100-753-606@WEB_ADMIN', 'Shiv@1234');
                        
                        HttpService sendHttpRequest = HttpService.getInstance();
                        sendHttpRequest.addHeader('Content-type', 'text/xml');
                        sendHttpRequest.addHeader('SOAPAction', 'https://px.ezidebit.com.au/INonPCIService/ProcessRefund');
                        //sendHttpRequest.setAuthorizationHeader(transactionParameterToProcess.getGateWay().MerchantId__c,transactionParameterToProcess.getGateWay().TransactionSecurityKey__c);
                        //sendHttpRequest.setAuthorizationHeader('241F14E6-9094-48E3-55B6-7D21CAA5E7A5','Shiv@1234');
                        sendHttpRequest.setAuthorizationHeader('59984E22-9ED0-4832-1ACA-593E7A6E2E21', '100-765-592@WEB_ADMIN');
                        System.debug('auth header');
                        sendHttpRequest.post('https://api.demo.ezidebit.com.au/v3-5/nonpci',transactionParameterToProcess.getRequestBody());
                        System.debug('requestBody:-' + transactionParameterToProcess.getRequestBody());
                        transactionParameterToProcess.mapOfResponseValueByKey.putAll(EziDebitUtils.getElements(sendHttpRequest.getResponse().getBodyDocument().getRootElement()));
                    }
                    catch (Exception e) 
                    {
                        transactionParameterToProcess.transactionResult.setIsSuccess(false);
                        transactionParameterToProcess.transactionResult.setError(e.getMessage());
                    }    
                }    
                 
            } 
            return populateTransactionResultForToken(mapOfTransactionParameterById);
        }
        catch (Exception e) 
        {
            throw e; 
        }    
    }

//Fortino 2021-02-04
    public Map<String, blng.TransactionResult> generateTokenCrCard (Map<String, blng.TransactionParameter> mapOfTransactionParameterById)
    {
        try
        {
            System.debug('Inside Generate Token');
            if(!mapOfTransactionParameterById.IsEmpty())
            {
                System.debug('Inside If');
                EziDebitUtils.getInstance().generateTokenCrCardXML(mapOfTransactionParameterById.Values());
                for(blng.TransactionParameter transactionParameterToProcess : mapOfTransactionParameterById.Values())
                {
                    try
                    {  
                        //sendHttpRequest.setTokenisationHeader('100-753-606@WEB_ADMIN', 'Shiv@1234');
                        
                        HttpService sendHttpRequest = HttpService.getInstance();
                        sendHttpRequest.addHeader('Content-type', 'text/xml');
                        sendHttpRequest.addHeader('SOAPAction', 'https://px.ezidebit.com.au/IPCIService/AddCardDebit');
                        //sendHttpRequest.setAuthorizationHeader(transactionParameterToProcess.getGateWay().MerchantId__c,transactionParameterToProcess.getGateWay().TransactionSecurityKey__c);
                        //sendHttpRequest.setAuthorizationHeader('241F14E6-9094-48E3-55B6-7D21CAA5E7A5','Shiv@1234');
                        sendHttpRequest.setAuthorizationHeader('59984E22-9ED0-4832-1ACA-593E7A6E2E21', '100-765-592@WEB_ADMIN');
                        System.debug('auth header');
                        sendHttpRequest.post('https://api.demo.ezidebit.com.au/v3-5/pci',transactionParameterToProcess.getRequestBody());
                        System.debug('requestBody:-' + transactionParameterToProcess.getRequestBody());
                        transactionParameterToProcess.mapOfResponseValueByKey.putAll(EziDebitUtils.getElements(sendHttpRequest.getResponse().getBodyDocument().getRootElement()));
                    }
                    catch (Exception e) 
                    {
                        transactionParameterToProcess.transactionResult.setIsSuccess(false);
                        transactionParameterToProcess.transactionResult.setError(e.getMessage());
                    }    
                }    
                 
            } 
            return populateTransactionResultForToken(mapOfTransactionParameterById);
        }
        catch (Exception e) 
        {
            throw e; 
        }    
    }
    
     
    public Map<String, blng.TransactionResult> generateToken(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)
    {
        try
        {
            System.debug('Inside Generate Token');
            if(!mapOfTransactionParameterById.IsEmpty())
            {
                System.debug('Inside If');
                EziDebitUtils.getInstance().generateTokenXML(mapOfTransactionParameterById.Values());
                for(blng.TransactionParameter transactionParameterToProcess : mapOfTransactionParameterById.Values())
                {
                    try
                    {  
                        //sendHttpRequest.setTokenisationHeader('100-753-606@WEB_ADMIN', 'Shiv@1234');
                        
                        HttpService sendHttpRequest = HttpService.getInstance();
                        sendHttpRequest.addHeader('Content-type', 'text/xml');
                        sendHttpRequest.addHeader('SOAPAction', 'https://px.ezidebit.com.au/INonPCIService/AddCustomer');
                        //sendHttpRequest.setAuthorizationHeader(transactionParameterToProcess.getGateWay().MerchantId__c,transactionParameterToProcess.getGateWay().TransactionSecurityKey__c);
                        //sendHttpRequest.setAuthorizationHeader('241F14E6-9094-48E3-55B6-7D21CAA5E7A5','Shiv@1234');
                        sendHttpRequest.setAuthorizationHeader('59984E22-9ED0-4832-1ACA-593E7A6E2E21', '100-765-592@WEB_ADMIN');
                        System.debug('auth header');
                        sendHttpRequest.post('https://api.demo.ezidebit.com.au/v3-5/nonpci',transactionParameterToProcess.getRequestBody());
                        System.debug('requestBody:-' + transactionParameterToProcess.getRequestBody());
                        transactionParameterToProcess.mapOfResponseValueByKey.putAll(EziDebitUtils.getElements(sendHttpRequest.getResponse().getBodyDocument().getRootElement()));
                    }
                    catch (Exception e) 
                    {
                        transactionParameterToProcess.transactionResult.setIsSuccess(false);
                        transactionParameterToProcess.transactionResult.setError(e.getMessage());
                    }    
                }    
                 
            } 
            return populateTransactionResultForToken(mapOfTransactionParameterById);
        }
        catch (Exception e) 
        {
            throw e; 
        }    
    }


//Fortino 2021-02-15
    public Map<String, blng.TransactionResult> populateTransactionResultForPayDetails(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)
    {
        try
        {
            Map<String, blng.TransactionResult> mapOfTransactionResultById = new Map<String, blng.TransactionResult>();
            for(String idToProcess : mapOfTransactionParameterById.KeySet())
            {
                blng.TransactionParameter transactionParameterToProcess = mapOfTransactionParameterById.get(idToProcess);
                System.debug('Result Values:-' + transactionParameterToProcess.getResponseValueByKey().KeySet());
                System.debug('Result Values:-' + transactionParameterToProcess.getResponseValueByKey().values());
                System.debug('Result Values:-' + transactionParameterToProcess.getResponseValueByKey().get('BankFailedReason'));
                if(transactionParameterToProcess.getResponseValueByKey().get('Error') == '0')
                {
                    transactionParameterToProcess.transactionResult.setResponseToValidate('S');
                    transactionParameterToProcess.transactionResult.setIsSuccess(true);
                }
                else if(transactionParameterToProcess.getResponseValueByKey().get('Error') != '0')
                {
                    transactionParameterToProcess.transactionResult.setResponseToValidate(FAILURE);
                    transactionParameterToProcess.transactionResult.setIsSuccess(false);
                }
                transactionParameterToProcess.transactionResult.setId(idToProcess);
                transactionParameterToProcess.transactionResult.setResponseCode(transactionParameterToProcess.getResponseValueByKey().get('Error'));
                
                if(NULL != transactionParameterToProcess.transactionResult.getResponseCode())
                {
                    transactionParameterToProcess.transactionResult.setResponseCodeMessage(transactionParameterToProcess.transactionResult.getResponseCode());
                } 

                //transactionParameterToProcess.transactionResult.setPaymentToken(transactionParameterToProcess.getResponseValueByKey().get('CustomerRef'));
                //getResponseCodeMessage()                  
                transactionParameterToProcess.transactionResult.setResponseMessage(transactionParameterToProcess.getResponseValueByKey().get('BankFailedReason'));  
                
                mapOfTransactionResultById.put(idToProcess,transactionParameterToProcess.transactionResult);
            }
            return mapOfTransactionResultById;
        }
        catch (Exception e) 
        {
            throw e; 
        }   
    }     
    
    public Map<String, blng.TransactionResult> populateTransactionResultForToken(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)
    {
        try
        {
            Map<String, blng.TransactionResult> mapOfTransactionResultById = new Map<String, blng.TransactionResult>();
            for(String idToProcess : mapOfTransactionParameterById.KeySet())
            {
                blng.TransactionParameter transactionParameterToProcess = mapOfTransactionParameterById.get(idToProcess);
                System.debug('Result Values:-' + transactionParameterToProcess.getResponseValueByKey().KeySet());
                System.debug('Result Values:-' + transactionParameterToProcess.getResponseValueByKey().values());
                if(transactionParameterToProcess.getResponseValueByKey().get('Error') == '0')
                {
                    transactionParameterToProcess.transactionResult.setResponseToValidate('S');
                    transactionParameterToProcess.transactionResult.setIsSuccess(true);
                }
                else if(transactionParameterToProcess.getResponseValueByKey().get('Error') != '0')
                {
                    transactionParameterToProcess.transactionResult.setResponseToValidate(FAILURE);
                    transactionParameterToProcess.transactionResult.setIsSuccess(false);
                }
                transactionParameterToProcess.transactionResult.setId(idToProcess);
                transactionParameterToProcess.transactionResult.setResponseCode(transactionParameterToProcess.getResponseValueByKey().get('Error'));
                
                if(NULL != transactionParameterToProcess.transactionResult.getResponseCode())
                {
                    transactionParameterToProcess.transactionResult.setResponseCodeMessage(transactionParameterToProcess.transactionResult.getResponseCode());
                } 

                transactionParameterToProcess.transactionResult.setPaymentToken(transactionParameterToProcess.getResponseValueByKey().get('CustomerRef'));
                
                mapOfTransactionResultById.put(idToProcess,transactionParameterToProcess.transactionResult);
            }
            return mapOfTransactionResultById;
        }
        catch (Exception e) 
        {
            throw e; 
        }   
    } 

    
    public Map<String, blng.TransactionResult> authorizeTransaction(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)
    {
        try
        {    
            
            return populateTransactionResultForAuthorize(mapOfTransactionParameterById);
        }
        
        catch (Exception e) 
        {
            throw e; 
        }    
    }
    
    
    public Map<String, blng.TransactionResult> populateTransactionResultForAuthorize(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)
    {
        try
        {    
            Map<String, blng.TransactionResult> mapOfTransactionResultById = new Map<String, blng.TransactionResult>();
            
            return mapOfTransactionResultById;
        }
        catch (Exception e) 
        {
            throw e; 
        }    
    } 

    
    public Map<String, blng.TransactionResult> chargeTransaction(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)
    {
        try
        {
            for(String idToProcess : mapOfTransactionParameterById.keySet())
            {
                blng.TransactionParameter transactionParameterToProcess = mapOfTransactionParameterById.get(idToProcess);        
                try
                {    
                    if(transactionParameterToProcess.getPaymentMethod().blng__PaymentType__c == PAYMENTTYPE_CREDITCARD)
                    {
                        System.debug('Inside first');
                        EziDebitUtils.getInstance().generateChargeXML(new Map<String, blng.TransactionParameter> {idToProcess => transactionParameterToProcess});  
                    }

                    HttpService sendHttpRequest = HttpService.getInstance();
                    sendHttpRequest.addHeader('Content-type', 'text/xml');
                    sendHttpRequest.addHeader('SOAPAction', 'https://px.ezidebit.com.au/INonPCIService/AddPayment');
                    //sendHttpRequest.setAuthorizationHeader(transactionParameterToProcess.getGateWay().MerchantId__c,transactionParameterToProcess.getGateWay().TransactionSecurityKey__c);
                    sendHttpRequest.setAuthorizationHeader('59984E22-9ED0-4832-1ACA-593E7A6E2E21','Shiv@1234');
                    sendHttpRequest.post('https://api.demo.ezidebit.com.au/v3-5/nonpci',transactionParameterToProcess.getRequestBody());
                    System.debug('requestBody:-' + transactionParameterToProcess.getRequestBody());
                    transactionParameterToProcess.mapOfResponseValueByKey.putAll(EziDebitUtils.getElements(sendHttpRequest.getResponse().getBodyDocument().getRootElement()));
                }
                catch (Exception e) 
                {
                    transactionParameterToProcess.transactionResult.setIsSuccess(false);
                    transactionParameterToProcess.transactionResult.setError(e.getMessage());
                }    
            }
            return populateTransactionResultForCharge(mapOfTransactionParameterById); 
        }
        catch (Exception e) 
        {
            
            throw  e; 
        }
    }
    
    
    public Map<String, blng.TransactionResult> populateTransactionResultForCharge(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)
    {
        try
        {
            System.debug('Inside Populate:-' + mapOfTransactionParameterById.keyset());
            Map<String, blng.TransactionResult> mapOfTransactionResultById = new Map<String, blng.TransactionResult>();
            for(String idToProcess : mapOfTransactionParameterById.KeySet())
            {
                System.debug('idToProcess:-' + idToProcess);
                blng.TransactionParameter transactionParameterToProcess = mapOfTransactionParameterById.get(idToProcess);
                System.debug('Result Keys:-' + transactionParameterToProcess.getResponseValueByKey().KeySet());
                System.debug('Result Values:-' + transactionParameterToProcess.getResponseValueByKey().values());
                if(transactionParameterToProcess.getResponseValueByKey().get('Data') == 'S')
                {
                    System.debug('Inside Success' );
                    transactionParameterToProcess.transactionResult.setResponseToValidate('S');
                    transactionParameterToProcess.transactionResult.setIsSuccess(true);
                }
                else if(transactionParameterToProcess.getResponseValueByKey().get(DECISION) == REJECT)
                {
                    transactionParameterToProcess.transactionResult.setResponseToValidate(FAILURE);
                    transactionParameterToProcess.transactionResult.setIsSuccess(false);
                }
                transactionParameterToProcess.transactionResult.setId(idToProcess);
                transactionParameterToProcess.transactionResult.setResponseCode(transactionParameterToProcess.getResponseValueByKey().get('Error'));
                
                if(NULL != transactionParameterToProcess.transactionResult.getResponseCode())
                {
                    transactionParameterToProcess.transactionResult.setResponseCodeMessage(transactionParameterToProcess.transactionResult.getResponseCode());
                } 

                //transactionParameterToProcess.transactionResult.setPaymentToken(transactionParameterToProcess.getResponseValueByKey().get(SUBSCRIPTIONID));
                transactionParameterToProcess.transactionResult.setGatewayId('a5K1m0000005A9QEAU');
                transactionParameterToProcess.transactionResult.setGatewayStatus(blng.TransactionResult.GatewayStatusType.Success);
                
                mapOfTransactionResultById.put(idToProcess,transactionParameterToProcess.transactionResult);
            }
            System.debug('final:-' + mapOfTransactionResultById.keyset());
            System.debug('final v:-' + mapOfTransactionResultById.values());
            return mapOfTransactionResultById;
        }
        catch (Exception e) 
        {
            throw e; 
        }        
    } 

    
    public Map<String, blng.TransactionResult> voidTransaction(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)
    {
        try
        {
            return populateTransactionResultForVoid(mapOfTransactionParameterById);
        }
        catch (Exception e) 
        {
            throw  e; 
        }         
    }
    
    public Map<String, blng.TransactionResult> populateTransactionResultForVoid(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)
    {
        try
        {    
            Map<String, blng.TransactionResult> mapOfTransactionResultById = new Map<String, blng.TransactionResult>();            
            return mapOfTransactionResultById;
        }
        catch (Exception e) 
        {
            throw  e; 
        }     
    } 
    
    public Map<String, blng.TransactionResult> refundTransaction(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)
    {
        try
        {   
            return populateTransactionResultForRefund(mapOfTransactionParameterById);
        }
        catch (Exception e) 
        {
            throw  e; 
        }     
    }

     
    public Map<String, blng.TransactionResult> populateTransactionResultForRefund(Map<String, blng.TransactionParameter> mapOfTransactionParameterById)
    {
        try
        {
            Map<String, blng.TransactionResult> mapOfTransactionResultById = new Map<String, blng.TransactionResult>();
            for(String idToProcess : mapOfTransactionParameterById.KeySet())
            {
                blng.TransactionParameter transactionParameterToProcess = mapOfTransactionParameterById.get(idToProcess);

                if(transactionParameterToProcess.getResponseValueByKey().get(DECISION) == ACCEPT)
                {
                    transactionParameterToProcess.transactionResult.setResponseToValidate(SUCCESS);
                    transactionParameterToProcess.transactionResult.setIsSuccess(true);
                }
                else if(transactionParameterToProcess.getResponseValueByKey().get(DECISION) == REJECT)
                {
                    transactionParameterToProcess.transactionResult.setResponseToValidate(FAILURE);
                    transactionParameterToProcess.transactionResult.setIsSuccess(false);
                }
                else if(transactionParameterToProcess.getResponseValueByKey().get(DECISION) == PENDING)
                {
                    transactionParameterToProcess.transactionResult.setResponseToValidate(PENDING);
                    transactionParameterToProcess.transactionResult.setIsSuccess(false);
                }
                else
                {
                    transactionParameterToProcess.transactionResult.setResponseToValidate('');
                }
                transactionParameterToProcess.transactionResult.setId(idToProcess);
                transactionParameterToProcess.transactionResult.setResponseCode(transactionParameterToProcess.getResponseValueByKey().get(REASONCODE));
                if(NULL != transactionParameterToProcess.transactionResult.getResponseCode())
                {
                    
                }
                transactionParameterToProcess.transactionResult.setGatewayId(transactionParameterToProcess.getResponseValueByKey().get(REQUEST_ID));
                transactionParameterToProcess.transactionResult.setResponseMessage(transactionParameterToProcess.getResponseValueByKey().get(INVALID_FIELD));
                mapOfTransactionResultById.put(idToProcess,transactionParameterToProcess.transactionResult);
            }
            return mapOfTransactionResultById;
        }
        catch (Exception e) 
        {
            throw  e;  
        }    
    } 
}