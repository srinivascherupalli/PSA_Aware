// ============================================================================================= 
//  Object:  NA: schedulable
//  Company: The Aware Group
//  Author: Kay Jin 
//  Purpose:  autorenew
//  Methods:  
//              
//  Created:  
// ============================================================================================= 
//  Use Cases or Requirements: 
//  @UseCase number - @requirement Description      
// ============================================================================================= 
//  Changes: @Date Author
//           @Description
// ============================================================================================= 

global class CPQ_RenewSchedule implements Schedulable {
    global void execute(SchedulableContext ctx) {
        CPQ_RenewContractsBatch batchObject = new CPQ_RenewContractsBatch();
        Id batchId = Database.executeBatch(batchObject, 1);
    }
}