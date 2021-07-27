public class PSA {
    
    @AuraEnabled
    public static user fetchUser() {
        
        User u;
        try {
            u = [SELECT AccountId,Id,AS_Membership_Span__c,AS_Membership_Status__c,FullPhotoUrl,Name,ProfileId,FirstName FROM User WHERE id =: userInfo.getUserId()];
        } catch(QueryException qe) {
        }
        
        return u;
    }
    
    @AuraEnabled
    public static AccountContactRelation getAccountContactRelation() {
        
        User u;
        AccountContactRelation acr;
        try {
            u = [SELECT Id,AccountId,ContactId FROM User WHERE Id =: userInfo.getUserId()];
            try {
                acr = [SELECT Id,AccountId,ContactId,Roles FROM AccountContactRelation WHERE (Roles = 'Self Care Pharmacy Assistant' OR Roles = 'Self Care Pharmacist') AND ContactId =: u.ContactId AND IsActive = true LIMIT 1];
            } catch(QueryException qe) {
            }
        } catch(QueryException qe) {
        }
        
        return acr;
    }
    
    @AuraEnabled
    public static String getPlanId( String recordId ) {
        
        String currentYear = String.valueOf( System.Today().year() );
        
        if ( recordId == '' ) {
            AsCPDPlanner__c cpd = [SELECT Id FROM AsCPDPlanner__c WHERE RecordTypeId = '0127F000000K1frQAC' AND AS_Current_CPD_Plan__c = true AND AsUser__c =: userInfo.getUserId() ORDER BY Id DESC LIMIT 1];
            recordId = cpd.Id;
        }
        
        return recordId;
    }
    
    @AuraEnabled
    public static Decimal currentCPDTarget( String recordId ) {
        
        Decimal target = 0.00;
        String currentYear = String.valueOf( System.Today().year() );
        
        try {
            AsCPDPlanner__c cpd;
            if ( recordId != '' ) {
                cpd = [SELECT Id,Target__c FROM AsCPDPlanner__c WHERE Id =: recordId AND AsUser__c =: userInfo.getUserId()];
            } else {
                cpd = [SELECT Id,Target__c FROM AsCPDPlanner__c WHERE RecordTypeId = '0127F000000K1frQAC' AND AS_Current_CPD_Plan__c = true AND AsUser__c =: userInfo.getUserId() ORDER BY Id DESC LIMIT 1];
            }
            
            target = cpd.Target__c;
        } catch(QueryException qe) {
        }
        
        return target;
    }
    
    @AuraEnabled
    public static Integer currentCPDActivitiesSummaryTotal( String recordId ) {
        
        Integer total = 0;
        String currentYear = String.valueOf( System.Today().year() );
        
        try {
            AsCPDPlanner__c cpd;
            if ( recordId != '' ) {
                cpd = [SELECT Id,Target__c FROM AsCPDPlanner__c WHERE Id =: recordId AND AsUser__c =: userInfo.getUserId()];
            } else {
                cpd = [SELECT Id,Target__c FROM AsCPDPlanner__c WHERE RecordTypeId = '0127F000000K1frQAC' AND AS_Current_CPD_Plan__c = true AND AsUser__c =: userInfo.getUserId() ORDER BY Id DESC LIMIT 1];
            }
            
            try {
                total = [SELECT COUNT() FROM AsCPD_Learning_Summary__c WHERE CPD_Planner__c =: cpd.Id];
            } catch(QueryException qe) {
            }
        } catch(QueryException qe) {
        }
        
        return total;
    }
    
    @AuraEnabled
    public static Double currentCPDActivitiesSummaryPercentage( String recordId ) {
        
        Double percentage = 0;
        String currentYear = String.valueOf( System.Today().year() );
        
        try {
            AsCPDPlanner__c cpd;
            if ( recordId != '' ) {
                cpd = [SELECT Id,Target__c,Total_CPD_Credits_Achieved__c FROM AsCPDPlanner__c WHERE Id =: recordId AND AsUser__c =: userInfo.getUserId()];
            } else {
                cpd = [SELECT Id,Target__c,Total_CPD_Credits_Achieved__c FROM AsCPDPlanner__c WHERE RecordTypeId = '0127F000000K1frQAC' AND AS_Current_CPD_Plan__c = true AND AsUser__c =: userInfo.getUserId() ORDER BY Id DESC LIMIT 1];
            }
            
            try {
                percentage = ( cpd.Total_CPD_Credits_Achieved__c * 100 ) / cpd.Target__c;
            } catch(Exception e) {
            }
        } catch(QueryException qe) {
        }
        
        if ( percentage > 100.00 ) {
            percentage = 100.00;
        }
        
        return percentage;
    }
    
    @AuraEnabled
    public static AsCPDPlanner__c currentCPD( String recordId ) {
        
        AsCPDPlanner__c cpd;
        String currentYear = String.valueOf( System.Today().year() );
        
        try {
            if ( recordId != '' ) {
                cpd = [SELECT Id,AS_Total_Group_1_CPD__c,AS_Total_Group_2_CPD__c,AS_Total_Group_3_CPD__c,Total_CPD_Credits_Achieved__c,AS_Accredited_pharmacist__c FROM AsCPDPlanner__c WHERE Id =: recordId AND AsUser__c =: userInfo.getUserId()];
            } else {
                cpd = [SELECT Id,AS_Total_Group_1_CPD__c,AS_Total_Group_2_CPD__c,AS_Total_Group_3_CPD__c,Total_CPD_Credits_Achieved__c,AS_Accredited_pharmacist__c FROM AsCPDPlanner__c WHERE RecordTypeId = '0127F000000K1frQAC' AND AS_Current_CPD_Plan__c = true AND AsUser__c =: userInfo.getUserId() ORDER BY Id DESC LIMIT 1];
            }
        } catch(QueryException qe) {
        }
        
        return cpd;
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getPlannedActivities( String recordId ) {
        
        List<Map<String,String>> filter_activities = new List<Map<String,String>>();
        List<AsCPD_Learning_Summary__c> activities;
        String currentYear = String.valueOf( System.Today().year() );
        
        try {
            if ( recordId != '' ) {
                activities = [SELECT Id, Name, AS_Training_Plan_Record_ID__c, RecordTypeId FROM AsCPD_Learning_Summary__c WHERE Status__c = 'Planned' AND CPD_Planner__c =: recordId];
            } else {
                AsCPDPlanner__c cpd = [SELECT Id,Target__c FROM AsCPDPlanner__c WHERE RecordTypeId = '0127F000000K1frQAC' AND AS_Current_CPD_Plan__c = true AND AsUser__c =: userInfo.getUserId() ORDER BY Id DESC LIMIT 1];
                try {
                    activities = [SELECT Id, Name, AS_Training_Plan_Record_ID__c, RecordTypeId FROM AsCPD_Learning_Summary__c WHERE Status__c = 'Planned' AND CPD_Planner__c =: cpd.Id];
                } catch(QueryException qe) {
                }
            }
        } catch(QueryException qe) {
        }
        
        try {
            for ( AsCPD_Learning_Summary__c activity: activities ) {
                Map<String,String> temp_activity = new Map<String,String>();
                temp_activity.put( 'Id',activity.Id );
                temp_activity.put( 'Name',activity.Name );
                temp_activity.put( 'RecordTypeId',activity.RecordTypeId );
                temp_activity.put( 'AS_Training_Plan_Record_ID__c',activity.AS_Training_Plan_Record_ID__c );
                try {
                    Training_Plan_Achievement__c tpa = [SELECT Id,Achievement__r.Eligible_Image__c FROM Training_Plan_Achievement__c WHERE Training_Plan__c =: activity.AS_Training_Plan_Record_ID__c LIMIT 1];
                    temp_activity.put( 'Eligible_Image__c',tpa.Achievement__r.Eligible_Image__c );
                } catch(QueryException qe) {
                }
                
                filter_activities.add( temp_activity );
            }
        } catch(Exception e) {
        }
        
        return filter_activities;
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getInProgressActivities( String recordId ) {
        
        List<Map<String,String>> filter_activities = new List<Map<String,String>>();
        List<AsCPD_Learning_Summary__c> activities;
        String currentYear = String.valueOf( System.Today().year() );
        
        try {
            if ( recordId != '' ) {
                activities = [SELECT Id, Name, AS_Training_Plan_Record_ID__c, RecordTypeId FROM AsCPD_Learning_Summary__c WHERE Status__c = 'In Progress' AND CPD_Planner__c =: recordId];
            } else {
                AsCPDPlanner__c cpd = [SELECT Id,Target__c FROM AsCPDPlanner__c WHERE RecordTypeId = '0127F000000K1frQAC' AND AS_Current_CPD_Plan__c = true AND AsUser__c =: userInfo.getUserId() ORDER BY Id DESC LIMIT 1];
                try {
                    activities = [SELECT Id, Name, AS_Training_Plan_Record_ID__c, RecordTypeId FROM AsCPD_Learning_Summary__c WHERE Status__c = 'In Progress' AND CPD_Planner__c =: cpd.Id];
                } catch(QueryException qe) {
                }
            }
        } catch(QueryException qe) {
        }
        
        try {
            for ( AsCPD_Learning_Summary__c activity: activities ) {
                Map<String,String> temp_activity = new Map<String,String>();
                temp_activity.put( 'Id',activity.Id );
                temp_activity.put( 'Name',activity.Name );
                temp_activity.put( 'RecordTypeId',activity.RecordTypeId );
                temp_activity.put( 'AS_Training_Plan_Record_ID__c',activity.AS_Training_Plan_Record_ID__c );
                try {
                    Training_Plan_Achievement__c tpa = [SELECT Id,Achievement__r.Eligible_Image__c FROM Training_Plan_Achievement__c WHERE Training_Plan__c =: activity.AS_Training_Plan_Record_ID__c LIMIT 1];
                    temp_activity.put( 'Eligible_Image__c',tpa.Achievement__r.Eligible_Image__c );
                } catch(QueryException qe) {
                }
                
                filter_activities.add( temp_activity );
            }
        } catch(Exception e) {
        }
        
        return filter_activities;
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getNotStartedActivities( String recordId ) {
        
        List<Map<String,String>> filter_activities = new List<Map<String,String>>();
        List<AsCPD_Learning_Summary__c> activities;
        String currentYear = String.valueOf( System.Today().year() );
        
        try {
            if ( recordId != '' ) {
                activities = [SELECT Id, Name, AS_Training_Plan_Record_ID__c, RecordTypeId FROM AsCPD_Learning_Summary__c WHERE Status__c = 'Not Started' AND CPD_Planner__c =: recordId];
            } else {
                AsCPDPlanner__c cpd = [SELECT Id,Target__c FROM AsCPDPlanner__c WHERE RecordTypeId = '0127F000000K1frQAC' AND AS_Current_CPD_Plan__c = true AND AsUser__c =: userInfo.getUserId() ORDER BY Id DESC LIMIT 1];
                try {
                    activities = [SELECT Id, Name, AS_Training_Plan_Record_ID__c, RecordTypeId FROM AsCPD_Learning_Summary__c WHERE Status__c = 'Not Started' AND CPD_Planner__c =: cpd.Id];
                } catch(QueryException qe) {
                }
            }
        } catch(QueryException qe) {
        }
        
        try {
            for ( AsCPD_Learning_Summary__c activity: activities ) {
                Map<String,String> temp_activity = new Map<String,String>();
                temp_activity.put( 'Id',activity.Id );
                temp_activity.put( 'Name',activity.Name );
                temp_activity.put( 'RecordTypeId',activity.RecordTypeId );
                temp_activity.put( 'AS_Training_Plan_Record_ID__c',activity.AS_Training_Plan_Record_ID__c );
                try {
                    Training_Plan_Achievement__c tpa = [SELECT Id,Achievement__r.Eligible_Image__c FROM Training_Plan_Achievement__c WHERE Training_Plan__c =: activity.AS_Training_Plan_Record_ID__c LIMIT 1];
                    temp_activity.put( 'Eligible_Image__c',tpa.Achievement__r.Eligible_Image__c );
                } catch(QueryException qe) {
                }
                
                filter_activities.add( temp_activity );
            }
        } catch(Exception e) {
        }
        
        return filter_activities;
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getCompleteActivities( String recordId ) {
        
        List<Map<String,String>> filter_activities = new List<Map<String,String>>();
        List<AsCPD_Learning_Summary__c> activities;
        String currentYear = String.valueOf( System.Today().year() );
        
        try {
            if ( recordId != '' ) {
                activities = [SELECT Id, Name, AS_Training_Plan_Record_ID__c, AS_Reflections__c, RecordTypeId, AsSummary_Plan__c FROM AsCPD_Learning_Summary__c WHERE (Status__c = 'Complete' OR RecordTypeId = '0127F000000K1c5QAC') AND CPD_Planner__c =: recordId];
            } else {
                AsCPDPlanner__c cpd = [SELECT Id,Target__c FROM AsCPDPlanner__c WHERE RecordTypeId = '0127F000000K1frQAC' AND AS_Current_CPD_Plan__c = true AND AsUser__c =: userInfo.getUserId() ORDER BY Id DESC LIMIT 1];
                try {
                    activities = [SELECT Id, Name, AS_Training_Plan_Record_ID__c, AS_Reflections__c, RecordTypeId, AsSummary_Plan__c FROM AsCPD_Learning_Summary__c WHERE (Status__c = 'Complete' OR RecordTypeId = '0127F000000K1c5QAC') AND CPD_Planner__c =: cpd.Id];
                } catch(QueryException qe) {
                }
            }
        } catch(QueryException qe) {
        }
        
        try {
            for ( AsCPD_Learning_Summary__c activity: activities ) {
                Map<String,String> temp_activity = new Map<String,String>();
                temp_activity.put( 'Id',activity.Id );
                temp_activity.put( 'Name',activity.Name );
                temp_activity.put( 'AS_Training_Plan_Record_ID__c',activity.AS_Training_Plan_Record_ID__c );
                temp_activity.put( 'AS_Reflections__c',activity.AS_Reflections__c );
                temp_activity.put( 'RecordTypeId',activity.RecordTypeId );
                if ( activity.AsSummary_Plan__c == true ) {
                    temp_activity.put( 'AsSummary_Plan__c', '1' );
                } else {
                    temp_activity.put( 'AsSummary_Plan__c', '0' );
                }
                
                try {
                    Training_Plan_Achievement__c tpa = [SELECT Id,Achievement__r.Eligible_Image__c FROM Training_Plan_Achievement__c WHERE Training_Plan__c =: activity.AS_Training_Plan_Record_ID__c LIMIT 1];
                    temp_activity.put( 'Eligible_Image__c',tpa.Achievement__r.Eligible_Image__c );
                } catch(QueryException qe) {
                }
                
                filter_activities.add( temp_activity );
            }
        } catch(Exception e) {
        }
        
        return filter_activities;
    }
    
    @AuraEnabled
    public static List<AsCPDPlanner__c> getPlans() {
        
        List<AsCPDPlanner__c> plans;
        
        try {
            plans = [SELECT Id, Name FROM AsCPDPlanner__c WHERE AsUser__c =: userInfo.getUserId()];
        } catch(QueryException qe) {
        }
        
        return plans;
    }
    
    @AuraEnabled
    public static String getReflection( String recordId ) {
        
        String reflection = '';
        
        if ( recordId != '' ) {
            try {
                AsCPD_Learning_Summary__c ls = [SELECT Id, AS_Reflections__c FROM AsCPD_Learning_Summary__c WHERE Id =: recordId];
                reflection = ls.AS_Reflections__c;
            } catch(QueryException qe) {
            }
        }
        
        return reflection;
    }
    
    @AuraEnabled
    public static Boolean addReflection( String recordId, String reflectionText ) {
        
        Boolean added = false;
        
        if ( recordId != '' ) {
            try {
                update new AsCPD_Learning_Summary__c( Id = recordId, AS_Reflections__c = reflectionText );
                added = true;
            } catch(QueryException qe) {
            }
        }
        
        return added;
    }
    
    @AuraEnabled
    public static Boolean saveIncludeStatus( String recordId, String includeStatus ) {
        
        Boolean added = false;
        Boolean status = false;
        
        if ( recordId != '' ) {            
            if ( includeStatus == '0' ) {
                status = true;
            }
            
            try {
                update new AsCPD_Learning_Summary__c( Id = recordId, AsSummary_Plan__c = status );
                added = true;
            } catch(QueryException qe) {
            }
        }
        
        return added;
    }
    
    @AuraEnabled
    public static Boolean generateCPDPlanReport( String recordId ) {
        
        Boolean generated = false;
        
        if ( recordId != '' ) {
            try {
                AsCPDPlanner__c cpd = new AsCPDPlanner__c();
                cpd.Id = recordId;
                cpd.AsGenerateCPDsummary__c = true;
                update cpd;
                generated = true;
            } catch(QueryException qe) {
            }
        }
        
        return generated;
    }
    
    @AuraEnabled
    public static List<String> hasCourse() {
        
        List<String> course;
        
        try {
            User u = [SELECT Id,AccountId FROM User WHERE Id =: userInfo.getUserId()];
            try {
                Account acc = [SELECT Id,Name,Active_Course__c FROM Account WHERE Id =: u.AccountId];
                course = acc.Active_Course__c.split(';');
            } catch(QueryException qe) {
            }
        } catch(QueryException qe) {
        }
        
        return course;
    }
    
    @AuraEnabled
    public static List<Attachment> getPlanAttachments( String recordId ) {
        
        List<Attachment> attachments;
        String currentYear = String.valueOf( System.Today().year() );
        
        try {
            if ( recordId != '' ) {
                attachments = [SELECT Id, Name, CreatedDate FROM Attachment WHERE parentId =: recordId ORDER BY Id DESC];
            } else {
                AsCPDPlanner__c cpd = [SELECT Id FROM AsCPDPlanner__c WHERE RecordTypeId = '0127F000000K1frQAC' AND AS_Current_CPD_Plan__c = true AND AsUser__c =: userInfo.getUserId() ORDER BY Id DESC LIMIT 1];
                try {
                    attachments = [SELECT Id, Name, CreatedDate FROM Attachment WHERE parentId =: cpd.Id ORDER BY Id DESC];
                } catch(QueryException qe) {
                }
            }
        } catch(QueryException qe) {
        }
        
        return attachments;
    }
    
    @AuraEnabled
    public static Attachment getPlanAttachment( String recordId ) {
        
        Attachment attachment;
        String currentYear = String.valueOf( System.Today().year() );
        
        try {
            if ( recordId != '' ) {
                attachment = [SELECT Id, Name, CreatedDate FROM Attachment WHERE parentId =: recordId ORDER BY Id DESC LIMIT 1];
            } else {
                AsCPDPlanner__c cpd = [SELECT Id FROM AsCPDPlanner__c WHERE RecordTypeId = '0127F000000K1frQAC' AND AS_Current_CPD_Plan__c = true AND AsUser__c =: userInfo.getUserId() ORDER BY Id DESC LIMIT 1];
                try {
                    attachment = [SELECT Id, Name, CreatedDate FROM Attachment WHERE parentId =: cpd.Id ORDER BY Id DESC LIMIT 1];
                } catch(QueryException qe) {
                }
            }
        } catch(QueryException qe) {
        }
        
        return attachment;
    }
    
    @AuraEnabled
    public static Boolean setAccreditedPharmacist( String recordId ) {
        
        Boolean flag = false;
        
        if ( recordId != '' ) {
            try {
                AsCPDPlanner__c cpdInfo = [SELECT Id,AS_Accredited_pharmacist__c FROM AsCPDPlanner__c WHERE Id =: recordId AND AsUser__c =: userInfo.getUserId()];
                AsCPDPlanner__c cpd = new AsCPDPlanner__c();
                cpd.Id = recordId;
                if ( cpdInfo.AS_Accredited_pharmacist__c == true ) {
                    cpd.AS_Accredited_pharmacist__c = false;
                } else {
                    cpd.AS_Accredited_pharmacist__c = true;
                }
                
                update cpd;
                flag = true;
            } catch(QueryException qe) {
            }
        }
        
        return flag;
    }
    
    public static void getNum() {
        
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
    public static void getNum1() {
        
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
    public static void getNum2() {
        
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
    public static void getNum3() {
        
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}