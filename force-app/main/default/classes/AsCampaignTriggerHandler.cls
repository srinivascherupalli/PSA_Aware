/*Author : John Hope
*Description : This is a class that handles Campaign File Object Trigger.
*Date Created : May 16, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : Campaign
*/
public class AsCampaignTriggerHandler {
    private boolean isExecutingBool = false;
    
    /*Author : John Hope
    *Description : this is a constructor
    *Date Created : May 16, 2018
    *Last Modified By : 
    *Date Last Modified : May 16, 2018
    *Related Meta Data :
    *Param : 
        0. boolean - set value for isExecutingBool 
    *Return : 
    */
    public AsCampaignTriggerHandler(boolean isExecuting){
        isExecutingBool = isExecuting;
    }
    
    /*Author : John Hope
    *Description : handler for before insert trigger for object Campaign
    *Date Created : May 16, 2018
    *Last Modified By : 
    *Date Last Modified : May 16, 2018
    *Related Meta Data :
    *Param : 
        0. List<Object> - the new Object from trigger
    *Return : 
    */
    public void OnBeforeInsert(Object[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
        //populateLearnCampAndCampTrain(newObjects, new Map<Id,Object>(),newMapObjects,'INSERT');
        //populateLearnCampAndCampTrain(newObjects, 'INSERT');
    }
    
    /*Author : John Hope
    *Description : handler for after insert trigger for object Campaign
    *Date Created : May 16, 2018
    *Last Modified By : 
    *Date Last Modified : May 16, 2018
    *Related Meta Data :
    *Param :
        0. List<Object> - the new Object from trigger
    *Return : 
    */
    public void OnAfterInsert(Object[] newObjects,Map<Id,Object> newMapObjects){
        // EXECUTE AFTER INSERT LOGIC
        
        createCampaignMemberStatus(newObjects, new Map<Id,Object>(),newMapObjects,'INSERT');
        
        //populateTrainingPlanCampaign(newObjects, new Map<Id,Object>(),newMapObjects,'INSERT');
        
        populateLearnCampAndCampTrain(newObjects,'INSERT');
        
        createEvent(newObjects, 'INSERT');
    }
    
    
    public static void createCampaignMemberStatus(Object[] newObjects, Map<Id,Object> oldMap, Map<Id,Object> newMapObjects, String action){
        Id eventRecId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        
        List<CampaignMemberStatus> allCamMemSta = new List<CampaignMemberStatus>();
        for(Campaign cam : (List<Campaign>) newObjects) {
            CampaignMemberStatus cms1 = new CampaignMemberStatus(CampaignId=cam.Id, HasResponded=true, Label='Attending');
            allCamMemSta.add(cms1);
            
            CampaignMemberStatus cms2 = new CampaignMemberStatus(CampaignId=cam.Id, HasResponded=true, Label='Checked In');
            allCamMemSta.add(cms2);
        }
        
        Database.Insert(allCamMemSta,false);
                
    }
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    /*Description: PSA-192 REVISION 09/08/18
    *   For Campaign where record type = Event and Learning =/= Null
    *       Update Learning.Campaign__c = Campaign.Id 
    *       Update Campaign.TrainingPlan_c = Campaign.Learning.TrainingPlan_c 
    *       (Campaign.TrainingPlanc and Campaign.Learningc will be filled)
    *   For Campaign where record type = Event and Learning = Null
    *       Update Campaign.TrainingPlan.Campaign__c = Campaign.Id
    *       (Campaign.Learningc will remain BLANK)
    *Date Created: August 10, 2018
    */
    public static boolean runFillLearnCampAndCampTrain = true;

    public static boolean runOnceFillLearnCampAndCampTrain(){/*Anti-recursion*/
        if(runFillLearnCampAndCampTrain){
            runFillLearnCampAndCampTrain=false;
            return true;
        }else{
            return runFillLearnCampAndCampTrain;
        }
    }
    
    //public static void populateLearnCampAndCampTrain(Object[] newObjects, Map<Id,Object> oldMap, Map<Id,Object> newMapObjects, String action){
    public static void populateLearnCampAndCampTrain(Object[] newObjects, String action){
        if(runOnceFillLearnCampAndCampTrain()){
        
            List<Learning__c> allLearning = new List<Learning__c>();
            List<Training_Plan__c> allTrainingPlan = new List<Training_Plan__c>();
            List<Campaign> allCampaign = new List<Campaign>();
            
            Set<Id> camLearningIds = new Set<Id>();
            Set<Id> camTPSI_Ids = new Set<Id>();
            Set<Id> TPS_Ids = new Set<Id>();
            Set<Id> TP_Ids = new Set<Id>();
            Map<Id, Id> mapLearnIdCamId = new Map<Id, Id>();
            
			system.debug('newObjects: '+newObjects);
            
            for(Campaign cam : (List<Campaign>) newObjects){
                if(cam.Learning__c <> NULL){
                    Learning__c indiLearning = new Learning__c();
                    Training_Plan__c indiTrainingPlan = new Training_Plan__c();
              
                    
                    indiLearning.Id = cam.Learning__c;
                    indiLearning.Campaign__c = cam.Id;
                    
                    camLearningIds.add(cam.Learning__c);
                    
                    
                    mapLearnIdCamId.put(cam.Learning__c, cam.Id);
                    
                    indiTrainingPlan.AS_Event__c = cam.Id; 
					indiTrainingPlan.Id = cam.Training_Plan__c;

                    
                   
                    allLearning.add(indiLearning);
                    
                }
                else if(cam.Learning__c == NULL){
                	//Update Campaign.TrainingPlan.Campaign__c = Campaign.Id
                	//Campaign.TraningPlan <> NULL
                	
                	if(cam.Training_Plan__c <> NULL){
	                    Training_Plan__c indiTrainingPlan = new Training_Plan__c();
	                    indiTrainingPlan.AS_Event__c = cam.Id;
	                    indiTrainingPlan.Id = cam.Training_Plan__c;
	                    allTrainingPlan.add(indiTrainingPlan);
                	}
                }  
            }
            
            system.debug('LearningId-->CampaignId'+mapLearnIdCamId);
			
            Map<Id, Id> mapTPS_Campaign = new Map<Id, Id>();
            for(Training_Plan_Section_Item__c TPSI : [SELECT Id, Name, Learning__c, Training_Plan_Section__c FROM Training_Plan_Section_Item__c WHERE Learning__c IN: mapLearnIdCamId.keySet() LIMIT 1]){
            	TPS_Ids.add(TPSI.Training_Plan_Section__c);
            	mapTPS_Campaign.put(TPSI.Training_Plan_Section__c, mapLearnIdCamId.get(TPSI.Learning__c));
            }
            system.debug('Training Plan Section Ids: '+TPS_Ids);
            system.debug('Map(TrainingPlanSection, Campaign) MAPTPS_CAMPAIGN: '+mapTPS_Campaign);
            
            Map<Id, Id> mapTP_Campaign = new Map<Id, Id>();
            for(Training_Plan_Section__c TPS : [SELECT Id, Name, Training_Plan__c FROM Training_Plan_Section__c WHERE Id IN: mapTPS_Campaign.keySet()]){
            	TP_Ids.add(TPS.Training_Plan__c);
            	mapTP_Campaign.put(TPS.Training_Plan__c, mapTPS_Campaign.get(TPS.Id));
            }
            system.debug('Training Plan Ids: '+TP_Ids);
            system.debug('Map(TrainingPlan, Campaign): '+mapTP_Campaign);
            
			for(Training_Plan__c TP : [SELECT Id FROM Training_Plan__c WHERE Id IN: mapTP_Campaign.keySet()]){
				Campaign indiCampaign = new Campaign();
				indiCampaign.Training_Plan__c = TP.Id; //Update Campaign.TrainingPlan_c = Campaign.Learning.TrainingPlan_c 
				indiCampaign.Id = mapTP_Campaign.get(TP.Id);
				allCampaign.add(indiCampaign);
			}
            system.debug('allCampaign: '+allCampaign);
            
            
            if(allCampaign.size()>0){
            	update allCampaign;
            	system.debug('Size of allCampaign: ' +allCampaign.size());
            }else{
            	system.debug('Size of allCampaign: ' +allCampaign.size());
            }
            
            
            if(allLearning.size()>0){
                update allLearning;
                system.debug('Size of allLearning: ' +allLearning.size());
            }else{
            	system.debug('Size of allLearning: ' +allLearning.size());
            }
            
            
            if(allTrainingPlan.size()>0){
                update allTrainingPlan;
            }
            
            if(allCampaign.size()>0 || allLearning.size()>0 || allTrainingPlan.size()>0){
                AsCampaignTriggerHandler.runFillLearnCampAndCampTrain = false;
            }else{
                AsCampaignTriggerHandler.runFillLearnCampAndCampTrain = true;
            }
        }
    }
    
    /*PSA-192 REVISION 09/08/18*/
    
   
    










    
    
    
    
    /*Author : John Hope
    *Description : handler for before update trigger for object Campaign
    *Date Created : May 16, 2018
    *Last Modified By : 
    *Date Last Modified : May 16, 2018
    *Related Meta Data :
    *Param :
        0. List<Object> - the old Object from trigger
        1. List<Object> - the new Object from trigger
        2. List<Object> - the new Map Object from trigger
    *Return : 
    */
    public void OnBeforeUpdate(Object[] oldObjects, Object[] updatedObjects, Map<Id,Object> MapObjectMap){
        // BEFORE UPDATE LOGIC
        //populateLearnCampAndCampTrain(oldObjects, 'UPDATE');
    }
    
    /*Author : John Hope
    *Description : handler for after update trigger for object Campaign
    *Date Created : May 16, 2018
    *Last Modified By : 
    *Date Last Modified : May 16, 2018
    *Related Meta Data :
    *Param :
        0. List<Object> - the old Object from trigger
        1. List<Object> - the new Object from trigger
        2. List<Object> - the new Map Object from trigger
    *Return : 
    */
    public void OnAfterUpdate(Object[] updatedObjects, Map<Id,Object> oldMap, Map<Id,Object> newMap){
        populateLearnCampAndCampTrain(updatedObjects,'UPDATE');
        runFillLearnCampAndCampTrain = true;
        //createEvent(updatedObjects, 'UPDATE');
        //
        List<Campaign> campList = new List<Campaign>();
        for(Campaign cam : (List<Campaign>) updatedObjects){
            Campaign old_cam = (Campaign)oldMap.get(cam.Id);
            if(cam.Name != old_cam.Name || 
               cam.Format__c != old_cam.Format__c || 
               cam.StartDate != old_cam.StartDate || 
               cam.EndDate != old_cam.EndDate || 
               cam.AS_Start_Time__c != old_cam.AS_Start_Time__c || 
               cam.AS_End_Time__c != old_cam.AS_End_Time__c || 
               cam.AS_Registration_End_Date__c != old_cam.AS_Registration_End_Date__c || 
               cam.AS_Region__c != old_cam.AS_Region__c || 
               cam.AS_Location__c != old_cam.AS_Location__c || 
               cam.AS_Total_Capacity__c != old_cam.AS_Total_Capacity__c || 
               cam.AS_Session__c != old_cam.AS_Session__c)
            {
                campList.add(cam);
            }
            
        }
        Object[] updatedObjects1 = campList;
        createEvent(updatedObjects1, 'UPDATE');
    }
    
    /*Author : John Hope
    *Description : handler for before delete trigger for object Campaign
    *Date Created : May 16, 2018
    *Last Modified By : 
    *Date Last Modified : May 16, 2018
    *Related Meta Data :
    *Param : List<Campaign>,List<Campaign>
        0. List<Campaign> - the old Campaign data from trigger
        1. Map<Id,Campaign> - the old Map data from trigger
    *Return : 
    */
    public void OnBeforeDelete(Object[] oldObjects,Map<Id,Object>  MapObjectMap){
    
        
    }
    
    /*Author : John Hope
    *Description : handler for after delete trigger for object Campaign
    *Date Created : May 16, 2018
    *Last Modified By : 
    *Date Last Modified : May 16, 2018
    *Related Meta Data :
    *Param : 
        0. List<Object> - the old object data list from trigger
        1. Map<Id,Object> - the old object data map from trigger
    *Return : 
    */
    public void OnAfterDelete(Object[] deletedObjects,Map<Id,Object>  MapObjectMap){
        // AFTER DELETE LOGIC
    }
    
    /*Author : John Hope
    *Description : handler for undelete trigger for object Campaign
    *Date Created : May 16, 2018
    *Last Modified By : 
    *Date Last Modified : May 16, 2018
    *Related Meta Data :
    *Param :
        0. List<Object> - the new object data list from trigger
    *Return : 
    */
    public void OnUndelete(Object[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }
    
    /*Author : John Hope
    *Description : checker if trigger is running
    *Date Created : May 16, 2018
    *Last Modified By : 
    *Date Last Modified : May 16, 2018
    *Related Meta Data :
    *Param : 
    *Return : boolean
    */
    public boolean IsTriggerContext{
        get{ return isExecutingBool;}
    }
    
    
    
    
    
    
    // PSAMOPT-26: Create Event Custom Object on Campaign Creation ; Edit Event Custom Object when linked Campaign is edited
    public static void createEvent(Object[] newObjects, String action){
        //system.debug(runOnceFillLearnCampAndCampTrain());
        Boolean createEvt = false;
        for(Campaign cam : (List<Campaign>) newObjects){
            if(cam.AS_Event__c == null) createEvt = true;
        }
        
        if(runOnceFillLearnCampAndCampTrain() || createEvt || action == 'UPDATE'){
            Id eventRT = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
            System.debug('** eventRT : ' + eventRT);
            List<AS_Event__c> eventList = new List<AS_Event__c>();
            List<AS_Event__c> eventListUpdate = new List<AS_Event__c>();
            
            for(Campaign cam : (List<Campaign>) newObjects){
                System.debug('** cam.RecordTypeId : ' + cam.RecordTypeId);
                if(cam.RecordTypeId == eventRT && cam.AS_Session__c){
                    
                    AS_Event__c evt = new AS_Event__c(Name = cam.Name,
                                                      AS_Format__c = cam.Format__c,
                                                      AS_Start_Date__c = cam.StartDate,
                                                      AS_End_Date__c = cam.EndDate,
                                                      AS_Start_Time__c = cam.AS_Start_Time__c,
                                                      AS_End_Time__c = cam.AS_End_Time__c,
                                                      AS_Registration_End_Date__c = cam.AS_Registration_End_Date__c,
                                                      AS_Session_Campaign__c = cam.Id,
                                                      AS_Region__C = cam.AS_Region__c,
                                                      AS_Location__c = cam.AS_Location__c,
                                                      AS_Total_Capacity__c = cam.AS_Total_Capacity__c);
                    
                    System.debug('evt : ' +  evt);
                    if(cam.AS_Event__c == null) eventList.add(evt);
                    else{
                        evt.Id = cam.AS_Event__c;
                        eventListUpdate.add(evt);
                    }
                }
            }
            
            if(eventList.size() > 0){
                insert eventList;
                
                List<Campaign> updateCamp = new List<Campaign>();
                
                for(AS_Event__c evt : eventList){
                    for(Campaign cam : (List<Campaign>) newObjects){
                        if(evt.AS_Session_Campaign__c == cam.Id){
                            updateCamp.add(new Campaign(Id = cam.Id, AS_Event__c = evt.Id));
                        }
                    }
                }
                if(updateCamp.size() > 0) update updateCamp;
            }
            
            if(eventListUpdate.size() > 0) update eventListUpdate;
        }
    }

}