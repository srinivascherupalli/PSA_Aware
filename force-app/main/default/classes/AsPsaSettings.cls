public  class AsPsaSettings {

    public string btnName {get;set;}
    public Id cronId {get;set;}
    public Set<Id> trainTrackcronIdSet = new Set<Id>();
    public Set<Id> apIntegrationcronIdSet = new Set<Id>();
    public string btnclass {get;set;} 
    public String MemberRenewalRunBatchType {get;set;}
    
    public string trainTrackBtnClassStr {get;set;} 
  public string trainTrackBtnNameStr {get;set;} 

    public String BatchCreateCpdYearStr {get;set;}
    public boolean BatchCreateCpdCurrentBool {get;set;}
    
    public string apIntegrationBtnClassStr {get;set;} 
    public string apIntegrationBtnNameStr {get;set;} 

    public String otherSettingsPdfUrlStr {get;set;}
    public String otherSettingsLoginUrlStr {get;set;}

    public AsPsaSettings(){
  
        getPSAOtherSettings();

    }

    /*Author : Jet R. Compayan
      *Description : This methode used to the run the Member Renewal Batch 
      *Date Created :
      *Last Modified By : Jet R. Compayan
      *Date Last Modified : 
      *Param : 
      *Return : null
     */
    public PageReference  MemberRenewalRunBatchByProcedure(){
     
        if( MemberRenewalRunBatchType == 't1' ){
            runThisBatch1();
        } else if( MemberRenewalRunBatchType == 't2t3t4' ){
            runThisBatch2();
        } else if( MemberRenewalRunBatchType == 'end' ){
            runThisBatch5();
        } else if( MemberRenewalRunBatchType == 't5t5t7' ){
            runThisBatch3();
        } else if( MemberRenewalRunBatchType == 't8' ){
            runThisBatch4();
        }
        return null;
    }
    
    /*Author : Jet R. Compayan
      *Description : This methode used to the run the Member Renewal Secheduler 
      *Date Created :
      *Last Modified By : Jet R. Compayan
      *Date Last Modified : 
      *Param : 
      *Return : null
     */
    public  PageReference MemberRenewalRunScheduler(){
        
        if( btnName == 'Run Scheduler' ){
            String schedule='0 0 0 1/1 * ? *';
            AS_membershipRenewalSchedulerExcute nextBatchJob = new AS_membershipRenewalSchedulerExcute(); 
            String jobID = System.schedule('Membership Renewal', schedule, nextBatchJob);   
        } else if( btnName == 'Abort Scheduler job' ) {
            System.abortJob(cronId);
        }
        loadisRunning();
        
        return null;
    }
    
    /*
    *Author : John Hope
      *Description : This method used to the run the train Track Sync Secheduler 
      *Date Created :
      *Last Modified By : John Hope
      *Date Last Modified : 
      *Param : 
      *Return : null
        */
    public  PageReference trainTrackAndMoodleRunScheduler(){
        
        if( trainTrackBtnNameStr == 'Run Training Track Registration and Moodle Syncing Batch' ){
            /*
            String schedule='0 0 0/1 1/1 * ? *';
            AS_batchTrainTrackAndMoodleScheduler nextBatchJob = new AS_batchTrainTrackAndMoodleScheduler(); 
            String jobID = System.schedule('Training Track and Moodle Syncing Batch', schedule, nextBatchJob);
           */
           
            System.schedule('Training Track and Moodle Syncing Batch 1', '0 0 * * * ?', new AS_batchTrainTrackAndMoodleScheduler());
                        System.schedule('Training Track and Moodle Syncing Batch 2', '0 5 * * * ?', new AS_batchTrainTrackAndMoodleScheduler());
                        System.schedule('Training Track and Moodle Syncing Batch 3', '0 10 * * * ?', new AS_batchTrainTrackAndMoodleScheduler());
                        System.schedule('Training Track and Moodle Syncing Batch 4', '0 15 * * * ?', new AS_batchTrainTrackAndMoodleScheduler());
                        System.schedule('Training Track and Moodle Syncing Batch 5', '0 20 * * * ?', new AS_batchTrainTrackAndMoodleScheduler());
                        System.schedule('Training Track and Moodle Syncing Batch 6', '0 25 * * * ?', new AS_batchTrainTrackAndMoodleScheduler());
                        System.schedule('Training Track and Moodle Syncing Batch 7', '0 30 * * * ?', new AS_batchTrainTrackAndMoodleScheduler());
                        System.schedule('Training Track and Moodle Syncing Batch 8', '0 35 * * * ?', new AS_batchTrainTrackAndMoodleScheduler());
                        System.schedule('Training Track and Moodle Syncing Batch 9', '0 40 * * * ?', new AS_batchTrainTrackAndMoodleScheduler());
                        System.schedule('Training Track and Moodle Syncing Batch 10', '0 45 * * * ?', new AS_batchTrainTrackAndMoodleScheduler());
                        System.schedule('Training Track and Moodle Syncing Batch 11', '0 50 * * * ?', new AS_batchTrainTrackAndMoodleScheduler());
                        System.schedule('Training Track and Moodle Syncing Batch 12', '0 55 * * * ?', new AS_batchTrainTrackAndMoodleScheduler());
                        
        } else if( trainTrackBtnNameStr == 'Abort Training Track and Moodle Syncing Scheduler job' ) {
         //   System.abortJob(trainTrackcronIdSet);
            for(Id cronId : trainTrackcronIdSet) {
                System.abortJob(cronId);
            }
        }
        LoadisRunning();
        
        return null;
    }
    
    /*
    *Author : John Hope
      *Description : This method used to the run the Ap Integration Secheduler 
      *Date Created :
      *Last Modified By : John Hope
      *Date Last Modified : 
      *Param : 
      *Return : null
        */
    public  PageReference apIntegrationRunScheduler(){
        
        if( apIntegrationBtnNameStr == 'Run Ap Integration Batch' ){
            System.schedule('Ap Integration Batch 1', '0 0 * * * ?', new AS_batchApIntegrationScheduler());
                        System.schedule('Ap Integration Batch 2', '0 5 * * * ?', new AS_batchApIntegrationScheduler());
                        System.schedule('Ap Integration Batch 3', '0 10 * * * ?', new AS_batchApIntegrationScheduler());
                        System.schedule('Ap Integration Batch 4', '0 15 * * * ?', new AS_batchApIntegrationScheduler());
                        System.schedule('Ap Integration Batch 5', '0 20 * * * ?', new AS_batchApIntegrationScheduler());
                        System.schedule('Ap Integration Batch 6', '0 25 * * * ?', new AS_batchApIntegrationScheduler());
                        System.schedule('Ap Integration Batch 7', '0 30 * * * ?', new AS_batchApIntegrationScheduler());
                        System.schedule('Ap Integration Batch 8', '0 35 * * * ?', new AS_batchApIntegrationScheduler());
                        System.schedule('Ap Integration Batch 9', '0 40 * * * ?', new AS_batchApIntegrationScheduler());
                        System.schedule('Ap Integration Batch 10', '0 45 * * * ?', new AS_batchApIntegrationScheduler());
                        System.schedule('Ap Integration Batch 11', '0 50 * * * ?', new AS_batchApIntegrationScheduler());
                        System.schedule('Ap Integration Batch 12', '0 55 * * * ?', new AS_batchApIntegrationScheduler());
                        
        } else if( apIntegrationBtnNameStr == 'Abort Ap Integration Scheduler job' ) {
            System.debug('apIntegrationcronIdSet : ' + apIntegrationcronIdSet);
            for(Id cronId : apIntegrationcronIdSet) {
                System.abortJob(cronId);
            }
        }
        LoadisRunning();
        
        return null;
    }

    /*Author : Jet R. Compayan
      *Description : This methode used to the run the Batch Create Cpd Run
      *Date Created :
      *Last Modified By : Jet R. Compayan
      *Date Last Modified : 
      *Param : 
      *Return : null
     */
    public PageReference BatchCreateCpdRun(){
            // code below is commented out to call 'ASCPDPlannerManualInactiveBatch' first and from there, run the 'ASCPDPlannerManualCreateBatch'.(#PSA-271)
        // ASCPDPlannerManualCreateBatch runBatch = new  ASCPDPlannerManualCreateBatch(BatchCreateCpdYearStr,BatchCreateCpdCurrentBool);
        ASCPDPlannerManualInactiveBatch runBatch = new  ASCPDPlannerManualInactiveBatch(BatchCreateCpdYearStr,BatchCreateCpdCurrentBool);
            database.executeBatch(runBatch);

        return null;
    }

    /*Author : Jet R. Compayan
      *Description : This methode used to save the data on the Custom Settings
      *Date Created :
      *Last Modified By : Jet R. Compayan
      *Date Last Modified : 
      *Param : 
      *Return : null
    */
    public PageReference OtherSettingSave(){
        //public String otherSettingsPdfUrlStr {get;set;}
        //public String otherSettingsLoginUrlStr {get;set;}

        ASPSASettings__c psaSettings =  ASPSASettings__c.getOrgDefaults();
        psaSettings.AsInvoicePDFUrl__c = otherSettingsPdfUrlStr;
        psaSettings.AsMembershipRegistrationURL__c = otherSettingsLoginUrlStr;
        upsert psaSettings;

        getPSAOtherSettings();
        return null;
    }

    /*Author : Jet R. Compayan
      *Description : This Method used to load the status of the scheduler
      *Date Created :
      *Last Modified By : John Hope 
      *Date Last Modified : 
      *Param : 
      *Return : null
    */
    public void loadisRunning(){
        // for membership renewal
        List<CronTrigger> listCronTrigger = [SELECT  Id,CronJobDetail.Name, CronJobDetailId FROM CronTrigger WHERE  CronJobDetail.Name = 'Membership Renewal' limit 1 ];
        if(listCronTrigger.size() != 0){
            system.debug( 'naa' ); 
            btnName = 'Abort Scheduler job';
            cronId  = listCronTrigger[0].Id;
            btnclass = 'btn-abort';
        } else {
            btnName = 'Run Scheduler';
            btnclass = '';
        }  
        
        // for training track 
        List<CronTrigger> trackCronTriggerList = [SELECT  Id,CronJobDetail.Name, CronJobDetailId FROM CronTrigger WHERE  CronJobDetail.Name like 'Training Track and Moodle Syncing Batch %'];
        if(trackCronTriggerList.size() != 0){
            trainTrackBtnNameStr = 'Abort Training Track and Moodle Syncing Scheduler job';
            trainTrackBtnClassStr = 'btn-abort';
            
            for(CronTrigger cron : trackCronTriggerList) {
                trainTrackcronIdSet.add(cron.Id);
            }
        } else {
            trainTrackBtnNameStr = 'Run Training Track Registration and Moodle Syncing Batch';
            trainTrackBtnClassStr = '';
        }
        
        // for ap integration
        List<CronTrigger> integrationCronTriggerList = [SELECT  Id,CronJobDetail.Name, CronJobDetailId FROM CronTrigger WHERE  CronJobDetail.Name like 'Ap Integration Batch %'];
        if(integrationCronTriggerList.size() != 0){
            apIntegrationBtnNameStr = 'Abort Ap Integration Scheduler job';
            apIntegrationBtnClassStr = 'btn-abort';
            
            for(CronTrigger cron : integrationCronTriggerList) {
                apIntegrationcronIdSet.add(cron.Id);
            }
        } else {
            apIntegrationBtnNameStr = 'Run Ap Integration Batch';
            apIntegrationBtnClassStr = '';
        }   
    }
    
    public void runThisBatch1(){
        AS_batchMembershipRenewalT1 T1 = new AS_batchMembershipRenewalT1();
        database.executeBatch(T1);
    }
    public  void runThisBatch2(){
        AS_batchMembershipRenewalT2T3T4 T2T3T4 = new AS_batchMembershipRenewalT2T3T4();
        database.executeBatch(T2T3T4);
    }
    public  void runThisBatch3(){
        AS_batchMembershipRenewalT5T6T7 T5T6T7 = new AS_batchMembershipRenewalT5T6T7();
        database.executeBatch(T5T6T7);
    }
    public  void runThisBatch4(){
        AS_batchMembershipRenewalT8 wew = new AS_batchMembershipRenewalT8();
        database.executeBatch(wew);
        
    }
    public  void runThisBatch5(){
        AS_batchMembershipRenewalEND TEND = new AS_batchMembershipRenewalEND();
        database.executeBatch(TEND);
    }
    
    /*Author : John Hope
      *Description : getter and setter for CPD Competencies
      *Date Created :
      *Last Modified By : John Hope
      *Date Last Modified : 
      *Param : 
      *Return : Map<String,List<AsCPDPlannerCompetencies__c>>
      */
    public  void getPSAOtherSettings() {
        ASPSASettings__c PSAOtherSettings = ASPSASettings__c.getInstance();

        otherSettingsPdfUrlStr = PSAOtherSettings.AsInvoicePDFUrl__c;
        otherSettingsLoginUrlStr =  PSAOtherSettings.AsMembershipRegistrationURL__c;
    }
}