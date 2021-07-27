/**
     * Class PSA_Progress for lightning component myCPD_Plan.cmp  and myCPDprogressBar.cmp(used at home page)
     * @author	Davanti:
     * @author	Surbhi Sharma (Davanti),
     * @since	24/07/2020 
     * @date	24/07/2020 - Surbhi Sharma (Davanti): created initial version
     * @return  pageStateWrapper 
     * @see     myCPD_Plan.cmp 
     */

public class PSA_Progress {
    public static courseCatalogWrapper state;
    
    /**
     * Method  to set courseCatalogWrapper wrapper values
     * @author	Davanti:
     * @author	Surbhi Sharma (Davanti),
     * @since	24/07/2020 
     * @date	24/07/2020 - Surbhi Sharma (Davanti): created initial version
     * @return  pageStateWrapper 
     * @see     myCPD_Plan.cmp
     */
    @AuraEnabled
    public static courseCatalogWrapper allCPDPlanmethod(String recordId){
        state = new courseCatalogWrapper();
        
        User userData;
        try {
            userData = [SELECT AccountId,Id,ContactId,AS_Membership_Span__c,AS_Membership_Status__c,FullPhotoUrl,Name,ProfileId,Profile.name,FirstName FROM User WHERE id =: userInfo.getUserId()];
        } catch(QueryException qe) {
        }
        
        state.userDeatils=userData;
        List<String> course;
       User userDetails = [SELECT AccountId,Id,ContactId,AS_Membership_Span__c,AS_Membership_Status__c,FullPhotoUrl,Name,ProfileId,Profile.name,FirstName FROM User WHERE id =: userInfo.getUserId()];
        if(userDetails.AccountId!=null){
            Account acc = [SELECT Id,Name,Active_Course__c FROM Account WHERE Id =: userDetails.AccountId];
        if(acc.Active_Course__c!=null){
            course = acc.Active_Course__c.split(';');
        }
        if(course!=null){   
        	state.course=course;
        }
            List<Enrolment_Form__c> enrolList = [SELECT Id FROM Enrolment_Form__c WHERE AS_Account__c =: userDetails.AccountId AND Enrolment_Status__c !=: 'Rejected' AND Enrolment_Status__c !=: 'Expired' AND Enrolment_Status__c !=: 'Cancelled/Withdrawn'];
            if(enrolList.size()>0){
                state.showEnrollment=true;
            }
            else{
                state.showEnrollment=false;
            }
        }
        else{
            state.showEnrollment=false;
        }
       
        if(userDetails.ContactId!=null){
            List<AccountContactRelation> acr=new List<AccountContactRelation>();
            acr = [SELECT Id,AccountId,ContactId,Roles,IsActive FROM AccountContactRelation WHERE (Roles = 'Self Care Pharmacy Assistant' OR Roles = 'Self Care Pharmacist') AND ContactId =: userDetails.ContactId AND IsActive = true AND AccountId !=null AND ContactId!=null LIMIT 1];
            if(acr.size()>0){
            state.AccConRelation=acr;
            }
    	}
        //AsCPDPlanner__c cpd = new AsCPDPlanner__c() ;
        List<AsCPDPlanner__c> cpd=new List<AsCPDPlanner__c>();
        try {
        if ( recordId!= '' ) {
                cpd = [SELECT Id,CPD_Year__c,AS_My_Plan_Goals__c,Group_1_Achieved__c , Group_2_Achieved__c ,Group_3_Achieved__c ,Target__c,AS_Total_Group_1_CPD__c,AS_Total_Group_2_CPD__c,AS_Total_Group_3_CPD__c,Total_CPD_Credits_Achieved__c,AS_Accredited_pharmacist__c FROM AsCPDPlanner__c WHERE Id =: recordId AND AsUser__c =: userInfo.getUserId()  ORDER BY Id DESC LIMIT 1];
            } else {
                cpd = [SELECT Id,CPD_Year__c,AS_My_Plan_Goals__c,Group_1_Achieved__c ,Group_2_Achieved__c ,Group_3_Achieved__c ,Target__c,AS_Total_Group_1_CPD__c,AS_Total_Group_2_CPD__c,AS_Total_Group_3_CPD__c,Total_CPD_Credits_Achieved__c,AS_Accredited_pharmacist__c FROM AsCPDPlanner__c WHERE  RecordTypeId = '0127F000000K1frQAC' AND AS_Current_CPD_Plan__c = TRUE AND AsUser__c =: userInfo.getUserId() ORDER BY Id DESC LIMIT 1];
            
            }
        }
        catch(QueryException qe) {
        }
        try{
        if(cpd!=null && cpd.size()>0){
        	state.cpdPlanRecordID=cpd[0].Id;
             state.currentCPDInfo=cpd[0];
        }}
        catch(QueryException qe) {
        }
        
        //Get CPD Activity Summary Data
        List<Map<String,String>> filter_activities = new List<Map<String,String>>();
        List<AsCPD_Learning_Summary__c> activities = new List<AsCPD_Learning_Summary__c>();
        
        try {
            if ( recordId != '' ) {
                activities = [SELECT Id, Name, AS_Training_Plan_Record_ID__c, RecordTypeId,status__c,ASTraining_Plan_Assignment__r.Training_Plan__r.Group__c,ASTraining_Plan_Assignment__r.Training_Plan__r.Achievement__r.Eligible_Image__c,AS_Reflections__c,ASTraining_Plan_Name__c,CPD_Planner__c,AsSummary_Plan__c FROM AsCPD_Learning_Summary__c WHERE CPD_Planner__c =: recordId ORDER BY ASTraining_Plan_Name__c ASC NULLS LAST];
            } else {
                AsCPDPlanner__c cpdnew = [SELECT Id,Target__c FROM AsCPDPlanner__c WHERE RecordTypeId = '0127F000000K1frQAC' AND AS_Current_CPD_Plan__c = true AND AsUser__c =: userInfo.getUserId() ORDER BY Id DESC LIMIT 1];
                try {
                    activities = [SELECT Id, Name, AS_Training_Plan_Record_ID__c, RecordTypeId,status__c,ASTraining_Plan_Assignment__r.Training_Plan__r.Group__c,ASTraining_Plan_Assignment__r.Training_Plan__r.Achievement__r.Eligible_Image__c,AS_Reflections__c,ASTraining_Plan_Name__c,CPD_Planner__c,AsSummary_Plan__c FROM AsCPD_Learning_Summary__c WHERE  CPD_Planner__c =: cpdnew.Id ORDER BY ASTraining_Plan_Name__c ASC NULLS LAST];
                } catch(QueryException qe) {
                }
            }
        } catch(QueryException qe) {
        }
        
        try {
            map<string,string> mapofplanIdGroup=new map<string,string> ();
            map<string,string> mapofplanIdImage=new map<string,string> ();
        List<Training_Plan__c> tpa = [SELECT Id,Group__c,Achievement__r.Eligible_Image__c FROM Training_Plan__c];
            for(Training_Plan__c tp: tpa){
                mapofplanIdGroup.put(tp.id,tp.Group__c);
                mapofplanIdImage.put(tp.id,tp.Achievement__r.Eligible_Image__c);
            }

            for ( AsCPD_Learning_Summary__c activity: activities ) {
                Map<String,String> temp_activity = new Map<String,String>();
                temp_activity.put( 'Id',activity.Id );
                temp_activity.put( 'Name',activity.Name );
                temp_activity.put( 'RecordTypeId',activity.RecordTypeId );
                temp_activity.put( 'Status__c',activity.Status__c );
                temp_activity.put( 'AS_Reflections__c',activity.AS_Reflections__c );
                if ( activity.AsSummary_Plan__c == true ) {
                    temp_activity.put( 'AsSummary_Plan__c', 'true' );
                } else {
                    temp_activity.put( 'AsSummary_Plan__c', 'false' );
                }
                temp_activity.put( 'ASTraining_Plan_Name__c',activity.ASTraining_Plan_Name__c );
                temp_activity.put( 'CPD_Planner__c',activity.CPD_Planner__c );
                temp_activity.put( 'AS_Training_Plan_Record_ID__c',activity.AS_Training_Plan_Record_ID__c );
                try {
                    if(activity.ASTraining_Plan_Assignment__c!=null){
                        temp_activity.put( 'Eligible_Image__c',activity.ASTraining_Plan_Assignment__r.Training_Plan__r.Achievement__r.Eligible_Image__c );
                   		temp_activity.put('Group__c',activity.ASTraining_Plan_Assignment__r.Training_Plan__r.Group__c );
                    }
                    else{
                    //Training_Plan__c tpa = [SELECT Id,Group__c,Achievement__r.Eligible_Image__c FROM Training_Plan__c WHERE Id =: activity.AS_Training_Plan_Record_ID__c LIMIT 1];
                    	temp_activity.put( 'Eligible_Image__c',mapofplanIdImage.get(activity.AS_Training_Plan_Record_ID__c));
                        temp_activity.put('Group__c',mapofplanIdGroup.get(activity.AS_Training_Plan_Record_ID__c));

                    }
                } catch(QueryException qe) {
                }
                
                filter_activities.add( temp_activity );
                
            }
            state.getActivities=filter_activities;
        } 
        catch(Exception e) {
        }
        
         
        try{      
        List<AsCPDPlanner__c> cpdList=[SELECT Id,CPD_Year__c,AS_My_Plan_Goals__c,Group_1_Achieved__c , Group_2_Achieved__c , Group_3_Achieved__c ,Name,Target__c,AS_Total_Group_1_CPD__c,AS_Total_Group_2_CPD__c,AS_Total_Group_3_CPD__c,Total_CPD_Credits_Achieved__c,AS_Accredited_pharmacist__c FROM AsCPDPlanner__c WHERE AsUser__c =: userInfo.getUserId() ORDER BY Id Asc ];
            Map<id,AsCPDPlanner__c> mapofAllCPDPlans=new Map<id,AsCPDPlanner__c>();
        if(cpdList.size()>0){
        	state.listofCPD=cpdList;
            for(AsCPDPlanner__c cpdObj : cpdList){
            mapofAllCPDPlans.put(cpdObj.id, cpdObj);
        	}
        	state.mapOfCPD=mapofAllCPDPlans;
        }
        }
        catch(QueryException qe) {
                }
        
        Attachment attachment=new Attachment();
        List<Attachment> attachments=new List<Attachment>();
        String currentYear = String.valueOf( System.Today().year() );
        try {
            if (recordId !='' ) {
                attachment = [SELECT Id, Name, CreatedDate FROM Attachment WHERE parentId =: recordId ORDER BY Id DESC LIMIT 1];
                attachments = [SELECT Id, Name, CreatedDate FROM Attachment WHERE parentId =: recordId ORDER BY Id DESC];

            } else if (recordId==''){
                AsCPDPlanner__c cpdPlan = [SELECT Id,AS_Current_CPD_Plan__c,AsUser__c FROM AsCPDPlanner__c WHERE AS_Current_CPD_Plan__c = true AND AsUser__c =: userInfo.getUserId() ORDER BY Id DESC LIMIT 1];
                try {
                    attachment = [SELECT Id, Name, CreatedDate FROM Attachment WHERE parentId =: cpdPlan.Id ORDER BY Id DESC LIMIT 1];
                 attachments = [SELECT Id, Name, CreatedDate FROM Attachment WHERE parentId =: cpdPlan.Id ORDER BY Id DESC];

                } catch(QueryException qe) {
                }
            }
        } 
        catch(QueryException qe) {
        }
        if(attachment!=null){
        	state.getPlanAttachment=attachment;
        }
        if(attachments.size()>0){
    		state.getPlanAttachments=attachments;
        }
        return state;
    }
    
