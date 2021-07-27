public class AS_massUpdateSubsStatus {
 	PageReference cancel;
    AS_Subscription__c[] records;
    public AS_massUpdateSubsStatus(ApexPages.StandardSetController sub) {
    	System.debug('sub : ' + sub.getSelected());
        records = (AS_Subscription__c[])sub.getSelected();
        cancel = sub.cancel();
    }
    public PageReference updateSubs() {
        System.debug('records : ' + records);
        for(AS_Subscription__c record: records) {
            record.AS_Membership_Status__c = 'Current';
            
        }
        System.debug('records : ' + records);
        update records;
        return cancel.setRedirect(true);
        
    }
}