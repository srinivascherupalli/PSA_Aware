/*Author : John Hope
*Description : This is a class that handles Training_Track_Account__c File Object Trigger.
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : Training_Track_Account__c
*/
public class AsTrainTrackAccTriggerHandler {
	private boolean isExecutingBool = false;
	
	/*Author : John Hope
	*Description : this is a constructor
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
		0. boolean - set value for isExecutingBool 
	*Return : 
 	*/
	public AsTrainTrackAccTriggerHandler(boolean isExecuting){
		isExecutingBool = isExecuting;
	}
	
	/*Author : John Hope
	*Description : handler for before insert trigger for object Training_Track_Account__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
		0. List<Training_Track_Account__c> - the new Training_Track_Account__c from trigger
	*Return : 
 	*/
 	/*
	public void OnBeforeInsert(Training_Track_Account__c[] newTrainTrackAcc){
	}
	*/
	
	/*Author : John Hope
	*Description : handler for after insert trigger for object Training_Track_Account__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
	public void OnAfterInsert(Training_Track_Account__c[] newTrainTrackAcc,Map<Id,Training_Track_Account__c> newMapTrainTrackAcc) {
		unlockAllTrainPlanFromTrack(newTrainTrackAcc, new Map<Id,Training_Track_Account__c>(),newMapTrainTrackAcc,'insert');
	}
	
	/*Author : John Hope
	*Description : handler for before update trigger for object Training_Track_Account__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Training_Track_Account__c> - the old Training_Track_Account__c from trigger
		1. List<Training_Track_Account__c> - the new Training_Track_Account__c from trigger
		2. List<Training_Track_Account__c> - the new Map Training_Track_Account__c from trigger
	*Return : 
 	*/
 	/*
	public void OnBeforeUpdate(Training_Track_Account__c[] updatedTrainTrackAcc, Map<Id,Training_Track_Account__c> oldMap, Map<Id,Training_Track_Account__c> newMap){
	}
	*/
	/*Author : John Hope
	*Description : handler for after update trigger for object Training_Track_Account__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Training_Track_Account__c> - the old Training_Track_Account__c from trigger
		1. List<Training_Track_Account__c> - the new Training_Track_Account__c from trigger
		2. List<Training_Track_Account__c> - the new Map Training_Track_Account__c from trigger
	*Return : 
 	*/
	public void OnAfterUpdate(Training_Track_Account__c[] updatedTrainTrackAcc,Map<Id,Training_Track_Account__c> oldMap,Map<Id,Training_Track_Account__c> newMap) {
		unlockAllTrainPlanFromTrack(updatedTrainTrackAcc,oldMap,newMap,'update');
	}
	
	/*Author : John Hope
	*Description : handler for before delete trigger for object Training_Track_Account__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : List<Training_Track_Account__c>,List<Training_Track_Account__c>
		0. List<Training_Track_Account__c> - the old Training_Track_Account__c data from trigger
		1. Map<Id,Training_Track_Account__c> - the old Map data from trigger
	*Return : 
 	*/
 	/*
	public void OnBeforeDelete(Training_Track_Account__c[] oldTrainTrackAcc,Map<Id,Training_Track_Account__c>  MapTrainTrackAccMap){
	   
	}
	*/
	/*Author : John Hope
	*Description : handler for after delete trigger for object Training_Track_Account__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
		0. List<Training_Track_Account__c> - the old Training_Track_Account__c data list from trigger
		1. Map<Id,Training_Track_Account__c> - the old Training_Track_Account__c data map from trigger
	*Return : 
 	*/
 	/*
	public void OnAfterDelete(Training_Track_Account__c[] deletedTrainTrackAcc,Map<Id,Training_Track_Account__c>  MapTrainTrackAccMap){
	    // AFTER DELETE LOGIC
	}
	*/
	/*Author : John Hope
	*Description : handler for undelete trigger for object Training_Track_Account__c
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Training_Track_Account__c> - the new Training_Track_Account__c data list from trigger
	*Return : 
 	*/
 	/*
	public void OnUndelete(Training_Track_Account__c[] restoredTrainTrackAcc){
	    // AFTER UNDELETE LOGIC
	}
	*/
	/*Author : John Hope
	*Description : checker if trigger is running
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
	*Return : boolean
 	*/
	public boolean IsTriggerContext{
	    get{ return isExecutingBool;}
	}
	
