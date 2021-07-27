/*Author : John Hope
*Description : This is a class that handles AsCPDPlanner__c File Object Trigger.
*Date Created : May 9, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : AsCPDPlanner__c
*/
public class AsCPDPlannerTriggerHandler {
    private boolean isExecutingBool = false;
    
    /*Author : John Hope
    *Description : this is a constructor
    *Date Created : May 9, 2018
    *Last Modified By : 
    *Date Last Modified : May 9, 2018
    *Related Meta Data :
    *Param : 
        0. boolean - set value for isExecutingBool 
    *Return : 
    */
    public AsCPDPlannerTriggerHandler(boolean isExecuting){
        isExecutingBool = isExecuting;
    }
    
    /*Author : John Hope
    *Description : handler for before insert trigger for object AsCPDPlanner__c
    *Date Created : May 9, 2018
    *Last Modified By : 
    *Date Last Modified : May 9, 2018
    *Related Meta Data :
    *Param : 
        0. List<Object> - the new Object from trigger
    *Return : 
    */
    public void OnBeforeInsert(Object[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
        checkIfPlanExist(newObjects,new Map<Id,Object>(),new Map<Id,Object>(), 'INSERT');
    }
    
    /*Author : John Hope
    *Description : handler for after insert trigger for object AsCPDPlanner__c
    *Date Created : May 9, 2018
    *Last Modified By : 
    *Date Last Modified : May 9, 2018
    *Related Meta Data :
    *Param :
        0. List<Object> - the new Object from trigger
    *Return : 
    */
    public void OnAfterInsert(Object[] newObjects,Map<Id,Object> newMapObjects) {
	    System.debug('after insert for cpd');
	    Set<Id> allCPDPlannerIDForPDFSet = new Set<Id>();
	    List<Id> allCPDPlannerIDForPDFList = new List<Id>();
	    Integer maxInt = 0;
	    for( AsCPDPlanner__c cpd : (List<AsCPDPlanner__c>) newObjects) {
	    	if(cpd.AsGenerateCPDsummary__c == true && maxInt<= 25) {
	        allCPDPlannerIDForPDFSet.add(cpd.Id);
	        maxInt++;
        } else if(maxInt > 25) {
        	break;
        }
	    }
	    
			// calling createCPDPlannerReview 8/17/18
			createCPDPlannerReview(newObjects,new Map<Id,Object>(),new Map<Id,Object>());
    
    	if(allCPDPlannerIDForPDFSet.size()>0 && !System.isFuture() && !System.isBatch() && AS_HelperClass.TrainingPlanPreviewValidation(UserInfo.getUserId()) != false) {
        allCPDPlannerIDForPDFList.addAll(allCPDPlannerIDForPDFSet);
        AsCPDPdfController.createCPDPdf(allCPDPlannerIDForPDFList);
    	}
        
    }
    
    /*Author : John Hope
    *Description : handler for before update trigger for object AsCPDPlanner__c
    *Date Created : May 9, 2018
    *Last Modified By : 
    *Date Last Modified : May 9, 2018
    *Related Meta Data :
    *Param :
        0. List<Object> - the old Object from trigger
        1. List<Object> - the new Object from trigger
        2. List<Object> - the new Map Object from trigger
    *Return : 
    */
    public void OnBeforeUpdate(Object[] updatedObjects, Map<Id,Object> oldMap, Map<Id,Object> newMap){
			checkIfPlanExist(updatedObjects,oldMap,newMap, 'UPDATE');
        // commented because of validation rule 'Lock_CPD_Planner' inside cpd plan object
        /*
        Id inActiveCPDRecId = Schema.SObjectType.AsCPDPlanner__c.getRecordTypeInfosByName().get('Inactive CPD Planner').getRecordTypeId();
        Integer triggerIndex = 0;
        
        for( AsCPDPlanner__c cpd : (List<AsCPDPlanner__c>) updatedObjects) {
            
            AsCPDPlanner__c tempCPD = (AsCPDPlanner__c) oldMap.get(cpd.Id);
            
            if(tempCPD.RecordTypeId == inActiveCPDRecId) {
                Trigger.new[triggerIndex].addError('You Can only Update an active CPD Planner.');
            }
            triggerIndex++;
            
        }
        */
        
    }
    
    /*Author : John Hope
    *Description : handler for after update trigger for object AsCPDPlanner__c
    *Date Created : May 9, 2018
    *Last Modified By : 
    *Date Last Modified : May 9, 2018
    *Related Meta Data :
    *Param :
        0. List<Object> - the old Object from trigger
        1. List<Object> - the new Object from trigger
        2. List<Object> - the new Map Object from trigger
    *Return : 
    */
    public void OnAfterUpdate(Object[] updatedObjects,Map<Id,Object> oldMap,Map<Id,Object> newMap) {
	    Set<Id> allCPDPlannerIDForPDFSet = new Set<Id>();
	    List<Id> allCPDPlannerIDForPDFList = new List<Id>();
	    Integer maxInt = 0;
	    for( AsCPDPlanner__c cpd : (List<AsCPDPlanner__c>) updatedObjects) {
        AsCPDPlanner__c  newFromMap = (AsCPDPlanner__c)newMap.get(cpd.Id);
        AsCPDPlanner__c  oldFromMap = (AsCPDPlanner__c)oldMap.get(cpd.Id);
		    if(cpd.AsGenerateCPDsummary__c == true && maxInt<= 25 && oldFromMap.AsGenerateCPDsummary__c != newFromMap.AsGenerateCPDsummary__c) {
	        allCPDPlannerIDForPDFSet.add(cpd.Id);
	        maxInt++;
		    } else if(maxInt > 25) {
	        break;
	    	}
			}
			
			// creation of pdf
			if(allCPDPlannerIDForPDFSet.size()>0 && !System.isFuture() && !System.isBatch() && AS_HelperClass.TrainingPlanPreviewValidation(UserInfo.getUserId()) != false) {
		    allCPDPlannerIDForPDFList.addAll(allCPDPlannerIDForPDFSet);
		    AsCPDPdfController.createCPDPdf(allCPDPlannerIDForPDFList);
		    
		    AsCPDPlannerTriggerHandler.run = false;
	    } else {
	         AsCPDPlannerTriggerHandler.run = true;
	    }
    }
    
    /*Author : John Hope
    *Description : handler for before delete trigger for object AsCPDPlanner__c
    *Date Created : May 9, 2018
    *Last Modified By : 
    *Date Last Modified : May 9, 2018
    *Related Meta Data :
    *Param : List<AsCPDPlanner__c>,List<AsCPDPlanner__c>
        0. List<AsCPDPlanner__c> - the old AsCPDPlanner__c data from trigger
        1. Map<Id,AsCPDPlanner__c> - the old Map data from trigger
    *Return : 
    */
    public void OnBeforeDelete(Object[] oldObjects,Map<Id,Object>  MapObjectMap){
    
        
    }
    
    /*Author : John Hope
    *Description : handler for after delete trigger for object AsCPDPlanner__c
    *Date Created : May 9, 2018
    *Last Modified By : 
    *Date Last Modified : May 9, 2018
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
    *Description : handler for undelete trigger for object AsCPDPlanner__c
    *Date Created : May 9, 2018
    *Last Modified By : 
    *Date Last Modified : May 9, 2018
    *Related Meta Data :
    *Param :
        0. List<Object> - the new object data list from trigger
    *Return : 
    */
    public void OnUndelete(Object[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }
    
    /*Author : John Hope
	*Description : check if plan year already exist for a given user
	*Date Created : August 28, 2018
	*Last Modified By : 
	*Date Last Modified :
	*Related Meta Data :
	*Param :
		0. List<Object> - the old Object from trigger
    1. List<Object> - the new Object from trigger
    2. List<Object> - the new Map Object from trigger
	*Return : 
 	*/
	public static void checkIfPlanExist(Object[] newObjects,Map<Id,Object> oldMap,Map<Id,Object> newMap,String action) {
		System.debug('checkIfPlanExist  here');
		Set<String> allPlanYearStrSet = new Set<String>();
		Set<Id> allPlanUserIdSet = new Set<Id>();
		Set<Id> allPlanIdSet = new Set<Id>();
		for( AsCPDPlanner__c cpd : (List<AsCPDPlanner__c>) newObjects) {
    	AsCPDPlanner__c  newFromMap = (AsCPDPlanner__c)newMap.get(cpd.Id);
    	AsCPDPlanner__c  oldFromMap = (AsCPDPlanner__c)oldMap.get(cpd.Id);
	    if(action == 'INSERT' || (action == 'UPDATE' && (newFromMap.AS_Plan_Year__c != oldFromMap.AS_Plan_Year__c || newFromMap.AsUser__c != oldFromMap.AsUser__c))) {
  			if(cpd.AsUser__c != null) {
  				allPlanUserIdSet.add(cpd.AsUser__c);
  			}
  			if(String.isNotBlank(cpd.AS_Plan_Year__c)) {
  				allPlanYearStrSet.add(cpd.AS_Plan_Year__c);
  			}
  			
  			if(action == 'UPDATE') {
  				allPlanIdSet.add(cpd.Id);
  			}
	    }
	    
	    if(cpd.AsUser__c == null) {
	    	cpd.AsUser__c = userinfo.getuserId(); // added for ticket #PSA-323
	    }
		}
		
		Map<String,Id> existCPDPlanMap = new Map<String,Id>();
		for(AsCPDPlanner__c cpd : [Select 
																	AS_Plan_Year__c,
																	AsUser__c,
																	Id
																from
																	AsCPDPlanner__c 
																where 
																	AsUser__c IN :allPlanUserIdSet
																and
																	AS_Plan_Year__c IN :allPlanYearStrSet
																and 
																	Id NOT IN :allPlanIdSet
																]) {
			existCPDPlanMap.put(cpd.AS_Plan_Year__c+String.valueOf(cpd.AsUser__c).toLowerCase().trim(), cpd.Id);
		}
		System.debug('existCPDPlanMap :' + existCPDPlanMap);
		for( AsCPDPlanner__c cpd : (List<AsCPDPlanner__c>) newObjects) {
			if(cpd.AsUser__c != null && String.isNotBlank(cpd.AS_Plan_Year__c)) {
				String tempKeyStr = cpd.AS_Plan_Year__c+String.valueOf(cpd.AsUser__c).toLowerCase().trim();
				
				if(existCPDPlanMap.containsKey(tempKeyStr)) {
					cpd.AddError('You have already created a CPD Plan for the selected Plan Year. Please remove your previously created Plan if you wish to start a CPD Plan for this year, or edit the existing Plan.');
				}
			}
		}
	}
    
   /*Author : John Hope
	*Description : create a new cpd planner review everytime a new cpd planner is created
	*Date Created : August 29, 2018
	*Last Modified By : 
	*Date Last Modified :
	*Related Meta Data :
	*Param :
		0. List<Object> - the old Object from trigger
    1. List<Object> - the new Object from trigger
    2. List<Object> - the new Map Object from trigger
	*Return : 
 	*/
	public static void createCPDPlannerReview(Object[] newObjects,Map<Id,Object> oldMap,Map<Id,Object> newMap) {
		// for creation of new cpd planner review starts here
		System.debug('test for create review');
		Set<Id> allUserIdSet = new Set<Id>();
		for(AsCPDPlanner__c cpd : (List<AsCPDPlanner__c>) newObjects) {
			allUserIdSet.add(cpd.AsUser__c);
		}
		
		Map<Id,User> allUserMap = new Map<Id,User>();
		if(allUserIdSet.size() > 0) {
			for(User use : [Select Id,Name from User where Id IN :allUserIdSet]) {
				allUserMap.put(use.Id,use);
			}
		}
		
		List<AsCPDPlannerReview__c> cpdPlannerRevList = new List<AsCPDPlannerReview__c>();
		for(AsCPDPlanner__c cpd : (List<AsCPDPlanner__c>) newObjects) {
			AsCPDPlannerReview__c singlecpdPlannerRev = new AsCPDPlannerReview__c();
			singlecpdPlannerRev.Name = allUserMap.get(cpd.AsUser__c).Name + ' - Review ' + cpd.AS_Plan_Year__c;
			singlecpdPlannerRev.AsUser__c = cpd.AsUser__c;
			singlecpdPlannerRev.AsCpdPlan__c = cpd.Id;
			cpdPlannerRevList.add(singlecpdPlannerRev);
		}
		
		System.debug('cpdPlannerRevList : ' + cpdPlannerRevList);
		if(cpdPlannerRevList.size() > 0){
			insert cpdPlannerRevList;
		}
		
			// for creation of new cpd planner review ends here
	}
    
    /*Author : John Hope
    *Description : checker if trigger is running
    *Date Created : May 9, 2018
    *Last Modified By : 
    *Date Last Modified : May 9, 2018
    *Related Meta Data :
    *Param : 
    *Return : boolean
    */
    public boolean IsTriggerContext{
        get{ return isExecutingBool;}
    }
    
    
    public static boolean run = true;
    public static boolean runOnce(){
        if(run){
         run=false;
         return true;
        }else{
            return run;
        }
    }
    
    
}