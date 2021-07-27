/*Author : John Hope
*Description : This is a class that handles User File Object Trigger.
*Date Created : June 1, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : User
*/
public class AsUserTriggerHandler {
	private boolean isExecutingBool = false;
	
	/*Author : John Hope
	*Description : this is a constructor
	*Date Created : June 1, 2018
	*Last Modified By : 
	*Date Last Modified : June 1, 2018
	*Related Meta Data :
	*Param : 
		0. boolean - set value for isExecutingBool 
	*Return : 
 	*/
	public AsUserTriggerHandler(boolean isExecuting){
		isExecutingBool = isExecuting;
	}
	
	/*Author : John Hope
	*Description : handler for before insert trigger for object User
	*Date Created : June 1, 2018
	*Last Modified By : 
	*Date Last Modified : June 1, 2018
	*Related Meta Data :
	*Param : 
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
	public void OnBeforeInsert(Object[] newObjects){
	    // EXECUTE BEFORE INSERT LOGIC
	}
	
	/*Author : John Hope
	*Description : handler for after insert trigger for object User
	*Date Created : June 1, 2018
	*Last Modified By : 
	*Date Last Modified : June 1, 2018
	*Related Meta Data :
	*Param :
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
	public void OnAfterInsert(Object[] newObjects,Map<Id,Object> newMapObjects){
		createDepRecord(newObjects, new Map<Id,Object>(),newMapObjects,'INSERT');
	}
	
	/*Author : John Hope
	*Description : handler for before update trigger for object User
	*Date Created : June 1, 2018
	*Last Modified By : 
	*Date Last Modified : June 1, 2018
	*Related Meta Data :
	*Param :
		0. List<Object> - the old Object from trigger
		1. List<Object> - the new Object from trigger
		2. List<Object> - the new Map Object from trigger
	*Return : 
 	*/
	public void OnBeforeUpdate(Object[] updatedObjects,Map<Id,Object> oldMap,Map<Id,Object> newMap){
		// BEFORE UPDATE LOGIC
		//avoidUserAndEmailUpdate(updatedObjects, oldMap, newMap);
		
	}
	
	/*Author : John Hope
	*Description : handler for after update trigger for object User
	*Date Created : June 1, 2018
	*Last Modified By : 
	*Date Last Modified : June 1, 2018
	*Related Meta Data :
	*Param :
		0. List<Object> - the old Object from trigger
		1. List<Object> - the new Object from trigger
		2. List<Object> - the new Map Object from trigger
	*Return : 
 	*/
	public void OnAfterUpdate(Object[] updatedObjects,Map<Id,Object> oldMap,Map<Id,Object> newMap){
		
		/*
		// check if profile is PSA Member
		Map<Id,User> oldObjectMap = (Map<Id,User>) oldMap;
		Map<Id,User> newObjectMap = (Map<Id,User>) newMap;
		List<Profile> pro = [Select Id,Name from Profile where Name='Member Login User' LIMIT 1];  // this is a static query]
		System.debug('updatedObjects :' + updatedObjects);
		System.debug('oldObjectMap :' + oldObjectMap);
		System.debug('newObjectMap :' + newObjectMap);
		
		if(pro.size() > 0) {
			List<AsCPDPlannerReview__c> cpdPlannerRevList = new List<AsCPDPlannerReview__c>();
			for(User use :(List<User>) updatedObjects) {
				Id oldProfId  = oldObjectMap.get(use.Id).ProfileId;
				Id newProfId  = newObjectMap.get(use.Id).ProfileId;
				if(use.ProfileId == pro[0].Id && oldProfId != newProfId){
					AsCPDPlannerReview__c singlecpdPlannerRev = new AsCPDPlannerReview__c();
					singlecpdPlannerRev.Name = use.Name;
					singlecpdPlannerRev.AsUser__c = use.Id;
					cpdPlannerRevList.add(singlecpdPlannerRev);
				}
			}
			AsUserTriggerHandler.createPlannerReview(JSON.serialize(cpdPlannerRevList));
		//	insert cpdPlannerRevList;
		}
		*/
		
		updateAccountFuture(updatedObjects,oldMap,newMap);
		createDepRecord(updatedObjects, oldMap,newMap,'UPDATE');
		
	}
	
