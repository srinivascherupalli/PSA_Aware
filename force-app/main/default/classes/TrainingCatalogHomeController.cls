/*
Copyright (c) 2014, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
global with sharing class TrainingCatalogHomeController extends LMSBaseController{

    public List<Learning_Category__c> lcategories {get;private set;}
		public Integer countTrainPlanInt {get;set;}
    public TrainingCatalogHomeController(){
        init();
    }

    private void init(){
        lcategories = LMSService.getLearningCategories(null);
    }
    
    /*
	 	*Author : John Hope
	  *Description : method to get all picklist value from target audience field in training plan object
	  *Date Created :
	  *Last Modified By : 
	  *Date Last Modified :
	  *Param : 
	  *Return : 
	  */ 
    public Map<String,String> getfilterTargetAudience() {
		  Map<String,String> options = new Map<String,String>();
		        
	   	Schema.DescribeFieldResult fieldResult = Training_Plan__c.AsTargetAudience__c.getDescribe();
	   	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	   	for( Schema.PicklistEntry f : ple) {
  			options.put(f.getLabel(), f.getValue());
	   	}       
	   	return options;
		}
		
		/*
	 	*Author : John Hope
	  *Description : method to get all picklist value from Training Plan Type field in training plan object
	  *Date Created :
	  *Last Modified By : 
	  *Date Last Modified :
	  *Param : 
	  *Return : 
	  */ 
    public Map<String,String> getfilterTrainingPlanType() {
		  Map<String,String> options = new Map<String,String>();
		        
	   	Schema.DescribeFieldResult fieldResult = Training_Plan__c.AS_Training_Plan_Type__c.getDescribe();
	   	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	   	for( Schema.PicklistEntry f : ple) {
  			options.put(f.getLabel(), f.getValue());
	   	}       
	   	return options;
		}
		
		/*
	 	*Author : John Hope
	  *Description : method to get all picklist value from Category field in training plan object
	  *Date Created :
	  *Last Modified By : 
	  *Date Last Modified :
	  *Param : 
	  *Return : 
	  */ 
    public Map<String,String> getfilterCategory() {
		  Map<String,String> options = new Map<String,String>();
		        
	   	Schema.DescribeFieldResult fieldResult = Training_Plan__c.AsCategory__c.getDescribe();
	   	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	   	for( Schema.PicklistEntry f : ple) {
  			options.put(f.getLabel(), f.getValue());
	   	}       
	   	return options;
		}
		
		/*
	 	*Author : John Hope
	  *Description : method to get all picklist value from Category field in training plan object
	  *Date Created :
	  *Last Modified By : 
	  *Date Last Modified :
	  *Param : 
	  *Return : 
	  */ 
    public Map<String,String> getfilterMethod() {
		  Map<String,String> options = new Map<String,String>();
		        
	   	Schema.DescribeFieldResult fieldResult = Training_Plan__c.AS_Delivery_Method__c.getDescribe();
	   	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	   	for( Schema.PicklistEntry f : ple) {
  			options.put(f.getLabel(), f.getValue());
	   	}       
	   	return options;
		}
		
	  /*
	  *Author : John Hope
	  *Description : method to get all training plan from filter
	  *Date Created :
	  *Last Modified By : Jet R. Compayan  
	  *Date Last Modified :
	  *Param : 
	  *Return : 
	  */ 
	  @remoteAction
      public static List<courseCatalogWrapper> allFilterTrainingPlan(String[] param) {
		String filterString  = param[0];//json parameters 
		String sortedBy = param[1];
    	List<courseCatalogWrapper> allPlanAndTrackWrapper = new List<courseCatalogWrapper>();
    	List<Object> allPlanAndTrack = new List<Object>();
		JSONTrainingPlanFilter filterTrainingPlan = (JSONTrainingPlanFilter)JSON.deserialize(filterString,JSONTrainingPlanFilter.class);
	   	System.debug('filterTrainingPlan :' + filterTrainingPlan.TargetAudience);
	   	List<String> TargetAudience = filterTrainingPlan.TargetAudience;
	   	List<String> CourseType = filterTrainingPlan.CourseType;
	   	List<String> Category = filterTrainingPlan.Category;
	   	List<String> Delivery = filterTrainingPlan.Delivery;

		String sortbyTrainingPlan = '';
		String sortbyTrainingTrack  = '';

		//Updated by Jet 
		//ticket:PSAMOPT-15

		// this sorteby assigned selection from the front end. It indicates what sorting to append to the query 
	 	if( sortedBy == 'dpn' ){
			sortbyTrainingPlan = ' ORDER BY Date_Published__c DESC NULLS LAST ';
		} else if( sortedBy == 'dpo' ){
			sortbyTrainingPlan = ' ORDER BY Date_Published__c ASC NULLS LAST ';
		} else if( sortedBy == 'az' ){
			sortbyTrainingPlan = ' ORDER BY Name ASC NULLS LAST ';
		} else if( sortedBy == 'za' ){
			sortbyTrainingPlan = ' ORDER BY Name DESC NULLS LAST ';
		} else if( sortedBy == 'accExDateOtoN' ){
			sortbyTrainingPlan = 'ORDER BY AS_Accreditation_expiry_date__c ASC NULLS LAST';
		}

	   	
	   	// start training plan here
	   	List<Training_Plan__c> allFilterTrainingPlan = new List<Training_Plan__c>();
	   	String theQueryArticleString = '';
			if(filterTrainingPlan.TargetAudience.size() > 0 || filterTrainingPlan.Delivery.size() > 0 || filterTrainingPlan.CourseType.size() > 0 || filterTrainingPlan.Category.size() > 0) {
				
				theQueryArticleString += 'Select Id,Name,Type__c, PSA_Marketing_Text__c, Description__c, Total_Section_Items__c, (Select Id,Name,Achievement__r.Acquired_Image__c,Achievement__r.Work_Badge_Image_URL__c from Training_Plan_Achievements__r LIMIT 1) FROM Training_Plan__c  WHERE (Status__c=\'Active\' AND AS_Include_In_Catalog__c = true) AND ';
				theQueryArticleString +='(';
				if(filterTrainingPlan.TargetAudience.size() > 0) {
					theQueryArticleString += 'AsTargetAudience__c INCLUDES (' + AS_commonFunction.convertListStrToStr(TargetAudience) + ') AND ';
				}
				if(filterTrainingPlan.CourseType.size() > 0) {
					theQueryArticleString += 'AS_Training_Plan_Type__c IN :CourseType AND ';
				}
				if(filterTrainingPlan.Category.size() > 0) {
					theQueryArticleString += 'AsCategory__c INCLUDES (' + AS_commonFunction.convertListStrToStr(Category) + ') AND ';
				}
				if(filterTrainingPlan.Delivery.size() > 0) {
					theQueryArticleString += 'AS_Delivery_Method__c IN :Delivery AND ';
				}
				
				String finalQueryString = theQueryArticleString.trim().normalizeSpace();
      	Integer strLength = finalQueryString.length();	 
				allFilterTrainingPlan = database.query(finalQueryString.substring(0, strLength-4) + ') '+sortbyTrainingPlan);
				 
			} else {
				theQueryArticleString += 'Select Id,Name,Type__c, PSA_Marketing_Text__c, Description__c, Total_Section_Items__c, (Select Id,Name,Achievement__r.Acquired_Image__c,Achievement__r.Work_Badge_Image_URL__c from Training_Plan_Achievements__r LIMIT 1) FROM Training_Plan__c WHERE (Status__c=\'Active\' AND AS_Include_In_Catalog__c = true) '+sortbyTrainingPlan;
 
				allFilterTrainingPlan = database.query(theQueryArticleString);
			}  
			
			for(Training_Plan__c plan : allFilterTrainingPlan){
				courseCatalogWrapper wrap = new courseCatalogWrapper('PLAN',(Object) plan);
				allPlanAndTrackWrapper.add(wrap);
			}
			// end training plan here
			
			// start training track here
	   	String theQueryTrackString = '';
	   	List<Training_Track__c> allFilterTrainingTrack = new List<Training_Track__c>();
			if(filterTrainingPlan.TargetAudience.size() > 0 || filterTrainingPlan.Category.size() > 0) {
				
				theQueryTrackString += 'Select Id,Name,Background_Color__c,Background_Image_URL__c,Description__c,Text_Color__c,Status__c,New_Until__c,Achievement__c,Achievement__r.Acquired_Image__c,Achievement__r.Eligible_Image__c,Achievement__r.Work_Badge_Id__c,Achievement__r.Work_Badge_Image_URL__c FROM Training_Track__c  WHERE (Status__c=\'Active\') AND ';
				theQueryTrackString += '(';
				if(filterTrainingPlan.TargetAudience.size() > 0) {
					theQueryTrackString += 'AsTargetAudience__c INCLUDES (' + AS_commonFunction.convertListStrToStr(TargetAudience) + ') AND ';
				}
				if(filterTrainingPlan.Category.size() > 0) {
					theQueryTrackString += 'AsCategory__c INCLUDES (' + AS_commonFunction.convertListStrToStr(Category) + ') AND ';
				}
				
				String finalQueryString2 = theQueryTrackString.trim().normalizeSpace();
	      Integer strLength2 = finalQueryString2.length();
				allFilterTrainingTrack = database.query(finalQueryString2.substring(0, strLength2-4) + ') ');
			} else if(filterTrainingPlan.CourseType.size() == 0){
				theQueryTrackString += 'Select Id,Name,Background_Color__c,Background_Image_URL__c,Description__c,Text_Color__c,Status__c,New_Until__c,Achievement__c,Achievement__r.Acquired_Image__c,Achievement__r.Eligible_Image__c,Achievement__r.Work_Badge_Id__c,Achievement__r.Work_Badge_Image_URL__c, Total_Training_Tracks_Items__c FROM Training_Track__c WHERE (Status__c=\'Active\') ';
				allFilterTrainingTrack = database.query(theQueryTrackString);
			}  
			
			for(Training_Track__c track : allFilterTrainingTrack){
				courseCatalogWrapper wrap2 = new courseCatalogWrapper('TRACK',(Object) track);
				allPlanAndTrackWrapper.add(wrap2);
			}
			// end training track here
			
			return allPlanAndTrackWrapper;
			
		}
		
	/*
 	*Author : John Hope
  *Description : wrapper class to get all training plan filter.
  *Date Created :
  *Last Modified By : 
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
	public class JSONTrainingPlanFilter {
    public List<String> TargetAudience{set;get;}
    public List<String> CourseType{set;get;}
    public List<String> Category{set;get;}
    public List<String> Delivery{set;get;}
	}
		
	/*
	*Author : John Hope
	*Description : wrapper class to check if course catalog is track or training plan
	*Date Created :
	*Last Modified By : 
	*Date Last Modified :
	*Param : 
	*Return : 
	 */ 
	public class courseCatalogWrapper {
		public String course{set;get;}
		public Object training{set;get;}
		
		public courseCatalogWrapper(String cour, Object obj) {
	      this.course = cour;
	      this.training = obj;
	   }
	}
		

}