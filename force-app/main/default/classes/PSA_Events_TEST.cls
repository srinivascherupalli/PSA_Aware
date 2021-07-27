@isTest
private class PSA_Events_TEST {



  /*
  *Author : Jet
  *Description : This method to test the getEvent
  *Date Created :
  *Last Modified By : Jet
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
  static testMethod void getEventsTest(){

    // Init the Class to be test/
    PSA_Events_CTRL psaEvent = new PSA_Events_CTRL();

    //Create Record for Campaign.
	    Id camRecId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
	    Campaign testCamp           = new Campaign();
      testCamp.Name             = 'Sample';
      testCamp.IsActive         = true ;
      testCamp.AS_Region__c     = 'NSW' ;
      testCamp.AS_Start_Time__c = datetime.now();
      testCamp.AS_End_Time__c   = datetime.now().addHours(10);
      testCamp.recordTypeId = camRecId;
      testCamp.IsActive = true;
    	insert testCamp;

    //Calling the method to Tested.

    list< Campaign > resCampList = psaEvent.getEvents();
    System.debug('resCampList : ' + resCampList.size() + ' - ' + resCampList);
   // system.assertEquals(resCampList.size(),1);


  }

  /*
  *Author : Jet
  *Description : This method to test the getSelectRegions 
  *Date Created :
  *Last Modified By : Jet
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
  static testMethod void getSelectRegionsTest(){

    // Init the Class to be test/
    PSA_Events_CTRL psaEvent = new PSA_Events_CTRL();

    //Calling the method to Tested.
    list< SelectOption > resSelectOptList = psaEvent.getSelectRegions();
    system.assertEquals( resSelectOptList[1].getValue() , 'ACT' );
 
  }


  /*
  *Author : Jet
  *Description : This method to test the getPickListValuesEventType 
  *Date Created :
  *Last Modified By : Jet
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
  static testMethod void getPickListValuesEventTypeTest(){

    // Init the Class to be test/
    PSA_Events_CTRL psaEvent = new PSA_Events_CTRL();

    //Calling the method to Tested.
    list< String > resEventTypeList = psaEvent.getPickListValuesEventType();
    system.debug( resEventTypeList );
    System.assert(resEventTypeList.size() != 0, 'is empty');
  }


  /*
  *Author : Jet
  *Description : This method to test the getPickListValuesInterestGroup 
  *Date Created :
  *Last Modified By : Jet
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
  static testMethod void getPickListValuesInterestGroupTest(){

    // Init the Class to be test/
    PSA_Events_CTRL psaEvent = new PSA_Events_CTRL();

    //Calling the method to Tested.
    list< String > resInteresGroupList = psaEvent.getPickListValuesInterestGroup();
    system.debug( resInteresGroupList );
    System.assert(resInteresGroupList.size() != 0, 'is empty');
 
  }


  /*
  *Author : Jet
  *Description : This method to test the eventdata 
  *Date Created :
  *Last Modified By : Jet
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
  static testMethod void eventdataTest(){

    //Create Record for Campaign.
    Campaign testCamp           = new Campaign();
      testCamp.Name             = 'Sample';
      testCamp.IsActive         = true ;
      testCamp.AS_Region__c     = 'NSW' ;
      testCamp.AS_Start_Time__c = datetime.newInstance(2018, 03, 25, 8, 30, 0) ;
      testCamp.AS_End_Time__c   = datetime.newInstance(2018, 03, 25, 7, 00, 0) ;
    insert testCamp;
 
    //Calling the method to Tested.

    String resCampJsonStr = PSA_Events_CTRL.eventdata();
    //system.assertEquals(
    //  resCampJsonStr
    //  ,'[]'
    //);
  
  }

  /*
  *Author : Jet
  *Description : This method to test remote function filterCampaign  
  *Date Created :
  *Last Modified By : Jet
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
  static testMethod void filterCampaignTest(){

    //Create Record for Campaign.
    Id camRecId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Event').getRecordTypeId();
    Campaign testCamp           = new Campaign();
      testCamp.Name             = 'Sample';
      testCamp.IsActive         = true ;
      testCamp.AS_Region__c     = 'NSW' ;
      testCamp.AS_Start_Time__c = datetime.newInstance(2018, 03, 25, 8, 30, 0) ;
      testCamp.AS_End_Time__c   = datetime.newInstance(2018, 03, 25, 7, 00, 0) ;
      testCamp.recordTypeId = camRecId;
    insert testCamp;
 		
 		
 		List<Campaign> allCam = [Select Id,name,AS_Region__c from campaign];
 		System.debug('allCam : ' + allCam.size() + allCam);
 		
    //Calling the method to Tested.
    list< Campaign > resCampListNonFilter  = PSA_Events_CTRL.filterCampaign('{"location":"NSW","eventType":["Option 1"],"interestgroup":["General practice pharmacist"],"campaigndate":"2018-6-14","searchAll":""}');
    list< Campaign > resCampListFilter     = PSA_Events_CTRL.filterCampaign('{"location":"","eventType":[],"interestgroup":[],"campaigndate":"","searchAll":""}');
		list< Campaign > resCampListFilterSearchAll     = PSA_Events_CTRL.filterCampaign('{"location":"","eventType":[],"interestgroup":[],"campaigndate":"","searchAll":"Sample"}');
    system.assertEquals(resCampListNonFilter.size(),0);
   // system.assertEquals(resCampListFilter.size(),1);
		system.assertEquals(resCampListFilterSearchAll.size(),0);
  }


  /*
  *Author : Jet
  *Description : This method to test the globalfilterCampaign 
  *Date Created :
  *Last Modified By : Jet
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
  static testMethod void globalfilterCampaignTest(){

    //Create Record for Campaign.
    Campaign testCamp           = new Campaign();
      testCamp.Name             = 'Sample';
      testCamp.IsActive         = true ;
      testCamp.AS_Region__c     = 'NSW' ;
      testCamp.AS_Start_Time__c = datetime.newInstance(2018, 03, 25, 8, 30, 0) ;
      testCamp.AS_End_Time__c   = datetime.newInstance(2018, 03, 25, 7, 00, 0) ;
    insert testCamp;

    //Calling the method to Tested.

    list< Campaign > resGlobalFilterList = PSA_Events_CTRL.globalfilterCampaign('Sample');
    system.assertEquals(resGlobalFilterList.size(),0);
 
  }


  ///*
  //*Author : Jet
  //*Description : This method to test remote function filterCampaign  
  //*Date Created :
  //*Last Modified By : Jet
  //*Date Last Modified :
  //*Param : 
  //*Return : 
  //*/ 
  //static testMethod void filterCampaignTest(){

