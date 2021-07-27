/*Author : John Hope
*Description : This is a class that handles Account File Object Trigger.
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : Account
*/
public class AsAccountTriggerHandler {
	private boolean isExecutingBool = false;
	
	/*Author : John Hope
	*Description : this is a constructor
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
		0. boolean - set value for isExecutingBool 
	*Return : 
 	*/
	public AsAccountTriggerHandler(boolean isExecuting){
		isExecutingBool = isExecuting;
	}
	
	/*Author : John Hope
	*Description : handler for before insert trigger for object Account
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
	public void OnBeforeInsert(Object[] newObjects){
	    // EXECUTE BEFORE INSERT LOGIC
	    prefillImporEmail(newObjects,new Map<Id,Object>(),new Map<Id,Object>(), 'insert');
	}
	
	/*Author : John Hope
	*Description : handler for after insert trigger for object Account
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the new Object from trigger
	*Return : 
 	*/
	public void OnAfterInsert(Object[] newObjects,Map<Id,Object> newMapObjects) {
		//createMemberMatch(newObjects);
	}
	
	/*Author : John Hope
	*Description : handler for before update trigger for object Account
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the old Object from trigger
		1. List<Object> - the new Object from trigger
		2. List<Object> - the new Map Object from trigger
	*Return : 
 	*/
	public void OnBeforeUpdate(Object[] updatedObjects, Map<Id,Object> oldMap, Map<Id,Object> newMap){
		// BEFORE UPDATE LOGIC
		//avoidLastNameUpdate(updatedObjects,oldMap,newMap);
		prefillImporEmail(updatedObjects,oldMap,newMap , 'update');
	}
	
	/*Author : John Hope
	*Description : handler for after update trigger for object Account
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the old Object from trigger
		1. List<Object> - the new Object from trigger
		2. List<Object> - the new Map Object from trigger
	*Return : 
 	*/
	public void OnAfterUpdate(Object[] updatedObjects,Map<Id,Object> oldMap,Map<Id,Object> newMap) {
		updateUserFuture(updatedObjects,oldMap,newMap);
//		createMemberMatch(updatedObjects);
	}
	
	/*Author : John Hope
	*Description : handler for before delete trigger for object Account
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : List<Account>,List<Account>
		0. List<Account> - the old Account data from trigger
		1. Map<Id,Account> - the old Map data from trigger
	*Return : 
 	*/
	public void OnBeforeDelete(Object[] oldObjects,Map<Id,Object>  MapObjectMap){
	
        
	}
	
	/*Author : John Hope
	*Description : handler for after delete trigger for object Account
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
		0. List<Object> - the old object data list from trigger
		1. Map<Id,Object> - the old object data map from trigger
	*Return : 
 	*/
	public void OnAfterDelete(Object[] deletedObjects,Map<Id,Object>  MapObjectMap){
	    // AFTER DELETE LOGIC
	}
	
	/*Author : John Hope
	*Description : handler for undelete trigger for object Account
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the new object data list from trigger
	*Return : 
 	*/
	public void OnUndelete(Object[] restoredObjects){
	    // AFTER UNDELETE LOGIC
	}
	
	/*Author : John Hope
	*Description : checker if trigger is running
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
	*Return : boolean
 	*/
	public boolean IsTriggerContext{
	    get{ return isExecutingBool;}
	}
	
	public static boolean runUpdateUser = true;
	
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
	public static boolean runOnceUpdateUser(){
	    if(runUpdateUser){
	     runUpdateUser=false;
	     return true;
	    }else{
	        return runUpdateUser;
	    }
	}
	
