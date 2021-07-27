/*Author : John Hope
*Description : extension class to get cpd planner learning summary 
*Date Created : May 9, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : AsCPDPlanner__c
*/
public class AsCPDPlannerExt {
	public final AsCPDPlanner__c finalPlanner;
    public Decimal group1Db {get;set;}
    public Decimal group2Db {get;set;}
    public Decimal group3Db {get;set;}
    public Decimal totalGroupdb {get;set;}

	public AsCPDPlannerExt(ApexPages.StandardController stdController) {
		this.finalPlanner = ( AsCPDPlanner__c )stdController.getRecord();
		System.debug('finalOrder : ' + finalPlanner );
		Id finalId = finalPlanner.Id;

		initLeanrinComplete(finalId);
		initLeanrinInProg(finalId);
		initLeanrinPlan(finalId);
	}

	public void initLeanrinComplete(Id IdFinal){

		totalGroupdb = 0.00;
		group1Db = 0.00;
		group2Db = 0.00;
		group3Db = 0.00;

 		for(AsCPD_Learning_Summary__c learnSum :  [Select 
															Id,
															Name,
															X2016_Competencies__c,
															CPD_Accreditation_Number__c,
															CPD_Category__c,
															CPD_Planner__c,
															Description__c,
															End_Date__c,
															Group_1_CPD__c,
															Group_2_CPD__c,
															Group_3_CPD__c,
															Learning_Assignment__c,
															Notes__c,
															Provider__c,
															Start_Date__c,
															Type__c,
                                                   			AS_Reflections__c,
                                                   			AS_Topics__c,
                                                   			AS_Type__c
															from 
																AsCPD_Learning_Summary__c 
																where 
																	CPD_Planner__c=:IdFinal 
																AND 
																	Status__c = 'Complete'
																AND 
																	AsSummary_Plan__c = true 
													]) {
			String name = learnSum.Name;
	        System.debug('output :'+ learnSum.X2016_Competencies__c);
	        String competency = (learnSum.X2016_Competencies__c!=null)?learnSum.X2016_Competencies__c.replaceAll(',',', '):learnSum.X2016_Competencies__c;
		    Date startDate = learnSum.Start_Date__c;
		    Date endDate = learnSum.End_Date__c;
		    String cpdType = learnSum.AS_Type__c;
		    String description = learnSum.AS_Topics__c;
		    String accreNum = learnSum.CPD_Accreditation_Number__c;
	                                                                                                    
		    String category = '';
		    Decimal credits = 0.00;
	 
		    if(learnSum.CPD_Category__c == 'Group 1') {
		    	category = 'GROUP1';
		    	credits = learnSum.Group_1_CPD__c;
		    	if( learnSum.Group_1_CPD__c != null ) {
		    		group1Db += learnSum.Group_1_CPD__c;
		    		totalGroupdb += learnSum.Group_1_CPD__c;
		    	}
		    } else if(learnSum.CPD_Category__c == 'Group 2') {
		    	category = 'GROUP2';
		    	credits = learnSum.Group_2_CPD__c;
		    	if( learnSum.Group_2_CPD__c != null ) {
		    		group2Db += learnSum.Group_2_CPD__c;
		    		totalGroupdb += learnSum.Group_2_CPD__c;
		    	}
		    } else if(learnSum.CPD_Category__c == 'Group 3') {
		    	category = 'GROUP3';
		    	credits = learnSum.Group_3_CPD__c;
		    	if( learnSum.Group_3_CPD__c != null ) {
		    		group3Db += learnSum.Group_3_CPD__c;
		    		totalGroupdb += learnSum.Group_3_CPD__c;
		    	}
		    }
		    String prov = learnSum.Provider__c;
		    String notes = learnSum.AS_Reflections__c;
		    
		    processLearningSum sum = new processLearningSum(name,competency,startDate,endDate,cpdType,description,accreNum,category,credits,prov,notes);
			allLearningSummaryCom.add(sum);
	    
		}

	}


	public void initLeanrinInProg(Id IdFinal){

			    

		
		for(AsCPD_Learning_Summary__c learnSum :  [Select 
															Id,
															Name,
															X2016_Competencies__c,
															CPD_Accreditation_Number__c,
															CPD_Category__c,
															CPD_Planner__c,
															Description__c,
															End_Date__c,
															Group_1_CPD__c,
															Group_2_CPD__c,
															Group_3_CPD__c,
															Learning_Assignment__c,
															Notes__c,
															Provider__c,
															Start_Date__c,
															Type__c,
                                                   			AS_Reflections__c,
                                                   			AS_Topics__c,
                                                   			AS_Type__c
															from 
																AsCPD_Learning_Summary__c 
															where 
																CPD_Planner__c=:IdFinal 
															AND 
																Status__c = 'In Progress'
															AND 
																AsSummary_Plan__c = true
													]) {
			String name = learnSum.Name;
	        System.debug('output :'+ learnSum.X2016_Competencies__c);
	        String competency = (learnSum.X2016_Competencies__c!=null)?learnSum.X2016_Competencies__c.replaceAll(',',', '):learnSum.X2016_Competencies__c;
		    Date startDate = learnSum.Start_Date__c;
		    Date endDate = learnSum.End_Date__c;
		    String cpdType = learnSum.AS_Type__c;
		    String description = learnSum.AS_Topics__c;
		    String accreNum = learnSum.CPD_Accreditation_Number__c;
	                                                                                                    
		    String category = '';
		    Decimal credits = 0.00;
		    if(learnSum.CPD_Category__c == 'Group 1') {
		    	category = 'GROUP1';
		    	credits = learnSum.Group_1_CPD__c;
		    } else if(learnSum.CPD_Category__c == 'Group 2') {
		    	category = 'GROUP2';
		    	credits = learnSum.Group_2_CPD__c;
		    } else if(learnSum.CPD_Category__c == 'Group 3') {
		    	category = 'GROUP3';
		    	credits = learnSum.Group_3_CPD__c;
		    }
		    String prov = learnSum.Provider__c;
		    String notes = learnSum.AS_Reflections__c;
		    
		    processLearningSum sum = new processLearningSum(name,competency,startDate,endDate,cpdType,description,accreNum,category,credits,prov,notes);
			allLearningSummaryInProg.add(sum);
	    
		}

	}

