/*Author : John Hope
*Description : This is a class that handles Learning Summary File Object Trigger.
*Date Created : May 16, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : Learning Summary
*/
public class AsCPDLearningSummaryTriggerHandler {
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
	public AsCPDLearningSummaryTriggerHandler(boolean isExecuting){
		isExecutingBool = isExecuting;
	}
	
	/*Author : John Hope
	*Description : handler for before insert trigger for object Learning Summary
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
		prefillLearnSummaryData(newObjects);
	}
	
	/*Author : John Hope
	*Description : handler for after insert trigger for object Learning Summary
	*Date Created : May 16, 2018
	*Last Modified By : 
	*Date Last Modified : May 16, 2018
	*Related Meta Data :
	*Param :
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
	public void OnAfterInsert(Object[] newObjects,Map<Id,Object> newMapObjects){
		//updatePlannerGroupCPD(newObjects);
	}
	
	/*Author : John Hope
	*Description : handler for before update trigger for object Learning Summary
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
	public void OnBeforeUpdate(Object[] newObjects, Map<Id,Object> oldMap,Map<Id,Object> newMap){
		// BEFORE UPDATE LOGIC
	}
	
	/*Author : John Hope
	*Description : handler for after update trigger for object Learning Summary
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
	public void OnAfterUpdate(Object[] newObjects,Map<Id,Object> oldMap,Map<Id,Object> newMap){
		//updatePlannerGroupCPD(newObjects);
	}
	
	/*Author : John Hope
	*Description : handler for before delete trigger for object Learning Summary 
							 : added for ticket (PSA-120) for deletion of of activity learning
	*Date Created : May 16, 2018
	*Last Modified By : 
	*Date Last Modified : May 16, 2018
	*Related Meta Data :
	*Param : List<Learning Summary>,List<Learning Summary>
		0. List<Learning Summary> - the old Learning Summary data from trigger
		1. Map<Id,Learning Summary> - the old Map data from trigger
	*Return : 
 	*/
	public void OnBeforeDelete(Object[] oldObjects,Map<Id,Object>  MapObjectMap){
		// added for PSA-120
		deleteRelatedBookmark(oldObjects,MapObjectMap);
	}
	
	/*Author : John Hope
	*Description : handler for after delete trigger for object Learning Summary
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
		
	}
	
	/*Author : John Hope
	*Description : handler for undelete trigger for object Learning Summary
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
	
	/*Author : John Hope
	*Description : use to update the planner group cpd.
	*Date Created : May 24, 2018
	*Last Modified By : 
	*Date Last Modified : May 24, 2018
	*Related Meta Data :
	*Param :
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
	public void deleteRelatedBookmark(Object[] deletedData,Map<Id,Object> deleteMap){
		Id trainPlanRecId = Schema.SObjectType.AsCPD_Learning_Summary__c.getRecordTypeInfosByName().get('Training Plan').getRecordTypeId();
		Set<Id> tobeDeletedBook = new Set<Id>();
		Integer counter = 0;
		Map<Id,Profile> memberProfileMap = new Map<Id,Profile>([Select Id,Name from Profile where Name IN ('Member Login User','Non Member Login User')]); // code is update from system administrator as per ticket (#PSA-400)
		for(AsCPD_Learning_Summary__c summ : [Select Id,AS_Bookmarked_Course__c,recordTypeId from AsCPD_Learning_Summary__c where Id IN :deleteMap.keySet()]) {
			AsCPD_Learning_Summary__c actualRecord = (AsCPD_Learning_Summary__c) Trigger.oldMap.get(summ.Id); 
			if(summ.recordTypeId == trainPlanRecId && memberProfileMap.containsKey(UserInfo.getProfileId())) {
				actualRecord.addError('You cannot delete an activity that is related to an existing course enrolment. If you simply do not need to include this activity in your Plan Summary document, please uncheck "Include in CPD Plan Summary" in the activity page.');
			} else {
				tobeDeletedBook.add(summ.AS_Bookmarked_Course__c);
			}
			counter++;
		}
		
		List<AsTrainingPlanBookmark__c> allBook = [Select Id from AsTrainingPlanBookmark__c where Id IN :tobeDeletedBook];
		delete allBook;
	}
	/*Author : John Hope
	*Description : use to update the planner group cpd.
	*Date Created : May 24, 2018
	*Last Modified By : 
	*Date Last Modified : May 24, 2018
	*Related Meta Data :
	*Param :
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
 	// code block commented is for ticket #PSA-156 
 	/*
	public void updatePlannerGroupCPD(Object[] newObjects){
		Set<Id> allCPDPlannerSet = new Set<Id>();
		for(AsCPD_Learning_Summary__c sum :(List<AsCPD_Learning_Summary__c>) newObjects) {
			allCPDPlannerSet.add(sum.CPD_Planner__c);
		}
		
		List<AsCPDPlanner__c> allTobeUpdatedPlannerList = new List<AsCPDPlanner__c>();
		for(AggregateResult summa : [Select 
																		CPD_Planner__c plan, 
																		SUM(Group_1_CPD__c) sum1, 
																		SUM(Group_2_CPD__c) sum2, 
																		SUM(Group_3_CPD__c) sum3
																	from 
																		AsCPD_Learning_Summary__c 
																	where 
																		CPD_Planner__c IN :allCPDPlannerSet 
																	Group by
																		CPD_Planner__c
																	]) {
			AsCPDPlanner__c indiTobeUpdatedPlanner = new AsCPDPlanner__c();
			indiTobeUpdatedPlanner.Id = (Id) summa.get('plan');
			
			indiTobeUpdatedPlanner.AS_Group_1_CPD__c = (Double) summa.get('sum1');
			indiTobeUpdatedPlanner.AS_Group_2_CPD__c = (Double) summa.get('sum2');
			indiTobeUpdatedPlanner.AS_Group_3_CPD__c = (Double) summa.get('sum3');
			
			allTobeUpdatedPlannerList.add(indiTobeUpdatedPlanner);														
		}
		update allTobeUpdatedPlannerList;
	}
	*/
	
