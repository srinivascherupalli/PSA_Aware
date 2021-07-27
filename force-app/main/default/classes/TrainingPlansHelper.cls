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
public with sharing class TrainingPlansHelper {

    private static final String ALL_USERS_GROUP = 'AllInternalUsers';

    public static void processAfterInsert(Map<Id,Training_Plan__c> newPlansMap, Object[] newPlans){
        List<Training_Plan__c> filteredPlans = new List<Training_Plan__c>();
        for(Training_Plan__c tp : newPlansMap.values()){
            if(tp.Enable_Self_Registration__c){
                filteredPlans.add(tp);
            }
        }
        updateSharing(filteredPlans);
        
        populateCampaignTrainingPlan(newPlans, new Map<Id,Object>(),newPlansMap,'INSERT');
        
        
    }

    public static void processAfterUpdate(Map<Id,Training_Plan__c> oldPlansMap,Map<Id, Training_Plan__c> newPlansMap, Object[] newPlans){
        List<Training_Plan__c> filteredPlans = new List<Training_Plan__c>();
        for(Training_Plan__c tp : newPlansMap.values()){
            Training_Plan__c oldTP = oldPlansMap.get(tp.Id);
            if(oldTP.Enable_Self_Registration__c != tp.Enable_Self_Registration__c){
                filteredPlans.add(tp);
            }
        }
        updateSharing(filteredPlans);
        
        populateCampaignTrainingPlan(newPlans, oldPlansMap, newPlansMap,'UPDATE');
    }

    private static void updateSharing(List<Training_Plan__c> tplans){

        if(tplans != null && tplans.size()>0){
            Set<Id> publicSharingAdditions = new Set<Id>();
            Set<Id> publicSharingDeletions = new Set<Id>();
            for(Training_Plan__c tp : tplans){
                if(tp.Enable_Self_Registration__c){
                    publicSharingAdditions.add(tp.Id);
                }else{
                    publicSharingDeletions.add(tp.Id);
                }
            }

            List<Group> groups = [SELECT Id FROM Group WHERE DeveloperName = :ALL_USERS_GROUP];

            if(groups.size()>0){

                TrainingPlansHelper.WithoutSharingOps wosHelper = new TrainingPlansHelper.WithoutSharingOps();

                Group allInternalGroup = groups.get(0);
                //Create sharing for additions
                if(publicSharingAdditions.size()>0){
                    List<Training_Plan__Share> newShares = new List<Training_Plan__Share>();
                    for(Id tPlanId : publicSharingAdditions){
                        Training_Plan__Share tPlanShare = new Training_Plan__Share();
                        tPlanShare.UserOrGroupId = allInternalGroup.Id;
                        tPlanShare.ParentId = tPlanId;
                        tPlanShare.AccessLevel = 'read';
                        tPlanShare.RowCause = Schema.Training_Plan__Share.RowCause.LMS_Sharing__c;
                        newShares.add(tPlanShare);
                    }
                    wosHelper.insertTPlanSharesWOS(newShares);
                }

                //Delete existing shares for deletions
                if(publicSharingDeletions.size()>0){
                    //No need to query without sharing here as it's only executed by admins
                    List<Training_Plan__Share> existingShares = [SELECT Id
                                                                        FROM Training_Plan__Share
                                                                        WHERE ParentId in :publicSharingDeletions
                                                                        AND UserOrGroupId = :allInternalGroup.id];

                    if(existingShares.size()>0){
                        wosHelper.deleteTPlanSharesWOS(existingShares);
                    }

                }
            }

        }

    }

    private without sharing class WithoutSharingOps{
        //We need to insert custom apex shares in the without sharing context to avoid granting MAD permissions for LMS Admins
        public void insertTPlanSharesWOS(List<Training_Plan__Share> newShares){
            insert newShares;
        }
        //We need to delete custom apex shares in the without sharing context to avoid granting MAD permissions for LMS Admins
        public void deleteTPlanSharesWOS(List<Training_Plan__Share> existingShares){
            delete existingShares;
        }
    }
    
    
   /*
    *Description: PSA-192.
    *
    *	REVISION 09/08/18
    *	For Training Plan where Campaign =/= null
	*		Update Campaign.TrainingPlan__c = TrainingPlan.Id
	*		(Campaign.Learningc will remain BLANK)
    *Date Created: August 9, 2018
    */
    public static boolean runFillCampaignTrainingPlan = true;
    
    public static boolean runOnceFillCampaignTrainingPlan(){/*Anti-recursion*/
	    if(runFillCampaignTrainingPlan){
	     	runFillCampaignTrainingPlan=false;
	     	return true;
	    }else{
	        return runFillCampaignTrainingPlan;
	    }
	}
    
    
    public static void populateCampaignTrainingPlan(Object[] newObjects, Map<Id,Object> oldMap, Map<Id,Object> newMapObjects, String action){
    	if(runOnceFillCampaignTrainingPlan()){
    		
	    	List<Campaign> allTrainingPlanCampaign = new List<Campaign>();
    		for(Training_Plan__c tp : (List<Training_Plan__c>) newObjects){
				
    			
    			if(tp.AS_Event__c <> NULL){
					Campaign indiCampaign = new Campaign();
					indiCampaign.Id = tp.AS_Event__c;
					indiCampaign.Training_Plan__c = tp.Id;
					allTrainingPlanCampaign.add(indiCampaign);
    			}
    		}
    		if(allTrainingPlanCampaign.size()>0){
    			update allTrainingPlanCampaign;
    			system.debug('All Training Campaign: '+ allTrainingPlanCampaign);
    			TrainingPlansHelper.runFillCampaignTrainingPlan = false;
    		}else{
    			TrainingPlansHelper.runFillCampaignTrainingPlan = true;
    		}
    		
    	}
    }/*PSA-192*/
    

}