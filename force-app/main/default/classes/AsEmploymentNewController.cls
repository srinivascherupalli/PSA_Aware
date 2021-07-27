/**
 * @File Name          : AsEmploymentNewController.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/20/2019, 3:33:57 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/20/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public without sharing class AsEmploymentNewController {
    
     /**
    *@author Michael Vincent Largo
    *@details AsEmploymentNewController is use in the AsEmploymentNew component as a server side
    *@date October 1, 2019 
    */

    /**
     * Get picklist value
     * @par getPicklistValue Method:
     * To get the picklist value of different picklist field in the component, it use the method called "getPicklistValue". It will return list of string.
     */
    @AuraEnabled
    public static List<String> getPicklistValue(String fieldname,String objectname){
        List<String> picklistValues = new List<String>();
        
        //Schema.DescribeFieldResult fieldResult = objectname.fieldname.getDescribe();
        SObjectType objectType = Schema.getGlobalDescribe().get(objectname);
        List<Schema.PicklistEntry> picklistVal = objectType.getDescribe()
                                                       .fields.getMap()
                                                       .get(fieldname)
                                                       .getDescribe().getPickListValues();//fieldResult.getPicklistValues();
       
        if(picklistVal.size() > 0){
            for(Schema.PicklistEntry picklist : picklistVal){
                picklistValues.add(picklist.getLabel());
            }
        }
        
        return picklistValues; 
    }
    
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
                                              AS_Employment_Pharmacy_Name__c,
                                              AS_Supervisor_Preceptor_Name__c,
                                              AS_Employment_Street__c,
                                              AS_Employment_City__c,
                                              AS_Employment_State__c,
                                              AS_Employment_Zip_Postal_Code__c,
                                              AS_Employment_Property_Name__c,
                                              AS_Employment_Unit_Details__c,
                                              AS_Employment_Street_Number__c,
                                              Recent_Occupation__c,
                                              Industry__c 
                                              FROM Enrolment_Form__c 
                                              WHERE Id =: recordID];
            
            return getEnrolInfo; 
        }else return null;
    }
    
     /**
     * Save Enrolment Information
     * @par saveEnrolmentInfo Method:
     * To save the Enrolment information base of the given record Id, we use "saveEnrolmentInfo" method. This will get all the information of the record in the page.
     *
     * @param enrolRecord It is the record or data of the Enrolment that need to be save or update.
     * @param enrolmentID It is the record id of the Enrolment.
     * @param recordAccID It is the record id of the Account.
     */
    @AuraEnabled
    public static Id saveEnrolmentInfo(Enrolment_Form__c enrolRecord,Id enrolmentID,Id recordAccID, Boolean sendmelink){
        
        if(enrolRecord != null){
            if(enrolmentID != null){
                Enrolment_Form__c enrol = new Enrolment_Form__c();
                enrol = enrolRecord;
                enrol.Id = enrolmentID;
                enrol.AS_Saved_Enrolment_Form__c = true;
                enrol.AS_Enrolment_Stage__c = 'Page 7: Employment Page';
                enrol.AS_Enrollment_Last_Modify_Date__c = Datetime.now();
                if( sendmelink ) enrol.AS_Send_enrollment_link__c = true;
                update enrol;
                return enrol.Id;
                
            }else{
                Enrolment_Form__c enrol = new Enrolment_Form__c();
                enrol = enrolRecord;
                if(recordAccID != null) enrol.AS_Account__c = recordAccID;
                enrol.AS_Saved_Enrolment_Form__c = true;
                enrol.AS_Enrolment_Stage__c = 'Page 7: Employment Page';
                enrol.AS_Enrollment_Last_Modify_Date__c = Datetime.now();
                if( sendmelink ) enrol.AS_Send_enrollment_link__c = true;
                insert enrol;
                return enrol.Id;
            }
        }else return null;
    }

    /**
     * Get Qualification Information
     * @par getQualificationInfo Method:
     * To get the Qualification information base of the given record Id, we use "getQualificationInfo" method.
     *
     * @param QualificationID It is the record id of the Qualification record, that will be use in the query.
     */
    /*@AuraEnabled
    public static List<Qualification__c> getQualificationInfo(Id enrolId) {

        if(enrolId != null){
            List<Qualification__c> getQualifiInfo = [SELECT Id,
                                                    ASQualification_Name__c,
                                                    ASQualification_Level__c,
                                                    ASQualification_Type__c 
                                                    FROM Qualification__c 
                                                    WHERE ASEnrolment_Form__c =: enrolId ORDER BY CreatedDate];
            
            return getQualifiInfo; 
        }else return new List<Qualification__c>();
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