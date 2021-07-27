trigger DL_AS_BG_Course_Enrolment_Trigger on AS_BG_Course_Enrolment__c (after insert, after update) {

    if(Trigger.isupdate){
        System.debug('DL_AS_BG_Course_Enrolment_Trigger');
        Boolean runScheduledClass = false;
        List<Id> certIIIComPharmacy_ids = new List<Id>();
        
        certIIIComPharmacy_ids.add('a1m0o00000KawZfAAJ');
        certIIIComPharmacy_ids.add('a1m0o00000Kh2j2AAB');
        certIIIComPharmacy_ids.add('a1m0o00000Kh1izAAB');

        if(Trigger.old.size() > 0){
            for(AS_BG_Course_Enrolment__c BGEnrolment : Trigger.old){
                if(certIIIComPharmacy_ids.contains(BGEnrolment.Parent_Banner_Group_Course__c) && BGEnrolment.AS_Enrolment_Confirmation_Status__c == 'Under Review'){
                    runScheduledClass = true;
                }
            }

            if(runScheduledClass){
                DL_BG_Course_Enrolment_Schedulable dl_bg_course_enrolment_schedulable = new DL_BG_Course_Enrolment_Schedulable();
                Datetime executeTime = System.now().addMinutes(2); 
                String jobName = 'DL_BG_Course_Enrolment_Schedulable ' + executeTime.format('h:mm a');
                String cronExp = dl_bg_course_enrolment_schedulable.GetCRONExpression(executeTime);
                if (!([SELECT Id, CronJobDetail.Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = :jobName].size() > 0) ){
                    try{
                        System.schedule(jobName, cronExp, dl_bg_course_enrolment_schedulable);
                    }
                    catch(Exception e){
                        System.debug(e.getMessage());
                    }
                    
                }
                
            }
        }
        
    }

}