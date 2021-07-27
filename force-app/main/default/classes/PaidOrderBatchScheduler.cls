global class PaidOrderBatchScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
       ProcessPaidOrdersBatch b = new ProcessPaidOrdersBatch();
		database.executeBatch(b, 1);
   }
}