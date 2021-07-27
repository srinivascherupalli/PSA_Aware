@isTest
public class ASPendingExpireNotificationHandlerTest {

    @testSetup static void setup() {
        
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id psaenrolment = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();
        
        Account acc = new Account();
        acc.FirstName = 'Sample Person';
        acc.LastName = 'Account';
        acc.PersonEmail = 'person@test.com';
        acc.RecordTypeId = personAccountId;
        acc.AS_Unique_Student_Identifier__c = '12312';
        insert acc;

        Learning_Package__c AsLearnPack = new Learning_Package__c(
            Name = 'Test Learning Package',
            AS_Accreditation_level__c = 'Qualification',
            AS_Number_Electives__c = 2,
            AS_Funding_eligible__c = true
        );
        insert AsLearnPack;

        Training_Plan__c tplan = new Training_Plan__c(
            AS_Training_Plan_Type__c = 'Australian Pharmacist',
            Name = 'Testing TPlan',
            Type__c = 'RTO',
            Status__c = 'Active',
            AS_LMS__c = 'Moodle Course',
            Start_Date__c = date.today(),
            End_Date__c = date.today() + 2,
            Date_Published__c = date.today()
        );
        insert tplan;

        Enrolment_Form__c enrolform = new Enrolment_Form__c(
            RecordTypeId = psaenrolment,
            AS_Account__c = acc.Id,
            AS_Learning_Package__c = AsLearnPack.Id,
            Training_Plan_Lookup__c = tplan.Id,
            AS_Processed__c = false,
            Enrolment_Status__c = 'Draft',
            AS_Pending_notification_sent__c = false,
            AS_Enrollment_Last_Modify_Date__c = Date.today() - 7
        );
        insert enrolform;

        Enrolment_Form__c enrolform1 = new Enrolment_Form__c(
            RecordTypeId = psaenrolment,
            AS_Account__c = acc.Id,
            AS_Learning_Package__c = AsLearnPack.Id,
            Training_Plan_Lookup__c = tplan.Id,
            AS_Processed__c = false,
            Enrolment_Status__c = 'Draft',
            AS_Pending_notification_sent__c = false,
            AS_Enrollment_Last_Modify_Date__c = Date.today() - 14
        );
        insert enrolform1;

        AS_pending_and_expired_notifications__c setting = new AS_pending_and_expired_notifications__c();
        setting.Expired_Notification__c = 14;
        setting.Pending_Notification__c = 7;
        insert setting;

    }

    @isTest static void testNotificationHanlder() {

        String q = 'SELECT ';
        q += 'Id';
        q += ', Name';
        q += ', AS_Enrollment_Last_Modify_Date__c';
        q += ', AS_Expired_notification_sent__c';
        q += ', AS_Account__r.AS_PersonAccount_ContactID__c';
        q += ', AS_Account__r.PersonEmail';

        Id rId = Schema.Sobjecttype.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();
        q += ', Enrolment_Status__c FROM Enrolment_Form__c WHERE Enrolment_Status__c = \'Draft\' AND RecordTypeId =: rId AND AS_Pending_notification_sent__c = false';

        List<Enrolment_Form__c> scope =  Database.query( q );

        Test.startTest();
        ASPendingExpireNotificationHandler notification = new ASPendingExpireNotificationHandler( scope );
        notification.runBatch();
        Test.stopTest();

        List<Task> t = [Select Id FROM Task WHERE Subject = 'Expired enrolment email sent'];
        System.assertEquals( 1, t.size());

        List<Task> t1 = [Select Id FROM Task WHERE Subject = 'Pending enrolment email sent'];
        System.assertEquals( 1, t1.size());

        List<Enrolment_Form__c> ep = [Select Id FROM Enrolment_Form__c WHERE AS_Pending_notification_sent__c = true];
        System.assertEquals( 1, ep.size());

        List<Enrolment_Form__c> ee = [Select Id FROM Enrolment_Form__c WHERE AS_Expired_notification_sent__c = true];
        System.assertEquals( 1, ee.size());

    }

}