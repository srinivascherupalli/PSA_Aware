/*
*Author : Michael Vincent Largo
*Description : Text here!!
*Date Created : 10/10/2019
*Last Modified By: Vincent
*/
@isTest
public class PreTrainingReviewControllerTest {
    
    @testSetup static void setup() {
        
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
            AS_Unique_Student_Identifier__c='01234',
            AS_Has_Disability_Impairment_or_Long_Ter__pc = true,
            AS_BG_Speaks_Languages_Other_Than_Englis__pc = true,
            AS_disability_type__c = 'Hearing/deaf',
            AS_Other_Disability_pc__c = 'test sample'
            
        );
        
        insert Accnt;
        
        Learning_Package__c learnPA = NEW Learning_Package__c();
        learnPA.Name = 'learning test';
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
    
    static testMethod void getPicklistTest(){
        
        PreTrainingReviewController.getPicklistValue('Computer_Skills__c','Pre_Training_Review__c');
        PreTrainingReviewController.getPicklistValue('Difficult_Assessment_Methods__c','Pre_Training_Review__c');
        PreTrainingReviewController.getPicklistValue('Employment_duration_for_current_position__c','Pre_Training_Review__c');
        PreTrainingReviewController.getPicklistValue('How_do_you_like_to_learn__c','Pre_Training_Review__c');
        PreTrainingReviewController.getPicklistValue('S2_S3_Dispensary_Skill__c','Pre_Training_Review__c');
        PreTrainingReviewController.getPicklistValue('State__c','Pre_Training_Review__c');
        PreTrainingReviewController.getPicklistValue('Support_Required__c','Pre_Training_Review__c');
        
    } 
    
      static testMethod void getPreTrainingReviewInfoTest(){
        
        Pre_Training_Review__c pretrain =[SELECT Id FROM Pre_Training_Review__c WHERE Current_Job_Role__c = 'test name'];
        System.AssertEquals(pretrain != null, true);
        PreTrainingReviewController.getPreTrainingReviewInfo(pretrain.Id);
        PreTrainingReviewController.getPreTrainingReviewInfo(null);
        System.AssertEquals(database.countquery('SELECT '
                                                + 'COUNT()'
                                                +' FROM'
                                                +' Pre_Training_Review__c '
                                                +'WHERE Current_Job_Role__c = \'test name\''),1);
    }
    
    static testMethod void savePreTraininInfoTest(){
        
        Account acc =[SELECT Id FROM Account WHERE FirstName = 'Test FName'];
        System.AssertEquals(acc != null, true);
        
        Enrolment_Form__c enrol =[SELECT Id FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        System.AssertEquals(enrol != null, true);
        
        Pre_Training_Review__c pretrain =[SELECT Id FROM Pre_Training_Review__c WHERE Current_Job_Role__c = 'test name'];
        System.AssertEquals(pretrain != null, true);
        
        Pre_Training_Review__c newpre = new Pre_Training_Review__c();
        newpre.Current_Job_Role__c = 'testsample';
        newpre.Learning_preferences__c = 'test learning';
        
        Enrolment_Form__c newenrol = new Enrolment_Form__c();
        newenrol.AS_Preferred_Name__c = 'My Name';
        newenrol.AS_Send_enrollment_link__c = true;
        PreTrainingReviewController.savePreTraininInfo(newpre,enrol.Id,pretrain.Id,acc.Id,true);
           
        System.AssertEquals(database.countquery('SELECT '
                                                + 'COUNT()'
                                                +' FROM'
                                                +' Pre_Training_Review__c '
                                                +'WHERE Current_Job_Role__c = \'testsample\''),1);
     
        
    }
      static testMethod void getEnrolmentTest(){
        
        Enrolment_Form__c enrol =[SELECT Id FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        System.AssertEquals(enrol != null, true);
        PreTrainingReviewController.getEnrolmentInfo(enrol.Id);
        
        System.AssertEquals(database.countquery('SELECT '
                                                + 'COUNT()'
                                                +' FROM'
                                                +' Enrolment_Form__c '
                                                +'WHERE AS_Preferred_Name__c = \'Test Enrolment\''),1);
    }
    
      static testMethod void getTrainingReviewtTest(){
          
          Pre_Training_Review__c pretrain =[SELECT Id FROM Pre_Training_Review__c WHERE Current_Job_Role__c = 'test name'];
          System.AssertEquals(pretrain != null, true);
          PreTrainingReviewController.getTrainingReview(pretrain.Id);
          
          System.AssertEquals(database.countquery('SELECT '
                                                  + 'COUNT()'
                                                  +' FROM'
                                                  +' Pre_Training_Review__c '
                                                  +'WHERE Current_Job_Role__c = \'test name\''),1);
        
        
    }
}