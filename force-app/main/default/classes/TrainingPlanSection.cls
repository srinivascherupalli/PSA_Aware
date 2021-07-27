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
public with sharing class TrainingPlanSection{

    @AuraEnabled public Training_Plan_Section__c trainingPlanSection{get;set;}
    @AuraEnabled public List<TrainingPlanSectionItem> items{get;set;}

    @AuraEnabled public transient List<Training_Plan_Achievement__c> achievements{get;set;}
    @AuraEnabled public transient Achievement__c mainAchievement{get;set;}

    @AuraEnabled public transient Training_Plan_Section_Assignment__c sectionAssignment{get;set;}

    @AuraEnabled public Id previousSectionId{get;set;}
    @AuraEnabled public Boolean previousSectionOptional{get;set;}
    
	@AuraEnabled public Boolean previousSectionInProgress{get;set;}

    @AuraEnabled public Integer totalMins{get;set;}
    @AuraEnabled public String totalDuration{get;set;}
    @AuraEnabled public Double totalProgress{get;set;}
    @AuraEnabled public Integer totalRequiredItems{get;set;}
    @AuraEnabled public Integer totalOptionalItems{get;set;}

    public TrainingPlanSection(){
       trainingPlanSection = null;
        items = new List<TrainingPlanSectionItem>();

        achievements = new List<Training_Plan_Achievement__c>();
        mainAchievement = null;

        totalMins = 0;
        totalProgress = 0;
        totalDuration = '';

        sectionAssignment = null;
        previousSectionId = null;
        previousSectionOptional = false;
        
		previousSectionInProgress=false;
        totalRequiredItems = 0;
        totalOptionalItems = 0;
    }

}