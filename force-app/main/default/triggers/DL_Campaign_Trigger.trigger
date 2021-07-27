trigger DL_Campaign_Trigger on Campaign (before insert, after insert, before update, after update) {

    if(Trigger.isBefore){

        for(Campaign cmpaign : Trigger.new){
            if(cmpaign.ParentId != null){
                cmpaign.Flow_Members_Down_Heirarchy__c = false;
            }
                                            
			/*
            if(cmpaign.Type == 'Seminar / Conference'){
                cmpaign.Auto_Close__c = true;
            }
			*/

            if(cmpaign.Type == 'Seminar / Conference' && cmpaign.ParentId == null){
                cmpaign.Flow_Members_Down_Heirarchy__c = true;
            }

           /* if(cmpaign.AS_Start_Time__c != null){
                cmpaign.Start_Time_Text__c = cmpaign.AS_Start_Time__c.format('h:mm a');
            }

            if(cmpaign.AS_End_Time__c != null){
                cmpaign.End_Time_Text__c = cmpaign.AS_End_Time__c.format('h:mm a');
            }*/
            
        }
    }


    if(Trigger.isAfter){
        if(Trigger.isInsert){
            System.debug('DL_Campaign_Trigger: Trigger.isInsert');

            for(Campaign cmpaign : Trigger.new){
                if(cmpaign.ParentId != null){
                    Campaign parentCampaign = [SELECT Id,Name,Flow_Members_Down_Heirarchy__c FROM Campaign WHERE Id = :cmpaign.ParentId];
                    System.debug(parentCampaign);
                    if(parentCampaign.Flow_Members_Down_Heirarchy__c == true){
                        DL_CampaignMember_TriggerHandler.FlowMembersHandler(parentCampaign.Id);
                    }
                }

                else if(cmpaign.Flow_Members_Down_Heirarchy__c == true){
                    DL_CampaignMember_TriggerHandler.FlowMembersHandler(cmpaign.Id);
                }

            }
        }

        else if(Trigger.isUpdate){
            System.debug('DL_Campaign_Trigger: Trigger.isUpdate');

            for(Campaign cmpaign : Trigger.new){
                if((cmpaign.ParentId == null) && (cmpaign.Status == 'Completed')){
                   // DL_Events.DeleteRFIDNumbers(cmpaign.Id);
                   system.debug(cmpaign.Id + ',' + cmpaign.Name);
                }
            }
        }
    }

}