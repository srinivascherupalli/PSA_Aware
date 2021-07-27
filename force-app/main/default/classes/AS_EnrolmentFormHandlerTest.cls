/*Author : Michael Vincent Largo
*Description :  This class is a test class  in Enrolment form that will update the enrolled unit that connected to enrolment form that being updated.
*Date Created : September 18,2019
*Last Modified By : 
*Date Last Modified :
*/
@isTest
public class AS_EnrolmentFormHandlerTest {
    @isTest 
    public static void testMethod1() {
        
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id psaenrolment = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();
        Id learningpackage = Schema.SObjectType.Learning_Package_Unit__c.getRecordTypeInfosByName().get('Elective').getRecordTypeId();
        Id OppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('RTO Enrolment').getRecordTypeId();
        
        Account acc = new Account(
            FirstName = 'Sample Person',
            LastName = 'Account',
            PersonEmail = 'person@test.com',
            RecordTypeId = personAccountId,
            AS_Unique_Student_Identifier__c = '12312'
        );
        insert acc;

        Opportunity opps = new Opportunity(
            RecordTypeId = OppRecTypeId,
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            CloseDate = Date.today(),
            StageName = 'Closed Won'
        );
        insert opps;

        List<Profile> pro = [Select Id,Name from Profile where Name='Member Login User' LIMIT 1];
        Account accToUsed = [Select Id,PersonContactId from Account where Id = :acc.Id limit 1];
        User indiUser = new User(
            ContactId = accToUsed.PersonContactId,
            profileid = (pro.size() > 0)?pro[0].Id:null,
            FirstName = acc.FirstName,
            LastName = acc.LastName,
            Alias =string.valueof(acc.FirstName.substring(0,1) + acc.LastName.substring(0,2)),
            Email = 'person@test.com',
            Username = 'person@test.com',
            CommunityNickname = acc.FirstName + acc.LastName + AS_commonFunction.generateRandomIntString(2),
            emailencodingkey='UTF-8',
            languagelocalekey='en_US', 
            localesidkey='en_AU', 
            timezonesidkey='GMT'
        );
        insert indiUser;

        LMS_Instance__c	 LmsInstance = new LMS_Instance__c(
            Type__c = 'Moodle',
            Date__c = Date.today(),
            Status__c = 'Active',
            Token__c = '1234567890',
            Domain_URL__c = 'https://samplewebsite.com',
            URL__c = 'https://lms.alphasys.com.au/moodle/'
        );
        insert LmsInstance;
        
        Training_Plan__c tplan1 = new Training_Plan__c(
            Name = 'Testing TPlan',
            AS_Training_Plan_Type__c = 'Australian Pharmacist',
            Type__c = 'RTO',
            Status__c = 'Draft',
            AS_LMS__c = 'Moodle Course',
            Start_Date__c = date.today(),
            AS_Include_In_Catalog__c = true,
            AS_Delivery_Method__c = 'Online module',
            Enable_Self_Registration__c = true,
            End_Date__c = date.today() + 2,
            Date_Published__c = date.today(),
            AS_LMS_Instance__c = LmsInstance.Id
        );
        insert tplan1;

        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;
        tplan.Self_Registration_Access__c = 'Public';
        update tplan;

        Training_Plan_Assignment__c tplanAss2 = new Training_Plan_Assignment__c(
            User__c = indiUser.Id,
            Status__c = 'Completed',
            AS_Result__c = 'Continuing',
            Training_Plan__c = tplan.Id
        );
        insert tplanAss2;
        
        Learning_Package__c AsLearnPack = new Learning_Package__c(
            Name = 'Test Learning Package',
            AS_Accreditation_level__c = 'Qualification',
            AS_Number_Electives__c = 2,
            AS_Funding_eligible__c = true
        );
        insert AsLearnPack;

        Enrolment_Form__c enrolform = new Enrolment_Form__c(
            RecordTypeId = psaenrolment,
            AS_Account__c = acc.Id,
            Enrolment_Status__c = 'Approved',
            AS_Learning_Package__c = AsLearnPack.Id,
            AS_Processed__c = false
        );
        insert enrolform;

        Unit__c AsUnit = new Unit__c(
            Name = 'Test Unit',
            AS_Training_Plan__c = tplan.Id,
            AS_Is_Event__c = true,
            AS_Vettrak_Unit_ID__c = '123331'
        );
        insert AsUnit;

        Learning_Package_Unit__c AsLeaningPackUnit = new Learning_Package_Unit__c(
            RecordTypeId = learningpackage,
            AS_Unit__c = AsUnit.Id,
            AS_Learning_Package__c = AsLearnPack.Id,
            AS_Order__c = 20
        );
        insert AsLeaningPackUnit;
        
        System.debug('AsEnrolUnit '+AsUnit.AS_Training_Plan__c);

        AS_Enrolled_Unit__c AsEnrolUnit = new AS_Enrolled_Unit__c(
            AS_Unit__c = AsUnit.Id,
            AS_Enrolment__c = enrolform.Id,
            AS_Status__c = 'Pending',
            AS_Result__c = 'Continuing'
        );
        insert AsEnrolUnit;

        AsEnrolUnit.Id = AsEnrolUnit.Id;
        AsEnrolUnit.AS_Status__c = 'Enrolled';
        AsEnrolUnit.AS_Completed_On__c = date.today();
        update AsEnrolUnit;

        Training_Plan_Section__c AsTrainingSec = new Training_Plan_Section__c (
            Optional__c = true,
            Order__c = 2,
            Training_Plan__c = tplan.Id
        );
        insert AsTrainingSec;

        Id AsLearnigRecType = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Quiz').getRecordTypeId();

        Learning__c AsLearning = new Learning__c(
            RecordTypeId = AsLearnigRecType,
            Name = 'Test Learning',
            Published__c = true,
            LMS_Instance__c = LmsInstance.Id
        );
        insert AsLearning;

        Training_Plan_Section_Item__c AstrainingSecItem = new Training_Plan_Section_Item__c(
            Learning__c = AsLearning.Id,
            Optional__c = true,
            Order__c = 3,
            Training_Plan_Section__c = AsTrainingSec.Id
        );
        insert AstrainingSecItem;

        Learning_Assignment__c AsLearningAss = new Learning_Assignment__c(
            Progress__c = 'In Progress',
            Learning__c = AsLearning.Id,
            LMS_Instance__c = LmsInstance.Id,
            Training_Plan_Section__c = AsTrainingSec.Id,
            Training_Plan__c = tplan.Id,
            Training_Plan_Section_Item__c = AstrainingSecItem.Id,
            User__c = indiUser.Id
        );
        insert AsLearningAss;
        
        //String genRandStringNo = AS_EnrolmentFormHandler.generateRandomNumber();
        
        map<Id, Id> AsenrollementUnitMap = new map<Id, Id>();
        AsenrollementUnitMap.put(AsEnrolUnit.Id, AsEnrolUnit.Id);

        set<Id> AsindiUser = new Set<ID>();
        AsindiUser.add( indiUser.Id );

        set<Id> Astplan1 = new Set<ID>();
        Astplan1.add( tplan1.Id );

        AS_EnrolmentFormHandler.CreateTraiingplanAssignmentBulk(AsindiUser, Astplan1, AsenrollementUnitMap);

        enrolform.Id = enrolform.Id;
        enrolform.Enrolment_Status__c = 'Approved';
        update enrolform;


    }

}