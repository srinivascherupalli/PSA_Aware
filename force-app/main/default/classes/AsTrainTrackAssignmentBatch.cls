public class AsTrainTrackAssignmentBatch implements Database.batchable<SObject>,Database.Stateful{
    
	private String errorMessage = '';
 	public Id communityId;
	public AsTrainTrackAssignmentBatch() {
		communityId = LMSUtils.getCurrentNetworkId();
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
			return Database.getQueryLocator('Select '+
																				'Id, ' +
																				'Name,' +
																				'As_User__c,' +
																				'As_Training_Plan__c ' +
																			 'from ' +
																			 	'As_TPlan_Assignment_Task__c ' +
																			 'where ' +
																			 	'As_Status__c=\'In Progress\' ' +
																			 'order by ' +
																			 	'createdDate asc'
																			);
	}

 	public void execute(Database.BatchableContext BC, List<As_TPlan_Assignment_Task__c> scope) {
			System.debug('Scope : ' + scope);
			for(As_TPlan_Assignment_Task__c task : scope) {
				try {
					Set<Id> userIds = new Set<Id>();
					Id trainingPlanId;
					Id communityId;
					
					userIds.add(task.As_User__c);
					trainingPlanId = task.As_Training_Plan__c;
	       	//Ignore inactive users
	        Map<Id,User> activeUsers = LMSService.getUserMap(userIds, true);
	        
	        //Auxiliary collections
	        Map<Id,List<Learning_Assignment__c>> results = new Map<Id,List<Learning_Assignment__c>>();
	        List<Learning_Assignment__c> assignmentsToInsert = new List<Learning_Assignment__c>();
	        Set<Id> newUsersWithAssignments = new Set<Id>();
	        Map<Id,Set<String>> excludedLearnings = new Map<Id,Set<String>>();
	        Map<Id,Training_Plan_Assignment__c> planAssignmentsToUpdate = new Map<Id,Training_Plan_Assignment__c>();
	
	        //Get all the learning ids under the specified training plan
	        Map<Id,Learning_Assignment__c> updatedOptionalAssignments = new  Map<Id,Learning_Assignment__c>();
	
	        LMSService.WithoutSharingOps wsops = new LMSService.WithoutSharingOps();
	        
	        Map<Id,Set<Id>> trainingPlanLearnings = wsops.getTrainingPlanLearningIds(new Set<Id>{trainingPlanId});
	        
	        //Get existing assignments for the user + learnings under the training plan, and add them to excluded learnings
	        System.debug('trainingPlanInLearning : ' + trainingPlanLearnings.get(trainingPlanId));
	        if(trainingPlanLearnings.get(trainingPlanId) != null){
	
	            //Fetch additional information for related training plan section items
	            Map<Id,List<Training_Plan_Section_Item__c>> tPlanSectionItems = wsops.getTrainingPlanSectionItemsFromTrainingPlans(new Set<Id>{trainingPlanId});
	            
	            //Fetch optional attribute from related training plan section and section items
	            Map<Id,Boolean> tPlanSectionItemMap = new Map<Id,Boolean>();
	            if(tPlanSectionItems.get(trainingPlanId) != null){
	                List<Training_Plan_Section_Item__c> sectionItems = tPlanSectionItems.get(trainingPlanId);
	                
	                for(Training_Plan_Section_Item__c tpsi : sectionItems){
	                    Boolean isOptional = false;
	                    if(tpsi.Training_Plan_Section__r != null && tpsi.Training_Plan_Section__r.Optional__c){
	                        isOptional = true;
	                    }else{
	                        isOptional = tpsi.Optional__c;
	                    }
	                    tPlanSectionItemMap.put(tpsi.id,isOptional);
	                }
	            }
	
	            Set<Id> learnings = trainingPlanLearnings.get(trainingPlanId);
	            
	            Map<Id,List<Learning_Assignment__c>> mapLearningAssignments = LMSService.getAssignmentsForLearnings(learnings,trainingPlanId,activeUsers.keySet());
	
	            //Look for learnings that already have assignments and add to excluded map
	            for(Id learningId : mapLearningAssignments.keySet()){
	                List<Learning_Assignment__c> existingUserAssignments = mapLearningAssignments.get(learningId);
	                for(Learning_Assignment__c la : existingUserAssignments){
	
	                    Id sectionItemId = la.Training_Plan_Section_Item__c;
	
	                    //Get the training plan assignment Id and store it, we'll update the Last Updated field here
	                    Id tPlanAssignmentId = la.Training_Plan_Section_Assignment__r.Training_Plan_Assignment__c;
	                    if(tPlanAssignmentId!= null && !planAssignmentsToUpdate.containsKey(tPlanAssignmentId)){
	                        planAssignmentsToUpdate.put(tPlanAssignmentId,new Training_Plan_Assignment__c(id=tPlanAssignmentId,Last_Updated__c = DateTime.now()));
	                    }
	
	                    //Initialize the set of excluded Learnings with the user id as key
	                    if(!excludedLearnings.containsKey(la.User__c)){
	                        excludedLearnings.put(la.User__c,new Set<String>());
	                    }
	                    //The value of the user key is a combination of learning and sectionItemId
	                    excludedLearnings.get(la.User__c).add(learningId+'_'+sectionItemId);
	
	                    //Update optional attributes if related section or section item has changed
	                    if(tPlanSectionItemMap.containsKey(la.Training_Plan_Section_Item__c)){
	                        if(la.Optional__c != tPlanSectionItemMap.get(la.Training_Plan_Section_Item__c)){
	                            la.Optional__c = tPlanSectionItemMap.get(la.Training_Plan_Section_Item__c);
	                            updatedOptionalAssignments.put(la.Id,la); 
	                        }
	                    }
	
	                }
	            }
	
	            for(List<Training_Plan_Section_Item__c> sectionItems : tPlanSectionItems.values()){
	
	                for(Training_Plan_Section_Item__c sectionItem : sectionItems){
	
	                    if(sectionItem.Learning__c != null){
	                        for(Id userId : activeUsers.keySet()){
	
	                            if(!excludedLearnings.containsKey(userId) || (excludedLearnings.containsKey(userId) && !excludedLearnings.get(userId).contains(sectionItem.Learning__c+'_'+sectionItem.Id))){
	
	                                User uInfo = activeUsers.get(userId);
	                                //Add learning to insert map
	                                Learning_Assignment__c newLA = new Learning_Assignment__c();
	                                newLA.OwnerId = userId;
	                                newLA.User__c = userId;
	                                newLA.Learning__c = sectionItem.Learning__c;
	                                newLA.Learning_Version__c = sectionItem.Learning__r.Current_Published_Version__c;
	                                newLA.Training_Plan__c = sectionItem.Training_Plan_Section__r.Training_Plan__c;
	                                newLA.Progress__c= LMSConstants.ASSIGNMENT_STATUS_NOT_STARTED;
	                                newLA.Progress_Percentage__c = 0;
	                                newLA.Training_Plan_Section__c = sectionItem.Training_Plan_Section__c;
	                                newLA.Training_Plan_Section_Item__c = sectionItem.Id;
	                                newLA.Contact__c = uInfo.ContactId;
	                                newLA.Optional__c = sectionItem.Optional__c;
	                                newLA.Community_Id__c = communityId;
	                                if(!results.containsKey(userId)){
	                                    results.put(userId,new List<Learning_Assignment__c>());
	                                }
	
	                                assignmentsToInsert.add(newLA);
	                                // Only share the training plan with supported licenses
	                                if(uInfo.UserType == 'Standard' || uInfo.UserType == 'CsnOnly'){
	                                    newUsersWithAssignments.add(userId);
	                                }
	
	                                results.get(userId).add(newLA);
	                            }
	                        } 
	                    }
	                }
	            }
	        }
					
					System.debug('newUsersWithAssignments : ' + newUsersWithAssignments);
	        if(newUsersWithAssignments.size()>0){
	            //Share the training and learnings with corresponding users
	            wsops.shareTrainingPlanWithUsers(newUsersWithAssignments,new Set<Id>{trainingPlanId});
	        }
	
	        // Regular users dont' have permissions to insert these objects, however it's possible that they create assignments
	        // for training plans with self-registration enabled. Therefore, we leave CRUD/FLS enforcement to the caller
	        // We need to insert these records in without sharing context to prevent insufficient cross reference errors since we don't
	        // share the learnings associated to the assignments due to limitations with portal users
	        System.debug('assignmentsToInsert : ' + assignmentsToInsert);
	        if(assignmentsToInsert.size()>0){
	            wsops.insertAssignments(assignmentsToInsert);
	        }
	
	        // Update optional flag for assignments where the parent section item or section has changed
	        // We need to update these records in without sharing context to prevent insufficient cross reference errors since we don't
	        // share the learnings associated to the assignments due to limitations with portal users
	        System.debug('updatedOptionalAssignments : ' + updatedOptionalAssignments);
	        if(updatedOptionalAssignments.size()>0){
	            wsops.updateAssignments(updatedOptionalAssignments.values());
	        }
	
					System.debug('planAssignmentsToUpdate : ' + planAssignmentsToUpdate);
	        if(planAssignmentsToUpdate.size()>0){
	            wsops.updateTrainingPlanAssignments(planAssignmentsToUpdate.values());
	        }
	
	        // Create Badge Assignments
	        LMSService.upsertAchievementAssignments(activeUsers.keySet(),trainingPlanId, communityId);
	
	        System.debug('results : ' + results);
      	} catch(Exception ex) {
		        errorMessage += '\n\r'+ task.Id + ' record : ' + ex.getMessage() + ' - Line :' + ex.getLineNumber();
		    }
		    
			}
    
   		
	}
	
	public void finish(Database.BatchableContext BC) {
		 
 		try {
       if(String.isNotBlank(errorMessage)) { 
       	AsyncApexJob batchResult = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];    
       // Email the Batch Job's submitter that the Job is finished.  
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
       String[] toAddresses = new String[] {batchResult.CreatedBy.Email};
       mail.setToAddresses(toAddresses);  
       mail.setSubject('Training Track Batch Process');  
       String theEmailBody = ''; 
       
       
         
          theEmailBody += 'This email is to notify you that your recent batch for training track registration has encountered some error.\n\r'; 
          theEmailBody += 'ERROR : \n';
          theEmailBody += errorMessage + '\n\r';
          
          mail.setPlainTextBody(theEmailBody);  
          
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       }
    } catch(Exception e) {
        
    }
    
    List<LMS_Instance__c> allLMSInstanceList = [Select 
    																							Id,
    																							Domain_URL__c,
    																							Status__c,
    																							Token__c,
    																							Type__c,
    																							URL__c 
    																						from 
    																							LMS_Instance__c 
    																						where 
    																							URL__c <> null 
    																						and 
    																							Token__c <> null
    																						];
 		if(allLMSInstanceList.size() > 0) {
 			ASCourseEnrollmentToMoodleBatch runBatch = new ASCourseEnrollmentToMoodleBatch(allLMSInstanceList,null); // this part call's ronald batch process
   		database.executeBatch(runBatch,50); 
 		}																				
        
	}
	
	
}