@isTest
public with sharing class MoodleActivityCompletionTest {
    @TestSetup 
    static void testData(){

        Id recordId = Schema.SObjectType.LMS_Course__c.getRecordTypeInfosByName().get('Chemist Warehouse').getRecordTypeId();
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Account acc = new Account();
        acc.FirstName = 'Test 101';
        acc.LastName = 'Account';
        acc.PersonEmail = 'test101@outlook.com';
        acc.RecordTypeId = personAccountId;
        insert acc;

        List<Profile> pro = [Select Id,Name from Profile where Name='Member Login User' LIMIT 1];
        Account accToUsed = [Select Id,PersonContactId from Account where Id = :acc.Id limit 1];
        User user = new User();
        user.ContactId = accToUsed.PersonContactId;
        user.profileid = (pro.size() > 0)?pro[0].Id:null;
        user.FirstName = acc.FirstName;
        user.LastName = acc.LastName;
        user.Alias =string.valueof(acc.FirstName.substring(0,1) + acc.LastName.substring(0,2));
        user.Email = 'test101@outlook.com';
        user.Username = 'test101@outlook.com';
        user.CommunityNickname = acc.FirstName + acc.LastName + AS_commonFunction.generateRandomIntString(2);
        user.emailencodingkey='UTF-8';
        user.languagelocalekey='en_US'; 
        user.localesidkey='en_AU'; 
        user.timezonesidkey='GMT';

		insert user;

        LMS_Instance__c instance = new LMS_Instance__c();
        instance.Type__c = 'Moodle';
        instance.Date__c = date.today();
        instance.Status__c = 'Active';
        instance.URL__c = 'https://lms.alphasys.com.au/moodle/webservice/rest/server.php';
        instance.Token__c = '77af90cdc0adc31fd9909cc2e568f0b6';
        instance.Domain_URL__c = 'https://lms.alphasys.com.au/moodle/';

        insert instance;

        LMS_Course__c course = new LMS_Course__c();
        course.Description__c = 'Test Description 101';
        course.LMS_Instance__c = instance.Id;
        course.Status__c = 'Active';
        course.Date__c = date.today();
        course.Moodle_Course_Id__c = '75';
        course.AsLmsCrouseExtId__c = '1629135156';
        course.RecordTypeId = recordId;

        insert course;

        LMS_Activity__c activity = new LMS_Activity__c();
        activity.Name = 'Moodle Quiz Test 101';
        activity.LMS_Course__c = course.Id;
        activity.Date__c = date.today();
        activity.ASLmsActivityExtId__c = '12323131';
        activity.LMS_Instance__c = instance.Id;
        activity.Moodle_Activity_Id__c = '101';
        activity.Status__c = 'Active';
        activity.AS_Activity_Type__c = 'Quiz';

        insert activity;

        LMS_User__c userc = new LMS_User__c();
        userc.FirstName__c = 'Test 101';
        userc.LastName__c = 'Test Lastname';
        userc.Email__c = 'test101@outlook.com';
        userc.Status__c = 'Active';
        userc.AS_Banner_Group_Contact__c = user.ContactId;
        userc.LMS_Instance__c = instance.Id;

        insert userc;


        LMS_Activity_Enrolment__c enrolment = new LMS_Activity_Enrolment__c();
        enrolment.AS_Completed_Status__c = true;
        enrolment.Completion_Status__c = 'Pass';
        enrolment.Start_Date__c = date.today();
        enrolment.End_Date__c = date.today() + 1;
        enrolment.LMS_Activity__c = activity.Id;
        enrolment.LMS_Course__c = course.Id;
        enrolment.LMS_Instance__c = instance.Id;
        enrolment.LMS_User__c = userc.Id;

        insert enrolment;

    }

    static testMethod void validatehttpost() {

        LMS_Activity__c activity = [ Select Id FROM LMS_Activity__c WHERE Name =: 'Moodle Quiz Test 101' AND Moodle_Activity_Id__c =: '101'  ];

        LMS_Course__c course = [ Select Id FROM LMS_Course__c WHERE Description__c =: 'Test Description 101' AND Moodle_Course_Id__c =: '75'  ];

        LMS_User__c user = [ Select Id  FROM LMS_User__c WHERE FirstName__c =: 'Test 101' AND Email__c =: 'test101@outlook.com' ];

        LMS_Activity_Enrolment__c enrolment = new LMS_Activity_Enrolment__c();
        enrolment.AS_Completed_Status__c = true;
        enrolment.Completion_Status__c = 'Pass';
        enrolment.End_Date__c = date.today();


        MoodleActivityCompletion.updateRecord( activity.Id, course.Id, user.Id, enrolment );

    }

}