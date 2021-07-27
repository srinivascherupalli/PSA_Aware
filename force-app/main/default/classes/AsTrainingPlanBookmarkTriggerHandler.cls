/*Author : John Hope
*Description : This is a class that handles AsTrainingPlanBookmark File Object Trigger.
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : AsTrainingPlanBookmark
*/
public class AsTrainingPlanBookmarkTriggerHandler {
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
	public AsTrainingPlanBookmarkTriggerHandler(boolean isExecuting){
		isExecutingBool = isExecuting;
	}
	
	/*Author : John Hope
	*Description : handler for before insert trigger for object AsTrainingPlanBookmark
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
	public void OnBeforeInsert(Object[] newObjects){
	    // EXECUTE BEFORE INSERT LOGIC
	}
	
	/*Author : John Hope
	*Description : handler for after insert trigger for object AsTrainingPlanBookmark
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
	public void OnAfterInsert(Object[] newObjects,Map<Id,Object> newMapObjects) {
		processActivitySummary(newObjects,newMapObjects);
	}
	
	/*Author : John Hope
	*Description : handler for before update trigger for object AsTrainingPlanBookmark
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the old Object from trigger
		1. List<Object> - the new Object from trigger
		2. List<Object> - the new Map Object from trigger
	*Return : 
 	*/
	public void OnBeforeUpdate(Object[] updatedObjects, Map<Id,Object> oldMap, Map<Id,Object> newMap){
		// BEFORE UPDATE LOGIC
	}
	
	/*Author : John Hope
	*Description : handler for after update trigger for object AsTrainingPlanBookmark
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the old Object from trigger
		1. List<Object> - the new Object from trigger
		2. List<Object> - the new Map Object from trigger
	*Return : 
 	*/
	public void OnAfterUpdate(Object[] updatedObjects,Map<Id,Object> oldMap,Map<Id,Object> newMap) {
	}
	
	/*Author : John Hope
	*Description : handler for before delete trigger for object AsTrainingPlanBookmark
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : List<AsTrainingPlanBookmark>,List<AsTrainingPlanBookmark>
		0. List<AsTrainingPlanBookmark> - the old AsTrainingPlanBookmark data from trigger
		1. Map<Id,AsTrainingPlanBookmark> - the old Map data from trigger
	*Return : 
 	*/
	public void OnBeforeDelete(Object[] oldObjects,Map<Id,Object>  MapObjectMap){
	
        
	}
	
