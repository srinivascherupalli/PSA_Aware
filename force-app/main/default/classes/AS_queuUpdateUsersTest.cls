@isTest
private class AS_queuUpdateUsersTest {
	
	@isTest static void AS_queuUpdateUsers() { //AS_queuUpdateUsers
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        List<AS_Subscription__c> listSub = new List<AS_Subscription__c>(); 
        List<AS_Subscription__c> listSub2 = new List<AS_Subscription__c>(); 
        List<Account> listAcc = new List<Account>(); 

        List<Profile> pro = [Select Id,Name from Profile where Name='Member Login User' LIMIT 1];

        User thisUser = [ Select Id,UserRoleId,ProfileId,UserRole.Name,Profile.Name from User where Id = :UserInfo.getUserId() ];
        system.debug('xUser : '+thisUser);

        System.runAs ( thisUser ) {
            for(Integer x=0;x<200;x++){
                Account acc = new Account();
                acc.FirstName = 'AccF'+x;
                acc.LastName = 'AccL'+x;
                acc.PersonEmail = 'person'+x+'@test.com';
                acc.RecordTypeId = personAccountId;
                listAcc.add(acc);
            }
            insert listAcc;

            Set<Id> setAcc = new Set<Id>();
            List<Id> listContactId = new List<Id>();
            for(Account acc : listAcc){
                setAcc.add(acc.Id);
            }
            
            for(Account acc:[Select Id,PersonContactId from Account where Id IN :setAcc]){
                listContactId.add(acc.PersonContactId);
            }

            for(Integer x=0;x<200;x++){
                AS_Subscription__c sub = new AS_Subscription__c();
                sub.AS_Membership_Status__c = 'Pending';
                sub.AS_Type__c = 'Member';
                sub.Account__c = listAcc[x].Id;
                listSub.add(sub);
            }
            system.debug('zzzlistSub : '+listSub);
            insert listSub;

            for(AS_Subscription__c sub : listSub){
                AS_Subscription__c sub2up = new AS_Subscription__c();
                sub2up.Id = sub.Id;
                sub2up.AS_Membership_Status__c = 'Expired';
                listSub2.add(sub2up);
            }
            update listSub2;

        }//run as
    }
	
}