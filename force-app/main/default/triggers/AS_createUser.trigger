/*
* Author : WEW
* Description: Trigger use for creation of user when opportunity is close won and user does not exist
* Parameter : None
* Return : None
*/
trigger AS_createUser on AS_Subscription__c (after insert,after update) {
	List<Profile> pro = [Select Id,Name from Profile where Name='Member Login User' LIMIT 1];  // this is a static query
    if(trigger.isInsert){
    	List<Id> allAccIdList = new List<Id>();
    	List<String> allUserEmailList = new List<String>();
    	Map<Id,Id> allAccCon = new Map<Id,Id>();
    	Map<Id,String> allAccEmail = new Map<Id,String>();
    	
    	Map<Id,Id> allSubsMapforPDF = new Map<Id,Id>();
    	
    	Integer max25 = 0;
    	for(AS_Subscription__c sub : Trigger.New) {
    		System.debug('The sub : ' + sub );
    		if(sub.Account__c != null && sub.AS_Type__c == 'Member') {
    			allAccIdList.add(sub.Account__c);
    		}
    		
    		// added for creation of pdf starts here
    		if(sub.AS_Membership_Status__c == 'Current' && sub.AS_Generate_Subscription__c == true && max25<= 25){
    			allSubsMapforPDF.put(sub.Id,sub.Account__c);
    			max25++;
    		}
			// added for creation of pdf ends here
    	}
    	
    	// call the pdf creator class starts here
    	if(allSubsMapforPDF.size()>0) {
	    	System.debug('allSubsMapforPDF : ' + allSubsMapforPDF);
	    	AS_pdfTriggerController.addPDFAttach(allSubsMapforPDF);
    	}
    	// call the pdf creator class end here
    	System.debug('The allAccIdList : ' + allAccIdList );
    	List<Account> allAcc = [SELECT FirstName,Id,IsPersonAccount,PersonContactId,LastName,Name,AS_Sign_Up_Email__pc,PersonEmail,Salutation FROM Account where Id IN :allAccIdList];
    	
    	for(Account acc : allAcc){
    		if(acc.AS_Sign_Up_Email__pc != null) {
    			allUserEmailList.add(acc.AS_Sign_Up_Email__pc);
    			allAccCon.put(acc.Id,acc.PersonContactId);
    			allAccEmail.put(acc.Id,acc.AS_Sign_Up_Email__pc.toLowerCase().trim());
    		} else if(acc.PersonEmail != null) {
    			allUserEmailList.add(acc.PersonEmail);
    			allAccCon.put(acc.Id,acc.PersonContactId);
    			allAccEmail.put(acc.Id,acc.PersonEmail.toLowerCase().trim());
    		}
    	}
    	System.debug('allUserEmailList :' + allUserEmailList);
    	System.debug('allAccCon :' + allAccCon);
    	Map<String,Id> allFoundUser = new Map<String,Id>();
    	for(User user :[SELECT AccountId,Alias,CommunityNickname,CompanyName,ContactId,CreatedById,CreatedDate,Email,FirstName,Id,LastName,Username FROM User where Username IN :allUserEmailList]){
    		allFoundUser.put(user.Username.toLowerCase().trim(),user.Id);
    	}
    	System.debug('allFoundUser :' + allFoundUser);
    	List<User> allUserInsert = new List<User>(); 
    	List<User> allUserUpdate = new List<User>(); 
    	List<Id> allUserUpdateId = new List<Id>(); 
    	for(Account acc : allAcc){
    		User indiUser = new User();
    		String finalEmail = (acc.AS_Sign_Up_Email__pc != null)?acc.AS_Sign_Up_Email__pc:acc.PersonEmail;
    		if(String.isNotBlank(finalEmail)) {
    			System.debug('finalEmail :' + finalEmail);
    			if(allFoundUser.containsKey(finalEmail.toLowerCase().trim())){
    				indiUser.Id = allFoundUser.get(finalEmail.toLowerCase().trim());
    				indiUser.profileid = (pro.size() > 0)?pro[0].Id:null;
    				indiUser.Username = finalEmail;
    				allUserUpdate.add(indiUser);
    				
    				allUserUpdateId.add(allFoundUser.get(finalEmail.toLowerCase().trim()));
    				
    				
    			} else {
    				Database.DMLOptions dmlo = new Database.DMLOptions();
					dmlo.EmailHeader.triggerUserEmail = true;
					dmlo.EmailHeader.triggerAutoResponseEmail= true;
    				
    				indiUser.ContactId = allAccCon.get(acc.Id);
    				indiUser.profileid = (pro.size() > 0)?pro[0].Id:null;
    				indiUser.FirstName = acc.FirstName;
    				indiUser.LastName = acc.LastName;
    				indiUser.Alias =string.valueof(acc.FirstName.substring(0,1) + acc.LastName.substring(0,2));
    				indiUser.Email = finalEmail;
    				indiUser.Username = finalEmail;
    				indiUser.CommunityNickname = acc.FirstName + acc.LastName + AS_commonFunction.generateRandomIntString(2);
    				indiUser.emailencodingkey='UTF-8';
    				indiUser.languagelocalekey='en_US'; 
    				indiUser.localesidkey='en_AU'; 
                    indiUser.timezonesidkey='GMT';
                    
                    indiUser.setOptions(dmlo);
                    
    				allUserInsert.add(indiUser);
    			}
    			
    		}
    	}
    	System.debug('allUserInsert : ' + allUserInsert);
    	System.debug('allUserUpdate : ' + allUserUpdate);
    	
    	if(allUserInsert.size() > 0) {
    		insert allUserInsert;
    	}
    	
    	Map<String,Id> allSaveUser = new Map<String,Id>();
    	for(User user : allUserInsert) {
    		allSaveUser.put(user.Username.toLowerCase().trim(),user.Id);
    	}
    	for(User user : allUserUpdate) {
    		allSaveUser.put(user.Username.toLowerCase().trim(),user.Id);
    	}
    	System.debug('allSaveUser : ' + allSaveUser);
    	
    	List<AS_Subscription__c> allTobeUpdatedSubs = new List<AS_Subscription__c>();
    	for(AS_Subscription__c sub : Trigger.New) {
    		AS_Subscription__c indiUpdatedSubs = new AS_Subscription__c();
    		if(sub.Account__c != null && sub.AS_Type__c == 'Member') {
    			if(allSaveUser.get(allAccEmail.get(sub.Account__c)) != null){
    				indiUpdatedSubs.Id = sub.Id;
    				indiUpdatedSubs.AS_User__c =  allSaveUser.get(allAccEmail.get(sub.Account__c));
    				allTobeUpdatedSubs.add(indiUpdatedSubs);
    			}
    		}
    	}
    	System.debug('allTobeUpdatedSubs :' + allTobeUpdatedSubs);
    	if(allTobeUpdatedSubs.size() > 0) {
    		update allTobeUpdatedSubs;
    	}
    	// added to put the update user to future 2/9/17
    	if(allUserUpdateId.size() > 0) {
    		//AS_createUserFuture.UpdateFutureUser(allUserUpdateId);
    		System.enqueueJob(new AS_createUserFuture(allUserUpdateId));
    	}
    	
    	
    	
    } else if(trigger.isUpdate){
    	Integer max25 = 0;
    	Map<Id,Id> allSubsMapforPDF = new Map<Id,Id>();
    	
    	// code block for ticket #PSA-316 starts here 
    	List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
    	EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='Connect_With_PSA'];
    	List<OrgWideEmailAddress> owea = [select Id,Address from OrgWideEmailAddress where Address = 'noreply@psa.org.au'];
    	
    	Set<Id> allConPerIdSet = new Set<Id>();
    	for(AS_Subscription__c sub : Trigger.New) {
    		if(sub.AS_User__c != null) {
    			allConPerIdSet.add(sub.AS_User__c);
    		}
    	}
    	
    	Map<Id,Id> userConForEmail = new Map<Id,Id>();
    	if(allConPerIdSet.size() > 0) {
    		for(User theUser : [Select Id,contactId from User where Id IN :allConPerIdSet]) {
    			if(theUser.contactId != null) {
    				userConForEmail.put(theUser.Id,theUser.contactId);
    			}
    		}
    	}
    	// code block for ticket #PSA-316 ends here 
    	
    	for(AS_Subscription__c sub : Trigger.New) {
    		// added for creation of pdf starts here
    		Boolean oldGenerate  = Trigger.OldMap.get(sub.Id).AS_Generate_Subscription__c;
    		Boolean newGenerate  = Trigger.NewMap.get(sub.Id).AS_Generate_Subscription__c;
    		String oldStatus  = Trigger.OldMap.get(sub.Id).AS_Membership_Status__c;
    		String newStatus  = Trigger.NewMap.get(sub.Id).AS_Membership_Status__c;
    		if(sub.AS_Membership_Status__c == 'Current' && sub.AS_Generate_Subscription__c == true && max25<= 25 &&  (oldGenerate != newGenerate || oldStatus != newStatus)){
    			allSubsMapforPDF.put(sub.Id,sub.Account__c);
    			max25++;
    		}
    		// added for creation of pdf ends here
    		
    		// code block for ticket #PSA-316 starts here 
    		if(oldStatus == 'Pending' && newStatus == 'Current' && sub.Account__c != null && sub.AS_User__c != null && userConForEmail.containsKey(sub.AS_User__c) ) {
    			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        	mail.setTemplateId(et.Id);
        	mail.setTargetObjectId( userConForEmail.get(sub.AS_User__c) );
   				mail.setWhatId( sub.Account__c  );
                        
        	if(owea.size()>0) {
							mail.setorgWideEmailAddressId(owea[0].Id);
					}
                        
	        mail.setSaveAsActivity(false);
	        allmsg.add(mail);
    		}
    		// code block for ticket #PSA-316 ends here 
			
    	}
    	
    	// call the pdf creator class starts here
    	if(allSubsMapforPDF.size()>0) {
    		System.debug('allSubsMapforPDF : ' + allSubsMapforPDF);
	    	AS_pdfTriggerController.addPDFAttach(allSubsMapforPDF);
	    }
    	// call the pdf creator class end here
    	
    	// code block for ticket #PSA-316 starts here 
    	if(allmsg.size() > 0) {
    		System.debug('allmsg :  ' + allmsg);
    		Messaging.SendEmailResult[] allEmailRes = Messaging.sendEmail(allmsg,false);
    		System.debug('allEmailRes : ' + allEmailRes);
    	}
    	// code block for ticket #PSA-316 ends here 
    }
}