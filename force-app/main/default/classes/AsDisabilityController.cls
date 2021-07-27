/**
 * @File Name          : AsDisabilityController.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/20/2019, 3:33:07 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/20/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public without sharing class AsDisabilityController {


    /**
     * Get Enrolment Information
     * @par getEnrolmentInfo Method:
     * To get the Enrolment information base of the given record Id, we use "getEnrolmentInfo" method.
     *
     * @param recordID It is the record id of the record, that will be use in the query.
     */
    @AuraEnabled
    public static Enrolment_Form__c getEnrolmentInfo(Id recordID){

        if(recordID != null){
            Enrolment_Form__c getEnrolInfo = [SELECT Id,
                                                    Enrolment_Status__c,
                                                    AS_Employment_Status__c,
                                                    AS_No_Previous_Qualifications__c,
                                                    AS_recognition_of_prior_learning__c,
                                                    AS_Study_Reason__c,
                                                    AS_Employment_Pharmacy_Name__c,
                                                    AS_PSA_ID__c,
                                                    AS_Supervisor_Preceptor_Name__c,
                                                    AS_Employment_Street__c,
                                                    AS_Employment_City__c,
                                                    AS_Employment_State__c,
                                                    AS_Employment_Zip_Postal_Code__c,
                                                    AS_Currently_Enrolled_in_Secondary_Educa__c,
                                                    AS_Highest_Completed_Education__c,
                                                    AS_Details_of_Disability__c,
                                                    AS_Has_Disability__c
                                                    FROM Enrolment_Form__c 
                                                    WHERE Id =: recordID];
            
            return getEnrolInfo; 
        }else return null;
    }

    /**
     * get picklist value for the object field
     *
     * @param fieldname field name to be retrieved
     * @param objectname object field to be retrieved
     * @return List<String> picklist values
     */
    @AuraEnabled
    public static List<String> getPicklistValue( String fieldname,String objectname ) {
        List<String> picklistValues = new List<String>();
        
        //Schema.DescribeFieldResult fieldResult = objectname.fieldname.getDescribe();
        SObjectType objectType = Schema.getGlobalDescribe().get(objectname);
        List<Schema.PicklistEntry> picklistVal = objectType.getDescribe()
                                                       .fields.getMap()
                                                       .get(fieldname)
                                                       .getDescribe().getPickListValues();//fieldResult.getPicklistValues();
       
        if(picklistVal.size() > 0){
            for(Schema.PicklistEntry picklist : picklistVal){
                picklistValues.add(picklist.getValue());
            }
        }
        
        return picklistValues; 
    }

    /**
     * get account fields
     *
     * @param recordID , account id of user
     * @return Account object
     */
    @AuraEnabled
    public static Account getAccountFields(Id recordID){

        if( recordID == null ) return null;

        Account accountArr = [
            SELECT AS_Country_of_Birth__pc,
            AS_City_of_Birth__pc,
            AS_Australian_Citizen__pc,
            AS_Aboriginal_Torres_Strait_Islander__pc,
            AS_BG_Speaks_Languages_Other_Than_Englis__pc,
            AS_Languages_spoken_other_than_English__pc,
            AS_Has_Disability_Impairment_or_Long_Ter__pc,
            AS_disability_type__c,
            AS_Other_Disability_pc__c
            FROM Account 
            WHERE Id =: recordID
        ];
        
        return accountArr; 
    }

    /**
     * Save changes for the disability form
     *
     * @param enrolId enrolment id to be updated
     * @param accId Account Id to be link on newly created enrolment
     * @param enrolRecord enrolment record to be updated
     * @param sendmelink indicator for send link button or natural save button
     * @return enrolment form object being updated
     */
    @AuraEnabled
    public static Enrolment_Form__c saveEnrolChanges( Id enrolId, Id accId, Enrolment_Form__c enrolRecord, Boolean sendmelink ) {
        Enrolment_Form__c enrol = new Enrolment_Form__c();
        enrol = enrolRecord;
        enrol.Id = enrolId;
        enrol.AS_Saved_Enrolment_Form__c = true;
        enrol.AS_Enrolment_Stage__c = 'Page 5: Disability';
        enrol.AS_Enrollment_Last_Modify_Date__c = Datetime.now();
        if( sendmelink ) enrol.AS_Send_enrollment_link__c = true;

        if( enrolId != null ) {
            update enrol;
        } else {
            if( accId != null ) enrol.AS_Account__c = accId;
            insert enrol;
        }
        return enrol;
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

            delete deleteEnrol;
            message = 'Enrolment sucessfully deleted!';
        } else {
            message = 'No record to be deleted!';
        }

        return message;
    }

}