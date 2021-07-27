/*Author : John Hope
 *Description : This is a test class for Account class.
 *Date Created : May 4, 2018
 *Last Modified By : 
 *Date Last Modified : 
 *Related Meta Data : Account.cls
 */
@isTest(SeeAllData = false)
private class AsAccountTriggerTest {

    static testMethod void isInsert() {
        Account acc = new Account();
        acc.Name = 'AlphaSys Account';
        insert acc;
    }
    @TestSetup
    static void isUpdate() {
        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'AlphaSys';
        acc.LastName = 'Account12345';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'memberuser@testorg.com';
        insert acc;

        // Create a unique UserName
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Member Login User'];
        Account acc1 = [SELECT Id, PersonContactId FROM Account WHERE Id =: acc.Id];

        System.debug('acc1 : ' + acc1);

        User use = new User(Alias = 'standt', Email = 'memberuser@testorg.com',
            EmailEncodingKey = 'UTF-8', LastName = 'mongrel', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = p.Id,
            ContactId = acc1.PersonContactId,
            TimeZoneSidKey = 'America/Los_Angeles',
            isActive = true,
            UserName = uniqueUserName1);
        insert use;

        System.debug('hooohayyy : ' + acc1.PersonContactId + ' - ' + use);
        List < User > userList = [Select Id, Name, ContactId from User];
        System.debug('userList :' + userList);
    }

    static testMethod void isUpdate2() {
        Account acc = [Select Id, Name from Account where lastname = 'Account12345'];
        System.debug('acc 2:' + acc);
        Account accUpdate = new Account();
        accUpdate.Id = acc.Id;
        accUpdate.Salutation = 'Mr.';
        update accUpdate;
    }

    static testMethod void isDelete() {
        Account acc = new Account();
        acc.Name = 'test Account';
        insert acc;

        delete acc;
    }

    static testMethod void isUndelete() {
        Account a = new Account(Name = 'Universal Containers');
        insert a;

        delete a;

        Account[] savedAccts = [SELECT Id, Name FROM Account WHERE Name = 'Universal Containers'
            ALL ROWS
        ];
        try {
            undelete savedAccts;
        } catch (DmlException e) {
            // Process exception here
        }
    }

    /*
    static testMethod void createMemberMatch() {
    Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
    Account acc = new Account();
    acc.FirstName = 'Alpha';
    acc.LastName = 'Sys';
    acc.recordTypeId = personAccRecId;
    acc.PersonEmail = 'bannegroupuser@testorg.com';
    acc.AS_Membership_Status__pc = 'Current';
    acc.AS_AHPRA_Number__pc = '123';
    insert acc;

    Account theAccount = [Select Id,LastName,PersonContactId from Account where PersonEmail = 'memberuser@testorg.com' LIMIT 1];

    Contact tobeUpdatedContact = new Contact();
    tobeUpdatedContact.Id = theAccount.PersonContactId;
    tobeUpdatedContact.ASAHPRA_ID__c = '123';
    update tobeUpdatedContact;
    System.debug('alltobeUpdatedContact wew : ' + tobeUpdatedContact);

    Account updateAcc  = new Account();
    updateAcc.Id = theAccount.Id;
    updateAcc.LastName = 'System';
    updateAcc.AS_AHPRA_Number__pc = '123';
    Update updateAcc;
    }
    */

}