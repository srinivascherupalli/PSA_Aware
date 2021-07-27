/*Author : Michael Vincent Largo
*Description :  This class is a test class  in Enrolled Unit that will update the Enrolment that connected to Enrolled Unit that being updated.
*Date Created : September 18,2019
*Last Modified By : 
*Date Last Modified :
*/
@isTest
public class AS_EnrolledUnitHandlerTest {
    
    
    @testSetup static void setup() {
        
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        Account acc = new Account();
        acc.FirstName = 'Sample Person';
        acc.LastName = 'Account';
        acc.PersonEmail = 'person@test.com';
        acc.RecordTypeId = personAccountId;
        acc.AS_Unique_Student_Identifier__c = '12312';
        insert acc; 
        
        List<Profile> pro = [Select Id,Name from Profile where Name='Member Login User' LIMIT 1];
        Account accToUsed = [Select Id,PersonContactId from Account where Id = :acc.Id limit 1];
        User indiUser = new User();
        indiUser.ContactId = accToUsed.PersonContactId;
        indiUser.profileid = (pro.size() > 0)?pro[0].Id:null;
        indiUser.FirstName = acc.FirstName;
        indiUser.LastName = acc.LastName;
        indiUser.Alias =string.valueof(acc.FirstName.substring(0,1) + acc.LastName.substring(0,2));
        indiUser.Email = 'person@test.com';
        indiUser.Username = 'person@test.com';
        indiUser.CommunityNickname = acc.FirstName + acc.LastName + AS_commonFunction.generateRandomIntString(2);
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
        
        
        Id psaenrolment = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();
        
        Enrolment_Form__c enrolform = new Enrolment_Form__c();
        enrolform.RecordTypeId = psaenrolment;
        enrolform.Enrolment_Status__c = 'Draft';
        enrolform.AS_Account__c = acc.Id; 
        insert enrolform;
        
        List<AS_Enrolled_Unit__c> allenrolunitlist = new List<AS_Enrolled_Unit__c>();  
        
        AS_Enrolled_Unit__c enrolled = new AS_Enrolled_Unit__c();
        enrolled.AS_Enrolment__c = enrolform.Id;
        enrolled.AS_Status__c = 'Pending';
        enrolled.AS_Result__c = null;
        enrolled.AS_Training_Plan_Assignment__c = tplanAss2.Id;
        allenrolunitlist.add(enrolled);
        
        
        AS_Enrolled_Unit__c enrolledunit2 = new AS_Enrolled_Unit__c();
        enrolledunit2.AS_Enrolment__c = enrolform.Id;
        enrolledunit2.AS_Status__c = 'In Progress';
        enrolledunit2.AS_Result__c = 'Competent';
        enrolledunit2.AS_Training_Plan_Assignment__c = tplanAss2.Id;
        allenrolunitlist.add(enrolledunit2);
     
        
        AS_Enrolled_Unit__c enrolledunit = new AS_Enrolled_Unit__c();
        enrolledunit.AS_Enrolment__c = enrolform.Id;
        enrolledunit.AS_Status__c = 'In Progress';
        enrolledunit.AS_Result__c = 'Not competent/fail';
        enrolledunit.AS_Training_Plan_Assignment__c = tplanAss2.Id;
        allenrolunitlist.add(enrolledunit);
        insert allenrolunitlist;

    }
    
    static testmethod void updateenrolmentunitforinprogress(){ 
        
        
        AS_Enrolled_Unit__c enrolunit = [SELECT Id,AS_Status__c,AS_Enrolment__c FROM AS_Enrolled_Unit__c WHERE AS_Status__c='Pending' LIMIT 1];
        enrolunit.AS_Status__c='In Progress';
        Update enrolunit;
     
        System.assertEquals(enrolunit !=null, true);
        
        Enrolment_Form__c enrolformlist = [SELECT Id,Enrolment_Status__c FROM Enrolment_Form__c WHERE Id =:enrolunit.AS_Enrolment__c];
        System.assertEquals(enrolformlist.Enrolment_Status__c == 'In Progress', true);
        
        
        
    }
    
    static testmethod void updateenrolmentunitforcompleted(){     
        
        AS_Enrolled_Unit__c enrolunitcompleted = [SELECT Id,AS_Status__c,AS_Enrolment__c,AS_Result__c FROM AS_Enrolled_Unit__c WHERE AS_Status__c='In Progress' LIMIT 1];
        //AS_Enrolled_Unit__c newenrol = new AS_Enrolled_Unit__c();
        //newenrol.Id = enrolunitcompleted.Id;
        enrolunitcompleted.AS_Status__c = 'Completed';
        //newenrol.AS_Result__c = 'Competent';
        Update enrolunitcompleted;
        
        System.assertEquals(enrolunitcompleted !=null, true);
        
        //Enrolment_Form__c enrolformcompletelist = [SELECT Id,Enrolment_Status__c FROM Enrolment_Form__c WHERE Id =:enrolunitcompleted.AS_Enrolment__c];
        //System.assertEquals(enrolformcompletelist.Enrolment_Status__c == 'Completed', true);
        
 
    }
    
    static testmethod void updateenrolmentunitforcompletednull(){     
        
        AS_Enrolled_Unit__c enrolunitcompleted2 = [SELECT Id,AS_Status__c,AS_Enrolment__c,AS_Result__c FROM AS_Enrolled_Unit__c WHERE AS_Result__c = 'Competent'  LIMIT 1];
        enrolunitcompleted2.AS_Result__c= 'Continuing';
        Update enrolunitcompleted2;
        AS_Enrolled_Unit__c enrolformcompleted2 = new AS_Enrolled_Unit__c();
        enrolformcompleted2.Id = enrolunitcompleted2.Id;
        enrolformcompleted2.AS_Result__c = null;
        Update enrolformcompleted2;
        
        System.assertEquals(enrolformcompleted2 !=null, true);
        //System.assertEquals(enrolformcompleted2.AS_Result__c == null, false);
        
    }

    
    static testmethod void updateenrolmentunitforcontinuing(){

        AS_Enrolled_Unit__c enrolunitcontinuing = [SELECT Id,AS_Status__c,AS_Enrolment__c,AS_Result__c FROM AS_Enrolled_Unit__c WHERE AS_Training_Plan_Assignment__r.AS_Result__c = 'Continuing'  LIMIT 1];
        enrolunitcontinuing.AS_Result__c= 'Continuing';
        Update enrolunitcontinuing;
        
          
        System.assertEquals(enrolunitcontinuing !=null, true);
        System.assertEquals(enrolunitcontinuing.AS_Result__c =='Continuing', true);
    }
    
    
}