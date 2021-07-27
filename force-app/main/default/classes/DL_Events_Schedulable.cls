global with sharing class DL_Events_Schedulable implements Schedulable {

    global void execute(SchedulableContext sc) {
        
        try{
            List<Id> autoFlowParentCampaignIds = new List<Id>();
            List<Campaign> autoFlowChildCampaigns = [SELECT Id,Name,Status,ParentId,Parent.Flow_Members_Down_Heirarchy__c 
                                                        FROM Campaign 
                                                        WHERE Parent.Flow_Members_Down_Heirarchy__c = true 
                                                        AND Status NOT IN ('Completed','Aborted')
                                                        AND Parent.Status NOT IN ('Completed','Aborted')];
            
            if(autoFlowChildCampaigns.size() > 0){

                for(Campaign cmpaign : autoFlowChildCampaigns){
                    if(!autoFlowParentCampaignIds.contains(cmpaign.ParentId)){
                        autoFlowParentCampaignIds.add(cmpaign.ParentId);
                    }
                }

                for(Id parentId : autoFlowParentCampaignIds){
                    DL_CampaignMember_TriggerHandler.FlowMembersHandler(parentId);
                }
            }
        }

        catch(Exception e){
            System.debug(e.getMessage());
        }


        try{
            List<Campaign> incompleteCampaigns = [SELECT Id, Name, Type, Status, StartDate, EndDate, AS_Start_Time__c, AS_End_Time__c, Back_to_Back_Session__c
                                                    FROM Campaign 
                                                    WHERE Status IN ('Planned','In Progress') 
                                                    AND Type IN ('Event','Seminar / Conference')
                                                    AND Auto_Close__c = true];

            List<Campaign> campaignsToUpdate = new List<Campaign>(); 
            List<Campaign> campaignsToClose = new List<Campaign>();
            Datetime datetime_Now = Datetime.now();
            Date date_Today = Date.today();

            for(Campaign cmpaign : incompleteCampaigns){
                if(date_Today > cmpaign.EndDate || datetime_Now > cmpaign.AS_End_Time__c){
                    System.debug('DL_Events_Schedulable: completed');
                    //cmpaign.Status = 'Completed';
                    campaignsToClose.add(cmpaign);
                }

                else if(date_Today > cmpaign.StartDate || datetime_Now > Datetime.valueOf(cmpaign.AS_Start_Time__c).addMinutes(-30)){
                    System.debug('DL_Events_Schedulable: In Progress');
                    cmpaign.Status = 'In Progress';
                    campaignsToUpdate.add(cmpaign); 
                }
            }

            if (campaignsToUpdate.size() > 0){
                update campaignsToUpdate;
            }

            if (campaignsToClose.size() > 0){
                for(Campaign cmpaignToClose : campaignsToClose){
                    if(cmpaignToClose.Back_to_Back_Session__c != null){
                        DL_CampaignMember_TriggerHandler.BackToBackSessionHandler(cmpaignToClose.Id, cmpaignToClose.Back_to_Back_Session__c);
                    }
                    DL_CampaignMember_TriggerHandler.CheckInMembersHandler(cmpaignToClose.Id);
                }
                
                //update campaignsToClose; 
                ////Campaigns now marked as closed by DL_CampaignMember_TriggerHandler.CheckInMembers()
            }
        }

        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}