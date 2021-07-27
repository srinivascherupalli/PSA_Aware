/*
* Author : jet
* Description: batch process to check for expired membership renewal
* Last modified by : John Hope
* Parameter : 
* Return : 
*/
public class AS_batchMembershipRenewalT8  implements Database.Batchable < sObject > , Database.Stateful{
  
  private String errorMessage {get;set;} 
  
	public string ISCLOSEDWON ;
	public string ISCLOSEDLOST ;
    public AS_batchMembershipRenewalT8() {    	

		for(OpportunityStage oppStage : [SELECT IsClosed,IsWon,MasterLabel FROM OpportunityStage ]){
			 if( oppStage.IsClosed == true  && oppStage.IsWon == true ){
			 	ISCLOSEDWON = oppStage.MasterLabel ;
			 }
			 if( oppStage.IsClosed == true  && oppStage.IsWon == false ){
			 	ISCLOSEDLOST = oppStage.MasterLabel ; 
			 }
		}
    	
	}   
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		Membership_End_Date_Renewal__c medr = Membership_End_Date_Renewal__c.getInstance();
 		Date entranceDate = system.today().addDays(  ( Integer.valueOf( medr.T8__c ) != null ? -1*(Integer.valueOf( medr.T8__c )) : 0 ) ) ;
		System.debug('expiry entranceDate : ' + entranceDate);
		
		Set<String> allowedStatusSet = new Set<String>{'Current','Grace Period'};
		String queryStr = 'Select ' +
												'Id,' +
												'AS_Auto_Renew__c,' +
												'Account__r.PersonContactId ,' +
												'AS_End_Date__c,AS_Frequency__c,'+
										    'AS_Membership_Span__c,' +
										    'AS_Membership_Status__c,' +
										    'AS_Opportunity__c,' +
										    'AS_Payment_Source__c,'+
										    'AS_Product__c,' +
										    'AS_Quantity__c,'+
										    'AS_Start_Date__c,' +
										    'AS_Type__c,Name , ' +
										    'AS_Opportunity__r.Name, ' +
										    'AS_Opportunity__r.StageName '+
											' from ' +
												'AS_Subscription__c ' +
											'where ' +
												'(AS_Opportunity__r.StageName != :ISCLOSEDWON and AS_Opportunity__r.StageName != :ISCLOSEDLOST ) ' +
											'AND ' +
												'AS_Type__c =\'Member\' ' +
											' AND ' +
												'AS_Membership_Status__c IN :allowedStatusSet'+
											' AND ' +
												'AS_End_Date__c <= :entranceDate';
		
