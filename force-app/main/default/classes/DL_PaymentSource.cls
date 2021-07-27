public with sharing class DL_PaymentSource {
    @AuraEnabled
    public static string deactivatePaymentSource(String paymentSource_ID){
        string response = null;
        
        try{
            ASPHPP__ASPayment_Source__c paymentSource = [SELECT ID,ASPHPP__Active__c,
                                                            (SELECT ASPHPP__Payment__c.Id,ASPHPP__Payment__c.ASPHPP__Payment_Status__c 
                                                            FROM ASPHPP__ASPayment_Source__c.ASPHPP__Payments__r) 
                                                        FROM ASPHPP__ASPayment_Source__c 
                                                        WHERE ID  = :paymentSource_ID];

            list<Opportunity> paymentSource_OppsList = [SELECT ID,ASPHPP__Payment_Source__c 
                                                        FROM Opportunity 
                                                        WHERE ASPHPP__Payment_Source__c = :paymentSource_ID];

            For(Opportunity opp : paymentSource_OppsList){
                opp.ASPHPP__Payment_Source__c = null;
            }

            paymentSource.ASPHPP__Active__c = false;

            update paymentSource_OppsList;
            update paymentSource;

            return response = 'Payment Sources + Opportunities Updated Successfully';
        }

        catch(Exception e){
            return response = e.getMessage();
        }  
        

    }

    @AuraEnabled
    public static string recoverFailedPayments(String paymentSource_ID){
        string response = null;

        try{
            ASPHPP__ASPayment_Source__c paymentSource = [SELECT ID,ASPHPP__Active__c,
                                                            (SELECT ASPHPP__Payment__c.Id,ASPHPP__Payment__c.ASPHPP__Payment_Status__c 
                                                            FROM ASPHPP__ASPayment_Source__c.ASPHPP__Payments__r) 
                                                        FROM ASPHPP__ASPayment_Source__c 
                                                        WHERE ID  = :paymentSource_ID];

            list<ASPHPP__Payment__c> failedPaymentsList = [SELECT ID,ASPHPP__Payment_Status__c 
                                                        FROM ASPHPP__Payment__c 
                                                        WHERE ID IN :paymentSource.ASPHPP__Payments__r
                                                        AND ASPHPP__Payment_Status__c = 'Failed'];

            for(ASPHPP__Payment__c failedPayment : failedPaymentsList){
                failedPayment.ASPHPP__Payment_Status__c = 'Failed but recovered';
            }

            update failedPaymentsList;
            return response = 'Failed Payments Updated Successfully';
        }

        catch(Exception e){
            return response = e.getMessage();
        }
    }
}