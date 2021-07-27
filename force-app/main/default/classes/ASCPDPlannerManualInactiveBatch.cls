/*Author : John Hope
*Description : This is a class that handles batch process that inactive all cpd when creation of CPD's base on the given year
*Date Created : December 7, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : 
*/
public class ASCPDPlannerManualInactiveBatch implements Database.batchable<SObject>,Database.Stateful {
	public String cpdYear { get;set; }
 	public Boolean cpdCurrent { get;set; }
 	
 	public ASCPDPlannerManualInactiveBatch(String year,Boolean current) {	
 		cpdYear = year;
 		cpdCurrent = current;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		Boolean setToActive;
 		Id theRecordType;
 		Id activeCPDRecId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByName().get('Active CPD Planner').getRecordTypeId();
 		if(Integer.valueOf(Date.today().year()) == Integer.valueOf(cpdYear) || cpdCurrent == true) {
 			return Database.getQueryLocator([Select 
									 								AS_Current_CPD_Plan__c,
									 								AS_Plan_Year__c,
									 								AsUser__c,
									 								Id,
									 								Name,
									 								recordTypeId 
									 							from 
									 								AsCPDPlanner__c 
									 							where							
									 								AS_Current_CPD_Plan__c = true
									 							and
									 								recordTypeId = :activeCPDRecId
									 							]);
 		} else {
 			return null;
 		}
  }

 	public void execute(Database.BatchableContext BC, List<AsCPDPlanner__c> scope) {
 		Savepoint sp = Database.setSavepoint();
 		try {
	 		Id inactiveCPDRecId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByName().get('Inactive CPD Planner').getRecordTypeId();
	 		
	 		List<AsCPDPlanner__c> tobeUpdatedCPDList = new List<AsCPDPlanner__c>();
	 		
	 		// for update of other cpd to inactive
	 		for(AsCPDPlanner__c cpd : scope) {
	 			AsCPDPlanner__c indiUpdatedCPD = new AsCPDPlanner__c();
	 			indiUpdatedCPD.Id = cpd.Id;
	 			indiUpdatedCPD.AS_Current_CPD_Plan__c = false;
	 			indiUpdatedCPD.AsGenerateCPDsummary__c = false;
	 			indiUpdatedCPD.recordTypeId = inactiveCPDRecId;
	 			tobeUpdatedCPDList.add(indiUpdatedCPD);
	 		}
	 		
	 		System.debug('tobeUpdatedCPDList : ' + tobeUpdatedCPDList);
	 		if(tobeUpdatedCPDList.size() > 0) {
	 			database.update(tobeUpdatedCPDList,false);
	 		}	
 		} catch (Exception e) {
 			Database.rollback(sp);
 		}
 	}
 	
 	public void finish(Database.BatchableContext BC) {
 		ASCPDPlannerManualCreateBatch manualBatch2 = new ASCPDPlannerManualCreateBatch(cpdYear,cpdCurrent);
		database.executeBatch(manualBatch2);
 	}
}