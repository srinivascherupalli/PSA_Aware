/**
     * Class PSA_MyEducation for lightning component 
     * @author	Davanti:
     * @author	Surbhi Sharma (Davanti),
     * @since	24/07/2020 
     * @date	24/07/2020 - Surbhi Sharma (Davanti): created initial version
     * @return  pageStateWrapper 
     * @see     myEducation.cmp
     */
public class PSA_MyEducation {
        public static courseCatalogWrapper state;
    @AuraEnabled
    public static courseCatalogWrapper allCPDPlanmethod(){
        state = new courseCatalogWrapper();
        User userData;
        try {
            userData = [SELECT AccountId,Id,ContactId,AS_Membership_Span__c,AS_Membership_Status__c,FullPhotoUrl,Name,ProfileId,Profile.name,FirstName FROM User WHERE id =: userInfo.getUserId()];
        } catch(QueryException qe) {
        }
        if(userData!=null){
            state.userDeatils=userData;
        }
        
        List<Training_Plan_Assignment__c> tpAssignmentList = new List<Training_Plan_Assignment__c>() ;
       	tpAssignmentList= [select id,Status__c,Completed_On__c,Training_Plan__c,Training_Plan__r.Name,Training_Plan__r.Group__c,CreatedDate,Training_Plan__r.Achievement__r.Eligible_Image__c from Training_Plan_Assignment__c where User__c = :UserInfo.getUserId() ORDER BY Training_Plan__r.Name ASC NULLS LAST];
        if(tpAssignmentList.size()>0){
            state.tpAssignmentList=tpAssignmentList;
        }
        
        Id currentUserId = UserInfo.getUserId();
        List<PermissionSetAssignment> userPerms = [select Id,AssigneeId,PermissionSetId from PermissionSetAssignment where PermissionSet.Name = 'LMS_Admin'and AssigneeId = :currentUserId];
        
        if(userPerms.size()>0){
            state.isAsAdminUser=true;
        }else{
            state.isAsAdminUser=false;
        }
    	return state;
    }
    
    public class courseCatalogWrapper {
        @AuraEnabled
        public user userDeatils{get;set;}
        @AuraEnabled
        public List<Training_Plan_Assignment__c> tpAssignmentList{get;set;}
       @AuraEnabled
        public boolean isAsAdminUser{get;set;}
    }

}