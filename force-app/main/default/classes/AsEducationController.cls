/**
 * @File Name          : AsEducationController.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/20/2019, 3:33:26 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/20/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public without sharing class AsEducationController {

    /**
    *@author danryl@alphasys.com.au
    *@details controller for AsEducation Lightning component
    *@date Oct 1, 2019 
    */

    /**
     * get picklist value for the object field
     *
     * @param fieldname field name to be retrieved
     * @param objectname object field to be retrieved
     * @return List<String> picklist values
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
                picklistValues.add(picklist.getValue());
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
                                                    AS_Highest_Completed_Education__c
                                                    FROM Enrolment_Form__c 
                                                    WHERE Id =: recordID];
            
            return getEnrolInfo; 
        }else return null;
    }

    /**
     * Get Qualification Information
     * @par getQualificationInfo Method:
     * To get the Qualification information base of the given record Id, we use "getQualificationInfo" method.
     *
     * @param QualificationID It is the record id of the Qualification record, that will be use in the query.
     */
    @AuraEnabled
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

    /**
     * Save changes for the education form
     *
     * @param enrolId enrolment id to be updated
     * @param enrolRecord enrolment record to be updated
     * @param qualRecord List of qualification to be updated/inserted
     * @param accId Account Id to be link on newly created enrolment
     * @param sendmelink indicator for send link button or natural save button
     */
    @AuraEnabled
    public static saveChangesReturn saveChanges( Id enrolId, Enrolment_Form__c enrolRecord, List<Qualification__c> qualRecord, Id accId, Boolean sendmelink ) {
        
        saveChangesReturn scr = new saveChangesReturn();

        if( enrolRecord != null ) {

            if( enrolId != null ) {

                Enrolment_Form__c enrol = new Enrolment_Form__c();
                enrol = enrolRecord;
                enrol.Id = enrolId;
                enrol.AS_Saved_Enrolment_Form__c = true;
                enrol.AS_Enrolment_Stage__c = 'Page 6: Employment And Education Details';
                enrol.AS_Enrollment_Last_Modify_Date__c = Datetime.now();
                if( sendmelink ) enrol.AS_Send_enrollment_link__c = true;
                update enrol;

                scr.enrolment = enrol.Id; 

            } else {

                Enrolment_Form__c enrol = new Enrolment_Form__c();
                enrol = enrolRecord;
                if( accId != null ) enrol.AS_Account__c = accId;
                enrol.AS_Saved_Enrolment_Form__c = true;
                enrol.AS_Enrolment_Stage__c = 'Page 6: Employment And Education Details';
                enrol.AS_Enrollment_Last_Modify_Date__c = Datetime.now();
                if( sendmelink ) enrol.AS_Send_enrollment_link__c = true;
                insert enrol;

                scr.enrolment = enrol.Id; 
            }

        }

        if( qualRecord != null && !qualRecord.isEmpty() ) {

            List<Qualification__c> qlist = new List<Qualification__c>();

            for( Qualification__c q : qualRecord ) {

                if ( q.Id != null ) {

                    Qualification__c qualifi = new Qualification__c();
                    qualifi = q;
                    qualifi.Id = q.Id;
                    qualifi.Name = q.ASQualification_Name__c;
                    qualifi.Account__c = accId;
                    qlist.add( qualifi );

                } else {

                    Qualification__c qualifi = new Qualification__c();
                    qualifi = q;
                    qualifi.Name = q.ASQualification_Name__c;
                    qualifi.Account__c = accId;
                    if( enrolId != null ) qualifi.ASEnrolment_Form__c = enrolId;
                    qlist.add( qualifi );
                }

            }

            upsert qlist;
            scr.qualification = qlist;
        }
        
        return scr;
    }

    /**
     * delete 
     *
     * @param qualIds List of qualification id to be deleted
     * @return List of qualifaction records that is being deleted
     */
    @AuraEnabled
    public static List<Qualification__c> deleteQualification( List<Id> qualIds ) {
        List<Qualification__c> q = [SELECT Id FROM Qualification__c WHERE Id IN : qualIds];
        if ( q.size() > 0 ) {
            delete q;
        }
        return q;
    }

    public class saveChangesReturn {
        @AuraEnabled public List<Qualification__c> qualification {get; set;}
        @AuraEnabled public Id enrolment {get; set;}
    }
}