	/*Author : John Hope
	*Description : use to prefill learning summary data when training plan assignment lookup is complete
	*Date Created : May 24, 2018
	*Last Modified By : 
	*Date Last Modified : May 24, 2018
	*Related Meta Data :
	*Param :
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
	public void prefillLearnSummaryData(Object[] newObjects){
		Set<Id> allTrainPlanAss = new Set<Id>();
		Set<Id> allCPDPlannerSet = new Set<Id>();
		for(AsCPD_Learning_Summary__c sum :(List<AsCPD_Learning_Summary__c>) newObjects) {
			allTrainPlanAss.add(sum.ASTraining_Plan_Assignment__c);
			allCPDPlannerSet.add(sum.CPD_Planner__c);
		}
		
		Map<Id,Training_Plan_Assignment__c> allTrainPlanAssMap = new Map<Id,Training_Plan_Assignment__c>();
		for( Training_Plan_Assignment__c tpAssign : [Select 
																						AS_Group_1_CPD_Achieved__c,
																						AS_Group_2_CPD_Achieved__c,
																						Completed_On__c,
																						CreatedDate,
																						Id,
																						Name,
																						Status__c,
																						Training_Plan__r.Name,
																						Training_Plan__r.Type__c,
																						Training_Plan__r.Description__c,
																						Training_Plan__r.AS_CPD_Accreditation_Number__c,
																						Training_Plan__r.Provider__c,
																						Training_Plan__r.AS_2016_Competencies__c,
																						Training_Plan__r.AS_Training_Plan_Type__c
																					from 
																						Training_Plan_Assignment__c 
																					where 
																						Id IN :allTrainPlanAss
																					] ) {
			allTrainPlanAssMap.put(tpAssign.Id,tpAssign);
		}
		
		Map<Id,AsCPDPlanner__c> allPlannerMap = new Map<Id,AsCPDPlanner__c>();
		for( AsCPDPlanner__c planner : [Select 
																			AsUser__c,
																			Id
																		from 
																			AsCPDPlanner__c 
																		where 
																			Id IN :allCPDPlannerSet
																		] ) {
			allPlannerMap.put(planner.Id,planner);
		}
		
		List<Training_Plan_Assignment__c> allTPAssignList = new List<Training_Plan_Assignment__c>();
		for(AsCPD_Learning_Summary__c sum :(List<AsCPD_Learning_Summary__c>) newObjects) {
			if(allTrainPlanAssMap.containsKey(sum.ASTraining_Plan_Assignment__c) && allTrainPlanAssMap.get(sum.ASTraining_Plan_Assignment__c).Status__c == 'Completed') {
				Training_Plan_Assignment__c assign = allTrainPlanAssMap.get(sum.ASTraining_Plan_Assignment__c);
				sum.Group_1_CPD__c = assign.AS_Group_1_CPD_Achieved__c;
				sum.Group_2_CPD__c = assign.AS_Group_2_CPD_Achieved__c;
		//		sum.Group_3_CPD__c = assign.AS_Group_2_CPD__c; // to be updated
				sum.ASTraining_Plan_Name__c = assign.Training_Plan__r.Name; 
				sum.Type__c = assign.Training_Plan__r.AS_Training_Plan_Type__c; 
				sum.Description__c = assign.Training_Plan__r.Description__c;
				sum.CPD_Accreditation_Number__c = assign.Training_Plan__r.AS_CPD_Accreditation_Number__c;
				sum.Provider__c = assign.Training_Plan__r.Provider__c;
				sum.X2016_Competencies__c = assign.Training_Plan__r.AS_2016_Competencies__c;
				sum.Start_Date__c = Date.valueOf( assign.CreatedDate );
				sum.End_Date__c = assign.Completed_On__c;
		//		sum.Notes__c = assign.User_Notes__c;
				
				// updating assignment user
				Training_Plan_Assignment__c indiTPAss = new Training_Plan_Assignment__c();
				indiTPAss.Id = assign.Id;
				indiTPAss.User__c = allPlannerMap.get(sum.CPD_Planner__c).AsUser__c;
				allTPAssignList.add(indiTPAss);
			}
		}
		
		System.debug('allTPAssignList :' + allTPAssignList);
		update allTPAssignList;
	}
	
	
}