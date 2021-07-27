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
public with sharing class TrainingPlan{

    @AuraEnabled public Training_Plan__c trainingPlan{get;set;}
    @AuraEnabled public List<TrainingPlanSection> sections{get;set;}
    @AuraEnabled public Integer totalMins{get;set;}
    @AuraEnabled public String totalDuration{get;set;}

    @AuraEnabled public transient List<Training_Plan_Achievement__c> achievements{get;set;}
    @AuraEnabled public transient Achievement__c mainAchievement{get;set;}
    @AuraEnabled public transient List<Training_Plan_FAQ__c> tpFAQs{get;set;}
    @AuraEnabled public transient List<Education_FAQ__c> listFAQs{get;set;}
    //@AuraEnabled public transient Education_FAQ__c mainFAQ{get;set;}
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
    
    public TrainingPlan(){
        trainingPlan = null;
        sections = new List<TrainingPlanSection>();
        achievements =new List<Training_Plan_Achievement__c>();
        mainAchievement = null;
        totalMins = 0;
        totalDuration = '';
        tpFAQs =new List<Training_Plan_FAQ__c>();
        listFAQs=new List<Education_FAQ__c>();
        mainAchievement = null;
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