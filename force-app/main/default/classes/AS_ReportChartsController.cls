public class AS_ReportChartsController {
    
     @AuraEnabled
    public static List<AsCPD_Learning_Summary__c> cpdActivityReport(String cpdPlanId){
        String cpdId = URL.getSalesforceBaseUrl().toString();
       System.debug('cpdId: ' + cpdPlanId);
        List<AsCPD_Learning_Summary__c> cpdActivitySummary = [Select ID, CreatedDate, Status__c, CPD_Planner__c, CPD_Planner__r.Logged_in_User__c From AsCPD_Learning_Summary__c Where CPD_Planner__c =: cpdPlanId AND CPD_Planner__r.Logged_in_User__c =: 'True'];
        
        return cpdActivitySummary;
    }
    
    @AuraEnabled
    public static List<AsCPDPlanner__c> cpdPlanProgressReport(String cpdPlanId){
        List<AsCPDPlanner__c> cpdPlanProgress = [Select ID, CreatedDate, AS_Plan_Year__c, AS_CPD_Credits_Percentage__c, Logged_in_User__c From AsCPDPlanner__c Where ID =: cpdPlanId AND Logged_in_User__c =: 'True'];
        
        return cpdPlanProgress;
    }
    
    //This method will return a profile member or non member
   	@AuraEnabled 
    public static boolean cpdIsMember(){
        return AS_HelperClass.isUserMember(UserInfo.getUserId());
    }
    
    
    
}