/*Author : Michael Vincent Largo
*Description :  This class is  Learning Assignment that will update the Training plan Assignment that connected to Training plan Section Assignment.
*Date Created : September 25,2019
*Last Modified By : 
*Date Last Modified :
*/
public class AS_LearningAssignmentHandler {
    
    private static Boolean recursiveVal = false;
    
    public static void UpdateLearningAssignmentBaseOnTrainingplanAssignmentResult(List<Learning_Assignment__c> newLearningAssignment){
        
        
        if (recursiveVal == false) {
            recursiveVal = true;
            
            
            Set<Id> learnaAssIds = new Set<Id>();
            Set<Id> TpanSecAssIds = new Set<Id>();
            List<Training_Plan_Assignment__c> allTplanAssignUpdate = new List<Training_Plan_Assignment__c>();
            
            for (Learning_Assignment__c learnAssign : newLearningAssignment){
                
                if (learnAssign.Learning__c !=null && learnAssign.Progress__c == 'Completed') {
                    learnaAssIds.add(learnAssign.Id);
                }
                
                if (learnAssign.Training_Plan_Section_Assignment__c !=null && learnAssign.User__c !=null) {
                    TpanSecAssIds.add(learnAssign.Training_Plan_Section_Assignment__c);
                }
            }
            
            Map<Id,String> mapTplanSecAss_tplanAss = new Map<Id,String>();
            Map<Id,Training_Plan_Section_Assignment__c> mapTplanSecAss = new Map<Id,Training_Plan_Section_Assignment__c>();
            for (Training_Plan_Section_Assignment__c TplanSecAss : [SELECT Id,User__c,Training_Plan_Assignment__c,Training_Plan_Assignment__r.User__c,Training_Plan_Assignment__r.AS_Enrolled_Unit__c,Training_Plan_Assignment__r.Status__c FROM Training_Plan_Section_Assignment__c WHERE Id =:TpanSecAssIds]) {
                if (TplanSecAss.Training_Plan_Assignment__c !=null){
                    mapTplanSecAss.put(TplanSecAss.Id,TplanSecAss);
                    mapTplanSecAss_tplanAss.put(TplanSecAss.Id, TplanSecAss.Training_Plan_Assignment__r.Status__c);
                }
            }
            
            if (!mapTplanSecAss.isEmpty()) {
                
                List<Learning_Assignment__c> alllearningassList = [SELECT Id,Name,Learning__c,Learning__r.RecordTypeId,User__c,Training_Plan_Section_Assignment__c FROM Learning_Assignment__c WHERE Id IN:learnaAssIds];
                Id learnRecordId = Schema.SObjectType.Learning__c.getRecordTypeInfosByDeveloperName().get('Resource').getRecordTypeId();
                string inprogress;
                
                
                for (Learning_Assignment__c learn : alllearningassList) {
                    
                    if (mapTplanSecAss.containsKey(learn.Training_Plan_Section_Assignment__c) && mapTplanSecAss_tplanAss.containsKey(learn.Training_Plan_Section_Assignment__c) && learn.Learning__r.RecordTypeId != learnRecordId) {
                        
                        inprogress = mapTplanSecAss_tplanAss.get(learn.Training_Plan_Section_Assignment__c);
                        Id tplanAssignId = mapTplanSecAss.get(learn.Training_Plan_Section_Assignment__c).Training_Plan_Assignment__c;
                       
                        if (mapTplanSecAss.get(learn.Training_Plan_Section_Assignment__c).Training_Plan_Assignment__r.AS_Enrolled_Unit__c !=null && mapTplanSecAss.get(learn.Training_Plan_Section_Assignment__c).Training_Plan_Assignment__r.User__c == learn.User__c) {
                            
                            if (inprogress == 'In Progress') {
                                Training_Plan_Assignment__c TplanAssign = new Training_Plan_Assignment__c();
                                TplanAssign.Id = tplanAssignId;
                                TplanAssign.AS_Result__c = 'Continuing';
                                allTplanAssignUpdate.add(TplanAssign);
                                
                           }
                        }
                    }
                }
            }
            
            if (!allTplanAssignUpdate.isEmpty()) {
                update allTplanAssignUpdate;
            }
            
        }
    }
    
}