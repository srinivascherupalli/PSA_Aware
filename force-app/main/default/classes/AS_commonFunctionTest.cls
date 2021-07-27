@isTest
private class AS_commonFunctionTest {
	
	@isTest static void test_method_one() {
		AS_commonFunction.generateRandomString(10);
		AS_commonFunction.generateRandomIntString(5);
		AS_commonFunction.runOnce();
		AS_commonFunction.runOrdIteTriggerOnce();
		AS_commonFunction.runOrdTriggerOnce();
		AS_commonFunction.isSandbox();
		AS_commonFunction.ownerId();
		AS_commonFunction.convertListStrToStr(new List<String>{'test'});
		AS_commonFunction.runOppCloseWonOnce();
		AS_commonFunction.runupdateAccountOnce();
	}



}