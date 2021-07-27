/*
*Author : John Hope
*Description : batch class that handles the processing of data from AP Integration object and check its corresponding LMS Course Enrollment
*Date Created : 3/21/2019
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : Ap Integration
*/

public class AsApIntegrationLMSBatch implements Database.batchable<SObject>,Database.Stateful{
    
	private String errorMessage = '';
	public Id apIntegrationId;
    public Set<Id> triggeredIntegIDs;
	public AsApIntegrationLMSBatch(Id theIntegrationId,Set<Id> triggered_IDs) {
		apIntegrationId = theIntegrationId;
        triggeredIntegIDs = triggered_IDs;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
        if(apIntegrationId != null){
            return Database.getQueryLocator('Select '+
																				'Id, ' +
																				'Name,' +
																				'As_User_ID__c,' +
																				'As_Training_Plan_ID__c, ' +
																				'As_Learning_ID__c, ' +
																				'As_Status__c ' +
																			 'from ' +
																			 	'As_AP_Integration__c ' +
																			 'where ' +
																			 	'Id = :apIntegrationId ' +
																			 'order by ' +
																			 	'createdDate asc'
																			);
        }else if(!triggeredIntegIDs.isEmpty()){
            return Database.getQueryLocator('Select '+
																				'Id, ' +
																				'Name,' +
																				'As_User_ID__c,' +
																				'As_Training_Plan_ID__c, ' +
																				'As_Learning_ID__c, ' +
																				'As_Status__c ' +
																			 'from ' +
																			 	'As_AP_Integration__c ' +
																			 'where ' +
																			 	'Id IN:triggeredIntegIDs ' +
																			 'order by ' +
																			 	'createdDate asc'
																			);
        }else {
			return Database.getQueryLocator('Select '+
																				'Id, ' +
																				'Name,' +
																				'As_User_ID__c,' +
																				'As_Training_Plan_ID__c, ' +
																				'As_Learning_ID__c, ' +
																				'As_Status__c ' +
																			 'from ' +
																			 	'As_AP_Integration__c ' +
																			 'where ' +
																			 	'As_Status__c=\'Not Processed\' ' +
																			 'order by ' +
																			 	'createdDate asc'
																			);
		}
	}

