public class AsBgCourseEnrollment {
  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx
  @TestVisible
  private boolean m_isExecuting = false;
  @TestVisible
  private integer BatchSize = 0;

  public AsBgCourseEnrollment(boolean isExecuting, integer size){
    m_isExecuting = isExecuting;
    BatchSize = size;
  }
	/*
  public void OnBeforeInsert(AS_BG_Course_Enrolment__c[] newRecords){
  }
	*/
	
  public void OnAfterInsert(AS_BG_Course_Enrolment__c[] newRecords, Map<Id,AS_BG_Course_Enrolment__c> newMap){
		// added by wew for (#PSABG-31)
    createLmsCourseEnrollmentChecker(newRecords, new Map<Id,AS_BG_Course_Enrolment__c>(), new Map<Id,AS_BG_Course_Enrolment__c>(), 'INSERT');
   	SendEmailBannerGroupCourseEnrolmentByCriteria( newRecords, new Map<Id,AS_BG_Course_Enrolment__c>(), newMap, 'INSERT' );
    // added by wew for (#PSABG-19)
  	if(!System.isFuture() && !System.isBatch()){
  		System.debug('RTOCertificateChecker OnAfterInsert ');
  		RTOCertificateChecker(newRecords, new Map<Id,AS_BG_Course_Enrolment__c>(), new Map<Id,AS_BG_Course_Enrolment__c>(), 'INSERT');
  	}
  }
	
	/*
  @future public static void OnAfterInsertAsync(Set<ID> newRecordIDs){
    //Example usage
    //List<AS_BG_Course_Enrolment__c> newRecords = [select Id, Name from AS_BG_Course_Enrolment__c where Id IN :newRecordIDs];
  }
  */
	/*
  public void OnBeforeUpdate(AS_BG_Course_Enrolment__c[] updatedObjects, Map<Id,AS_BG_Course_Enrolment__c> oldMap, Map<Id,AS_BG_Course_Enrolment__c> newMap){
  }
	*/
  public void OnAfterUpdate(AS_BG_Course_Enrolment__c[] updatedObjects, Map<Id,AS_BG_Course_Enrolment__c> oldMap, Map<Id,AS_BG_Course_Enrolment__c> newMap){
	// added by wew for (#PSABG-31)
	createLmsCourseEnrollmentChecker(updatedObjects, oldMap, newMap, 'UPDATE');
	 	
    // added by Jet for (#PSABG-22)
    createCpdAtivitySummaryFromBgCourseEnrollment( updatedObjects  , oldMap , newMap );

    SendEmailBannerGroupCourseEnrolmentByCriteria( updatedObjects, oldMap, newMap, 'UPDATE' );

	 	// added by wew for (#PSABG-19)
  	if(!System.isFuture() && !System.isBatch()){
  		RTOCertificateChecker(updatedObjects,oldMap,newMap,'UPDATE');
  	}
  	
  }

	/*
  @future public static void OnAfterUpdateAsync(Set<ID> updatedRecordIDs){
    //List<AS_BG_Course_Enrolment__c> updatedRecords = [select Id, Name from AS_BG_Course_Enrolment__c where Id IN :updatedRecordIDs];
  }
	*/
	
	/*
  public void OnBeforeDelete(AS_BG_Course_Enrolment__c[] recordsToDelete, Map<ID, AS_BG_Course_Enrolment__c> recordMap){
		
  }
  */
  

  public void OnAfterDelete(AS_BG_Course_Enrolment__c[] deletedRecords, Map<ID, AS_BG_Course_Enrolment__c> recordMap){
		// added for ticket PSABG-28
		createLmsCourseEnrollmentChecker(deletedRecords, recordMap, new Map<Id,AS_BG_Course_Enrolment__c>(), 'DELETE');
  }
	
	/*
  @future public static void OnAfterDeleteAsync(Set<ID> deletedRecordIDs){

  }
	*/

	/*
  public void OnUndelete(AS_BG_Course_Enrolment__c[] restoredRecords){

  }
  */

  @TestVisible public boolean IsTriggerContext{
    get{ return m_isExecuting;}
  }
  
  
  /*
	* Author : john hope
	* Description: method to check data before createLmsCourseEnrollment (#PSABG-31)
	* Parameter : None
	* Return : None
	*/
  public void createLmsCourseEnrollmentChecker(AS_BG_Course_Enrolment__c[] enrollData, Map<Id,AS_BG_Course_Enrolment__c> oldMap, Map<Id,AS_BG_Course_Enrolment__c> newMap,String action) {
  	List<AS_BG_Course_Enrolment__c> tobeProcessed = new List<AS_BG_Course_Enrolment__c>();
  	Set<Id> tobeProcessedContactCPDPoints = new Set<Id>();
  	
  	Set<Id> allbgCourse = new Set<Id>();
  	for(AS_BG_Course_Enrolment__c enroll : enrollData) {
    	if(enroll.AS_Banner_Group_Course__c != null)
    		allbgCourse.add(enroll.AS_Banner_Group_Course__c);
    }
    
    Map<Id,AS_BG_Course__c> bgCourseDataCheckMap = new Map<Id,AS_BG_Course__c>();
  	for(AS_BG_Course__c bgCourse : [Select Id,AS_Status__c from AS_BG_Course__c where Id IN :allbgCourse]) {
  		bgCourseDataCheckMap.put(bgCourse.Id,bgCourse);
  	}
  	
  	for(AS_BG_Course_Enrolment__c enroll : enrollData) {
  		if(enroll.AS_Contact__c !=null && enroll.AS_Banner_Group_Course__c != null && enroll.AS_Enrolment_Confirmation_Status__c == 'Confirmed' && bgCourseDataCheckMap.get(enroll.AS_Banner_Group_Course__c).AS_Status__c == 'Active') {
	  		System.debug('checker : ' + 1 + action);
	  		if(action == 'INSERT' || (action == 'UPDATE' && oldMap.get(enroll.Id).AS_Enrolment_Confirmation_Status__c != newMap.get(enroll.Id).AS_Enrolment_Confirmation_Status__c) ) {
	  			System.debug('checker : ' + 2);
	  			tobeProcessed.add(enroll);
	  		}
  		}
  		// added for ticket PSABG-28
  		System.debug('checker : 2A' + enroll.AS_Contact__c + ' - ' + enroll.AS_Passed__c + ' - ' + enroll.AS_Status__c);
  		if(enroll.AS_Contact__c !=null) {
	  		System.debug('checker : 2B');
	  		if(action == 'INSERT' || action == 'DELETE' || (action == 'UPDATE' && (oldMap.get(enroll.Id).AS_Passed__c != newMap.get(enroll.Id).AS_Passed__c || oldMap.get(enroll.Id).AS_Status__c != newMap.get(enroll.Id).AS_Status__c)) ) {
	  			System.debug('checker : 2C ');
	  			tobeProcessedContactCPDPoints.add(enroll.AS_Contact__c);
	  		}
  		}
  	}
  	if(tobeProcessed.size() > 0) {
  		createLmsCourseEnrollment(tobeProcessed);
  	}
  	
  	// added for ticket PSABG-28
  	System.debug('tobeProcessedContactCPDPoints : ' + tobeProcessedContactCPDPoints);
  	if(tobeProcessedContactCPDPoints.size() > 0) {
  		updateContactTotalCPDPoints(tobeProcessedContactCPDPoints);
  	}
  }

