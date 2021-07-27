/*
*Author : Michael Vincent Largo
*Description : Text here!!
*Date Created : 10/10/2019
*Last Modified By: Vincent
*/
@isTest
public class AsEnrolmentFormControllerTest {
    
    @testSetup static void setup() {
        
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
        
        Learning_Package__c learnPA = NEW Learning_Package__c();
        learnPA.Name = 'learning test';
        insert learnPA;
        
        Unit__c unit = new Unit__c();
        unit.AS_Is_Event__c = true;
        unit.AS_State__c = 'NSW';
        insert unit;
        
        
        Learning_Package_Unit__c leanunit = new Learning_Package_Unit__c();
        leanunit.RecordTypeId = learunitcore;
        leanunit.AS_Learning_Package__c = learnPA.Id;
        leanunit.AS_Unit__c= unit.Id;
        leanunit.AS_Order__c = 2;
        insert leanunit;
        
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
        
        Training_Plan__c tplan = new Training_Plan__c();
        tplan.Name = 'tplanName';
        tplan.Type__c = 'RTO';
        insert tplan;
        
        Pre_Training_Review__c pre = new Pre_Training_Review__c(
            Account__c = Accnt.Id,
            Current_Job_Role__c = 'test name',
            Learning_preferences__c = 'test learning',
            Computer_Skills__c= 'Use Email',
            Difficult_Assessment_Methods__c ='Projects',
            Employment_duration_for_current_position__c= '0-3 months',
            Employment_Goals__c= 'test goals',
            Enrolment__c= enrol.Id,
            Government__c= true,
            How_do_you_like_to_learn__c= 'Reading',
            Qualification_Goals__c= 'test qualification',
            S2_S3_Dispensary_Skill__c= 'Yes, S2S3',
            Skills_and_Abilities__c= 'test skils',
            State__c= 'NSW',
            Work_Experience__c= 'test work',
            Support_Required__c= 'Specific equipment'
        ); 
        insert pre;    
        
    }
    
    static testMethod void getAccountInfoTest(){
        
        Account acc =[SELECT Id FROM Account WHERE FirstName = 'Test FName'];
        System.AssertEquals(acc != null, true);
        AsEnrolmentFormController.getAccountInfo(acc.Id);
    }
    
    static testMethod void getEnrolmentInfoTest(){
        
        Enrolment_Form__c enrol =[SELECT Id,AS_Email__c,RecordTypeId FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        System.AssertEquals(enrol != null, true);
        AsEnrolmentFormController.getEnrolmentInfo(enrol.Id);
    }
    
    static testMethod void getLearningPackageInfoTest(){
        Learning_Package__c learn =[SELECT Id,Name FROM Learning_Package__c WHERE Name = 'learning test'];
        System.AssertEquals(learn != null, true);
        AsEnrolmentFormController.getLearningPackageInfo(learn.Id);
    }
    
    static testMethod void getLearningEnrolledUnitInfoTest(){
        
        Learning_Package_Unit__c learnunit =[SELECT Id,Name,AS_Order__c FROM Learning_Package_Unit__c WHERE AS_Order__c = 2];
        System.AssertEquals(learnunit != null, true);
        AsEnrolmentFormController.getLearningEnrolledUnitInfo(learnunit.Id);
    }
    
    static testMethod void getUnitInfoTest(){
        
        Unit__c unit =[SELECT Id,Name FROM Unit__c WHERE AS_State__c = 'NSW'];
        System.AssertEquals(unit != null, true);
        AsEnrolmentFormController.getUnitInfo(unit.Id);
    }
    
    static testMethod void getTrainingPlanInfoTest(){
        
        Training_Plan__c tplan =[SELECT Id,Name,Type__c FROM Training_Plan__c WHERE Name = 'tplanName'];
        System.AssertEquals(tplan != null, true);
        AsEnrolmentFormController.getTrainingPlanInfo(tplan.Id);
    }
    
    static testMethod void getTrainingReviewTest(){
        
        Pre_Training_Review__c preTrain =[SELECT Id,Name FROM Pre_Training_Review__c WHERE Current_Job_Role__c = 'test name'];
        System.AssertEquals(preTrain != null, true);
        AsEnrolmentFormController.getTrainingReview(preTrain.Id);
    }
    
}