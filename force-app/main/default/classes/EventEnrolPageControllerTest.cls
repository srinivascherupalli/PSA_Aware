@isTest
public class EventEnrolPageControllerTest {
    static testmethod void MethodTest() {
        
        Id eventRT = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        Id recordTypeL = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        
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

        Training_Track__c weeee = new Training_Track__c( Name = 'Test Training Track' );
        insert weeee;

        List<Id> aaa = new List<Id>();
        aaa.add( plan.Id );
        String ff = JSON.serialize( aaa );

        EventEnrolPageController.getEvents(plan.Id, l.Id);
        EventEnrolPageController.getEvnts(plan.Id, null);
        EventEnrolPageController.getEvnts(ff, 'true');
        EventEnrolPageController.getTrainingPlan(plan.Id);
        EventEnrolPageController.getEvent(evnt.Id);
        EventEnrolPageController.passEvt(plan.Id, evnt.Id, weeee.Id);
    }
    
    static testmethod void MethodTest1() {
        
        Id eventRT = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        Id recordTypeL = Schema.SObjectType.Learning__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        
        AS_Event__c evnt = new AS_Event__c(Name = 'Test Event', AS_Start_Date__c = date.today()-1, AS_End_Date__c = date.today());
        insert evnt;
        
        Campaign camp1 = new Campaign(RecordTypeId = eventRT, Name = 'Test Camp', AS_Region__c = 'NSW', AS_Event__c = evnt.Id);
        insert camp1;
            
        Campaign camp = new Campaign(RecordTypeId = eventRT, Name = 'Test Camp', AS_Region__c = 'NSW', ParentId = camp1.Id);
        insert camp;
        
        Learning__c l = new Learning__c(Name = 'Test', RecordTypeId = recordTypeL, Campaign__c = camp.Id);
        insert l;

        Learning_Package__c lp = new Learning_Package__c(Name = 'Test');
        insert lp;
        
        evnt.AS_Session_Campaign__c = camp.Id;
        update evnt;
        
        Training_Plan__c plan = new Training_Plan__c(Name = 'Test Plan', Type__c = 'Paid', Start_Date__c = date.today()-1, End_Date__c = date.today(), AS_Event__c = camp.Id);
        insert plan;
        
        Training_Plan__c plan1 = new Training_Plan__c(Name = 'Test Plan', Type__c = 'Member Only (Paid)', Start_Date__c = date.today()-1, End_Date__c = date.today(), AS_Event__c = camp.Id);
        insert plan1;

        Training_Track__c weeee = new Training_Track__c( Name = 'Test Training Track' );
        insert weeee;

        List<Id> aaa = new List<Id>();
        aaa.add( plan1.Id );
        String ff = JSON.serialize( aaa );
        
        EventEnrolPageController.getEvents(plan.Id, l.Id);
        EventEnrolPageController.getPrice(plan.Id);
        EventEnrolPageController.getTrainingPlanType(plan.Id, null);
        EventEnrolPageController.getTrainingPlanType(ff, 'true');
        EventEnrolPageController.getAccessType(plan1.Id, null);
        EventEnrolPageController.getAccessType(ff, 'true');
        EventEnrolPageController.getLearnings(plan.Id, null);
        EventEnrolPageController.getLearnings(ff, 'true');
        EventEnrolPageController.getIcon(plan.Id, null);
        EventEnrolPageController.getIcon(ff, 'true');
        EventEnrolPageController.getTrainingPlan(plan.Id);
        EventEnrolPageController.getEvent(evnt.Id);
        EventEnrolPageController.passEvt(plan.Id, evnt.Id, weeee.Id);
        EventEnrolPageController.createEnrolment( lp.Id );
    }
}