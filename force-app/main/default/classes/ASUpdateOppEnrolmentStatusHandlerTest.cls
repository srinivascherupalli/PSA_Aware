/**
 * @author Ronald Santander
 * @since Sept 18 , 2019
 */

@isTest
public class ASUpdateOppEnrolmentStatusHandlerTest {
    
    @testSetup static void setup() {
        Id oppEDRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Education').getRecordTypeId();
		Id RecordTypeIdPerAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Id enrolRecId = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();
        
        Account Accnt = new Account(
            RecordTypeID=RecordTypeIdPerAccount,
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

        Learning_Package__c learningPack = new Learning_Package__c(Name='Test learning');
        insert learningPack;

        /*Enrolment_Form__c enrol = new Enrolment_Form__c(
            RecordTypeId=enrolRecId,AS_Title__c='Mr',
            AS_Preferred_Name__c='Test Enrolment',
            AS_Learning_Package__c=learningPack.Id,
            Enrolment_Status__c='Draft'
        );
        insert enrol;*/
        
        Enrolment_Form__c enrol = new Enrolment_Form__c(
            RecordTypeId= enrolRecId,
            AS_Account__c = Accnt.Id,
            AS_Learning_Package__c = learningPack.Id,
            AS_Preferred_Name__c='Test Enrolment',
            Enrolment_Status__c='In Progress',
            AS_Employment_Pharmacy_Name__c = 'alphasys pharmacy',
            AS_Email__c = 'Vincent@alphasys.com',
            AS_Employment_State__c = 'NSW',
            AS_Employment_Status__c = 'Full-time',
            Recent_Occupation__c = 'Labourers',
            Industry__c = 'Retail Trade',
            Funded_position__c = true,
            AS_Send_enrollment__c = false,
            AS_Send_enrollment_link__c = true,
            AS_Pending_notification_sent__c = false,
            AS_Enrollment_Last_Modify_Date__c = date.today(),
            AS_Expired_notification_sent__c = false,
            AS_Enrolment_Received_Sent__c = false
            
        );
        insert enrol;


        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.RecordTypeId = oppEDRecordTypeId;
        opp.Amount = 10.00;
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.AS_Enrolment__c = enrol.Id;
        insert opp;

    }

    public static testMethod void updateEnroll(){
        Enrolment_Form__c enrol = [SELECT Id, AS_Send_enrollment__c FROM Enrolment_Form__c];
        Enrolment_Form__c AsEnrolUpdate = new Enrolment_Form__c(
            Id = enrol.Id,
            AS_Send_enrollment__c = true
        );
        update AsEnrolUpdate;

        ASUpdateSentEnrollment AsNew = new ASUpdateSentEnrollment( new ApexPages.StandardController(enrol) );
        //ASUpdateSentEnrollment AsNewUpdate = new ASUpdateSentEnrollment();
        PageReference AsPageRef = AsNew.redirectVF();
        //AsNew.recID = enrol;
    }

    static testMethod void updateOpp(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: 'Test Opp'];
        System.AssertEquals(opp != null, true);

        Opportunity newOpp = new Opportunity();
        newOpp.Id = opp.Id;
        newOpp.StageName = 'Closed Won';
        update newOpp;

        Enrolment_Form__c enrol = [SELECT Enrolment_Status__c FROM Enrolment_Form__c];
        System.AssertEquals(enrol.Enrolment_Status__c, 'In Progress');
    }

    static testMethod void updateOppAmount(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name =: 'Test Opp'];
        System.AssertEquals(opp != null, true);

        Opportunity newOpp = new Opportunity();
        newOpp.Id = opp.Id;
        newOpp.Amount = 0.00;
        update newOpp;
    }
}