  //  //Create Record for Campaign.
  //  Campaign testCamp           = new Campaign();
  //    testCamp.Name             = 'Sample';
  //    testCamp.IsActive         = true ;
  //    testCamp.AS_Region__c     = 'NSW' ;
  //    testCamp.AS_Start_Time__c = datetime.newInstance(2018, 03, 25, 8, 30, 0) ;
  //    testCamp.AS_End_Time__c   = datetime.newInstance(2018, 03, 25, 7, 00, 0) ;
  //  insert testCamp;
 
  //  //Calling the method to Tested.
  //  PSA_Events_CTRL.filterCampaign('{"location":"NSW","eventType":["Option 1"],"interestgroup":["General practice pharmacist"],"campaigndate":"2018-6-14"}');
  //  PSA_Events_CTRL.filterCampaign('{"location":"","eventType":[],"interestgroup":[],"campaigndate":""}');


  //}






 // static TestMethod void EventsTest() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;

 //  PSA_Events_CTRL psa_events = new PSA_Events_CTRL();
 //  psa_events.flag      = 'Region';
 //  psa_events.region    = 'NSW';
 //  psa_events.getEvents();
 //  psa_events.getSelectRegions();

 //}

 //static TestMethod void EventsTest1() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;


 //  PSA_Events_CTRL psa_events = new PSA_Events_CTRL();
 //  psa_events.flag      = 'Region';
 //  psa_events.region    = 'All';
 //  psa_events.getEvents();
 //  psa_events.getSelectRegions();
 //}

