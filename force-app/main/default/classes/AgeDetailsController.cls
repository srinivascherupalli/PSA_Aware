/**
 * @File Name          : AgeDetailsController.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/20/2019, 3:22:06 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/20/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public without sharing class AgeDetailsController {

    @AuraEnabled
     public static Account getAccountInfo(Id recordID){

        Account getEnrolInfo = [
            SELECT Id,
            Age__c
            FROM Account 
            WHERE Id =: recordID
        ];
        
        return getEnrolInfo; 
    }

    @AuraEnabled
    public static Enrolment_Form__c getEnrolmentInfo(Id recordID){

        Enrolment_Form__c getEnrolInfo = [
            SELECT Id,
            AS_Parent_Guardian_Name__c,
            AS_Parent_Guardian_Phone_Number__c,
            AS_Parent_Guardian_Email__c,
            As_over_age__c,
            Enrolment_Status__c
            FROM Enrolment_Form__c 
            WHERE Id =: recordID
        ];

        return getEnrolInfo; 
    }

    @AuraEnabled
    public static void updateEnrolment(Id recordID, Enrolment_Form__c objArr, Boolean isEmail){

        Enrolment_Form__c enrol = new Enrolment_Form__c();
        enrol = ObjArr;
        enrol.Id = recordID;
        enrol.AS_Saved_Enrolment_Form__c = true;
        enrol.AS_Enrolment_Stage__c = 'Page 2: Privacy Notice';
        enrol.AS_Enrollment_Last_Modify_Date__c = Datetime.now();

        if( isEmail ) enrol.AS_Send_enrollment_link__c = true;

        update enrol;
    }
    @AuraEnabled
    public static String deleteEnrolment( Id enrolId ) {

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