 	public void execute(Database.BatchableContext BC, List<As_AP_Integration__c> scope) {
 		try {
			System.debug('AsApIntegrationLMSBatch Scope : ' + scope);
			Set<Id> allLearningIdSet = new Set<Id>();
			Set<Id> allUserIdSet = new Set<Id>();
			for(As_AP_Integration__c ap : scope) {
				if(String.isNotBlank(ap.As_Learning_ID__c)) {
					try {
						allLearningIdSet.add(Id.valueOf(ap.As_Learning_ID__c));
					} catch (Exception e){
					}
				}
				
				if(String.isNotBlank(ap.As_User_ID__c)) {
					try {
						allUserIdSet.add(Id.valueOf(ap.As_User_ID__c));
					} catch (Exception e){
					}
				}
			}
			
			Map<Id,Id> allLearningLMSCourseMap = new Map<Id,Id>();
	    for(Learning__c lear : [Select Id,Name,LMS_Course__c from Learning__c where Id IN :allLearningIdSet]) {
	    	if(lear.LMS_Course__c != null) {
	    		allLearningLMSCourseMap.put(lear.Id,lear.LMS_Course__c);
	    	}
	    }
	    System.debug('allLearningLMSCourseMap : ' + allLearningLMSCourseMap);
	    
	    Map<Id,Id> allUserContactMap = new Map<Id,Id>();
	    for(User theUser : [SELECT ContactId,Id FROM User where Id IN :allUserIdSet]) {
				if(theUser.ContactId != null) {
					allUserContactMap.put(theUser.Id,theUser.ContactId);
				}
	    }
	    System.debug('allUserContactMap : ' + allUserContactMap);
	    
	    Map<Id,Id> allContactLMSUserMap = new Map<Id,Id>();
	    for(LMS_User__c lmsUser : [SELECT AS_Banner_Group_Contact__c,Id FROM LMS_User__c where AS_Banner_Group_Contact__c IN :allUserContactMap.values()]) {
				if(lmsUser.AS_Banner_Group_Contact__c != null) {
					allContactLMSUserMap.put(lmsUser.AS_Banner_Group_Contact__c,lmsUser.Id);
				}
	    }
	    System.debug('allContactLMSUserMap : ' + allContactLMSUserMap);
	    
	    Map<String,Id> allCourseEnrollmentMap = new Map<String,Id>();
	    for(LMS_Course_Enrolment__c enroll : [Select Id,LMS_Course__c,LMS_User__c from LMS_Course_Enrolment__c where LMS_User__c IN :allContactLMSUserMap.values() AND LMS_Course__c IN :allLearningLMSCourseMap.values()]) {
	    	if(enroll.LMS_User__c != null && enroll.LMS_Course__c != null) {
	    		 String lmsUser = String.valueOf(enroll.LMS_User__c).toLowerCase();
	    		 String lmsCourse = String.valueOf(enroll.LMS_Course__c).toLowerCase();
	    		 
	    		 allCourseEnrollmentMap.put(lmsUser+lmsCourse,enroll.Id);
	    	}
	    }
	    System.debug('allCourseEnrollmentMap : ' + allCourseEnrollmentMap);
	    
	    Map<Id,Id> allCourseEnrollLearAssMap = new Map<Id,Id>();
	    Map<Id,Id> allCourseEnrollTrainPlanAssMap = new Map<Id,Id>();
	    for(Learning_Assignment__c leaAss : [Select Id,LMS_Course_Enrolment__c,Training_Plan_Section_Assignment__r.Training_Plan_Assignment__c from Learning_Assignment__c where LMS_Course_Enrolment__c IN :allCourseEnrollmentMap.values()]) {
	    	if(leaAss.LMS_Course_Enrolment__c != null) {
	    		 allCourseEnrollLearAssMap.put(leaAss.LMS_Course_Enrolment__c, leaAss.Id);
	    		 allCourseEnrollTrainPlanAssMap.put(leaAss.LMS_Course_Enrolment__c, leaAss.Training_Plan_Section_Assignment__r.Training_Plan_Assignment__c);
	    	}
	    }
	    
	    List<As_AP_Integration__c> allTobeUpdatedApIntegrationList = new List<As_AP_Integration__c>();
	    List<LMS_Course_Enrolment__c> allTobeUpdatedLMSCourseEnrollList = new List<LMS_Course_Enrolment__c>();
	    Map<Id,As_AP_Integration__c> lmsCourseApIntegrationMap = new Map<Id,As_AP_Integration__c>();
	    for(As_AP_Integration__c ap : scope) {
	    	if(ap.As_User_ID__c == null || ap.As_Training_Plan_ID__c == null || ap.As_Learning_ID__c == null) {
	    		errorMessage += '\n\r'+ ap.Id + ' record, must have User, Training Plan and Learning.';
	    		
	    		As_AP_Integration__c tobeUpdateApIntegration = new As_AP_Integration__c();
					tobeUpdateApIntegration.Id = ap.Id;
					tobeUpdateApIntegration.As_Status__c ='Error';
					tobeUpdateApIntegration.As_Batch_Notes__c = 'This record, must have a User, Training Plan and Learning.';
					allTobeUpdatedApIntegrationList.add(tobeUpdateApIntegration);
	    		
	    	} else {
	    		// code below is to make sure that value given is a correct salesforce Id starts here
	    		Id finalUserId;
					Id finalTrainPlanId;
					Id finalLearnId;
	    		try {
						finalUserId = Id.valueOf(ap.As_User_ID__c);
					 	finalTrainPlanId = Id.valueOf(ap.As_Training_Plan_ID__c);
						finalLearnId = Id.valueOf(ap.As_Learning_ID__c);
	    		} catch (Exception ex) {
	    			errorMessage += '\n\r'+ ap.Id + ' record, must have a correct User, Training Plan and Learning.';
	    			
	    			As_AP_Integration__c tobeUpdateApIntegration = new As_AP_Integration__c();
						tobeUpdateApIntegration.Id = ap.Id;
						tobeUpdateApIntegration.As_Status__c ='Error';
						tobeUpdateApIntegration.As_Batch_Notes__c = 'This record, must have a correct User, Training Plan and Learning.';
						allTobeUpdatedApIntegrationList.add(tobeUpdateApIntegration);
						
	    			continue;
	    		}
	    		// code below is to make sure that value given is a correct salesforce Id ends here
	    		Id contactIdVal = allUserContactMap.get(finalUserId);
	    		
	    		Id lmsUserId = allContactLMSUserMap.get(contactIdVal);
	    		Id lmsCourseId = allLearningLMSCourseMap.get(finalLearnId);
	    		
	    		System.debug('lmsUserId : ' + lmsUserId + ' - ' + 'lmsCourseId : ' + lmsCourseId);
	    		
	    		if(lmsUserId != null && lmsCourseId != null) {
	    			String checkerStr = String.valueOf(lmsUserId).toLowerCase()+String.valueOf(lmsCourseId).toLowerCase();
	    			
	    			if(allCourseEnrollmentMap.containsKey(checkerStr)) {
	    				LMS_Course_Enrolment__c tobeUpdatedLMSCourseEnroll = new LMS_Course_Enrolment__c();
	    				tobeUpdatedLMSCourseEnroll.Id = allCourseEnrollmentMap.get(checkerStr);
	    				tobeUpdatedLMSCourseEnroll.AS_Completed_Status__c = true;
	    				tobeUpdatedLMSCourseEnroll.Completion_Status__c = 'Fail';
	    				tobeUpdatedLMSCourseEnroll.End_Date__c = date.today();
	    				allTobeUpdatedLMSCourseEnrollList.add(tobeUpdatedLMSCourseEnroll);
	    				
	    				As_AP_Integration__c tobeUpdateApIntegration = new As_AP_Integration__c();
	    				tobeUpdateApIntegration.Id = ap.Id;
	    				tobeUpdateApIntegration.As_Status__c ='Processed';
	    				tobeUpdateApIntegration.As_Learning_Assignment__c = allCourseEnrollLearAssMap.get(allCourseEnrollmentMap.get(checkerStr));
	    				tobeUpdateApIntegration.As_Training_Plan_Assignment__c = allCourseEnrollTrainPlanAssMap.get(allCourseEnrollmentMap.get(checkerStr));
	    				tobeUpdateApIntegration.As_Batch_Notes__c = 'Successfully Processed.';
	    				
	    				lmsCourseApIntegrationMap.put(allCourseEnrollmentMap.get(checkerStr),tobeUpdateApIntegration);
	    			}
	    		}
	    		
	    	}//end else
	    	
	    }//end for
	    
        TrainingPlanAssignmentHelper.createLearnSumEnroll = true; // this line is used to pass even in recursive process so that all activity summary will be updated every time the loop runs
	    //no need to update the LMS course Enrolment base on PSAMOPT-77
        /*if(allTobeUpdatedLMSCourseEnrollList.size() > 0) {
	    	System.debug('AsApIntegrationLMSBatch TrainingPlanAssignmentHelper here');
	    	TrainingPlanAssignmentHelper.createLearnSumEnroll = true; // this line is used to pass even in recursive process so that all activity summary will be updated every time the loop runs
	    	Database.SaveResult[] updateCourseEnrollResList = Database.update(allTobeUpdatedLMSCourseEnrollList, false);
	    	System.debug('updateCourseEnrollResList : ' + updateCourseEnrollResList);
				// Iterate through each returned result
				for (Database.SaveResult sr : updateCourseEnrollResList) {
			    if (sr.isSuccess() == true) {
			      As_AP_Integration__c tobeUpdateApIntegration = lmsCourseApIntegrationMap.get(sr.getId());
			      allTobeUpdatedApIntegrationList.add(tobeUpdateApIntegration);
			    }
				}
	    }
	    
	    if(allTobeUpdatedApIntegrationList.size() > 0) {
	    	Database.SaveResult[] updateApIntegrationResList = Database.update(allTobeUpdatedApIntegrationList, false);
	    }*/
            
        if(lmsCourseApIntegrationMap.size() > 0) {
	    	Database.SaveResult[] updateApIntegrationResList = Database.update(lmsCourseApIntegrationMap.values(), false);
	    }
    
 		}  catch (Exception ex) {
			System.debug('AN OVERALL ERROR OCCUR');
   		errorMessage +=  '\n\r' + ex.getMessage() + ' - Line :' + ex.getLineNumber();
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
		   	mail.setSubject('AP Integration Assignment Batch Process');  
		   	String theEmailBody = ''; 
	       
	       
	         
	      theEmailBody += 'This email is to notify you that your recent batch for AP Integration has encountered some error.\n\r'; 
	      theEmailBody += 'ERROR : \n';
	      theEmailBody += errorMessage + '\n\r';
	      
	      mail.setPlainTextBody(theEmailBody);  
	      
	   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   		}
    } catch(Exception e) {
    }
    
	}
	
	
}