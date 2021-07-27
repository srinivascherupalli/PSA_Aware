public with sharing class DL_Events {

    @AuraEnabled
    public static List<Campaign> GetCampaigns(Boolean showClosed) {
        Date date_weekAgo = Date.today().addDays(-7);
        DateTime datetime_weekAgo = Datetime.now().addDays(-7);

        List<Campaign> campaigns = new List<Campaign>();

        if(showClosed){
            campaigns = [SELECT Id,Name,Status,Type,AS_Start_Time__c,Format__c
                        FROM Campaign 
                        WHERE Status IN ('Planned','In Progress','Completed')
                        AND Type IN ('Event','Seminar / Conference')
                        AND ParentId = null
                        AND (EndDate > :date_weekAgo OR AS_End_Time__c > :datetime_weekAgo)
                        ORDER BY Status DESC];
        }

        else{
            campaigns = [SELECT Id,Name,Status,Type,AS_Start_Time__c,Format__c
                        FROM Campaign 
                        WHERE Status IN ('Planned','In Progress')
                        AND Type IN ('Event','Seminar / Conference')
                        AND ParentId = null
                        AND (EndDate > :date_weekAgo OR AS_End_Time__c > :datetime_weekAgo)
                        ORDER BY Status];
        }

        return campaigns;
    }


    @AuraEnabled
    public static List<Campaign> GetCampaignSessions(String campaignId, String showClosed) {
        List<Campaign> campaignSessions = new List<Campaign>();

        if(showClosed == 'true'){
            campaignSessions = [SELECT Id,Name,Status,Type,AS_Start_Time__c,Format__c,StartDate
                                FROM Campaign 
                                WHERE ParentId = :campaignId
                                ORDER BY Status DESC,AS_Start_Time__c];
        }

        else if(showClosed == 'false'){
            campaignSessions = [SELECT Id,Name,Status,Type,AS_Start_Time__c,Format__c,StartDate
                                FROM Campaign 
                                WHERE ParentId = :campaignId
                                AND Status IN ('In Progress','Planned')
                                ORDER BY Status,AS_Start_Time__c];
        }

        else{
            campaignSessions = [SELECT Id,Name,Status,Type,AS_Start_Time__c,Format__c,StartDate
                                FROM Campaign 
                                WHERE ParentId = :campaignId
                                AND Status IN ('In Progress','Planned','Completed')
                                ORDER BY AS_Start_Time__c];
        }
        
        return campaignSessions;
    }



    @AuraEnabled
    public static String GetImageURL(String campaignId){
        Campaign campaign = [SELECT Id,Name,CampaignImageId FROM Campaign WHERE Id = :campaignId];
        ContentDocument contentDocument = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id = :campaign.CampaignImageId];

        return contentDocument.LatestPublishedVersionId != null ? '/sfc/servlet.shepherd/version/download/'+contentDocument.LatestPublishedVersionId : null;
    }


    @AuraEnabled
    public static Contact GetMember(String psaId){
        String conferenceID = psaId.contains('-') ? psaId : null;
        Contact attendee_Contact = new Contact();

        try{
            if(conferenceID != null){
                attendee_Contact = [SELECT Id, Account.PSA_PSA_ID__c, Account.Conference_ID__c, Account.Name FROM Contact WHERE Account.Conference_ID__c = :conferenceID];
            }

            else{
                attendee_Contact = [SELECT Id, Account.PSA_PSA_ID__c, Account.Name FROM Contact WHERE Account.PSA_PSA_ID__c = :psaId];
            }
            
            System.debug(attendee_Contact);
        }

        catch(Exception e){
            System.debug(e.getMessage());
        }

        return attendee_Contact != null? attendee_Contact : null;
    }


    
    @AuraEnabled
    public static String SaveRFIDNumber(String psaId, String rfidNumber){
        String response;
        String conferenceID = psaId.contains('-') ? psaId : null;
        Account attendeeAccount = new Account();
        Account RFID_AlreadyExists_Account = new Account();
        System.debug(RFID_AlreadyExists_Account);

        try{
            if(conferenceID != null){
                attendeeAccount = [SELECT Id,RFID_Number__c,PSA_PSA_ID__c,Conference_ID__c FROM Account WHERE Conference_ID__c = :conferenceID];
            }

            else{
                attendeeAccount = [SELECT Id,RFID_Number__c,PSA_PSA_ID__c FROM Account WHERE PSA_PSA_ID__c = :psaId];
            }

            RFID_AlreadyExists_Account = [SELECT Id,RFID_Number__c,PSA_PSA_ID__c FROM Account WHERE RFID_Number__c = :rfidNumber LIMIT 1];
        }

        catch(Exception e){
            System.debug(e.getMessage());
        }
    

        

        
        if(rfidNumber != null){

            if(RFID_AlreadyExists_Account.Id == null){
                attendeeAccount.RFID_Number__c = rfidNumber;
                update attendeeAccount;
                response = 'Success';
            }
            
            else{
                response = 'RFID Already Exists On ' + RFID_AlreadyExists_Account.PSA_PSA_ID__c;
            }
        }
            
        else{
            response = 'Error';
        }
        

        return response;
    }
      

    @AuraEnabled
    public static String ProcessScan_psaId(Boolean scanIn, String psaId, ID campaignId){
        String response;
        CampaignMember attendee_CampaignMember = new CampaignMember();
        System.debug(campaignId);

        try{

            attendee_CampaignMember = [SELECT Id,LeadOrContactId,Status,CampaignId,Contact.Account.PSA_PSA_ID__c, Contact.Account.Name 
                                        FROM CampaignMember 
                                        WHERE CampaignId = :campaignId 
                                        AND Contact.Account.PSA_PSA_ID__c = :psaId];
            System.debug(attendee_CampaignMember);
        }

        catch(Exception e){
            System.debug(e.getMessage());
        }


        if(attendee_CampaignMember != null){

            if(scanIn == true){

                if(attendee_CampaignMember.Status == 'Registered' || attendee_CampaignMember.Status == 'Withdrawn'){
                    attendee_CampaignMember.Status = 'Attending';
                    update attendee_CampaignMember;
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Attending';
                }

                else if(attendee_CampaignMember.Status == 'Attending'){
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Is Already Attending';
                }

                else if(attendee_CampaignMember.Status == 'Checked In'){
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Is Already Checked In';
                }

                else{
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Not Registered for Event';
                }
            }

            else{

                if(attendee_CampaignMember.Status == 'Attending'){
                    attendee_CampaignMember.Status = 'Withdrawn';
                    update attendee_CampaignMember;
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Scanned OUT';
                }

                else if(attendee_CampaignMember.Status == 'Withdrawn' || attendee_CampaignMember.Status == 'Registered'){
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Is Already Scanned OUT';
                }

                else if(attendee_CampaignMember.Status == 'Checked In'){
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Is Already Checked In';
                }

                else{
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Not Registered for Event';
                }
            }
        }

        else{
            response = 'Error: Cannot Find Member ' + psaId;
        }

        return response;
    }

    
    @AuraEnabled
    public static string ProcessScan_ID(Boolean scanIn, String idNumber, ID campaignId){
        String response;
        CampaignMember attendee_CampaignMember = new CampaignMember();
        String psaId;

        if(idNumber.contains('-')){
            try{
                attendee_CampaignMember = [SELECT Id,ContactId,Status,CampaignId,Conference_ID__c,Contact.Account.PSA_PSA_ID__c,Contact.Account.Name 
                                            FROM CampaignMember 
                                            WHERE Conference_ID__c = :idNumber 
                                            AND CampaignId = :campaignId];
                psaId = attendee_CampaignMember.Contact.Account.PSA_PSA_ID__c;

                System.debug(attendee_CampaignMember);
                System.debug(psaId);
            }

            catch(Exception e){
                System.debug(e.getMessage());
            }
        }

        else{
            try{
                attendee_CampaignMember = [SELECT Id,ContactId,Status,CampaignId,RFID_Number__c,Contact.Account.PSA_PSA_ID__c,Contact.Account.Name 
                                            FROM CampaignMember 
                                            WHERE RFID_Number__c = :idNumber 
                                            AND CampaignId = :campaignId];
                psaId = attendee_CampaignMember.Contact.Account.PSA_PSA_ID__c;

                System.debug(attendee_CampaignMember);
                System.debug(psaId);
            }

            catch(Exception e){
                System.debug(e.getMessage());
            }
        }

        if(attendee_CampaignMember != null){
            if(scanIn == true){

                if(attendee_CampaignMember.Status == 'Registered' || attendee_CampaignMember.Status == 'Withdrawn'){
                    attendee_CampaignMember.Status = 'Attending';
                    update attendee_CampaignMember;
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Attending';
                }

                else if(attendee_CampaignMember.Status == 'Attending'){
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Is Already Attending';
                }

                else if(attendee_CampaignMember.Status == 'Checked In'){
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Is Already Checked In';
                }

                else{
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Not Registered for Event';
                }
            }

            else{

                if(attendee_CampaignMember.Status == 'Attending'){
                    attendee_CampaignMember.Status = 'Withdrawn';
                    update attendee_CampaignMember;
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Scanned OUT';
                }

                else if(attendee_CampaignMember.Status == 'Registered' || attendee_CampaignMember.Status == 'Withdrawn'){
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Is Already Scanned OUT';
                }

                else if(attendee_CampaignMember.Status == 'Checked In'){
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Is Already Checked In';
                }

                else{
                    response = attendee_CampaignMember.Contact.Account.Name + '('+psaId+')' + ' Not Registered for Event';
                }
            }
        }

        else{
            response = 'Error: Cannot Find Member ' + psaId;
        }

        return response;
    }
    

    public static void DeleteRFIDNumbers(Id parentCampaignId){
        List<CampaignMember> members = [SELECT Id,Contact.Account.Id,CampaignId FROM CampaignMember WHERE CampaignId = :parentCampaignId];
        List<Id> memberAccountIds = new List<Id>();
        
        for(CampaignMember member : members){
            memberAccountIds.add(member.Contact.Account.Id);
        }

        if(memberAccountIds.size() > 0){
            List<Account> memberAccounts = [SELECT Id,RFID_Number__c FROM Account WHERE Id IN :memberAccountIds];
            for(Account accnt : memberAccounts){
                accnt.RFID_Number__c = null;
            }

            update memberAccounts;
        }
    }
}