  // My Functions
  
  /*
  * Author : John Hope
  * Description: method to update contact total cpd points ( ticket # PSABG-28)
  * Last Updated by:John Hope
  * Parameter : 0. List = Set of Contact Id's
  * Return : None
  */
  public void updateContactTotalCPDPoints(Set<Id> allContactId){
  	List<Contact> allTobeUpdatedContact = new List<Contact>();
  	for(AggregateResult agg : [SELECT
  																AS_Contact__c contact,
  																SUM(AS_Group_1_CPD_Achieved__c) group1,
  																SUM(AS_Group_2_CPD_Achieved__c) group2 
  															FROM 
  																AS_BG_Course_Enrolment__c 
  															WHERE 
  																AS_Contact__c IN :allContactId 
  															AND 
  																(
  																	AS_Passed__c = true
  																OR
  																	AS_Status__c = 'Completed'
  																OR
  																	AS_Status__c = 'Failed'
  																)
  															GROUP BY
  																AS_Contact__c
  															]) {
  		Contact indiTobeUpdatedContact = new Contact();
  		indiTobeUpdatedContact.Id = (Id) agg.get('contact');		
  		indiTobeUpdatedContact.AS_Total_Group_1_CPD__c = (Decimal) agg.get('group1');
  		indiTobeUpdatedContact.AS_Total_Group_2_CPD__c = (Decimal) agg.get('group2');
  		allTobeUpdatedContact.add(indiTobeUpdatedContact);
  	}
  	if(allTobeUpdatedContact.size() > 0) {
  		update allTobeUpdatedContact;
  	}
  }
  /*
  * Author : Jet R. Compayan
  * Description: method to will create Lms Course Enrolment ( ticket # PSABG-5 , #PSABG-31)
  * Last Updated by:John Hope
  * Parameter : 0. List = list of AS_BG_Course_Enrolment__c
  * Return : None
  */
  public void createLmsCourseEnrollment( AS_BG_Course_Enrolment__c[] newRecords ){
    System.debug('createLmsCourseEnrollment : ' + newRecords.size() + newRecords);
    if(runOnceUpdateBGEnroll()) {
    	System.debug('createLmsCourseEnrollment misulod sa condition');
	    Set<Id> allEnrollees = new Set<Id>();
	    Set<Id> allLMSInstance = new Set<Id>();
	    Set<Id> allBgCourseId = new Set<Id>();
	    
	    for(AS_BG_Course_Enrolment__c enroll : newRecords) {
	    	allEnrollees.add(enroll.AS_Contact__c);
	    	allBgCourseId.add(enroll.AS_Banner_Group_Course__c);
	    }
	    
	    map< Id,Contact > ContactMap = new map<Id,Contact >();
	    if(allEnrollees.size() > 0) {
		    for(Contact con : [Select Id,FirstName,LastName,Email,AS_BG_Position_Description__c from Contact where Id IN :allEnrollees]){
		    	ContactMap.put(con.Id, con);
		    }
	    }
	    System.debug('ContactMap : ' + ContactMap.size() + ContactMap);
	    
	    map< Id,AS_BG_Course__c > bgCourseMap = new map<Id,AS_BG_Course__c >();
			for( AS_BG_Course__c  bgCourse : [SELECT
	                                          Id,
	                                          LMS_Instance_lookup__c,
	                                          AS_LMS_Course__c,
	                                          Name,
	                                          recordTypeId
	                                    FROM 
	                                          AS_BG_Course__c 
	                                    WHERE
	                                          Id in:allBgCourseId
	                                    ] ) {
	  		bgCourseMap.put( bgCourse.Id , bgCourse );
	  		allLMSInstance.add(bgCourse.LMS_Instance_lookup__c);
	    }
	    
	    
	    System.debug('bgCourseMap : ' + bgCourseMap.size() + bgCourseMap);
	    System.debug('allLMSInstance : ' + allLMSInstance.size() + allLMSInstance);
	    
	    
	    Map<String,LMS_User__c> lmsUserMap = new Map<String,LMS_User__c>();
	    Map<String,String> tobeAddedlmsUserMap = new Map<String,String>();
	    for(LMS_User__c lmsUser : [Select Id,Name,AS_Banner_Group_Contact__c,LMS_Instance__c from LMS_User__c where AS_Banner_Group_Contact__c IN :allEnrollees AND LMS_Instance__c IN :allLMSInstance]) {
	    	if(lmsUser.AS_Banner_Group_Contact__c !=null && lmsUser.LMS_Instance__c !=null) {
	    		String keyStr = String.valueOf(lmsUser.AS_Banner_Group_Contact__c).toLowercase()+String.valueOf(lmsUser.LMS_Instance__c).toLowercase();
	    		lmsUserMap.put(keyStr,lmsUser);
	    	}
	    }
	    System.debug('lmsUserMap : ' + lmsUserMap.size() + lmsUserMap);
	    
	    List<AS_BG_Course_Enrolment__c> allTobeUpdateBGCourseEn = new List<AS_BG_Course_Enrolment__c>();
	    list<LMS_Course_Enrolment__c> allCourseEnList = new list< LMS_Course_Enrolment__c >();
	    List<LMS_User__c> allNewLMSUser = new List<LMS_User__c>();
	    for(AS_BG_Course_Enrolment__c enroll : newRecords) {
	    	if(enroll.AS_Contact__c!=null && enroll.AS_Banner_Group_Course__c!=null && bgCourseMap.get(enroll.AS_Banner_Group_Course__c).LMS_Instance_lookup__c!=null) {
	    		String randomStr = AS_commonFunction.generateRandomString(20);
	    		
	    		System.debug('AsBgCourseEnrollment : ' + 1);
	    		String keyStr = String.valueOf(enroll.AS_Contact__c).toLowercase()+String.valueOf(bgCourseMap.get(enroll.AS_Banner_Group_Course__c).LMS_Instance_lookup__c).toLowercase();
	    		LMS_Course_Enrolment__c newCourseEn = new LMS_Course_Enrolment__c();
		    	if(lmsUserMap.containsKey(keyStr)) {
			      newCourseEn.Start_Date__c = enroll.AS_Start_Date__c;
			      newCourseEn.End_Date__c =   enroll.AS_End_Date__c;
			      newCourseEn.LMS_Course__c = bgCourseMap.get(enroll.AS_Banner_Group_Course__c).AS_LMS_Course__c;
			      newCourseEn.LMS_Instance__c = bgCourseMap.get(enroll.AS_Banner_Group_Course__c).LMS_Instance_lookup__c;
			      newCourseEn.LMS_User__c = lmsUserMap.get(keyStr).Id;
			      newCourseEn.AsExtId__c = 'LMSCE'+randomStr;
			      allCourseEnList.add( newCourseEn );
			      System.debug('AsBgCourseEnrollment : ' + 2);
		    	} else if(tobeAddedlmsUserMap.containsKey(keyStr)) {
		    		LMS_User__c lmsUserReference = new LMS_User__c();
		    		lmsUserReference.AsExtId__c = tobeAddedlmsUserMap.get(keyStr);
		    		
		    		
			      newCourseEn.Start_Date__c = enroll.AS_Start_Date__c;
			      newCourseEn.End_Date__c =   enroll.AS_End_Date__c;
			      newCourseEn.LMS_Course__c = bgCourseMap.get(enroll.AS_Banner_Group_Course__c).AS_LMS_Course__c;
			      newCourseEn.LMS_Instance__c =bgCourseMap.get(enroll.AS_Banner_Group_Course__c).LMS_Instance_lookup__c;
			      newCourseEn.LMS_User__r = lmsUserReference;
			      newCourseEn.AsExtId__c = 'LMSCE'+randomStr;
			      
			      allCourseEnList.add(newCourseEn);
		    	} else {
		    		// create user 
		    		LMS_User__c newLMSUser = new LMS_User__c();
		    		newLMSUser.AS_Banner_Group_Contact__c = enroll.AS_Contact__c;
		    		newLMSUser.Email__c = ContactMap.get(enroll.AS_Contact__c).Email;
		    		newLMSUser.FirstName__c = ContactMap.get(enroll.AS_Contact__c).FirstName;
		    		newLMSUser.LastName__c = ContactMap.get(enroll.AS_Contact__c).LastName;
		    		newLMSUser.LMS_Instance__c = bgCourseMap.get(enroll.AS_Banner_Group_Course__c).LMS_Instance_lookup__c;
		    		newLMSUser.Status__c = 'Active';
		    		newLMSUser.AsExtId__c = randomStr;
		    		
		    		LMS_User__c lmsUserReference = new LMS_User__c();
		    		lmsUserReference.AsExtId__c = randomStr;
		    		
			      newCourseEn.Start_Date__c = enroll.AS_Start_Date__c;
			      newCourseEn.End_Date__c =   enroll.AS_End_Date__c;
			      newCourseEn.LMS_Course__c = bgCourseMap.get(enroll.AS_Banner_Group_Course__c).AS_LMS_Course__c;
			      newCourseEn.LMS_Instance__c =bgCourseMap.get(enroll.AS_Banner_Group_Course__c).LMS_Instance_lookup__c;
			      newCourseEn.LMS_User__r = lmsUserReference;
			      newCourseEn.AsExtId__c = 'LMSCE'+randomStr;
			      
			      allNewLMSUser.add(newLMSUser);
			      allCourseEnList.add(newCourseEn);
		    		System.debug('AsBgCourseEnrollment : ' + 3);
		    		
		    		tobeAddedlmsUserMap.put(keyStr,randomStr);
		    	}
		    	
		    	LMS_Course_Enrolment__c lmsCourEnrReference = new LMS_Course_Enrolment__c();
		    	lmsCourEnrReference.AsExtId__c = newCourseEn.AsExtId__c;
		    	
		    	AS_BG_Course_Enrolment__c tobeUpdateBGCourseEn = new AS_BG_Course_Enrolment__c();
		    	tobeUpdateBGCourseEn.Id = enroll.Id;
		    	tobeUpdateBGCourseEn.AS_LMS_Course_Enrolment__r = lmsCourEnrReference;
		    	allTobeUpdateBGCourseEn.add(tobeUpdateBGCourseEn);
		    	
	    	} else {
	    		System.debug('LMS ENROLLMENT CANNOT BE CREATED : ' + enroll.AS_Contact__c + ' - ' + enroll.AS_Banner_Group_Course__c + ' - ' + bgCourseMap.get(enroll.AS_Banner_Group_Course__c).LMS_Instance_lookup__c);
	    	}
	    	
	    }
	    
	    insert allNewLMSUser;
	    insert allCourseEnList;
	    System.debug('allNewLMSUser : ' + allNewLMSUser.size() + allNewLMSUser);
	    System.debug('allCourseEnList : ' + allCourseEnList.size() + allCourseEnList);
	    
	    
	    if(allTobeUpdateBGCourseEn.size() > 0) {
	    	System.debug('allTobeUpdateBGCourseEn : ' + allTobeUpdateBGCourseEn.size() + allTobeUpdateBGCourseEn);
	    	
		    update allTobeUpdateBGCourseEn;
		    
		    AsBgCourseEnrollment.runUpdateBGEnroll = false;
		  }	else {
			 	AsBgCourseEnrollment.runUpdateBGEnroll = true;
			}
			
			if(allTobeUpdateBGCourseEn.size() == 200) {
				AsBgCourseEnrollment.runUpdateBGEnroll = true;
			}
	    
	  }
  }
  
