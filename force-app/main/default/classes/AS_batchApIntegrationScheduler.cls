/*
*Author : John Hope
*Description : This is a class that acts as a scheduler for running the ap Integration batch.
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data :
*/
global class AS_batchApIntegrationScheduler implements Schedulable{
    global void execute(SchedulableContext SC){
        
       
        Map<Id,ApexClass> allApexClassMap = new Map<Id,ApexClass>([Select Id from ApexClass where Name IN ('AsApIntegrationTPlanBatch','AsApIntegrationLMSBatch')]);        
            Integer enqueuedJobs = [SELECT COUNT() FROM AsyncApexJob 
                                                WHERE JobType='BatchApex' 
                                                AND Status IN ('Processing','Preparing','Queued') 
                                                AND ApexClassID IN :allApexClassMap.keySet()] ;
                        
            if(enqueuedJobs <= 0){
                System.debug(' no enqueuedJobs ');
                Id nullId;
                Set<Id> setnullId = new Set<Id>();
                AsApIntegrationTPlanBatch runBatch = new AsApIntegrationTPlanBatch(nullId,setnullId);
            database.executeBatch(runBatch,50); 
            }
            else{
                System.debug(' has enqueuedJobs ');
            }
        
    }
}