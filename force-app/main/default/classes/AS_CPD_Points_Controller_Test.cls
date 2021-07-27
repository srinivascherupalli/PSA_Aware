@IsTest(SeeAllData=true)
public class AS_CPD_Points_Controller_Test {

    static AS_CPD_Points_Parser.StrPoints strPoints;
    
    static testMethod void testUnit() {
        strPoints = new AS_CPD_Points_Parser.StrPoints();

        LMS_Instance__c li = new LMS_Instance__c();
        li.Token__c         = '6d6e009a7317681cad15d8780f1d27cf';
        li.URL__c = 'https://moodle.alphasys.com.au/webservice/rest/server.php';
        li.Domain_URL__c = 'https://moodle.alphasys.com.au/webservice/rest/server.php';
        li.Status__c = 'Active';
        li.Type__c = 'Moodle';
        insert li;
        System.assert(li != null, 'LMS instance is empty');
        
        LMS_Course__c lc = new LMS_Course__c();
        lc.Name = 'test lc';
        lc.Status__c = 'Active';
        lc.LMS_Instance__c = li.Id;
        insert lc;
        System.assert(lc != null, 'LMS course is empty');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
		    acc.FirstName = 'AlphaSys';
		    acc.LastName = 'UserAccount12345';
		    acc.recordTypeId = personAccRecId;
		    acc.PersonEmail = 'memberuser@testorg.com';
		    insert acc;
    
		    // Create a unique UserName
		    String uniqueUserName = 'memberuser2' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
        Account acc1 = [SELECT Id,PersonContactId FROM Account WHERE Id =:acc.Id];
        
        User u = new User(Alias = 'standt', Email='memberuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='johnmongrel', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        ContactId = acc1.PersonContactId,
        TimeZoneSidKey='America/Los_Angeles',
        isActive = true,
        UserName=uniqueUserName);
        insert u;
        
        System.assert(u != null, 'User is empty');
        
        LMS_User__c lu = new LMS_User__c();
        lu.FirstName__c = u.FirstName;
        lu.LastName__c = u.LastName;
        lu.Email__c = u.Email;
        lu.LMS_Instance__c = li.Id;
        insert lu;
        System.assert(lu != null, 'LMS user is empty');
        
        LMS_Course_Enrolment__c lce = new LMS_Course_Enrolment__c();
        lce.LMS_Instance__c = li.Id;
        lce.LMS_Course__c = lc.Id;
        lce.LMS_User__c = lu.Id;
        insert lce;
        System.assert(lce != null, 'LMS course enrolment is empty');

        Learning__c l = new Learning__c();
        l.Name = 'test l';
        l.AS_Group_1_CPD__c = 100;
        l.AS_Group_2_CPD__c = 200;
        l.LMS_Instance__c = li.Id;
        l.LMS_Course__c = lc.Id;
        l.Published__c = true;
        insert l;
        System.assert(l != null, 'Learning is empty');
        
        Training_Plan__c tp = new Training_Plan__c();
        tp.Name = 'test tp';
        tp.Status__c = 'Active';
        tp.Type__c = 'Member Benefit';
        tp.Enable_Self_Registration__c = true;
        tp.Self_Registration_Access__c = 'External';
        insert tp;
        System.assert(tp != null, 'Training Plan is empty');
        
        Training_Plan_Section__c tps = new Training_Plan_Section__c();
        tps.Name = 'test tps';
        tps.Training_Plan__c = tp.Id;
        insert tps;
        System.assert(tps != null, 'Training Plan Section is empty');
        
        Training_Plan_Section_Item__c tpsi = new Training_Plan_Section_Item__c();
        tpsi.Learning__c = l.Id;
        tpsi.Training_Plan_Section__c = tps.Id;
        insert tpsi;
        System.assert(tpsi != null, 'Training Plan Section Item is empty');

        Training_Plan_Assignment__c tpa = new Training_Plan_Assignment__c();
        tpa.Training_Plan__c = tp.Id;
        tpa.User__c = u.Id;
        insert tpa;
        System.assert(tpa != null, 'Training Plan Assignment is empty');

        Training_Plan_Section_Assignment__c tpsa = new Training_Plan_Section_Assignment__c();
        tpsa.Training_Plan_Assignment__c = tpa.Id;
        tpsa.Training_Plan_Section__c = tps.Id;
        tpsa.User__c = u.Id;
        insert tpsa;
        System.assert(tpsa != null, 'Training Plan Section Assignment is empty');

        Learning_Assignment__c la = new Learning_Assignment__c();
        la.Learning__c = l.Id;
        la.Training_Plan__c = tp.Id;
        la.Training_Plan_Section__c = tps.Id;
        la.Training_Plan_Section_Item__c = tpsi.Id;
        la.Training_Plan_Section_Assignment__c = tpsa.Id;
        la.LMS_Instance__c = li.Id;
        la.LMS_Course_Enrolment__c = lce.Id;
        la.User__c = u.Id;
        insert la;
        System.assert(la != null, 'Learning Assignment is empty');
        
        Test.startTest();
            strPoints.courseId = lc.Id;
            strPoints.userId = lu.Id;
            strPoints.courseResult = 'a';
			System.assert(strPoints != null, 'strPoints (a) is empty');
            executeMethod(strPoints);    

            strPoints.courseId = lc.Id;
            strPoints.userId = lu.Id;
            strPoints.courseResult = 'b';
        	System.assert(strPoints != null, 'strPoints (b) is empty');
            executeMethod(strPoints);

            strPoints.courseId = lc.Id;
            strPoints.userId = lu.Id;
            strPoints.courseResult = 'c';
        	System.assert(strPoints != null, 'strPoints (c) is empty');
            executeMethod(strPoints);

            strPoints.courseId = '';
            strPoints.userId = lu.Id;
            strPoints.courseResult = 'c';
        	System.assert(strPoints != null, 'strPoints (c-2) is empty');
            executeMethod(strPoints);
        Test.stopTest();
    }
    
    private static void executeMethod(AS_CPD_Points_Parser.StrPoints strPoints){
        String jsonRequest = JSON.serialize(strPoints);
        
        //Test.startTest();

        RestRequest req   = new RestRequest();
        RestResponse res  = new RestResponse();

        req.addHeader('Content-Type', 'application/json');
        req.requestURI    = '/services/apexrest/donation/';
        req.httpMethod    = 'POST';
        req.requestBody   = Blob.valueOf(jsonRequest);

        RestContext.request  = req;
        RestContext.response = res;

        AS_CPD_Points_Controller.ResponseWrapper result = new AS_CPD_Points_Controller.ResponseWrapper();
        result = AS_CPD_Points_Controller.doPost(strPoints);
        
        //Test.stopTest();
    }    
}