	public void initLeanrinPlan(Id IdFinal){

 
		for(AsCPD_Learning_Summary__c learnSum :  [Select 
															Id,
															Name,
															X2016_Competencies__c,
															CPD_Accreditation_Number__c,
															CPD_Category__c,
															CPD_Planner__c,
															Description__c,
															End_Date__c,
															Group_1_CPD__c,
															Group_2_CPD__c,
															Group_3_CPD__c,
															Learning_Assignment__c,
															Notes__c,
															Provider__c,
															Start_Date__c,
															Type__c,
                                                   			AS_Reflections__c,
                                                   			AS_Topics__c,
                                                   			AS_Type__c
															from 
																AsCPD_Learning_Summary__c 
															where 
																CPD_Planner__c=:IdFinal 
															AND 
																(Status__c = 'Not Started' OR Status__c='Planned')
															AND 
																AsSummary_Plan__c = true
													]) {
			String name = learnSum.Name;
	        System.debug('output :'+ learnSum.X2016_Competencies__c);
	        String competency = (learnSum.X2016_Competencies__c!=null)?learnSum.X2016_Competencies__c.replaceAll(',',', '):learnSum.X2016_Competencies__c;
		    Date startDate = learnSum.Start_Date__c;
		    Date endDate = learnSum.End_Date__c;
		    String cpdType = learnSum.AS_Type__c;
		    String description = learnSum.AS_Topics__c;
		    String accreNum = learnSum.CPD_Accreditation_Number__c;
	                                                                                                    
		    String category = '';
		    Decimal credits = 0.00;
		    if(learnSum.CPD_Category__c == 'Group 1') {
		    	category = 'GROUP1';
		    	credits = learnSum.Group_1_CPD__c;
		    } else if(learnSum.CPD_Category__c == 'Group 2') {
		    	category = 'GROUP2';
		    	credits = learnSum.Group_2_CPD__c;
		    } else if(learnSum.CPD_Category__c == 'Group 3') {
		    	category = 'GROUP3';
		    	credits = learnSum.Group_3_CPD__c;
		    }
		    String prov = learnSum.Provider__c;
		    String notes = learnSum.AS_Reflections__c;
		    
		    processLearningSum sum = new processLearningSum(name,competency,startDate,endDate,cpdType,description,accreNum,category,credits,prov,notes);
			allLearningSummaryPlan.add(sum);
	    
		}

	}
    
		
	public List<processLearningSum> allLearningSummaryCom {
      get {
          if(allLearningSummaryCom == null) {
              allLearningSummaryCom = new List<processLearningSum>();
          }
          return allLearningSummaryCom;
      }
      set;
  	}

  	public List<processLearningSum> allLearningSummaryInProg {
      get {
          if(allLearningSummaryInProg == null) {
              allLearningSummaryInProg = new List<processLearningSum>();
          }
          return allLearningSummaryInProg;
      }
      set;
  	}
  	public List<processLearningSum> allLearningSummaryPlan {
      get {
          if(allLearningSummaryPlan == null) {
              allLearningSummaryPlan = new List<processLearningSum>();
          }
          return allLearningSummaryPlan;
      }
      set;
  	}
  	
  	
  	/*
    * Author : WEW
    * Description: wrapper class for order line item
    * Parameter : None
    * Return : None
    */
    public class processLearningSum {  
    	public String name {get; set;}
    	public String competency { get; set;}
    	public Date startDate { get; set; }
    	public Date endDate { get; set; }
    	public String cpdType { get; set; }
    	public String description { get; set; }
    	public String accreNum { get; set; }
    	public String category { get; set; }
    	public Decimal credits { get; set; }
    	public String prov { get; set; }
    	public String notes { get; set; }
    	
    	
    	public processLearningSum(String na,String com, Date sta,Date endD, String cpdty,String des, String accre, String cat, Decimal cred, String pro, String note  ) {
	        name = na;
	        competency = com;
	        startDate = sta;
	        endDate = endD;
	        cpdType = cpdty;
	        description = ( String.isNotBlank(des) && des.contains(';') ) ? des.replace(';', '\n') : des;
	        accreNum = accre;
	        category = cat;
	        credits = cred;
	        prov = pro;
	        notes = note;
	    }
    	
    }
     
}