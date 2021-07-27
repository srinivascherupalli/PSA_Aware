public class FlowController {
    
    public Flow.Interview.AS_Test_Flow myFlow { get; set; }
    
    public String getmyID() {
        if (myFlow==null) return '';
        else return myFlow.Opp_id;
    }
    
    public PageReference getOID(){
        PageReference p = new PageReference('/apex/PaymentPage?oppID='+getmyID());
        p.setRedirect(true);
        return p;
    }
    
}