    /**
     * Method  to update AS_Accredited_pharmacist__c value of AsCPDPlanner__c record
     * @author	Davanti:
     * @author	Surbhi Sharma (Davanti),
     * @since	24/07/2020 
     * @date	24/07/2020 - Surbhi Sharma (Davanti): created initial version
     * @return  - 
     * @see     myCPD_Plan.cmp
     */
    @AuraEnabled
	public static void updateCheck(boolean isAccredite,string key){
        List<AsCPDPlanner__c> cpdList=new List<AsCPDPlanner__c>();
        cpdList =[select id,AS_Accredited_pharmacist__c from AsCPDPlanner__c WHERE  id=:key];
        AsCPDPlanner__c cpdObj=new AsCPDPlanner__c();
        cpdObj.Id=cpdList[0].id;
        cpdObj.AS_Accredited_pharmacist__c=isAccredite;
        update cpdObj;
    }
    /**
     * Method  to update AS_My_Plan_Goals__c value of AsCPDPlanner__c record from component 
     * @author	Davanti:
     * @author	Surbhi Sharma (Davanti),
     * @since	24/07/2020 
     * @date	24/07/2020 - Surbhi Sharma (Davanti): created initial version
     * @return  - 
     * @see     myCPD_Plan.cmp
     */
    
