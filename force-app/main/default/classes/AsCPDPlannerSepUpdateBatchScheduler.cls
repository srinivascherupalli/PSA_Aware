/*
*Author : Crishel-Ann
*Description : This is a class that acts as a scheduler for running the ASCPDPlannerManualCreateBatch batch.
*JIRA TASK: https://jira.alphasys.com.au/browse/PSAMOPT-120
*Date Created : December 18, 2019
*/
global class AsCPDPlannerSepUpdateBatchScheduler implements Schedulable{
    global void execute(SchedulableContext SC){
        
        
        Map<Id,ApexClass> allApexClassMap = new Map<Id,ApexClass>([Select Id from ApexClass where Name IN ('ASCPDPlannerManualCreateBatch')]);        
        Integer enqueuedJobs = [SELECT COUNT() FROM AsyncApexJob 
                                WHERE JobType='BatchApex' 
                                AND Status IN ('Processing','Preparing','Queued') 
                                AND ApexClassID IN :allApexClassMap.keySet()] ;
        
        if(enqueuedJobs <= 0){
            System.debug(' no enqueuedJobs ');
            String cpdYear = String.valueOf(Date.today().addDays(400).year());
            Boolean cpdCurrent = true;
            ASCPDPlannerManualCreateBatch runBatch = new ASCPDPlannerManualCreateBatch(cpdYear,cpdCurrent);
            database.executeBatch(runBatch,50); 
        }
        else{
            System.debug(' has enqueuedJobs ');
        }
        
    }
}