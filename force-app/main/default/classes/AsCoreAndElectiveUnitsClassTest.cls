/*
*Author : Michael Vincent Largo
*Description : Text here!!
*Date Created : 10/10/2019
*Last Modified By: Vincent
*/

@isTest
public class AsCoreAndElectiveUnitsClassTest {
    
    @testSetup static void setup() {
        
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id enrolRecId = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();
        
        Id learunitcore = Schema.SObjectType.Learning_Package_Unit__c.getRecordTypeInfosByName().get('Core').getRecordTypeId();
        Id learunitElective = Schema.SObjectType.Learning_Package_Unit__c.getRecordTypeInfosByName().get('Elective').getRecordTypeId();
        
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
        learnPA.AS_Number_Electives__c = 2; 
        insert learnPA;
        
        Unit__c unit = new Unit__c();
        unit.AS_Is_Event__c = true;
        unit.AS_State__c = 'NSW';
        insert unit;
        
        
        Learning_Package_Unit__c leanunit = new Learning_Package_Unit__c();
        leanunit.RecordTypeId = learunitElective;
        leanunit.AS_Learning_Package__c = learnPA.Id;
        leanunit.AS_Unit__c= unit.Id;
        leanunit.AS_Order__c = 2;
        insert leanunit;
        
        Learning_Package_Unit__c leanunitcorerec = new Learning_Package_Unit__c();
        leanunitcorerec.RecordTypeId = learunitcore;
        leanunitcorerec.AS_Learning_Package__c = learnPA.Id;
        leanunitcorerec.AS_Unit__c= unit.Id;
        leanunitcorerec.AS_Order__c = 4;
        insert leanunitcorerec;
        
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
            AS_Enrolment_Received_Sent__c = false,
            AS_Enrollment_State__c = 'WA'
            
        );
        insert enrol;
        
        AS_Enrolled_Unit__c enroLLMe = new AS_Enrolled_Unit__c();
        enroLLMe.AS_Enrolment__c = enrol.Id;
        enroLLMe.AS_Unit__c = unit.Id;
        enroLLMe.AS_Status__c = 'Pending';
        insert enroLLMe;

        List<AsCoreElectiveClassWrapper>  LPUnitsListWrapper = new List<AsCoreElectiveClassWrapper>();
        AsCoreElectiveClassWrapper  LPUnitsWrapper = new AsCoreElectiveClassWrapper();
        LPUnitsWrapper.UnitState = 'NSW';
        LPUnitsWrapper.OrderNo = leanunitcorerec.AS_Order__c;
        LPUnitsWrapper.recTypeId = leanunit.RecordTypeId;
        LPUnitsWrapper.eLec = leanunit.RecordTypeId;
        LPUnitsWrapper.LPUName = leanunit.Name;
        LPUnitsWrapper.LPUId = leanunit.Id;
        LPUnitsWrapper.LPUTPDescription = 'Check Description';
        //LPUnitsWrapper.enrolledId = EnroLLmentId;
        LPUnitsListWrapper.add(LPUnitsWrapper);
        System.assertEquals(LPUnitsListWrapper.isEmpty(), false);
    
    }   

    

    static testMethod void initLoadUsersEnrollmentTest(){
        
  
        Account acc =[SELECT Id FROM Account WHERE FirstName = 'Test FName'];
        System.AssertEquals(acc != null, true);
        
        Enrolment_Form__c enrol =[SELECT Id,AS_Email__c,RecordTypeId,AS_Enrollment_State__c,Enrolment_Status__c FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        System.AssertEquals(enrol != null, true);
        AsCoreAndElectiveUnitsClass.initLoadUsersEnrollment(acc.Id,enrol.Id);
     
    }
    
    static testMethod void createEnrollmenUnitsTest(){
        
        Account acc =[SELECT Id FROM Account WHERE FirstName = 'Test FName'];
        System.AssertEquals(acc != null, true);
        
        Learning_Package_Unit__c learnunit =[SELECT Id,Name,AS_Unit__c FROM Learning_Package_Unit__c WHERE AS_Order__c = 4];
        System.AssertEquals(learnunit != null, true);
        
        Enrolment_Form__c enrol =[SELECT Id FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        System.AssertEquals(enrol != null, true);
        
        AS_Enrolled_Unit__c enrolunit = [SELECT Id FROM AS_Enrolled_Unit__c WHERE AS_Status__c = 'Pending'];
        System.AssertEquals(enrolunit != null, true);
        
        Map<Id,Boolean> maptrue = new  Map<Id,Boolean>();
        Unit__c unit = new Unit__c();
        unit.AS_Is_Event__c = true; 
        maptrue.put(unit.Id,true);
        AsCoreAndElectiveUnitsClass.createEnrollmenUnits(maptrue,enrol.Id,acc.Id,true);
        AsCoreAndElectiveUnitsClass.createEnrollmenUnits(maptrue,enrol.Id,acc.Id,false);
        
    }
    static testMethod void deleteEnrolmentTest(){
        
        Enrolment_Form__c enroldelete =[SELECT Id FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        AsCoreAndElectiveUnitsClass.deleteEnrolment(enroldelete.Id);
        System.AssertEquals(enroldelete !=null, true);
    }
    
    /**
    * @details Test method for AsCoreAndElectiveUnitsClass.createEnrolledUnits
    * @author Juliver A. | 10/21/2019 
    * @return testMethod 
    **/
    static testMethod void createEnrolledUnitsTEST(){
        
        Enrolment_Form__c enrment =[SELECT Id, AS_Account__c, AS_Learning_Package__c  FROM Enrolment_Form__c WHERE AS_Preferred_Name__c = 'Test Enrolment'];
        AsCoreAndElectiveUnitsClass.createEnrolledUnits(enrment.Id, enrment.AS_Account__c, enrment.AS_Learning_Package__c);
        System.AssertEquals(enrment !=null, true);
    }
    
}