	/*Author : John Hope
	*Description : checker if trigger is running
	*Date Created : June 1, 2018
	*Last Modified By : 
	*Date Last Modified : June 1, 2018
	*Related Meta Data :
	*Param : 
	*Return : boolean
 	*/
	public boolean IsTriggerContext{
	    get{ return isExecutingBool;}
	}
	
	public static boolean runUpdateAcc = true;
	
	/*Author : John Hope
	*Description : check the runUpdateAcc variable and use for recursion
	*Date Created : May 29, 2018
	*Last Modified By : 
	*Date Last Modified : May 29, 2018
	*Related Meta Data :
	*Param :
		0. List<Object> - the new object data list from trigger
	*Return : 
 	*/
	public static boolean runOnceUpdateAcc(){
	    if(runUpdateAcc){
	     runUpdateAcc=false;
	     return true;
	    }else{
	        return runUpdateAcc;
	    }
	}
	
	/*Author : John Hope
	*Description : Create new record for cpd planner review, permission set for almond and etc. when adding new user
	*Date Created : August 1, 2018
	*Last Modified By : 
	*Date Last Modified : August 1, 2018
	*Related Meta Data :
	*Param :
		0. Object - the trigger.new list
		1. Map<Id,Object> - the trigger.oldMap list
		2. Map<Id,Object> - the trigger.newMap list
		3. String - the trigger action
	*Return : 
 	*/
	public static void createDepRecord(Object[] newObject,Map<Id,Object> oldMap,Map<Id,Object> newMap,String action) {
		System.debug('runOncerunCPDAndPerm ...'+ runCPDAndPerm);
		if(runOncerunCPDAndPerm()) {
			System.debug(runCPDAndPerm + ' - runOncerunCPDAndPerm ...'+ newObject.size() + ' - ' + newObject);
			List<PermissionSetAssignment> allTobeAddedPermSetAssign = new List<PermissionSetAssignment>();
			Id activeCPDRecId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByName().get('Active CPD Planner').getRecordTypeId();
			Set<String> almondAdminPro = new Set<String>{
																								'contract manager',
																								'marketing user',
																								'psa exec team',
																								'psa membership staff user',
																								'psa system administrator',
																								'solution manager',
																								'standard user',
																								'system administrator',
																								'test'
																								};
			Set<String> almondExternalPro = new Set<String>{
																										'member login user',
																										'non member login user'
																									};
			
			List<User> finalNew = new List<User>();
			String theSerializedOldMap = JSON.serialize(oldMap);
			String theSerializedNewMap = JSON.serialize(newMap);
			Map<Id,User> finalOldMap = (Map<Id, User>)JSON.deserialize(theSerializedOldMap,Map<Id, User>.class);
			Map<Id,User> finalNewMap = (Map<Id, User>)JSON.deserialize(theSerializedNewMap,Map<Id, User>.class);
			finalNew = (List<User>) newObject;
			
			Set<Id> allProfileIdSet = new Set<Id>();
			for(User use : finalNew) {
				allProfileIdSet.add(use.ProfileId);
			}
			
			
				
			Map<Id,User> allNewUserForCPDMap = new Map<Id,User>();
			Set<Id> userForAlmAdmPermSet = new Set<Id>();
			Set<Id> userForAlmExtPermSet = new Set<Id>();
			Set<Id> allMemAndNonMemPro = new Set<Id>();
			for(Profile pro :[SELECT Id FROM Profile WHERE Name='Member Login User' OR Name ='Non Member Login User']) {
				allMemAndNonMemPro.add(pro.Id);
			} 
			if(newMap.size() > 0) {
				for(User use : [Select Id,Profile.Name,isActive,Name from User where Id IN :newMap.KeySet()]) {
					if((use.Profile.Name == 'Member Login User' || use.Profile.Name == 'Non Member Login User') && (action == 'INSERT' || (action == 'UPDATE' && !allMemAndNonMemPro.contains(finalOldMap.get(use.Id).ProfileId)))) {
						allNewUserForCPDMap.put(use.Id,use);
					}
					if(use.isActive == true) {
						if(almondAdminPro.contains(use.Profile.Name.toLowerCase())) {
							userForAlmAdmPermSet.add(use.Id);
						} else if(almondExternalPro.contains(use.Profile.Name.toLowerCase())) {
							userForAlmExtPermSet.add(use.Id);
						}
					}
				}
			}
			
			if(action == 'INSERT') {
				Id almondAdminPermId;
				Id almondExterPermId;
				for(PermissionSet perSet : [Select Id,Name from PermissionSet where Name = 'LMS_Admin' OR Name = 'LMS_External_User']) {
					if(perSet.Name == 'LMS_Admin') {
						almondAdminPermId = perSet.Id;
					} else if(perSet.Name == 'LMS_External_User') {
						almondExterPermId = perSet.Id;
					}
				}
				
				Set<Id> allPermSet = new Set<Id>();
				if(almondAdminPermId != null) {
					allPermSet.add(almondAdminPermId);
				} 
				
				if(almondExterPermId != null) {
					allPermSet.add(almondExterPermId);
				}
				
				Map<String,Boolean> permAssCheckerMap = new Map<String,Boolean>();
				if(allPermSet.size() > 0 && newMap.size() > 0) {
					for(PermissionSetAssignment perSetAs : [Select AssigneeId,Id,PermissionSetId from PermissionSetAssignment where PermissionSetId IN :allPermSet AND  AssigneeId IN :newMap.KeySet()]) {
						permAssCheckerMap.put(String.valueOf(perSetAs.PermissionSetId).toLowerCase() + String.valueOf(perSetAs.AssigneeId).toLowerCase(),true);
					}
				}
				System.debug('permAssCheckerMap : ' + permAssCheckerMap);
				// for creation of new permission set assignment starts here
				if(almondAdminPermId != null) {
					for(Id adminUserId : userForAlmAdmPermSet){
						PermissionSetAssignment indiPermSetAss = new PermissionSetAssignment();
						indiPermSetAss.PermissionSetId = almondAdminPermId;
						indiPermSetAss.AssigneeId = adminUserId;
						System.debug('check permAssCheckerMap : ' + String.valueOf(almondAdminPermId).toLowerCase() + String.valueOf(adminUserId).toLowerCase());
						if(!permAssCheckerMap.containsKey(String.valueOf(almondAdminPermId).toLowerCase() + String.valueOf(adminUserId).toLowerCase())) {
							allTobeAddedPermSetAssign.add(indiPermSetAss);
						}
					}
				}
				
				if(almondExterPermId != null) {
					for(Id extUserId : userForAlmExtPermSet){
						PermissionSetAssignment indiPermSetAss = new PermissionSetAssignment();
						indiPermSetAss.PermissionSetId = almondExterPermId;
						indiPermSetAss.AssigneeId = extUserId;
						System.debug('check permAssCheckerMap : ' + String.valueOf(almondExterPermId).toLowerCase() + String.valueOf(extUserId).toLowerCase());
						if(!permAssCheckerMap.containsKey(String.valueOf(almondExterPermId).toLowerCase() + String.valueOf(extUserId).toLowerCase())) {
							allTobeAddedPermSetAssign.add(indiPermSetAss);
						}
					}
				}
				// for creation of new permission set assignment ends here 
			}
			
			
			
			// for creation of new cpd planner starts here
			Map<Id,String> allFoundPlannerMap = new Map<Id,String>();
			String yearNow = String.valueOf(Date.today().year());
			if(allNewUserForCPDMap.size() > 0) {
				for(AsCPDPlanner__c loopExistPlanner : [Select 
																										AsUser__c,
																										Id,
																										Name 
																									from 
																										AsCPDPlanner__c 
																									where 
																										AsUser__c IN :allNewUserForCPDMap.keySet()
																									and
																										AS_Plan_Year__c  = :yearNow
																									]) {
					allFoundPlannerMap.put(loopExistPlanner.AsUser__c,loopExistPlanner.Name);
				}
			}
			List<AsCPDPlanner__c> cpdPlannerList = new List<AsCPDPlanner__c>();
			for(Id plannerKey : allNewUserForCPDMap.KeySet()) {
				if(!allFoundPlannerMap.containsKey(plannerKey)){
					Integer finalYearDate;
					Date startDate = Date.newInstance(Date.Today().year(),10,1);
					Date endDate = Date.newInstance(Date.Today().year(),12,31);
					Date presentDate = Date.Today();
					
					if(Test.isRunningTest()){
						finalYearDate = Date.Today().year();
					} else {
						if(presentDate >= startDate && presentDate<=endDate) {
							finalYearDate = Date.Today().year()+1;
						} else {
							finalYearDate = Date.Today().year();
						}
					}
					AsCPDPlanner__c singlecpdPlanner = new AsCPDPlanner__c();
					singlecpdPlanner.recordTypeId = activeCPDRecId;
					singlecpdPlanner.Name = allNewUserForCPDMap.get(plannerKey).Name + ' - CPD Plan - ' + finalYearDate;
					singlecpdPlanner.AsUser__c = plannerKey;
	 				singlecpdPlanner.AS_Plan_Year__c = String.valueOf(finalYearDate);
	 				singlecpdPlanner.AsStartDate__c = Date.newInstance(finalYearDate-1,10,1);
	 				singlecpdPlanner.AsEndDate__c = Date.newInstance(finalYearDate,9,30);
	 				singlecpdPlanner.AS_Current_CPD_Plan__c = true;
	 				singlecpdPlanner.AsGenerateCPDsummary__c = false;
					cpdPlannerList.add(singlecpdPlanner);
				}
			}
			// for creation of new cpd planner ends here
			
			if(allTobeAddedPermSetAssign.size()>0 || cpdPlannerList.size() > 0) {
				System.debug('cpdPlannerList : ' + cpdPlannerList);
				if(!System.isFuture() && !System.isBatch()){
					if(cpdPlannerList.size() > 0) {
						runCreateNewCPDAsFuture(JSON.serialize(cpdPlannerList));  
					}
					if(allTobeAddedPermSetAssign.size()>0) {
						runCreatePermSetAsFuture(JSON.serialize(allTobeAddedPermSetAssign)); 
					}
				} 
		    AsUserTriggerHandler.runCPDAndPerm = false;
			} else {
				 AsUserTriggerHandler.runCPDAndPerm = true;
			}
		}
	}
	
