/*
* Author : WEW
* Description: batch process to check for END DATE membership renewal
* Parameter : 
* Return : 
*/
public class AS_batchMembershipRenewalEND implements Database.batchable<SObject>,Database.Stateful{
    
    private String errorMessage {get;set;} 
    
    public AS_batchMembershipRenewalEND() {
		
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		Membership_End_Date_Renewal__c memRenew = Membership_End_Date_Renewal__c.getInstance();
 		Integer t8RenewInt = (memRenew.T8__c!=null)?Integer.valueOf(memRenew.T8__c):null;
		
		Set<String> allowedStatusSet = new Set<String>{'Current'};
		String queryStr = '';
		if(t8RenewInt != null && t8RenewInt >= 0) {
			Date possibleStartEndDateDate = Date.today().addDays(-1*(t8RenewInt)); // this added to get the first possible date of end Date (#PSA-375)
			Date possibleExpiredDate = Date.today().addDays(t8RenewInt); // this added to get the last possible date of expiration (#PSA-375)
			System.debug('Start possibleStartEndDateDate : ' + possibleStartEndDateDate + ' possibleExpiredDate : ' + possibleExpiredDate);
			queryStr = 'Select ' +
										'Id,' +
										'Name,' +
										'AS_Membership_Status__c,' +
										'AS_Opportunity__r.CloseDate,' +
										'AS_Opportunity__r.Name,' +
										'AS_Opportunity__r.Amount,' +
										'AS_Opportunity__r.AS_GST_Component__c,' +
										'AS_Opportunity__c,' +
										'AS_Frequency__c,' +
										'Account__c,' +
										'Account__r.Name,' +
										'Account__r.PersonContactId,' +
										'AS_Payment_Source__c,' +
										'AS_End_Date__c,' +
										'AS_Auto_Renew__c,' +
										'AS_Price_Book__c,' +
										'AS_Product__c,' +
										'AS_Product__r.AS_Renewal_Product__c' +
									' from ' +
										'AS_Subscription__c ' +
									'where ' +
										'AS_End_Date__c >:possibleStartEndDateDate ' +
									'AND ' +
										'AS_End_Date__c < :possibleExpiredDate ' +
									'AND ' +
										'AS_Type__c =\'Member\' ' +
									'AND ' +
										'AS_Membership_Status__c IN :allowedStatusSet';
		} else {
			Date entranceDate = Date.today().addDays(-1); // added for (#PSA-375) grace period happens on endDate+1
			Date lastDate = Date.today();
			queryStr = 'Select ' +
										'Id,' +
										'Name,' +
										'AS_Membership_Status__c,' +
										'AS_Opportunity__r.CloseDate,' +
										'AS_Opportunity__r.Name,' +
										'AS_Opportunity__r.Amount,' +
										'AS_Opportunity__r.AS_GST_Component__c,' +
										'AS_Opportunity__c,' +
										'AS_Frequency__c,' +
										'Account__c,' +
										'Account__r.Name,' +
										'Account__r.PersonContactId,' +
										'AS_Payment_Source__c,' +
										'AS_End_Date__c,' +
										'AS_Auto_Renew__c,' +
										'AS_Price_Book__c,' +
										'AS_Product__c,' +
										'AS_Product__r.AS_Renewal_Product__c' +
									' from ' +
										'AS_Subscription__c ' +
									'where ' +
										'AS_End_Date__c >=:entranceDate ' +
									'AND ' +
										'AS_End_Date__c < :lastDate ' +
									'AND ' +
										'AS_Type__c =\'Member\' ' +
									'AND ' +
										'AS_Membership_Status__c IN :allowedStatusSet';
		}
		System.debug('queryStr : ' + queryStr);
		return Database.getQueryLocator(queryStr);
		
	}

