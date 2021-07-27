/*
Copyright (c) 2014, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
public with sharing class TrainingPlanAssignmentHelper{

    public static void processBeforeUpdate(Map<Id,Training_Plan_Assignment__c> oldAssignmentsMap,Map<Id,Training_Plan_Assignment__c> newAssignmentsMap){
        //Only process assignments that have changed
        for(Training_Plan_Assignment__c tpa : newAssignmentsMap.values()){

            Training_Plan_Assignment__c oldTPA = oldAssignmentsMap.get(tpa.Id);

            if(oldTPA.Status__c != LMSConstants.ASSIGNMENT_STATUS_COMPLETED && tpa.Status__c == LMSConstants.ASSIGNMENT_STATUS_COMPLETED){
                tpa.Completed_On__c = Date.today();
            }
        }
    }

    public static void processAfterInsert(List<Training_Plan_Assignment__c> assignments, Map<Id,Training_Plan_Assignment__c> newAssignmentsMap){
//        postChatterNotifications(assignments);
        System.debug(' INSERT THE TRAINING PLAN assignments : ' + assignments.size() + assignments);
        createLearnSumOnComplete(new Map<Id,Training_Plan_Assignment__c>(),newAssignmentsMap,'INSERT');
        checkAndUpdateTPlanTask(newAssignmentsMap);
    }

    public static void processBeforeDelete(List<Training_Plan_Assignment__c> assignments){
        deleteAssociatedLearningAssignments(assignments);
    }

    public static void processAfterUpdate(Map<Id,Training_Plan_Assignment__c> oldAssignmentsMap,Map<Id,Training_Plan_Assignment__c> newAssignmentsMap){
        System.debug(' UPDATE THE TRAINING PLAN assignments : ' + newAssignmentsMap.size() + newAssignmentsMap);
        processAchievementRulesForAssignments(oldAssignmentsMap,newAssignmentsMap);
        createLearnSumOnComplete(oldAssignmentsMap,newAssignmentsMap,'UPDATE');
        checkAndUpdateTPlanTask(newAssignmentsMap); 
    }
    
    // added for fixing error of maximum trigger depth starts here 7-25-2018
    public static boolean createLearnSumEnroll = true;
    
    /*Author : John Hope
    *Description : check the run variable and use for recursion
    *Date Created : 
    *Last Modified By : 
    *Date Last Modified : 
    *Related Meta Data :
    *Param :
    *Return : Boolean
    */
    public static boolean runcreateLearnSumEnroll(){
        if(createLearnSumEnroll){
         createLearnSumEnroll=false;
         return true;
        }else{
            return createLearnSumEnroll;
        }
    } 
    
    /*Author : John Hope
    *Description : this method is used to create or update a learning summary when status is complete
    *Date Created : May 24, 2018
    *Last Modified By : 
    *Date Last Modified : May 27, 2018
    *Related Meta Data :
    *Param : 
        0. Map<Id,Object> - the old object data map from trigger
        1. Map<Id,Object> - the new object data map from trigger
    *Return : 
		*/
		public static void checkAndUpdateTPlanTask(Map<Id,Training_Plan_Assignment__c> newAssignmentsMap) {
			Set<Id> allTPlanIdSet = new Set<Id>();
			Set<Id> allUserIdSet = new Set<Id>();
			for(Training_Plan_Assignment__c tPlanAssgnmt : newAssignmentsMap.values()) {
				if(tPlanAssgnmt.User__c != null) {
					allUserIdSet.add(tPlanAssgnmt.User__c);
				}
				if(tPlanAssgnmt.Training_Plan__c != null) {
					allTPlanIdSet.add(tPlanAssgnmt.Training_Plan__c);
				}
			}
			
			Map<String,Id> tPlanTaskMap = new Map<String,Id>();
			for(As_TPlan_Assignment_Task__c tPlanTask : [Select 
																										As_Training_Plan__c,
																										As_User__c,
																										Id
																									from 
																										As_TPlan_Assignment_Task__c 
																									where 
																										As_Training_Plan__c IN :allTPlanIdSet 
																									AND 
																										As_User__c IN :allUserIdSet
																									AND
																										As_Status__c = 'In Progress'
																									]) {
				String mapKey = String.valueOf(tPlanTask.As_Training_Plan__c).toLowerCase()+String.valueOf(tPlanTask.As_User__c).toLowerCase();
				tPlanTaskMap.put(mapKey,tPlanTask.Id);
			}
			
			List<As_TPlan_Assignment_Task__c> toBeUpdatedTPlanTaskList = new List<As_TPlan_Assignment_Task__c>();
			Set<Id> toBeUpdatedTPlanTaskIdSet = new Set<Id>();
			for(Training_Plan_Assignment__c tPlanAssgnmt : newAssignmentsMap.values()) {
				if(tPlanAssgnmt.User__c != null && tPlanAssgnmt.Training_Plan__c != null) {
					String mapKey = String.valueOf(tPlanAssgnmt.Training_Plan__c).toLowerCase()+String.valueOf(tPlanAssgnmt.User__c).toLowerCase();
					if(tPlanTaskMap.containsKey(mapKey) && toBeUpdatedTPlanTaskIdSet.contains(tPlanTaskMap.get(mapKey)) == false) {
						As_TPlan_Assignment_Task__c indiToBeUpdatedTPlanTask = new As_TPlan_Assignment_Task__c();
						indiToBeUpdatedTPlanTask.Id = tPlanTaskMap.get(mapKey);
						indiToBeUpdatedTPlanTask.As_Status__c = 'Complete';
						toBeUpdatedTPlanTaskList.add(indiToBeUpdatedTPlanTask);
						
						// added as of 2/22/19 by john for ticket (#PSA-362)
						toBeUpdatedTPlanTaskIdSet.add(tPlanTaskMap.get(mapKey));
					}
				}
			}
			if(toBeUpdatedTPlanTaskList.size()>0){
				update toBeUpdatedTPlanTaskList;
			}
		}
    
		/*Author : John Hope
	    *Description : this method is used to create or update a learning summary when status is complete
	    *Date Created : May 24, 2018
	    *Last Modified By : 
	    *Date Last Modified : May 27, 2018
	    *Related Meta Data :
	    *Param : 
	        0. Map<Id,Object> - the old object data map from trigger
	        1. Map<Id,Object> - the new object data map from trigger
	    *Return : 
    */
    public static void createLearnSumOnComplete(Map<Id,Training_Plan_Assignment__c> oldAssignmentsMap,Map<Id,Training_Plan_Assignment__c> newAssignmentsMap,String action) {
        System.debug('oldAssignmentsMap : '+ oldAssignmentsMap);
        System.debug('newAssignmentsMap : '+ newAssignmentsMap);
        if(runcreateLearnSumEnroll()) {
        	System.debug('TrainingPlanAssignmentHelper : no recursion');
            Set<Id> allTPAssIdSet = new Set<Id>();
            Map<String,Id> summTPMap = new Map<String,Id>();
            Set<Id> allCPDUserIdSet = new Set<Id>();
            for(Id key : newAssignmentsMap.KeySet()) {
                Training_Plan_Assignment__c oldAssign = new Training_Plan_Assignment__c();
                Training_Plan_Assignment__c newAssign = new Training_Plan_Assignment__c();
                if(action=='UPDATE') {
                    oldAssign = oldAssignmentsMap.get(key);
                }
                newAssign = newAssignmentsMap.get(key);
                
                if(action=='INSERT' || action=='UPDATE') {
                    allTPAssIdSet.add(key);
                    
                    if(newAssign.User__c != null) {
                        allCPDUserIdSet.add(newAssign.User__c);
                    }
                    
                }
            }
            // use to get the cpd Planner of the user starts here
            Id activeCPDRecId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByName().get('Active CPD Planner').getRecordTypeId();
            Map<Id,AsCPDPlanner__c> allPlannerMap = new Map<Id,AsCPDPlanner__c>();
            Set<Id> allCPDIdSet = new Set<Id>();
            for( AsCPDPlanner__c planner : [Select 
										                            AsUser__c,
										                            Id
										                        from 
										                            AsCPDPlanner__c 
										                        where 
										                            AsUser__c IN :allCPDUserIdSet 
										                        AND 
										                            AS_Current_CPD_Plan__c = true
										                        AND
										                            recordTypeId = :activeCPDRecId
										                      	for update
										                        ] ) {
                allPlannerMap.put(planner.AsUser__c,planner);
                allCPDIdSet.add(planner.Id);
            }
            // use to get the cpd Planner of the user ends here
            
            System.debug('allCPDUserIdSet : '+ allCPDUserIdSet);
            Id trainPlanRecId = Schema.SObjectType.AsCPD_Learning_Summary__c.getRecordTypeInfosByName().get('Training Plan').getRecordTypeId();
            Id planActRecId = Schema.SObjectType.AsCPD_Learning_Summary__c.getRecordTypeInfosByName().get('Planned Activity').getRecordTypeId();
            Map<Id,Training_Plan_Assignment__c> allTrainPlanAssMap = new Map<Id,Training_Plan_Assignment__c>();
            Map<Id,Boolean> allFoundLearSumm = new Map<Id,Boolean>();
            List<AsCPD_Learning_Summary__c> tobeUpdatedLearnSummList = new List<AsCPD_Learning_Summary__c>();
            Map<String,AsCPD_Learning_Summary__c> tempLearnSummList = new Map<String,AsCPD_Learning_Summary__c>();
            Map<String,Training_Plan_Assignment__c> tPlanCpdAssignList = new Map<String,Training_Plan_Assignment__c>();
            Map<Id,Boolean> activeTPlanMap = new Map<Id,Boolean>();
            if(allTPAssIdSet.size() > 0) {
                for( Training_Plan_Assignment__c tpAssign : [Select 
										                                            AS_Group_1_CPD_Achieved__c,
										                                            AS_Group_2_CPD_Achieved__c,
										                                            Completed_On__c,
										                                            CreatedDate,
										                                            Id,
										                                            Name,
										                                            Status__c,
										                                            Training_Plan__c,
										                                            Training_Plan__r.Status__c,
										                                            Training_Plan__r.Name,
										                                            Training_Plan__r.Type__c,
										                                            Training_Plan__r.Description__c,
										                                            Training_Plan__r.AS_CPD_Accreditation_Number__c,
										                                            Training_Plan__r.Provider__c,
										                                            Training_Plan__r.AS_2016_Competencies__c,
										                                            Training_Plan__r.AS_Training_Plan_Type__c,
										                                            Training_Plan__r.AsCategory__c,
										                                            User__c
										                                        from 
										                                            Training_Plan_Assignment__c 
										                                        where 
										                                            Id IN :allTPAssIdSet
										                                       	for update
										                                        ] ) {
                    allTrainPlanAssMap.put(tpAssign.Id,tpAssign);
                    summTPMap.put(String.valueOf(tpAssign.Training_Plan__c),tpAssign.Id);
                    if(tpAssign.Training_Plan__c != null && tpAssign.User__c != null && allPlannerMap.containsKey(tpAssign.User__c)) {
                    	String theKeyStr  = String.valueOf(tpAssign.Training_Plan__c).toLowerCase().trim() + String.valueOf(allPlannerMap.get(tpAssign.User__c).Id).toLowerCase().trim();
                    	tPlanCpdAssignList.put(theKeyStr,tpAssign);
                    }
                    
                    // code block below is added for (#PSA-301)
                    if(tpAssign.Training_Plan__c != null && tpAssign.Training_Plan__r.Status__c == 'Active') {
                    	activeTPlanMap.put(tpAssign.Training_Plan__c,true);
                    }
                    
                }
                
                System.debug('allTrainPlanAssMap : '+ allTrainPlanAssMap);
                System.debug('tPlanCpdAssignList : '+ tPlanCpdAssignList);
                
                for(AsCPD_Learning_Summary__c learn : [Select 
	                                                        ASTraining_Plan_Assignment__c,
	                                                        ASTraining_Plan_Assignment__r.Status__c,
	                                                        AS_Training_Plan_Record_ID__c,
	                                                        CPD_Planner__c,
	                                                        Id,
	                                                        Name,
	                                                        Status__c
                                                        from 
                                                    		AsCPD_Learning_Summary__c 
                                                        where 
                                                        (
                                                        	ASTraining_Plan_Assignment__c IN :allTrainPlanAssMap.KeySet()
                                                        	and
                                                            CPD_Planner__c IN :allCPDIdSet
                                                        )
                                                        OR 
                                                        (
                                                        	ASTraining_Plan_Assignment__c IN :allTrainPlanAssMap.KeySet()
                                                        	and
                                                    			Status__c = 'Complete'
                                                        )
                                                        OR 
                                                        (
                                                        	recordTypeId = :planActRecId
                                                        	and
                                                    				AS_Training_Plan_Record_ID__c IN :summTPMap.keySet()
	                                                        	and
                                                            CPD_Planner__c IN :allCPDIdSet
                                                        )
                                                        for update
                                                        ]) {
                    	String tPlanStr = (learn.AS_Training_Plan_Record_ID__c!=null)?String.valueOf(Id.valueOf(learn.AS_Training_Plan_Record_ID__c)).toLowerCase().trim():'';
                    	String cpdStr = (learn.CPD_Planner__c!=null)?String.valueOf(learn.CPD_Planner__c).toLowerCase().trim():'';
                     	String theKeyStr = tPlanStr + cpdStr;
                     	System.debug(' first theKeyStr : '+ theKeyStr);
                     		
                     	if( (learn.ASTraining_Plan_Assignment__c != null && allTrainPlanAssMap.containsKey(learn.ASTraining_Plan_Assignment__c)) ) {
                        allFoundLearSumm.put(learn.ASTraining_Plan_Assignment__c,true);
                        
                        Training_Plan_Assignment__c newAssign = allTrainPlanAssMap.get(learn.ASTraining_Plan_Assignment__c);
                        
                        AsCPD_Learning_Summary__c indiUpdatedLearnSumm = new AsCPD_Learning_Summary__c();
                     //   indiUpdatedLearnSumm.AsSummary_Plan__c = (newAssign.Status__c == 'Completed')?true:false; // code commented as per juan's request in ticket (#PSA-338)
                        indiUpdatedLearnSumm.AS_Planned_Status_Validation__c = false;
                        indiUpdatedLearnSumm.ASTraining_Plan_Assignment__c = newAssign.Id;
                        indiUpdatedLearnSumm.ASTraining_Plan_Name__c = newAssign.Training_Plan__r.Name; 
                        indiUpdatedLearnSumm.CPD_Accreditation_Number__c = newAssign.Training_Plan__r.AS_CPD_Accreditation_Number__c;
                        indiUpdatedLearnSumm.End_Date__c = newAssign.Completed_On__c;
                        indiUpdatedLearnSumm.Description__c = newAssign.Training_Plan__r.Description__c;
                        indiUpdatedLearnSumm.Id = learn.Id;
                        indiUpdatedLearnSumm.Provider__c = newAssign.Training_Plan__r.Provider__c;
                        indiUpdatedLearnSumm.RecordTypeId = trainPlanRecId;
                        indiUpdatedLearnSumm.Status__c = (newAssign.Status__c == 'Completed')?'Complete':newAssign.Status__c;
                        
                        if(newAssign.Status__c == 'Completed' || newAssign.Status__c == 'Complete') {
                        	if(newAssign.AS_Group_2_CPD_Achieved__c != null && newAssign.AS_Group_2_CPD_Achieved__c != 0) {
                        		indiUpdatedLearnSumm.Group_2_CPD__c = newAssign.AS_Group_2_CPD_Achieved__c;
                        		indiUpdatedLearnSumm.Group_1_CPD__c = 0;
                        	} else {
                        		indiUpdatedLearnSumm.Group_1_CPD__c = newAssign.AS_Group_1_CPD_Achieved__c;
                        		indiUpdatedLearnSumm.Group_2_CPD__c = 0;
                        	}
                        } else {
                        	indiUpdatedLearnSumm.Group_1_CPD__c = newAssign.AS_Group_1_CPD_Achieved__c;
                        	indiUpdatedLearnSumm.Group_2_CPD__c = newAssign.AS_Group_2_CPD_Achieved__c;
                        }
                        
                        indiUpdatedLearnSumm.Start_Date__c = Date.valueOf( newAssign.CreatedDate );
                        indiUpdatedLearnSumm.Type__c = newAssign.Training_Plan__r.AS_Training_Plan_Type__c; 
                        indiUpdatedLearnSumm.AS_Type__c = newAssign.Training_Plan__r.AS_Training_Plan_Type__c;
                        indiUpdatedLearnSumm.AS_Topics__c = newAssign.Training_Plan__r.AsCategory__c;  
                        indiUpdatedLearnSumm.X2016_Competencies__c = newAssign.Training_Plan__r.AS_2016_Competencies__c;
                        indiUpdatedLearnSumm.AS_Training_Plan_Record_ID__c = String.valueOf(newAssign.Training_Plan__c);
                        
                        // added for ticket (#PSA-279)
                        if(allPlannerMap.containsKey(newAssign.User__c)) {
                        	indiUpdatedLearnSumm.CPD_Planner__c = allPlannerMap.get(newAssign.User__c).Id; 
                        }
                        
                        /* // code below is commented for (#PSAS-110)
                        // code block below is for ticket (#PSA-299)
                     		if(learn.Status__c == 'Complete') {
                     			continue;
                     		} else {
                        	tobeUpdatedLearnSummList.add(indiUpdatedLearnSumm); // the record will not be udpated if its current status is completed
                     		}
                     		*/
                     		tobeUpdatedLearnSummList.add(indiUpdatedLearnSumm);
                     		
                     	} else if(tPlanCpdAssignList.containsKey(theKeyStr)) {
                     		if(learn.AS_Training_Plan_Record_ID__c != null && learn.CPD_Planner__c != null) {
             			 			Training_Plan_Assignment__c newAssign = tPlanCpdAssignList.get(theKeyStr);
                        
	                        AsCPD_Learning_Summary__c indiUpdatedLearnSumm = new AsCPD_Learning_Summary__c();
	                     //   indiUpdatedLearnSumm.AsSummary_Plan__c = (newAssign.Status__c == 'Completed')?true:false; // code commented as per juan's request in ticket (#PSA-338)
	                        indiUpdatedLearnSumm.AS_Planned_Status_Validation__c = false;
	                        indiUpdatedLearnSumm.ASTraining_Plan_Assignment__c = newAssign.Id;
	                        indiUpdatedLearnSumm.ASTraining_Plan_Name__c = newAssign.Training_Plan__r.Name; 
	                        indiUpdatedLearnSumm.CPD_Accreditation_Number__c = newAssign.Training_Plan__r.AS_CPD_Accreditation_Number__c;
	                        indiUpdatedLearnSumm.End_Date__c = newAssign.Completed_On__c;
	                        indiUpdatedLearnSumm.Description__c = newAssign.Training_Plan__r.Description__c;
	                        
	                        
	                        if(newAssign.Status__c == 'Completed' || newAssign.Status__c == 'Complete') {
	                        	if(newAssign.AS_Group_2_CPD_Achieved__c != null && newAssign.AS_Group_2_CPD_Achieved__c != 0) {
	                        		indiUpdatedLearnSumm.Group_2_CPD__c = newAssign.AS_Group_2_CPD_Achieved__c;
	                        		indiUpdatedLearnSumm.Group_1_CPD__c = 0;
	                        	} else {
	                        		indiUpdatedLearnSumm.Group_1_CPD__c = newAssign.AS_Group_1_CPD_Achieved__c;
	                        		indiUpdatedLearnSumm.Group_2_CPD__c = 0;
	                        	}
	                        } else {
	                        	indiUpdatedLearnSumm.Group_1_CPD__c = newAssign.AS_Group_1_CPD_Achieved__c;
	                        	indiUpdatedLearnSumm.Group_2_CPD__c = newAssign.AS_Group_2_CPD_Achieved__c;
	                        }
	                        
	                        indiUpdatedLearnSumm.Id = learn.Id;
	                        indiUpdatedLearnSumm.Provider__c = newAssign.Training_Plan__r.Provider__c;
	                        indiUpdatedLearnSumm.RecordTypeId = trainPlanRecId;
	                        indiUpdatedLearnSumm.Status__c = (newAssign.Status__c == 'Completed')?'Complete':newAssign.Status__c;
	                        indiUpdatedLearnSumm.Start_Date__c = Date.valueOf( newAssign.CreatedDate );
	                        indiUpdatedLearnSumm.Type__c = newAssign.Training_Plan__r.AS_Training_Plan_Type__c; 
	                        indiUpdatedLearnSumm.AS_Type__c = newAssign.Training_Plan__r.AS_Training_Plan_Type__c;
	                        indiUpdatedLearnSumm.AS_Topics__c = newAssign.Training_Plan__r.AsCategory__c;  
	                        indiUpdatedLearnSumm.X2016_Competencies__c = newAssign.Training_Plan__r.AS_2016_Competencies__c;
	                        indiUpdatedLearnSumm.AS_Training_Plan_Record_ID__c = String.valueOf(newAssign.Training_Plan__c);
	                        
	                        // added for ticket (#PSA-279)
	                        if(allPlannerMap.containsKey(newAssign.User__c)) {
	                        	indiUpdatedLearnSumm.CPD_Planner__c = allPlannerMap.get(newAssign.User__c).Id; 
	                        }
	                        
	                        /* // code below is commented for (#PSAS-110)
	                        // code block below is for ticket (#PSA-299)
	                     		if(learn.Status__c == 'Complete') {
	                     			continue;
	                     		} else {
	                        	tempLearnSummList.put(theKeyStr,indiUpdatedLearnSumm);
	                     		}
	                     		*/
	                     		tempLearnSummList.put(theKeyStr,indiUpdatedLearnSumm); 
                     		}
                     	}
                }
                System.debug('allFoundLearSumm : '+ allFoundLearSumm);
                System.debug('tobeUpdatedLearnSummList : '+ tobeUpdatedLearnSummList.size() + ' - '  + tobeUpdatedLearnSummList);
            
                if(tobeUpdatedLearnSummList.size() > 0) {
                    update tobeUpdatedLearnSummList;
                }
                
            }
            
            
            System.debug('allPlannerMap : '+ allPlannerMap);
            System.debug('tempLearnSummList : '+ tempLearnSummList);
            
            // use to create new learning summary assignment starts here
            List<AsCPD_Learning_Summary__c> allNewLearnSummList = new List<AsCPD_Learning_Summary__c>();
            List<AsCPD_Learning_Summary__c> tobeUpdatedLearnSumm2List = new List<AsCPD_Learning_Summary__c>();
            for(Id key : newAssignmentsMap.KeySet()) {
            	if(allTrainPlanAssMap.containsKey(key)) {
                Training_Plan_Assignment__c newAssign = newAssignmentsMap.get(key);
                
                Training_Plan_Assignment__c trainPlanVal = allTrainPlanAssMap.get(key);
                
                System.debug('trainPlanVal : ' + trainPlanVal);
                System.debug('newAssign.Id : ' + newAssign.Id);
                System.debug('trainPlanVal.Training_Plan__c : ' + trainPlanVal.Training_Plan__c);
                System.debug('newAssign.User__c : ' + newAssign.User__c);
                
                if( !allFoundLearSumm.containsKey(newAssign.Id) && trainPlanVal.Training_Plan__c != null && newAssign.User__c!= null && allPlannerMap.containsKey(newAssign.User__c) && allPlannerMap.get(newAssign.User__c)!=null) {  
                		String theKeyStr = String.valueOf(trainPlanVal.Training_Plan__c).toLowerCase().trim() + String.valueOf(allPlannerMap.get(newAssign.User__c).Id).toLowerCase().trim();
                		System.debug('theKeyStr : ' + theKeyStr);
                		if(tempLearnSummList.containsKey(theKeyStr)) {
                			tobeUpdatedLearnSumm2List.add(tempLearnSummList.get(theKeyStr));
                		} else {
                			if(activeTPlanMap.containsKey(trainPlanVal.Training_Plan__c)) {  // condition is added for (#PSA-301)
                			AsCPD_Learning_Summary__c indiNewLearnSumm = new AsCPD_Learning_Summary__c();
                        indiNewLearnSumm.Name = allTrainPlanAssMap.get(key).Training_Plan__r.Name;
                        indiNewLearnSumm.CPD_Planner__c = allPlannerMap.get(newAssign.User__c).Id;
                        indiNewLearnSumm.ASTraining_Plan_Assignment__c = key;
                        indiNewLearnSumm.AS_Planned_Status_Validation__c = false;
                        indiNewLearnSumm.Status__c = (newAssign.Status__c == 'Completed')?'Complete':newAssign.Status__c;
                        
                        
                        if(newAssign.Status__c == 'Completed' || newAssign.Status__c == 'Complete') {
                        	if(trainPlanVal.AS_Group_2_CPD_Achieved__c != null && trainPlanVal.AS_Group_2_CPD_Achieved__c != 0) {
                        		indiNewLearnSumm.Group_2_CPD__c = trainPlanVal.AS_Group_2_CPD_Achieved__c;
                        		indiNewLearnSumm.Group_1_CPD__c = 0;
                        	} else {
                        		indiNewLearnSumm.Group_1_CPD__c = trainPlanVal.AS_Group_1_CPD_Achieved__c;
                        		indiNewLearnSumm.Group_2_CPD__c = 0;
                        	}
                        } else {
                        	indiNewLearnSumm.Group_1_CPD__c = trainPlanVal.AS_Group_1_CPD_Achieved__c;
                        	indiNewLearnSumm.Group_2_CPD__c = trainPlanVal.AS_Group_2_CPD_Achieved__c;
                        }
	                        
                        indiNewLearnSumm.ASTraining_Plan_Name__c = trainPlanVal.Training_Plan__r.Name; 
                        indiNewLearnSumm.Type__c = trainPlanVal.Training_Plan__r.AS_Training_Plan_Type__c; 
                        indiNewLearnSumm.AS_Type__c = trainPlanVal.Training_Plan__r.AS_Training_Plan_Type__c;
                        indiNewLearnSumm.AS_Topics__c = trainPlanVal.Training_Plan__r.AsCategory__c; 
                        indiNewLearnSumm.Description__c = trainPlanVal.Training_Plan__r.Description__c;
                        indiNewLearnSumm.CPD_Accreditation_Number__c = trainPlanVal.Training_Plan__r.AS_CPD_Accreditation_Number__c;
                        indiNewLearnSumm.Provider__c = trainPlanVal.Training_Plan__r.Provider__c;
                        indiNewLearnSumm.X2016_Competencies__c = trainPlanVal.Training_Plan__r.AS_2016_Competencies__c;
                        indiNewLearnSumm.Start_Date__c = Date.valueOf( trainPlanVal.CreatedDate );
                        indiNewLearnSumm.End_Date__c = trainPlanVal.Completed_On__c;
                        indiNewLearnSumm.RecordTypeId = trainPlanRecId;
                        indiNewLearnSumm.AS_Training_Plan_Record_ID__c = String.valueOf(newAssign.Training_Plan__c);
                        allNewLearnSummList.add(indiNewLearnSumm);
                			}
                		}
                } else {
                	continue;
                }
            	} else {
            		continue;
            	}
            }
            
            System.debug('allNewLearnSummList : ' + allNewLearnSummList.size() + ' - ' + allNewLearnSummList);
            if(allNewLearnSummList.size() > 0) {
                insert allNewLearnSummList;
            }
            System.debug('tobeUpdatedLearnSumm2List : ' + tobeUpdatedLearnSumm2List.size() + ' - ' + tobeUpdatedLearnSumm2List);
            if(tobeUpdatedLearnSumm2List.size() > 0) {
                update tobeUpdatedLearnSumm2List;
            }
            // use to create new learning summary assignment ends here
            
            // for recursion purpose
            if(tobeUpdatedLearnSummList.size() > 0 || tobeUpdatedLearnSumm2List.size() > 0 || allNewLearnSummList.size() > 0) {
                TrainingPlanAssignmentHelper.createLearnSumEnroll = false; 
            } else {
                TrainingPlanAssignmentHelper.createLearnSumEnroll = true; 
            }
            if(newAssignmentsMap.size() == 200) {
                TrainingPlanAssignmentHelper.createLearnSumEnroll = true; 
            }
        } /*else {
        	System.debug('TrainingPlanAssignmentHelper : recursion');
        } */
    }

    //This methods deletes all training plan section assignments associated to the specified plan assignments
    public static void deleteAssociatedLearningAssignments(List<Training_Plan_Assignment__c> assignments){

        //Set a static attribute in the assignment helper with the list of the deleted training plan asssignment ids
        //This will be used to ignore progress recalculation
        Set<Id> deletedTrainingPlanAssignmentIds = new Set<Id>();
        Map<Id,Set<Id>> mapTPlanUserIds = new Map<Id,Set<Id>>();

        for(Training_Plan_Assignment__c tpa : assignments){
            if(tpa.Training_Plan__c != null){
                deletedTrainingPlanAssignmentIds.add(tpa.Id);
                if(!mapTPlanUserIds.containsKey(tpa.Training_Plan__c)){
                    mapTPlanUserIds.put(tpa.Training_Plan__c, new Set<Id>());
                }
                mapTPlanUserIds.get(tpa.Training_Plan__c).add(tpa.User__c);
            }
        }

        TrainingPlanSectionAssignmentHelper.deletedTrainingPlanAssignments = deletedTrainingPlanAssignmentIds;

        TrainingPlanAssignmentHelper.WithoutSharingOps wosHelper = new TrainingPlanAssignmentHelper.WithoutSharingOps();
        wosHelper.deleteAssociatedLearningAssignmentsWOS(assignments,mapTPlanUserIds);

    }

    //This method evaluates completed plan assignments and updates related AA records status
    private static void processAchievementRulesForAssignments(Map<Id,Training_Plan_Assignment__c> oldAssignmentsMap,Map<Id,Training_Plan_Assignment__c> newAssignmentsMap){

        TrainingPlanAssignmentHelper.WithoutSharingOps wosHelper = new TrainingPlanAssignmentHelper.WithoutSharingOps();

        //Auxiliary collections
        Set<Id> trainingPlanIds = new Set<Id>();
        Set<Id> trainingPlanAchievementIds = new Set<Id>();
        List<Achievement_Assignment__c> achievementAssignmentsToUpdate = new List<Achievement_Assignment__c>();

        List<Training_Plan_Assignment__c> completedAssignments = new List<Training_Plan_Assignment__c>();
        Map<Id,List<Training_Plan_Assignment__c>> completedAssignmentsPerUser = new Map<Id,List<Training_Plan_Assignment__c>>();

        //Get plan ids for assignments and separate completed assignments
        for(Training_Plan_Assignment__c tpa : newAssignmentsMap.values()){

            Training_Plan_Assignment__c oldTpa = oldAssignmentsMap.get(tpa.Id);

            if(tpa.User__c != null && tpa.Training_Plan__c != null){
                if(oldTpa.Status__c != LMSConstants.ASSIGNMENT_STATUS_COMPLETED && tpa.Status__c == LMSConstants.ASSIGNMENT_STATUS_COMPLETED){

                    if(!completedAssignmentsPerUser.containsKey(tpa.User__c)){
                        completedAssignmentsPerUser.put(tpa.User__c,new List<Training_Plan_Assignment__c>());
                    }

                    completedAssignmentsPerUser.get(tpa.User__c).add(tpa);
                    trainingPlanIds.add(tpa.Training_Plan__c);
                    completedAssignments.add(tpa);
                }
            }
        }

        //Continue only if there are completed assignments
        if(completedAssignments.size()>0){

            //Get training plan achievements for the plan
            Map<Id,List<Training_Plan_Achievement__c>> planAchievementsMap = wosHelper.getTrainingPlanAchievementsWOS(trainingPlanIds);

            for(Id tpId : planAchievementsMap.keySet()){
                for(Training_Plan_Achievement__c tpa : planAchievementsMap.get(tpId)){
                    trainingPlanAchievementIds.add(tpa.Id);
                }
            }

            //We have achievements related to the completed plans, continue analysis
            if(trainingPlanAchievementIds != null && trainingPlanAchievementIds.size()>0){

                //Get AA records for the users + training plan achievements
                Map<String,List<Achievement_Assignment__c>> userPlanAchievementAssignments = LMSService.getAchievementAssignmentforTrainingPlanAchievements(completedAssignmentsPerUser.keySet(),trainingPlanAchievementIds);

                //Iterate over completed assignments and update corresponding achievement assignment records
                for(Training_Plan_Assignment__c tpa : completedAssignments){
                    List<Achievement_Assignment__c> aas = userPlanAchievementAssignments.get(tpa.User__c+'_'+tpa.Training_Plan__c);
                    if(aas != null){
                        for(Achievement_Assignment__c aa : aas){
                            if(aa.Achievement__r.Override_Completed_Status__c != null){
                                aa.Status__c = aa.Achievement__r.Override_Completed_Status__c;
                            }else{
                                aa.Status__c = LMSConstants.AA_ACQUIRED_STATUS;
                            }
                            achievementAssignmentsToUpdate.add(aa);
                        }
                    }
                }
            }

            //Update AA records
            if(achievementAssignmentsToUpdate.size()>0){
                wosHelper.updateAchievementAssignmentsWOS(achievementAssignmentsToUpdate);
            }

            if(!LMSSettings.getDisableTrackAchievements()){
                //Check for training track progress for the completed assignments
                processAchievementRulesForTracks(completedAssignmentsPerUser.keySet(),trainingPlanIds);
            }

        }

    }

    @TestVisible
    private static void postChatterNotifications(List<Training_Plan_Assignment__c> assignments){

        Map<String,Set<Id>> mapTrainingPlanAssignments = new Map<String,Set<Id>>();
        Map<String,Training_Plan__c> mapTrainingPlanInfo = new Map<String,Training_Plan__c>();
        Map<Id,String> communityUserMap = new Map<Id,String>();
        Map<Id,String> communityNamesMap = new Map<Id,String>();
        Map<String,String> sitePrefixDomainMap = new Map<String,String>();

        //Collect all training plan assignments
        for(Training_Plan_Assignment__c tpa : assignments){

            if(tpa.Training_Plan__c != null){

                if(!mapTrainingPlanAssignments.containsKey(tpa.Training_Plan__c)){
                    mapTrainingPlanAssignments.put(tpa.Training_Plan__c,new Set<Id>());
                }

                mapTrainingPlanAssignments.get(tpa.Training_Plan__c).add(tpa.User__c);
                //Collect related community ids
                if(tpa.Community_Id__c != null){
                    communityUserMap.put(tpa.User__c , tpa.Community_Id__c);
                }
            }

        }

        TrainingPlanAssignmentHelper.WithoutSharingOps wosHelper = new TrainingPlanAssignmentHelper.WithoutSharingOps();

        //Fetch additional community information
        if(communityUserMap.size()>0){
            for(SObject r : wosHelper.getCommunitiesInfoWOS(communityUserMap.values())){
                String communityURLPathPrefix = r.get('UrlPathPrefix')!=null?(String)r.get('UrlPathPrefix'):'';
                communityNamesMap.put(r.Id, communityURLPathPrefix);
            }
        }

        //Fetch site information for the referenced communiy url path prefixes
        if(communityNamesMap.size()>0){
            for(SObject s : wosHelper.getSiteInfoWOS()){
                String urlPrefix = s.get('UrlPathPrefix')!=null?(String)s.get('UrlPathPrefix'):'';
                sitePrefixDomainMap.put(urlPrefix, (String)s.get('Subdomain'));
            }
        }

        if(mapTrainingPlanAssignments.size()>0){
            for(Training_Plan__c tp : wosHelper.getTrainingPlansInfoWOS(mapTrainingPlanAssignments.keySet())){
                mapTrainingPlanInfo.put(tp.Id,tp);
            }
        }

        //Create chatter notification for each user + training plan combination
        for(String tplanId : mapTrainingPlanAssignments.keySet()){
            Training_Plan__c tPlanInfo = mapTrainingPlanInfo.get(tplanId);

            if(tPlanInfo != null && tPlanInfo.Chatter_Notifications_Enabled__c){

                Map<String,List<ConnectApi.BatchInput>> feedItemsMap = new Map<String,List<ConnectApi.BatchInput>>();
                for(Id uId : mapTrainingPlanAssignments.get(tplanId)){

                    try{
                        //Create message body input
                        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
                        //initalize message body segments
                        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                        //Create a text segment
                        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                        textSegment.text = System.Label.ALMS_Chatter_Notification_Greeting+' ';

                        if(tPlanInfo.Custom_Notification_Message__c == null){
                            messageInput.messageSegments.add(textSegment);
                        }

                        //Create a mention segment
                        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                        mentionSegment.id = uId;
                        messageInput.messageSegments.add(mentionSegment);

                        //Create a text segment
                        textSegment = new ConnectApi.TextSegmentInput();

                        if(tPlanInfo.Custom_Notification_Message__c != null){
                            textSegment.text = '\n\n'+tPlanInfo.Custom_Notification_Message__c;
                        }else{
                            textSegment.text = ' '+System.Label.ALMS_Chatter_Notification_Message_1+' : '+tPlanInfo.Name+'. '+System.Label.ALMS_Chatter_Notification_Message_2+' : ';
                        }
                        messageInput.messageSegments.add(textSegment);

                        ConnectApi.LinkCapabilityInput linkSegment = new ConnectApi.LinkCapabilityInput();
                        String sfUrl=URL.getSalesforceBaseUrl().getHost();
                        PageReference tPlanDetailPageRef = Page.TrainingPlanDetail;

                        String tplanRefURL = tPlanDetailPageRef.getUrl();

                        Id userCommunityId = communityUserMap.get(uId);

                        if(userCommunityId != null){
                            String communityURLPathPrefix = communityNamesMap.get(userCommunityId);
                            tplanRefURL = LMSUtils.updateURLCommunityPath(tplanRefURL,communityURLPathPrefix);
                            //Override sfURL with subdomain for the associated site
                            String siteSubdomain = sitePrefixDomainMap.get(communityURLPathPrefix);
                            if(siteSubdomain != null){
                                //Fix for dev edition url path
                                if(siteSubdomain.endsWith('developer-edition')){
                                    siteSubdomain += '.'+LMSUtils.getCurrentInstance();
                                }
                                sfUrl = siteSubdomain+'.force.com';
                            }
                        }

                        String tPlanURL = 'https://'+sfUrl+''+tplanRefURL+'?id='+tplanId;
                        linkSegment.url = tPlanURL;
                        linkSegment.urlName = tPlanInfo.Name;

                        //Finally create the feed item
                        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                        input.body = messageInput;
                        input.feedElementType = ConnectApi.FeedElementType.FeedItem;
                        ConnectApi.FeedElementCapabilitiesInput linkCapability = new ConnectApi.FeedElementCapabilitiesInput();
                        linkCapability.link = linkSegment;
                        input.capabilities = linkCapability;
                        input.subjectId = uId;

                        if(!feedItemsMap.containsKey(userCommunityId)){
                          feedItemsMap.put(userCommunityId, new List<ConnectApi.BatchInput>());
                        }

                        feedItemsMap.get(userCommunityId).add(new ConnectApi.BatchInput(input));

                    }catch(Exception e){
                        LMSUtils.logException(e,'TrainingPlanAssignmentHelper');
                    }

                }

                //Insert feed items in batch
                for(String communityIdKey : feedItemsMap.keySet()){
                    List<ConnectApi.BatchInput> feedItems = feedItemsMap.get(communityIdKey);
                    if(feedItems.size()>0){
                        if(!Test.isRunningTest()) List<ConnectApi.BatchResult> results = ConnectApi.ChatterFeeds.postFeedElementBatch(communityIdKey,feedItems);
                    }
                }

            }
        }

    }

    private static void processAchievementRulesForTracks(Set<Id> uIds, Set<Id> tPlanIds){

        try{

            //Extract training tracks from the completed training plan ids
            TrainingPlanAssignmentHelper.WithoutSharingOps wosHelper = new TrainingPlanAssignmentHelper.WithoutSharingOps();
            Set<Id> trackIds = wosHelper.getAssociatedTrainingTracksWOS(tPlanIds);

            //Update progress for all the users in the associated tracks
            if(!System.isFuture() && !System.isBatch()){
                calculateTrainingTrackProgressInFuture(uIds,trackIds);
            }else{
                calculateTrainingTrackProgress(uIds,trackIds);
            }

        }catch(Exception e){
            LMSUtils.logException(e,'TrainingPlanAssignmentHelper');
        }

    }

    @future
    private static void calculateTrainingTrackProgressInFuture(Set<Id> uIds, Set<Id> trackIds){
        calculateTrainingTrackProgress(uIds,trackIds);
    }

    private static void calculateTrainingTrackProgress(Set<Id> uIds, Set<Id> trackIds){
        TrainingPlanAssignmentHelper.WithoutSharingOps wosHelper = new TrainingPlanAssignmentHelper.WithoutSharingOps();
        wosHelper.calculateTrainingTrackProgressWOS(uIds,trackIds);
    }

    private without sharing class WithoutSharingOps{

        // We need to run this without sharing to make sure we clean related assignment record even if the records are not available to the running user
        public void deleteAssociatedLearningAssignmentsWOS(List<Training_Plan_Assignment__c> assignments,Map<Id,Set<Id>> mapTPlanUserIds){

            //Fetch related training plan section assignments
            List<Training_Plan_Section_Assignment__c> tpsas = [select id
                                                                        from Training_Plan_Section_Assignment__c
                                                                        where Training_Plan_Assignment__c in :assignments];


            //Force a cascade deletion of the associated learning assignments.
            //CRUD/FLS enforcement is bypassed here to make sure all associated section assignments are cleared otherwise we can have corrupted data
            if(tpsas.size() > 0){
                delete tpsas;
            }

            //Delete existing shares for the training plan
            List<Training_Plan__Share> sharesToDelete = new List<Training_Plan__Share>();
            for(Id tPlanKey : mapTPlanUserIds.keySet()){
                Set<Id> uIds = mapTPlanUserIds.get(tPlanKey);
                List<Training_Plan__Share> tpshrs = [select id
                                                            from Training_Plan__Share
                                                            where ParentId = :tPlanKey
                                                            and UserOrGroupId in :uIds
                                                            and RowCause != 'Owner'];
                sharesToDelete.addAll(tpshrs);
            }

            //CRUD/FLS enforcement is bypassed here to make sure all associated tplan shares are cleared otherwise we can have corrupted data
            if(sharesToDelete.size()>0){
                delete sharesToDelete;
            }

        }

        // We need to update Achievement Assignments in a without sharing since records will be shared with public read only access
        public void updateAchievementAssignmentsWOS(List<Achievement_Assignment__c> achievementAssignmentsToUpdate){
            update achievementAssignmentsToUpdate;
        }

        // We need to calculate progress for training tracks in a without sharing context, as the executing (running) user may be a user different from the record owner
        // And this running user, may not have access to see all of the training tracks in the system
        public void calculateTrainingTrackProgressWOS(Set<Id> uIds, Set<Id> trackIds){

            if(uIds.size() > 0 && trackIds.size() > 0){

                //Determine if we should link the achievement assignment to a network id
                Id currentNetworkId = null;
                if(uIds.size() == 1 && uIds.contains(UserInfo.getUserId())){
                    currentNetworkId = LMSUtils.getCurrentNetworkId();
                }

                //Get track achievements
                Map<Id,String> trackAchievementMap = new Map<Id,String>();
                Map<Id,String> completedTrackAchievementMap = new Map<Id,String>();
                Map<Id,Set<Id>> trackPlansMap = new Map<Id,Set<Id>>();
                Map<Id,Set<Id>> userCompletedPlansMap = new Map<Id,Set<Id>>();
                Set<Id> tplansToBeChecked = new Set<Id>();

                //Get achievement information for the specified tracks, only if they are active
                for(Training_Track__c tt : [select id
                                                ,Achievement__c
                                                from Training_Track__c
                                                where id in :trackIds
                                                and Status__c = :LMSConstants.TTRACK_ACTIVE_STATUS]){
                    if(tt.Achievement__c != null){
                        trackAchievementMap.put(tt.Id,tt.Achievement__c);
                    }
                }

                //Continue only if the related active tracks have an achievement
                if(trackAchievementMap.size() == 0){
                    return;
                }

                //Get training plan information from related track items
                for(Training_Track_Level_Item__c tti : [select id
                                                        ,Training_Plan__c
                                                        ,Training_Track_Level__r.Training_Track__c
                                                        from Training_Track_Level_Item__c
                                                        where Training_Track_Level__r.Training_Track__c in :trackAchievementMap.keySet()]){
                    if(tti.Training_Plan__c != null){
                        tplansToBeChecked.add(tti.Training_Plan__c);

                        if(!trackPlansMap.containsKey(tti.Training_Track_Level__r.Training_Track__c)){
                            trackPlansMap.put(tti.Training_Track_Level__r.Training_Track__c, new Set<Id>());
                        }

                        trackPlansMap.get(tti.Training_Track_Level__r.Training_Track__c).add(tti.Training_Plan__c);
                    }

                }

                //Continue only if there are items to be checked
                if(tplansToBeChecked.size() == 0){
                    return;
                }

                //Get all the training plan assignments for the specified users
                for(Training_Plan_Assignment__c tpa : [select id
                                                            ,User__c
                                                            ,Status__c
                                                            ,Training_Plan__c
                                                            from Training_Plan_Assignment__c
                                                            where User__c in :uIds
                                                            and Training_Plan__c in :tplansToBeChecked
                                                            and Status__c = :LMSConstants.TPLAN_STATUS_COMPLETED
                                                            order by User__c]){

                    if(!userCompletedPlansMap.containsKey(tpa.User__c)){
                        userCompletedPlansMap.put(tpa.User__c, new Set<Id>());
                    }

                    userCompletedPlansMap.get(tpa.User__c).add(tpa.Training_Plan__c);
                }


                //Iterate over each of the training tracks and check if the user has completed all associated training plans
                Map<Id,Set<Id>> userCompletedTrackMap = new Map<Id,Set<Id>>();

                for(Id trackId : trackPlansMap.keySet()){

                    Set<Id> trackPlanIds = trackPlansMap.get(trackId);

                    if(trackPlanIds != null && trackPlanIds.size()>0){
                        for(Id uid : uIds){
                            Set<Id> userCompletedPlanIds = userCompletedPlansMap.get(uid);

                            if(userCompletedPlanIds != null && userCompletedPlanIds.containsAll(trackPlanIds)){
                                //This user has completed all of the items in this track
                                if(!userCompletedTrackMap.containsKey(uid)){
                                    userCompletedTrackMap.put(uid,new Set<Id>());
                                }

                                userCompletedTrackMap.get(uid).add(trackId);

                                if(!completedTrackAchievementMap.containsKey(trackId)){
                                    completedTrackAchievementMap.put(trackId,trackAchievementMap.get(trackId));
                                }
                            }


                        }

                    }

                }

                // Continue if we found users that have completed tracks
                if(userCompletedTrackMap.size()>0){

                    Map<Id,Set<Id>> userAcquiredAchievementsMap = new Map<Id,Set<Id>>();

                    //Check existing achievement assignments for the current users, to make sure we dont creatre dups
                    for(Achievement_Assignment__c aa : [select id
                                                            ,Achievement__c
                                                            ,User__c
                                                            from Achievement_Assignment__c
                                                            where User__c in :userCompletedTrackMap.keySet()
                                                            and Status__c = :LMSConstants.AA_ACQUIRED_STATUS
                                                            and Achievement__c in :completedTrackAchievementMap.values()]){

                        if(!userAcquiredAchievementsMap.containsKey(aa.User__c)){
                            userAcquiredAchievementsMap.put(aa.User__c, new Set<Id>());
                        }
                        userAcquiredAchievementsMap.get(aa.User__c).add(aa.Achievement__c);
                    }

                    Map<Id,User> userInfoMap = LMSService.getUserMap(userCompletedTrackMap.keySet(), false);
                    List<Achievement_Assignment__c> aaInsert = new List<Achievement_Assignment__c>();

                    //Create achievement assignments if they don't exist already
                    for(Id uid : userCompletedTrackMap.keySet()){

                        Set<Id> userAcquiredAchievements = userAcquiredAchievementsMap.get(uid);
                        Set<Id> userCompTracks = userCompletedTrackMap.get(uid);
                        User uInfo = userInfoMap.get(uid);

                        for(Id tid : userCompTracks){

                            String trackAchievementId = completedTrackAchievementMap.get(tid);

                            if(userAcquiredAchievements == null || !userAcquiredAchievements.contains(trackAchievementId)){
                                Achievement_Assignment__c aa = new Achievement_Assignment__c();
                                aa.User__c = uid;
                                aa.Contact__c = uInfo.ContactId;
                                aa.OwnerId = uid;
                                aa.Achievement__c = trackAchievementId;
                                aa.Status__c = LMSConstants.AA_ACQUIRED_STATUS;
                                aa.Training_Track__c = tid;
                                aaInsert.add(aa);

                            }

                        }

                    }

                    if(aaInsert.size()>0){
                        //By-pass CRUD/FLS checks as the invoking user doesn't have access to create achievement assignments
                        insert aaInsert;
                    }

                }

            }

        }

        // We want to make sure the running user has access to the training plan records even if the training plan hasn't been shared with the user
        public Map<Id,List<Training_Plan_Achievement__c>> getTrainingPlanAchievementsWOS(Set<Id> trainingPlanIds){

            Map<Id,List<Training_Plan_Achievement__c>> results = new Map<Id,List<Training_Plan_Achievement__c>>();

            //Create local scope vars for Dynamic SOQL binding
            Set<Id> tplIds = trainingPlanIds;

            List<String> listSOQLFields = new List<String>{
                'Id'
                ,'Name'
                ,'Training_Plan__c'
                ,'Training_Plan_Section__c'
                ,'Type__c'
                ,'Main_Achievement__c'
                ,'Achievement__c'
                ,'Achievement__r.Id'
                ,'Achievement__r.Acquired_Image__c'
                ,'Achievement__r.Eligible_Image__c'
                ,'Achievement__r.Work_Badge_Id__c'
                ,'Achievement__r.Work_Badge_Image_URL__c'
            };

            String soqlQuery = 'select '+String.join(listSOQLFields,',')+' from Training_Plan_Achievement__c where Training_Plan__c in :tplIds and Type__c = \'Plan\'';
            soqlQuery += ' order by CreatedDate desc';

            List<Training_Plan_Achievement__c> tplanAchievements = (List<Training_Plan_Achievement__c>)Database.query(soqlQuery);
            for(Training_Plan_Achievement__c tpa : tplanAchievements){
                if(!results.containsKey(tpa.Training_Plan__c)){
                    results.put(tpa.Training_Plan__c, new List<Training_Plan_Achievement__c>());
                }
                results.get(tpa.Training_Plan__c).add(tpa);
            }

            return results;

        }

        /*
        * We're running this query without sharing due to our data/security model design
        * This method will be called by a trigger running in a with sharing context, in some cases the running user
        * Will not have access to the all of the training tracks for the affected user, for example, an approver is updating an assignment status
        */
        //Get all the training track ids that have the specified training plan as part of the items
        public Set<Id> getAssociatedTrainingTracksWOS(Set<Id> tplanIds){

            Set<Id> result = new Set<Id>();
            for(Training_Track_Level_Item__c ti : [select Training_Track_Level__r.Training_Track__c
                                                from Training_Track_Level_Item__c
                                                where Training_Plan__c in :tplanIds]){
                result.add(ti.Training_Track_Level__r.Training_Track__c);

            }

            return result;

        }

        public List<SObject> getCommunitiesInfoWOS(List<String> communityIds){
            String soqlQuery = 'select Id,UrlPathPrefix from Network where Id in :communityIds';
            return Database.query(soqlQuery);
        }

        public List<SObject> getSiteInfoWOS(){
            String soqlQuery = 'select Id, UrlPathPrefix, Subdomain from Site where Status = \'Active\' and SiteType = \'ChatterNetwork\'';
            return Database.query(soqlQuery);
        }

        public List<Training_Plan__c> getTrainingPlansInfoWOS(Set<String> tplanIds){
            List<Training_Plan__c> results = [select id
                                                    ,Name
                                                    ,Chatter_Notifications_Enabled__c
                                                    ,Custom_Notification_Message__c
                                                    from Training_Plan__c
                                                    where id in :tplanIds];
            return results;
        }
    }


}