public class AS_Learning_Trigger_Handler {
   
    /*
    *Description: (PSA-192) (REVISION 09/08/18) 
    *	If record type = event and Campaign != NULL
    *		Update Campaign.Learning__c= Learning.Id, 
    *		Update Campaign.Trainingplan__c = Learning.TrainingPlan.Id 
    *											
    *Date Created: August 10, 2018
    */


	public void OnAfterInsert(Learning__c[] newObjects,Map<Id,Learning__c> newMapObjects){
		populateCampLearnAndCampTrain(newObjects, new Map<Id,Learning__c>(),newMapObjects,'INSERT');
        CreateLmsActBaseOnLearning(newObjects);//added by vincent in ticket pri 41. 
	}
	
    public void OnAfterUpdate(Learning__c[] updatedObjects, Map<Id,Learning__c> oldMap, Map<Id,Learning__c> newMap){
    	populateCampLearnAndCampTrain(updatedObjects, oldMap, newMap, 'UPDATE');
    }
      
    
    
    
    
    public static boolean runFillCampLearnAndCampTrain = true;

    public static boolean runOnceFillCampLearnAndCampTrain(){/*Anti-recursion*/
	    if(runFillCampLearnAndCampTrain){
	     	runFillCampLearnAndCampTrain=false;
	     	return true;
	    }else{
	        return runFillCampLearnAndCampTrain;
	    }
	}
	
	public static void populateCampLearnAndCampTrain(Learning__c[] newObjects, Map<Id,Learning__c> oldMap, Map<Id,Learning__c> newMapObjects, String action){
		if(runOnceFillCampLearnAndCampTrain()){
			
			List<Campaign> allCampaignLearning = new List<Campaign>();
			List<Campaign> allCampaignTrainingPlan = new List<Campaign>();
			Set<Id> camLearningIds = new Set<Id>();
            Set<Id> camTPSI_Ids = new Set<Id>();
            Set<Id> TPS_Ids = new Set<Id>();
            Set<Id> TP_Ids = new Set<Id>();
            Map<Id, Id> mapLearnIdCamId = new Map<Id,Id>();
            set<Id> trainingPlanSecIdSet  = new set<Id>();
            set<Id> trainingPlanIdSet = new set<Id>();
            Boolean isProcced = false;
            
            for(Learning__c learnin : (List<Learning__c>) newObjects){
                if(learnin.Campaign__c != null ){
                    if( action == 'UPDATE'){
                        
                        if(oldMap.get(learnin.Id).Campaign__c != newMapObjects.get(learnin.Id).Campaign__c){
                            isProcced = true; 
                        } else {
                            isProcced = false;
                        }
                        
                    } else {
                        
                        isProcced = true;
                    }
                    
                    if( isProcced ){
                        Campaign indiCampaign = new Campaign();
                        indiCampaign.Learning__c = learnin.Id;
                        indiCampaign.Id = learnin.Campaign__c;
                        allCampaignLearning.add(indiCampaign);
                        camLearningIds.add(learnin.Id);
                        mapLearnIdCamId.put(learnin.Id, learnin.Campaign__c);	
                    }
                }
            } 
            
            if(allCampaignLearning.size()>0){
                update allCampaignLearning;
            }
            system.debug('allCampaignLearning: ' + allCampaignLearning);
            
            Map<Id, Id> mapTPS_Campaign = new Map<Id, Id>();
            
            if(mapLearnIdCamId.size() > 0) {
                
                for(Training_Plan_Section_Item__c trainingPlanSecItem : [SELECT Id, Name, Learning__c, Training_Plan_Section__c FROM Training_Plan_Section_Item__c WHERE Learning__c IN: mapLearnIdCamId.keySet() ]){
                    
                    mapTPS_Campaign.put(trainingPlanSecItem.Training_Plan_Section__c, mapLearnIdCamId.get(trainingPlanSecItem.Learning__c));
                    trainingPlanSecIdSet.add(trainingPlanSecItem.Training_Plan_Section__c);
                } 
            }
            system.debug('Here mapTPS_Campaign: '+mapTPS_Campaign);  
            
            Map<Id, Id> mapTP_Campaign = new Map<Id, Id>();
            if(mapTPS_Campaign.size() > 0) {
                for(Training_Plan_Section__c trainingPlanSection : [SELECT Id, Name, Training_Plan__c FROM Training_Plan_Section__c WHERE Id IN:trainingPlanSecIdSet  ]){
                    //TP_Ids.add(TPS.Training_Plan__c);
                    mapTP_Campaign.put(trainingPlanSection.Training_Plan__c, mapTPS_Campaign.get(trainingPlanSection.Id));
                    trainingPlanIdSet.add(trainingPlanSection.Training_Plan__c);
                }
            }
            system.debug('mapTP_Campaign:==> '+mapTP_Campaign);
            if(mapTP_Campaign.size() > 0) {  
                for(Training_Plan__c trainingPlan : [SELECT Id FROM Training_Plan__c WHERE Id IN:trainingPlanIdSet limit 1 ]){
                    Campaign indiCampaign = new Campaign();
                    indiCampaign.Training_Plan__c = trainingPlan.Id; 
                    indiCampaign.Id = mapTP_Campaign.get(trainingPlan.Id);
                    allCampaignTrainingPlan.add(indiCampaign);
                }
            }
            system.debug('allCampaignTrainingPlan: '+allCampaignTrainingPlan);
            if(allCampaignTrainingPlan.size()>0){
                update allCampaignTrainingPlan;
            }
            
            if(allCampaignLearning.size()>0 || allCampaignTrainingPlan.size()>0){
                AS_Learning_Trigger_Handler.runFillCampLearnAndCampTrain = false;
            }else{
                AS_Learning_Trigger_Handler.runFillCampLearnAndCampTrain = true;
            }
        }
    }
    
    
/*
*Author : Michael Vincent Largo
*Description : 
*Date Created : 08/28/2019
*Last Modified By: Deadz 
*Action : insert/Update(Only for trigger)
*/
    
