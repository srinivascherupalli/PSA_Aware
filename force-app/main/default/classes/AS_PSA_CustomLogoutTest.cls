@isTest
public class AS_PSA_CustomLogoutTest {
    
    static testMethod void myUnitTest() {
        
        PSA_Community__c psacom = new PSA_Community__c();
        psacom.Name = 'Websetting';
        psacom.URLS__c = 'https://psastaging.alphasys.com.au/wp-json/wp/logout, https://moodle.alphasys.com.au/webservice/rest/server.php?wstoken=0d83b75e50e68fa72b4189b3da389c74&wsfunction=local_psa_integration_user_logout&moodlewsrestformat=json';
        insert psacom;
        
        
        PageReference myVfPage = Page.AS_PSA_CustomLogoutCallback;
        test.setCurrentPage(myVfPage);
        
        ApexPages.currentPage().getParameters().put( 'myParam', 'test@alphasys.com.au' );
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new AS_PSA_CustomLogoutHttpCalloutMock());
        AS_PSA_CustomLogoutController controller = new AS_PSA_CustomLogoutController();
        controller.pushValue();
        test.stopTest();
       
    }
    
}