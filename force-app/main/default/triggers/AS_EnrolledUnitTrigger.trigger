/*Author : Michael Vincent Largo
*Description :  This class will update the Enrolment that connected to Enrolled Unit that being updated.
*Date Created : September 18,2019
*Last Modified By : 
*Date Last Modified :
*/
trigger AS_EnrolledUnitTrigger on AS_Enrolled_Unit__c (after update) {
    
     if(!System.isBatch()){
         if(Trigger.isAfter){
             if(Trigger.isUpdate){
                 /*PRI-95*/
                 /*this has been revied by the client and wont be requried. 
				 Please keep the code for future reference but inactive the trigger and any class ralated to this*/
                 AS_EnrolledUnitHandler.updateEnrolmentfromEnrolmentUnit(Trigger.new);
             }
         }
    }
    

}