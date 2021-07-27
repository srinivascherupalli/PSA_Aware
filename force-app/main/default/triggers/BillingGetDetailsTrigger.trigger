trigger BillingGetDetailsTrigger on blng__PaymentTransaction__c (after insert) 
{
    for(blng__PaymentTransaction__c p : Trigger.New) 
    {
        System.debug('PaymentTransactionId: ' + p.Id);
        // Check if the Payment Transaction failed or was successful/approved
        //if (p.blng__ResponseStatus__c == 'Failed')
        //{
            Billing_GetPaymentDetails.GetPaymentDetails(p.Id);
        //}
        //else if (p.blng__ResponseStatus__c == 'Approved')
        //{
         //   Billing_GetDetailsSuccess.GetPaymentDetails(p.Id);
        //}
        
    }
}