	/*Author : John Hope
	*Description : prefill important emails on create or update of account ()
	*Date Created : May 29, 2018
	*Last Modified By : 
	*Date Last Modified : May 29, 2018
	*Related Meta Data :
	*Param :
		0. String - the json string of User List
	*Return : 
 	*/
	public static void prefillImporEmail(Object[] theObjects,Map<Id,Object> oldMap,Map<Id,Object> newMap, String action) {
		for(Account acc :(List<Account>) theObjects) { 
			
			if( action == 'insert' ){

				if( acc.PersonEmail != null ){

					acc.AS_Sign_Up_Email__pc = acc.PersonEmail ; 

				} else {

					acc.PersonEmail = acc.AS_Sign_Up_Email__pc; 

				}

			} else if( action == 'update' ){

				if(acc.PersonEmail != null ) {

					acc.AS_Sign_Up_Email__pc = acc.PersonEmail; 
					 
				} 

			}

		} 
	}
	
	/*Author : John Hope
	*Description : update corresponding user for the Account 
	*Date Created : May 29, 2018
	*Last Modified By : 
	*Date Last Modified : May 29, 2018
	*Related Meta Data :
	*Param :
		0. String - the json string of User List
	*Return : 
 	*/
	public static void updateUserFuture(Object[] updatedObjects,Map<Id,Object> oldMap,Map<Id,Object> newMap) {
		 
		System.debug('Account after update');
		if(runOnceUpdateUser()) {
			System.debug('Account after update runOnceUpdateUser');
			Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
			Set<Id> allUserContactIdSet = new Set<Id>();
			
			for(Account acc :(List<Account>) updatedObjects) {
				if(acc.recordTypeId == personAccRecId) {
					allUserContactIdSet.add(acc.PersonContactId);
				}
			}
			System.debug('allUserContactIdSet : ' + allUserContactIdSet);
			
			// added and to be deleted
			List<User> allUse = [Select Id,Name,ContactId from User where ContactId IN :allUserContactIdSet];
			System.debug('allUse : ' + allUse);
			// added and to be deleted
			Map<Id,Id> conUserMap = new Map<Id,Id>();
			if(allUserContactIdSet.size() > 0) {
				for(User use : [Select ContactId,Id,Name,LastName from User where ContactId IN :allUserContactIdSet]) {
					conUserMap.put(use.ContactId,use.Id);
				}
			}
			System.debug('conUserMap : ' + conUserMap);
			List<User> alltobeUpdatedUserList = new List<User>();
			for(Account acc :(List<Account>) updatedObjects) {
				if(conUserMap.containsKey(acc.PersonContactId)) {
					System.debug(' acc error : ' + acc);
					User singleUser = new User();
					singleUser.Id =  conUserMap.get(acc.PersonContactId);
					singleUser.FirstName =  acc.FirstName;
					singleUser.LastName = acc.LastName;
					singleUser.Street = acc.PersonMailingStreet;
					singleUser.City= acc.PersonMailingCity;
					singleUser.State = acc.PersonMailingState;
					singleUser.PostalCode = acc.PersonMailingPostalCode;
					singleUser.Country = acc.PersonMailingCountry;
					if(acc.AS_Sign_Up_Email__pc != null) {
						singleUser.Email = acc.AS_Sign_Up_Email__pc; 
					} else if(acc.PersonEmail != null) {
						singleUser.Email = acc.PersonEmail; 
					}
					singleUser.Title = acc.Salutation;
					singleUser.Phone = acc.Phone;
					singleUser.MobilePhone = acc.PersonMobilePhone;
					
					alltobeUpdatedUserList.add(singleUser);
					
				}
			}
			System.debug('alltobeUpdatedUserList :' + alltobeUpdatedUserList);
			if(alltobeUpdatedUserList.size()>0) {
				//	update alltobeUpdatedUserList;
				if(!System.isFuture() && !System.isBatch()){
					System.debug('alltobeUpdatedUserList :' + alltobeUpdatedUserList);
					runUpdateUserFuture(JSON.serialize(alltobeUpdatedUserList)); 
				} 
		    AsAccountTriggerHandler.runUpdateUser = false;
			} else {
				 AsAccountTriggerHandler.runUpdateUser = true;
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
	public static void runUpdateUserFuture(String theDatatoUpdate) {
		List<User> allAccount = (List<User>)JSON.deserialize(theDatatoUpdate,List<User>.class);
		if(allAccount.size() > 0) {
			Update allAccount;
		}
	}
	
	
}