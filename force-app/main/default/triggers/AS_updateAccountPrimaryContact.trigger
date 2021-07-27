/*
* Author : WEW
* Description: PSAS-43 Create Primary Contact trigger
* Parameter : None
* Return : None
*/
trigger AS_updateAccountPrimaryContact on Contact (after insert, after update) {
	// this is commented since this is transferred to AsContactTriggerHandler.updateAccountPrimaryContact
    /*
    if(AS_commonFunction.runupdateAccountOnce()){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id,Id> updatePrimaryMap = new Map<Id,Id>();
        for (Contact c : Trigger.new) {
           // accountIds.add(c.AccountId);
            if(c.AccountId!=null && !updatePrimaryMap.containsKey(c.AccountId)){
                updatePrimaryMap.put(c.AccountId,c.Id);
                contactIds.add(c.Id);
            }
        }
        
        System.debug('accountIds :' + accountIds);
        System.debug('contactIds :' + contactIds);
        System.debug('updatePrimaryMap :' + updatePrimaryMap);
        
        List<Contact> allConUpdate = new List<Contact>();
        List<Account> allAccUpdate = new List<Account>();
        for(Account acc : [Select Id, Primary_Contact__c,(Select Id, Name, Primary_Contact__c from Contacts where Id NOT IN :contactIds) from Account where Id in :updatePrimaryMap.keySet()]){
            Account indiAccUpdate = new Account();
            indiAccUpdate.Id = acc.Id;
            indiAccUpdate.Primary_Contact__c = updatePrimaryMap.get(acc.Id);
            allAccUpdate.add(indiAccUpdate);
            
            System.debug('acc.Contacts.size() :' + acc.Contacts.size());
            if(acc.Contacts.size() > 0) {
                for(Contact cn :acc.Contacts){
                    Contact indiConUpdate = new Contact();
                    indiConUpdate.Id = cn.Id;
                    indiConUpdate.Primary_Contact__c = false;
                    allConUpdate.add(indiConUpdate);
                }
            }
        }
        
        System.debug('allAccUpdate :' + allAccUpdate);
        System.debug('allConUpdate :' + allConUpdate);
        if(allAccUpdate.size()>0) {
            update allAccUpdate;
            update allConUpdate;
            AS_commonFunction.runupdateAccount = false;
        } else {
            AS_commonFunction.runupdateAccount = true;
        }
        
        
    }
   */
}