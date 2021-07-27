/*Author : John Hope
*Description : This is a class that handles Contact File Object Trigger.
*Date Created : 
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : Contact
*/
public class AsContactTriggerHandler {
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
    public AsContactTriggerHandler(boolean isExecuting){
        isExecutingBool = isExecuting;
    }
    
    /*Author : John Hope
    *Description : handler for before insert trigger for object Contact
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
    }
    
    /*Author : John Hope
    *Description : handler for after insert trigger for object Contact
    *Date Created : 
    *Last Modified By : 
    *Date Last Modified : 
    *Related Meta Data :
    *Param :
        0. List<Object> - the new Object from trigger
    *Return : 
    */
    public void OnAfterInsert(Object[] newObjects,Map<Id,Object> newMapObjects) {
        System.debug('INSERT TRIGGER');
        createMemberMatch(newObjects,'INSERT');
        updateAccountPrimaryContact(newObjects);
    }
    
    /*Author : John Hope
    *Description : handler for before update trigger for object Contact
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
        System.debug('UPDATE TRIGGER');
        createMemberMatch(updatedObjects,'UPDATE');
    }
    
    /*Author : John Hope
    *Description : handler for after update trigger for object Contact
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
        processOnUpdateContact(updatedObjects,oldMap,newMap);
        updateAccountPrimaryContact(updatedObjects);
    }
    
    /*Author : John Hope
    *Description : handler for before delete trigger for object Contact
    *Date Created : 
    *Last Modified By : 
    *Date Last Modified : 
    *Related Meta Data :
    *Param : List<Contact>,List<Contact>
        0. List<Contact> - the old Contact data from trigger
        1. Map<Id,Contact> - the old Map data from trigger
    *Return : 
    */
    public void OnBeforeDelete(Object[] oldObjects,Map<Id,Object>  MapObjectMap){
    }
    
    /*Author : John Hope
    *Description : handler for after delete trigger for object Contact
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
    *Description : handler for undelete trigger for object Contact
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
    
     /*Author : John Hope
    *Description : method to process after contact update(#PSABG-47)
    *Date Created : 
    *Last Modified By : 
    *Date Last Modified : 
    *Related Meta Data :
    *Param : 
        0. List<Object> - the new Object from trigger
    *Return : List<Member_Match__c> - the newly created member match
    */
    public void processOnUpdateContact(List<Object> updatedObjects,Map<Id,Object> oldMap,Map<Id,Object> newMap) {
        List<Contact> allNewContact = new List<Contact>();
        Map<Id,Contact> finalOldMap = new Map<Id,Contact>();
        Map<Id,Contact> finalNewMap = new Map<Id,Contact>();
        allNewContact = (List<Contact>) updatedObjects;
        finalOldMap = (Map<Id,Contact>) oldMap;
        finalNewMap = (Map<Id,Contact>) newMap;
        
        Set<Id> tobeProConIdSet = new Set<Id>(); 
        
        for(Contact con : allNewContact) {
            if(finalOldMap.get(con.Id).AS_BG_Position_Description__c != finalNewMap.get(con.Id).AS_BG_Position_Description__c && finalOldMap.get(con.Id).AS_Moodle_Authentication__c != finalNewMap.get(con.Id).AS_Moodle_Authentication__c) {
                tobeProConIdSet.add(con.Id);
            }
        }
        List<LMS_User__c> updateLMSUserList = new List<LMS_User__c>(); 
        for(LMS_User__c lmsUser : [SELECT Id,As_Creation_Status__c,Firstname__c, Lastname__c,Email__c,AS_Authentication_Method__c,LMS_Instance__c FROM LMS_User__c WHERE AS_Banner_Group_Contact__c IN :tobeProConIdSet]) {
            system.debug('lmsUser==> :' + lmsUser);
            LMS_User__c updatenewlmsUser = new LMS_User__c();
            updatenewlmsUser.Id = lmsUser.Id;
            updatenewlmsUser.As_Creation_Status__c = 'In Progress';
            updateLMSUserList.add(updatenewlmsUser);
        }
        system.debug('updateLMSUserList==> :' + updateLMSUserList);
        
        update updateLMSUserList;
    }
    
