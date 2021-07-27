public with sharing class AsCourseConfirmationFlows {

    public Flow.Interview.CourseConfirmation myFlow { get; set; }
//  public Flow.Interview.RTO_Course_Confirmation_Flow rtoMyFlow { get; set; }

    public String productId {get;set;}
    public string accountId {get;set;}
    public string opportunityId {get;set;}
    //https://psa-org--staging--c.cs6.visual.force.com/apex/AsCourseConfirmationFlows?accId=001N000001JwP6o&prodId=01tN0000004rB6l

    public AsCourseConfirmationFlows() {
        productId = apexpages.currentpage().getparameters().get('prodId');
        accountId = apexpages.currentpage().getparameters().get('accId');
        opportunityId = apexpages.currentpage().getparameters().get('oppid');
    } 

    public String getmyID() {
        if (myFlow==null) return '';
        else return myFlow.OpportunityId;
    } 

    public PageReference getOID(){ 
        String oppId = '';
        oppId = getmyID();
        PageReference p = new PageReference('/apex/PaymentPage?oppId='+getmyID());
                p.setRedirect(true);
                return p;
    } 
}