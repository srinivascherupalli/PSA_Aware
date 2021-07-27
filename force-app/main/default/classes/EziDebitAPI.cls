global class EziDebitAPI implements blng.PaymentGateWay
{
    
    private static EziDebit EziDebitInstance;

    
    @TestVisible
    private static EziDebit service()
    {
        if (NULL == EziDebitInstance)
        {
            EziDebitInstance = EziDebit.getInstance();
        }
        return EziDebitInstance;
    }
    
 //Fortino 2021-02-10
      global static Map<String, blng.TransactionResult> generatePaymentDetail(Map<String, blng.TransactionParameter> mapOfTransactionParameterById) 
    {
        System.debug('Inside generatePaymentDetail');
        return service().generatePaymentDetail(mapOfTransactionParameterById);
    }   

 //Fortino 2021-02-04
     global static Map<String, blng.TransactionResult> generateTokenCrCard(Map<String, blng.TransactionParameter> mapOfTransactionParameterById) 
    {
        System.debug('Inside generateToken');
        return service().generateTokenCrCard(mapOfTransactionParameterById);
    }
  
      global static Map<String, blng.TransactionResult> refundTransactionWeb(Map<String, blng.TransactionParameter> mapOfTransactionParameterById) 
    {
        System.debug('Inside refundTransactionWeb');
        return service().refundTransactionWeb(mapOfTransactionParameterById);
    }
     
    global static Map<String, blng.TransactionResult> generateToken(Map<String, blng.TransactionParameter> mapOfTransactionParameterById) 
    {
        System.debug('Inside generateToken');
        return service().generateToken(mapOfTransactionParameterById);
    }

    
    global static Map<String, blng.TransactionResult> authorizeTransaction(Map<String, blng.TransactionParameter> mapOfTransactionParameterById) 
    {
        System.debug('Inside AT');
        return service().authorizeTransaction(mapOfTransactionParameterById);
    }
        
    global static Map<String, blng.TransactionResult> chargeTransaction(Map<String, blng.TransactionParameter> mapOfTransactionParameterById) 
    {
        System.debug('Inside chargeT');
        System.debug('TP KeySet:-' + mapOfTransactionParameterById.keyset());
        System.debug('TP KeyValues:-' + mapOfTransactionParameterById.values());
        return service().chargeTransaction(mapOfTransactionParameterById);
    }

       
    global static Map<String, blng.TransactionResult> voidTransaction(Map<String, blng.TransactionParameter> mapOfTransactionParameterById) 
    {
        System.debug('Inside void');
        return service().voidTransaction(mapOfTransactionParameterById);
    }

    
    global static Map<String, blng.TransactionResult> refundTransaction(Map<String, blng.TransactionParameter> mapOfTransactionParameterById) 
    {
        return service().refundTransaction(mapOfTransactionParameterById);
    }
    
}