	/*Author : John Hope
	*Description : method to create/edit member match when a new banner group contact is created (PSABG-24).
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param : 
	    0. List<Object> - the new Object from trigger
	*Return : List<Member_Match__c> - the newly created member match
	*/
	public void createMemberMatch(Object[] newObjects,String action) {
	    // EXECUTE BEFORE INSERT LOGIC
	    Map<Id,Id> memberMatchMap = new Map<Id,Id>();
	    Set<Id> allContactIdSet = new Set<Id>();
	    Set<String> allAHPRAIdSet = new Set<String>();
	    for(Contact con : (List<Contact>) newObjects) {
	        allContactIdSet.add(con.Id);
	        if(con.ASAHPRA_ID__c != null) { // added to avoid null values
       	 		allAHPRAIdSet.add(con.ASAHPRA_ID__c);
	        }
	    }
	    System.debug('allAHPRAIdSet :' + allAHPRAIdSet);
	    Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
	    Map<String,Account> allAccountMap  = new Map<String,Account>();
	    if(allAHPRAIdSet.size() > 0) {
		    for(Account acc : [Select
		                            PSA_PSA_ID__c, 
		                            AS_Membership_Status__pc,
		                            AS_AHPRA_Number__pc,
		                            Id,
		                            Name
		                        from 
		                            Account 
		                        where 
		                            AS_AHPRA_Number__pc IN :allAHPRAIdSet 
		                        AND 
		                        RecordTypeId = :personAccRecId
		                    ]) {
		        allAccountMap.put(acc.AS_AHPRA_Number__pc,acc);
		    }
	    }
	    System.debug('allAccountMap : ' + allAccountMap.size());
	    List<Member_Match__c> allMemMatchList = new List<Member_Match__c>();
	    for(Contact con : (List<Contact>) newObjects) {
	        if(con.ASAHPRA_ID__c != null && con.AS_Member_Match__c == null && allAccountMap.containsKey(con.ASAHPRA_ID__c)) {
	            String theStatus = allAccountMap.get(con.ASAHPRA_ID__c).AS_Membership_Status__pc;
	            if((theStatus == 'Pending' || theStatus == 'Current' || theStatus == 'Grace Period')) {
	                Member_Match__c memMatch = new Member_Match__c();
	                memMatch.AS_BG_Contact__c = con.Id;
	                memMatch.AS_PSA_Member__c = allAccountMap.get(con.ASAHPRA_ID__c).Id;
	                    memMatch.AS_AHPRAID__c = con.ASAHPRA_ID__c;
	                    memMatch.AS_PSAID__c = allAccountMap.get(con.ASAHPRA_ID__c).PSA_PSA_ID__c;
	                    allMemMatchList.add(memMatch);
	            }
	        }
	    }
	    if(allMemMatchList.size() > 0) {
	        insert allMemMatchList;
	        
	        List<Account> allTobeUpdatedAccMemMatch = new List<Account>();
	        for(Member_Match__c member : allMemMatchList) {
	            memberMatchMap.put(member.AS_BG_Contact__c,member.Id);
	            
	            Account indiTobeUpdatedAccMemMatch = new Account();
	            indiTobeUpdatedAccMemMatch.Id = member.AS_PSA_Member__c;
	            indiTobeUpdatedAccMemMatch.AS_Member_Match__pc = member.Id;
	            allTobeUpdatedAccMemMatch.add(indiTobeUpdatedAccMemMatch);
	        }
	        update allTobeUpdatedAccMemMatch;
	        
	        List<Contact> allTobeUpdatedCon = new List<Contact>();
	        if(action == 'INSERT') { // action is insert
	            for(Contact con : (List<Contact>) newObjects) {
	                Contact newCon =  new Contact();
	                newCon.Id = con.Id;
	                newCon.AS_Member_Match__c = memberMatchMap.get(con.Id);
	                allTobeUpdatedCon.add(newCon);
	            }
	            update allTobeUpdatedCon;
	        } else if(action == 'UPDATE') {
	            for(Contact con : (List<Contact>) newObjects) {
	                con.AS_Member_Match__c = memberMatchMap.get(con.Id);
	            }
	        }
	    }
	    
	    
}
    