	public static boolean runCPDAndPerm = true;
	
	/*Author : John Hope
	*Description : check the run variable and use for recursion
	*Date Created : May 29, 2018
	*Last Modified By : 
	*Date Last Modified : May 29, 2018
	*Related Meta Data :
	*Param :
		0. List<Object> - the new object data list from trigger
	*Return : 
 	*/
	public static boolean runOncerunCPDAndPerm(){
	    if(runCPDAndPerm){
	     runCPDAndPerm=false;
	     return true;
	    }else{
	        return runCPDAndPerm;
	    }
	}
	
	
	/*Author : John Hope
	*Description : update corresponding account for the user 
	*Date Created : May 29, 2018
	*Last Modified By : 
	*Date Last Modified : May 29, 2018
	*Related Meta Data :
	*Param :
		0. String - the json string of Account List
	*Return : 
 	*/
	
	public static void updateAccountFuture(Object[] updatedObjects,Map<Id,Object> oldMap,Map<Id,Object> newMap) {
		if(runOnceUpdateAcc()) {
			System.debug(' This is running 2');
			Set<Id> allUserContactIdSet = new Set<Id>();
			
			for(User use :(List<User>) updatedObjects) {
				allUserContactIdSet.add(use.ContactId);
			}
			System.debug(' allUserContactIdSet');
			Map<Id,Id> conAccMap = new Map<Id,Id>();
			if(allUserContactIdSet.size() > 0) {
				for(Contact con : [Select AccountId,Id,Name from Contact where Id IN :allUserContactIdSet and IsPersonAccount = true]) {
					conAccMap.put(con.Id,con.AccountId);
				}
			}
			System.debug(' conAccMap : '+ conAccMap);
			List<Account> alltobeUpdatedAccountList = new List<Account>();
			for(User use :(List<User>) updatedObjects) {
				if(conAccMap.containsKey(use.ContactId)) {
					Account singleAccount = new Account();
					singleAccount.Id =  conAccMap.get(use.ContactId);
					singleAccount.FirstName = use.FirstName;
					singleAccount.LastName = use.LastName;
					singleAccount.PersonMailingStreet = use.Street;
					singleAccount.PersonMailingCity = use.City;
					singleAccount.PersonMailingState = use.State;
					singleAccount.PersonMailingPostalCode = use.PostalCode;
					singleAccount.PersonMailingCountry = use.Country;
					singleAccount.PersonEmail = use.Email;
					singleAccount.Salutation = use.Title;
					singleAccount.Phone = use.Phone;
					singleAccount.PersonMobilePhone = use.MobilePhone;
					
					alltobeUpdatedAccountList.add(singleAccount);
					
				}
			}
			if(alltobeUpdatedAccountList.size()>0) {
			//	update alltobeUpdatedAccountList;
				if(!System.isFuture() && !System.isBatch()){
					System.debug('alltobeUpdatedAccountList :' +alltobeUpdatedAccountList);
					runUpdateAccountFuture(JSON.serialize(alltobeUpdatedAccountList));
					AsUserTriggerHandler.runUpdateAcc = false;
				} else {
					System.debug('already in future');
				}
		    
			} else {
				 AsUserTriggerHandler.runUpdateAcc = true;
			}
			
			

		}
	}
	
