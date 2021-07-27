public with sharing class DL_CampaignMember_TriggerHandler {

    public static void DeleteFlowCampaignMembers(List<CampaignMember> cmpaignMembers){
        System.debug('DeleteFlowCampaignMembers');
        List<Id> leadOrContactIds = new List<Id>();

        for(CampaignMember member : cmpaignMembers){
            leadOrContactIds.add(member.LeadOrContactId);
        }

        List<CampaignMember> membersToDelete = [SELECT Id,Name,LeadOrContactId,Campaign.Parent.Flow_Members_Down_Heirarchy__c, Campaign.Flow_Members_Down_Heirarchy__c 
                                                FROM CampaignMember 
                                                WHERE (Campaign.Flow_Members_Down_Heirarchy__c = true OR Campaign.Parent.Flow_Members_Down_Heirarchy__c = true)
                                                AND LeadOrContactId IN :leadOrContactIds];

        System.debug(membersToDelete);
    }


    public static void FlowMembersHandler(Id parentCampaignId){
        System.debug('FlowMembersHandler: '+parentCampaignId);
        Campaign parentCampaign = [SELECT Id,Name,NumberOfContacts,NumberOfLeads FROM Campaign WHERE Id = :parentCampaignId];
        List<Campaign> childCampaigns = [SELECT Id,Name,ParentId,NumberOfContacts,NumberOfLeads FROM Campaign WHERE ParentId = :parentCampaignId];

        for(Campaign childCampaign : childCampaigns){
            if((childCampaign.NumberOfContacts != parentCampaign.NumberOfContacts) || (childCampaign.NumberOfLeads != parentCampaign.NumberOfLeads)){
                FlowMembers(childCampaign.Id);
            }
        }
    }



    @future
    public static void FlowMembers(Id childCampaignId){
        System.debug('FlowMembers: '+childCampaignId);
        Campaign childCampaign = [SELECT Id,Name,ParentId FROM Campaign WHERE Id = :childCampaignId];
        List<CampaignMember> newMembers = new List<CampaignMember>();
        List<CampaignMember> parentMembers = [SELECT Id,Name,ContactId,LeadId,CampaignId FROM CampaignMember WHERE CampaignId = :childCampaign.ParentId];

        List<CampaignMember> currentMembers = [SELECT Id,Name,ContactId,LeadId,CampaignId FROM CampaignMember WHERE CampaignId = :childCampaign.Id];
        List<Id> currentMemberContactOrLeadIds = new List<Id>();

        for(CampaignMember member : currentMembers){
            currentMemberContactOrLeadIds.add(member.ContactId != null ? member.ContactId : member.LeadId);
        }

        System.debug(currentMemberContactOrLeadIds);

        for(CampaignMember parentMember :  parentMembers){
            if(!currentMemberContactOrLeadIds.contains(parentMember.ContactId) && !currentMemberContactOrLeadIds.contains(parentMember.LeadId)){
                CampaignMember newMember = parentMember.clone(false,true);
                newMember.CampaignId = childCampaignId;
                newMember.Status = 'Registered';
                newMembers.add(newMember);
            }
        }

        try{
            insert newMembers;
        }

        catch(Exception e){
            System.debug(e.getMessage());
        }
    }



    public static void BackToBackSessionHandler(Id primaryCmpaignId, Id secondaryCmpaignId){
        System.debug('BackToBackSessionHandler');
        List<CampaignMember> primaryCmpaignMembers = [SELECT Id,Name,CampaignId,LeadOrContactId,Status FROM CampaignMember WHERE CampaignId = :primaryCmpaignId AND Status IN ('Attending','Checked In') ];
        List<CampaignMember> secondaryCmpaignMembers = [SELECT Id,Name,CampaignId,LeadOrContactId,Status FROM CampaignMember WHERE CampaignId = :secondaryCmpaignId];
        List<Id> primaryCmpaignMemberIds = new List<Id>();
        List<Id> secondaryCmpaignMemberIds = new List<Id>();
        

        for (CampaignMember primaryCmpaignMember : primaryCmpaignMembers){
            primaryCmpaignMemberIds.add(primaryCmpaignMember.LeadOrContactId);
        }
        
        for (CampaignMember secondaryMember : secondaryCmpaignMembers){
            if(primaryCmpaignMemberIds.contains(secondaryMember.LeadOrContactId)){
                secondaryCmpaignMemberIds.add(secondaryMember.Id);
            }
        }


        if(secondaryCmpaignMemberIds.size() > 0){
            Integer loopTimes = (Math.floor(secondaryCmpaignMemberIds.size() / 50)).intValue(); 
            Integer leftOver = Math.round(Math.mod(secondaryCmpaignMemberIds.size(),50));
            list<Id> secondaryCmpaignMemberIds_Chunk = new List<id>();

            if(secondaryCmpaignMemberIds.size() >= 50){
                System.debug('secondaryCmpaignMemberIds.Size:'+secondaryCmpaignMemberIds.size());
                System.debug('loopTimes:'+loopTimes);
                System.debug('leftOver:'+leftOver);
    
                for(Integer i=0; i < loopTimes; i++){

    
                    for(Integer j=0; j < 50; j++){
                        secondaryCmpaignMemberIds_Chunk.add(secondaryCmpaignMemberIds.remove(0));
                    }
    
                    try{
                        System.debug('TotalChunkSize: ' + secondaryCmpaignMemberIds_Chunk.size());
                        BackToBackSessionUpdateStatus(secondaryCmpaignMemberIds_Chunk);
                    }
    
                    catch(Exception e){
                        System.debug(e.getMessage());
                    }
                    secondaryCmpaignMemberIds_Chunk.clear();
                }
    
                if(leftOver > 0){
                    for(Integer i=0; i < leftOver; i++){
                        secondaryCmpaignMemberIds_Chunk.add(secondaryCmpaignMemberIds.remove(0));
                    }
    
                    try{
                        System.debug('TotalChunkSize: ' + secondaryCmpaignMemberIds_Chunk.size());
                        BackToBackSessionUpdateStatus(secondaryCmpaignMemberIds_Chunk);
                    }
    
                    catch(Exception e){
                        System.debug(e.getMessage());
                    }
                }
            }
    
            else{
                try{
                    BackToBackSessionUpdateStatus(secondaryCmpaignMemberIds);
                }
    
                catch(Exception e){
                    System.debug(e.getMessage());
                }
            }
        }
    }


    @Future
    public static void BackToBackSessionUpdateStatus(List<Id> attendeeCampaignMemberIds){
        System.debug('BackToBackSessionUpdateStatus');
        List<CampaignMember> attendeeCmpaignMembers= [SELECT ID,Name,CampaignId FROM CampaignMember WHERE Id IN :attendeeCampaignMemberIds];

        for(CampaignMember attendeeCmpaignMember : attendeeCmpaignMembers){
            attendeeCmpaignMember.Status = 'Attending';
        }

        update attendeeCmpaignMembers;
    }


    public static void CheckInMembersHandler(Id cmpaignId){
        System.debug('CheckInMembersHandler');

        Campaign cmpaign = [SELECT Id,Name,EndDate,AS_End_Time__c FROM Campaign WHERE Id = :cmpaignId];
        List<CampaignMember> attendingMembers = [SELECT Id,Name,CampaignId,LeadOrContactId,Status FROM CampaignMember WHERE CampaignId = :cmpaign.Id AND Status = 'Attending'];
        List<Id> attendingMemberIds = new List<Id>();

        for(CampaignMember attendingMember : attendingMembers){
            attendingMemberIds.add(attendingMember.Id);
        }


        if(attendingMemberIds.size() > 0){
            Integer loopTimes = (Math.floor(attendingMemberIds.size() / 50)).intValue(); 
            Integer leftOver = Math.round(Math.mod(attendingMemberIds.size(),50));
            list<Id> attendingMemberIds_Chunk = new List<id>();

            if(attendingMemberIds.size() >= 50){
                System.debug('secondaryCmpaignMemberIds.Size:'+attendingMemberIds.size());
                System.debug('loopTimes:'+loopTimes);
                System.debug('leftOver:'+leftOver);
    
                for(Integer i=0; i < loopTimes; i++){

    
                    for(Integer j=0; j < 50; j++){
                        attendingMemberIds_Chunk.add(attendingMemberIds.remove(0));
                    }
    
                    try{
                        System.debug('TotalChunkSize: ' + attendingMemberIds_Chunk.size());
                        CheckInMembers(attendingMemberIds_Chunk);
                    }
    
                    catch(Exception e){
                        System.debug(e.getMessage());
                    }
                    attendingMemberIds_Chunk.clear();
                }
    
                if(leftOver > 0){
                    for(Integer i=0; i < leftOver; i++){
                        attendingMemberIds_Chunk.add(attendingMemberIds.remove(0));
                    }
    
                    try{
                        System.debug('TotalChunkSize: ' + attendingMemberIds_Chunk.size());
                        CheckInMembers(attendingMemberIds_Chunk);
                    }
    
                    catch(Exception e){
                        System.debug(e.getMessage());
                    }
                }
            }
    
            else{
                try{
                    CheckInMembers(attendingMemberIds);
                }
    
                catch(Exception e){
                    System.debug(e.getMessage());
                }
            }
        }

        else{
            Datetime datetime_Now = Datetime.now();
            Date date_Today = Date.today();

            if(date_Today > cmpaign.EndDate || datetime_Now > cmpaign.AS_End_Time__c){
                cmpaign.Status = 'Completed';
                update cmpaign;
            }
        }
    }


    @Future
    public static void CheckInMembers(List<Id> cmpaignMemberIds){
        System.debug('CheckInMembers');
        List<CampaignMember> attendingMembers = [SELECT Id,Name,CampaignId,LeadOrContactId,Status FROM CampaignMember WHERE Id in :cmpaignMemberIds];
        Id attendeeMemberCmpaignId = attendingMembers[0].CampaignId;

        for(CampaignMember member : attendingMembers){
            if(member.Status == 'Attending'){
                member.Status = 'Checked In';
            }
        }

        update attendingMembers;

        Integer attendingMembersCount = [SELECT COUNT() FROM CampaignMember WHERE CampaignId = :attendeeMemberCmpaignId AND Status = 'Attending'];
        
        if(attendingMembersCount == 0){
            Campaign cmpaign = [SELECT Id,Name,Status FROM Campaign WHERE Id = :attendeeMemberCmpaignId];
            cmpaign.Status = 'Completed';
            update cmpaign;
        }
    }

}