@isTest
public class languageCulturalDiversityControllerTest {
    
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
    }
    
    static testMethod void getPicklistTest(){
        
        languageCulturalDiversityController.getPicklistValue('AS_BG_Speaks_Languages_Other_Than_Englis__pc','Account');
        languageCulturalDiversityController.getPicklistValue('AS_disability_type__c','Account');
        languageCulturalDiversityController.getPicklistValue('AS_Employment_Status__c','Enrolment_Form__c');
        
    } 
    
    static testMethod void updateFieldAccountTest(){
        
        Account accrec =[SELECT Id FROM Account WHERE FirstName = 'Test FName'];
        System.AssertEquals(accrec != null, true);
        
        Account newacc = new Account();
        newacc.Id = accrec.Id;
        newacc.FirstName ='Test FNameUpdate';
        newacc.LastName ='Test LName';
        languageCulturalDiversityController.updateFieldAccount(accrec,newacc.Id);
        
    } 
    
    static testMethod void getAccountFieldsTest(){
        
        Account acc =[SELECT Id FROM Account WHERE FirstName = 'Test FName'];
        System.AssertEquals(acc != null, true);
        languageCulturalDiversityController.getAccountFields(acc.Id);
        System.AssertEquals(database.countquery('SELECT '
                                                + 'COUNT()'
                                                +' FROM'
                                                +' Account '
                                                +'WHERE FirstName = \'Test FName\''),1);
    }
    
    static testMethod void getEnrolmentInfoTest(){
        
        Enrolment_Form__c enrol =[SELECT Id FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        System.AssertEquals(enrol != null, true);
        languageCulturalDiversityController.getEnrolmentInfo(enrol.Id);
        System.AssertEquals(database.countquery('SELECT '
                                                + 'COUNT()'
                                                +' FROM'
                                                +' Enrolment_Form__c '
                                                +'WHERE AS_Preferred_Name__c = \'Test Enrolment\''),1);
        
    }
    
    static testMethod void updateEnrolmentInfoTest(){
        
        Enrolment_Form__c enrol =[SELECT Id FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        System.AssertEquals(enrol != null, true);
        
        Enrolment_Form__c newenrol = new Enrolment_Form__c();
        newenrol.AS_Preferred_Name__c = 'My Name';
        newenrol.AS_Send_enrollment_link__c = true;
        languageCulturalDiversityController.updateEnrolmentInfo(enrol.Id,newenrol,true);
        
        System.AssertEquals(database.countquery('SELECT '
                                                + 'COUNT()'
                                                +' FROM'
                                                +' Enrolment_Form__c '
                                                +'WHERE AS_Preferred_Name__c = \'My Name\''),1);
        
    }
    
    static testMethod void deleteEnrolmentTest(){
        
        Enrolment_Form__c enroldelete =[SELECT Id FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        languageCulturalDiversityController.deleteEnrolment(enroldelete.Id);
        System.AssertEquals(enroldelete !=null, true);
    } 
    
}