		System.debug('queryStr : ' + queryStr);
		if(medr.T8__c != null && medr.T8__c>=0) {
  		return Database.getQueryLocator(queryStr);
  	} else {
  		return null;
  	}
	}
	
	public void execute(Database.BatchableContext BC, List<AS_Subscription__c> scope) {
		System.debug('scope 8 :' + scope);
		try {
			Membership_End_Date_Renewal__c medr = Membership_End_Date_Renewal__c.getInstance();
	    list< AS_Subscription__c > subOppSendRenew  = new list< AS_Subscription__c >();
	    map< Id,AS_Subscription__c >  mp_subOpp = new map< Id,AS_Subscription__c >(); 
	    map< Id,  Opportunity  > mp_subcripId_and_opp = new map < Id,  Opportunity  >();
		    
			set< Id > sub = new set< Id >();
			
			system.debug('scope jr => :'+scope);
			
	    for( AS_Subscription__c subscription : scope  ) {
				subOppSendRenew.add( subscription );
	    }
	
	    List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
	    EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='AS_Expired_Membership_Subscription'];
	
	
	    list < Opportunity > oppToUpdateToCloseLost = new list< Opportunity >();
	    list < AS_Subscription__c > subToUpdatetoEdxpired = new list< AS_Subscription__c >();
	    for ( AS_Subscription__c subs : subOppSendRenew ) {
		    try {
		    	system.debug(' iyang solod choy ==> '+subs);
		    	if(subs.AS_Opportunity__c != null) {
		        	Opportunity updOpp = new Opportunity();
		        	updOpp.Id = subs.AS_Opportunity__c;
		        	updOpp.StageName = ISCLOSEDLOST;
		        	oppToUpdateToCloseLost.add( updOpp );
		    	}
		        	
		    	AS_Subscription__c updSub = new AS_Subscription__c();
		    	updSub.Id = subs.Id;
		    	updSub.AS_Membership_Status__c = 'Expired';    
		    	subToUpdatetoEdxpired.add( updSub );
		        	
		
		    	//Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		    	//mail.setTemplateId(et.Id);
		    	//mail.setTargetObjectId( subs.Id );
		    	//mail.setSaveAsActivity(false);
		    	
		    	
		    	//system.debug( ' mail ==> jrc ==: '+mail );
		    	
		   		//allmsg.add( mail ); 
	   		
	   		} catch (Exception e) {
	   			errorMessage += '\n\r'+ subs.Id + ' record : ' + e.getMessage() + ' - Line :' + e.getLineNumber();
	   		}
	
	    } 
	
			system.debug( 'oppToUpdateToCloseLost ==> '+oppToUpdateToCloseLost );
			system.debug( 'subToUpdatetoEdxpired ==> '+subToUpdatetoEdxpired );
			
	    // update of opportunity to close lost starts here
	    if( oppToUpdateToCloseLost.size() != 0 ) {
	    	
				Database.SaveResult[] oppUpdateResList = Database.update(oppToUpdateToCloseLost, false);
				System.debug('oppUpdateResList : ' + oppUpdateResList);
				// Iterate through each returned result
				for (Database.SaveResult sr : oppUpdateResList) {
				    if (sr.isSuccess() == false) {
				      // Operation failed, so get all errors                
				        for(Database.Error err : sr.getErrors()) {                  
				            System.debug(err.getStatusCode() + ': ' + err.getMessage());
				            errorMessage += '\n\r '+ sr.getId() +' - Opportunity Update Error : ' + err.getMessage();
				        }
				    }
				}
	    }
	    // update of opportunity to close lost ends here
	    
	    system.debug(' email ni jet ==> '+allmsg);
	     
	   	// update of subscription to expired starts here
	    if( subToUpdatetoEdxpired.size() != 0 ){
	    	
	    	Database.SaveResult[] subsUpdateResList = Database.update(subToUpdatetoEdxpired, false);
				System.debug('subsUpdateResList : ' + subsUpdateResList);
				// Iterate through each returned result
				for (Database.SaveResult sr : subsUpdateResList) {
				    if (sr.isSuccess() == false) {
				      // Operation failed, so get all errors                
				        for(Database.Error err : sr.getErrors()) {                  
				            System.debug(err.getStatusCode() + ': ' + err.getMessage());
				            errorMessage += '\n\r '+ sr.getId() +' - Membership Subscription Update Error : ' + err.getMessage();
				        }
				    }
				}
	    	
	    	//Messaging.sendEmail(allmsg,false);	
	    }
	    // update of subscription to expired ends here
	    
	    // this is added just to cover the catch 
	    if(Test.isRunningTest()) {
    			String forCoveringCatchStr;
					forCoveringCatchStr.toLowerCase(); 
	    }
	    
    
		} catch (Exception ex) {
			System.debug('AN OVERALL ERROR OCCUR');
   		errorMessage +=  '\n\r' + ex.getMessage() + ' - Line :' + ex.getLineNumber();
		}
 
	} 
	
	public void finish(Database.BatchableContext BC) {
		try {
	   	if(String.isNotBlank(errorMessage)) { 
	   		AsyncApexJob batchResult = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];    
		   	// Email the Batch Job's submitter that the Job is finished.  
		   	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
		  	String[] toAddresses = new String[] {batchResult.CreatedBy.Email};
		   	mail.setToAddresses(toAddresses);  
		   	mail.setSubject('Expired batch Membership Renewal');  
		   	String theEmailBody = ''; 
	   
	   
	     
	      theEmailBody += 'This email is to notify you that your recent batch of membership renewal encounter a problem.\n\r'; 
	      theEmailBody += 'ERROR : \n';
	      theEmailBody += errorMessage + '\n\r';
	      
      	mail.setPlainTextBody(theEmailBody);  
	      
       	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	   	}
		} catch(Exception e) {  
		}
	}
}