  /*
	* Author : john hope
	* Description: method to check data before generate certificate on completion of non-RTO course (#PSABG-19,PSABG-49)
	* Parameter : None
	* Return : None
	*/
  public void RTOCertificateChecker(AS_BG_Course_Enrolment__c[] enrollData, Map<Id,AS_BG_Course_Enrolment__c> oldMap, Map<Id,AS_BG_Course_Enrolment__c> newMap,String action) {
  	System.debug('RTOCertificateChecker starts here');
  	List<Id> Idlist = new List<Id>();
  	Integer max25 = 0;
  	for(AS_BG_Course_Enrolment__c enroll : enrollData) {
  		if (max25<= 25 && enroll.AS_Passed__c == true && enroll.AS_Generate_Certificate__c == true && enroll.AS_Status__c == 'Completed') {
  		//	System.debug('RTOCertificateChecker : ' + 1);
	  		if(action == 'INSERT') {
	  			Idlist.add(enroll.Id);
	  		} else if(action == 'UPDATE') {
	  		//	System.debug('RTOCertificateChecker : ' + 2);
	  			if(oldMap.get(enroll.Id).AS_Generate_Certificate__c != newMap.get(enroll.Id).AS_Generate_Certificate__c || oldMap.get(enroll.Id).AS_Status__c != newMap.get(enroll.Id).AS_Status__c || oldMap.get(enroll.Id).AS_Passed__c != newMap.get(enroll.Id).AS_Passed__c) {
	  				Idlist.add(enroll.Id);
	  			}
	  		}
  		} else if(max25 > 25){
				break;
			}
  	}
  	
  	if(Idlist.size() > 0) {
  		System.debug('Idlist : ' + Idlist);
  		AsBgCourseEnrollment.generateRTOCertificate(Idlist);
  	}
  }
  /*
	* Author : john hope
	* Description: method to generate certificate on completion of non-RTO course (#PSABG-19)
	* Parameter : None
	* Return : None
	*/
	@Future(callout=true)
	public static void generateRTOCertificate(list<id> IdList){
		System.debug('generateRTOCertificate start here' + IdList);
		EmailTemplate emailTempCourseComp = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='AS_CW_Course_Completion_Template'];
		List<OrgWideEmailAddress> owea = [select Id,Address from OrgWideEmailAddress where Address = 'noreply@amsolutions.net.au'];
		Map<Id,AS_BG_Course_Enrolment__c> mapAllEnroll = new Map<Id,AS_BG_Course_Enrolment__c>();
		list<attachment> insertAttachment = new list<attachment>();
		List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
		for(AS_BG_Course_Enrolment__c enroll : [Select 
																							AS_Status__c,
																							AS_Generate_Certificate__c,
																							AS_Banner_Group_Course__r.AS_Course_Type__c,
																							AS_Contact__r.Email,
																							AS_Contact__r.Account.ASStore_Email__c,
																							Id 
																						from 
																							AS_BG_Course_Enrolment__c 
																						where 
																							Id IN :IdList
																					]) {
   		mapAllEnroll.put(enroll.Id,enroll);
   	}
   	