    @AuraEnabled
	public static void updateGoal(string cpdGoals,string key){
        List<AsCPDPlanner__c> cpdList=new List<AsCPDPlanner__c>();
        cpdList =[select id,AS_My_Plan_Goals__c from AsCPDPlanner__c WHERE  id=:key];
        AsCPDPlanner__c cpdObj=new AsCPDPlanner__c();
        cpdObj.Id=cpdList[0].id;
        cpdObj.AS_My_Plan_Goals__c=cpdGoals;
        update cpdObj;
    }
    /**
     * Method  to update AS_Reflections__c value of AsCPD_Learning_Summary__c record from component 
     * @author	Davanti:
     * @author	Surbhi Sharma (Davanti),
     * @since	24/07/2020 
     * @date	24/07/2020 - Surbhi Sharma (Davanti): created initial version
     * @return  - 
     * @see     myCPD_Plan.cmp
     */
    
    @AuraEnabled
	public static void updateReflection(string cpdGoals,string key){
        List<AsCPD_Learning_Summary__c> cpdList=new List<AsCPD_Learning_Summary__c>();
        cpdList =[select id,AS_Reflections__c from AsCPD_Learning_Summary__c WHERE  id=:key];
        AsCPD_Learning_Summary__c cpdObj=new AsCPD_Learning_Summary__c();
        cpdObj.Id=cpdList[0].id;
        cpdObj.AS_Reflections__c=cpdGoals;
        update cpdObj;
    }
    
