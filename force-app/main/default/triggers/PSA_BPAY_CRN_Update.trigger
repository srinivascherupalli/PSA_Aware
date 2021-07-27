trigger PSA_BPAY_CRN_Update on Account (after insert) {
    
Account myAccount=trigger.new[0];
Account updacc=[select id from Account where id = :myAccount.id];
try{
        List<PSA_BPay_Reference_Lookup__c> bpayRef = [select id,CRN__c from PSA_BPay_Reference_Lookup__c where Name = :myAccount.PSA_PSA_ID__c];
        if(bpayRef.size() > 0 )  {
            updacc.PSA_BPAY_CRN__c = bpayRef[0].CRN__c ;
            update updacc;
        }
}
catch(dmlexception e){
    updacc.PSA_BPAY_CRN__c = 'PSA_ID Missing' ;
    update updacc;
}

}