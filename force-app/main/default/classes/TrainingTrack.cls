public with sharing class TrainingTrack {
@AuraEnabled public Training_Track__c trainingTrack{get;set;}
    //@AuraEnabled public List<TrainingPlanSection> sections{get;set;}
    //@AuraEnabled public Integer totalMins{get;set;}
    //@AuraEnabled public String totalDuration{get;set;}
    //@AuraEnabled public transient List<Training_Plan_Achievement__c> achievements{get;set;}
    @AuraEnabled public transient Achievement__c mainAchievement{get;set;}
    @AuraEnabled public transient List<Training_Track_FAQ__c > tpFAQs{get;set;}
    @AuraEnabled public transient List<Education_FAQ__c> listFAQs{get;set;}
    @AuraEnabled public transient Education_FAQ__c mainFAQ{get;set;}
    @AuraEnabled public Training_Plan__c prerequsite1Plan{get;set;}
    @AuraEnabled public Training_Plan__c prerequsite2Plan{get;set;}
    @AuraEnabled public Training_Plan__c prerequsite3Plan{get;set;}
    @AuraEnabled public Training_Plan__c related1Plan{get;set;}
    @AuraEnabled public Training_Plan__c related2Plan{get;set;}
    @AuraEnabled public Training_Plan__c related3Plan{get;set;}
	@AuraEnabled public Training_Plan__c related4Plan{get;set;}
	@AuraEnabled public transient Achievement__c AchievementPR1{get;set;}
    @AuraEnabled public transient Achievement__c AchievementPR2{get;set;}
    @AuraEnabled public transient Achievement__c AchievementPR3{get;set;}
    @AuraEnabled public transient Achievement__c AchievementR1{get;set;}
    @AuraEnabled public transient Achievement__c AchievementR2{get;set;}
    @AuraEnabled public transient Achievement__c AchievementR3{get;set;}
    @AuraEnabled public transient Achievement__c AchievementR4{get;set;}
    public TrainingTrack(){
        trainingTrack = null;
        /*sections = new List<TrainingPlanSection>();
        achievements =new List<Training_Plan_Achievement__c>();
        
        totalMins = 0;
        totalDuration = '';*/
        mainAchievement = null;
        tpFAQs =new List<Training_Track_FAQ__c>();
        listFAQs=new List<Education_FAQ__c>();
        prerequsite1Plan=null;
        prerequsite2Plan=null;
        prerequsite3Plan=null;
        related1Plan=null;
        related2Plan=null;
        related3Plan=null;
        related4Plan=null;
        AchievementPR1=null;
        AchievementPR2=null;
        AchievementPR3=null;
        AchievementR1=null;
        AchievementR2=null;
        AchievementR3=null;
        AchievementR4=null;
    }
}