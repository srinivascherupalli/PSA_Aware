/**
 * Class for the CourrseCardwithFilter Componnet  
 * 
 * @author	Davanti:
 * @author	Surbhi Sharma(Davanti Isobar),
 * @since	05/08/2020 
 * @date	05/08/2020 - Surbhi Sharma(Davanti Isobar): created initial class structure
 * @see		CourrseCardwithFilter component 
 */
public class TrainingCourseViewController_Lightning {
	public static courseCatalogWrapper state;
	
    // Method to set values for courseCatalogWrapper wrapper and return wrapper
    @AuraEnabled
	public static courseCatalogWrapper allFilterTrainingPlanmethod(list<string> categoryFilter,List<string> deliveryFilter,List<string> TypeFilter,List<string>TargetFilter,string sortedBy) {
		state = new courseCatalogWrapper();
        
        list<string> optionTarget = new list<string>();
        list<string> optionType = new list<string>();
        list<string>optionCategory = new list<string>();
        list<string> optionCategorylist=new list<string>();
        list<string> optionsMthod = new list<string>();

		        
	   	Schema.DescribeFieldResult fieldResultTarget = Training_Plan__c.AsTargetAudience__c.getDescribe();
	   	List<Schema.PicklistEntry> ple = fieldResultTarget.getPicklistValues();
	   	for( Schema.PicklistEntry f : ple) {
  			optionTarget.add(f.getValue());
	   	}   
        state.filterTargetAudience=optionTarget;
        
        Schema.DescribeFieldResult fieldResultType = Training_Plan__c.AS_Training_Plan_Type__c.getDescribe();
	   	List<Schema.PicklistEntry> pleType = fieldResultType.getPicklistValues();
	   	for( Schema.PicklistEntry f : pleType) {
            optionType.add(f.getValue());
	   	}  
        state.filterType=optionType;
        
        Schema.DescribeFieldResult fieldResultCategory = Training_Plan__c.AsCategory__c.getDescribe();
	   	List<Schema.PicklistEntry> pleCategory = fieldResultCategory.getPicklistValues();
	   	for( Schema.PicklistEntry f : pleCategory) {
  			optionCategorylist.add(f.getValue());
	   	}       
        state.categorylist=optionCategorylist;
        Schema.DescribeFieldResult fieldResultDelivery = Training_Plan__c.AS_Delivery_Method__c.getDescribe();
	   	List<Schema.PicklistEntry> pleDelivery = fieldResultDelivery.getPicklistValues();
	   	for( Schema.PicklistEntry f : pleDelivery) {
  			optionsMthod.add(f.getValue());
	   	}     
        state.filterMethod=optionsMthod;
        init(categoryFilter,deliveryFilter,TypeFilter,TargetFilter,sortedBy);
        return state;
    }	
    Public  static void init(list<string> categoryFilter,List<string> deliveryFilter,List<string> TypeFilter,List<string>TargetFilter,string sortedBy){
        String theQueryArticleString = '';
        String theQueryTrackString = '';
       	List<Training_Plan__c> allFilterTrainingPlan = new List<Training_Plan__c>();
		List<Training_Track__c> allFilterTrainingTrack = new List<Training_Track__c>();
		String sortbyTrainingPlan = '';
		String sortbyTrainingTrack= '';
		if( sortedBy == 'dpn' ){
			sortbyTrainingPlan = ' ORDER BY Date_Published__c DESC NULLS LAST ';
            sortbyTrainingTrack = ' ORDER BY PSA_Date_Published__c DESC NULLS LAST ';
		} else if( sortedBy == 'dpo' ){
			sortbyTrainingPlan = ' ORDER BY Date_Published__c ASC NULLS LAST ';
            sortbyTrainingTrack = ' ORDER BY PSA_Date_Published__c ASC NULLS LAST ';
		} else if( sortedBy == 'az' ){
			sortbyTrainingPlan = ' ORDER BY Name ASC NULLS LAST ';
            sortbyTrainingTrack = ' ORDER BY Name ASC NULLS LAST ';
		} else if( sortedBy == 'za' ){
			sortbyTrainingPlan = ' ORDER BY Name DESC NULLS LAST ';
            sortbyTrainingTrack= ' ORDER BY Name DESC NULLS LAST ';
		} else if( sortedBy == 'accExDateOtoN' ){
			sortbyTrainingPlan = 'ORDER BY AS_Accreditation_expiry_date__c ASC NULLS LAST';
            sortbyTrainingTrack = 'ORDER BY PSA_Accreditation_Expiry_Date__c ASC NULLS LAST';
		}
        
        if(categoryFilter.size()>0||deliveryFilter.size()>0||TypeFilter.size()>0||TargetFilter.size()>0){
          theQueryArticleString += 'Select Id,Name,Type__c,Group__c ,Start_Date__c,Date_Published__c,AS_Accreditation_expiry_date__c,PSA_TP_Tile_Image__c ,Qualification_Card__c,AS_Training_Plan_Type__c, PSA_Marketing_Text__c,Has_Tile_Image__c  ,AS_Delivery_Method__c, Description__c,AsTargetAudience__c,Tile_image__c,Duration_editorial__c, Total_Section_Items__c,AS_Group_1_CPD__c,AS_Group_2_CPD__c,AS_Group_3_CPD__c,Card_Description__c,AsCategory__c,Achievement__c,Achievement__r.Eligible_Image__c FROM Training_Plan__c WHERE (Status__c=\'Active\' AND AS_Include_In_Catalog__c = true AND Start_Date__c <= TODAY AND End_Date__c >TODAY )  ';
			
            if(categoryFilter.size()>0){
                system.debug('under with filter string query'+allFilterTrainingPlan);
                    theQueryArticleString += ' AND AsCategory__c INCLUDES (' + AS_commonFunction.convertListStrToStr(categoryFilter) + ') ';
                    
                system.debug('under with cate filter string query'+theQueryArticleString);
            }
            if(deliveryFilter.size()>0){
				theQueryArticleString += ' AND AS_Delivery_Method__c IN :deliveryFilter ';
                system.debug('under with delivery  filter string query'+theQueryArticleString);
            }
            if(TypeFilter.size()>0){
				theQueryArticleString += ' AND AS_Training_Plan_Type__c IN :TypeFilter ';
                system.debug('under with type filter string query'+theQueryArticleString);
            }
            if(TargetFilter.size()>0){
                theQueryArticleString += ' AND AsTargetAudience__c INCLUDES (' + AS_commonFunction.convertListStrToStr(TargetFilter) + ') ';
            	system.debug('under with target filter string query'+theQueryArticleString);
            }
				system.debug('query string complete '+theQueryArticleString);
            	allFilterTrainingPlan = database.query(theQueryArticleString +sortbyTrainingPlan);
                state.trainingPlanList=allFilterTrainingPlan;
        }
        else{
          theQueryArticleString += 'Select Id,Name,Type__c,Group__c ,Start_Date__c,AS_Accreditation_expiry_date__c,Date_Published__c,PSA_TP_Tile_Image__c ,Qualification_Card__c,AS_Training_Plan_Type__c, PSA_Marketing_Text__c,Has_Tile_Image__c  ,AS_Delivery_Method__c, Description__c,AsTargetAudience__c,Tile_image__c,Duration_editorial__c, Total_Section_Items__c,AS_Group_1_CPD__c,AS_Group_2_CPD__c,AS_Group_3_CPD__c,Card_Description__c,AsCategory__c,Achievement__c,Achievement__r.Eligible_Image__c FROM Training_Plan__c WHERE (Status__c=\'Active\' AND AS_Include_In_Catalog__c = true AND Start_Date__c <= TODAY AND End_Date__c >TODAY )' +sortbyTrainingPlan;
            allFilterTrainingPlan = database.query(theQueryArticleString);
        	state.trainingPlanList=allFilterTrainingPlan;
        	system.debug('under null filter string query'+allFilterTrainingPlan);
        }
        if(categoryFilter.size()>0||TargetFilter.size()>0||TypeFilter.size()>0||deliveryFilter.size()>0) {
				theQueryTrackString += 'Select Id,Name,PSA_Date_Published__c,PSA_Group__c ,PSA_Start_Date__c,Qualification_Card__c,Background_Color__c,PSA_TT_Tile_Image__c ,Background_Image_URL__c,PSA_Marketing_Text__c,PSA_Card_Description__c,Description__c,PSA_Accreditation_Expiry_Date__c,Text_Color__c,PSA_Duration_editorial__c,PSA_Delivery_Method__c,Status__c,New_Until__c,Achievement__c,Achievement__r.Acquired_Image__c,Achievement__r.Eligible_Image__c,Achievement__r.Work_Badge_Id__c,Achievement__r.Work_Badge_Image_URL__c, Total_Training_Tracks_Items__c FROM Training_Track__c WHERE (Status__c=\'Active\' AND PSA_Include_in_Catalogue__c = true  AND PSA_Start_Date__c <= TODAY AND PSA_Accreditation_Expiry_Date__c  >TODAY) ';
				if(TargetFilter.size() > 0) {
					theQueryTrackString += 'AND AsTargetAudience__c INCLUDES (' + AS_commonFunction.convertListStrToStr(TargetFilter) + ')  ';
				}
				if(categoryFilter.size() > 0) {
					theQueryTrackString += 'AND AsCategory__c INCLUDES (' + AS_commonFunction.convertListStrToStr(categoryFilter) + ')  ';
				}
                if(TypeFilter.size()>0){
					theQueryTrackString += 'AND PSA_Education_Type__c IN :TypeFilter';
            	}
                if(deliveryFilter.size()>0){
                    theQueryTrackString += ' AND PSA_Delivery_Method__c IN :deliveryFilter ';
                }
				allFilterTrainingTrack = database.query(theQueryTrackString +sortbyTrainingTrack);
                state.trainingTrackList=allFilterTrainingTrack;
			} 
        else {
				theQueryTrackString += 'Select Id,PSA_Date_Published__c,PSA_Accreditation_Expiry_Date__c,Name,PSA_Group__c ,Qualification_Card__c,Background_Color__c,PSA_Start_Date__c,PSA_TT_Tile_Image__c ,Background_Image_URL__c,PSA_Marketing_Text__c,PSA_Card_Description__c,Description__c,Text_Color__c,PSA_Duration_editorial__c,PSA_Delivery_Method__c,Status__c,New_Until__c,Achievement__c,Achievement__r.Acquired_Image__c,Achievement__r.Eligible_Image__c,Achievement__r.Work_Badge_Id__c,Achievement__r.Work_Badge_Image_URL__c, Total_Training_Tracks_Items__c FROM Training_Track__c WHERE (Status__c=\'Active\' AND PSA_Include_in_Catalogue__c = true  AND PSA_Start_Date__c <= TODAY AND PSA_Accreditation_Expiry_Date__c  >TODAY)'+sortbyTrainingTrack;
				allFilterTrainingTrack = database.query(theQueryTrackString);
                state.trainingTrackList=allFilterTrainingTrack;
			}
    }
	
	public class courseCatalogWrapper {
        @auraEnabled
		public List<Training_Plan__c> trainingPlanList {set;get;}
		@auraEnabled
		public List<Training_Track__c> trainingTrackList {set;get;}
        @auraEnabled
		public list<string> filterTargetAudience {set;get;}
        @auraEnabled
		public list<string> filterType {set;get;}
		
		@auraEnabled
        public list<string> categorylist {set;get;}
		@auraEnabled
		public list<string> filterMethod {set;get;}
	}
}