/*Author : John Hope
*Description : This is a class for creating pdf for CPD
*Date Created : May 9, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : 
*/
global class AsCPDPdfController {
    
 	/*Author : John Hope
  *Description : constructor
  *Date Created : May 9, 2018
  *Last Modified By : John Hope
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
	public  AsCPDPdfController(){
 	}
 	
 	/*Author : John Hope
  *Description : this method is use to create pdf for cpd
  *Date Created : May 9, 2018
  *Last Modified By : John Hope
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
	@Future(callout=true) @auraEnabled
	webservice static void createCPDPdf(List<id> IdList){
		system.debug('IdList : '+IdList);
		
		list<attachment> insertAttachment = new list<attachment>();
   	List<AsCPDPlanner__c> allUpdateCPDPLan = new List<AsCPDPlanner__c>();
  
    for(Id plannerId: IdList) {
	    //create a pageReference instance of the VF page.
	    pageReference pdf = Page.AsCpdPlanPdf;
	    //pass the Account Id parameter to the class.
	    pdf.getParameters().put('id',plannerId);
	    Attachment attach = new Attachment();
	    Blob body;
	    if(!test.isRunningTest()){
	        body = pdf.getContent();
	    }else{
	        body=blob.valueOf('TestString');
	    }
	    attach.Body = body;
	    attach.Name = 'CPD Summary -'+plannerId+'.pdf';
	    attach.IsPrivate = false;
    	attach.ParentId = plannerId;//This is the record to which the pdf will be attached
	    insertAttachment.add(attach);
	    
	    AsCPDPlanner__c indiUpdatePlanner = new AsCPDPlanner__c();
	    indiUpdatePlanner.Id = plannerId;
	    indiUpdatePlanner.AsGenerateCPDsummary__c = false;
			allUpdateCPDPLan.add(indiUpdatePlanner);
 		}
     //insert the list
 		System.debug('insertAttachment for subscription:' + insertAttachment);
 		insert insertAttachment;
     
 		update allUpdateCPDPLan;
	}
	
	/*Author : John Hope
  *Description : this method is use for lightning button
  *Date Created : May 9, 2018
  *Last Modified By : John Hope
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
	@AuraEnabled 
	webservice static void createCPDPdfByButton(Id cpdPlannerId){
    system.debug('cpdPlannerId : '+cpdPlannerId);
    AsCPDPlanner__c cpd = new AsCPDPlanner__c();
    cpd.Id = cpdPlannerId;
    cpd.AsGenerateCPDsummary__c = true;
    update cpd;
	}
	
	/*Author : John Hope
  *Description : this method is use to create pdf for learning summary
  *Date Created : May 9, 2018
  *Last Modified By : John Hope
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
	@Future(callout=true) @auraEnabled
	webservice static void createTrainPlanAssignPdf(Id assignId){
		System.debug('assignId :' + assignId);
		List<AsCPD_Learning_Summary__c> allLearnSumAssign = [Select Id,Name,ASTraining_Plan_Assignment__c, ASTraining_Plan_Assignment__r.Status__c from AsCPD_Learning_Summary__c where Id = :assignId LIMIT 1];
		if(allLearnSumAssign.size() > 0 && (allLearnSumAssign[0].ASTraining_Plan_Assignment__r.Status__c == 'Completed' || allLearnSumAssign[0].ASTraining_Plan_Assignment__r.Status__c == 'Complete')) {
			list<attachment> insertAttachment = new list<attachment>();
	    //create a pageReference instance of the VF page.
	    pageReference pdf = Page.AsTrainPlanAssignmentPdf;
	    //pass the Account Id parameter to the class.
	    pdf.getParameters().put('id',assignId);
	    Attachment attach = new Attachment();
	    Blob body;
	    if(!test.isRunningTest()){
	        body = pdf.getContent();
	    }else{
	        body=blob.valueOf('TestString');
	    }
	    attach.Body = body;
	    attach.Name = 'Learning Summary - '+assignId+'.pdf';
	    attach.IsPrivate = false;
		attach.ParentId = assignId;//This is the record to which the pdf will be attached
	    insertAttachment.add(attach);
	 //insert the list
	 		System.debug('insertAttachment for subscription:' + insertAttachment);
	 		insert insertAttachment;
		}
	}
	
    
    
}