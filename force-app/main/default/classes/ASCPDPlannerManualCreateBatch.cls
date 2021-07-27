/*Author : John Hope
*Description : This is a class that handles batch process creation of CPD's base on the given year
*Date Created : August 8, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : 
*/
public class ASCPDPlannerManualCreateBatch implements Database.batchable<SObject>,Database.Stateful {
 	public String cpdYear { get;set; }
	public Boolean cpdCurrent { get;set; }
	public Id memberProfileId = [SELECT Id,Name FROM Profile WHERE Name = 'Member Login User'].Id;
	public Id nonMemberProfileId = [SELECT Id,Name FROM Profile WHERE Name = 'Non Member Login User'].Id;
 	
 	public ASCPDPlannerManualCreateBatch(String year,Boolean current) {	
 		cpdYear = year;
		cpdCurrent = current;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString;
        if(Test.isRunningTest()){
			queryString ='SELECT Id,ProfileId,IsActive,Name '+
							'FROM User '+ 
							'WHERE ProfileId IN (\''+
							memberProfileId+
							'\',\''+
							nonMemberProfileId+
            				'\') AND IsActive =true '+
                			'LIMIT 50';}
        else{
            queryString ='SELECT Id,ProfileId,IsActive,Name '+
							'FROM User '+ 
							'WHERE ProfileId IN (\''+
							memberProfileId+
							'\',\''+
							nonMemberProfileId+
            				'\') AND IsActive =true';
        }
		System.debug(queryString);
		return Database.getQueryLocator(queryString);
  }

 	public void execute(Database.BatchableContext BC, List<User> scope) {
 		Id activeCPDRecId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByName().get('Active CPD Planner').getRecordTypeId();
 		Id inactiveCPDRecId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByName().get('Inactive CPD Planner').getRecordTypeId();
 		
        System.debug(activeCPDRecId);
        System.debug(inactiveCPDRecId);
        
 		Boolean setToActive;
 		Id theRecordType;
 		if(Integer.valueOf(Date.today().year()) == Integer.valueOf(cpdYear) || cpdCurrent == true) {
 			setToActive = true;
 			theRecordType = activeCPDRecId;
 		} else {
 			setToActive = false;
 			theRecordType = inactiveCPDRecId;
 		}
 		
 		map<Id,User> allUserMap = new Map<Id, User>(scope);
 		map<String,Id> allExistCPDMap = new map<String,Id>(); 
 		List<AsCPDPlanner__c> tobeUpdatedCPDList = new List<AsCPDPlanner__c>();
 		List<AsCPDPlanner__c> tobeAddedUpdatedCPDList = new List<AsCPDPlanner__c>();
 		
 		// for update of other cpd to inactive
 			if(setToActive == true) {
	 			for(AsCPDPlanner__c cpd :[Select 
	 																AS_Current_CPD_Plan__c,
	 																AS_Plan_Year__c,
	 																AsUser__c,
	 																Id,
	 																Name,
	 																recordTypeId 
	 															from 
	 																AsCPDPlanner__c 
	 															where 
	 																(
	 																	AsUser__c NOT IN :allUserMap.KeySet()
	 																or
	 																	AS_Plan_Year__c != :cpdYear
	 																)								
	 															and
	 																AS_Current_CPD_Plan__c = true
	 															and
	 																recordTypeId = :activeCPDRecId
	 															]) {
	 			AsCPDPlanner__c indiUpdatedCPD = new AsCPDPlanner__c();
	 			indiUpdatedCPD.Id = cpd.Id;
	 			indiUpdatedCPD.AS_Current_CPD_Plan__c = false;
	 			indiUpdatedCPD.AsGenerateCPDsummary__c = false;
	 			indiUpdatedCPD.recordTypeId = inactiveCPDRecId;
	 			tobeUpdatedCPDList.add(indiUpdatedCPD);
	 		}
 		}
 					
 		for(AsCPDPlanner__c cpd :[Select 
 																AS_Current_CPD_Plan__c,
 																AS_Plan_Year__c,
 																AsUser__c,
 																Id,
 																Name,
 																recordTypeId 
 															from 
 																AsCPDPlanner__c 
 															where 
 																AsUser__c IN :allUserMap.KeySet()
 															]) {
 			if(cpd.AsUser__c != null) {
 				allExistCPDMap.put(String.valueOf(cpd.AsUser__c).toLowerCase() + cpd.AS_Plan_Year__c,cpd.Id);
 			}
 		}
 		System.debug('tobeUpdatedCPDList : ' + tobeUpdatedCPDList);
 		if(tobeUpdatedCPDList.size() > 0) {
 			database.update(tobeUpdatedCPDList,false);
 		}
 		
 		for(User theUser : scope) {
 			System.debug('userTobeProcess 2 : ' + String.valueOf(theUser.Id).toLowerCase() + cpdYear);
 			if(allExistCPDMap.containsKey(String.valueOf(theUser.Id).toLowerCase() + cpdYear)){
 				System.debug('userTobeProcess 2 if : ');
 				if(cpdCurrent == true) {
 					AsCPDPlanner__c indiAddedUpdatedCPD = new AsCPDPlanner__c();
 					indiAddedUpdatedCPD.Id = allExistCPDMap.get(String.valueOf(theUser.Id).toLowerCase() + cpdYear);
 					indiAddedUpdatedCPD.AS_Current_CPD_Plan__c = true;
 					indiAddedUpdatedCPD.recordTypeId = activeCPDRecId;
 					indiAddedUpdatedCPD.AsGenerateCPDsummary__c = false;
 					tobeAddedUpdatedCPDList.add(indiAddedUpdatedCPD);
 				}
 			} else {
 				System.debug('userTobeProcess 2 else : ' + ' - ' + theRecordType + ' - ' + setToActive);
 				
 				AsCPDPlanner__c indiAddedUpdatedCPD = new AsCPDPlanner__c();
 				indiAddedUpdatedCPD.recordTypeId = theRecordType;
 				indiAddedUpdatedCPD.Name = theUser.Name + ' - CPD Plan - ' + cpdYear;
 				indiAddedUpdatedCPD.AsUser__c = theUser.Id;
 				indiAddedUpdatedCPD.AS_Plan_Year__c = cpdYear;
 				indiAddedUpdatedCPD.AsStartDate__c = Date.newInstance(Integer.valueOf(cpdYear)-1,10,1);
 				indiAddedUpdatedCPD.AsEndDate__c = Date.newInstance(Integer.valueOf(cpdYear),9,30);
 				indiAddedUpdatedCPD.AS_Current_CPD_Plan__c = setToActive;
 				indiAddedUpdatedCPD.AsGenerateCPDsummary__c = false;
 				tobeAddedUpdatedCPDList.add(indiAddedUpdatedCPD);
 			}
 		}
 		System.debug('tobeAddedUpdatedCPDList : ' + tobeAddedUpdatedCPDList);
 		if(tobeAddedUpdatedCPDList.size() > 0) {
 			database.upsert(tobeAddedUpdatedCPDList,false);
 		}
 		
 		
 	}
 	
 	public void finish(Database.BatchableContext BC) {
 		
 	}
}