	/*Author : John Hope
	*Description : update corresponding account for the user 
	*Date Created : June 21, 2018
	*Last Modified By : 
	*Date Last Modified : June 21, 2018
	*Related Meta Data :
	*Param :
		0. String - the json string of Account List
	*Return : 
 	*/
 	@future
	public static void runUpdateAccountFuture(String theDatatoUpdate) {
		List<Account> allAccount = (List<Account>)JSON.deserialize(theDatatoUpdate,List<Account>.class);
		if(allAccount.size() > 0) {
			Update allAccount;
		}
		
	}
	
	/*Author : John Hope
	*Description : create permission sets for new user
	*Date Created : August 1, 2018
	*Last Modified By : 
	*Date Last Modified : August 1, 2018
	*Related Meta Data :
	*Param :
		0. String - the json string of permissionSetAssigment
	*Return : 
 	*/
 	@future
	public static void runCreatePermSetAsFuture(String theDatatoInsert) {
		List<PermissionSetAssignment> allPermSetAssList = (List<PermissionSetAssignment>)JSON.deserialize(theDatatoInsert,List<PermissionSetAssignment>.class);
		System.debug('allPermSetAssList : ' + allPermSetAssList);
		if(allPermSetAssList.size() > 0) {
			database.insert(allPermSetAssList,false);
		}
	}
	
	/*Author : John Hope
	*Description : create cpd planner review and cpd plan for new user
	*Date Created : August 1, 2018
	*Last Modified By : 
	*Date Last Modified : August 1, 2018
	*Related Meta Data :
	*Param :
		0. String - the json string of permissionSetAssigment
	*Return : 
 	*/
 	@future
	public static void runCreateNewCPDAsFuture(String theCPDtoInsert) {
		List<AsCPDPlanner__c> allCpdList = (List<AsCPDPlanner__c>)JSON.deserialize(theCPDtoInsert,List<AsCPDPlanner__c>.class);
		if(allCpdList.size() > 0) {
			insert allCpdList;
		}
	}
	
}