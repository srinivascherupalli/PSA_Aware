/**
 * @File Name          : languageCulturalDiversityController.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/20/2019, 3:32:49 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/20/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public without sharing class languageCulturalDiversityController {
    
    @AuraEnabled
    public static Id updateFieldAccount(Account dataArr,Id recordId){
        
        List<String> newArr = new List<String>();
        
         Account acc = new Account();
        acc = dataArr;
        acc.Id = recordId;
        update acc;
        return acc.Id; 
      
    }

    @AuraEnabled
    public static List<String> getPickListValue(String fieldname,String objectname) {

        List<String> picklistValues = new List<String>();

        SObjectType objectType = Schema.getGlobalDescribe().get(objectname);
        List<Schema.PicklistEntry> picklistVal = objectType.getDescribe().fields.getMap().get(fieldname).getDescribe().getPickListValues();
       
        if(picklistVal.size() > 0){
            for(Schema.PicklistEntry picklist : picklistVal){
                picklistValues.add(picklist.getValue());
            }
        }
        
        return picklistValues; 
    }

    @AuraEnabled
    public static Account getAccountFields(Id recordID){

        Account accountArr = [
            SELECT Id,
            AS_Country_of_Birth__pc,
            AS_City_of_Birth__pc,
            AS_Australian_Citizen__pc,
            AS_Aboriginal_Torres_Strait_Islander__pc,
            AS_BG_Speaks_Languages_Other_Than_Englis__pc,
            AS_Languages_spoken_other_than_English__pc
            FROM Account 
            WHERE Id =: recordID
        ];
        
        return accountArr; 
    }

    @AuraEnabled
     public static Enrolment_Form__c getEnrolmentInfo(Id recordID){

        Enrolment_Form__c getEnrolInfo = [
            SELECT Id,
            AS_Country_of_Birth__c,
            AS_City_of_Birth__c,
            Enrolment_Status__c,
            AS_Languages_spoken_other_than_English__c,
            AS_Australian_Citizen__c,
            AS_Aboriginal_or_Torres_Strait_Islander__c,
            AS_BG_Speaks_Languages_Other_Than_Englis__c    
            FROM Enrolment_Form__c 
            WHERE Id =: recordID
        ];
        
        return getEnrolInfo; 
    }
    
    @AuraEnabled
    public static void updateEnrolmentInfo(Id recordID, Enrolment_Form__c obj, Boolean isEmail){
        Enrolment_Form__c enrol = new Enrolment_Form__c();
        enrol = obj;
        enrol.Id = recordID;
        enrol.AS_Saved_Enrolment_Form__c = true;
        enrol.AS_Enrolment_Stage__c = 'Page 5: Disability';
        enrol.AS_Enrollment_Last_Modify_Date__c = Date.today();
        if( isEmail ) enrol.AS_Send_enrollment_link__c = true;
        update enrol;
    }

    @AuraEnabled
    public static String deleteEnrolment(Id enrolId){

       String message = '';

        List<Enrolment_Form__c> deleteEnrol = new List<Enrolment_Form__c>();

        if( enrolId != null ) {
            List<Enrolment_Form__c> getEnrolInfo = [SELECT Id FROM Enrolment_Form__c 
                                                    WHERE Id =: enrolId AND Enrolment_Status__c = 'Draft'];

            if ( !getEnrolInfo.isEmpty() ) {
                deleteEnrol.addAll( getEnrolInfo );
            }
 
        }

        if ( !deleteEnrol.isEmpty() ) {

            delete deleteEnrol;
            message = 'Enrolment sucessfully deleted!';
        } else {
            message = 'No record to be deleted!';
        }

        return message;
    }

}