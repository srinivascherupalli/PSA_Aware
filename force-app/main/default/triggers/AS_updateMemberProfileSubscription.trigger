/*
* Author : WEW
* Description: trigger to update account base on membership subscription data PSAS-21
* Parameter : None
* Return : None
*/
trigger AS_updateMemberProfileSubscription on AS_Subscription__c (after insert, after update) {
    List<Account> allAccList = new List<Account>();
    
    Set<Id> setProductId = new Set<Id>();
    List<Id> listProductId = new List<Id>();
    for(AS_Subscription__c sub : Trigger.New){
        if(sub.AS_Product__c != null) {
            setProductId.add(sub.AS_Product__c);
        }
    }
    listProductId.addAll(setProductId);
    
    Map<Id,String> prodMemType = new Map<Id,String>();
    for(Product2 prod :[Select Id,Name,AS_Membership_Type__c,AS_Membership_Type__r.Name from Product2 where Id IN :listProductId]) {
        prodMemType.put(prod.Id,prod.AS_Membership_Type__r.Name);
    }
    
    Map<Id,String> prodMemName = new Map<Id,String>();
    for(Product2 prod :[Select Id,Name,AS_Membership_Type__c,AS_Membership_Type__r.Name from Product2 where Id IN :listProductId]) {
        prodMemName.put(prod.Id,prod.Name);
    }
    
    for(AS_Subscription__c sub : Trigger.New){
        if(sub.AS_Type__c == 'Member' && sub.Account__c != null) {
            Account indiAcc = new Account();
            indiAcc.Id = sub.Account__c;
            indiAcc.AS_Membership_Number__pc = sub.AS_Membership_Number__c;
            indiAcc.AS_Membership_Joined_Date__pc = sub.AS_Start_Date__c;
            indiAcc.AS_Membership_End_Date__pc = sub.AS_End_Date__c;
            indiAcc.AS_Membership_Status__pc = sub.AS_Membership_Status__c;
            indiAcc.PSA_Member_Verified__pc = sub.PSA_Member_Verified__c;
            indiAcc.PSA_Membership_Level__pc = (prodMemName.get(sub.AS_Product__c)!=null)?prodMemName.get(sub.AS_Product__c):'';
            indiAcc.AS_Membership_Span__pc = sub.AS_Membership_Span__c;
            indiAcc.AS_Membership_Renewal_Date__pc = sub.AS_Membership_Renewal_Date__c;
            indiAcc.AS_Membership_Level__pc = (prodMemType.get(sub.AS_Product__c)!=null)?prodMemType.get(sub.AS_Product__c):'';
            indiAcc.AS_Membership_Number__pc = sub.AS_Membership_Number__c;
            allAccList.add(indiAcc);
        }
    }
    update allAccList;
}