	public static boolean runupdateAccountPrimaryContact = true;
	
	/*Author : John Hope
	*Description : check the run variable and use for recursion
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
		0. List<Object> - the new object data list from trigger
	*Return : 
 	*/
	public static boolean runOnceupdateAccountPrimaryContact(){
	    if(runupdateAccountPrimaryContact){
	     runupdateAccountPrimaryContact=false;
	     return true;
	    }else{
	        return runupdateAccountPrimaryContact;
	    }
	}
	
	public void updateAccountPrimaryContact(Object[] newObjects) {
		if(AsContactTriggerHandler.runOnceupdateAccountPrimaryContact()) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id,Id> updatePrimaryMap = new Map<Id,Id>();
        for (Contact c : (List<Contact>) newObjects) {
           // accountIds.add(c.AccountId);
            if(c.AccountId!=null && !updatePrimaryMap.containsKey(c.AccountId)){
                updatePrimaryMap.put(c.AccountId,c.Id);
                contactIds.add(c.Id);
            }
        }
        
        System.debug('accountIds :' + accountIds);
        System.debug('contactIds :' + contactIds);
        System.debug('updatePrimaryMap :' + updatePrimaryMap);
        
        List<Contact> allConUpdate = new List<Contact>();
        List<Account> allAccUpdate = new List<Account>();
        // comment by jet :  for(Account acc : [Select Id, Primary_Contact__c,(Select Id, Name, Primary_Contact__c from Contacts where Id NOT IN :contactIds) from Account where Id in :updatePrimaryMap.keySet()]){
        for(Account acc : [Select Id, Primary_Contact__c from Account where Id in :updatePrimaryMap.keySet()]){
            Account indiAccUpdate = new Account();
            indiAccUpdate.Id = acc.Id;
            indiAccUpdate.Primary_Contact__c = updatePrimaryMap.get(acc.Id);
            allAccUpdate.add(indiAccUpdate);
            
           /* System.debug('acc.Contacts.size() :' + acc.Contacts.size());
            if(acc.Contacts.size() > 0) {
                for(Contact cn :acc.Contacts){
                    Contact indiConUpdate = new Contact();
                    indiConUpdate.Id = cn.Id;
                    indiConUpdate.Primary_Contact__c = false;
                    allConUpdate.add(indiConUpdate);
                }
            }*/
        }
            
        //added by Jet     
        for(Contact cn : [SELECT Id,
                          		  Name, 
                         		  Primary_Contact__c 
                          FROM
           						Contact 
                          WHERE 
                          	AccountId IN :accountIds 
                          AND 
                          	Id NOT IN :contactIds]
         ){
                Contact indiConUpdate = new Contact();
                indiConUpdate.Id = cn.Id;
                indiConUpdate.Primary_Contact__c = false;
                allConUpdate.add(indiConUpdate);
        }
            
        
        
        System.debug('allAccUpdate :' + allAccUpdate);
        System.debug('allConUpdate :' + allConUpdate);
        if(allAccUpdate.size()>0) {
            update allAccUpdate;
            update allConUpdate;
            AsContactTriggerHandler.runupdateAccountPrimaryContact = false;
        } else {
            AsContactTriggerHandler.runupdateAccountPrimaryContact = true;
        }
        if(newObjects.size() == 200) {
        	AsContactTriggerHandler.runupdateAccountPrimaryContact = true;
        }
        
        
    }
	}
	
	
    
    
}