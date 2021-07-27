/**
 * @File Name          : declarationController.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/20/2019, 3:36:58 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/20/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public without sharing class declarationController {
    
    @AuraEnabled
    public static void saveSignature(Id accountId, Id enrolId, String signatureBody, Enrolment_Form__c permissionPub, Account optedout, Boolean sendmelink){

        //system.debug('signatureBody==>' +signatureBody);
        Attachment a = new Attachment();
        a.ParentId = enrolId; //'0019D000005AFyBQAW';
        a.Body = EncodingUtil.base64Decode(signatureBody);
        a.ContentType = 'image/png';
        a.Name = enrolId + '-signature.png';
        insert a;

        Enrolment_Form__c enrol = new Enrolment_Form__c();
        enrol = permissionPub;
        enrol.Id = enrolId;
        enrol.AS_Saved_Enrolment_Form__c = true;
        enrol.AS_Enrolment_Stage__c = 'Page 12: Student Declaration and Consent';
        enrol.AS_Enrollment_Last_Modify_Date__c = Datetime.now();
        if( sendmelink ) enrol.AS_Send_enrollment_link__c = true;
        if( !sendmelink ) enrol.AS_Enrolment_Form_Compliance_Date__c = Date.today();
        if( !sendmelink ) enrol.Enrolment_Status__c = 'Pending Payment';
        update enrol;
         
        Account acc = new Account();
        acc = optedout;
        acc.Id = accountId;
        update acc;
    }
    @AuraEnabled
    public static Enrolment_Form__c getFieldEnrolState(Id recordID){

        if( recordID == null ) return null;

        Enrolment_Form__c enrolArr = [
            SELECT AS_Enrollment_State__c,
            AS_Permission_to_Publish__c,
            Enrolment_Status__c
            FROM Enrolment_Form__c 
            WHERE Id =: recordID
        ];
        
        return enrolArr; 
    }
    @AuraEnabled
    public static Account getFieldAccount(Id accountID){

        if( accountID == null ) return null;

        Account accArr = [
            SELECT PersonHasOptedOutOfEmail
            FROM Account 
            WHERE Id =: accountID
        ];
        
        return accArr; 
    }
    
    /**
     * callback handler for cancel button (delete enrolment record)
     *
     * @param enrolId enrolment id to be deleted
     */
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

            //delete deleteEnrol;
            message = 'Enrolment sucessfully deleted!';
        } else {
            message = 'No record to be deleted!';
        }

        return message;
    }
}