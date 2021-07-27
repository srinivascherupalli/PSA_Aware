public class AS_HelperClass {
    
    /** MLO
    * used in "TrainingPlanPreviewController.apxc"
    * Create Opportunity : RT: Education, Prospecting
    * tPlan: Paid 
    */
    //This will uncomment when deploying the RTO Feature
    // public static Opportunity TrainingPlanRegisterHelper(Id userId, Id tPlanProduct){
    //     try{
    //         User usr = [SELECT Id, Name,
    //                         ContactId,
    //                         Contact.Name, 
    //                         Contact.Account.AS_Salesforce_ID__c,
    //                         ProfileId, 
    //                         Profile.Name 
    //                     FROM User 
    //                     WHERE Id =: userId];
    //         System.debug('usr : ' + usr);
    //         Id rt = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Education').getRecordTypeId();
            
    //         Opportunity opp     = new Opportunity();
    //         opp.Name            = usr.Name + ' - Education';
    //         opp.RecordTypeId    = rt;
    //         opp.StageName       = 'Prospecting';
    //         opp.CloseDate       = date.today();
    //         opp.AccountId       = usr.Contact.Account.AS_Salesforce_ID__c;
    //         opp.AS_Product__c   = tPlanProduct;
    //         opp.AS_Add_Products__c = true;
    //         opp.AS_Generate_Order_Without_Invoice__c = true;
            
            
    //         //System.debug('opp :' + opp);
    //         List<PricebookEntry> pbe_list = new List<PricebookEntry>([SELECT Id, 
    //                                                                       Product2Id, 
    //                                                                       UnitPrice, 
    //                                                                       PriceBook2Id, 
    //                                                                       PriceBook2.IsStandard,
    //                                                                       PriceBook2.IsActive,
    //                                                                       PriceBook2.Name
    //                                                                   FROM PricebookEntry 
    //                                                                   WHERE Product2Id =: tPlanProduct
    //                                                                   AND PriceBook2.IsActive =: TRUE
    //                                                                   AND (PriceBook2.Name =: 'PSA Non-Member'
    //                                                                        OR PriceBook2.Name =: 'PSA Member')]);
            
    //         System.debug('pbe_list :' + pbe_list);
    //         if(pbe_list.size() > 0){
    //             List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();

    //             for(PricebookEntry pbe : pbe_list){
    //                 /*
    //                 OpportunityLineItem oli = new OpportunityLineItem();
    //                 oli.OpportunityId       = opp.id;
    //                 oli.Quantity            = 1;
    //                 oli.UnitPrice           = pbe.UnitPrice;
    //                 */
    //                 System.debug('pbe.PriceBook2.Name :' + pbe.PriceBook2.Name);
    //                 if(usr.Profile.Name == 'Member Login User'){
    //                 	System.debug('Member Login User 1');
    //                     if(pbe.PriceBook2.Name == 'PSA Member') {
    //                      //   oli.PricebookEntryId = pbe.id;
    //                      	opp.PriceBook2Id = pbe.PriceBook2Id;
    //                      	opp.AS_Product_Price__c = pbe.UnitPrice;
    //                     }
    //                 }else if(usr.Profile.Name == 'Non Member Login User'){
    //                 		System.debug('Non Member Login User 2');
    //                     if(pbe.PriceBook2.Name == 'PSA Non-Member') {
    //                     	// oli.PricebookEntryId = pbe.id;
    //                     	opp.PriceBook2Id = pbe.PriceBook2Id;
    //                     	opp.AS_Product_Price__c = pbe.UnitPrice;
    //                     }
    //                 }else if(usr.Profile.Name == 'System Administrator'){
    //                 	System.debug('System Member Login User 3');
    //                    // oli.PricebookEntryId = pbe.id;
    //                    opp.PriceBook2Id = pbe.PriceBook2Id;
    //                    opp.AS_Product_Price__c = pbe.UnitPrice;
    //                 }
    //                 /*
    //                 System.debug('*** oli: ' + oli);
    //                 if(oli.PricebookEntryId != null){
    //                     oliList.add(oli);
    //                     break;
    //                 }
    //                 */
    //                 System.debug('opp.PriceBook2Id : ' + opp.PriceBook2Id); 
    //                 if(opp.PriceBook2Id != null){
    //                     break;
    //                 }
    //             }
    //            // System.debug('oliList : ' + oliList.size() + oliList);
    //           //  if(oliList.size() > 0) insert oliList;
                
                
    //         }
    //         System.debug('final opp 1: ' + opp);
    //         System.debug('opp.PriceBook2Id: ' + opp.PriceBook2Id);
    //         if(opp.PriceBook2Id != null) {
    //         	insert opp;
    //         	System.debug('final opp 2: ' + opp);
    //         	return opp;
    //         } else {
    //         	return null;
    //         }
            
    //     }catch(Exception e){
    //             System.debug('Exception :' + e);
    //         LMSUtils.addErrorMessage(e.getStackTraceString());
    //         return null;
    //     }
    // }
    

    
    public static Opportunity TrainingPlanRegisterHelper(Id userId, Id tPlanProduct, String campId){
        try{
            User usr = [SELECT Id, Name,
                        ContactId,
                        Contact.Name,
                        Contact.Account.AS_Salesforce_ID__c,  
                        ProfileId, 
                        Profile.Name 
                        FROM User 
                        WHERE Id =: userId];
           
           
            System.debug('usr : ' + usr);
            Id rt = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Education').getRecordTypeId();
            
            
            Opportunity opp     = new Opportunity();
            opp.Name            = usr.Name + ' - Education';
            opp.RecordTypeId    = rt;
            opp.StageName       = 'Prospecting';
            opp.CloseDate       = date.today();
            opp.AccountId       = usr.Contact.Account.AS_Salesforce_ID__c;
            opp.AS_Product__c   = tPlanProduct;
            opp.AS_Add_Products__c = true;
            opp.AS_Generate_Order_Without_Invoice__c = true;
            opp.CampaignId__c = campId;
            
            //System.debug('opp :' + opp);
            List<PricebookEntry> pbe_list = new List<PricebookEntry>([SELECT Id, 
                                                                      Product2Id, 
                                                                      UnitPrice, 
                                                                      PriceBook2Id, 
                                                                      PriceBook2.IsStandard,
                                                                      PriceBook2.IsActive,
                                                                      PriceBook2.Name
                                                                      FROM PricebookEntry 
                                                                      WHERE Product2Id =: tPlanProduct
                                                                      AND PriceBook2.IsActive =: TRUE
                                                                      AND (PriceBook2.Name =: 'PSA Non-Member'
                                                                           OR PriceBook2.Name =: 'PSA Member')]);
            
            System.debug('pbe_list :' + pbe_list);
            if(pbe_list.size() > 0){
                List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                
                for(PricebookEntry pbe : pbe_list){
                    /*
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.OpportunityId       = opp.id;
                    oli.Quantity            = 1;
                    oli.UnitPrice           = pbe.UnitPrice;
                    */
                    System.debug('pbe.PriceBook2.Name :' + pbe.PriceBook2.Name);
                    if(usr.Profile.Name == 'Member Login User'){
                        System.debug('Member Login User 1');
                        if(pbe.PriceBook2.Name == 'PSA Member') {
                            //   oli.PricebookEntryId = pbe.id;
                            opp.PriceBook2Id = pbe.PriceBook2Id;
                            opp.AS_Product_Price__c = pbe.UnitPrice;
                        }
                    }else if(usr.Profile.Name == 'Non Member Login User'){
                        System.debug('Non Member Login User 2');
                        if(pbe.PriceBook2.Name == 'PSA Non-Member') {
                            // oli.PricebookEntryId = pbe.id;
                            opp.PriceBook2Id = pbe.PriceBook2Id;
                            opp.AS_Product_Price__c = pbe.UnitPrice;
                        }
                    }else if(usr.Profile.Name == 'System Administrator'){
                        System.debug('System Member Login User 3');
                        // oli.PricebookEntryId = pbe.id;
                        opp.PriceBook2Id = pbe.PriceBook2Id;
                        opp.AS_Product_Price__c = pbe.UnitPrice;
                    }
                    
                    if(opp.PriceBook2Id != null){
                        break;
                    }
                }
                
            }
            if(opp.PriceBook2Id != null) {
                insert opp;
                return opp;
            } else {
                return null;
            }
            
        }catch(Exception e){
            System.debug('Exception :' + e);
            LMSUtils.addErrorMessage(e.getStackTraceString());
            return null;
        }
    }
    
    /** MLO
    * used in "TrainingPlanPreviewController.apxc"
    * check User Profile : Non Member Login User
    */
    public static Boolean TrainingPlanPreviewValidation(Id userId){
        
        if(userId != null){
            User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id =: userId];
            if(currentUser.Profile.Name == 'Non Member Login User') return false;
        }
        return true;
        
    }
    
    /** MLO
    * used in "TrainingPlanPreviewController.apxc"
     * check User Profile : Non Member Login User
    */ 
    public static Boolean isUserMember(Id userId){
        boolean isMember = false;
        if(userId != null){
            User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id =: userId];
            if(currentUser.Profile.Name == 'Member Login User' ){
                isMember = true;
            }
        }
        return isMember;
    } 
    
    /** MLO
    * used in "AS_Learning_Trigger.apxt"
    * Learning.Unlock_Training_Plan__c = true
    */
    public static void UpdateRequestApproveHelper(Map<Id, Learning__c> newMapLearning, Set<Id> userIds, Id trainingPlanId, Id communityId){
        Set<Id> tpsId = new Set<Id>();
        
        if(newMapLearning.size() > 0){
            List<Training_Plan_Section_Item__c> TPSList = [SELECT Training_Plan_Section__r.Training_Plan__c FROM Training_Plan_Section_Item__c where Learning__c =: newMapLearning.keySet()];
            
            if(TPSList.size() > 0){
                for(Training_Plan_Section_Item__c tps : TPSList){
                    tpsId.add(tps.Training_Plan_Section__r.Training_Plan__c); 
                }
            }            
        }
        
        if(trainingPlanId != null) tpsId.add(trainingPlanId);
        
        if(tpsId.size() > 0){
            List<Training_Plan_Access_Request__c> tparList = [Select Status__c, 
                                                              Training_Plan__c,
                                                              User__c 
                                                              From  Training_Plan_Access_Request__c 
                                                              Where Training_Plan__c IN: tpsId
                                                              And Status__c !=: 'Approved'];
            
            for(Training_Plan_Access_Request__c tpar : tparList){
                tpar.Status__c = 'Approved';
            }
            
            update tparList;
        }
    }
    
    /** MLO
    * used in "LearningAssignmentTrigger.apxt"
    * CPD Points from LearningAssignment to TrainingPlanAssignment
    */
    public static void LearningAssignmentTriggerHelper(List<Learning_Assignment__c> assignments){
        if(assignments.size() > 0){
            Set<Id> tpsa = new Set<Id>();
            
            for(Learning_Assignment__c la : assignments){
                tpsa.add(la.Training_Plan_Section_Assignment__c);
            }
            
            if(tpsa.size() > 0){
                List<Learning_Assignment__c> lrnAsgnList = [SELECT Id,
                                                            AS_Group_1_CPD__c,
                                                            AS_Group_2_CPD__c,
                                                            Training_Plan_Section_Assignment__r.Training_Plan_Assignment__c
                                                            FROM Learning_Assignment__c
                                                            WHERE Training_Plan_Section_Assignment__c IN : tpsa];
                
                if(lrnAsgnList.size() > 0){
                    Decimal cpd1 = 0, cpd2 = 0;
                    Id tPlanAsgnId;
                    
                    for(Learning_Assignment__c la : lrnAsgnList){
                        cpd1 += (la.AS_Group_1_CPD__c != null ? la.AS_Group_1_CPD__c : 0);
                        cpd2 += (la.AS_Group_2_CPD__c != null ? la.AS_Group_2_CPD__c : 0);
                        tPlanAsgnId = la.Training_Plan_Section_Assignment__r.Training_Plan_Assignment__c;
                    }
                    
                    if(tPlanAsgnId != null){
                        Training_Plan_Assignment__c tPlan = new Training_Plan_Assignment__c();
                        tPlan.Id = tPlanAsgnId;
                        tPlan.AS_Group_1_CPD_Achieved__c = cpd1;
                        tPlan.AS_Group_2_CPD_Achieved__c = cpd2;
                        update tPlan;
                    }
                }
            }
        }
    }
    
    /** MLO
    *  On VF Page TrainingPlanDetail --> Launch Learning button 
    *  LEARNING recordType = EVENT
    *  Redirect to Eventbrite
    */
    ///dead///
    public static PageReference LearningEventRecType(String currentRecordType, String campaignEventURL){
        if(currentRecordType == 'Event') return new PageReference(campaignEventURL);
        return null;
    }
    
    /** MLO
    *  used in "TrainingPlanPreviewController.apxc"
    *  On CampaignMember trigger
    *  from TrainingPlan.Type == Event
    * Updated by : John Hope (#PSA-179)
    */
    public static void CampaignMemberTriggerHelper(List<CampaignMember> campaignMember){
        System.debug('campaignMember for training plan assignment');
        if(campaignMember.size() > 0){
            Set<Id> campaignMemberIds = new Set<Id>(new Map<Id, CampaignMember>(campaignMember).keySet());
            Map<Id,Set<Id>> allTrainPlanMap = new Map<Id,Set<Id>>();
            List<CampaignMember> cmList = [SELECT 
                                           Id, 
                                           ContactId, 
                                           Campaign.Training_Plan__c,
                                           Campaign.Training_Plan__r.Id,
                                           Learning__c,
                                           Campaign.Learning__c
                                           FROM 
                                           CampaignMember
                                           WHERE 
                                           Id =: campaignMemberIds
                                           AND 
                                           ContactId != null
                                           AND
                                           (
                                               Campaign.Training_Plan__c != null
                                               OR
                                               Campaign.Learning__c != null
                                           )
                                           AND Status =: 'Attending'
                                          ];
            System.debug('cmList : ' + cmList);
            //collect contact ids
            Set<Id> contactId = new Set<Id>();
            for(CampaignMember cm : cmList){
                contactId.add(cm.ContactId);
            }
            System.debug('contactId : ' + contactId);
            if(contactId.size() > 0) {
                //get all users with User.ContactId IN CampaignMember.ContactId
                Map<Id,Id> allConUserMap = new Map<Id,Id>();
                for(User theUser:[SELECT  
                                  ContactId,
                                  Id
                                  FROM 
                                  User 
                                  WHERE 
                                  ContactId IN: contactId
                                 ]) {
                                     allConUserMap.put(theUser.ContactId,theUser.Id);
                                 }
                System.debug('allConUserMap : ' + allConUserMap);
                List<Learning_Assignment__c> allNewLearnAssList = new List<Learning_Assignment__c>();
                for(CampaignMember mem : cmList) {
                    Id finalUserId = allConUserMap.get(mem.ContactId);
                    System.debug('finalUserId : ' + finalUserId);
                    if(mem.Campaign.Training_Plan__c != null) {
                        if(allTrainPlanMap.containsKey(mem.Campaign.Training_Plan__c)) {
                            System.debug('1 finalUserId : ' + finalUserId);
                            allTrainPlanMap.get(mem.Campaign.Training_Plan__c).add(finalUserId);
                        }	else {
                            System.debug('2 finalUserId : ' + finalUserId);
                            allTrainPlanMap.put(mem.Campaign.Training_Plan__c,new Set<Id>{finalUserId});
                             
                        }
                    } else if(mem.Campaign.Learning__c != null) { 
                        /*
                        // for adding new learning assignment
                        Learning_Assignment__c indiNewLearnAssList = new Learning_Assignment__c();
                        indiNewLearnAssList.User__c = finalUserId;
                        indiNewLearnAssList.Contact = mem.ContactId;
                        indiNewLearnAssList.Training_Plan__c = 
                        indiNewLearnAssList.Learning = mem.Campaign.Learning__c;
                        
                        indiNewLearnAssList.LMS_Instance__c = finalUserId;
                        */
                    }
                }
                System.debug('allTrainPlanMap : ' + allTrainPlanMap);
                if(allTrainPlanMap.size() > 0) {
                    for(Id trainPlan : allTrainPlanMap.keySet()) { 
                       Map<Id,List<Learning_Assignment__c>> LearnAssMap =  LMSService.upsertAssignments(allTrainPlanMap.get(trainPlan), trainPlan, LMSUtils.getCurrentNetworkId());
                    } 
                } 
                
            }                 	 		
            
        }
    }
    
    /** ================ MOODLE ================ **/
    
    /** MLO
    * used in "AS_Learning_Trigger.apxt"
    * on create LEARNING, sync to custom objects
    * LMS Course
    * update LEARNING 
    */
    public static Id LMS_Integration_Learning(List<Learning__c> learning, String trgEvent){
        if(trgEvent == 'before'){
            System.debug('learning***: ' + learning[0].LMS_Course__c);
            //added learning[0].AS_LMS_type__c != 'Activity'; in ticket PRI 41
            if(learning[0].LMS_Instance__c != null && learning[0].AS_LMS_type__c != 'Activity'){
                LMS_Course__c lc    = new LMS_Course__c();
                lc.Name             = learning[0].Name;
                lc.Date__c          = date.today();
                lc.Description__c   = learning[0].Description__c;
                lc.Status__c        = 'Active';
                lc.LMS_Instance__c  = learning[0].LMS_Instance__c;
                
                if(learning[0].LMS_Course__c == null){
                    insert lc;
                    return lc.Id;
                }else return learning[0].LMS_Course__c;/*else if(trgEvent == 'after'){
                    System.debug('id*** '+ learning[0].LMS_Course__c);
                    lc.Id = learning[0].LMS_Course__c;
                    update lc;
                    return learning[0].LMS_Course__c;
                    }*/
            }
        }
        
        return null;
    }

 
    
    
    
    
    /** MLO
    * used in "LearningAssigmentTrigger.apxt"
    * Create LMS Course Enrolment
    * Create LMS User (moodle team)
    * Updated by John as of 7/13/2018 for(#PSABG-45)
    */
    public static Id LMS_Integration_LearningAssignment(List<Learning_Assignment__c> lrnAsgn, String trgEvent){
        if(trgEvent == 'after insert'){
            List<User> usr = [SELECT Id,
                              FirstName,
                              LastName,  
                              Email,
                              ContactId,
                              LMS_Instance__c, 
                              LMS_User__c 
                              FROM User 
                              WHERE Id =: lrnAsgn[0].User__c];
            
            if(usr.size() > 0){
                List<LMS_User__c> lmsUsr = [SELECT Id FROM LMS_User__c
                                            WHERE FirstName__c =: usr[0].FirstName
                                            AND LastName__c =: usr[0].LastName
                                            AND Email__c =: usr[0].Email];
                
                Id lmsUsrId;
                
                if(lmsUsr.size() <= 0){
                    LMS_User__c lu      = new LMS_User__c();
                    lu.FirstName__c     = usr[0].FirstName;
                    lu.LastName__c      = usr[0].LastName;
                    lu.Email__c         = usr[0].Email;
                    lu.Status__c        = 'Active';
                    lu.LMS_Instance__c  = lrnAsgn[0].LMS_Instance__c;
                    lu.AS_Banner_Group_Contact__c = usr[0].ContactId;
                    insert lu;
                    
                    lmsUsrId = lu.Id;                
                }else lmsUsrId = lmsUsr[0].Id;
                
                
                List<Learning__c> learning = [SELECT Id, 
                                              LMS_Course__c, 
                                              LMS_Instance__c 
                                              FROM Learning__c 
                                              WHERE Id =: lrnAsgn[0].Learning__c];
                
                if(learning.size() > 0){
                    LMS_Course_Enrolment__c lce = new LMS_Course_Enrolment__c();
                    lce.Description__c          = '';
                    lce.Start_Date__c           = null;
                    lce.End_Date__c             = null;
                    lce.Completion_Status__c    = null;
                    lce.LMS_Course__c           = learning[0].LMS_Course__c != null ? learning[0].LMS_Course__c : null;//learningAsgn__r.Learning__c.LMS_Course;
                    lce.LMS_Instance__c         = lrnAsgn[0].LMS_Instance__c != null ? lrnAsgn[0].LMS_Instance__c : 
                    learning[0].LMS_Instance__c != null ? learning[0].LMS_Instance__c : null;//learningAsgn__r.Learning__c.LMS_Instance__c;
                    lce.LMS_User__c             = lmsUsrId != null ? lmsUsrId : null;//learningAsgn__r.User__c.LMS_User__c;
                    
                    if(lrnAsgn[0].LMS_Course_Enrolment__c == null){
                        
                        if(lce.LMS_Instance__c != null) insert lce;
                        
                    }else{
                        lce.Id = lrnAsgn[0].LMS_Course_Enrolment__c;
                        update lce;
                    } 
                    
                    if(!Test.isRunningTest()){
                        usr[0].LMS_User__c     = (usr[0].LMS_User__c != null ? usr[0].LMS_User__c : lmsUsrId);
                        usr[0].LMS_Instance__c = (usr[0].LMS_Instance__c != null ? usr[0].LMS_Instance__c : lce.LMS_Instance__c != null ? lce.LMS_Instance__c : null);
                        update usr[0];
                    }
                    
                    Learning_Assignment__c la   = new Learning_Assignment__c();
                    la.Id                       = lrnAsgn[0].Id;
                    la.LMS_Course_Enrolment__c  = lce.Id;
                    update la;
                    
                    return lce.Id;
                }
            }
        }
        
        return null;
    }

        /*
    * Author : john hope
    * Description: method to check data before createLmsCourseEnrollment (#PSABG-45)
    * Parameter : None
    * Return : None
    */
    public void createLmsCourseEnrollmentChecker(Learning_Assignment__c[] LearningAssData, Map<Id,Learning_Assignment__c> oldMap, Map<Id,Learning_Assignment__c> newMap,String action) {
        List<Learning_Assignment__c> tobeProcessed = new List<Learning_Assignment__c>();
        Set<Id> trainPlanSecAssIdSet = new Set<Id>();
        for(Learning_Assignment__c enroll : LearningAssData) {
            if(enroll.Contact__c != null && enroll.Learning__c != null) {
                system.debug(' Solod debug 1 ');
                if( action == 'INSERT' || (action == 'UPDATE' && oldMap.get(enroll.Id).Contact__c != newMap.get(enroll.Id).Contact__c) ) {
                    System.debug('checker : ' + 2);
                    tobeProcessed.add(enroll);
                }
            }
            // added for ticket #PSA-96 as of 7-25-2018
            if(enroll.Training_Plan_Section_Assignment__c != null) {
               	system.debug(' Solod debug 2 ');
                if(action == 'INSERT' || (action == 'UPDATE' && ((oldMap.get(enroll.Id).AS_Group_1_CPD__c != newMap.get(enroll.Id).AS_Group_1_CPD__c) || oldMap.get(enroll.Id).AS_Group_2_CPD__c != newMap.get(enroll.Id).AS_Group_2_CPD__c)) ) {
                    trainPlanSecAssIdSet.add(enroll.Training_Plan_Section_Assignment__c); 
                }
            }
        }
        if(tobeProcessed.size() > 0) {
            createLmsCourseEnrollment(tobeProcessed);
        }
        
        if(trainPlanSecAssIdSet.size() > 0) {
            rollUpLearnAssCPDinTrainPlanAss(trainPlanSecAssIdSet);
        }
    }  

    /*
    * Author : John Hope
    * Description: method to will roll up of learning assignment cpd and put the data to the training plan assignments(##PSA-96)
    * Last Updated by:John Hope
    * Parameter : 0. Set = Set of training plan section assignments
    * Return : None
    */
    public void rollUpLearnAssCPDinTrainPlanAss(Set<Id> trainPlanSecAssId ){
        Set<Id> allTrainPlanAssIdSet = new Set<Id>();
        for(Training_Plan_Section_Assignment__c trainPlanSecAss : [Select 
                                                                   id,
                                                                   Training_Plan_Assignment__c
                                                                   from 
                                                                   Training_Plan_Section_Assignment__c
                                                                    where
                                                                   Id IN :trainPlanSecAssId
                                                                  ]) {
                                                                      if(trainPlanSecAss.Training_Plan_Assignment__c != null) {
                                                                          allTrainPlanAssIdSet.add(trainPlanSecAss.Training_Plan_Assignment__c);
                                                                      }
                                                                  }
        List<Training_Plan_Assignment__c> allTobeUpdatedTrainPlanAssList = new List<Training_Plan_Assignment__c>();
        for(AggregateResult agg : [Select 
                                   Training_Plan_Section_Assignment__r.Training_Plan_Assignment__c assign,
                                   SUM(AS_Group_1_CPD__c) group1,
                                   SUM(AS_Group_2_CPD__c) group2
                                   from 
                                   Learning_Assignment__c 
                                   where 
                                   Training_Plan_Section_Assignment__r.Training_Plan_Assignment__c IN :allTrainPlanAssIdSet
                                   group by 
                                   Training_Plan_Section_Assignment__r.Training_Plan_Assignment__c
                                  ]) {
                                      Training_Plan_Assignment__c inditobeUpdatedTrainPlanAssList = new Training_Plan_Assignment__c();
                                      inditobeUpdatedTrainPlanAssList.Id = (Id) agg.get('assign');
                                      inditobeUpdatedTrainPlanAssList.AS_Group_1_CPD_Achieved__c = (Decimal) agg.get('group1');
                                      inditobeUpdatedTrainPlanAssList.AS_Group_2_CPD_Achieved__c = (Decimal) agg.get('group2');
                                      allTobeUpdatedTrainPlanAssList.add(inditobeUpdatedTrainPlanAssList);
                                  }
        
        if(allTobeUpdatedTrainPlanAssList.size() > 0 ) {
            update allTobeUpdatedTrainPlanAssList;
        }
    }

    /*
    * Author : John Hope
    * Description: method to will create Lms Course Enrolment (#PSABG-45)
    * Last Updated by:John Hope
    * Parameter : 0. List = list of Learning_Assignment__c
    * Return : None
    */
    /*Updated functionaliy in ticket PRI- 69 BY VINCENT */  
    //Last Updated by: Michael Vincent Largo
  public void createLmsCourseEnrollment(Learning_Assignment__c[] newRecords ){
      
    if(runOnceUpdateLeaAssEnroll()) {
        
        Set<Id> allEnrollees = new Set<Id>();
        Set<Id> allLMSInstance = new Set<Id>();
        Set<Id> allLearningId = new Set<Id>();
        Set<Id> allTplanId = new Set<Id>();
        Set<Id> allTplanSecId = new Set<Id>();
        
        list< Learning_Assignment__c > learnAssCheckDuplicate = new list< Learning_Assignment__c >();
        
        for(Learning_Assignment__c enroll : newRecords) {
            if(enroll.Contact__c != null) {
                allEnrollees.add(enroll.Contact__c);
            }
            if(enroll.Learning__c != null) {
                allLearningId.add(enroll.Learning__c);
                learnAssCheckDuplicate.add( enroll );  
            }
            if (enroll.Training_Plan_Section_Assignment__c !=null){
                allTplanSecId.add(enroll.Training_Plan_Section_Assignment__c);
            }
        }
        
        //system.debug('allTplanSecId==>' + allTplanSecId);
        
        map<Id,Contact> ContactMap = new map<Id,Contact>();
        if(allEnrollees.size() > 0) {
            for(Contact con : [Select Id,FirstName,LastName,Email from Contact where Id IN :allEnrollees]){
                ContactMap.put(con.Id, con);
            }
        }
        
        map<Id,Learning__c> LearningMap = new map<Id,Learning__c>();
        Id MoodleRecordtypeId = Schema.SObjectType.Learning__c.getRecordTypeInfosByDeveloperName().get('Moodle').getRecordTypeId();
        
        for( Learning__c  learn : [SELECT
                                   Id,
                                   LMS_Instance__c,
                                   LMS_Course__c,
                                   AS_LMS_type__c,
                                   AS_Activity_Type__c,
                                   RecordTypeId,
                                   RecordType.Name,
                                   AS_Training_Plan__r.AS_LMS_Course__c,
                                   AS_LMS_Activity__c,
                                   AS_Training_Plan__c,
                                   Name 
                                   FROM 
                                   Learning__c 
                                   WHERE 
                                   Id in:allLearningId
                                  ] ) {
                                      LearningMap.put( learn.Id , learn );
                                      allLMSInstance.add(learn.LMS_Instance__c);
                                  }

        System.debug('LearningMap==> : ' + LearningMap);                  
        
        Map<String,LMS_User__c> lmsUserMap = new Map<String,LMS_User__c>();
        Map<String,String> tobeAddedlmsUserMap = new Map<String,String>();
        Map<Id,LMS_User__c> lmsUserIdsMap = new Map<Id,LMS_User__c>();
        for(LMS_User__c lmsUser : [Select Id,Name,AS_Banner_Group_Contact__c,LMS_Instance__c from LMS_User__c where AS_Banner_Group_Contact__c IN :allEnrollees AND LMS_Instance__c IN :allLMSInstance]) {
            if(lmsUser.AS_Banner_Group_Contact__c !=null && lmsUser.LMS_Instance__c !=null) {
                String keyStr = String.valueOf(lmsUser.AS_Banner_Group_Contact__c).toLowercase()+String.valueOf(lmsUser.LMS_Instance__c).toLowercase();
                lmsUserMap.put(keyStr,lmsUser);
				lmsUserIdsMap.put(lmsUser.AS_Banner_Group_Contact__c, lmsUser);
            }
        }

        System.debug('lmsUserMap===> :'+lmsUserMap);
        System.debug('lmsUserIdsMap===> :'+lmsUserIdsMap);

        List<Learning_Assignment__c> allTobeUpdateLeaAssEn = new List<Learning_Assignment__c>();
        list<LMS_Course_Enrolment__c> allCourseEnList = new list< LMS_Course_Enrolment__c >();
        list<LMS_Activity_Enrolment__c> allActivityEnList = new list<LMS_Activity_Enrolment__c>();
        List<LMS_User__c> allNewLMSUser = new List<LMS_User__c>();
    
        set<Id> learningAssIdSet = new set<Id>();

        for(Learning_Assignment__c enroll : newRecords) {
            
            /*Added functionality in ticket PRI-69 that will created Lms_Activity_enrolment and update Learning_assignment*/
            
            if (!LearningMap.isEmpty() && LearningMap.containsKey(enroll.Learning__c) && MoodleRecordtypeId == LearningMap.get(enroll.Learning__c).RecordTypeId) {
                      
                String randomStr = AS_commonFunction.generateRandomString(20);

                String keyStr1 = ( String.valueOf(enroll.Contact__c) != null ? String.valueOf(enroll.Contact__c).toLowercase() : null );
                String keyStr2 = ( String.valueOf( LearningMap.get(enroll.Learning__c).LMS_Instance__c ) != null ? String.valueOf( LearningMap.get(enroll.Learning__c).LMS_Instance__c ).toLowercase() : null );

                String keyStr = keyStr1+keyStr2;
                
                if (LearningMap.get(enroll.Learning__c).AS_LMS_type__c== 'Activity' && LearningMap.get(enroll.Learning__c).AS_Activity_Type__c !=null){
                    if (lmsUserIdsMap.containsKey(enroll.Contact__c) && lmsUserIdsMap.get(enroll.Contact__c).AS_Banner_Group_Contact__c == enroll.Contact__c){
                        
                        if(lmsUserMap.containsKey(keyStr)) {

                            learningAssIdSet.add( enroll.Id );

                        }
                    
                    }
                }
            
            }
        
        }
    
        Map<Id,Learning_Assignment__c> learningAssMap = new Map<Id,Learning_Assignment__c>();
        for( Learning_Assignment__c getLearningAss : [
            Select
                Id,
                Training_Plan_Section_Assignment__r.User__c,
                Training_Plan_Section_Assignment__r.Training_Plan_Assignment__r.AS_LMS_course_enrolment__c
            From
                Learning_Assignment__c
            Where
                Id In:learningAssIdSet
        ] ){

            learningAssMap.put( getLearningAss.Id  , getLearningAss );

        }
                                                          
        //system.debug('TplanSecList===>' + TplanSecList);
        for(Learning_Assignment__c enroll : newRecords) {
            
            /*Added functionality in ticket PRI-69 that will created Lms_Activity_enrolment and update Learning_assignment*/
            
            if (!LearningMap.isEmpty() && LearningMap.containsKey(enroll.Learning__c) && MoodleRecordtypeId == LearningMap.get(enroll.Learning__c).RecordTypeId) {
                
                String randomStr = AS_commonFunction.generateRandomString(20);
                String keyStr = String.valueOf(enroll.Contact__c).toLowercase()+String.valueOf(LearningMap.get(enroll.Learning__c).LMS_Instance__c).toLowercase();
                
                if (LearningMap.get(enroll.Learning__c).AS_LMS_type__c== 'Activity' && LearningMap.get(enroll.Learning__c).AS_Activity_Type__c !=null){
                    if (lmsUserIdsMap.containsKey(enroll.Contact__c) && lmsUserIdsMap.get(enroll.Contact__c).AS_Banner_Group_Contact__c == enroll.Contact__c){
                        
                        if(lmsUserMap.containsKey(keyStr)) {

                            LMS_Activity_Enrolment__c newActivityEn = new LMS_Activity_Enrolment__c();
                            newActivityEn.LMS_Activity__c = LearningMap.containsKey(enroll.Learning__c) ? LearningMap.get(enroll.Learning__c).AS_LMS_Activity__c : null;
                            newActivityEn.As_Creation_Status__c = 'In Progress';
                            newActivityEn.LMS_Course__c = LearningMap.containsKey(enroll.Learning__c) ? LearningMap.get(enroll.Learning__c).AS_Training_Plan__r.AS_LMS_Course__c : null;
                            newActivityEn.LMS_Instance__c = LearningMap.containsKey(enroll.Learning__c) ? LearningMap.get(enroll.Learning__c).LMS_Instance__c : null;
                            newActivityEn.LMS_User__c =  lmsUserMap.get(keyStr).Id;
                            newActivityEn.AsExtId__c= 'LMSAE'+randomStr;
                            newActivityEn.Start_Date__c = Date.today();
                            
                            if( learningAssMap.get( enroll.Id ).Training_Plan_Section_Assignment__r.User__c == enroll.User__c ){
                               newActivityEn.AS_LMS_Course_Enrolment__c = (learningAssMap.get( enroll.Id ).Training_Plan_Section_Assignment__r.Training_Plan_Assignment__r.AS_LMS_course_enrolment__c !=null) ? learningAssMap.get( enroll.Id ).Training_Plan_Section_Assignment__r.Training_Plan_Assignment__r.AS_LMS_course_enrolment__c :null;
                            }
    
                            // if ( TplanSecList.Training_Plan_Assignment__r.User__c == enroll.User__c) {
                            //     system.debug('TplanSecList.Training_Plan_Assignment__r.AS_LMS_course_enrolment__c==> :' +TplanSecList.Training_Plan_Assignment__r.AS_LMS_course_enrolment__c);                                       
                            //     newActivityEn.AS_LMS_Course_Enrolment__c = (TplanSecList.Training_Plan_Assignment__r.AS_LMS_course_enrolment__c !=null) ? TplanSecList.Training_Plan_Assignment__r.AS_LMS_course_enrolment__c :null;
                            // }
                            allActivityEnList.add(newActivityEn);
                        }
                         
                        LMS_Activity_Enrolment__c lmsActivityEnreffe = new LMS_Activity_Enrolment__c();
                        lmsActivityEnreffe.AsExtId__c= 'LMSAE'+randomStr;
                        
                        Learning_Assignment__c tobeUpdateLeaAssEn = new Learning_Assignment__c();
                        tobeUpdateLeaAssEn.Id = enroll.Id;
                        tobeUpdateLeaAssEn.AS_LMS_activity_enrolment__r = lmsActivityEnreffe;
                        allTobeUpdateLeaAssEn.add(tobeUpdateLeaAssEn);
                    }
                    
                } else if (LearningMap.get(enroll.Learning__c).AS_LMS_type__c== 'Course' || LearningMap.get(enroll.Learning__c).AS_LMS_type__c== null) {
                    
                    if(enroll.Contact__c!=null && enroll.Learning__c!=null && LearningMap.get(enroll.Learning__c).LMS_Instance__c!=null) {
                        
                        if(lmsUserMap.containsKey(keyStr)) {
                            LMS_Course_Enrolment__c newCourseEn = new LMS_Course_Enrolment__c();
                            newCourseEn.LMS_Course__c = LearningMap.get(enroll.Learning__c).LMS_Course__c;
                            newCourseEn.LMS_Instance__c = LearningMap.get(enroll.Learning__c).LMS_Instance__c;
                            newCourseEn.LMS_User__c = lmsUserMap.get(keyStr).Id;
                            newCourseEn.AsExtId__c = 'LMSCE'+randomStr;
                            allCourseEnList.add( newCourseEn );
                            //System.debug('AsBgCourseEnrollment : ' + 2);
                        } else if(tobeAddedlmsUserMap.containsKey(keyStr)) {
                            
                            LMS_User__c lmsUserReference = new LMS_User__c();
                            lmsUserReference.AsExtId__c = tobeAddedlmsUserMap.get(keyStr);
                            
                            LMS_Course_Enrolment__c newCourseEn = new LMS_Course_Enrolment__c();
                            newCourseEn.Start_Date__c = Date.Today();
                            newCourseEn.LMS_Course__c = LearningMap.get(enroll.Learning__c).LMS_Course__c;
                            newCourseEn.LMS_Instance__c =LearningMap.get(enroll.Learning__c).LMS_Instance__c;
                            newCourseEn.LMS_User__r = lmsUserReference;
                            newCourseEn.AsExtId__c = 'LMSCE'+randomStr;
                            allCourseEnList.add(newCourseEn);
                            
                        } else {
                            // create user 
                            LMS_User__c newLMSUser = new LMS_User__c();
                            newLMSUser.AS_Banner_Group_Contact__c = enroll.Contact__c;
                            newLMSUser.Email__c = ContactMap.get(enroll.Contact__c).Email;
                            newLMSUser.FirstName__c = ContactMap.get(enroll.Contact__c).FirstName;
                            newLMSUser.LastName__c = ContactMap.get(enroll.Contact__c).LastName;
                            newLMSUser.LMS_Instance__c = LearningMap.get(enroll.Learning__c).LMS_Instance__c;
                            newLMSUser.Status__c = 'Active';
                            newLMSUser.AsExtId__c = randomStr;
                            
                            
                            LMS_User__c lmsUserReference = new LMS_User__c();
                            lmsUserReference.AsExtId__c = randomStr;
                            
                            
                            LMS_Course_Enrolment__c newCourseEn = new LMS_Course_Enrolment__c();
                            newCourseEn.Start_Date__c = Date.Today();
                            newCourseEn.LMS_Course__c = LearningMap.get(enroll.Learning__c).LMS_Course__c;
                            newCourseEn.LMS_Instance__c =LearningMap.get(enroll.Learning__c).LMS_Instance__c;
                            newCourseEn.LMS_User__r = lmsUserReference;
                            newCourseEn.AsExtId__c = 'LMSCE'+randomStr;
                            
                            allNewLMSUser.add(newLMSUser);
                            allCourseEnList.add(newCourseEn);
                            //System.debug('AsBgCourseEnrollment : ' + 3);
                            tobeAddedlmsUserMap.put(keyStr,randomStr);
                        }
                        
                        LMS_Course_Enrolment__c lmsCourEnrReference = new LMS_Course_Enrolment__c();
                        lmsCourEnrReference.AsExtId__c = 'LMSCE'+randomStr;
                        
                        Learning_Assignment__c tobeUpdateLeaAssEn = new Learning_Assignment__c();
                        tobeUpdateLeaAssEn.Id = enroll.Id;
                        tobeUpdateLeaAssEn.LMS_Course_Enrolment__r = lmsCourEnrReference;
                        allTobeUpdateLeaAssEn.add(tobeUpdateLeaAssEn);
                    }
                    
                }
                
            }
            
            
        }
        
        insert allNewLMSUser;
        insert allCourseEnList;
        insert allActivityEnList;
  
        
        if(allTobeUpdateLeaAssEn.size() > 0) {
           update allTobeUpdateLeaAssEn;
            
            AS_HelperClass.runUpdateLeaAssEnroll = false;
        } else { 
            AS_HelperClass.runUpdateLeaAssEnroll = true;
        }
        
       deleteDuplicateLearningAss( learnAssCheckDuplicate ); 
    }  
  } 
     
    

    public void deleteDuplicateLearningAss( List< Learning_Assignment__c > learningAssList ){
        
       
        set<Id> userIdSet = new set<Id>();
        set<Id> learningIdSet = new set<Id>();
        set<Id> trainingPlanId = new set<Id>();
        
        for( Learning_Assignment__c learningAss : learningAssList ){
            if( LearningAss.User__c != null  ){
                userIdSet.add( LearningAss.User__c );
            }
            
            if( LearningAss.Learning__c != null  ){
                 learningIdSet.add( LearningAss.Learning__c );
            }
            
            if( LearningAss.Training_Plan__c != null  ){
                 trainingPlanId.add( LearningAss.Training_Plan__c );
            } 
        }
         
        Map< String, List< Learning_Assignment__c > > learningAssMap = new  Map<String, List< Learning_Assignment__c > >();

        for( Learning_Assignment__c learningAss : [ Select Id, Name , User__c , Training_Plan__c , Learning__c , Progress__c From Learning_Assignment__c WHERE User__c in:userIdSet AND Learning__c in:learningIdSet AND Training_Plan__c in:trainingPlanId  ] ){
            
            String KeyMapStr = learningAss.User__c+''+learningAss.Training_Plan__c+''+learningAss.Learning__c;
            
            if( learningAssMap.containskey( KeyMapStr ) ){
                
                learningAssMap.get( KeyMapStr ).add( learningAss ); 
               
            } else {

                learningAssMap.put( KeyMapStr , new List< Learning_Assignment__c > { learningAss } );
                
            }

        }
        
        List< Learning_Assignment__c > learningAssToDelete = new List< Learning_Assignment__c >();
            
        for( String keyStr : learningAssMap.keySet() ){
            
            if( learningAssMap.get( keyStr ).size() > 1 ){
				
                for( Learning_Assignment__c learningAss : learningAssMap.get( keyStr ) ){
                    
                    if( learningAss.Progress__c == 'Not Started' ){
                        
						learningAssToDelete.add( learningAss );
                        
                    }
                    
                }
                
            }
            
        }
        
        if( learningAssToDelete.size() != 0 ){
            delete learningAssToDelete;
        }

    }
 
    public static boolean runUpdateLeaAssEnroll = true;
    
    /*Author : John Hope
    *Description : check the run variable and use for recursion
    *Date Created : 
    *Last Modified By : 
    *Date Last Modified : 
    *Related Meta Data :
    *Param :
    *Return : Boolean
    */
    public static boolean runOnceUpdateLeaAssEnroll(){
        if(runUpdateLeaAssEnroll){
            runUpdateLeaAssEnroll=false;
            return true;
        }else{
            return runUpdateLeaAssEnroll;
        }
    }   
    
    //Jrc
    //On Before Update the Campaging Member.
    public void OnAfterUpdate(CampaignMember[] updatedObjects, Map<Id,CampaignMember> oldMap, Map<Id,CampaignMember> newMap){
        UpdateStatusOfLearingAss(updatedObjects, oldMap, newMap);
        createAttendee(updatedObjects);
    }
     
    public void OnAfterInsertCampMember(CampaignMember[] newRecords, Map<Id,CampaignMember> newMap){
        UpdateStatusOfLearingAss(newRecords,null, newMap);
        createAttendee(newRecords); 
    } 
     
     
    //Jrc
    //On Before Update the Campaging Member.
    public void OnBeforeInsert(Learning_Assignment__c[] updatedObjects, Map<Id,Learning_Assignment__c> oldMap, Map<Id,Learning_Assignment__c> newMap){
        // InsertStatusOfLearingAss(updatedObjects, oldMap, newMap);
    } 
 
    // added by Jet for (PSA-205)
    //On Before Update the Campaging Member and to update the Learning  Ass.
    // modified by john as of 10/18/2018 for ticket (#PSA-296)
    public void UpdateStatusOfLearingAss(CampaignMember[] updatedObjects, Map<Id,CampaignMember> oldMap, Map<Id,CampaignMember> newMap){
        
        Id campRecId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        set<Id> campMemberIdSet = new set<Id>(); 
        set<Id> learningId = new set<Id>();
        set<Id> learningAssId = new set<Id>();
        set<Id> contactId = new set<Id>();
        set<Id> userId = new set<Id>();
        map<Id,String> campMemberStatusMap = new  map<Id,String>();
        
        for( CampaignMember campMember :   updatedObjects ){
            campMemberIdSet.add( campMember.Id );
            campMemberStatusMap.put(campMember.contactId,campMember.Status);
            
            if(campMember.contactId != null) {
              
            }
        }
        
       
        system.debug('campMemberIdSet==>'+campMemberIdSet); 
        system.debug('campMemberStatusMap==>'+campMemberStatusMap);
        
        List<CampaignMember> finalCampaignMem = [   
            Select  
            Id,
            CampaignId,
            Campaign.Learning__c,
            Campaign.Training_Plan__c,
            contactId,
            AS_Attendee__r.AS_User__c,
            Status
            From 
            CampaignMember 
            WHERE 
            Status IN ('Checked In' ,'Attending') 
            And
            Id in:campMemberIdSet 
            And 
            Campaign.RecordTypeId =:campRecId 
        ];
        
        for( CampaignMember campMember :  finalCampaignMem) {
            if(campMember.Campaign.Learning__c !=null) {
                learningId.add( campMember.Campaign.Learning__c );
                contactId.add(campMember.contactId);
            }
        }
 
        // for getting all user starts here
        Map<Id,Id> allConUserMap = new Map<Id,Id>();
        if(contactId.size() > 0) {
            for(User theUser:[SELECT  
                              ContactId,
                              Id
                              FROM 
                              User 
                              WHERE 
                              ContactId IN: contactId
                             ]) {
                                 allConUserMap.put(theUser.ContactId,theUser.Id);
                             }
        }
        // for getting all user ends here
        
        system.debug('learningId==>'+learningId);  
        system.debug('contactId==>'+contactId);
        
        Map<String,Boolean> leaAssIsUpdatedMap = new Map<String,Boolean>();
        
        // for the update of existing learning assignment starts here
        if( learningId.size() != 0 ){
            
            list< Learning_Assignment__c > allLearningAss = new list<Learning_Assignment__c>();
            for( Learning_Assignment__c learnAss : [SELECT  Id,
                                                    Name,
                                                    Learning__c,
                                                    Learning__r.AS_Group_1_CPD__c,
                                                    Learning__r.AS_Group_2_CPD__c,
                                                    Training_Plan__c, 
                                                    Contact__c
                                                    From Learning_Assignment__c Where Learning__c IN:learningId AND Contact__c IN:contactId ] ){
                                                        System.debug(' solod man diri '+learnAss.Id ); 
                                                        Learning_Assignment__c updateLearnAss = new Learning_Assignment__c();
                                                        if( campMemberStatusMap.get( learnAss.Contact__c ) == 'Checked In' ){
                                                            
                                                            updateLearnAss.Id  =  learnAss.Id;
                                                            updateLearnAss.Progress__c = 'Completed';
                                                            updateLearnAss.Progress_Percentage__c = 100;
                                                            updateLearnAss.AS_Group_1_CPD__c  = learnAss.Learning__r.AS_Group_1_CPD__c;
                                                            updateLearnAss.AS_Group_2_CPD__c  = learnAss.Learning__r.AS_Group_2_CPD__c;
                                                            updateLearnAss.Completed_On__c = system.today();
                                                            
                                                            leaAssIsUpdatedMap.put(String.valueOf(learnAss.Training_Plan__c).toLowerCase()+String.valueOf(learnAss.Contact__c).toLowerCase(),true);
                                                            
                                                        } else if (  campMemberStatusMap.get( learnAss.Contact__c ) == 'Attending' ){
                                                            
                                                            updateLearnAss.Id  =  learnAss.Id;
                                                            updateLearnAss.Progress__c = 'In Progress';
                                                            updateLearnAss.Progress_Percentage__c = 50;
                                                            updateLearnAss.AS_Group_1_CPD__c  = 0;
                                                            updateLearnAss.AS_Group_2_CPD__c  = 0;
                                                            
                                                            leaAssIsUpdatedMap.put(String.valueOf(learnAss.Training_Plan__c).toLowerCase()+String.valueOf(learnAss.Contact__c).toLowerCase(),true);
                                                        }
                                                        
                                                        allLearningAss.add(updateLearnAss);
                                                        
                                                    }
            
            system.debug('allLearningAss ==> '+ allLearningAss);
            if( allLearningAss.size() != 0 ){
                try{
                    update allLearningAss;
                }
                 
                catch(Exception e){ 
                    System.debug(e.getMessage());
                }
            }
        }
        // for the update of existing learning assignment ends here
        
        // for the creation of new learning assignment on update starts here
 		
       
       list< Learning_Assignment__c > lstLearningAss = [ Select Id , Progress__c From Learning_Assignment__c  limit 10   ];
       system.debug('jrclstLearningAss===>' + lstLearningAss ); 
        
       Map<Id,Set<Id>> allTrainPlanMap = new Map<Id,Set<Id>>();
        Map<String,CampaignMember> allCamMemForLeaAssUpMap = new Map<String,CampaignMember>();
        for( CampaignMember campMember :  finalCampaignMem) {
            if(campMember.Campaign.Training_Plan__c != null && campMember.contactId != null) {
                Id finalUserId = (allConUserMap.containsKey(campMember.ContactId))?allConUserMap.get(campMember.ContactId):null;
                
                String theKey = String.valueOf(campMember.Campaign.Training_Plan__c).toLowerCase()+String.valueOf(campMember.contactId);
                
                if(!leaAssIsUpdatedMap.containsKey(theKey) && finalUserId!=null) {
                    if(allTrainPlanMap.containsKey(campMember.Campaign.Training_Plan__c)) {
                        allTrainPlanMap.get(campMember.Campaign.Training_Plan__c).add(finalUserId);
                    }   else {
                        allTrainPlanMap.put(campMember.Campaign.Training_Plan__c,new Set<Id>{finalUserId});
                    }
                    
                    if(campMember.Campaign.Learning__c != null) {
                        String theLearnKey = String.valueOf(campMember.Campaign.Learning__c).toLowerCase()+String.valueOf(campMember.contactId);
                        allCamMemForLeaAssUpMap.put(theLearnKey,campMember);
                    }
                    
                }
            }
        }
        
        System.debug('allTrainPlanMap : ' + allTrainPlanMap);
        if(allTrainPlanMap.size() > 0) {
            List<Learning_Assignment__c> allTobeUpdatedLeaAss = new List<Learning_Assignment__c>();
            for(Id trainPlan : allTrainPlanMap.keySet()) {
                Map<Id,List<Learning_Assignment__c>> LearnAssMap = LMSService.upsertAssignments(allTrainPlanMap.get(trainPlan), trainPlan, LMSUtils.getCurrentNetworkId());
                System.debug('LearnAssMap : ' + LearnAssMap);
                for(List<Learning_Assignment__c> leaAssList : LearnAssMap.values()) {
                    allTobeUpdatedLeaAss.addAll(leaAssList);
                }
            }
            
            Set<Id> allNewLearnAssIdSet = new Set<Id>(new Map<Id, Learning_Assignment__c>(allTobeUpdatedLeaAss).keySet());
            System.debug('allNewLearnAssIdSet : ' + allNewLearnAssIdSet);
            
            list< Learning_Assignment__c > allReProLearningAss = new list<Learning_Assignment__c>();
            for( Learning_Assignment__c learnAss : [SELECT  
                                                    Id,
                                                    Name,
                                                    Learning__c,
                                                    Learning__r.AS_Group_1_CPD__c,
                                                    Learning__r.AS_Group_2_CPD__c,
                                                    Training_Plan__c,
                                                    Contact__c
                                                    From
                                                    Learning_Assignment__c 
                                                    Where 
                                                    Id IN :allNewLearnAssIdSet
                                                   ]) {
                                                       String theKey = String.valueOf(learnAss.Learning__c).toLowerCase()+String.valueOf(learnAss.Contact__c);
                                                       
                                                       if(allCamMemForLeaAssUpMap.containsKey(theKey)) {
                                                           CampaignMember theCamMem = allCamMemForLeaAssUpMap.get(theKey);
                                                           
                                                           Learning_Assignment__c updateLearnAss = new Learning_Assignment__c();
                                                           if(theCamMem.Status == 'Checked In') {
                                                               
                                                               updateLearnAss.Id  =  learnAss.Id;
                                                               updateLearnAss.Progress__c = 'Completed';
                                                               updateLearnAss.Progress_Percentage__c = 100;
                                                               updateLearnAss.AS_Group_1_CPD__c  = learnAss.Learning__r.AS_Group_1_CPD__c;
                                                               updateLearnAss.AS_Group_2_CPD__c  = learnAss.Learning__r.AS_Group_2_CPD__c;
                                                               updateLearnAss.Completed_On__c = system.today();
                                                               
                                                           } else if (theCamMem.Status == 'Attending'){
                                                               updateLearnAss.Id  =  learnAss.Id;
                                                               updateLearnAss.Progress__c = 'In Progress';
                                                               updateLearnAss.Progress_Percentage__c = 50;
                                                               updateLearnAss.AS_Group_1_CPD__c  = 0;
                                                               updateLearnAss.AS_Group_2_CPD__c  = 0;
                                                           }
                                                           
                                                           allReProLearningAss.add(updateLearnAss);
                                                       }
                                                   }
            
            system.debug('allReProLearningAss ==> '+ allReProLearningAss);
            if( allReProLearningAss.size() != 0 ){
                update allReProLearningAss;
            }
            //UpdateStatusOfLearingAss(allTobeReupdatedCamMem, new Map<Id,CampaignMember>(), new Map<Id,CampaignMember>());
        } 


        // for the creation of new learning assignment on update starts here
    }
    
    
    
    public static boolean runOnce = true;

    public static boolean runOnceMethod(){/*Anti-recursion*/
        if(runOnce){
            runOnce=false;
            return true;
        }else{
            return runOnce;
        }
    }
    
    public void OnAfterDelete(Map<Id,CampaignMember> oldMap){
        Set<Id> deleteAttendee = new Set<Id>();
        
        for(CampaignMember member : oldMap.values()){
            if(member.AS_Attendee__c != null) deleteAttendee.add(member.AS_Attendee__c);
        }
        
        if(deleteAttendee.size() > 0) delete [SELECT Id FROM AS_Attendee__c WHERE Id IN : deleteAttendee];   
    }
    
    public void createAttendee(CampaignMember[] newRecords){
        if(runOnceMethod()){
            Set<Id> campaignIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            for(CampaignMember member : (List<CampaignMember>) newRecords){
                campaignIds.add(member.CampaignId);
                contactIds.add(member.ContactId);
            }
            
            Map<Id, Campaign> campaignMap = new Map<Id, Campaign>([SELECT Id, AS_Event__c FROM Campaign WHERE Id IN : campaignIds AND AS_Event__c != null]);
            
            if(campaignMap.size() > 0) {
                List<AS_Attendee__c> insertAttendee = new List<AS_Attendee__c>(),
                    updateAttendee = new List<AS_Attendee__c>();
                
                for(CampaignMember member : (List<CampaignMember>) newRecords){
                    AS_Attendee__c attendee = new AS_Attendee__c(//AS_Campaign_Member__c = member.Id,
                        AS_Event__c = campaignMap.get(member.CampaignId).AS_Event__c,
                        AS_Status__c = member.Status,
                        AS_User__c = member.ContactId,
                        AS_Attendee_First_Name__c = member.FirstName,
                        AS_Attendee_Last_Name__c = member.LastName);
                    
                    if(member.AS_Attendee__c != null){
                        attendee.Id = member.AS_Attendee__c;
                        updateAttendee.add(attendee);
                    }else if(member.Created_from_Attendee__c == false) insertAttendee.add(attendee);
                }
                
                if(updateAttendee.size() > 0) update updateAttendee; 
                
                if(insertAttendee.size() > 0){
                    insert insertAttendee;
                    
                    List<CampaignMember> updateMember = new List<CampaignMember>();
                    
                    for(CampaignMember member : (List<CampaignMember>) newRecords){
                        for(AS_Attendee__c attendee : insertAttendee){
                            if(attendee.AS_Event__c == campaignMap.get(member.CampaignId).AS_Event__c && attendee.AS_User__c == member.ContactId){
                                CampaignMember newMember = new CampaignMember(Id = member.Id, AS_Attendee__c = attendee.Id);
                                updateMember.add(newMember);
                            }
                        }
                    }
                    if(updateMember.size() > 0) update updateMember;
                }
            }
        }
    }
    
    public static void createAttendeeFromSession(String tpId, String tpEvent, String trackId){
        User usr = [SELECT Id, FirstName, LastName, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('tpEvent: '+tpEvent);
        System.debug('ContactId: '+usr.ContactId);
        System.debug('tpId: '+tpId);
        List<AS_Attendee__c> atts = [Select Id From AS_Attendee__c Where AS_User__c =: usr.ContactId AND AS_Training_Plan__c =: tpId AND AS_Attendee_Last_Name__c =: usr.LastName AND AS_Attendee_First_Name__c =: usr.FirstName AND AS_Event__c =: tpEvent];
        
        if(atts.size() == 0){
            AS_Attendee__c attendee = new AS_Attendee__c(AS_Attendee_First_Name__c = usr.FirstName,
                                                         AS_Attendee_Last_Name__c = usr.LastName,
                                                         AS_Status__c = 'Registered',
                                                         AS_User__c = usr.ContactId,
                                                         AS_Training_Plan__c = tpId,
                                                         AS_Agrees_to_terms_and_conditions__c = true,
                                                         AS_Event__c = tpEvent,
                                                         AS_Training_Track__c = trackId);
            
            insert attendee;
        }
    }
}