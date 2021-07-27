/**
 * @File Name          : AS_CampaignMember.trigger
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/8/2019, 6:06:40 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/8/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
trigger AS_CampaignMember on CampaignMember (after insert , after update , after delete) {
    AS_HelperClass asHelper = new AS_HelperClass();

    /* After Insert */
    if(Trigger.isInsert && Trigger.isAfter){
        
  
        AS_HelperClass.CampaignMemberTriggerHelper(Trigger.new);
        asHelper.OnAfterInsertCampMember(Trigger.new,Trigger.newMap);
        
    }  
 
    /* After Update */ 
    else if(Trigger.isUpdate && Trigger.isAfter){

         asHelper.OnAfterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
  
    /* After Delete */
    else if(Trigger.isDelete && Trigger.isAfter){
         asHelper.OnAfterDelete(Trigger.oldMap);
    }
}