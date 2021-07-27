@isTest 
public class CPQ_RenewContractsBatchTest 
{
    static testMethod void testauto() 
    {
        //SELECT ITP_Enddate__c, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c, Id FROM Contract WHERE SBQQ__RenewalForecast__c = FALSE AND SBQQ__RenewalQuoted__c = FALSE AND (EndDate = TODAY  )'
        
        account testacc= new account(name='test');
        insert testacc;
        
        date startdate=system.today().addmonths(-1);
        startdate=startdate.adddays(1);
        
        Contract testcontract= new Contract(  AccountID = testacc.Id, startdate=startdate, ContractTerm=1);
        insert testcontract;
   
        CPQ_RenewContractsBatch obj= new CPQ_RenewContractsBatch();
   
        //        testcontract.Status = 'Aktiviert';
        
        
        Test.startTest();
            CPQ_RenewContractsBatch batchObject = new CPQ_RenewContractsBatch();
            Id batchId = Database.executeBatch(batchObject, 1);
        
            CPQ_RenewSchedule testsch= new CPQ_RenewSchedule ();      
            String sch = '0 0 23 * * ?';
            system.schedule('Test', sch, testsch);        

        Test.stopTest();

        system.AssertEquals(1, [select id from opportunity].size());    //Should create a renewal opp
    }
}