 //static TestMethod void SearchEventsTest1() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;

 //  PSA_Events_CTRL psa_events = new PSA_Events_CTRL();
 //  psa_events.flag           = 'Search';
 //  psa_events.eventname      = null;
 //  psa_events.eventloc       = null;
 //  psa_events.eventStartDate = null;
 //  psa_events.eventEndDate   = null;
 //  psa_events.getEvents();
 //  psa_events.getSelectRegions();
 //}

 //static TestMethod void SearchEventsTest2() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;

 //  PSA_Events_CTRL psa_events = new PSA_Events_CTRL();
 //  psa_events.flag           = 'Search';
 //  psa_events.eventname      = 'Sample 1';
 //  psa_events.eventloc       = null;
 //  psa_events.eventStartDate = null;
 //  psa_events.eventEndDate   = null;
 //  psa_events.getEvents();
 //  psa_events.getSelectRegions();
 //}

 //static TestMethod void SearchEventsTest3() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;

 //  PSA_Events_CTRL psa_events = new PSA_Events_CTRL();
 //  psa_events.flag           = 'Search';
 //  psa_events.eventname      = null;
 //  psa_events.eventloc       = 'Sa ilalom nga mabugnaw na tulay';
 //  psa_events.eventStartDate = null;
 //  psa_events.eventEndDate   = null;
 //  psa_events.getEvents();
 //  psa_events.getSelectRegions();
 //}

 //static TestMethod void SearchEventsTest4() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;

 //  PSA_Events_CTRL psa_events = new PSA_Events_CTRL();
 //  psa_events.flag           = 'Search';
 //  psa_events.eventname      = null;
 //  psa_events.eventloc       = null;
 //  psa_events.eventStartDate = '2018-3-24';
 //  psa_events.eventEndDate   = null;
 //  psa_events.getEvents();
 //  psa_events.getSelectRegions();
 //}

 //static TestMethod void SearchEventsTest5() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;

 //  PSA_Events_CTRL psa_events = new PSA_Events_CTRL();
 //  psa_events.flag           = 'Search';
 //  psa_events.eventname      = null;
 //  psa_events.eventloc       = null;
 //  psa_events.eventStartDate = null;
 //  psa_events.eventEndDate   = '2018-3-25';
 //  psa_events.getEvents();
 //  psa_events.getSelectRegions();
 //}

 //static TestMethod void SearchEventsTest6() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;

 //  PSA_Events_CTRL psa_events = new PSA_Events_CTRL();
 //  psa_events.flag           = 'Search';
 //  psa_events.eventname      = 'Sample 3';
 //  psa_events.eventloc       = 'Sa ilalom nga mabugnaw na tulay';
 //  psa_events.eventStartDate = null;
 //  psa_events.eventEndDate   = null;
 //  psa_events.getEvents();
 //  psa_events.getSelectRegions();
 //}

 //static TestMethod void SearchEventsTest7() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;

 //  PSA_Events_CTRL psa_events = new PSA_Events_CTRL();
 //  psa_events.flag           = 'Search';
 //  psa_events.eventname      = 'Sample 4';
 //  psa_events.eventloc       = 'Sa ilalom nga mabugnaw na tulay';
 //  psa_events.eventStartDate = null;
 //  psa_events.eventEndDate   = null;
 //  psa_events.getEvents();
 //  psa_events.getSelectRegions();
 //}

 //static TestMethod void SearchEventsTest8() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;