	/*Author : John Hope
	*Description : handler for after delete trigger for object AsTrainingPlanBookmark
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
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
	*Description : handler for undelete trigger for object AsTrainingPlanBookmark
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
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
	
	
	public void processActivitySummary(List<Object> newDataList,Map<Id,Object> newMap) {
		
		List<AsTrainingPlanBookmark__c> allTrainBookList = (List<AsTrainingPlanBookmark__c>) newDataList;
		Map<Id,AsTrainingPlanBookmark__c> allTrainBookMap = (Map<Id,AsTrainingPlanBookmark__c>) newMap;
		System.debug('allTrainBookList : ' + allTrainBookList);
		System.debug('allTrainBookMap : ' + allTrainBookMap);
		//Set<Id> trainPlanSet = new Set<Id>();
		Set<String> trainPlanStrIdSet = new Set<String>();
		Set<Id> cpdPlannerSet = new Set<Id>();
		for(AsTrainingPlanBookmark__c book : [Select 
																						AsTrainingPlan__c,
																						AsTrainingPlan__r.Name,
																						AsCPDPlanner__c,
																						Id
																					from 
																						AsTrainingPlanBookmark__c 
																					where 
																						Id IN :allTrainBookMap.KeySet()
																					]) {
			if(book.AsTrainingPlan__c != null) {
				//trainPlanSet.add(book.AsTrainingPlan__c);
				trainPlanStrIdSet.add(String.valueOf(book.AsTrainingPlan__c));
				cpdPlannerSet.add(book.AsCPDPlanner__c);
			}
		}
		System.debug('trainPlanStrIdSet : ' + trainPlanStrIdSet);
		//Map<Id,AsCPD_Learning_Summary__c> summTrainPlanMap = new Map<Id,AsCPD_Learning_Summary__c>();
		Map<String,AsCPD_Learning_Summary__c> summTrainPlanMap = new Map<String,AsCPD_Learning_Summary__c>();
		for(AsCPD_Learning_Summary__c summ : [Select 
																						ASTraining_Plan_Assignment__r.Training_Plan__c,
																						ASTraining_Plan_Name__c,
																						AS_Training_Plan_Record_ID__c,
																						CPD_Planner__c,
																						Id,
																						Name
																					from 
																						AsCPD_Learning_Summary__c 
																					where 
																						AS_Training_Plan_Record_ID__c IN :trainPlanStrIdSet
																					and
																						CPD_Planner__c IN :cpdPlannerSet
																					]) {
			if(String.isNotBlank(summ.AS_Training_Plan_Record_ID__c)) {
				summTrainPlanMap.put(summ.AS_Training_Plan_Record_ID__c.toLowerCase().trim()+String.valueOf(summ.CPD_Planner__c).toLowerCase().trim(),summ);
			}
		}
		
		System.debug('summTrainPlanMap : ' + summTrainPlanMap);
		
		Id activeCPDRecId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByName().get('Active CPD Planner').getRecordTypeId();
		Id plannedSummaRecId = Schema.SObjectType.AsCPD_Learning_Summary__c.getRecordTypeInfosByName().get('Planned Activity').getRecordTypeId();
		
		List<AsCPD_Learning_Summary__c> tobeAddedLearnSummList = new List<AsCPD_Learning_Summary__c>();
		for(AsTrainingPlanBookmark__c book : [Select 
																						AsCPDPlanner__c,
																						AsCPDPlanner__r.AS_Current_CPD_Plan__c,
																						AsCPDPlanner__r.recordtypeId,
																						AsFromCPDPlanTool__c,
																						AsTrainingPlan__c,
																						AsTrainingPlan__r.Name,
																						AsTrainingPlan__r.Type__c,
																						AsTrainingPlan__r.AS_Group_1_CPD__c,
																						AsTrainingPlan__r.AS_Group_2_CPD__c,
																						AsTrainingPlan__r.AS_CPD_Accreditation_Number__c,
																						AsTrainingPlan__r.AS_2016_Competencies__c,
																						AsTrainingPlan__r.Provider__c,
																						AsTrainingPlan__r.Description__c,
																						AsTrainingPlan__r.AS_Training_Plan_Type__c,
																						AsTrainingPlan__r.AsCategory__c,
																						Id
																					from 
																						AsTrainingPlanBookmark__c 
																					where 
																						Id IN :allTrainBookMap.KeySet()
																					]) {
			if(book.AsFromCPDPlanTool__c == true && summTrainPlanMap.containsKey(String.valueOf(book.AsTrainingPlan__c).toLowerCase().trim()+String.valueOf(book.AsCPDPlanner__c).toLowerCase().trim()) == false) {
				System.debug('misulod sa adding 2');
				AsCPD_Learning_Summary__c inditobeAddedLearnSummList = new AsCPD_Learning_Summary__c();
				inditobeAddedLearnSummList.Name = book.AsTrainingPlan__r.Name;
				inditobeAddedLearnSummList.ASTraining_Plan_Name__c = book.AsTrainingPlan__r.Name;
				inditobeAddedLearnSummList.CPD_Accreditation_Number__c = book.AsTrainingPlan__r.AS_CPD_Accreditation_Number__c;
				inditobeAddedLearnSummList.X2016_Competencies__c = book.AsTrainingPlan__r.AS_2016_Competencies__c;
				inditobeAddedLearnSummList.Provider__c = book.AsTrainingPlan__r.Provider__c;
				inditobeAddedLearnSummList.Description__c = book.AsTrainingPlan__r.Description__c;
				inditobeAddedLearnSummList.CPD_Planner__c = book.AsCPDPlanner__c;
				inditobeAddedLearnSummList.Status__c = 'Planned';
				inditobeAddedLearnSummList.AS_Planned_Status_Validation__c = true;
				inditobeAddedLearnSummList.AS_Bookmarked_Course__c = book.Id;
				inditobeAddedLearnSummList.AS_Training_Plan_Record_ID__c = (book.AsTrainingPlan__c!=null)?String.valueOf(book.AsTrainingPlan__c):null;
				inditobeAddedLearnSummList.RecordTypeId = plannedSummaRecId;
				inditobeAddedLearnSummList.AsSummary_Plan__c = true;
				inditobeAddedLearnSummList.Type__c = book.AsTrainingPlan__r.AS_Training_Plan_Type__c;
				inditobeAddedLearnSummList.AS_Type__c = book.AsTrainingPlan__r.AS_Training_Plan_Type__c;
				inditobeAddedLearnSummList.AS_Topics__c = book.AsTrainingPlan__r.AsCategory__c;
				tobeAddedLearnSummList.add(inditobeAddedLearnSummList);
			} 
			// coode below added for ticket (#PSA-236)
			else if (book.AsFromCPDPlanTool__c == false && book.AsCPDPlanner__r.recordtypeId == activeCPDRecId && book.AsCPDPlanner__r.AS_Current_CPD_Plan__c == true && summTrainPlanMap.containsKey(String.valueOf(book.AsTrainingPlan__c).toLowerCase().trim()+String.valueOf(book.AsCPDPlanner__c).toLowerCase().trim()) == false) {
				System.debug('misulod sa adding 3');
				AsCPD_Learning_Summary__c inditobeAddedLearnSummList = new AsCPD_Learning_Summary__c();
				inditobeAddedLearnSummList.Name = book.AsTrainingPlan__r.Name;
				inditobeAddedLearnSummList.ASTraining_Plan_Name__c = book.AsTrainingPlan__r.Name;
				inditobeAddedLearnSummList.CPD_Accreditation_Number__c = book.AsTrainingPlan__r.AS_CPD_Accreditation_Number__c;
				inditobeAddedLearnSummList.X2016_Competencies__c = book.AsTrainingPlan__r.AS_2016_Competencies__c;
				inditobeAddedLearnSummList.Provider__c = book.AsTrainingPlan__r.Provider__c;
				inditobeAddedLearnSummList.Description__c = book.AsTrainingPlan__r.Description__c;
				inditobeAddedLearnSummList.CPD_Planner__c = book.AsCPDPlanner__c;
				inditobeAddedLearnSummList.Status__c = 'Planned';
				inditobeAddedLearnSummList.AS_Planned_Status_Validation__c = true;
				inditobeAddedLearnSummList.AS_Bookmarked_Course__c = book.Id;
				inditobeAddedLearnSummList.AS_Training_Plan_Record_ID__c = (book.AsTrainingPlan__c!=null)?String.valueOf(book.AsTrainingPlan__c):null;
				inditobeAddedLearnSummList.RecordTypeId = plannedSummaRecId;
				inditobeAddedLearnSummList.AsSummary_Plan__c = true;
				inditobeAddedLearnSummList.Type__c = book.AsTrainingPlan__r.AS_Training_Plan_Type__c;
				inditobeAddedLearnSummList.AS_Type__c = book.AsTrainingPlan__r.AS_Training_Plan_Type__c;
				inditobeAddedLearnSummList.AS_Topics__c = book.AsTrainingPlan__r.AsCategory__c;
				tobeAddedLearnSummList.add(inditobeAddedLearnSummList);
				
			}
		}
		System.debug('tobeAddedLearnSummList : ' + tobeAddedLearnSummList);
		if(tobeAddedLearnSummList.size() > 0) {
			insert tobeAddedLearnSummList;
		}
	}
	
	
	
	
	
}