@isTest
public class AsEnrollmentListControllerTest {

    static testMethod void AsEnrollmentList() {

        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id enrolRecId = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();
        
        Account Accnt = new Account(
            RecordTypeID=personAccountId,
            FirstName='Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@alphasys.com.au',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonEmail='test@alphasys.com.au',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678',
            AS_Unique_Student_Identifier__c='01234'
        );
        insert Accnt;

        List<Profile> pro = [Select Id,Name from Profile where Name='Member Login User' LIMIT 1];
        Account accToUsed = [Select Id,PersonContactId from Account where Id = :Accnt.Id limit 1];
        User indiUser = new User();
        indiUser.ContactId = accToUsed.PersonContactId;
        indiUser.profileid = (pro.size() > 0)?pro[0].Id:null;
        indiUser.FirstName = Accnt.FirstName;
        indiUser.LastName = Accnt.LastName;
        indiUser.Alias =string.valueof(Accnt.FirstName.substring(0,1) + Accnt.LastName.substring(0,2));
        indiUser.Email = 'person@test.com';
        indiUser.Username = 'person@test.com';
        indiUser.CommunityNickname = Accnt.FirstName + Accnt.LastName + AS_commonFunction.generateRandomIntString(2);
        indiUser.emailencodingkey='UTF-8';
        indiUser.languagelocalekey='en_US'; 
        indiUser.localesidkey='en_AU'; 
        indiUser.timezonesidkey='GMT';
        insert indiUser;

        LMS_Instance__c	 LmsInstance = new LMS_Instance__c();
        LmsInstance.Type__c = 'Moodle';
        LmsInstance.Date__c = Date.today();
        LmsInstance.Status__c = 'Active';
        LmsInstance.Token__c = '1234567890';
        LmsInstance.Domain_URL__c = 'https://samplewebsite.com';
        LmsInstance.URL__c = 'https://lms.alphasys.com.au/moodle/';
        insert LmsInstance;

        Training_Plan__c tplan = new Training_Plan__c();
        tplan.AS_Training_Plan_Type__c = 'Australian Pharmacist';
        tplan.Name = 'Testing TPlan';
        tplan.Type__c = 'Public';
        tplan.Status__c = 'Active';
        tplan.AS_LMS__c = 'Moodle Course';
        tplan.AS_LMS_Instance__c = LmsInstance.Id;
        insert tplan;

        Training_Plan_Assignment__c tplanAss2 = new Training_Plan_Assignment__c();
        tplanAss2.User__c = indiUser.Id;
        tplanAss2.Status__c = 'Completed';
        tplanAss2.AS_Result__c = 'Continuing';
        tplanAss2.Training_Plan__c = tplan.Id;
        insert tplanAss2;

        Learning_Package__c learnPA = NEW Learning_Package__c(
            Name = 'Test Learning Package',
            AS_Accreditation_level__c = 'Qualification',
            AS_Number_Electives__c = 2,
            AS_Funding_eligible__c = true
        );
        insert learnPA;

        Enrolment_Form__c enrol = new Enrolment_Form__c(
            RecordTypeId= enrolRecId,
            AS_Account__c = Accnt.Id,
            AS_Learning_Package__c = learnPA.Id,
            AS_Preferred_Name__c='Test Enrolment',
            Enrolment_Status__c='In Progress',
            AS_Employment_Pharmacy_Name__c = 'alphasys pharmacy',
            AS_Email__c = 'Vincent@alphasys.com',
            AS_Employment_State__c = 'NSW',
            AS_Employment_Status__c = 'Full-time',
            Recent_Occupation__c = 'Labourers',
            Industry__c = 'Retail Trade',
            Funded_position__c = true,
            AS_Send_enrollment__c = true,
            AS_Send_enrollment_link__c = true,
            AS_Pending_notification_sent__c = false,
            AS_Enrollment_Last_Modify_Date__c = date.today(),
            AS_Expired_notification_sent__c = false,
            AS_Enrolment_Received_Sent__c = false
            
        );
        insert enrol;

        AS_Enrolled_Unit__c enrolled = new AS_Enrolled_Unit__c();
        enrolled.AS_Enrolment__c = enrol.Id;
        enrolled.AS_Status__c = 'Pending';
        enrolled.AS_Result__c = null;
        enrolled.AS_Training_Plan_Assignment__c = tplanAss2.Id;
        Insert enrolled;

        AsEnrollmentListController.getEnrolUnit( enrolled.Id );
        AsEnrollmentListController.getAccountEnrol( enrol.Id );
        AsEnrollmentListController.getMapEnrolUnit( enrolled.Id );

        System.runAs( indiUser ) {

            User u = [Select Id, ContactId, Name FROM User WHERE Id =: userInfo.getUserId()];

            Account acc = [Select Id FROM Account WHERE PersonContactId =: u.ContactId ];

            System.assertEquals( acc.Id, AsEnrollmentListController.getCurrentUser(), 'got the right user' );

        }

    
    }

}