/*
*Author : John Hope
*Description : This is a class that acts as a scheduler for running the training track and moodle syncing batch.
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*/
global class AS_batchTrainTrackAndMoodleScheduler implements Schedulable{
    global void execute(SchedulableContext SC){
   		
       
   		Map<Id,ApexClass> allApexClassMap = new Map<Id,ApexClass>([Select Id from ApexClass where Name IN ('AsTrainTrackAssignmentBatch','AsLMSUserToMoodleBatch','ASCourseEnrollmentToMoodleBatch')]);        
			Integer enqueuedJobs = [SELECT COUNT() FROM AsyncApexJob 
			                                    WHERE JobType='BatchApex' 
			                                    AND Status IN ('Processing','Preparing','Queued') 
			                                    AND ApexClassID IN :allApexClassMap.keySet()] ;
			            
			if(enqueuedJobs <= 0){
				System.debug(' no enqueuedJobs ');
				AsTrainTrackAssignmentBatch runBatch = new AsTrainTrackAssignmentBatch();
   			database.executeBatch(runBatch,1); // this is used to run only one record at a time
			}
			else{
			    System.debug(' has enqueuedJobs ');
			}
        
    }
}