public with sharing class ASUpdateSentEnrollment {
    
    public Enrolment_Form__c recID { get; set; }

    public ASUpdateSentEnrollment(ApexPages.StandardSetController controller){}
    public ASUpdateSentEnrollment(ApexPages.StandardController controller){
        
        recID = (Enrolment_Form__c)controller.getRecord();	
        
    }
    
    public PageReference redirectVF(){
        
        Enrolment_Form__c updaterec = new Enrolment_Form__c();
        updaterec.Id = recID.Id;
        updaterec.AS_Send_enrollment__c = true;
        update updaterec;
        
        PageReference pageRef = new PageReference('/'+recID.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
}