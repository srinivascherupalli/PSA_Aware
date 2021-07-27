/**
    *@author vincent@alphasys.com.au
    *@details Test class for AsEducation Lightning component
    *@date Oct 9, 2019 
    */

    /**
     * get picklist value for the object field
     *
     * @param fieldname field name to be retrieved
     * @param objectname object field to be retrieved
     * @return List<String> picklist values
     */
@isTest
public class AsEducationControllerTest {
    
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
        
        Qualification__c qualification = new Qualification__c(
            Name='Test qualification',
            ASQualification_Name__c='Test qualification');
        insert qualification;
        
    }
    
    static testMethod void getPicklistTest(){
        /*enrolment form picklist*/
        AsEducationController.getPicklistValue('AS_Highest_Completed_Education__c','Enrolment_Form__c');
        AsEducationController.getPicklistValue('AS_Study_Reason__c','Enrolment_Form__c');
        /*qualification picklist*/
        AsEducationController.getPicklistValue('ASQualification_Level__c','Qualification__c');
        AsEducationController.getPicklistValue('ASQualification_Type__c','Qualification__c');
        
    }
    
    static testMethod void getEnrolmentInfoTest(){
        
        Enrolment_Form__c enrol =[SELECT Id,AS_Email__c,RecordTypeId FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        System.AssertEquals(enrol != null, true);
        AsEducationController.getEnrolmentInfo(enrol.Id);
    }
    
    static testMethod void getQualificationTest(){
        
        Qualification__c quali =[SELECT Id FROM Qualification__c WHERE Name = 'Test qualification'];
        System.AssertEquals(quali != null, true);
        AsEducationController.getQualificationInfo(quali.Id);
        
        List<Qualification__c>  qualist = [SELECT Id,ASQualification_Name__c FROM Qualification__c WHERE Name = 'Test qualification'];
        System.AssertEquals(qualist != null, true);
    }
    
    static testMethod void deleteEnrolmentTest(){ 
        
        Enrolment_Form__c enroldelete =[SELECT Id FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        AsEducationController.deleteEnrolment(enroldelete.Id);
        System.AssertEquals(enroldelete !=null, true);
    }
    
    static testMethod void saveChangesReturnTest(){
        
        Account acc =[SELECT Id FROM Account WHERE FirstName = 'Test FName'];
        System.AssertEquals(acc != null, true);
        
        Enrolment_Form__c enrol =[SELECT Id FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        System.AssertEquals(enrol != null, true);
        
        List<Qualification__c> quali =[SELECT Id,ASQualification_Type__c,ASQualification_Name__c FROM Qualification__c WHERE Name = 'Test qualification'];
        System.AssertEquals(quali != null, true);
        
        Enrolment_Form__c newenrol = new Enrolment_Form__c();
        newenrol.AS_Preferred_Name__c = 'My Fname';
        newenrol.AS_Send_enrollment_link__c = true;
        AsEducationController.saveChanges(enrol.Id,newenrol,quali,acc.Id,true);
        
        System.AssertEquals(database.countquery('SELECT '
                                                + 'COUNT()'
                                                +' FROM'
                                                +' Enrolment_Form__c '
                                                +'WHERE AS_Preferred_Name__c = \'My Fname\''),1);
        
        List<Qualification__c> qlist = new List<Qualification__c>();
        if (quali !=null && !quali.isEmpty()){
            
            Qualification__c newqualifi = new Qualification__c();
            newqualifi.Name = 'International';
            newqualifi.ASQualification_Name__c = 'International';
            newqualifi.ASQualification_Type__c = 'International';
            qlist.add(newqualifi);
        }
        AsEducationController.saveChanges(enrol.Id,newenrol,qlist,acc.Id,true);
        
        System.AssertEquals(database.countquery('SELECT '
                                                + 'COUNT()'
                                                +' FROM'
                                                +' Qualification__c '
                                                +'WHERE Name = \'International\''),1);
        
    }
    
    static testMethod void saveEnrolmentNullIdTest(){
        
        Learning_Package__c learn =[SELECT Id,Name FROM Learning_Package__c WHERE Name = 'learning test'];
        System.AssertEquals(learn != null, true);
        
        Account acc =[SELECT Id FROM Account WHERE FirstName = 'Test FName'];
        System.AssertEquals(acc != null, true);
        
        List<Qualification__c> quali =[SELECT Id,ASQualification_Name__c,Name FROM Qualification__c WHERE Name = 'Test qualification'];
        System.AssertEquals(quali != null, true);  
        
        Enrolment_Form__c newenrol = new Enrolment_Form__c();
        newenrol.AS_Preferred_Name__c   = 'my Fname null';
        newenrol.Enrolment_Status__c    ='In Progress';
        newenrol.AS_Account__c = acc.Id;
        newenrol.AS_Learning_Package__c = learn.Id;
        newenrol.AS_Send_enrollment_link__c = true;
        newenrol.AS_Email__c = 'Vincent@alphasys.com';
        AsEducationController.saveChanges(null,newenrol,quali,acc.Id,true);
        
        System.AssertEquals(database.countquery('SELECT '
                                                + 'COUNT()'
                                                +' FROM'
                                                +' Enrolment_Form__c '
                                                +'WHERE AS_Preferred_Name__c = \'my Fname null\''),1);
    }
    
}