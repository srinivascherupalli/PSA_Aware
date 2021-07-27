public class AS_TrainingPlanAssignmentQueueable implements Queueable, Database.AllowsCallouts {
    
    
    public Set<Id> newLmsc {get;set;}
	public Map<string,Id> newmapxID_TpAssign {get;set;}
   
    public AS_TrainingPlanAssignmentQueueable(Set<Id> LmsC,Map<String,Id> mapxID_TpAssign) {
        newLmsc = LmsC;
        newmapxID_TpAssign = mapxID_TpAssign;
    }
    
    public void execute(QueueableContext context) {
         
        
        if(!newLmsc.isEmpty()){
            List<LMS_Course_Enrolment__c> lmsCourseEnrol = [SELECT Id, AsExtId__c, LMS_Instance__c FROM LMS_Course_Enrolment__c WHERE Id IN: newLmsc];
            List<Training_Plan_Assignment__c> updateLmsTplanAss = new List<Training_Plan_Assignment__c>();
            if(!lmsCourseEnrol.isEmpty()){
                
                for(LMS_Course_Enrolment__c singleLmsCorseEnrol : lmsCourseEnrol){
                    if(newmapxID_TpAssign.containsKey(singleLmsCorseEnrol.AsExtId__c)){
                        Training_Plan_Assignment__c newTpAssign = new Training_Plan_Assignment__c();
                        newTpAssign.Id = newmapxID_TpAssign.get(singleLmsCorseEnrol.AsExtId__c);
                        newTpAssign.AS_LMS_course_enrolment__c = singleLmsCorseEnrol.Id;
                        newTpAssign.AS_LMS_Instance__c = singleLmsCorseEnrol.LMS_Instance__c;
						updateLmsTplanAss.add(newTpAssign);
                    }
                }
            }
            if(!updateLmsTplanAss.isEmpty()) Database.update(updateLmsTplanAss,false);
        }
    }

}