	public void execute(Database.BatchableContext BC, List<AS_Subscription__c> scope) {
   	System.debug('RenewalEnd scope :' + scope);
	//	Savepoint sp = Database.setSavepoint();
		try {
			List<OrgWideEmailAddress> owea = [select Id,Address from OrgWideEmailAddress where Address = 'noreply@psa.org.au'];
			
			ASPHPP__PPSettings__c settings = ASPHPP__PPSettings__c.getOrgDefaults();
	    Id defaultGateway = String.isNotBlank(settings.ASPHPP__Gateway_ID__c)?Id.valueOf(settings.ASPHPP__Gateway_ID__c):null;
	    
	    EmailTemplate emailTempNotice = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='AS_Send_Renewal_Notice_Email'];
	    
	    List<ASPHPP__Subscription__c> allPaymentSubscription = new List<ASPHPP__Subscription__c>();
	   	List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
	   	List<AS_Subscription__c> allupdatetoGrace = new List<AS_Subscription__c>();
			for(AS_Subscription__c subs : scope){
				try {
					Date endDatePlus1 = subs.AS_End_Date__c.addDays(1);
					Membership_End_Date_Renewal__c renew = Membership_End_Date_Renewal__c.getOrgDefaults();
					Integer t8RenewInt = (renew.T8__c!=null)?Integer.valueOf(renew.T8__c):null;
					
					Integer numberDaysDue = subs.AS_End_Date__c.daysBetween(Date.today());
					
					Date expiredDate = (renew.T8__c!=null && renew.T8__c >= 0)?subs.AS_End_Date__c.addDays(Integer.valueOf(renew.T8__c)):endDatePlus1.addDays(1);
					System.debug('endDatePlus1 : ' + endDatePlus1 + ' - ' + ' expiredDate : ' + expiredDate + ' Date.today() : ' + Date.today());
					//if( (t8RenewInt != null && t8RenewInt >= 0 && t8RenewInt > numberDaysDue && numberDaysDue >= 0 && Date.today() >= endDatePlus1 && Date.today()< expiredDate) || ( (t8RenewInt == null || t8RenewInt < 1) && Date.today() >= endDatePlus1 && Date.today()< expiredDate ) )  { //another validation to filter the correct subscription to process
					if( (t8RenewInt != null && t8RenewInt > 0 && t8RenewInt > numberDaysDue && numberDaysDue > 0 && Date.today()< expiredDate) || ( (t8RenewInt == null || t8RenewInt < 1) && Date.today() >= endDatePlus1 ) )  { //another validation to filter the correct subscription to process
						System.debug('to be process subscription : ' + subs.Id);
						if(subs.AS_Auto_Renew__c == true && Date.today() == endDatePlus1) {
							// map to for getting the right frequency from integer starts here
			        Map<Integer,String> mapFreq = new Map<Integer,String>();
			        mapFreq.put(1,'Yearly');
			        mapFreq.put(2,'Every Six Months');
			        mapFreq.put(4,'Quarterly');
			        mapFreq.put(12,'Monthly');
			        // map to for getting the right frequency from integer ends here
			        
			        // add payment Source starts here
			        ASPHPP__Subscription__c indiPaymentSubscription = new ASPHPP__Subscription__c();
			        indiPaymentSubscription.AS_forRenewal__c = true;
			        indiPaymentSubscription.Name = subs.AS_Opportunity__r.Name + ' Subscription';
			        indiPaymentSubscription.ASPHPP__Frequency__c = mapFreq.get(Integer.valueOf(subs.AS_Frequency__c));
			        indiPaymentSubscription.AS_opportunity__c = subs.AS_Opportunity__c;
			        indiPaymentSubscription.ASPHPP__Process_First_Payment_Today__c = false;
			        indiPaymentSubscription.ASPHPP__Last_Payment_Date__c = date.today();
			        indiPaymentSubscription.ASPHPP__Next_Payment_Date__c = date.today();
			        indiPaymentSubscription.ASPHPP__Account__c = subs.Account__c;
			        indiPaymentSubscription.ASPHPP__Payment_Source__c = subs.AS_Payment_Source__c;
			        indiPaymentSubscription.ASPHPP__Gateway__c = defaultGateway;
			        indiPaymentSubscription.AS_Subscription__c = subs.Id;
			        indiPaymentSubscription.ASPHPP__End_Date__c = subs.AS_Opportunity__r.CloseDate.addDays(364);
			        indiPaymentSubscription.ASPHPP__Amount__c = (subs.AS_Opportunity__r.Amount + subs.AS_Opportunity__r.AS_GST_Component__c)/subs.AS_Frequency__c;
			        allPaymentSubscription.add(indiPaymentSubscription);
			        // add payment Source starts here
						}
						
						// update all the membership subscription to grace period
						AS_Subscription__c indiUpdateToGrace = new AS_Subscription__c();
						indiUpdateToGrace.Id = subs.Id;
						indiUpdateToGrace.AS_Membership_Status__c = 'Grace Period';
						allupdatetoGrace.add(indiUpdateToGrace);
						
						if(subs.AS_Auto_Renew__c == false) {
							// email part starts here
							Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
							
							mail.setTemplateId(emailTempNotice.Id);
							
							mail.setTargetObjectId( subs.Account__r.PersonContactId  );
		       		mail.setWhatId( subs.Id  );
							
							if(owea.size()>0) {
								mail.setorgWideEmailAddressId(owea[0].Id);
							}
							
							
							mail.setSaveAsActivity(false);
							allmsg.add(mail);
						}
					}
				} catch (Exception e) {
	   			errorMessage += '\n\r'+ subs.Id + ' record : ' + e.getMessage() + ' - Line :' + e.getLineNumber();
	   		}
			}
			
			// insertion of all payment subscription starts here
			System.debug('allPaymentSubscription : ' + allPaymentSubscription);
			Database.SaveResult[] paySubsResList = Database.insert(allPaymentSubscription, false);
			System.debug('paySubsResList : ' + paySubsResList);
			// Iterate through each returned result
			for (Database.SaveResult sr : paySubsResList) {
			    if (sr.isSuccess() == false) {
			      // Operation failed, so get all errors                
			        for(Database.Error err : sr.getErrors()) {                  
			            System.debug(err.getStatusCode() + ': ' + err.getMessage());
			            errorMessage += '\n\r'+' Payment Subscription Insertion Error : ' + err.getMessage();
			        }
			    }
			}
			// insertion of all payment subscription ends here here
			
			
			// update of subscription to grace period starts here
			System.debug('allupdatetoGrace : ' + allupdatetoGrace);
			Database.SaveResult[] subsUpdateResList = Database.update(allupdatetoGrace, false);
			System.debug('subsUpdateResList : ' + subsUpdateResList);
			// Iterate through each returned result
			for (Database.SaveResult sr : subsUpdateResList) {
			    if (sr.isSuccess() == false) {
			      // Operation failed, so get all errors                
			        for(Database.Error err : sr.getErrors()) {                  
			            System.debug(err.getStatusCode() + ': ' + err.getMessage());
			            errorMessage += '\n\r '+ sr.getId() +' Membership Subscription Update Error : ' + err.getMessage();
			        }
			    }
			}
			// update of subscription to grace period ends here
			
			//Messaging.SendEmailResult[] wew= Messaging.sendEmail(allmsg,false);
			
		} catch (Exception e) {
   		System.debug('AN OVERALL ERROR OCCUR');
   		errorMessage +=  '\n\r' + e.getMessage() + ' - Line :' + e.getLineNumber();
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
           mail.setSubject('batch Membership Renewal for Grace Period');  
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