public class TrainingPlanAssignmentTrgHandler {
    public static void updateAttendee(List<Training_Plan_Assignment__c> assignmentList){
        
        Set<String> trainingPlanIds = new Set<String>();
        Set<String> userId = new Set<String>(); 
        Set<String> assId = new Set<String>();
        Set<String> evntIds = new Set<String>();
        Set<String> evntId = new Set<String>();
        List<AS_Attendee__c> attendeeList = new List<AS_Attendee__c>();
        List<Training_Plan_Assignment__c> assignsLists = new List<Training_Plan_Assignment__c>();
        List<Training_Plan_Assignment__c> missingAssignsList = new List<Training_Plan_Assignment__c>();
        
        if(!assignmentList.isEmpty()){
            System.debug('assignmentList: '+assignmentList);
            for(Training_Plan_Assignment__c assignments : assignmentList){
                assId.add(assignments.Id);
                trainingPlanIds.add(assignments.Training_Plan__c);     
                userId.add(assignments.User__c);
                assignsLists.add(assignments);
            }
            
            // get event(campaign) linked to tplan
            for(Training_Plan_Assignment__c assignments : [SELECT Id, Training_Plan__c, Training_Plan__r.AS_Event__c, Training_Plan__r.AS_Event__r.AS_Event__c, Training_Plan__r.AS_Event__r.Type, User__c, User__r.ContactId 
                                                           	FROM Training_Plan_Assignment__c 
                                                           	WHERE Id In: assId
                                                          		AND Training_Plan__r.AS_Event__c != null]){
                if(assignments.Training_Plan__r.AS_Event__c != null){
                    if(assignments.Training_Plan__r.AS_Event__r.AS_Event__c == null) evntIds.add(assignments.Training_Plan__r.AS_Event__c);
                    else evntId.add(assignments.Training_Plan__r.AS_Event__r.AS_Event__c);
                }
            }
        }
        
        Boolean parentCamp = false;
        Set<String> campIds = new Set<String>();
        Set<String> campId = new Set<String>();
        if(evntIds.size() > 0){
            System.debug('camp.Id: '+evntIds);
            List<Campaign> campaigns = [SELECT Id, AS_Event__c FROM Campaign WHERE ParentId In: evntIds];
            for(Campaign camp: campaigns){
                if(camp.AS_Event__c != null) evntId.add(camp.AS_Event__c);
                System.debug('evntId: '+evntId);
            }
        }
        System.debug('future? => ' + System.isFuture());
        System.debug('batch? => ' + System.isBatch());
        if(!System.isFuture() && !System.isBatch()) TrainingPlanAssignmentTrgHandler.future_updateAttendee_helper(assId, trainingPlanIds, userId, evntId);
        else TrainingPlanAssignmentTrgHandler.updateAttendee_helper(assId, trainingPlanIds, userId, evntId);
    }
    
    @future
    public static void future_updateAttendee_helper(Set<String> tplanAsgnId, Set<String> trainingPlanIds, Set<String> userId, Set<String> evntId){
        updateAttendee_helper(tplanAsgnId, trainingPlanIds, userId, evntId);
    }
    public static void updateAttendee_helper(Set<String> tplanAsgnId, Set<String> trainingPlanIds, Set<String> userId, Set<String> evntId){
        List<AS_Attendee__c> attendeeList = new List<AS_Attendee__c>();
        List<Training_Plan_Assignment__c> missingAssignsList = new List<Training_Plan_Assignment__c>();
        
        Set<String> conIds = new Set<String>();
        
        Id recordType = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        
        Set<Id> learningIds = new Set<Id>();
        
        for(Training_Plan_Section_Item__c tpsi : [SELECT Id, Learning__c 
                                                  FROM Training_Plan_Section_Item__c 
                                                  WHERE Training_Plan_Section__r.Training_Plan__c IN: trainingPlanIds
                                                  AND Learning__r.RecordTypeId =: recordType]){
                                                      learningIds.add(tpsi.Learning__c);
                                                  }
        if(learningIds.size() > 0) {
            Map<String, AS_Event__c> events = new Map<String, AS_Event__c>([SELECT Id FROM AS_Event__c Where AS_Session_Campaign__r.Learning__c In: learningIds AND AS_Session_Campaign__r.AS_Include_in_Portal__c = true]);
            evntId = events.keySet();
        }
    
    
    
        if(!tplanAsgnId.isEmpty() && evntId != null){
            if(userId != null){
                List<User> users = [SELECT ContactId FROM User WHERE Id In: userId];
                for(User usr : users){
                    conIds.add(usr.ContactId);
                }
            }
            
            //conIds.add('0030k00000rOFKoAAO');
            List<AS_Attendee__c> attendees = [SELECT Id FROM AS_Attendee__c 
                                              WHERE AS_Training_Plan__c In: trainingPlanIds 
                                              AND AS_User__c In: conIds
                                              AND AS_Event__c IN : evntId];// AND (AS_Event__c In: evntId OR AS_Event__r.AS_Session_Campaign__c In: evntId OR AS_Event__r.AS_Session_Campaign__r.ParentId In: evntId)];
            System.debug('attendees: '+attendees);
            if(!attendees.isEmpty()){
                for(AS_Attendee__c att : attendees){
                    AS_Attendee__c atts = new AS_Attendee__c(); 
                    atts.Id = att.Id;
                    atts.AS_Status__c = 'Attending';
                    attendeeList.add(atts);
                }
            }
            else{
                for(Id assignments : tplanAsgnId){
                    Training_Plan_Assignment__c assign = new Training_Plan_Assignment__c();
                    assign.Id = assignments;
                    assign.AS_Missing_Session__c = true;
                    missingAssignsList.add(assign);
                }
            }
            
            if(attendeeList.size() > 0) update attendeeList;
            if(missingAssignsList.size() > 0) update missingAssignsList;
        }
    }
}