global class PSA_Events_CTRL {

  public String flag {
    get;
    set;
  }
  public String region {
    get;
    set;
  }
  public String eventCategory {
    get;
    set;
  }

  // public string eventsJSON {get; set;}  


  //ticket PSAPWSGP-5
  //field update to Practice_Area__c from Interest_Group__c
  //date change : 7/5/18
  //field update to Format__c from Practice_Area__c

  //date change : 7/5/18
  //field update to Topic__c from AsCategory__c

  global PSA_Events_CTRL() {
    region = 'All';
    flag = 'Region';
  }

  global List < Campaign > getEvents() {
    List < Campaign > events = new List < Campaign > ();
    events = [SELECT Id, Name, RecordType.Name, AS_Event_URL__c, AS_Location__c, StartDate, EndDate, AS_Start_Time__c, AS_End_Time__c, AS_Total_Attendees__c, AS_Remaining_Seats__c
    FROM Campaign WHERE RecordType.Name = 'Event'
    AND IsActive = true AND AS_Region__c != null AND Topic__c =: eventCategory ORDER BY StartDate ASC LIMIT 5
    ];
    eventCategory = 'none';
    events = updateEventTime(events);
    return events;
  }

  global List < SelectOption > getSelectRegions() {

    List < SelectOption > options = new List < SelectOption > ();
    options.add(new SelectOption('All', ' Events: All Region'));
    options.add(new SelectOption('ACT', ' Events: Australian Capital Territory'));
    options.add(new SelectOption('NSW', ' Events: New South Wales'));
    options.add(new SelectOption('NT', ' Events: Northern Territory'));
    options.add(new SelectOption('QLD', ' Events: Queensland'));
    options.add(new SelectOption('SA', ' Events: South Australia'));
    options.add(new SelectOption('TAS', ' Events: Tasmania'));
    options.add(new SelectOption('VIC', ' Events: Victoria'));
    options.add(new SelectOption('WA', ' Events: Western Australia'));
    return options;
  }

  /* JRC */
  global List < String > getPickListValuesEventType() {
    List < String > pickListValuesList = new List < String > ();
    Schema.DescribeFieldResult fieldResult = Campaign.Topic__c.getDescribe();
    List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry pickListVal: ple) {
      pickListValuesList.add(pickListVal.getLabel());
    }
    return pickListValuesList; 
  }

  static String dtFormat = 'EEE, d MMM yyyy HH:mm:ss z';

  global List < String > getPickListValuesInterestGroup() {
    List < String > pickListValuesList = new List < String > ();
    Schema.DescribeFieldResult fieldResult = Campaign.Format__c.getDescribe();
    List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry pickListVal: ple) {
      pickListValuesList.add(pickListVal.getLabel());
    }
    return pickListValuesList;
  }

  @RemoteAction
  global static String eventdata() {
    calEvent[] psa_events = new calEvent[] {};

    List < Campaign > camp = [SELECT Id, Name, RecordType.Name, AS_Event_URL__c, AS_Location__c, StartDate, EndDate, AS_Start_Time__c, AS_End_Time__c,
    Description, AS_Total_Attendees__c, AS_Remaining_Seats__c FROM Campaign WHERE RecordType.Name = 'Event'
    AND AS_Start_Time__c != null AND AS_End_Time__c != null AND IsActive = true AND Status='live' ORDER BY StartDate ASC
    ];

    for (Campaign c: camp) {

      DateTime startDT = c.AS_Start_Time__c.addHours(10);
      DateTime endDT = c.AS_End_Time__c.addHours(10);
      System.debug(' camp ==> ' + c);
      calEvent psaEvents = new calEvent();
      psaEvents.title = c.Name;
      psaEvents.startString = startDT.formatGmt(dtFormat);
      psaEvents.endString = endDT.formatGmt(dtFormat);
      psaEvents.url = c.AS_Event_URL__c;
      psaEvents.location = c.AS_Location__c;
      psaEvents.attendees = String.valueOf(c.AS_Total_Attendees__c);
      psaEvents.seats = String.valueOf(c.AS_Remaining_Seats__c);
      psaEvents.descrip = c.Description;

      system.debug(' psa_events ==> ' + psaEvents);

      psa_events.add(psaEvents);
    }

    String jsonEvents = JSON.serialize(psa_events);
    jsonEvents = jsonEvents.replace('startString', 'start');
    jsonEvents = jsonEvents.replace('endString', 'end');

    return jsonEvents;
  }

  global class calEvent {
    public String title {
      get;
      set;
    }
      //public Boolean allDay {get;set;}
      public String startString {
        get;
        set;
      }
      public String endString {
        get;
        set;
      }
      public String url {
        get;
        set;
      }
      public String location {
        get;
        set;
      }
      public String attendees {
        get;
        set;
      }
      public String seats {
        get;
        set;
      }
      public String descrip {
        get;
        set;
      }

      //public String className {get;set;}
    }

    global List < Campaign > updateEventTime(List < Campaign > elist) {
      for (Campaign erow: elist) {
        DateTime sdt = (erow.AS_Start_Time__c != null ? erow.AS_Start_Time__c.addHours(10) : erow.AS_Start_Time__c);
        DateTime edt = (erow.AS_End_Time__c != null ? erow.AS_End_Time__c.addHours(10) : erow.AS_End_Time__c);
        erow.AS_Start_Time__c = sdt;
        erow.AS_End_Time__c = edt;
      }

      return elist;
    }

  /*
   *Author : John Hope
   *Description : method to get all event via filter for this page
   *Date Created :
   *Last Modified By : 
   *Date Last Modified :
   *Param : 
   *Return : 
   */
   @remoteAction
   global static List < Campaign > filterCampaign(String filterString) {
    JSONCampaignFilter filterCampaign = (JSONCampaignFilter) JSON.deserialize(filterString, JSONCampaignFilter.class);
    String searchAll = filterCampaign.searchAll;
    String location = filterCampaign.location;
    List < String > eventType = filterCampaign.eventType;
    Date campaigndate = (String.isNotBlank(filterCampaign.campaigndate) ? Date.valueOf(filterCampaign.campaigndate) : null);
    List < String > interestgroup = filterCampaign.interestgroup;

    String theQueryArticleString = '';
        if(String.isnotBlank(searchAll)) {
            System.debug('searchAll : ' + searchAll);
            String searchStr = String.escapeSingleQuotes(searchAll)+'*';
        String searchQuery = 'FIND \'' + searchStr + '\' IN ALL FIELDS RETURNING Campaign(Id,AS_Region__c,Name,RecordType.Name,AS_Training_Plan_URL__c,AS_Event_URL__c,AS_Location__c,StartDate,EndDate,AS_Start_Time__c,AS_End_Time__c,AS_Total_Attendees__c,AS_Remaining_Seats__c,AS_Total_Capacity__c WHERE RecordType.Name = \'Event\' AND StartDate >= TODAY AND IsActive = true ORDER BY StartDate ASC )' ;
        System.debug('searchQuery : ' + searchQuery);
        List<List <sObject>> allFilterCampaign = search.query(searchQuery);
        System.debug('allFilterCampaign all : ' + allFilterCampaign);
      return (List<Campaign>) allFilterCampaign[0];
        } else {
        if (String.isBlank(location) && eventType.size() == 0 && campaigndate == null && interestgroup.size() == 0) {
          theQueryArticleString += 'Select Id, AS_Region__c, Name, RecordType.Name, AS_Training_Plan_URL__c, AS_Event_URL__c, AS_Location__c, StartDate, EndDate, AS_Start_Time__c, AS_End_Time__c, AS_Total_Attendees__c, AS_Remaining_Seats__c ,AS_Total_Capacity__c FROM Campaign WHERE RecordType.Name = \'Event\' AND IsActive = true AND EndDate >= TODAY AND Status NOT IN (\'Completed\',\'cancelled\') AND ';
        } else {
            theQueryArticleString += 'Select Id,AS_Region__c, Name,RecordType.Name, AS_Training_Plan_URL__c, AS_Event_URL__c,AS_Location__c,StartDate,EndDate,AS_Start_Time__c,AS_End_Time__c,AS_Total_Attendees__c,AS_Remaining_Seats__c,AS_Total_Capacity__c FROM Campaign WHERE RecordType.Name=\'Event\' AND IsActive=true AND EndDate >= TODAY AND Status NOT IN (\'Completed\',\'cancelled\') AND ';
                if (String.isNotBlank(location)) {
              theQueryArticleString += 'AS_Region__c=:location AND ';
            }
    
            if (eventType.size() > 0) {
              theQueryArticleString += 'Topic__c IN :eventType AND ';
            }
    
            if (campaigndate != null) {
              theQueryArticleString += 'StartDate=:campaigndate AND ';
            }
     
            if (interestgroup.size() > 0) {
              theQueryArticleString += 'Format__c INCLUDES (\'' + String.join(interestgroup, '\',\'') + '\') AND ';
            }
    
        }

      String finalQueryString = theQueryArticleString.trim().normalizeSpace();
      Integer strLength = finalQueryString.length();
      System.debug('theQueryArticleString' + finalQueryString);
      System.debug('theQueryArticleString :' + finalQueryString.substring(0,strLength-4));
      transient List < Campaign > allFilterCampaign = database.query(finalQueryString.substring(0, strLength-4) + ' ORDER BY StartDate ASC NULLS LAST');
      System.debug('allFilterCampaign :' + allFilterCampaign);
      return allFilterCampaign;
        }
    }


  /*
   *Author : John Hope
   *Description : method to get all event via global search in wordpress 
   *Date Created :
   *Last Modified By : 
   *Date Last Modified :
   *Param : String
   *Return : List<Campaign>
   */
   @remoteAction
   global static List < Campaign > globalfilterCampaign(String filterString) {
    transient List < Campaign > allFilterCampaign = new List < Campaign > ();
    if (String.isNotBlank(filterString)) {
      allFilterCampaign = (List < Campaign > )[FIND: String.escapeSingleQuotes(filterString) RETURNING Campaign(Id, Name, AS_Region__c, RecordType.Name, AS_Training_Plan_URL__c, AS_Event_URL__c, AS_Location__c, StartDate, EndDate, AS_Start_Time__c, AS_End_Time__c, AS_Total_Attendees__c, AS_Remaining_Seats__c WHERE RecordType.Name = 'Event' 
      AND IsActive = true AND EndDate >= TODAY AND Status NOT IN ('Completed','cancelled') ORDER BY StartDate DESC NULLS LAST)][0];
    }
    return allFilterCampaign;
  }

  /*
   *Author : John Hope
   *Description : wrapper class to get all filter value for campaign.
   *Date Created :
   *Last Modified By : 
   *Date Last Modified :
   *Param : 
   *Return : 
   */
  public class JSONCampaignFilter {
    public String location {
      set;
      get;
    }
    public List < String > eventType {
      set;
      get;
    }
    public String campaigndate {
      set;
      get;
    }
    public List < String > interestgroup {
      set;
      get;
    }
    public String searchAll {
      set;
      get;
    }
  }
}