public class AS_paymentThankYouPage {

	public String theOpportunityId {get;set;}

	public AS_paymentThankYouPage() {
	}

	public void updateStudentOpp(){
		system.debug('mThank You!');
		theOpportunityId = ApexPages.currentPage().getParameters().get('oppId');

		if(String.isNotBlank(theOpportunityId)){
			system.debug('mUPDATE STUDENT OPPORTUNITY !!!');
			List<Opportunity> listOpp = [Select Id,Name,StageName from Opportunity where Id = :theOpportunityId];
			Opportunity opp = new Opportunity();
			opp.Id = listOpp[0].Id;
			opp.StageName = 'Closed Won';
			update opp;
		}
		
	}
}