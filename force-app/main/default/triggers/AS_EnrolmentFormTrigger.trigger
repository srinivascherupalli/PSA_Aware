/*Author : Michael Vincent Largo
*Description :  This class will update the Enrolment that being updated.
*Date Created : September 24,2019
*Last Modified By : 
*Date Last Modified :
*/
trigger AS_EnrolmentFormTrigger on Enrolment_Form__c (after update) {
    
       if(!System.isBatch()){
         if(Trigger.isAfter){
             if(Trigger.isUpdate){
                 AS_EnrolmentFormHandler.UpdateEnrolmentForm(Trigger.new);
             }
         }
    }
    

}