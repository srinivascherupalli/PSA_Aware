public class AS_Attendee_TriggerHandler {
    public static void createCampaignMember(List<AS_Attendee__c> attendeeList){
        Set<CampaignMember> campMemList = new Set<CampaignMember>();
        if(!attendeeList.isEmpty()){
            String conId;
            String attId;
            String campId;
            Boolean createCamp = true;
            System.debug('attendeeList1: '+attendeeList.size());
            //Id conId = users[0].ContactId;//updateAttendee(attendeeList);
                /*Id conId = updateAttendee(attendeeList);
                for(AS_Attendee__c att : attendeeList){
                    Id sesCampId = getSessionCampId(att.AS_Event__c);
                    if(sesCampId != null){
                        CampaignMember campMem = new CampaignMember();
                        campMem.Status = 'Attending';
                        if(conId != null) campMem.ContactId = conId;
                        campMem.AS_Attendee__c = att.Id;
                        campMem.CampaignId = sesCampId;
                        campMemList.add(campMem);
                    }
                }*/
            
            for(AS_Attendee__c att : attendeeList){
                conId = att.AS_User__c;
                campId = att.AS_Event__c;
                attId = att.Id;
            }
            if(String.isBlank(conId)) conId = updateAttendee(attendeeList);
            Id sesCampIds = getSessionCampId(campId);
            List<CampaignMember> camp = [Select Id From CampaignMember where ContactId =: conId AND CampaignId =: sesCampIds];
            if(camp.size() > 0){
                //updateCampaignMember(attId);
                createCamp = false;
                conId = null;
            }
            if(createCamp == true){
                Set<Id> contIds = new Set<Id>();
                for(AS_Attendee__c att : attendeeList){
                    Id sesCampId = getSessionCampId(att.AS_Event__c);
                    System.debug('sesCampId: '+sesCampId);
                    if(sesCampId != null && conId != null){
                        CampaignMember campMem = new CampaignMember();
                        campMem.Status = 'Attending';
                        if(conId != null) campMem.ContactId = conId;
                        campMem.Created_from_Attendee__c = true;
                        campMem.AS_Attendee__c = att.Id;
                        campMem.CampaignId = sesCampId;
                        if(!contIds.contains(att.Id)) campMemList.add(campMem);
                        contIds.add(att.Id);
                    }
                }
            }
            System.debug('campMemList: '+campMemList);
            if(campMemList != null){
                List<CampaignMember> campInsert = new List<CampaignMember>();
                campInsert.addAll(campMemList);
                insert campInsert;
            } 
        }
    }
    @future
    public static void updateCampaignMember(String attIds){
        List<AS_Attendee__c> attendeeList = [Select Id, AS_User__c, AS_Event__c, AS_Status__c From AS_Attendee__c Where Id =: attIds];
        List<CampaignMember> campMemList = new List<CampaignMember>();
        Set<String> conId = new Set<String>();
        Set<String> attId = new Set<String>();
        if(!attendeeList.isEmpty()){
            for(AS_Attendee__c att : attendeeList){
                conId.add(att.AS_User__c);
                attId.add(att.Id);
            }
            List<CampaignMember> camps = [Select Id, CampaignId From CampaignMember where ContactId IN: conId AND AS_Attendee__c IN: attId];
            for(AS_Attendee__c att : attendeeList){
                Id sesCampId = getSessionCampId(att.AS_Event__c);
                for(CampaignMember camp : camps){
                    if(camp.CampaignId == sesCampId){
                        CampaignMember cmp = new CampaignMember();
                        cmp.Id = camp.Id;
                        cmp.Status = att.AS_Status__c;
                        //if(conId != null) cmp.ContactId = att.AS_User__c;
                        cmp.Created_from_Attendee__c = true;
                        //cmp.AS_Attendee__c = att.Id;
                        //cmp.CampaignId = sesCampId;
                        campMemList.add(cmp);
                    }
                }
            }
            System.debug('campMemList: '+campMemList);
            if(campMemList != null) update campMemList;
        }
    }
    public static void deleteCampaignMember(Map<Id,AS_Attendee__c> oldMap){
        Set<Id> campMemIds = new Set<Id>();
        Set<String> conId = new Set<String>();
        Set<String> attId = new Set<String>();
        if(oldMap.values() != null){
            for(AS_Attendee__c att : oldMap.values()){
                conId.add(att.AS_User__c);
                attId.add(att.Id);
            }
            System.debug('conId: '+conId);
            System.debug('attId: '+attId);
            List<CampaignMember> camps = [Select Id, CampaignId, IsDeleted From CampaignMember where ContactId IN: conId AND AS_Attendee__c IN: attId];
            System.debug('camps: '+camps);
            for(AS_Attendee__c att : oldMap.values()){
                Id sesCampId = getSessionCampId(att.AS_Event__c);
                System.debug('sesCampId: '+sesCampId);
                for(CampaignMember camp : camps){
                    if(camp.CampaignId == sesCampId){
                        campMemIds.add(camp.Id);
                    }
                }
            }
            System.debug('campMemList: '+campMemIds);
            if(campMemIds != null) deleteCampaignMem(campMemIds);
        }
    }
    @future
    public static void deleteCampaignMem(Set<Id> campIds){
        
            List<CampaignMember> camps = [Select Id, CampaignId, IsDeleted From CampaignMember where Id In: campIds];
            System.debug('campsToDelete: '+camps);
            if(camps != null) delete camps;
    }
    /*public static void deleteCampaignMember(List<AS_Attendee__c> attendeeList){
        Set<String> conId = new Set<String>();
        Set<String> attId = new Set<String>();
        if(!attendeeList.isEmpty()){
            for(AS_Attendee__c att : attendeeList){
                conId.add(att.AS_User__c);
                attId.add(att.Id);
            }
            if(conId != null && attId != null) delete [Select Id, CampaignId From CampaignMember where ContactId IN: conId AND AS_Attendee__c IN: attId];
            
        }
    }*/
    public static Id updateAttendee(List<AS_Attendee__c> attendeeList){
        if(!attendeeList.isEmpty()){
            System.debug('attendeeList: '+attendeeList);
            Id userId = UserInfo.getUserId();
            Id conId;
            if(Test.isRunningTest()){
                Account acc = new Account( Name = 'Community'  );
                insert acc;
                Contact con = new Contact(LastName = 'TestContact', AccountId = acc.Id);
                insert con;
                conId = con.Id;
            }
            List<AS_Attendee__c> attendees = new List<AS_Attendee__c>();
            List<User> users = [Select ContactId from User where Id =: userId];
            
            Set<String> con = new Set<String>();
            for(AS_Attendee__c att : attendeeList){
                con.add(att.AS_User__c);
            }
            
            if(!Test.isRunningTest()) conId = users[0].ContactId;
            //conId = '0030k00000rOFKpAAO';
            if(con == null || !con.contains(conId)){
            for(AS_Attendee__c att : attendeeList){
                    if(conId != null){
                        AS_Attendee__c atts = new AS_Attendee__c();
                        atts.Id = att.Id;
                        atts.AS_User__c = conId;
                        attendees.add(atts);
                    }
                }
            }
            if(attendees != null) update attendees;
            return conId;
        }
        return null;
    }
    public static Id getSessionCampId(Id evntId){
        List<AS_Event__c> evnt = [Select AS_Session_Campaign__c From AS_Event__c where Id =: evntId];
        return evnt[0].AS_Session_Campaign__c;
    }
}