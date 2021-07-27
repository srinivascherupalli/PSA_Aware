global with sharing class DL_Fax_Update implements Schedulable{

    global void execute(SchedulableContext sc){
        List<fax__c> faxes = [SELECT Id, GoFax_Ref_ID__c, Status__c FROM Fax__c WHERE Status__c = '' OR Status__c = null OR Status__c = 'Queued for Transmission..'];

        List<String> faxIDs = new List<String>();

        for(Fax__c fax : faxes){
            faxIDs.add(fax.GoFax_Ref_ID__c);
        }

        if(faxIDs.Size() > 0){ 
            DL_Fax.faxStatusProxy(faxIDs);
        }

        else{
            String message = 'No Faxes to Update';
            System.debug(message);
        }

    }

}