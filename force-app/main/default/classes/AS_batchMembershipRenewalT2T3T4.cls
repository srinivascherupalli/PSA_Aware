public class AS_batchMembershipRenewalT2T3T4  implements Database.Batchable < sObject > , Database.Stateful{
    
    String query; 
  
    public string ISCLOSEDWON ;
    public string ISCLOSEDLOST ;
    public AS_batchMembershipRenewalT2T3T4() {
        for(OpportunityStage oppStage : [SELECT IsClosed,IsWon,MasterLabel FROM OpportunityStage ]){
             if( oppStage.IsClosed == true  && oppStage.IsWon == true ){
                ISCLOSEDWON = oppStage.MasterLabel ;
             }
             if( oppStage.IsClosed == true  && oppStage.IsWon == false ){
                ISCLOSEDLOST = oppStage.MasterLabel ; 
             }
        }
    } 
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        Membership_End_Date_Renewal__c medr = Membership_End_Date_Renewal__c.getInstance();
        set< Date > dateCarteriaSet = new set< Date >();        
                if( medr.T2__c != null && medr.T2__c>=0) {
                    dateCarteriaSet.add( system.today().addDays(  ( Integer.valueOf( medr.T2__c ) != null ? Integer.valueOf( medr.T2__c ) : 0 ) ) );
                }
        
        if( medr.T3__c != null && medr.T3__c>=0) {
            dateCarteriaSet.add( system.today().addDays(  ( Integer.valueOf( medr.T3__c )  != null ? Integer.valueOf( medr.T3__c ) : 0 ) ) );  
        }
        
        if( medr.T4__c != null && medr.T4__c>=0) {
            dateCarteriaSet.add( system.today().addDays(  ( Integer.valueOf( medr.T4__c )   != null ? Integer.valueOf( medr.T4__c ) : 0 ) ) );  
        }
        
        system.debug( 'dateCarteriaSet ==>'+ dateCarteriaSet );

        String type = 'Member';
        String memberStatus = 'Current'; 
        String QuerySTring = 'SELECT '+
                             'Id,AS_Auto_Renew__c,Account__r.PersonContactId ,AS_End_Date__c,AS_Frequency__c,'+
                             'AS_Membership_Span__c,AS_Membership_Status__c,'+
                             'AS_Opportunity__c,AS_Payment_Source__c,'+
                             'AS_Product__c,AS_Quantity__c,'+
                             'AS_Start_Date__c,AS_Type__c,Name '+
                             ',AS_Opportunity__r.Name, AS_Opportunity__r.StageName '+
                             'FROM AS_Subscription__c WHERE (AS_Opportunity__r.StageName != :ISCLOSEDWON and AS_Opportunity__r.StageName != :ISCLOSEDLOST ) and AS_End_Date__c IN :dateCarteriaSet AND AS_Membership_Status__c =:memberStatus AND AS_Type__c =:type';
        
        if(dateCarteriaSet.size() > 0) {
            return Database.getQueryLocator(QuerySTring);
        } else {
            return null;
        }
        
        
    }

    public void execute(Database.BatchableContext BC, List<AS_Subscription__c> scope) {
        
        list< AS_Subscription__c > subOppSendAuto = new list< AS_Subscription__c >();
        list< AS_Subscription__c > subOppSendRenew  = new list< AS_Subscription__c >();
        
        List<OrgWideEmailAddress> owea = [select Id,Address from OrgWideEmailAddress where Address = 'noreply@psa.org.au'];
     
        system.debug(' scope debug ==> '+scope );

        for( AS_Subscription__c subscription : scope  ) {
            if( subscription.AS_Auto_Renew__c ){
                subOppSendAuto.add(subscription);
            }
            else { 
                subOppSendRenew.add(subscription );
            } 
        } 

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='AS_Send_Renewal_Notice_Email1'];
        EmailTemplate et2 = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='PSA_Send_Email_of_Automatic_Renewal'];
        
        for(AS_Subscription__c sub : subOppSendAuto ){
       
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et2.Id);
            mail.setTargetObjectId( sub.Account__r.PersonContactId  );
            mail.setWhatId( sub.Id  );
           
            if(owea.size()>0) {
                mail.setorgWideEmailAddressId(owea[0].Id);
            }
           
            mail.setSaveAsActivity(false);
            allmsg.add( mail ); 
     
        }
    
        for(AS_Subscription__c sub : subOppSendRenew ){
       
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et.Id);
            mail.setTargetObjectId(sub.Account__r.PersonContactId);
                    mail.setWhatId(sub.Id);
            if(owea.size()>0) {
                mail.setorgWideEmailAddressId(owea[0].Id);
            }
            
            mail.setSaveAsActivity(false);
            allmsg.add( mail ); 
 
        }

       Messaging.sendEmail(allmsg,false);      
     
    }
     
    public void finish(Database.BatchableContext BC) {   
        
        

      // 

        
    }

}