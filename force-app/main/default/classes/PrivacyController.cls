/**
 * @File Name          : PrivacyController.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/20/2019, 3:31:11 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/20/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public without sharing class PrivacyController {
    
    @AuraEnabled
    public static Enrolment_Form__c getEnrolmentField(Id enrolId){

        Enrolment_Form__c enrolArr = [SELECT AS_agree_privacy_notice__c, Enrolment_Status__c FROM Enrolment_Form__c WHERE Id =: enrolId];
        
        return enrolArr; 
    }

    @AuraEnabled
    public static void updateEnrolmentField(Id enrolId, Enrolment_Form__c obj ) {
        Enrolment_Form__c enrol = new Enrolment_Form__c();
        enrol = obj;
        enrol.Id = enrolId;
        enrol.AS_Saved_Enrolment_Form__c = true;
        enrol.AS_Enrolment_Stage__c = 'Page 3: Personal Details';
        enrol.AS_Enrollment_Last_Modify_Date__c = Datetime.now();

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