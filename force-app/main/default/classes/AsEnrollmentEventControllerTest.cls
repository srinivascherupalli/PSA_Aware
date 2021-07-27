@isTest
public class AsEnrollmentEventControllerTest {
    static testMethod void AsEnrollmentEvent() {

        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id enrolRecId = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();
        Id learunitcore = Schema.SObjectType.Learning_Package_Unit__c.getRecordTypeInfosByName().get('Core').getRecordTypeId();
        
        
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

        LMS_Instance__c lmsInst = new LMS_Instance__c();
        lmsInst.Type__c     = 'Moodle';
        lmsInst.Date__c     = Date.today();
        lmsInst.Status__c   = 'Active';
        lmsInst.Domain_URL__c = 'https://lms.alphasys.com.au/moodle/';
        insert lmsInst;


        Training_Plan__c tplan = new Training_Plan__c();
        tplan.Name             = 'tp test';
        tplan.Start_Date__c    = Date.today();
        tplan.End_Date__c      = Date.today().addDays(30);
        tplan.Date_Published__c = Date.today();
        tplan.Status__c        = 'Draft';
        tplan.AS_LMS__c        = 'Moodle Course';
        tplan.Type__c          = 'Public';
        tplan.AS_Include_In_Catalog__c = true;
        //tplan.AS_LMS_Instance__c = lmsInst.Id;
        insert tplan;

        Training_Plan_Section__c AsTplanSec = new Training_Plan_Section__c(
            Name = 'Test Plan Section',
            Order__c = 3,
            Optional__c = true,
            Training_Plan__c = tplan.Id
        );
        insert AsTplanSec;
        
        Learning_Package__c learnPA = NEW Learning_Package__c(
            Name = 'Test Learning Package',
            AS_Accreditation_level__c = 'Qualification',
            AS_Number_Electives__c = 2,
            AS_Funding_eligible__c = true
        );
        insert learnPA;
        
        Unit__c unit = new Unit__c();
        unit.AS_Is_Event__c = true;
        unit.AS_Training_Plan__c = tplan.Id;
        insert unit;

        Learning_Package_Unit__c AsLearnUnit = new Learning_Package_Unit__c(
            RecordTypeId = learunitcore,
            AS_Learning_Package__c = learnPA.Id,
            AS_Unit__c = unit.Id,
            AS_Order__c = 2
        );
        insert AsLearnUnit;

        Id learnmoodlerecId = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        
        Learning__c learn 		= new Learning__c();
        learn.RecordTypeId = learnmoodlerecId;
        learn.Name 				= 'test l';
        learn.AS_Group_1_CPD__c = 100;
        learn.AS_Group_2_CPD__c = 200;
        learn.AS_LMS_type__c   	= 'Activity';
        learn.AS_Activity_Type__c = 'Lesson';
        learn.LMS_Instance__c = lmsInst.Id;
        learn.AS_Training_Plan__c = tplan.Id;
        learn.Description__c = 'test2132';
        learn.Published__c 		= true;
        insert learn;

        Id eventRT = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
 		Campaign cam = new Campaign(
            Name = 'Alphasys Campaign',
            RecordTypeId = eventRT,
            AS_Session__c = true,
            Training_Plan__c = tplan.Id,
            Learning__c = learn.Id,
            AS_Include_in_Portal__c = true
        );
		insert cam;

        AS_Event__c evnt = new AS_Event__c(
            Name = 'Campaign Event',
            AS_Session_Campaign__c = cam.Id,
            AS_Start_Date__c = date.today(),
            AS_End_Date__c = date.today() + 3
        );
        insert evnt;
        
        System.runAs(indiUser) {

            AS_Attendee__c att = new AS_Attendee__c(
                AS_Event__c = evnt.Id,
                AS_Attendee_First_Name__c = indiUser.FirstName,
                AS_Attendee_Last_Name__c = indiUser.LastName,
                AS_Status__c = 'Attending',
                AS_Agrees_to_terms_and_conditions__c = true,
                AS_User__c = indiUser.ContactId,
                AS_Training_Plan__c = tplan.Id
            );
            insert att;
            System.debug('att 1'+tplan.Id);
            System.debug('att 2'+att.AS_Training_Plan__c);
            
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

            Training_Plan_Section_Item__c AsTplanSecItem = new Training_Plan_Section_Item__c(
                Learning__c = learn.Id,
                Order__c = 3,
                Training_Plan_Section__c = AsTplanSec.Id,
                Optional__c = true
            );
            insert AsTplanSecItem;
            System.debug('AsTplanSecItem.Learning__c '+AsTplanSecItem.Learning__c);

            
            Object aa = (Object) tplan.Id;

            Map<String, Object> params = new Map<String, Object>();
                params.put( evnt.Id, aa );

                System.debug('params '+params);

            AsEnrollmentEventController.EventWrapper AsEventWrapper = new AsEnrollmentEventController.EventWrapper();
                AsEventWrapper.eventSession = evnt;
                AsEventWrapper.isAttened = true;
                AsEventWrapper.AttenedId = att.Id;
                AsEventWrapper.isEnabled = ( enrol.Enrolment_Status__c != 'Draft' ? true : false );
                AsEventWrapper.learningPackageUnit = AsLearnUnit;
            AsEnrollmentEventController.loadEvents( enrol.Id );
            AsEnrollmentEventController.createAttendeeFromSession( params, enrol.Id, enrol.AS_Send_enrollment_link__c );
            AsEnrollmentEventController.saveChanges( enrol.Id, enrol.AS_Send_enrollment_link__c );
            AsEnrollmentEventController.deleteEnrolment( enrol.Id );

            System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        }
    }
}