 //  PSA_Events_CTRL psa_events = new PSA_Events_CTRL();
 //  psa_events.flag           = 'Search';
 //  psa_events.eventname      = 'Sample 5';
 //  psa_events.eventloc       = null;
 //  psa_events.eventStartDate = '2018-3-24';
 //  psa_events.eventEndDate   = null;
 //  psa_events.getEvents();
 //  psa_events.getSelectRegions();
 //}


 //static TestMethod void SearchEventsTest9() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;

 //  PSA_Events_CTRL psa_events = new PSA_Events_CTRL();
 //  psa_events.flag           = 'Search';
 //  psa_events.eventname      = 'Sample 6';
 //  psa_events.eventloc       =  null;
 //  psa_events.eventStartDate =  null;
 //  psa_events.eventEndDate   = '2018-3-25';
 //  psa_events.getEvents();
 //  psa_events.getSelectRegions();
 //}

 //static TestMethod void SearchEventsTest10() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;

 //  PSA_Events_CTRL psa_events = new PSA_Events_CTRL();
 //  psa_events.flag           = 'Search';
 //  psa_events.eventname      = null;
 //  psa_events.eventloc       = 'Sa ilalom nga mabugnaw na tulay';
 //  psa_events.eventStartDate = '2018-3-24';
 //  psa_events.eventEndDate   = null;
 //  psa_events.getEvents();
 //  psa_events.getSelectRegions();
 //}

 //static TestMethod void SearchEventsTest11() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;

 //  PSA_Events_CTRL psa_events = new PSA_Events_CTRL();
 //  psa_events.flag           = 'Search';
 //  psa_events.eventname      = null;
 //  psa_events.eventloc       = 'Sa ilalom nga mabugnaw na tulay';
 //  psa_events.eventStartDate = null;
 //  psa_events.eventEndDate   = '2018-3-24';
 //  psa_events.getEvents();
 //  psa_events.getSelectRegions();
 //}

 //static TestMethod void SearchEventsTest12() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;

 //  PSA_Events_CTRL psa_events = new PSA_Events_CTRL();
 //  psa_events.flag           = 'Search';
 //  psa_events.eventname      = null;
 //  psa_events.eventloc       = null;
 //  psa_events.eventStartDate = '2018-3-24';
 //  psa_events.eventEndDate   = '2018-3-25';
 //  psa_events.getEvents();
 //  psa_events.getSelectRegions();
 //}

 //static TestMethod void SearchEventsTest13() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;

 //  PSA_Events_CTRL psa_events = new PSA_Events_CTRL();
 //  psa_events.flag           = 'Search';
 //  psa_events.eventname      = 'Sample 7';
 //  psa_events.eventloc       = 'Sa ilalom nga mabugnaw na tulay';
 //  psa_events.eventStartDate = '2018-3-24';
 //  psa_events.eventEndDate   = '2018-3-25';
 //  psa_events.getEvents();
 //  psa_events.getSelectRegions();
 //}

 //static TestMethod void RemotingEventsTest1() {

 //  String strRecordTypeId = [Select Id From RecordType 
 //  Where SobjectType = 'Campaign'
 //  and Name = 'Event'].Id;

 //  Campaign camp = new Campaign(
 //   Name 				= 'Sample',
 //   IsActive 			= true,
 //   AS_Region__c 		= 'NSW',
 //   AS_Start_Time__c  = datetime.newInstance(2018, 03, 25, 8, 30, 0),
 //   AS_End_Time__c  = datetime.newInstance(2018, 03, 25, 7, 00, 0)
 //   );
 //  insert camp;

 //  PSA_Events_CTRL.eventdata();

 //  PSA_Events_CTRL.calEvent calendarEvents = new PSA_Events_CTRL.calEvent();
 //  calendarEvents.title       = 'Sample Events';
 //  calendarEvents.startString = '2018-03-26';
 //  calendarEvents.endString   = '2018-03-27'; 
 //  calendarEvents.url         = 'wwww.EventBrite.com';

 //}


}