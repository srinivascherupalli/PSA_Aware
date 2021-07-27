public class sampleJRC {
  /*
  Author : Jet Compayan
  Description:  This class is not used 
  last Date modified : Feb 28 2018
  */
   

   
     //  public Flow.Interview.PSA_Membership_Sign_Up myFlow { get; set; }
     //  public Transient Blob theFileHander {get;set;}
     //  public String theFileName {get;set;}
     //  public String theAccId {get;set;}
      
     //  public sampleJRC(){
     //  }
      
     // public void upload() {
           
     //      theAccId = myFlow.AccountID;
     //      try{
     //          if( theFileHander.size() != 1024 * 1024 * 1 ){
     //              Attachment attachment = new  Attachment();
     //              attachment.OwnerId = UserInfo.getUserId();
     //              attachment.body = theFileHander; 
     //              attachment.Name = theFileName;
     //              attachment.ParentId = theAccId; // the record the file is attached to
     //              attachment.IsPrivate = true; 
     //              insert attachment;
     //              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Successfully Upload the file.'));
     //          }else{
     //              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'file too large it should maximum of 10MB.'));
     //          }
              
     //      }catch(exception  er){
     //          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, er + ' or  file too large it should maximum of 10MB.'));
     //      }

     //  } 
    
      
     //  public String getmyID() {
     //      if (myFlow==null) return '';
     //      else return myFlow.OpportunityID;
     //  } 
   

     //  public PageReference getOID(){
     //      String oppId = '';
     //      oppId = getmyID();
     //      system.debug('mOPP : '+oppId);
     //      List<Opportunity> listOpp = new List<Opportunity>();
     //      List<String> listOpptoCloseWon = new List<String>();//Jan 18

     //      if(String.isNotBlank(oppId)){
     //          listOpp = [Select Id, Name, AS_Product__r.Name, AS_Product__c from Opportunity where Id = :getmyID()];
     //          if( listOpp[0].AS_Product__r.Name.tolowerCase().trim() == 'student'){
     //              //PageReference p = new PageReference('http://www.psa.org.au/');
     //              //Opportunity opp = new Opportunity();
     //              //opp.Id = listOpp[0].Id;
     //              //opp.StageName = 'Closed Won';
     //              //update opp;

     //              PageReference p = new PageReference('/apex/paymentThankYouPage?oppId='+getmyID());
     //              p.setRedirect(true); 
     //              return p;  
     //          }else{ // if not student
   
     //              PageReference p = new PageReference('/apex/PaymentPage?oppId='+getmyID());
     //              p.setRedirect(true);
     //              return p;
     //          }
     //      }else{
     //          system.debug('kELSE !!!');
     //          PageReference p = new PageReference('/apex/PaymentPage?oppId='+getmyID());
     //          p.setRedirect(true);
     //          return p;
     //      }

     //  }

     //  @AuraEnabled 
     //  public static String checkIfStudent(String oppId){  
     //      system.debug('mOpportunity : '+oppId);
     //      //Boolean ifStudent = false;
     //      String stringUrl = '';
     //      List<Opportunity> listOpp = [Select Id, Name, StageName, AccountId, Owner.Name, Account.Owner.Name, AS_Product__r.Name, AS_Product__c from Opportunity where Id = :oppId];
     //          if( listOpp[0].AS_Product__r.Name.tolowerCase().trim() == 'student'){
     //              //ifStudent = true;
     //              //stringUrl = '/apex/PaymentThankYouPage?oppId='+oppId;

     //              Opportunity opp = new Opportunity();
     //              opp.Id = listOpp[0].Id;
     //              if(listOpp[0].Owner.Name.toLowerCase() == 'membership sign up site guest user') {
     //                  opp.OwnerId = AS_commonFunction.ownerId();
     //                  opp.StageName = 'Closed Won';
     //              }
     //              update opp;

     //              if(listOpp[0].Account.Owner.Name.toLowerCase() == 'membership sign up site guest user') {
     //                  Account updateAcc = new Account();
     //                  updateAcc.Id = listOpp[0].AccountId;
     //                  updateAcc.OwnerId = AS_commonFunction.ownerId();
     //                  update updateAcc;
     //              }

     //              stringUrl = 'http://www.psa.org.au/';
     //          }else{
     //              stringUrl = '/apex/PaymentPage?oppId='+oppId;
     //          }
     //      system.debug('mCHECKER : '+stringUrl);
     //      return stringUrl;
     //  }
      
     //  /*
     //  Author : jrc 
     //  return url 
     //  aura-lightning component : AS_ProcessMemberPay
     //  */
     //  @AuraEnabled 
     //  public static String getSalesforceBaseUrl(){
     //    return System.URL.getSalesforceBaseURL().toExternalForm();   
     //  } 
  }