public without sharing class AsEnrolmentFormController {

    @AuraEnabled
    public static Account getAccountInfo(Id recordID){
 
        Account obj = [
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
            WHERE Id =: recordID
        ];
        
        return obj; 
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

        Enrolment_Form__c obj = [
            SELECT Id,
            As_over_age__c,
            AS_Parent_Guardian_Name__c,
            AS_Parent_Guardian_Phone_Number__c,
            AS_Parent_Guardian_Email__c,
            AS_Alternate_Email__c,
            AS_Business_Pharmacy_Name__c,
            AS_Primary_Property_name__c,
            AS_Primary_Unit_details__c,
            AS_Primary_Street_Number__c,
            AS_Alternate_Property_name__c,
            AS_Alternate_Unit_details__c,
            AS_Alternate_Street_Number__c,
            AS_Enrolment_Stage__c,
            AS_Primary_Suburb_Town__c,
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
            AS_VSN__c,
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
            Industry__c,
            AS_recognition_of_prior_learning__c,
            AS_Study_Reason__c,
            AS_PSA_ID__c,
            AS_Currently_Enrolled_in_Secondary_Educa__c,
            AS_Highest_Completed_Education__c,
            AS_Details_of_Disability__c,
            AS_Has_Disability__c,
            AS_Account__c,
            AS_Learning_Package__c,
            AS_Learning_Package__r.AS_Accreditation_level__c,
            AS_Employment_Status__c
            FROM Enrolment_Form__c 
            WHERE Id =: recordID
        ];
            
        return obj; 
    }
    @AuraEnabled
    public static Learning_Package__c getLearningPackageInfo( Id recordID ){

        Learning_Package__c obj = [
            SELECT Id,
            AS_Number_Electives__c
            FROM Learning_Package__c 
            WHERE Id =: recordID
        ];

        return obj;
    }
    // @AuraEnabled
    // public static AS_Enrolled_Unit__c getEnrolledUnitInfo( Id recordID ){

    //     AS_Enrolled_Unit__c obj = [
    //         SELECT Id,
    //         AS_Number_Electives__c,
    //         AS_Unit__c,
    //         AS_Learning_Package__c
    //         FROM AS_Enrolled_Unit__c 
    //         WHERE Id =: recordID
    //     ];

    //     return obj;
    // }

    @AuraEnabled
    public static Learning_Package_Unit__c getLearningEnrolledUnitInfo( Id recordID ){

        Learning_Package_Unit__c obj = [
            SELECT Id,
            AS_Unit__c,
            AS_Learning_Package__c,
            AS_Order__c
            FROM Learning_Package_Unit__c 
            WHERE Id =: recordID
        ];

        return obj;
    }

    @AuraEnabled
    public static Unit__c getUnitInfo( Id recordID ){

        Unit__c obj = [
            SELECT Id,
            AS_Training_Plan__c,
            AS_State__c
            FROM Unit__c 
            WHERE Id =: recordID
        ];

        return obj;
    }

    
    @AuraEnabled
    public static Training_Plan__c getTrainingPlanInfo( Id recordID ){

        Training_Plan__c obj = [
            SELECT Id,
            Description__c
            FROM Training_Plan__c 
            WHERE Id =: recordID
        ];

        return obj;
    }

    @AuraEnabled
    public static String getTrainingReview( Id recordID ){

        List<Pre_Training_Review__c> obj = [
            SELECT Id,
            Learning_preferences__c,
            Computer_Skills__c,
            Difficult_Assessment_Methods__c,
            Employment_duration_for_current_position__c,
            Employment_Goals__c,
            Enrolment__c,
            Government__c,
            How_do_you_like_to_learn__c,
            Qualification_Goals__c,
            S2_S3_Dispensary_Skill__c,
            Skills_and_Abilities__c,
            State__c,
            Work_Experience__c,
            Support_Required__c
            FROM Pre_Training_Review__c 
            WHERE Enrolment__c =: recordID
        ];

        String strId;
        for( Pre_Training_Review__c o : obj ) {
            strId = String.valueOf( o.Id );
        }

        return strId;
    }
}