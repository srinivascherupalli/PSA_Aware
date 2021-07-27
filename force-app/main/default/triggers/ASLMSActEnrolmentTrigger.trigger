/*Author : Ronald Santander
*Description : This trigger will run once LMS Activity Enrolment record updated.
*Date Created : Aug 13,2019
*Last Modified By : 
*Date Last Modified :
*/
trigger ASLMSActEnrolmentTrigger on LMS_Activity_Enrolment__c (after update) {
    if(!System.isBatch()){
         if(Trigger.isAfter){
             if(Trigger.isUpdate){
                 ASLMSActEnrolmentHandler.processAfterUpdate(Trigger.newMap);
                 //ASLMSActEnrolmentHandler.lmsActivityenrolmentMoodle(Trigger.new);//not use
             }
         }
    }
}