trigger AS_Attendee_Trigger on AS_Attendee__c (after insert, after update, before delete) {
    List<AS_Attendee__c> attendeeList = new List<AS_Attendee__c>();
    List<AS_Attendee__c> attendeeListUpdate = new List<AS_Attendee__c>();
    List<AS_Attendee__c> attendeeListDelete = new List<AS_Attendee__c>();
    Id userId = UserInfo.getUserId();
    List<User> users = [Select ContactId from User where Id =: userId];
    //Id conId = '0030k00000rOFKpAAO';
    Id conId = users[0].ContactId;
    if(trigger.isInsert || trigger.isUpdate){
        for(AS_Attendee__c att : Trigger.New){
            if(att.AS_Event__c != null && att.AS_Attendee_Last_Name__c != null && att.AS_Status__c == 'Attending'){
                attendeeList.add(att);
            }
            if(Trigger.isUpdate){
                attendeeListUpdate.add(att);
                /*if(conId != null || att.AS_User__c != conId){
                    att.AS_User__c = conId;
                    if(!attendeeList.isEmpty()) AS_Attendee_TriggerHandler.createCampaignMember(attendeeList);
                }*/
            }
        }
    }
    else if(Trigger.isDelete){
    	 AS_Attendee_TriggerHandler.deleteCampaignMember(Trigger.oldMap);
    }
    
    if(Trigger.isInsert){
        if(!attendeeList.isEmpty()) AS_Attendee_TriggerHandler.createCampaignMember(attendeeList);
    }
    if(Trigger.isUpdate){
        if(!attendeeList.isEmpty()) AS_Attendee_TriggerHandler.createCampaignMember(attendeeList);
        //if(!attendeeListUpdate.isEmpty()) AS_Attendee_TriggerHandler.updateCampaignMember(attendeeListUpdate);
    }
}