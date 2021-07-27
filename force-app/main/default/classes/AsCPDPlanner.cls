/*Author : John Hope
*Description : This is a class for CPD Planner
*Date Created : April 27, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : 
*/
global class AsCPDPlanner {
	public Boolean isAuthorized {get;set;}
	public String theFullurl {get;set;}
	 /*Author : John Hope
  *Description : constructor
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
	global AsCPDPlanner(){
		Set<String> allProfile = new Set<String>{
																							'member login user',
																							'psa system administrator',
																							'psa exec team',
																							'system administrator',
																							'psa education staff user',
																							'psa membership staff user',
																							'psa standard user'
																						};
																						
		User userPro = [Select Id,Profile.Name from User where Id = :userinfo.getuserId() LIMIT 1];
		if(allProfile.contains(userPro.Profile.Name.toLowercase())){
			isAuthorized = true;
		} else {
			isAuthorized = false;
		}
		
		ASPSASettings__c psaSettings = ASPSASettings__c.getOrgDefaults();
		theFullurl = (psaSettings.AsMembershipRegistrationURL__c!=null)?String.valueOf(psaSettings.AsMembershipRegistrationURL__c):'https://staging-staging-pharmaceuticalaus.cs6.force.com'; //staging url as default if no given data
		
		
		
 	}
 	
 	/*Author : John Hope
  *Description : getter and setter for CPD Competencies
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified : 
  *Param : 
  *Return : Map<String,List<AsCPDPlannerCompetencies__c>>
  */
  @RemoteAction   
 	global static Map<String,List<competencyChecker>> allCPDPlannerCompetencies(String cpdPlanner) {
		Map<String,List<competencyChecker>> allCPDPlannerCompetenciesMap = new Map<String,List<competencyChecker>>();
		
		Id finalCpdPlanReview;
		
		if(String.isNotBlank(cpdPlanner)) {
			finalCpdPlanReview = getCPDPlannerReview(Id.valueOf(cpdPlanner));
			System.debug('has cpd in url ');
		} else {
			System.debug('has cpd in url no ');
			Id cpdPlan = getCurrentPlan(userinfo.getuserId());
			finalCpdPlanReview = getCPDPlannerReview(cpdPlan);
		}
		System.debug('finalCpdPlanReview : ' + finalCpdPlanReview);
		
		Map<Id,Boolean> existingComMap = new Map<Id,Boolean>();
		
		if( finalCpdPlanReview != null) {
			for(AsCPDPlannerCompetencieslink__c planComLink : [Select 
																															AsCPDPlannerCompetencies__c,
																															AsCPDPlannerReview__c,
																															Id,
																															Name 
																														from 
																															AsCPDPlannerCompetencieslink__c 
																														where 
																															AsCPDPlannerReview__c = :finalCpdPlanReview
																														]) {
				existingComMap.put(planComLink.AsCPDPlannerCompetencies__c,true);
			}
		}
		
		for(AsCPDPlannerCompetencies__c com: [Select 
																						AsDescription__c,
																						AsDomain__c,
																						AsStatus__c,
																						Id,
																						Name 
																					from 
																						AsCPDPlannerCompetencies__c 
																					where 
																						AsStatus__c= 'Active' 
																					ORDER BY 
																						Name ASC
																				]) {
			if(com.AsDomain__c != null) {
				String domainString = com.AsDomain__c.toLowerCase();
				if( allCPDPlannerCompetenciesMap.containsKey( domainString ) ){
					competencyChecker comCheck = new competencyChecker( com,( existingComMap.containsKey(com.Id)?true:false ) );
					allCPDPlannerCompetenciesMap.get(domainString).add(comCheck);
				} else {
					competencyChecker comCheck = new competencyChecker( com,( existingComMap.containsKey(com.Id)?true:false ) );
					allCPDPlannerCompetenciesMap.put(domainString,new List<competencyChecker>{comCheck});
				}
			}
		}
		 
		return allCPDPlannerCompetenciesMap;
 	}
 	
 	 /*Author : John Hope
  *Description : getter and setter for CPD Topics
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified : 
  *Param : 
  *Return : List<AsCPDPlannerTopic__c>
  */
  @remoteAction 
 	public static List<topicChecker> allCPDTopics(String cpdPlanner) {
 		// topicChecker
 		Id finalCpdPlanReview;
		
		if(String.isNotBlank(cpdPlanner)) {
			finalCpdPlanReview = getCPDPlannerReview(Id.valueOf(cpdPlanner));
			System.debug('has cpd in url ');
		} else {
			System.debug('has cpd in url no ');
			Id cpdPlan = getCurrentPlan(userinfo.getuserId());
			finalCpdPlanReview = getCPDPlannerReview(cpdPlan);
		}
																							
		Map<Id,Boolean> existingTopicMap = new Map<Id,Boolean>();
		
		if(finalCpdPlanReview != null) {
			for(AsCPDPlannerTopicLink__c planTopicLink : [Select 
																											AsCPDPlannerTopic__c,
																											AsCPDPlannerReview__c,
																											Id,
																											Name 
																										from 
																											AsCPDPlannerTopicLink__c 
																										where 
																											AsCPDPlannerReview__c = :finalCpdPlanReview
																										]) {
				existingTopicMap.put(planTopicLink.AsCPDPlannerTopic__c,true);
			}
		}
																							
		List<topicChecker> allCPDTopicsList = new List<topicChecker>();
		for(AsCPDPlannerTopic__c topic: [Select 
																				AsStatus__c,
																				Id,
																				Name 
																			from 
																				AsCPDPlannerTopic__c 
																			where 
																				AsStatus__c= 'Active' 
																			ORDER BY 
																				Name ASC]) {
			topicChecker topCheck = new topicChecker( topic, existingTopicMap.containsKey(topic.Id)?true:false );
			allCPDTopicsList.add(topCheck);
		}
		System.debug('allCPDTopicsList : ' + allCPDTopicsList);
    return allCPDTopicsList;
 	}
 	
 	 /*Author : John Hope
  *Description : Process the competencies and topics selected
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified : 
  *Param : String
  *Return :
  */   
 	@RemoteAction
	public static processCPDResult processCPD(String CPDData) {
		Savepoint sp = Database.setSavepoint();
		try {
			AsCPDPlannerWrapper theFinal = (AsCPDPlannerWrapper)JSON.deserializeStrict(CPDData,AsCPDPlannerWrapper.class);
			System.debug('theFinal :' + theFinal);
			
			Set<Id> allSelCompQuerySet = new Set<Id>();
			Set<Id> allSelTopQuerySet = new Set<Id>();
			
			Id finalCpdPlanReview;
			
			if(String.isNotBlank(theFinal.CpdId)) {
				finalCpdPlanReview = getCPDPlannerReview(Id.valueOf(theFinal.CpdId));
				System.debug('has cpd in url ');
			} else {
				System.debug('has cpd in url no ');
				Id cpdPlan = getCurrentPlan(userinfo.getuserId());
				finalCpdPlanReview = getCPDPlannerReview(cpdPlan);
			}
			
			if( finalCpdPlanReview != null ) {
				
				// insertion of planner compentencies link starts here
				for(String key : theFinal.Competency.KeySet()) {
					if( theFinal.Competency.get(key) ==  true ) {
						allSelCompQuerySet.add(Id.valueOf(key));
					}
				}
				
				for(AsCPDPlannerCompetencies__c com: [Select 
																								AsDescription__c,
																								AsDomain__c,AsStatus__c,
																								Id,
																								Name 
																							from 
																								AsCPDPlannerCompetencies__c 
																							where 
																								AsStatus__c= 'Active' 
																							AND 
																								AsDomain__c NOT IN ('Domain 3', 'Domain 4.3-4.7', 'Domain 5') 
																							ORDER BY 
																								Name ASC
																						]) {
					allSelCompQuerySet.add(com.Id);
				}
				
				// query for deletion start
				List<AsCPDPlannerCompetencieslink__c> planComToDelete = [Select 
																																		Id
																																	from 
																																		AsCPDPlannerCompetencieslink__c 
																																	where 
																																		AsCPDPlannerReview__c = :finalCpdPlanReview 
																																	AND 
																																		AsCPDPlannerCompetencies__c NOT IN :allSelCompQuerySet
																																];
				delete planComToDelete;
				// query for deletion end
				
				Map<Id,Boolean> existingComMap = new Map<Id,Boolean>();
				for(AsCPDPlannerCompetencieslink__c planComLink : [Select 
																														AsCPDPlannerCompetencies__c,
																														AsCPDPlannerReview__c,
																														Id,
																														Name 
																													from 
																														AsCPDPlannerCompetencieslink__c 
																													where 
																														AsCPDPlannerReview__c = :finalCpdPlanReview
																													AND 
																														AsCPDPlannerCompetencies__c IN :allSelCompQuerySet
																													]) {
					existingComMap.put(planComLink.AsCPDPlannerCompetencies__c,true);
				}
				
				List<AsCPDPlannerCompetencieslink__c> allPlanComLink = new List<AsCPDPlannerCompetencieslink__c>();
				for(Id indiComPlan : allSelCompQuerySet) {
					if(!existingComMap.containsKey(indiComPlan)) {
						AsCPDPlannerCompetencieslink__c indiPlanComLink = new AsCPDPlannerCompetencieslink__c();
						indiPlanComLink.AsCPDPlannerCompetencies__c = indiComPlan;
						indiPlanComLink.AsCPDPlannerReview__c =finalCpdPlanReview;
						allPlanComLink.add(indiPlanComLink);
					}
				}
				System.debug('allPlanComLink :' + allPlanComLink);
				insert allPlanComLink;
				// insertion of planner compentencies link ends here
				
				// insertion of planner topic link starts here
				for(String key : theFinal.Topic.KeySet()) {
					if( theFinal.Topic.get(key) ==  true) {
						allSelTopQuerySet.add(Id.valueOf(key));
					}
				}
				
				// query for deletion start
				List<AsCPDPlannerTopicLink__c> planTopicToDelete = [Select 
																																		Id
																																	from 
																																		AsCPDPlannerTopicLink__c 
																																	where 
																																		AsCPDPlannerReview__c = :finalCpdPlanReview
																																	AND 
																																		AsCPDPlannerTopic__c NOT IN :allSelTopQuerySet
																																];
				delete planTopicToDelete;
				// query for deletion end
				
				Map<Id,Boolean> existingTopicMap = new Map<Id,Boolean>();
				for(AsCPDPlannerTopicLink__c planTopicLink : [Select 
																												AsCPDPlannerTopic__c,
																												AsCPDPlannerReview__c,
																												Id,
																												Name 
																											from 
																												AsCPDPlannerTopicLink__c 
																											where 
																												AsCPDPlannerReview__c = :finalCpdPlanReview
																											AND 
																												AsCPDPlannerTopic__c IN :allSelTopQuerySet
																											]) {
					existingTopicMap.put(planTopicLink.AsCPDPlannerTopic__c,true);
				}
				
				List<AsCPDPlannerTopicLink__c> allPlanTopicLink = new List<AsCPDPlannerTopicLink__c>();
				for(Id indiTopicId : allSelTopQuerySet) {
					if(!existingTopicMap.containsKey(indiTopicId)) {
						AsCPDPlannerTopicLink__c indiPlanTopicLink = new AsCPDPlannerTopicLink__c();
						indiPlanTopicLink.AsCPDPlannerTopic__c = indiTopicId;
						indiPlanTopicLink.AsCPDPlannerReview__c =finalCpdPlanReview;
						allPlanTopicLink.add(indiPlanTopicLink);
					}
				}
				
				System.debug('allPlanTopicLink :' + allPlanTopicLink);
				insert allPlanTopicLink;
				// insertion of planner topic link ends here
			}
			
			Map<Id,Boolean> allComTrainPlanLinkMap = new Map<Id,Boolean>();
			for(AsCPDPlannerCompetenciesTrainingPlanLink__c comTrainPlanLink : [Select 
																																						AsCPDPlannerCompetencies__c, 
																																						AsTrainingPlan__c, 
																																						Id, 
																																						Name 
																																					from 
																																						AsCPDPlannerCompetenciesTrainingPlanLink__c 
																																					where 
																																						AsCPDPlannerCompetencies__c IN :allSelCompQuerySet
																																					]) {
				if(comTrainPlanLink.AsTrainingPlan__c != null) {
					allComTrainPlanLinkMap.put(comTrainPlanLink.AsTrainingPlan__c,true);
				}
			}
			
			Map<Id,Boolean> allTopTrainPlanLinkMap = new Map<Id,Boolean>();
			for(AsCPDPlannerReviewTrainingPlanLink__c topTrainPlanLink : [Select 
																																			AsCPDPlannerTopic__c,
																																			AsTrainingPlan__c,
																																			Id, 
																																			Name  
																																		from 
																																			AsCPDPlannerReviewTrainingPlanLink__c 
																																		where 
																																			AsCPDPlannerTopic__c IN :allSelTopQuerySet
																																	]) {
				if(topTrainPlanLink.AsTrainingPlan__c != null) {
					allTopTrainPlanLinkMap.put(topTrainPlanLink.AsTrainingPlan__c,true);
				}
			}
			
			Set<Id> finalTrainingPlanIdSet = new Set<Id>();
			if(allComTrainPlanLinkMap.size() >= allTopTrainPlanLinkMap.size()) {
				for(Id comTrainKey : allComTrainPlanLinkMap.KeySet()){
					if(allTopTrainPlanLinkMap.containsKey(comTrainKey)) {
						finalTrainingPlanIdSet.add(comTrainKey);
					}
				}
			} else {
				for(Id topTrainKey : allTopTrainPlanLinkMap.KeySet()){
					if(allComTrainPlanLinkMap.containsKey(topTrainKey)) {
						finalTrainingPlanIdSet.add(topTrainKey);
					}
				}
			}
			
			List<Training_Plan__c> finalTrainingPlan = [Select
																										AS_Product__c,
																										AS_Learning_Objectives__c,
																										AS_Training_Plan_Type__c,
																										Background_Color__c,
																										Description__c,
																										End_Date__c,
																										Id,
																										Name,
																										Start_Date__c,
																										Status__c,
																										Text_Color__c,
																										Training_Plan_Rating__c,
																										Type__c,Group__c,
                            																			PSA_Marketing_Text__c,
                            																			Total_Section_Items__c,	
                                                        Achievement__r.Acquired_Image__c,Achievement__r.Eligible_Image__c,
																										(Select 
																												Achievement__r.Acquired_Image__c,
																												Achievement__r.Work_Badge_Image_URL__c,
																												Id,
																												Name 
																											from 
																												Training_Plan_Achievements__r 
																											LIMIT 1
																										)
																									from 
																										Training_Plan__c 
																									where 
																										ID IN :finalTrainingPlanIdSet 
																									and
																										Status__c = 'Active'
																									];
			processCPDResult res = new processCPDResult('SUCCESS','CPD is successfully process',finalTrainingPlan);
			
			return res;
		} catch (Exception exc) {
			Database.rollback(sp);
			
			processCPDResult res = new processCPDResult('ERROR',exc.getMessage(),null);
			return res;
		}
	}
	
	/*Author : John Hope
  *Description : Process training link selected to be a training bookmark
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified : 
  *Param : String
  *Return :
  */   
 	@RemoteAction
	public static processTrainingResult processTrainingBook(String TrainData) {
		Savepoint sp = Database.setSavepoint();
	try {
			Id activeCPDRecId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByName().get('Active CPD Planner').getRecordTypeId();
			System.debug('raw TrainData' + TrainData);
			ASTrainBookmarkWrapper theFinal = (ASTrainBookmarkWrapper)JSON.deserializeStrict(TrainData,ASTrainBookmarkWrapper.class);
			System.debug('theFinal :' + theFinal);
			
			Id finalcpdPlannerId;
			
			if(String.isNotBlank(theFinal.CpdId)) {
				finalcpdPlannerId = Id.valueOf(theFinal.CpdId);
			} else {
				finalcpdPlannerId = getCurrentPlan(userinfo.getuserId());
			}
			
			Set<Id> allSelBookMarkQuerySet = new Set<Id>();
			
			if(finalcpdPlannerId != null) {
				for(String key : theFinal.Training.KeySet()) {
					if( theFinal.Training.get(key) ==  true ) {
						allSelBookMarkQuerySet.add(Id.valueOf(key));
					}
				}
				
				System.debug('allSelBookMarkQuerySet :' + allSelBookMarkQuerySet.size() + ' - ' + allSelBookMarkQuerySet);
				// delete book mark map start
				List<AsTrainingPlanBookmark__c> bookMarkToDelete = [Select 
																															AsTrainingPlan__c,
																															AsCPDPlanner__c,
																															Id,
																															Name 
																														from 
																															AsTrainingPlanBookmark__c 
																														where 
																															AsCPDPlanner__c = :finalcpdPlannerId
																														AND 
																															AsTrainingPlan__c NOT IN :allSelBookMarkQuerySet
																														];
				System.debug('bookMarkToDelete :' + bookMarkToDelete.size() + ' - ' + bookMarkToDelete);
				delete bookMarkToDelete;
				// delete book mark map end
				
				Map<Id,Boolean> existingBookMarkMap = new Map<Id,Boolean>();
				for(AsTrainingPlanBookmark__c planBookMarkLink : [Select 
																												AsTrainingPlan__c,
																												AsCPDPlanner__c,
																												Id,
																												Name 
																											from 
																												AsTrainingPlanBookmark__c 
																											where 
																												AsCPDPlanner__c = :finalcpdPlannerId
																											AND 
																												AsTrainingPlan__c IN :allSelBookMarkQuerySet
																											]) {
					existingBookMarkMap.put(planBookMarkLink.AsTrainingPlan__c,true);
				}
				
				List<AsTrainingPlanBookmark__c> allTrainBookLink = new List<AsTrainingPlanBookmark__c>();
				for(Id planTrainKey : allSelBookMarkQuerySet) {
					if( !existingBookMarkMap.containsKey(planTrainKey) ) {
						AsTrainingPlanBookmark__c indiTrainBook = new AsTrainingPlanBookmark__c();
						indiTrainBook.AsTrainingPlan__c = planTrainKey;
						indiTrainBook.AsCPDPlanner__c =finalcpdPlannerId;
						indiTrainBook.AsFromCPDPlanTool__c = true; // added for this (#PSA-236)
						allTrainBookLink.add(indiTrainBook);
					}
				}
				System.debug('insert allTrainBookLink :' + allTrainBookLink);
				insert allTrainBookLink;
				
			
			}
			
			processTrainingResult res = new processTrainingResult('SUCCESS','CPD is successfully process');
			
			return res;
			
		} catch (Exception exc) {
			Database.rollback(sp);
			
			processTrainingResult res = new processTrainingResult('ERROR',exc.getMessage());
			return res;
		} 
		
	}
	
	/*Author : John Hope
  *Description : wrapper controller that will hold the training plan
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified : 
  *Param : String
  *Return :
  */   
	public class processCPDResult {  
    public String status {get; set;}
    public String message {get; set;}
    public List<Training_Plan__c> training {get; set;}
    
    public processCPDResult(String sta, String mes,List<Training_Plan__c> train) {
        status = sta;
        message = mes;
        training = train;
    }
	}
	
	/*Author : John Hope
  *Description : wrapper controller that will hold the training bookmark
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified : 
  *Param : String
  *Return :
  */   
	public class processTrainingResult {  
    public String status {get; set;}
    public String message {get; set;}
    
    public processTrainingResult(String sta, String mes) {
        status = sta;
        message = mes;
    }
	}
	
	/*Author : John Hope
  *Description : wrapper controller that will hold competencies data and if competency is selected.
  *Date Created : May 16,2018
  *Last Modified By : John Hope
  *Date Last Modified : 
  *Param : String
  *Return :
  */   
	public class competencyChecker {  
    public AsCPDPlannerCompetencies__c competency {get; set;}
    public Boolean selected {get; set;}
    
    public competencyChecker(AsCPDPlannerCompetencies__c comp, Boolean sel) {
        competency = comp;
        selected = sel;
    }
	}
	
	/*Author : John Hope
  *Description : wrapper controller that will hold topics data and if topic is selected.
  *Date Created : May 16,2018
  *Last Modified By : John Hope
  *Date Last Modified : 
  *Param : String
  *Return :
  */   
	public class topicChecker {  
    public AsCPDPlannerTopic__c topic {get; set;}
    public Boolean selected {get; set;}
    
    public topicChecker(AsCPDPlannerTopic__c comp, Boolean sel) {
        topic = comp;
        selected = sel;
    }
	}
	
	/*Author : John Hope
  *Description : method for getting user base on cpd planner id
  *Date Created : June 1, 2018
  *Last Modified By : John Hope
  *Date Last Modified : 
  *Param : String
  *Return : Id
  */   
	public static Id getUserfromCPDPlanner(String cpdIdStr) {  
		Id finalId = null;
		try {
	    List<AsCPDPlanner__c> cpdPlanner = [Select Id,Name, AsUser__c from AsCPDPlanner__c where Id = :cpdIdStr];
	    if(cpdPlanner.size() > 0) {
	    	if(cpdPlanner[0].AsUser__c != null) {
	    		finalId = cpdPlanner[0].AsUser__c;
	    	} 
	    } 
		} catch(Exception e) {
			
		}
    return finalId;
	}
	
	/*Author : John Hope
  *Description : method for transferring training bookmark to the latest cpd plan (#PSAS-74)
  *Date Created : June 22, 2018
  *Last Modified By : John Hope
  *Date Last Modified : 
  *Param : String
  *Return : Id
  */   
  @AuraEnabled 
	webservice static void transferBookmark(String cpdIdStr) { 
		Id cpdUser = AsCPDPlanner.getUserfromCPDPlanner(cpdIdStr);
		if(cpdUser!=null) {
			System.debug('cpdUser : ' + cpdUser);
			List<AsCPDPlanner__c> currentPlanner = [Select 
																								AsUser__c,
																								Id,
																								Name  
																							from 
																								AsCPDPlanner__c 
																							where 
																								AS_Current_CPD_Plan__c=true 
																							and 
																								AsUser__c = :cpdUser
																							ORDER BY createdDate DESC
																							LIMIT 1  
																							];
			
			AsCPDPlanner__c checkOldPlanner = [Select 
																					AS_Current_CPD_Plan__c,
																					Id
																				from 
																					AsCPDPlanner__c 
																				where 
																					Id = :Id.ValueOf(cpdIdStr)  
																				];
			if(currentPlanner.size()>0 && checkOldPlanner.AS_Current_CPD_Plan__c == false) {
				System.debug('currentPlanner : ' + currentPlanner);
				Map<String,boolean> allCurCpdTrainPlanMap = new Map<String,boolean>();
				// loop to get existing cpd activity summary
				for(AsCPD_Learning_Summary__c actSumm : [Select 
																										Name,
																										ASTraining_Plan_Name__c,
																										ASTraining_Plan_Assignment__r.Training_Plan__c,
																										AS_Training_Plan_Record_ID__c,
																										Id 
																									from
																										AsCPD_Learning_Summary__c
																									where 
																										CPD_Planner__c = :currentPlanner[0].Id
																									]) {
					if(actSumm.AS_Training_Plan_Record_ID__c !=null) {
						allCurCpdTrainPlanMap.put(actSumm.AS_Training_Plan_Record_ID__c.toLowerCase().trim(),true);	
					}
					if(actSumm.Name !=null) {
						allCurCpdTrainPlanMap.put(actSumm.Name.toLowerCase().trim(),true);	
					}
				}
				
				
				System.debug('allCurCpdTrainPlanMap : ' + allCurCpdTrainPlanMap);
				// loop to get all to be added cpd activity summary
				List<AsCPD_Learning_Summary__c> allNewActSummList = new List<AsCPD_Learning_Summary__c>();
				List<AsCPD_Learning_Summary__c> allOldActSummList = new List<AsCPD_Learning_Summary__c>();
				for(AsCPD_Learning_Summary__c actSumm : [Select 
																										ASTraining_Plan_Assignment__c,
																										ASTraining_Plan_Assignment__r.Training_Plan__c,
																										ASTraining_Plan_Name__c,
																										AS_Training_Plan_Record_ID__c,
																										CPD_Planner__c,
																										Group_1_CPD__c,
																										Group_2_CPD__c,
																										CPD_Accreditation_Number__c,
																										X2016_Competencies__c,
																										Provider__c,
																										Description__c,
																										Id,
																										Name,
																										RecordTypeId,
																										Status__c 
																									from
																										AsCPD_Learning_Summary__c
																									where 
																										CPD_Planner__c = :cpdIdStr
																									AND
																										Status__c != 'Complete'
																									]) {
					String finalKey = String.isNotBlank(actSumm.AS_Training_Plan_Record_ID__c)?actSumm.AS_Training_Plan_Record_ID__c.toLowerCase().trim():actSumm.Name.toLowerCase().trim();
					if(!allCurCpdTrainPlanMap.containsKey(finalKey)) {
						/* block below commented out for (#PSA-274)
						// block below added for (#PSA-212)
						AsCPD_Learning_Summary__c inditobeUpdatedLearnSummList = new AsCPD_Learning_Summary__c();
						inditobeUpdatedLearnSummList.Id = actSumm.Id;
						inditobeUpdatedLearnSummList.ASTraining_Plan_Assignment__c = null;
						allOldActSummList.add(inditobeUpdatedLearnSummList);
						*/
						
						AsCPD_Learning_Summary__c inditobeAddedLearnSummList = new AsCPD_Learning_Summary__c();
						inditobeAddedLearnSummList.Name = (String.isNotBlank(actSumm.ASTraining_Plan_Name__c)) ? actSumm.ASTraining_Plan_Name__c:actSumm.Name;
						inditobeAddedLearnSummList.ASTraining_Plan_Name__c = actSumm.ASTraining_Plan_Name__c;
						inditobeAddedLearnSummList.AS_Training_Plan_Record_ID__c = actSumm.AS_Training_Plan_Record_ID__c; // added for (#PSA-212)
						inditobeAddedLearnSummList.ASTraining_Plan_Assignment__c = actSumm.ASTraining_Plan_Assignment__c; 
						inditobeAddedLearnSummList.Group_1_CPD__c = actSumm.Group_1_CPD__c;
						inditobeAddedLearnSummList.Group_2_CPD__c = actSumm.Group_2_CPD__c;
						inditobeAddedLearnSummList.CPD_Accreditation_Number__c = actSumm.CPD_Accreditation_Number__c;
						inditobeAddedLearnSummList.X2016_Competencies__c = actSumm.X2016_Competencies__c;
						inditobeAddedLearnSummList.Provider__c = actSumm.Provider__c;
						inditobeAddedLearnSummList.Description__c = actSumm.Description__c;
						inditobeAddedLearnSummList.CPD_Planner__c = currentPlanner[0].Id;
						inditobeAddedLearnSummList.Status__c = actSumm.Status__c;
						inditobeAddedLearnSummList.RecordTypeId = actSumm.RecordTypeId;
						allNewActSummList.add(inditobeAddedLearnSummList);
					}
				}
				System.debug('allNewActSummList : ' + allNewActSummList);
				insert allNewActSummList;
			//	update allOldActSummList; // block below commented out for (#PSA-274)
			}	
		}
	}
	
	/*Author : John Hope
  *Description : check cpd planner review by the cpd planner given
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified : 
  *Param : Id (cpd planner id)
  *Return : Id  - cpd Plan Review Id
  */  
 	public static Id getCPDPlannerReview(Id cpdPlannerId) {
 		Id finalReviewId = null;
 		try {
			List<AsCPDPlannerReview__c> planReview = [Select 
																										Id,
																										Name 
																									from 
																										AsCPDPlannerReview__c 
																									where 
																										AsCpdPlan__c =:cpdPlannerId 
																									ORDER BY 
																										CreatedDate LIMIT 1
																								];
			if(planReview.size() > 0) {
				finalReviewId = planReview[0].Id;
			} else {
				AsCPDPlanner__c plan = [Select Id,Name,AS_Plan_Year__c,AsUser__r.Name from AsCPDPlanner__c where Id = :cpdPlannerId];
				
				AsCPDPlannerReview__c singlecpdPlannerRev = new AsCPDPlannerReview__c();
				singlecpdPlannerRev.Name = plan.AsUser__r.Name + ' - Review ' + plan.AS_Plan_Year__c;
				singlecpdPlannerRev.AsUser__c = plan.AsUser__c;
				singlecpdPlannerRev.AsCpdPlan__c = cpdPlannerId;
				insert singlecpdPlannerRev;
				
				finalReviewId = singlecpdPlannerRev.Id;
			}
	 	} catch (Exception e){
	 	}
	 	return finalReviewId;
 	}
 	
 	/*Author : John Hope
  *Description : check the current cpd plan of a user
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified : 
  *Param : Id (cpd planner id)
  *Return : Id  - cpd Plan Review Id
  */  
 	public static Id getCurrentPlan(Id userId) {
 		Id finalCurrentPlanId = null;
 		Id activeCPDRecId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByName().get('Active CPD Planner').getRecordTypeId();
 		try {
			List<AsCPDPlanner__c> curPlan = [Select 
																				Id,
																				Name 
																			from 
																				AsCPDPlanner__c 
																			where 
																				AsUser__c =:userId  
																			AND 
																				AS_Current_CPD_Plan__c = true 
																			AND
																				recordTypeId = :activeCPDRecId 
																			ORDER BY 
																				CreatedDate LIMIT 1
																			];
			if(curPlan.size() > 0) {
				finalCurrentPlanId = curPlan[0].Id;
			}
	 	} catch (Exception e){
	 	}
	 	return finalCurrentPlanId;
 	}
	
	
	
	
}