public with sharing class AsBgCourseTriggerHandler {
  // This should be used in conjunction with the ApexTriggerComprehensive.trigger template
  // The origin of this pattern is http://www.embracingthecloud.com/2010/07/08/ASimpleTriggerTemplateForSalesforce.aspx
  @testVisible private boolean m_isExecuting = false;
  @testVisible private integer BatchSize = 0;

  public AsBgCourseTriggerHandler(boolean isExecuting, integer size){
    m_isExecuting = isExecuting;
    BatchSize = size;
  }

  public void OnBeforeInsert(AS_BG_Course__c[] newRecords){
    /*
    //Example usage
    for(AS_BG_Course__c newRecord : newRecords){
      if(newRecord.AnnualRevenue == null){
        newRecord.AnnualRevenue.addError('Missing annual revenue');
      }
    }
    */ 
  } 

  public void OnAfterInsert(AS_BG_Course__c[] newRecords){
  	createLMSCourseIfNotFound(newRecords,new Map<ID, AS_BG_Course__c>(),new Map<ID, AS_BG_Course__c>(),'INSERT');
  }

  @future public static void OnAfterInsertAsync(Set<ID> newRecordIDs){
  }

  public void OnBeforeUpdate(AS_BG_Course__c[] newRecord, Map<ID, AS_BG_Course__c> oldMap, Map<ID, AS_BG_Course__c> newMap){
  	
  }

  public void OnAfterUpdate(AS_BG_Course__c[] newRecord, Map<ID, AS_BG_Course__c> oldMap, Map<ID, AS_BG_Course__c> newMap){
		updateBgCourseLMSCourse(newRecord,oldMap,newMap);
    createLMSCourseIfNotFound(newRecord,oldMap,newMap,'UPDATE');
  }

  @future public static void OnAfterUpdateAsync(Set<ID> updatedRecordIDs){
    //List<AS_BG_Course__c> updatedRecords = [select Id, Name from AS_BG_Course__c where Id IN :updatedRecordIDs];
  }

  public void OnBeforeDelete(AS_BG_Course__c[] recordsToDelete, Map<ID, AS_BG_Course__c> recordMap){

  }

  public void OnAfterDelete(AS_BG_Course__c[] deletedRecords, Map<ID, AS_BG_Course__c> recordMap){

  }

  @future public static void OnAfterDeleteAsync(Set<ID> deletedRecordIDs){

  }

  public void OnUndelete(AS_BG_Course__c[] restoredRecords){

  }

  @testVisible public boolean IsTriggerContext{
    get{ return m_isExecuting;}
  }

  @testVisible public boolean IsVisualforcePageContext{
    get{ return !IsTriggerContext;}
  }

  @testVisible public boolean IsWebServiceContext{
    get{ return !IsTriggerContext;}
  }

  @testVisible public boolean IsExecuteAnonymousContext{
    get{ return !IsTriggerContext;}
  }

  /*
  * Author : Jet R. Compayan
  * Description: method to will create Lms Course  ( ticket # PSABG-5 )
  * Updated by : John Hope for (#PSABG-51)
  * Parameter : 0. List = list of AS_BG_Course__c
  * Return : None
  */
  public void createLMSCourseIfNotFound(AS_BG_Course__c[] newRecord, Map<ID, AS_BG_Course__c> oldMap, Map<ID, AS_BG_Course__c> newMap, String action){

    Map <Id , AS_BG_Course__c > BgCourseMap = new Map< Id, AS_BG_Course__c >();
    Map <Id , String > lmsCourseMap = new Map< Id, String >();

    for( AS_BG_Course__c bgCourse : newRecord ){
      if( bgCourse.AS_Status__c == 'Active' ){
        if(action == 'INSERT' || (action == 'UPDATE' && bgCourse.AS_Status__c != oldMap.get( bgCourse.Id ).AS_Status__c)){
          BgCourseMap.put( bgCourse.Id , bgCourse );
        }
      }
    } 

    if( BgCourseMap.size() != 0 ){
      list< LMS_Course__c > lmsCourseList = new list< LMS_Course__c >();
      map<string,Id> lmsExtIdandBgIdMap = new map<string,Id>();

      for( Id bgCourseKey : BgCourseMap.keySet() ){
				if(BgCourseMap.get(bgCourseKey).AS_LMS_Course__c == null ) {
          AS_BG_Course__c BgCourse = BgCourseMap.get(bgCourseKey);
          String randomStrForExtId = AS_commonFunction.generateRandomString(16); 

          LMS_Course__c newLmsCourse = new LMS_Course__c();
          newLmsCourse.LMS_Instance__c =  BgCourse.LMS_Instance_lookup__c;
          newLmsCourse.Name  = BgCourse.Name;
          newLmsCourse.Status__c = BgCourse.AS_Status__c;
          newLmsCourse.Date__c = BgCourse.AS_Course_Start_Date__c;
          newLmsCourse.AsLmsCrouseExtId__c = randomStrForExtId;

          lmsExtIdandBgIdMap.put(randomStrForExtId,bgCourseKey);

          // set the new lms Course for thie Bg couse
          lmsCourseList.add(newLmsCourse);

        }
      }
      
      if( lmsCourseList.size() != 0 ){ 
      	insert lmsCourseList;

	      list< AS_BG_Course__c > bgCourseLst = new list<AS_BG_Course__c>();
	      for( LMS_Course__c lsmCourse : lmsCourseList ){
	        AS_BG_Course__c bgCourse = new AS_BG_Course__c();
	        bgCourse.Id = lmsExtIdandBgIdMap.get(lsmCourse.AsLmsCrouseExtId__c);
	        bgCourse.AS_LMS_Course__c = lsmCourse.Id;
	        bgCourseLst.add(bgCourse);
	      }

	      if( bgCourseLst.size() != 0 ){
	        update bgCourseLst;
	      }
    	}
    }
 
  } 



  
  /*
	* Author : john hope
	* Description: method to Update BG Course, update LMS Course (#PSABG-11)
	* Parameter : None
	* Return : None
	*/
	public void updateBgCourseLMSCourse(AS_BG_Course__c[] newRecord, Map<ID, AS_BG_Course__c> oldMap, Map<ID, AS_BG_Course__c> newMap) {
		List<LMS_Course__c> allTobeUpdatedLMSList = new List<LMS_Course__c>();
		for(AS_BG_Course__c BgCourse : [SELECT 
																			AS_Description__c,
																			AS_Status__c,
																			AS_LMS_Course__c,
																			AS_LMS_Course__r.AS_Update_LMS_Course__c,
																			Id,
																			Name,
																			LMS_Instance_lookup__c
																		FROM 
																			AS_BG_Course__c 
																		where 
																			Id IN :newMap.keySet()
																		]) {
			if(BgCourse.AS_LMS_Course__c != null && oldMap.get(BgCourse.Id).AS_LMS_Course__c !=null) {
				LMS_Course__c indiTobeUpdatedLMSList = new LMS_Course__c();
				indiTobeUpdatedLMSList.Id = BgCourse.AS_LMS_Course__c;
				indiTobeUpdatedLMSList.Name = BgCourse.Name;
				indiTobeUpdatedLMSList.LMS_Instance__c = BgCourse.LMS_Instance_lookup__c;
				indiTobeUpdatedLMSList.Description__c = BgCourse.AS_Description__c;
				indiTobeUpdatedLMSList.Status__c = (BgCourse.AS_Status__c != 'Active')?'Non-active':'Active';
				indiTobeUpdatedLMSList.AS_Update_LMS_Course__c = (BgCourse.AS_LMS_Course__r.AS_Update_LMS_Course__c == true)?false:true;
				allTobeUpdatedLMSList.add(indiTobeUpdatedLMSList);
			}
		}
		if(allTobeUpdatedLMSList.size() > 0) {
			System.debug('allTobeUpdatedLMSList : ' + allTobeUpdatedLMSList);
			update allTobeUpdatedLMSList; // to be uncomment
		}
		
	}
	

}