    /**
     * Method  to update AsSummary_Plan__c selection value of AsCPD_Learning_Summary__c record from component 
     * @author	Davanti:
     * @author	Surbhi Sharma (Davanti),
     * @since	24/07/2020 
     * @date	24/07/2020 - Surbhi Sharma (Davanti): created initial version
     * @return  - 
     * @see     myCPD_Plan.cmp
     */
    
    @AuraEnabled
	public static void updateSelection(Integer selectedCard ,string key){
        List<AsCPD_Learning_Summary__c> cpdList=new List<AsCPD_Learning_Summary__c>();
        cpdList =[select id,AsSummary_Plan__c from AsCPD_Learning_Summary__c WHERE  id=:key];
        AsCPD_Learning_Summary__c cpdObj=new AsCPD_Learning_Summary__c();
        cpdObj.Id=cpdList[0].id;
        if(selectedCard ==1){
        cpdObj.AsSummary_Plan__c=true;
    	}
        else if(selectedCard==0){
        cpdObj.AsSummary_Plan__c=false;
    	}
        update cpdObj;
    }
    /**
     * Method  to update to genearte report from component selection 
     * @author	Davanti:
     * @author	Surbhi Sharma (Davanti),
     * @since	24/07/2020 
     * @date	24/07/2020 - Surbhi Sharma (Davanti): created initial version
     * @return  - 
     * @see     myCPD_Plan.cmp
     */
    
    @AuraEnabled
    public static void generateCPDPlanReport(String recordId) {
        
        if ( recordId != '' ) {
            try {
          List<AsCPDPlanner__c> cpdlist = [SELECT id,AsGenerateCPDsummary__c FROM AsCPDPlanner__c WHERE Id=:recordId LIMIT 1];
               AsCPDPlanner__c cpd = new AsCPDPlanner__c();
                cpd.Id = cpdlist[0].id;
                cpd.AsGenerateCPDsummary__c = true;
                update cpd;
                
            } catch(QueryException qe) {
            }
        }
        else{
            List<AsCPDPlanner__c> cpdlist = [SELECT id,AsGenerateCPDsummary__c FROM AsCPDPlanner__c WHERE AS_Current_CPD_Plan__c = true AND AsUser__c =: userInfo.getUserId() ORDER BY Id DESC LIMIT 1];
               AsCPDPlanner__c cpd = new AsCPDPlanner__c();
                cpd.Id = cpdlist[0].id;
                cpd.AsGenerateCPDsummary__c = true;
                update cpd;
        }
    }
    /**
     * Wrapper class  for myCPD_Plan.cmp and its child components
     * @author	Davanti:
     * @author	Surbhi Sharma (Davanti),
     * @since	24/07/2020 
     * @date	24/07/2020 - Surbhi Sharma (Davanti): created initial version
     * @return  - 
     * @see     myCPD_Plan.cmp
     */
    
    public class courseCatalogWrapper {
        @AuraEnabled
        public String cpdPlanRecordID{set;get;}
        @AuraEnabled
        public AsCPDPlanner__c currentCPDInfo{set;get;}
        @AuraEnabled
        public user userDeatils{get;set;}
        @AuraEnabled
        public List<AsCPDPlanner__c> listofCPD{get;set;}
        @AuraEnabled
        Public Map<id,AsCPDPlanner__c> mapOfCPD {get;set;}
        @AuraEnabled
        public List<Attachment> getPlanAttachments{get;set;}
         @AuraEnabled
        public Attachment getPlanAttachment{get;set;}
        @AuraEnabled
        public List<String> course{get;set;}
        @AuraEnabled
        public List<AccountContactRelation> AccConRelation{get;set;}
        @AuraEnabled
        public  List<Map<String,String>> getActivities{get;set;}
        @AuraEnabled
        public Boolean showEnrollment{get;set;}
    }
}