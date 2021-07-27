/*
* Author: John Hope 
* Created: Last 2017
* Last Updated Date: March 2020
* Last Update by: Danryl T. Carpio
* Description: Roll up payment object amount and update Opportunity paid amount field
* and should not trigger when Opportunity is Online Shop
*/

trigger AS_ppaymentRollup on ASPHPP__Payment__c (after insert, after update) {
	
	system.debug('AS_ppaymentRollup trigger is running...');
	
	if(as_checkRecursive.runOnce_AS_ppaymentRoll())
    { 
		system.debug(' as_checkRecursive inside is running...');

		// process rollup
		AS_ppaymentRollupHandler.processTrigger( Trigger.new );

    }
		
}