    private static Boolean recursiveVal = false;
    
    /*ticket PRI-41 8/13/2019*/
    public static void CreateLmsActBaseOnLearning(List<Learning__c> newObjects){
        if(recursiveVal == false){
            recursiveVal = true;
            List<LMS_Activity__c> newLmsActivity = new List<LMS_Activity__c>();
            //List<Learning__c> newLearning = new List<Learning__c>();
            Map<String,Id> mapxIDandActivity = new Map<String,Id>();
            Set<Id> learnId = new Set<Id>();
            
            for (Learning__c LC : newObjects){
                if (LC.LMS_Instance__c !=null){
                    learnId.add(LC.Id); 
                }
            }
            List<Learning__c> newLearning = [SELECT Description__c,AS_Activity_Moodle_Id__c,AS_Activity_Type__c,AS_LMS_Activity__c,AS_LMS_type__c,AS_Training_Plan__r.AS_LMS_Course__c,Id,LMS_Instance__c,Name FROM Learning__c WHERE Id IN:learnId];
            system.debug('momo==>:' + newLearning);
            if (newLearning.size() >0) {
                for(Learning__c learn : newLearning){
                      system.debug('learn' +learn);
                    String xID = generateRandomNumber();
                    LMS_Activity__c lmsActivityRef = new LMS_Activity__c(ASLmsActivityExtId__c = xID);
                    
                    //updated this in AS_HelperClass.LMS_Integration_Learning
                    
                    /*if (learn.AS_LMS_type__c =='Course' && learn.LMS_Instance__c !=null){
                    /*THEN Use the existing trigger functionality to creaste a LMS Course 
                    and set up the learning_c.LMS_Coursec and learningc.LMS_course_id_c
                    EXISTING FUNCTIONALITY IN THE ORG
                    }*/
                    
                    if (learn.AS_LMS_type__c =='Activity' && learn.LMS_Instance__c !=null && learn.AS_Activity_Type__c !=null){
                        system.debug('sulod dre');
                        LMS_Activity__c lmsActivity = new LMS_Activity__c();
                        lmsActivity.Date__c = Date.today();
                        lmsActivity.Description__c = learn.Description__c;
                        lmsActivity.Name = learn.Name;
                        lmsActivity.LMS_Instance__c = learn.LMS_Instance__c;
                        lmsActivity.Status__c = 'Active';
                        lmsActivity.AS_Activity_Type__c = learn.AS_Activity_Type__c;
                        lmsActivity.LMS_Course__c = learn.AS_Training_Plan__r.AS_LMS_Course__c;
                        lmsActivity.ASLmsActivityExtId__c = xID;
                        newLmsActivity.add(lmsActivity);
                        mapxIDandActivity.put(xID,learn.Id);    
                    }
                }
            }
            
            if(newLmsActivity.size() > 0){
                system.debug('GodSpeedoflife==>'+newLmsActivity);                
                Set<Id> insertedLMSactivity = new Set<Id>();
                Database.SaveResult[] insertLMSsctivityList = Database.insert(newLmsActivity, false);
                for (Database.SaveResult sr : insertLMSsctivityList){
                    if (sr.isSuccess() == true){
                        insertedLMSactivity.add(sr.getId());
                    }
                }
                if(!insertedLMSactivity.isEmpty()){
                    updateLearningRecord(insertedLMSactivity,mapxIDandActivity);
                }
            }
        }
    }
    
    /*new function in ticket PRI-41*/
    public static String generateRandomNumber() {
        String randomNumber = generate();
        
        if (randomNumber.length() < 10) {
            String randomNumber2 = generate();
            randomNumber = randomNumber + randomNumber2.substring(0, 10 - randomNumber.length());
        }
        return randomNumber;
    }
    
    public static String generate() {
        return String.valueOf(Math.abs(Crypto.getRandomInteger()));
    }
    
    public static void updateLearningRecord(Set<Id> LmsA,Map<String,Id> mapxID_LmsActivity){
        
        List<LMS_Activity__c> lmsActivity = [SELECT Id, ASLmsActivityExtId__c FROM LMS_Activity__c WHERE Id IN: LmsA];
        List<Learning__c> updateLmsLearn = new List<Learning__c>();
        if(!lmsActivity.isEmpty()){
            
            for(LMS_Activity__c singleLmsActivity : lmsActivity){
                if(mapxID_LmsActivity.containsKey(singleLmsActivity.ASLmsActivityExtId__c)){
                    Learning__c newLearn = new Learning__c();
                    newLearn.Id = mapxID_LmsActivity.get(singleLmsActivity.ASLmsActivityExtId__c);
                    newLearn.AS_LMS_Activity__c = singleLmsActivity.Id;
                    //newLearn.AS_activity_moodle_id__c = singleLmsActivity.Moodle_Activity_Id__c;
                    updateLmsLearn.add(newLearn);
                }
            }
        }
        if(!updateLmsLearn.isEmpty()){
            update updateLmsLearn;
        }
    }
    /*end new function in ticket PRI-41*/
}