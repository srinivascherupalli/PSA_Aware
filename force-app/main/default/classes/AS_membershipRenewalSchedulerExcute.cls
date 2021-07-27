global class AS_membershipRenewalSchedulerExcute implements Schedulable{
    global void execute(SchedulableContext SC){
         
        AS_batchMembershipRenewalT1 T1 = new AS_batchMembershipRenewalT1();
        database.executeBatch(T1);
        
        //AS_batchMembershipRenewalT2T3T4 T2T3T4 = new AS_batchMembershipRenewalT2T3T4();
        //database.executeBatch(T2T3T4);
        
        AS_batchMembershipRenewalT5T6T7 T5T6T7 = new AS_batchMembershipRenewalT5T6T7();
        database.executeBatch(T5T6T7);
        
        AS_batchMembershipRenewalT8 wew = new AS_batchMembershipRenewalT8();
        database.executeBatch(wew);
        
        AS_batchMembershipRenewalEND TEND = new AS_batchMembershipRenewalEND();
        database.executeBatch(TEND);
    }
}