   	System.debug('mapAllEnroll : ' + mapAllEnroll.size() + mapAllEnroll);
   	List<AS_BG_Course_Enrolment__c> allTobeUpdatedEnroll = new List<AS_BG_Course_Enrolment__c>();
   	for(Id enrollId: IdList) {
   		AS_BG_Course_Enrolment__c newEnroll = mapAllEnroll.get(enrollId);
   		System.debug('newEnroll : ' + newEnroll);
   		if(newEnroll.AS_Generate_Certificate__c == true && newEnroll.AS_Status__c == 'Completed' && (newEnroll.AS_Banner_Group_Course__r.AS_Course_Type__c == 'CW' || newEnroll.AS_Banner_Group_Course__r.AS_Course_Type__c == 'Non RTO')) {
   			pageReference pdf = Page.AsBgCertificateOfCompletionPdf;
		    //pass the AS_BG_Course_Enrolment__c Id parameter to the class.
		    pdf.getParameters().put('id',enrollId);
		    Attachment attach = new Attachment();
		    Blob body;
		    
		    if(!test.isRunningTest()){
        	body = pdf.getContent();
        }else{
        	body=blob.valueOf('TestString');
        }
        attach.Body = body;
	            
		    attach.Body = body;
		    attach.Name = 'BG Course Enrollment -'+enrollId+'.pdf';
		    attach.IsPrivate = false;
	    	attach.ParentId = enrollId;//This is the record to which the pdf will be attached
		    insertAttachment.add(attach);
	   		
	   		// for updating to send
	   		AS_BG_Course_Enrolment__c singleEnroll = new AS_BG_Course_Enrolment__c(); 
	   		singleEnroll.Id = enrollId;
	   		singleEnroll.AS_Certificate_Sent__c = true;
	   		allTobeUpdatedEnroll.add(singleEnroll);
	   		
	   		// for email
	    	if(newEnroll.AS_Contact__r.Email != null) {
	    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
						
					Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
					efa1.setFileName(attach.Name);
	    		efa1.setBody(attach.Body);
					
					mail.setTemplateId(emailTempCourseComp.Id);
	
	       	mail.setTargetObjectId(newEnroll.AS_Contact__c);
         	mail.setWhatId(enrollId);           
						
						
					if(owea.size()>0) {
						mail.setorgWideEmailAddressId(owea[0].Id);
					}
					
					mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1}); // this is for attachment
					mail.setSaveAsActivity(false);
					allmsg.add(mail);
				}
				
