public class CPQ_invokeAmendAPI
{
  /**/
  //final static string Memstatus = 'Expired';      
    
    @InvocableMethod(label='Amend' description='AmendAPI.')
    public static void ExpireAccounts(list<contract> contracts) 
    {
        system.debug('qqqqqqq ' +contracts[0].id);
        callCPQAPI(contracts[0].id);
    }
    
    static string getFreq (string cid) {
        list<contract> c= [select id , SBQQ__Order__r.pricebook2.name, SBQQ__Order__r.Opportunity.Pricebook2.name from contract where id=:cid];
        string billf='';
 

        if (c.size()>0) {     
            system.debug(c[0].SBQQ__Order__r.Opportunity.Pricebook2.name + ' wwwwww ' + c[0].SBQQ__Order__r.pricebook2.name);

            if (c[0].SBQQ__Order__r.Opportunity<>null) {
        
                if (c[0].SBQQ__Order__r.Opportunity.Pricebook2.name.contains('Month')) { billf='Monthly'; }
                else if (c[0].SBQQ__Order__r.Opportunity.Pricebook2.name.contains('Quarter')) { billf='Quarterly'; }
                else { billf='Annual'; }
            }
            else if (c[0].SBQQ__Order__r.pricebook2.name<>null) {
                if (c[0].SBQQ__Order__r.pricebook2.name.contains('Month')) { billf='Monthly'; }
                else if (c[0].SBQQ__Order__r.pricebook2.name.contains('Quarter')) { billf='Quarterly'; }
                else { billf='Annual'; }
            }
        }
        
        return billf;
    }
    
    @future(callout=true)
    public static void callCPQAPI( string con)
    {   
         // Perform a callout to an external service
        CPQ_AmenderAPI amender =new CPQ_AmenderAPI();
    
        //string billf=getFreq('8001m0000001Igw');
        string billf=getFreq(con );

        if (billf!=null){
            CPQ_QuoteModel qm=new CPQ_QuoteModel ();
            //qm = amender.load('8001m0000001Igw');
            qm = amender.load(con );
            SBQQ__Quote__c q = qm.record;
            q.SBQQ__PaymentTerms__c='Due on receipt';
            update q;
            
            /*
            list <CPQ_QuoteLineModel> qlm = qm.lineItems ; 
            SBQQ__QuoteLine__c liner= qlm[0].record ; 
            liner.SBQQ__Existing__c = false;
            liner.SBQQ__ChargeType__c='Recurring';
            liner.SBQQ__BillingFrequency__c=billf;
            liner.SBQQ__BillingType__c='Advance';
            
            update liner;
            */
            //ORDER opp
            opportunity opp=[select id, SBQQ__Ordered__c , SBQQ__AmendedContract__r.Auto_Renew__c from opportunity WHERE id=: q.SBQQ__Opportunity2__c ];
            if (opp.SBQQ__AmendedContract__r.Auto_Renew__c) {
                opp.SBQQ__Ordered__c =true;
                update opp;
            }
            
            
        }    
        //System.debug('zzzzzzzzz ' + q);
    }

}