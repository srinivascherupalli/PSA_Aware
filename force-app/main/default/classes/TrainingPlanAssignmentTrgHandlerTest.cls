@isTest
public class TrainingPlanAssignmentTrgHandlerTest {
    static testMethod void testPreviewRedirection(){
        Id eventRT = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        Id recordTypeL = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        List<Training_Plan_Assignment__c> assignsLists = new List<Training_Plan_Assignment__c>();
        
        AS_Event__c evnt = new AS_Event__c(Name = 'Test Event', AS_Start_Date__c = date.today()-1, AS_End_Date__c = date.today());
        insert evnt;
            
        Campaign camp = new Campaign(RecordTypeId = eventRT, Name = 'Test Camp', AS_Region__c = 'NSW', AS_Event__c = evnt.Id);
        insert camp;
        
        Learning__c l = new Learning__c(Name = 'Test', RecordTypeId = recordTypeL, Campaign__c = camp.Id);
        insert l;
        
        evnt.AS_Session_Campaign__c = camp.Id;
        update evnt;
        
        Training_Plan__c plan = new Training_Plan__c(Name = 'Test Plan', Type__c = 'Paid', Start_Date__c = date.today()-1, End_Date__c = date.today(), AS_Event__c = camp.Id);
        insert plan;
        
        Account acc = new Account( Name = 'Community'  );
        insert acc;
        
        Contact con = new Contact(LastName = 'TestContact', AccountId = acc.Id);
        insert con;
        
        Set<String> customerUserTypes = new Set<String> {'CspLitePortal'};
        Profile UserprofileId = [SELECT Id FROM Profile WHERE UserType in :customerUserTypes limit 1];
        
        // Create user as test data
        User usr = new User(LastName = 'PortalUser',
            FirstName='user',
            Alias = 'Portal',
            Email = 'test@test.alphasys.com',
            Username = System.currentTimeMillis()+'@test.alphasys.com',
            ProfileId = UserprofileId.id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            PortalRole = 'Manager',
            ContactId = con.Id
            );
        insert usr;
        
        Training_Plan_Assignment__c assign = new Training_Plan_Assignment__c(Training_Plan__c = plan.Id, User__c = usr.Id);
        insert assign;
        assignsLists.add(assign);
        
        TrainingPlanAssignmentTrgHandler.updateAttendee(assignsLists);
        TrainingPlanAssignmentTrgHandler.future_updateAttendee_helper(new Set<String>{ assign.Id }, new Set<String>{ plan.Id }, new Set<String>{ usr.Id }, new Set<String>{ evnt.Id });
    }
}