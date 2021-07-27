/**
 * @File Name          : PreTrainingReviewController.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/20/2019, 3:34:33 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/20/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public without sharing class PreTrainingReviewController {
    
    @AuraEnabled
    public static List<String> getPicklistValue(String fieldname,String objectname) {
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
    
    /*Updated by vincent base on PRI-156 ticket*/
    @AuraEnabled
    public static Pre_Training_Review__c getPreTrainingReviewInfo(Id recordID){
        
        if(recordID != null){
            Pre_Training_Review__c getPreTrainingInfo = [SELECT Id,
            Current_Job_Role__c,
            Computer_Skills__c,
            Learning_preferences__c,
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
            Support_Required__c, 
            Enrolment__r.AS_Learning_Package__r.AS_Accreditation_level__c
            FROM Pre_Training_Review__c  
            WHERE Id =: recordID];
            return getPreTrainingInfo;
        }else return null;
    }
    
    
    @AuraEnabled
    public static String savePreTraininInfo(Pre_Training_Review__c preRecord,Id parentId,Id preId, Id recordId,  Boolean sendmelink){
       	String trainingReview = null;
        try{
            
            Pre_Training_Review__c pre = new Pre_Training_Review__c();
            pre = preRecord;
            pre.Id = preId;
            pre.Account__c = recordId;
            pre.Enrolment__c = parentId;
            upsert pre;
            trainingReview = String.valueOf( pre.Id ); 
            
            Enrolment_Form__c enrol = new Enrolment_Form__c();
            enrol.Id = parentId;
            enrol.AS_PTR__c = true;
            enrol.AS_Saved_Enrolment_Form__c = true;
            enrol.AS_Enrolment_Stage__c = 'Page 8: Pre-Training Review Page';
            enrol.AS_Enrollment_Last_Modify_Date__c = Datetime.now();
            if( sendmelink ) enrol.AS_Send_enrollment_link__c = true;
            update enrol;


        }catch( Exception er ){
            System.debug('AS Error System ****:'+er );
            trainingReview = String.valueOf( er );
        }
        return trainingReview; 
    }
    @AuraEnabled
    public static Enrolment_Form__c getEnrolmentInfo(Id recordID){

        Enrolment_Form__c getEnrolInfo = [
            SELECT Id,
            Enrolment_Status__c,
            AS_Learning_Package__r.AS_Accreditation_level__c
            FROM Enrolment_Form__c 
            WHERE Id =: recordID
        ];
            
        return getEnrolInfo;
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