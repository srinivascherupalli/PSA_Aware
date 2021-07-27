trigger DL_CampaignMember_Trigger on CampaignMember (after insert, after delete) {
    if(!System.isFuture() && !System.isBatch()){
        if(Trigger.isAfter){
            List<Campaign> autoFlowParentCampaigns = [SELECT Id,Name,ParentId,Flow_Members_Down_Heirarchy__c FROM Campaign WHERE Flow_Members_Down_Heirarchy__c = true AND ParentId = null];
            List<Campaign> autoFlowChildCampaigns = [SELECT Id,Name,ParentId,Parent.Flow_Members_Down_Heirarchy__c FROM Campaign WHERE Parent.Flow_Members_Down_Heirarchy__c = true AND ParentId != null];
            Map<Id, Campaign>autoFlowParentCampaignsMap = new Map<Id,Campaign>(autoFlowParentCampaigns);
            Map<Id, Campaign>autoFlowChildCampaignsMap = new Map<Id,Campaign>(autoFlowChildCampaigns);

            if(Trigger.isInsert){
                System.debug('DL_CampaignMember_Trigger: Trigger.isInsert');
                List<CampaignMember> flowCampaignMembers = new List<CampaignMember>();

                for(CampaignMember member : Trigger.new){
                    if(autoFlowParentCampaignsMap.containsKey(member.CampaignId)){ 
                        flowCampaignMembers.add(member);
                    }
                    /*
                    else if(autoFlowChildCampaignsMap.containsKey(member.CampaignId)){ 
                       flowCampaignMembers.add(member);
                    }*/
                }

                if(flowCampaignMembers.size() > 0){
                    DL_CampaignMember_TriggerHandler.FlowMembersHandler(flowCampaignMembers); 
                }
            }


            if(Trigger.isDelete){
                System.debug('DL_CampaignMember_Trigger: Trigger.isDelete');
                List<CampaignMember> flowCampaignMembersToDelete = new List<CampaignMember>();

                for(CampaignMember member : Trigger.old){
                    if(autoFlowParentCampaignsMap.containsKey(member.CampaignId) || autoFlowChildCampaignsMap.containsKey(member.CampaignId)){
                        flowCampaignMembersToDelete.add(member);
                    }
                }

                if(flowCampaignMembersToDelete.size() > 0){
                    DL_CampaignMember_TriggerHandler.DeleteFlowCampaignMembers(flowCampaignMembersToDelete); 
                }
            }
        }
    }
}