	/*Author : John Hope
	*Description : create training plan assignments for all training plan under the training track
	*Date Created : October 23, 2018
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
	*Return : 
 	*/
 	public void unlockAllTrainPlanFromTrack(Training_Track_Account__c[] newObject,Map<Id,Training_Track_Account__c> oldMap,Map<Id,Training_Track_Account__c> newMap,String action){
 		//System.debug('unlockAllTrainPlanFromTrack from Trigger : ' + newObject.size());
 		if(newObject.size() == 1) {
	 		Set<Id> trainTrackIdSet = new Set<Id>();
	 		Set<Id> userAccountIdSet = new Set<Id>();
	 		Map<Id,Set<Id>> trackAccountsMap = new Map<Id,Set<Id>>(); // use to store all account from a certain track 
	 		for(Training_Track_Account__c track : newObject) {
	 			
	 			Training_Track_Account__c  newFromMap = newMap.get(track.Id);
				Training_Track_Account__c  oldFromMap = new Training_Track_Account__c();
				if(action == 'update'){
					oldFromMap = oldMap.get(track.Id);
				}
				
				if( track.AS_Approval_Status__c == 'Confirmed' && ((action == 'insert') || (action == 'update' && (oldFromMap.AS_Approval_Status__c != newFromMap.AS_Approval_Status__c))) ) {
		 			if(track.Training_Track__c != null) {
		 				trainTrackIdSet.add(track.Training_Track__c);
		 				
		 				if(track.Account__c != null) {
			 				userAccountIdSet.add(track.Account__c);
			 				
			 				
			 				// adding of data in map trackAccountsMap
			 				if(trackAccountsMap.containsKey(track.Training_Track__c)) {
			 					trackAccountsMap.get(track.Training_Track__c).add(track.Account__c);
			 				} else {
			 					trackAccountsMap.put(track.Training_Track__c,new Set<Id>{track.Account__c});
			 				}
			 				
			 			}
		 			}
				}
	 		}
	 		
	 		Map<Id,Id> allAccUserIdMap = new Map<Id,Id>();
	 		for(User theUser : [Select Id,AccountId from User where AccountId IN :userAccountIdSet and IsActive = true]) {
	 			if(theUser.AccountId != null) {
	 				allAccUserIdMap.put(theUser.AccountId,theUser.Id);
	 			}
	 		}
	 		
	 		Map<Id,Set<Id>> trainPlanTracksMap = new Map<Id,Set<Id>>();
	 		for(Training_Track_Level__c trackLevel : [Select Id,Training_Track__c, (Select Training_Plan__c from Training_Track_Level_Items__r) from Training_Track_Level__c where Training_Track__c IN :trainTrackIdSet]) {
	 			if(trackLevel.Training_Track_Level_Items__r.size() > 0 ) {
	 				for(Training_Track_Level_Item__c trackLevelItem : trackLevel.Training_Track_Level_Items__r) {
	 					if(trackLevelItem.Training_Plan__c != null) {
	 						// adding of data in map trainPlanTracksMap
			 				if(trainPlanTracksMap.containsKey(trackLevelItem.Training_Plan__c)) {
                                //System.debug('enter trackAccountsMap :' + trackAccountsMap.get(trackLevelItem.Training_Plan__c));
                                If(trackAccountsMap.get(trackLevelItem.Training_Plan__c) != null) {
                                    trackAccountsMap.get(trackLevelItem.Training_Plan__c).add(trackLevel.Training_Track__c);
                                }
			 				} else {
                                //System.debug('enter trackLevel :' + trackLevel.Training_Track__c);
			 					trainPlanTracksMap.put(trackLevelItem.Training_Plan__c,new Set<Id>{trackLevel.Training_Track__c});
			 				}
                            
	 					}
	 				}
	 			}
	 		}
	 		
	 		System.debug('trainPlanTracksMap : ' +trainPlanTracksMap);
	 		Map<Id,Set<Id>> TrainPlanUsersMap = new Map<Id,Set<Id>>();
	 		if(trainPlanTracksMap.size() > 0) {
	 			// getting all user under a training plan starts here
	 			for(Id planId : trainPlanTracksMap.KeySet()) {
	 				for(Id trackId : trainPlanTracksMap.get(planId)) {
	 					for(Id accId : trackAccountsMap.get(trackId)) {
	 						if(allAccUserIdMap.containsKey(accId)) {
	 							// adding of data in map TrainPlanUsersMap
				 				if(TrainPlanUsersMap.containsKey(planId)) {
				 					TrainPlanUsersMap.get(planId).add(allAccUserIdMap.get(accId));
				 				} else {
				 					TrainPlanUsersMap.put(planId,new Set<Id>{allAccUserIdMap.get(accId)});
				 				}
	 						}
	 					}
	 				}
	 			}
	 			// getting all user under a training plan ends here
	 			
	 			System.debug('TrainPlanUsersMap : ' + TrainPlanUsersMap);
	 			if (TrainPlanUsersMap.size() > 0) { 
	 				List<As_TPlan_Assignment_Task__c> allTPlanAssgnmtTaskList = new List<As_TPlan_Assignment_Task__c>();
		 			for(Id trainPlan : TrainPlanUsersMap.keySet()) {
		 			
		 				As_TPlan_Assignment_Task__c indiTPlanAssTask = new As_TPlan_Assignment_Task__c();
		 				
		 				List<Id> userIdList = new List<Id>();
		 				userIdList.addAll(TrainPlanUsersMap.get(trainPlan));
		 				
		 				indiTPlanAssTask.As_Training_Plan__c = trainPlan;
		 				indiTPlanAssTask.As_User__c = userIdList[0];
		 				allTPlanAssgnmtTaskList.add(indiTPlanAssTask);
		    	}
		    	
		    	if(allTPlanAssgnmtTaskList.size() > 0 ){
		    		insert allTPlanAssgnmtTaskList;
		    	}
	 			}
	 		}
 		}
 	}
 
}