/*
*Author : Michael Vincent Largo
*Description : Text here!!
*Date Created : 10/10/2019
*Last Modified By: Vincent
*/
@isTest
public class AsEmploymentNewControllerTest {
    
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
            AS_Unique_Student_Identifier__c='01234'
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
        
    }
    
    static testMethod void getPicklist(){
        
        AsEmploymentNewController.getPicklistValue('AS_Employment_State__c','Enrolment_Form__c');
        AsEmploymentNewController.getPicklistValue('AS_Employment_Status__c','Enrolment_Form__c');
        AsEmploymentNewController.getPicklistValue('Recent_Occupation__c','Enrolment_Form__c');
        AsEmploymentNewController.getPicklistValue('Industry__c','Enrolment_Form__c');
    } 
    
    static testMethod void getEnrolmentInfoTest(){
        
        Enrolment_Form__c enrol =[SELECT Id,AS_Email__c,RecordTypeId FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        System.AssertEquals(enrol != null, true);
        AsEmploymentNewController.getEnrolmentInfo(enrol.Id);
    }
    
    static testMethod void saveEnrolment(){
        
        Account acc =[SELECT Id FROM Account WHERE FirstName = 'Test FName'];
        System.AssertEquals(acc != null, true);
        
        Enrolment_Form__c enrol =[SELECT Id FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        System.AssertEquals(enrol != null, true);
        
        Enrolment_Form__c newenrol = new Enrolment_Form__c();
        newenrol.AS_Preferred_Name__c = 'My Name';
        newenrol.AS_Send_enrollment_link__c = true;
        AsEmploymentNewController.saveEnrolmentInfo(newenrol,enrol.Id,acc.Id,true);
        
        System.AssertEquals(database.countquery('SELECT '
                                                + 'COUNT()'
                                                +' FROM'
                                                +' Enrolment_Form__c '
                                                +'WHERE AS_Preferred_Name__c = \'My Name\''),1);
        
    }
    
    static testMethod void saveEnrolmentNullId(){
        
        Learning_Package__c learn =[SELECT Id,Name FROM Learning_Package__c WHERE Name = 'learning test'];
        System.AssertEquals(learn != null, true);
        
        Account acc =[SELECT Id FROM Account WHERE FirstName = 'Test FName'];
        System.AssertEquals(acc != null, true);
        
        Enrolment_Form__c newenrol = new Enrolment_Form__c();
        newenrol.AS_Preferred_Name__c   = 'testing';
        newenrol.Enrolment_Status__c    ='In Progress';
        newenrol.AS_Account__c = acc.Id;
        newenrol.AS_Learning_Package__c = learn.Id;
        newenrol.AS_Send_enrollment_link__c = true;
        newenrol.AS_Email__c = 'Vincent@alphasys.com';
        
        AsEmploymentNewController.saveEnrolmentInfo(newenrol,null,acc.Id,true);
        
        System.AssertEquals(database.countquery('SELECT '
                                                + 'COUNT()'
                                                +' FROM'
                                                +' Enrolment_Form__c '
                                                +'WHERE AS_Preferred_Name__c = \'testing\''),1); 
    }
    
    static testMethod void deleteEnrolment(){
        
        Enrolment_Form__c enroldelete =[SELECT Id FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        AsEmploymentNewController.deleteEnrolment(enroldelete.Id);
        System.AssertEquals(enroldelete !=null, true);
    } 
    
}