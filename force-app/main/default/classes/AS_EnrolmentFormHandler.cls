/*Author : Michael Vincent Largo
*Description :  This class will update the Enrolment that being updated and it will create a case record.
*Date Created : September 24,2019
*Last Modified By :  Jet R. Compayan <jet@alphasys.com.au>
*Date Last Modified :
*/
public class AS_EnrolmentFormHandler {
    
    private static Boolean recursiveVal = false;
    
    
    public static void UpdateEnrolmentForm(List<Enrolment_Form__c> newEnrolmentform){
 
            Set<Id> EmrolmentIds = new Set<Id>();
            Map<Id,Enrolment_Form__c> mapenrolled_enrolmentIds = new Map<Id,Enrolment_Form__c>();
            Map<Id,Enrolment_Form__c> mapenrolmenttoupdate = new Map<Id,Enrolment_Form__c>();
            list<Enrolment_Form__c> updateEnrollmentProcesssList = new list<Enrolment_Form__c>();

            for (Enrolment_Form__c enrolment : newEnrolmentform){
           
                if (enrolment.Enrolment_Status__c == 'Approved' && enrolment.AS_Processed__c == false) {
                    EmrolmentIds.add(enrolment.Id);
                    mapenrolled_enrolmentIds.put(enrolment.Id,enrolment);

                    Enrolment_Form__c updateEnrollmentProcesss = new Enrolment_Form__c();
                    updateEnrollmentProcesss.Id = enrolment.Id;
                    updateEnrollmentProcesss.AS_Processed__c = true;
                    updateEnrollmentProcesssList.add( updateEnrollmentProcesss );

                }
            } 

            system.debug('EmrolmentIds=>'+EmrolmentIds);

            List<Training_Plan_Assignment__c> allTplanAssignList = new List<Training_Plan_Assignment__c>();
            List<AS_Enrolled_Unit__c> allenrolledunitList = new List<AS_Enrolled_Unit__c>();

            set<Id> trainingPlanIdSet = new set<Id>();
            set<Id> AccountIdSet = new set<Id>();

            
            if (!EmrolmentIds.isEmpty()) {
                //Get Enrollment Unit base on the Parent Enrollement Id
                List<AS_Enrolled_Unit__c> allenrolmentunit = [ 
                    SELECT 
                        Id,  
                        Name,
                        AS_Enrolment__c,
                        AS_Enrolment__r.AS_Account__c,
                        AsExtId__c,
                        AS_Status__c,
                        AS_Unit__c,
                        AS_Unit__r.AS_Training_Plan__c,
                        AS_Training_Plan_Assignment__c 
                    FROM 
                        AS_Enrolled_Unit__c 
                    WHERE 
                        AS_Enrolment__c IN:EmrolmentIds
                		AND
                		AS_Status__c  = 'Pending'  
                	];


                set<Id> enrolledAccId = new set<Id>();
                for (AS_Enrolled_Unit__c unitenrol : allenrolmentunit) {
                    
                    if (unitenrol.AS_Unit__r.AS_Training_Plan__c !=null) {
 
                        enrolledAccId.add( unitenrol.AS_Enrolment__r.AS_Account__c );
                        
                      //  AccountIdSet.add( unitenrol.AS_Enrolment__r.AS_Account__r.Contact_ID__pc  );
                        trainingPlanIdSet.add( unitenrol.AS_Unit__r.AS_Training_Plan__c );

                    } 

                }     



                //Check Training plan Assignment is user already enrolled to the Unit.
                Map<String,Id> alreadyEnrolledMap = new  Map<String,Id>();
                for( Training_Plan_Assignment__c tPlanAss : [
                    Select 
                        Id,
                        User__r.AccountId,
                        Training_Plan__c
                    From
                        Training_Plan_Assignment__c
                    WHERE
                        Training_Plan__c IN:trainingPlanIdSet
                        AND
                        User__r.AccountId IN:enrolledAccId
                ]){
                    alreadyEnrolledMap.put( tPlanAss.User__r.AccountId+''+tPlanAss.Training_Plan__c, tPlanAss.Id );
                }


                //Get User Id base on the Account Id that collected from the Enrollment Object.
                Map< Id , Id > accountIdUserMap = new Map< Id , Id >();
                for( User enrlledUser : [
                    Select
                        Id,
                        AccountId
                    FROM
                        User
                    WHERE
                       AccountId In:enrolledAccId  
                ]){ 
                    //Collect all the User Id and Account Id in one map
                    accountIdUserMap.put( enrlledUser.AccountId , enrlledUser.Id ); 
                } 


                system.debug('alreadyEnrolledMap->'+alreadyEnrolledMap);

                set<Id> traininplanIdList = new set<Id>();
                set<Id> userIdSet = new  set<Id>();
                map<Id,Id> enrollementUnitMap = new  map<Id,Id>();
                List< AS_Enrolled_Unit__c > enrollmentUnitListUpdatePrev = new  list< AS_Enrolled_Unit__c >();    
                //Interate the Enrollment Unit 
                for (AS_Enrolled_Unit__c unitenrol : allenrolmentunit) {
 
                    // When the Training plan exist it will create an Enrollunit DML to update as Previously Enrolled
                    if( alreadyEnrolledMap.containsKey( unitenrol.AS_Enrolment__r.AS_Account__c+''+unitenrol.AS_Unit__r.AS_Training_Plan__c  ) ) {
                        
                       // if( unitenrol.AS_Status__c != 'Enrolled'   ){

                            AS_Enrolled_Unit__c enrollmentUnitUpdatePrev = new AS_Enrolled_Unit__c();
                            enrollmentUnitUpdatePrev.Id = unitenrol.Id;  
                            enrollmentUnitUpdatePrev.AS_Training_Plan_Assignment__c = alreadyEnrolledMap.get( unitenrol.AS_Enrolment__r.AS_Account__c+''+unitenrol.AS_Unit__r.AS_Training_Plan__c  );
                            enrollmentUnitUpdatePrev.AS_Status__c = 'Previously Enrolled';
                            enrollmentUnitListUpdatePrev.add( enrollmentUnitUpdatePrev ); 

                    //    }
  
                    } else {

                        traininplanIdList.add( unitenrol.AS_Unit__r.AS_Training_Plan__c ); 
                        userIdSet.add( accountIdUserMap.get( unitenrol.AS_Enrolment__r.AS_Account__c ) );
                        enrollementUnitMap.put(  unitenrol.AS_Unit__r.AS_Training_Plan__c , unitenrol.Id ); 

                    }
 
                }

                if( traininplanIdList.size() != 0 ){
                    //Bulk Creation of Learning Ass and Creation of Tplan Assigment also
                    CreateTraiingplanAssignmentBulk(
                        userIdSet,
                        traininplanIdList,
                        enrollementUnitMap
                    ); 

                }   
 
                if( enrollmentUnitListUpdatePrev.size() != 0 ){
                    system.debug( 'enrollmentUnitUpdatePrev=>>'+enrollmentUnitListUpdatePrev );
                    update enrollmentUnitListUpdatePrev; 
                } 
           

                if( updateEnrollmentProcesssList.size() != 0 ){
                    update updateEnrollmentProcesssList;
                }  

            }
            
        
    } 