				// added for PSABG-80
				if(newEnroll.AS_Contact__r.Account.ASStore_Email__c != null && newEnroll.AS_Contact__r.Account.ASStore_Email__c != newEnroll.AS_Contact__r.Email) {
	    		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
						
					Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
					efa1.setFileName(attach.Name);
	    			efa1.setBody(attach.Body);
					
					mail.setTemplateId(emailTempCourseComp.Id);
	
	       	
         			mail.setWhatId(enrollId);       
         	
         			mail.setToAddresses(new List < String > { newEnroll.AS_Contact__r.Account.ASStore_Email__c });    
         			mail.setTargetObjectId(newEnroll.AS_Contact__c);
					mail.setTreatTargetObjectAsRecipient(false);
						
					if(owea.size()>0) {
						mail.setorgWideEmailAddressId(owea[0].Id);
					}
					
					mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1}); // this is for attachment
					mail.setSaveAsActivity(false);
					allmsg.add(mail);
				}
   		}
   	}
   	
   	System.debug('insertAttachment : ' + insertAttachment.size() + ' - ' + insertAttachment);
   	System.debug('allmsg : ' + allmsg.size() + allmsg);
   	
   	insert insertAttachment;
	 	Messaging.SendEmailResult[] wew= Messaging.sendEmail(allmsg,false);
	 	update allTobeUpdatedEnroll;
	 	
	 	System.debug('email Result : ' + wew.size() + wew);
	}
  
  /*
  * Author : Jet R. Compayan
  * Description: method to will create Lms Course Enrolment ( ticket # PSABG-22 )
  * Parameter : 0. List = list of AS_BG_Course_Enrolment__c
  * Return : None
  */
  public void createCpdAtivitySummaryFromBgCourseEnrollment( AS_BG_Course_Enrolment__c[] updatedObjects, Map<Id,AS_BG_Course_Enrolment__c> oldMap, Map<Id,AS_BG_Course_Enrolment__c> newMap ){
    
    set<Id> bgContactIdset = new set<Id>();
    set<Id> bgCourseEnIdSet = new set<Id>();
    map<Id,Set<Id>> bgCourseEnIdContactId = new  map<Id,Set<Id>>();
    for( AS_BG_Course_Enrolment__c bgCourseEn : updatedObjects ){

      if( bgCourseEn.AS_Status__c  != null  ){
        bgCourseEnIdSet.add( bgCourseEn.Id );
      }

    }

    set<Id> personContactId = new set<Id>();
    for(  AS_BG_Course_Enrolment__c bgCourseEn : [ 	Select 
    													AS_Contact__c,
                              AS_Contact__r.AS_Member_Match__r.AS_PSA_Member__r.PersonContactId,
    													Id 
    												From 
    													AS_BG_Course_Enrolment__c 
    												WHERE 
    													Id in:bgCourseEnIdSet 
    											]  ) {
    	System.debug('bgCourseEn==>'+ bgCourseEn);
    	System.debug('bgCourseEn.AS_Contact__r.AS_Member_Match__r.AS_PSA_Member__r.PersonContactId==>'+bgCourseEn.AS_Contact__r.AS_Member_Match__r.AS_PSA_Member__r.PersonContactId);  
    	if(bgCourseEn.AS_Contact__r.AS_Member_Match__r.AS_PSA_Member__r.PersonContactId != null){

    		personContactId.add( bgCourseEn.AS_Contact__r.AS_Member_Match__r.AS_PSA_Member__r.PersonContactId );
    		
    		if(bgCourseEnIdContactId.containsKey(bgCourseEn.AS_Contact__r.AS_Member_Match__r.AS_PSA_Member__r.PersonContactId)) {
    			Set<Id> contactIdSet = bgCourseEnIdContactId.get(bgCourseEn.AS_Contact__r.AS_Member_Match__r.AS_PSA_Member__r.PersonContactId);
    			contactIdSet.add(bgCourseEn.Id);
    			bgCourseEnIdContactId.put(bgCourseEn.AS_Contact__r.AS_Member_Match__r.AS_PSA_Member__r.PersonContactId , contactIdSet);
    		} else{
    			bgCourseEnIdContactId.put(bgCourseEn.AS_Contact__r.AS_Member_Match__r.AS_PSA_Member__r.PersonContactId , new Set<Id>{bgCourseEn.Id}  );
    		}

    	} 

    } 


    System.debug('personContactId =>'+personContactId);

    set<Id> userIdSet = new set<Id>();  
    map<Id,Set<Id>> userIdrWithContactIdMap = new map<Id,Set<Id>>();
    for( User user : [ Select 
                          ContactId,
                          Id,
                          Name
                        FROM 
                            User  
                        WHERE 
                            ContactId IN:personContactId 
                      ] ){



      userIdSet.add( user.Id );
      userIdrWithContactIdMap.put( user.Id , bgCourseEnIdContactId.get( user.ContactId ) ); // map<user,BGCourseEnrollment>

    }

    System.debug('userIdSet =>'+userIdSet);
    System.debug('userIdrWithContactIdMap =>'+userIdrWithContactIdMap);

    if( userIdSet.size() != 0 ){

    	Map<Id,Id> bgCourseIdWithCpdPlannerId = new  Map<Id,Id>();
		for( AsCPDPlanner__c  cpdPlanner : [  SELECT 
		                                        AS_Current_CPD_Plan__c ,
		                                        AsUser__c,
		                                        Id 
		                                    FROM 
		                                        AsCPDPlanner__c 
		                                    WHERE 
		                                        AsUser__c in:userIdSet 
		                                        AND 
		                                        AS_Current_CPD_Plan__c = true 
		                                  ] ){

			if( userIdrWithContactIdMap.containsKey( cpdPlanner.AsUser__c ) ){
			  if( userIdrWithContactIdMap.get(cpdPlanner.AsUser__c).size() > 0 ) {
			  	List<Id> userIdrWithContactIdValList = new List<Id>();
			  	userIdrWithContactIdValList.addAll(userIdrWithContactIdMap.get(cpdPlanner.AsUser__c));
			  	
			  	System.debug('userIdrWithContactIdValList : ' +userIdrWithContactIdValList.size() + ' ' + +userIdrWithContactIdValList);
			  	for(Id userIdrWithContactId : userIdrWithContactIdValList) {
			  		System.debug('misulod sa loop : ');
			  		bgCourseIdWithCpdPlannerId.put( userIdrWithContactId , cpdPlanner.Id ); // this ma<BGCourseEnroll => CPD Plan>
			  	}
			  }
			} 

		}

		System.debug('bgCourseIdWithCpdPlannerId =>'+bgCourseIdWithCpdPlannerId);
      
		map< Id, Id > bgCourseEnIdWithcpdLearningSum = new map<Id,Id>();
		for( AsCPD_Learning_Summary__c cpdLearningSummary : [ 
		                                                    Select 
		                                                        AS_Banner_Group_Course_Enrolment_ID__c, 
		                                                        Id
		                                                    From 
		                                                        AsCPD_Learning_Summary__c 
		                                                    WHERE 
		                                                        AS_Banner_Group_Course_Enrolment_ID__c in:bgCourseEnIdSet 
		                                                        

		                                                  ] ){

			bgCourseEnIdWithcpdLearningSum.put( cpdLearningSummary.AS_Banner_Group_Course_Enrolment_ID__c , cpdLearningSummary.Id );

		}    

		//Map<String,String> STATUSMap = new Map<String,String>{ 
		//	'In Progress' => 'In Progress'
		//	,'Read' => 'In Progress'
		//	,'In Review' => 'under review'
		//	,'Completed' => 'Complete'
		//	,'Cancelled' => ''
		//	,'Failed' =>'Under Review'
		//	,'Withdrawn' => '' 
		//	,'Not Started' => 'Not Started'
		//	,'Failed' => 'Complete'
		//}; 

		Map<String,String> STATUSMap = new Map<String,String>();
		STATUSMap.put('In Progress','In Progress');
		STATUSMap.put('Read','In Progress');
		STATUSMap.put('In Review','under review');
		STATUSMap.put('Completed','Complete');
		STATUSMap.put('Cancelled','');
		STATUSMap.put('Failed','Under Review');
		STATUSMap.put('Withdrawn','');
		STATUSMap.put('Not Started','Not Started');
		System.debug('STATUSMap=> '+STATUSMap); 

		list< AsCPD_Learning_Summary__c > cpdLearningSummaryList = new list< AsCPD_Learning_Summary__c >();
		for( AS_BG_Course_Enrolment__c getBgCourseEn : [ Select
		                                                    AS_Banner_Group_Course__r.AS_2016_Competencies__c,
		                                                    AS_Banner_Group_Course__r.AS_Content_Sponsor__c,
		                                                    AS_Banner_Group_Course__r.AS_CPD_Accreditation_Number__c,
		                                                    AS_Group_1_CPD_Achieved__c,
		                                                    AS_Group_2_CPD_Achieved__c,
		                                                    AS_Banner_Group_Course__r.AS_CPD_Category__c,
		                                                    AS_Banner_Group_Course__r.AS_Description__c,
		                                                    AS_Banner_Group_Course__r.AS_Provided_By_PSA__c,
		                                                    AS_Banner_Group_Course__r.Name,
		                                                    AS_End_Date__c,
		                                                    AS_Start_Date__c,
		                                                    Id,
		                                                    AS_Contact__c,
		                                                    AS_Status__c,
		                                                    AS_Completed_On__c
		                                                FROM 
		                                                    AS_BG_Course_Enrolment__c
		                                                WHERE
		                                                    Id in:bgCourseEnIdSet 
		                                              ] ) {

			if( bgCourseIdWithCpdPlannerId.get( getBgCourseEn.Id ) != null ){ // so that activity cannot be created when no cpd
				System.debug('getBgCourseEn.AS_Status__c=> '+ getBgCourseEn.AS_Status__c.trim()); 
				System.debug('STATUSMap=> '+ STATUSMap.get( getBgCourseEn.AS_Status__c.trim() ) );  
			    AsCPD_Learning_Summary__c newCpdLearningSum = new AsCPD_Learning_Summary__c();
			    newCpdLearningSum.Name =  getBgCourseEn.AS_Banner_Group_Course__r.Name;
			    newCpdLearningSum.ASTraining_Plan_Name__c = getBgCourseEn.AS_Banner_Group_Course__r.Name;
			    newCpdLearningSum.Start_Date__c = getBgCourseEn.AS_Start_Date__c;
			    newCpdLearningSum.Status__c = STATUSMap.get( getBgCourseEn.AS_Status__c.trim() ) ; 
			   
			    newCpdLearningSum.End_Date__c = getBgCourseEn.AS_Completed_On__c;
			    newCpdLearningSum.Group_1_CPD__c = getBgCourseEn.AS_Group_1_CPD_Achieved__c;
			    newCpdLearningSum.Group_2_CPD__c = getBgCourseEn.AS_Group_2_CPD_Achieved__c;
			    newCpdLearningSum.Description__c = getBgCourseEn.AS_Banner_Group_Course__r.AS_Description__c;
			    newCpdLearningSum.CPD_Accreditation_Number__c = getBgCourseEn.AS_Banner_Group_Course__r.AS_CPD_Accreditation_Number__c;
			    newCpdLearningSum.X2016_Competencies__c = getBgCourseEn.AS_Banner_Group_Course__r.AS_2016_Competencies__c;
			    newCpdLearningSum.Provider__c =  ( getBgCourseEn.AS_Banner_Group_Course__r.AS_Provided_By_PSA__c == true ? 'PSA' : '' );
			    newCpdLearningSum.CPD_Category__c = getBgCourseEn.AS_Banner_Group_Course__r.AS_CPD_Category__c;
			    newCpdLearningSum.AS_Banner_Group_Course_Enrolment_ID__c = getBgCourseEn.Id;
			    newCpdLearningSum.RecordTypeId =  Schema.SObjectType.AsCPD_Learning_Summary__c.getRecordTypeInfosByName().get('Chemist Warehouse').getRecordTypeId();
			    newCpdLearningSum.CPD_Planner__c = bgCourseIdWithCpdPlannerId.get( getBgCourseEn.Id );
			    newCpdLearningSum.Id = bgCourseEnIdWithcpdLearningSum.get( getBgCourseEn.Id );
			    cpdLearningSummaryList.add( newCpdLearningSum );

			}

			System.debug('cpdLearningSummaryList ==>'+cpdLearningSummaryList); 

		} 

    	if( cpdLearningSummaryList.size() != 0 ){
    		upsert cpdLearningSummaryList; 
    	}
      
    } 
  } 
  
  public static boolean runUpdateBGEnroll = true;
	
	/*Author : John Hope
	*Description : check the run variable and use for recursion
	*Date Created : 
	*Last Modified By : 
	*Date Last Modified : 
	*Related Meta Data :
	*Param :
	*Return : Boolean
 	*/
	public static boolean runOnceUpdateBGEnroll(){
	    if(runUpdateBGEnroll){
	     runUpdateBGEnroll=false;
	     return true;
	    }else{
	        return runUpdateBGEnroll;
	    }
	}


	/*
	* Author : Jet R. Compayan
	* Description:  Process builder is failing for bulk creation/update of Banner Group course enrolments. Depending on the type of enrolment communication is sent to the students.  ( ticket # PSABG-78)
	* Parameter :
	* Return : None
	* Ticket : ACCSI-50
	*/	

	public void SendEmailBannerGroupCourseEnrolmentByCriteria(AS_BG_Course_Enrolment__c[] enrollData, Map<Id,AS_BG_Course_Enrolment__c> oldMap, Map<Id,AS_BG_Course_Enrolment__c> newMap,String action) {

 		
		if( AS_commonFunction.runSendEmailBgCurseEnOnce() ){

			Id CHEMISTWAREHOUSE = Schema.SObjectType.AS_BG_Course_Enrolment__c.getRecordTypeInfosByName().get('Chemist Warehouse').getRecordTypeId();	
			
			Map< String , Id > orgWideAddressMap = new Map< String, Id >();
			for( OrgWideEmailAddress orgWideAdd  : [select id, DisplayName, Address from OrgWideEmailAddress WHERE Address In ('noreply@amsolutions.net.au','noreply@psa.org.au')] ) {
				orgWideAddressMap.put(orgWideAdd.Address,orgWideAdd.id);
			}


			map<String,Id> emailTemplateMap = new Map<String,Id>();
			for( EmailTemplate emailTemp : [Select id,name from EmailTemplate where name In ('Enrolment Form Template','Welcome to PSA course','Welcome to CW course') ] ){
			    emailTemplateMap.put(emailTemp.name,emailTemp.id); 
			}

			set<Id> bgCorseEnIdSet = new set<Id>();
			for( AS_BG_Course_Enrolment__c bgEnrolment : enrollData ){

				if( bgEnrolment.recordTypeId == CHEMISTWAREHOUSE  ){
					bgCorseEnIdSet.add( bgEnrolment.Id  );
				}

			}

			List<Messaging.SingleEmailMessage> emailListTosentList = new List<Messaging.SingleEmailMessage>();

			list<AS_BG_Course_Enrolment__c> bgCourseEnUpdateToSentList = new list<AS_BG_Course_Enrolment__c>();

			for( AS_BG_Course_Enrolment__c bgCourseEn : [	Select AS_Banner_Group_Course__c ,
																AS_Contact__c,
																AS_Contact__r.Account.ASStore_Email__c,
																AS_Banner_Group_Course__r.AS_Provided_By_PSA__c ,
																AS_Banner_Group_Course__r.AS_Course_Type__c ,
																AS_Banner_Group_Course__r.AS_Status__c,
																AS_Enrolment_Confirmation_Status__c ,
																AS_BG_Enrolment_Form_Sent__c,
																Enrolment_Confirmation_Email_Send__c
																FROM 
															AS_BG_Course_Enrolment__c WHERE Id In:bgCorseEnIdSet ] ){

				Messaging.SingleEmailMessage mailStudent = new Messaging.SingleEmailMessage();
				Messaging.SingleEmailMessage mailStoreEmail = new Messaging.SingleEmailMessage();
				AS_BG_Course_Enrolment__c updateBgCorseEn = new AS_BG_Course_Enrolment__c();

				if( bgCourseEn.AS_Contact__c != null ){

					Boolean hitCriteria = false;

					//AS_PSA_Enrolment_Form 
					if( bgCourseEn.AS_Banner_Group_Course__r.AS_Provided_By_PSA__c  &&  bgCourseEn.AS_Enrolment_Confirmation_Status__c == 'Pending' &&  !bgCourseEn.AS_BG_Enrolment_Form_Sent__c && bgCourseEn.AS_Banner_Group_Course__r.AS_Status__c == 'Active' && bgCourseEn.AS_Banner_Group_Course__r.AS_Course_Type__c == 'RTO' ){
						
						mailStudent.setTemplateID( emailTemplateMap.get('Enrolment Form Template') ); 
						mailStoreEmail.setTemplateID( emailTemplateMap.get('Enrolment Form Template') ); 

						mailStudent.setOrgWideEmailAddressId( orgWideAddressMap.get('noreply@psa.org.au'));
						mailStoreEmail.setOrgWideEmailAddressId( orgWideAddressMap.get('noreply@psa.org.au'));

						updateBgCorseEn.AS_BG_Enrolment_Form_Sent__c = true;

						hitCriteria = true;
					}
					//AS_BG_Welcome_PSA_course  
					else if( bgCourseEn.AS_Banner_Group_Course__r.AS_Provided_By_PSA__c  &&  bgCourseEn.AS_Enrolment_Confirmation_Status__c == 'Confirmed' &&  !bgCourseEn.Enrolment_Confirmation_Email_Send__c && bgCourseEn.AS_Banner_Group_Course__r.AS_Status__c == 'Active' && bgCourseEn.AS_Banner_Group_Course__r.AS_Course_Type__c == 'RTO'){
					
						mailStudent.setTemplateID( emailTemplateMap.get('Welcome to PSA course') );
						mailStoreEmail.setTemplateID( emailTemplateMap.get('Welcome to PSA course') );

						mailStudent.setOrgWideEmailAddressId( orgWideAddressMap.get('noreply@psa.org.au'));
						mailStoreEmail.setOrgWideEmailAddressId( orgWideAddressMap.get('noreply@psa.org.au')); 

						updateBgCorseEn.Enrolment_Confirmation_Email_Send__c = true;
						
						hitCriteria = true;
					}
					//AS_Welcome_to_CW_course  
					else if( !bgCourseEn.AS_Banner_Group_Course__r.AS_Provided_By_PSA__c  &&  bgCourseEn.AS_Enrolment_Confirmation_Status__c == 'Confirmed' &&  !bgCourseEn.Enrolment_Confirmation_Email_Send__c && bgCourseEn.AS_Banner_Group_Course__r.AS_Status__c == 'Active' && bgCourseEn.AS_Banner_Group_Course__r.AS_Course_Type__c == 'RTO'){
						
						mailStudent.setTemplateID( emailTemplateMap.get('Welcome to CW course') );
						mailStoreEmail.setTemplateID( emailTemplateMap.get('Welcome to CW course') ); 

						mailStudent.setOrgWideEmailAddressId( orgWideAddressMap.get('noreply@amsolutions.net.au'));
						mailStoreEmail.setOrgWideEmailAddressId( orgWideAddressMap.get('noreply@amsolutions.net.au')); 	

						updateBgCorseEn.Enrolment_Confirmation_Email_Send__c = true;
						
						hitCriteria = true;
					}

					if( hitCriteria ){
 
						mailStudent.setTargetObjectId( bgCourseEn.AS_Contact__c ); 
						mailStudent.setWhatId(bgCourseEn.Id);
						mailStudent.setSaveAsActivity(false);
						emailListTosentList.add(mailStudent);

						if(  bgCourseEn.AS_Contact__r.Account.ASStore_Email__c != null ){

							mailStoreEmail.setToAddresses(new List < String > { bgCourseEn.AS_Contact__r.Account.ASStore_Email__c });    
							mailStoreEmail.setTargetObjectId( bgCourseEn.AS_Contact__c ); 
							mailStoreEmail.setTreatTargetObjectAsRecipient(false);
							mailStoreEmail.setWhatId(bgCourseEn.Id);
							mailStoreEmail.setSaveAsActivity(false);
							emailListTosentList.add(mailStoreEmail);

						}

						hitCriteria = false;

						updateBgCorseEn.Id = bgCourseEn.Id;						
						bgCourseEnUpdateToSentList.add(updateBgCorseEn);

					}

				}
			}

			if( emailListTosentList.size() != 0 ){
				Messaging.sendEmail(emailListTosentList,false);
				update bgCourseEnUpdateToSentList;
			}

		}

	}


}