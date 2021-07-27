/*
*Author : Michael Vincent Largo
*Description : Test class for AsLMSUserToMoodleBatch
*Date Created : 01/20/2019
*Last Modified By: Deadz 
*Date Last Modified: 01/20/2019
*Related Metadata : Account 
*Action : None
*Param : None
*Return : None
*/

@istest
public class AsLMSUserToMoodleBatchTest {

	 @testSetup 
	 static void setup() {

	 	List<LMS_Instance__c>  insertImsInstance = new List<LMS_Instance__c>();

        LMS_Instance__c lmsinst = new LMS_Instance__c();
        lmsinst.AS_Instance_Long_Name__c = 'sample instance';
        lmsinst.Status__c = 'Active';
        lmsinst.Token__c = '1234567890';
        lmsinst.Type__c = 'Moodle';
        lmsinst.Domain_URL__c = 'https://samplewebsite.com';
        lmsinst.URL__c = 'https://samplewebsite.com';
        insertImsInstance.add(lmsinst);

        LMS_Instance__c lmsinst2 = new LMS_Instance__c();
        lmsinst2.AS_Instance_Long_Name__c = 'sample instance2';
        lmsinst2.Status__c = 'Active';
        lmsinst2.Token__c = '12345678902';
        lmsinst2.Type__c = 'Moodle';
        lmsinst2.Domain_URL__c = 'https://samplewebsite.com';
        lmsinst2.URL__c = 'https://samplewebsite.com';
        insertImsInstance.add(lmsinst2);
        insert insertImsInstance;

        LMS_User__c lmsuser01 = new LMS_User__c();
        lmsuser01.LMS_Instance__c  = insertImsInstance[0].Id;
        lmsuser01.Moodle_User_Id__c ='12345';
        lmsuser01.FirstName__c = 'Michael';
        lmsuser01.LastName__c = 'Mode';
        lmsuser01.Status__c = 'Active';
        lmsuser01.Email__c = 'Vincent@yahoo.com';
        lmsuser01.As_Creation_Status__c = 'In Progress';
        lmsuser01.As_Sync_Attempt__c = 0;
        insert lmsuser01;

	 }

	static testMethod void testLMSUserBatch(){

    List<LMS_Instance__c> LmsInstanceList = [Select 
                                            Id,
                                            Token__c,
                                            URL__c 
                                        from 
                                            LMS_Instance__c
                                        where 
                                            Token__c !=NULL
                                            And
                                            URL__c !=NULL
                                        ];

    
    AsLMSUserToMoodleBatch AsLMSUser = new AsLMSUserToMoodleBatch(LmsInstanceList);
    Database.executeBatch(AsLMSUser);


	Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AsLMSUserToMoodleBatchHttpCallOutMock());
	Test.stopTest();
    }

    Static testMethod void testLMSUserBatcherror (){


    List<LMS_Instance__c> LmsInstanceList = [Select 
                                            Id,
                                            Token__c,
                                            URL__c 
                                        from 
                                            LMS_Instance__c
                                        where 
                                            Token__c !=NULL
                                            And
                                            URL__c !=NULL
                                        ];


    AsLMSUserToMoodleBatch AsLMSUser = new AsLMSUserToMoodleBatch(LmsInstanceList);
    Database.executeBatch(AsLMSUser);


    List<LMS_User__c> InsertlmsUserList = new List<LMS_User__c>();                           

    LMS_User__c lmsusernew02 = new LMS_User__c();
    lmsusernew02.LMS_Instance__c  = LmsInstanceList[0].Id;
    lmsusernew02.Moodle_User_Id__c = '75';
    lmsusernew02.FirstName__c = 'Michael';
    lmsusernew02.LastName__c = 'Mode';
    lmsusernew02.Status__c = 'Active';
    lmsusernew02.Email__c = 'Vincent@yahoo.com';
    lmsusernew02.As_Creation_Status__c = 'In Progress';
    lmsusernew02.As_Sync_Attempt__c = 0;
    InsertlmsUserList.add(lmsusernew02);
    insert InsertlmsUserList;

    LMS_User__c lmsusernew03 = new LMS_User__c();
    lmsusernew03.Id = lmsusernew02.Id;
    lmsusernew03.Moodle_User_Id__c ='75';
    lmsusernew03.As_Creation_Status__c = 'In Progress';
    lmsusernew02.As_Sync_Attempt__c = 1;
    update lmsusernew03;

    }

}