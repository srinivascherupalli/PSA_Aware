/*Author : Ronald Santander
*Description : This class will update the learning assignment that connected to LMS Activity Enrolment that being updated.
*Date Created : Aug 13,2019
*Last Modified By : Romnick Hilot
*Date Last Modified :March 26, 2020
*/

public class ASLMSActEnrolmentHandler {
    private static Boolean recursiveVal = false;
    
    public static void processAfterUpdate(Map<Id, LMS_Activity_Enrolment__c> newPlansMap){
        if(recursiveVal == false){
            recursiveVal = true;
            
            Set<Id> LMSActEnrolIds = new Set<Id>();
            Map<Id,LMS_Activity_Enrolment__c> mapLMSActEnrol = new Map<Id,LMS_Activity_Enrolment__c>();
            for(LMS_Activity_Enrolment__c lmsActEnrol: newPlansMap.values()){
                if(lmsActEnrol.AS_Completed_Status__c == true){
                    //map the LMS Activity Enrolment
                    mapLMSActEnrol.put(lmsActEnrol.Id,lmsActEnrol);
                    //set of id to use on learning assignment query
                    LMSActEnrolIds.add(lmsActEnrol.Id);
                }
            }
            
            List<Learning_Assignment__c> newlearningAssignList = new List<Learning_Assignment__c>();
            //using the triggered lms activity enrolment get the learning assignment and loop
            for(Learning_Assignment__c learningAssign : [SELECT Id,
                                                                AS_LMS_activity_enrolment__c,
                                                                Learning__r.AS_Group_1_CPD__c,
                                                                Learning__r.AS_Group_2_CPD__c
                                                            FROM 
                                                                Learning_Assignment__c 
                                                            WHERE 
                                                                AS_LMS_activity_enrolment__c IN: LMSActEnrolIds
                                                        ]){
                if(mapLMSActEnrol.containsKey(learningAssign.AS_LMS_activity_enrolment__c)){
                    
                    String status = mapLMSActEnrol.get(learningAssign.AS_LMS_activity_enrolment__c).Completion_Status__c;
                    Learning_Assignment__c newlearningAssign = new Learning_Assignment__c();

                    if( status == 'Pass' && (learningAssign.Learning__r.AS_Group_2_CPD__c != NULL && learningAssign.Learning__r.AS_Group_2_CPD__c != 0 ) ) {

                        newlearningAssign.Id 				     = learningAssign.Id;
                        newlearningAssign.AS_Passed__c           = true;
                        newlearningAssign.AS_Group_1_CPD__c      = 0;
                        newlearningAssign.AS_Group_2_CPD__c      = learningAssign.Learning__r.AS_Group_2_CPD__c;
                        newlearningAssign.Progress__c		     = 'Completed';
                        newlearningAssign.Progress_Percentage__c = 100;
                        newlearningAssign.Completed_On__c 	     = (mapLMSActEnrol.get(learningAssign.AS_LMS_activity_enrolment__c).End_Date__c != null) ? mapLMSActEnrol.get(learningAssign.AS_LMS_activity_enrolment__c).End_Date__c : null;

                    } else {
                    
                        newlearningAssign.Id 				     = learningAssign.Id;
                        newlearningAssign.AS_Passed__c           = (status == 'Pass') ? true:false;
                        newlearningAssign.AS_Group_1_CPD__c      = learningAssign.Learning__r.AS_Group_1_CPD__c;
                        newlearningAssign.AS_Group_2_CPD__c      = 0;
                        newlearningAssign.Progress__c		     = (status == 'Pass') ? 'Completed':'In Progress';
                        newlearningAssign.Progress_Percentage__c = 100;
                        newlearningAssign.Completed_On__c	     = (mapLMSActEnrol.get(learningAssign.AS_LMS_activity_enrolment__c).End_Date__c != null) ? mapLMSActEnrol.get(learningAssign.AS_LMS_activity_enrolment__c).End_Date__c : null;
                    
                    }
                    
                    newlearningAssignList.add(newlearningAssign);
                }
            }
            if(!newlearningAssignList.isEmpty()){
                update newlearningAssignList;
            }
        }
    }
    
}