    public static void CreateTraiingplanAssignmentBulk( Set<Id> userIds  , set<Id> trainingPlanIdList ,map<Id,Id> enrollementUnitMap ){

        Map<Id,User> activeUsers = LMSService.getUserMap(userIds, true);

        //Auxiliary collections
        Map<Id,List<Learning_Assignment__c>> results = new Map<Id,List<Learning_Assignment__c>>();
        List<Learning_Assignment__c> assignmentsToInsert = new List<Learning_Assignment__c>();
        Set<Id> newUsersWithAssignments = new Set<Id>();
        Map<Id,Set<String>> excludedLearnings = new Map<Id,Set<String>>();
        Map<Id,Training_Plan_Assignment__c> planAssignmentsToUpdate = new Map<Id,Training_Plan_Assignment__c>();

         //Get all the learning ids under the specified training plan
        Map<Id,Learning_Assignment__c> updatedOptionalAssignments = new  Map<Id,Learning_Assignment__c>();

        LMSService.WithoutSharingOps wsops = new LMSService.WithoutSharingOps();

        Map<Id,Set<Id>> trainingPlanLearnings = wsops.getTrainingPlanLearningIds( trainingPlanIdList );

        set<Id> learningIdSet = new set<Id>();
 
        for( Id keyTplanId : trainingPlanLearnings.keySet() ) {

            for( Id keyLaerningId : trainingPlanLearnings.get( keyTplanId ) ){
 
                learningIdSet.add( keyLaerningId );

            }
     
        }

        Map<Id,List<Training_Plan_Section_Item__c>> tPlanSectionItems = wsops.getTrainingPlanSectionItemsFromTrainingPlans( trainingPlanIdList );
   
        Map<Id,List<Learning_Assignment__c>> mapLearningAssignments = LMSService.As_getAssignmentsForLearnings(learningIdSet,trainingPlanIdList,activeUsers.keySet());

        Map< String, Learning_Assignment__c> learnigAssMap = new Map< String, Learning_Assignment__c>();

        for( Id keyTplanId : trainingPlanLearnings.keySet() ){

            if( trainingPlanLearnings.get(keyTplanId) != null ){
 
                //Fetch optional attribute from related training plan section and section items
                Map<Id,Boolean> tPlanSectionItemMap = new Map<Id,Boolean>();
                if(tPlanSectionItems.get(keyTplanId) != null){
                    List<Training_Plan_Section_Item__c> sectionItems = tPlanSectionItems.get(keyTplanId);
                    
                    for(Training_Plan_Section_Item__c tpsi : sectionItems){
                        Boolean isOptional = false;
                        if(tpsi.Training_Plan_Section__r != null && tpsi.Training_Plan_Section__r.Optional__c){
                            isOptional = true; 
                        }else{
                            isOptional = tpsi.Optional__c;
                        }
                        tPlanSectionItemMap.put(tpsi.id,isOptional);
                    }
                }
 
            }

            for(List<Training_Plan_Section_Item__c> sectionItems : tPlanSectionItems.values()){

                system.debug('Parent==>'+sectionItems);

                for(Training_Plan_Section_Item__c sectionItem : sectionItems){

                    system.debug('Child ==> '+sectionItem.Learning__c);
 

                    if(sectionItem.Learning__c != null){
                        for(Id userId : activeUsers.keySet()){

                            if(!excludedLearnings.containsKey(userId) || (excludedLearnings.containsKey(userId) && !excludedLearnings.get(userId).contains(sectionItem.Learning__c+'_'+sectionItem.Id))){

                                User uInfo = activeUsers.get(userId);
                                //Add learning to insert map
                                Learning_Assignment__c newLA = new Learning_Assignment__c();
                                newLA.OwnerId = userId;
                                newLA.User__c = userId;
                                newLA.Learning__c = sectionItem.Learning__c;
                                newLA.Learning_Version__c = sectionItem.Learning__r.Current_Published_Version__c;
                                newLA.Training_Plan__c = sectionItem.Training_Plan_Section__r.Training_Plan__c;
                                newLA.Progress__c= LMSConstants.ASSIGNMENT_STATUS_NOT_STARTED;
                                newLA.Progress_Percentage__c = 0;
                                newLA.Training_Plan_Section__c = sectionItem.Training_Plan_Section__c;
                                newLA.Training_Plan_Section_Item__c = sectionItem.Id;
                                newLA.Contact__c = uInfo.ContactId;
                                newLA.Optional__c = sectionItem.Optional__c;
                                newLA.Community_Id__c = LMSUtils.getCurrentNetworkId();
                                newLA.As_Exnternal_Enroll_Unit_Id__c = enrollementUnitMap.get( sectionItem.Training_Plan_Section__r.Training_Plan__c );
 
                                if(!results.containsKey(userId)){
                                    results.put(userId,new List<Learning_Assignment__c>());
                                }

                                learnigAssMap.put( sectionItem.Learning__c+''+sectionItem.Learning__r.Current_Published_Version__c+''+sectionItem.Training_Plan_Section__r.Training_Plan__c , newLA );

                                assignmentsToInsert.add(newLA);
                 
                                results.get(userId).add(newLA);
                            }
                        } 
                    }
                }
            }
             
        } 

        List< Learning_Assignment__c > learningAssInsertList = new List< Learning_Assignment__c >();
        for( String lstAss : learnigAssMap.keySet() ){
            learningAssInsertList.add( learnigAssMap.get( lstAss ) );
            system.debug( 'assignmentsToInsert before ' + learnigAssMap.get( lstAss ) );
        }


        insert learningAssInsertList;

      //  Insert assignmentsToInsert;  
       // system.debug( 'assignmentsToInsert after ' + assignmentsToInsert );

 
            /*  
        System.debug('newUsersWithAssignments : ' + newUsersWithAssignments);
        if(newUsersWithAssignments.size()>0){
            //Share the training and learnings with corresponding users
            wsops.shareTrainingPlanWithUsers(newUsersWithAssignments, trainingPlanIdList );
        }

        // Regular users dont' have permissions to insert these objects, however it's possible that they create assignments
        // for training plans with self-registration enabled. Therefore, we leave CRUD/FLS enforcement to the caller
        // We need to insert these records in without sharing context to prevent insufficient cross reference errors since we don't
        // share the learnings associated to the assignments due to limitations with portal users
        System.debug('assignmentsToInsert : ' + assignmentsToInsert);
        if(assignmentsToInsert.size()>0){
            wsops.insertAssignments(assignmentsToInsert);
        } 

        // Update optional flag for assignments where the parent section item or section has changed
        // We need to update these records in without sharing context to prevent insufficient cross reference errors since we don't
        // share the learnings associated to the assignments due to limitations with portal users
        System.debug('updatedOptionalAssignments : ' + updatedOptionalAssignments);
        if(updatedOptionalAssignments.size()>0){
            wsops.updateAssignments(updatedOptionalAssignments.values());
        }

        System.debug('planAssignmentsToUpdate : ' + planAssignmentsToUpdate);
        if(planAssignmentsToUpdate.size()>0){
            wsops.updateTrainingPlanAssignments(planAssignmentsToUpdate.values());
        } 

        // Create Badge Assignments
       // LMSService.upsertAchievementAssignments(activeUsers.keySet(),trainingPlanId, communityId);
 
        system.debug('getTrainingPlanLearningIds => '+trainingPlanLearnings);
        system.debug('tPlanSectionItems => '+tPlanSectionItems);
        system.debug( 'mapLearningAssignments=>'+mapLearningAssignments );
        */

    }
 
}