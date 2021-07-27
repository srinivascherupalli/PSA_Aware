@isTest (SeeAllData=true)
public class testGuestTest 
{
    static testMethod void testauto() 
    {
        //string idp = [select id from profile where id='00e7F000000Zqki'].id;
        user u = [select id from user where id='0057F000004FE1s'];
        
        //guest - 0057F000004Dw11
        //testprofile - 0057F000004FE1s
    
        string oppid='';
    
        System.runAs(u) {
              // The following code runs as user 'u'
              System.debug('Current User: ' + UserInfo.getUserName());
              System.debug('Current Profile: ' + UserInfo.getProfileId());
              
              system.debug('gggggg ' + Schema.sObjectType.SBQQ__Quote__c.isAccessible() );
              
              
              
              orderitem oi = new orderitem(product2id='01t7F0000048bWT', orderid='8017F000001jKCs', PricebookEntryId='01u7F000004K4KVQA0',UnitPrice=635.45, Quantity=1.00, AS_Discount__c=null, AS_Tax_Rate__c=10, AS_Taxable__c=true, Description=null);
              
              //try {
                  insert oi;
                  
               
                  
                  
              //}
              //catch(exception e) {
              
                //system.debug('eeeeeeeee ' + e.getmessage());
              //}
              
              

              
              /*
              list<opportunity> allopp= [select Pricebook2Id, AS_Payment_Amount__c, RecordTypeId,
                      id,name, stagename, accountid, closedate,AS_Product__c   
                       from opportunity where stagename='closed won' order by createddate desc limit 9];
              
              list<blng__RevenueRecognitionRule__c> bl=[select id from blng__RevenueRecognitionRule__c];
          
              list<order> o = [select id from order limit 5];
              
              system.debug('sssssss ' + allopp);
              
              opportunity opp=new opportunity();
              opp= allopp[0].clone(false,true);
              opp.Pricebook2Id  ='01s7F00000IRO7O';
              opp.AS_Product__c ='01t7F0000048bWT';
              insert opp;
              oppid=opp.id;
              
              product2 prod=[select id , blng__RevenueRecognitionRule__c, blng__TaxRule__c, SBQQ__BillingType__c, 
              blng__BillingRule__c, SBQQ__ChargeType__c, SBQQ__BillingFrequency__c from product2 where id='01t7F0000048bWT'];
              
              
              pricebook2 pbe=[select id from pricebook2 where id='01s7F00000IRO7O'];
              system.debug('ppppppp '+pbe);
              */
              /*
              list<opportunitylineitem> oli =[select Product2Id , UnitPrice, quantity, AS_Discounted_Products__c, AS_Membership_Type__c
                                              FROM opportunitylineitem WHERE opportunityid= :allopp[0].id limit 1];
              opportunitylineitem olinew= new opportunitylineitem();
                olinew.quantity=1;
              olinew.opportunityid=oppid;
                            insert olinew;
              olinew.Product2Id = '01t7F0000048bWT';
              olinew.UnitPrice=123;
              
              
              olinew.AS_Membership_Type__c='a1M7F000001u24B';
    
              opp.stagename='Closed Won';
              
              update opp;
              */
        } //end runas
        //system.debug('ffffff ' + [select owner.name from opportunity where id=:oppid]);
        
    
    }
}