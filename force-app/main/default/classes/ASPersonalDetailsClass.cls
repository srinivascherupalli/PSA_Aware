/**
 * @File Name          : ASPersonalDetailsClass.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/20/2019, 3:32:20 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/20/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public without sharing class ASPersonalDetailsClass {
    /**
    *@author Ronald Santander
    *@details ASPersonalDetailsClass is use in the PersonalDetails component as a server side
    *@date September 3, 2019 
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
     * Get Account Information
     * @par getAccountInfo Method:
     * To get the Account information base of the given record Id, we use "getAccountInfo" method.
     * This will get all the value of the field that specified and display it in the page.
     *
     * @param recordID It is the record id of the record, that will be use in the query.
     */
    @AuraEnabled
    public static Account getAccountInfo(Id recordID){

        Account getEnrolInfo = [
        SELECT Id,
        FirstName,
        Salutation,
        LastName,
        Age__c,
        PersonTitle,
        AS_Middle_Name__pc,
        Gender__pc,
        PSA_Preferred_Name__c,
        Date_of_Birth__c,
        PersonEmail,
        PersonMobilePhone,
        PersonHomePhone,
        PersonBirthdate,
        PersonMailingState,
        AS_Work_Phone__pc,
        BillingStreet,
        BillingCity,
        BillingState,
        BillingPostalCode,
        ShippingStreet,
        ShippingCity,
        ShippingState,
        ShippingPostalCode,
        AS_Unique_Student_Identifier__c,
        USI_Status__pc,
        AS_VSN__c 
        FROM Account 
        WHERE Id =: recordID];
        
        return getEnrolInfo; 
    }

    /**
     * Get Enrolment Information
     * @par getEnrolmentInfo Method:
     * To get the Enrolment information base of the given record Id, we use "getEnrolmentInfo" method.
     * This will get all the value of the field that specified and display it in the page.
     *
     * @param recordID It is the record id of the record, that will be use in the query.
     */
    @AuraEnabled
    public static Enrolment_Form__c getEnrolmentInfo(Id recordID){

        if(recordID != null){
            Enrolment_Form__c getEnrolInfo = [
                SELECT Id,
                AS_Parent_Guardian_Name__c,
                AS_Parent_Guardian_Phone_Number__c,
                AS_Parent_Guardian_Email__c,
                AS_Alternate_Email__c,
                AS_Business_Pharmacy_Name__c,
                AS_Primary_Property_name__c,
                AS_Primary_Unit_details__c,
                AS_Primary_Street_Number__c,
                AS_Primary_Suburb_Town__c,
                AS_Alternate_Property_name__c,
                AS_Alternate_Unit_details__c,
                AS_Alternate_Street_Number__c,
                AS_same_as_above__c,
                AS_Enrollment_State__c,
                Enrolment_Status__c,
                AS_Title__c,
                AS_Given_Name__c,
                AS_Surname__c,
                AS_second_given_name__c,
                AS_Preferred_Name__c,
                AS_Date_of_Birth__c,
                AS_Gender__c,
                AS_Home_Phone__c,
                AS_Work_Phone__c,
                AS_Mobile_Phone__c,
                AS_Email__c,
                AS_Primary_Street__c,
                AS_City_of_Birth__c,
                AS_Primary_State__c,
                AS_Primary_Postcode__c,
                AS_Alternate_Street__c,
                AS_Alternate_Suburb__c,
                AS_Alternate_State__c,
                AS_Alternate_Postcode__c,
                AS_Unique_Student_Identifier__c,
                AS_VSN__c
                FROM Enrolment_Form__c 
                WHERE Id =: recordID
            ];
            
            return getEnrolInfo; 
        }else return null;
    }

    /**
     * Save Account Information
     * @par saveAccountInfo Method:
     * To save the Account information base of the given record Id, we use "saveAccountInfo" method.
     *
     * @param accRecord It is the record or data of the Account.
     * @param accID It is the record id of the Account.
     * @param enrolID It is the record id of the Enrolment.
     */
    @AuraEnabled
    public static Id saveAccountInfo(Account accRecord,Id accID,Id enrolID){

        if(accRecord != null){
            if(accID != null){
                Account acc = new Account();
                acc = accRecord;
                acc.Id = accID;
                update acc;
                return acc.Id; 
            }else return null;
        }else return null;
    }

    /**
     * Save Enrolment Information
     * @par saveEnrolmentInfo Method:
     * To save the Enrolment information base of the given record Id, we use "saveEnrolmentInfo" method. This will get all the information of the record in the page.
     *
     * @param enrolRecord: It is the Enrolment data that need to insert or update.
     * @param enrolmentID: It is the record id of Enrolment record.
     * @param recordAccID: It is the record id of Account.
     */
    @AuraEnabled
    public static Id saveEnrolmentInfo(Enrolment_Form__c enrolRecord, Id enrolmentID, Boolean isEmail ){
        //btnAction is use for email

        Enrolment_Form__c enrol = new Enrolment_Form__c();
        enrol = enrolRecord;
        enrol.Id = enrolmentID;
        enrol.AS_Saved_Enrolment_Form__c    = true;
        enrol.AS_Enrolment_Stage__c = 'Page 4: Langage & Cultural Diversity';
        enrol.AS_Enrollment_Last_Modify_Date__c = Date.today();
        if( isEmail ) enrol.AS_Send_enrollment_link__c = true;
        update enrol;
       
        return enrol.Id; 

    }

    /**
     * Delete Enrolment Information
     * @par delEnrolmentInfo Method:
     * The delEnrolmentInfo method will delete the enrolment record when user click cancel button.
     *
     * @param enrolmentID: It is the Enrolment id.
     */
    @AuraEnabled
    public static String delEnrolmentInfo(Id enrolId){

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

    @AuraEnabled
    public static void updateEnrolmentInfo(Id enrolmentID, Enrolment_Form__c enrolRecord){
        Enrolment_Form__c enrol = new Enrolment_Form__c();
        enrol = enrolRecord;
        enrol.Id = enrolmentID;
        update enrol;
    }
}