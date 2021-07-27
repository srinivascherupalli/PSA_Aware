/*
* Author : papa doms
* Description: Checks expired or grace period subscriptions and changes their respective user's profile.
* Parameter : 
* Return : 
*/

trigger AS_expiredSubscription on AS_Subscription__c (before update) {
    List<User> listUserUpdate = new List<User>();
    List<Profile> listProfile = [Select Id,Name from Profile where Name='Non Member Login User' LIMIT 1];
    Set<Id> setUserId = new Set<Id>();
    Set<Id>  setAccountId = new Set<Id>();
    Map<Id,Account> mapIdAccount = new Map<Id,Account>();
    //Map<Id,User> mapIdUser = new Map<Id,User>();
    List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

    EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='AS_Expired_Membership_Subscription'];
    
    List<OrgWideEmailAddress> owea = [select Id,Address from OrgWideEmailAddress where Address = 'noreply@psa.org.au'];

    for(AS_Subscription__c subscription : Trigger.new){
        //setUserId.add(subscription.AS_User__c);

        setAccountId.add(subscription.Account__c); 
    }

    //for(User usr : [Select Id, Name, Email from User where Id IN :setUserId]){
    //  mapIdUser.put(usr.Id,usr);
    //}

    for(Account acc : [Select Id, Name,PersonContactId from Account where Id IN:setAccountId]){
        mapIdAccount.put(acc.Id, acc);
    }

    for(AS_Subscription__c subscription : Trigger.new){
			try { // added since there are possibility that an error will occur like ticket (#PSA-390) for example the account record type is not person account
        if( (Trigger.oldMap.get(subscription.Id).AS_Membership_Status__c !=  'Expired' &&  Trigger.newMap.get(subscription.Id).AS_Membership_Status__c ==  'Expired') || (Trigger.oldMap.get(subscription.Id).AS_Membership_Status__c !=  'Grace Period' &&  Trigger.newMap.get(subscription.Id).AS_Membership_Status__c ==  'Grace Period')){
            if(subscription.AS_Type__c == 'Member' && subscription.AS_User__c != null && listProfile.size()>0){
              if(subscription.AS_Membership_Status__c == 'Expired'){
                
                setUserId.add(subscription.AS_User__c);
								//email
                Id contactId = mapIdAccount.get(subscription.Account__c).PersonContactId;
                if(contactId!=null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(et.Id);
                    mail.setTargetObjectId( contactId );
   									mail.setWhatId( subscription.Id  );
                    
                	if(owea.size()>0) {
											mail.setorgWideEmailAddressId(owea[0].Id);
										}
                    
                    mail.setSaveAsActivity(false);
                    allmsg.add(mail);
                }
								//email
            	} else if(subscription.AS_Membership_Status__c == 'Grace Period') {
            		setUserId.add(subscription.AS_User__c);
            	}
            }//if
        }

			} catch (Exception e) {
			}
    }//for

    //Messaging.sendEmail(allmsg,false);
    //update listUserUpdate;
    if( setUserId.size()>0 ){
        //AS_commonFunction.updateUsers(setUserId);
        System.enqueueJob(new AS_queuUpdateUsers(setUserId));
    }
    

}//trigger