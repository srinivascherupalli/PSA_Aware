@isTest
public class LMSServiceTest {

    // TestMyTraining
    static testmethod void testMyTrainingNotStarted(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id,Pre_Requisite_1__c,Pre_Requisite_2__c,Pre_Requisite_3__c,Related_Education_1__c,Related_Education_2__c,Related_Education_3__c,Related_Education_4__c from Training_Plan__c];
        System.assertEquals(1,tplan.size());
        List<Training_Plan__c> tplistInsert=new List<Training_Plan__c>();
        for(Integer  i=0;i<8;i++){
            Training_Plan__c tp=new Training_Plan__c();
            tp.Name='Training plan';
            tplistInsert.add(tp);
        }
        insert tplistInsert;
        system.debug('tplistInsert data ** '+tplistInsert.size());
        tplan[0].Pre_Requisite_1__c=tplistInsert[0].Id;
        tplan[0].Pre_Requisite_2__c=tplistInsert[1].Id;
        tplan[0].Pre_Requisite_3__c=tplistInsert[2].Id;
        tplan[0].Related_Education_1__c=tplistInsert[3].Id;
        tplan[0].Related_Education_2__c=tplistInsert[4].Id;
        tplan[0].Related_Education_3__c=tplistInsert[5].Id;
        tplan[0].Related_Education_4__c=tplistInsert[6].Id;
        update tplan;
        system.debug('tplan data ** '+tplan);
		
        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        
        // Create Education FAQ Data
		Education_FAQ__c edFAQ=new Education_FAQ__c();
        edFAQ.Type__c ='CPD';
        edFAQ.Answer__c ='test Answer';
      	edFAQ.Question__c ='Test Question';
        insert edFAQ;
        
        // Create Plan FAQ
        Training_Plan_FAQ__c planFAQ =new Training_Plan_FAQ__c();
        planFAQ.Education_FAQ__c=edFAQ.Id;
        planFAQ.Training_Plan__c=tplan[0].Id;
            insert planFAQ;
        
        Set<Id> selectedUserIds = new Set<Id>();
		Set<Id> tplanids = new Set<Id>();
            for(Training_Plan__c tp :tplan){
                tplanids.add(tp.id);
            }
        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
                LMSService.queryRelatedTrainingPlans(tplanids);
                LMSService.getTrainingMainFAQs(tplanids);
                LMSService.getTrainingPlanFAQs(tplanids);
                LMSService.WithoutSharingOps wsopss = new LMSService.WithoutSharingOps();
                wsopss.getTrainingPlanFAQs(tplanId);
                LMSService.getTrainingTrackMainAchievements(tplanids);
                LMSWrappersService.getTrainingPlanDetails(tplanId,adminUsers[0].Id,true,true);

            }
        Test.stopTest();

        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.MyTraining;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'iPhone');
            MyTrainingController controller = new MyTrainingController();

            System.assert(controller.selectedType == LMSConstants.TPLAN_STATUS_NOT_STARTED);
            System.assert(controller.tPlans.size() == 1);

            controller.selectedType = LMSConstants.TPLAN_STATUS_IN_PROGRESS;
            controller.loadTrainingPlans();
            System.assert(controller.tPlans.size() == 0);

            controller.selectedType = LMSConstants.TPLAN_STATUS_COMPLETED;
            controller.loadTrainingPlans();

        }

    }

    static testmethod void testMyTrainingInProgress(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);

                List<Training_Plan_Assignment__c> ltpa = [select id,
                                                                Status__c,
                                                                Training_Plan__c,
                                                                User__c from Training_Plan_Assignment__c
                                                                where User__c =: lmsUsers.get(0).Id
                                                                and Training_Plan__c =: tplan.get(0).Id];
                System.assert(ltpa.size() == 1);
                ltpa.get(0).Status__c = 'In Progress';
                upsert ltpa;
            }
        Test.stopTest();

        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.MyTraining;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'iPhone');
            MyTrainingController controller = new MyTrainingController();

            System.assert(controller.selectedType == LMSConstants.TPLAN_STATUS_NOT_STARTED);
            System.assert(controller.tPlans.size() == 0);

            controller.selectedType = LMSConstants.TPLAN_STATUS_IN_PROGRESS;
            controller.loadTrainingPlans();
            System.assert(controller.tPlans.size() == 1);

            controller.selectedType = LMSConstants.TPLAN_STATUS_COMPLETED;
            controller.loadTrainingPlans();
            System.assert(controller.tPlans.size() == 0);

            controller.selectedType ='INVALID VALUE';
            controller.loadTrainingPlans();
            System.assert(controller.tPlans.size() == 0);

        }

    }

    static testmethod void testMyTrainingInProgressWithExpiredItems(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id,Start_Date__c,End_Date__c,Hide_After_End_Date__c from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        //Update date configuration
        Training_Plan__c tp = tplan.get(0);
        tp.Start_Date__c = Date.today().addDays(-10);
        tp.End_Date__c = Date.today().addDays(-1);
        tp.Hide_After_End_Date__c = true;
        update tp;


        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);

                List<Training_Plan_Assignment__c> ltpa = [select id,
                                                                Status__c,
                                                                Training_Plan__c,
                                                                User__c from Training_Plan_Assignment__c
                                                                where User__c =: lmsUsers.get(0).Id
                                                                and Training_Plan__c =: tplan.get(0).Id];
                System.assert(ltpa.size() == 1);
                ltpa.get(0).Status__c = 'In Progress';
                upsert ltpa;
            }
        Test.stopTest();

        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.MyTraining;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'iPhone');
            MyTrainingController controller = new MyTrainingController();

            System.assert(controller.selectedType == LMSConstants.TPLAN_STATUS_NOT_STARTED);
            System.assert(controller.tPlans.size() == 0);

            controller.selectedType = LMSConstants.TPLAN_STATUS_IN_PROGRESS;
            controller.loadTrainingPlans();
           // System.assert(controller.tPlans.size() == 0);

            controller.selectedType = LMSConstants.TPLAN_STATUS_COMPLETED;
            controller.loadTrainingPlans();
            System.assert(controller.tPlans.size() == 0);

        }

    }

    // TestQuestionNewController

    static testmethod void testCreateBooleanQuestion(){
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        //Assign corresponding perm sets
        TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');

        System.runAs(adminUsers.get(0)){

            //Create quiz learnings
            List<Learning__c> quizLearnings = TestLearningData.createTestLearning(1, 'Quiz', true);
            //create quiz
            List<Quiz__c> quiz = TestLearningData.createTestQuiz(quizLearnings);
            //create question line
            List<Question_Line__c> qline = TestLearningData.createTestQuestionLine(quiz, 1);

            //go to QuestionNew page
            PageReference pageRef = Page.QuestionNew;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('retURL', '/'+qline.get(0).Id);
            ApexPages.Standardcontroller stdcontroller = new ApexPages.StandardController(new Question__c());
            QuestionNewController extension = new QuestionNewController(stdcontroller);
            System.assert(extension.question != null, 'extension.question is not initialized');
            extension.question.Description__c = 'This is a test of boolean?';
            extension.question.Type__c = 'Boolean';
            extension.question.Order__c = 1;
            extension.questiontype = 'Boolean';
            extension.answerseqenabler();
            extension.question.Correct_Boolean__c = 'true';
            extension.c_save();

            List<Question__c> lquestions = [select Id, Description__c, Type__c, Order__c, Correct_Boolean__c  from Question__c where Question_Line__c =: qline.get(0).Id];
            System.assert(lquestions.size() == 1, 'issues with question, size = ' + lquestions.size());
            System.assert(lquestions.get(0).Description__c == 'This is a test of boolean?');
            System.assert(lquestions.get(0).Type__c == 'Boolean');
            System.assert(lquestions.get(0).Order__c == 1);
            System.assert(lquestions.get(0).Correct_Boolean__c == 'true');
        }
    }

    static testmethod void testCreateNumberQuestion(){
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        //Assign corresponding perm sets
        TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');

        System.runAs(adminUsers.get(0)){

            //Create quiz learnings
            List<Learning__c> quizLearnings = TestLearningData.createTestLearning(1, 'Quiz', true);
            //create quiz
            List<Quiz__c> quiz = TestLearningData.createTestQuiz(quizLearnings);
            //create question line
            List<Question_Line__c> qline = TestLearningData.createTestQuestionLine(quiz, 1);

            //go to QuestionNew page
            PageReference pageRef = Page.QuestionNew;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('retURL', '/'+qline.get(0).Id);
            ApexPages.Standardcontroller stdcontroller = new ApexPages.StandardController(new Question__c());
            QuestionNewController extension = new QuestionNewController(stdcontroller);
            System.assert(extension.question != null, 'extension.question is not initialized');
            extension.question.Description__c = 'What is the age of the kid?';
            extension.question.Type__c = 'Number';
            extension.question.Order__c = 1;
            extension.questiontype = 'Number';
            extension.answerseqenabler();
            extension.question.Correct_Number__c = 3;
            extension.c_save();

            List<Question__c> lquestions = [select Id, Description__c, Type__c, Order__c, Correct_Number__c  from Question__c where Question_Line__c =: qline.get(0).Id];
            System.assert(lquestions.size() == 1, 'issues with question, size = ' + lquestions.size());
            System.assert(lquestions.get(0).Description__c == 'What is the age of the kid?');
            System.assert(lquestions.get(0).Type__c == 'Number');
            System.assert(lquestions.get(0).Order__c == 1);
            System.assert(lquestions.get(0).Correct_Number__c == 3);
        }
    }

    static testmethod void testCreateTextQuestion(){
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        //Assign corresponding perm sets
        TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');

        System.runAs(adminUsers.get(0)){

            //Create quiz learnings
            List<Learning__c> quizLearnings = TestLearningData.createTestLearning(1, 'Quiz', true);
            //create quiz
            List<Quiz__c> quiz = TestLearningData.createTestQuiz(quizLearnings);
            //create question line
            List<Question_Line__c> qline = TestLearningData.createTestQuestionLine(quiz, 1);

            //go to QuestionNew page
            PageReference pageRef = Page.QuestionNew;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('retURL', '/'+qline.get(0).Id);
            ApexPages.Standardcontroller stdcontroller = new ApexPages.StandardController(new Question__c());
            QuestionNewController extension = new QuestionNewController(stdcontroller);
            System.assert(extension.question != null, 'extension.question is not initialized');
            extension.question.Description__c = 'What is love?';
            extension.question.Type__c = 'Text';
            extension.question.Order__c = 1;
            extension.questiontype = 'Text';
            extension.answerseqenabler();
            extension.c_save();

            List<Question__c> lquestions = [select Id, Description__c, Type__c, Order__c from Question__c where Question_Line__c =: qline.get(0).Id];
            System.assert(lquestions.size() == 1, 'issues with question, size = ' + lquestions.size());
            System.assert(lquestions.get(0).Description__c == 'What is love?');
            System.assert(lquestions.get(0).Type__c == 'Text');
            System.assert(lquestions.get(0).Order__c == 1);
        }
    }

    static testmethod void testCreateSelectOneQuestion(){
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        //Assign corresponding perm sets
        TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');

        System.runAs(adminUsers.get(0)){

            //Create quiz learnings
            List<Learning__c> quizLearnings = TestLearningData.createTestLearning(1, 'Quiz', true);
            //create quiz
            List<Quiz__c> quiz = TestLearningData.createTestQuiz(quizLearnings);
            //create question line
            List<Question_Line__c> qline = TestLearningData.createTestQuestionLine(quiz, 1);

            //go to QuestionNew page
            PageReference pageRef = Page.QuestionNew;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('retURL', '/'+qline.get(0).Id);
            ApexPages.Standardcontroller stdcontroller = new ApexPages.StandardController(new Question__c());
            QuestionNewController extension = new QuestionNewController(stdcontroller);
            System.assert(extension.question != null, 'extension.question is not initialized');
            extension.question.Description__c = 'What is the best Blur song?';
            extension.question.Type__c = 'SelectOneQuestion';
            extension.question.Order__c = 1;
            extension.questiontype = 'SelectOneQuestion';
            extension.answerseqenabler();

            extension.lanswerseqitems.get(0).Item_Id__c = '#ans1';
            extension.lanswerseqitems.get(0).Answer_Text__c = 'Coffee & TV';
            extension.lanswerseqitems.get(0).Order__c = 1;
            extension.lanswerseqitems.get(0).Is_Correct_Answer__c = true;

            extension.addanswerseqitem();
            extension.lanswerseqitems.get(1).Item_Id__c = '#ans2';
            extension.lanswerseqitems.get(1).Answer_Text__c = 'Song #2';
            extension.lanswerseqitems.get(1).Order__c = 1;
            extension.lanswerseqitems.get(1).Is_Correct_Answer__c = false;

            extension.c_save();

            List<Answer_Sequence__c> lansseq = [select id from Answer_Sequence__c];
            System.assert(lansseq.size() == 1, 'Answer Sequence is wrong, size = ' + lansseq.size());

            List<Answer_Sequence_Item__c> lasitem = [select id from Answer_Sequence_Item__c where Answer_Sequence__c = :lansseq.get(0).Id];
            System.assert(lasitem.size() == 2, 'Answer Sequence Item is wrong, size = ' + lasitem.size());

            List<Question__c> lquestions = [select Id,
                                                Description__c,
                                                Type__c,
                                                Order__c from Question__c
                                                where Question_Line__c =: qline.get(0).Id and Answer_Sequence__c =: lansseq.get(0).Id];

            System.assert(lquestions.size() == 1, 'issues with question, size = ' + lquestions.size());
            System.assert(lquestions.get(0).Description__c == 'What is the best Blur song?');
            System.assert(lquestions.get(0).Type__c == 'SelectOneQuestion');
            System.assert(lquestions.get(0).Order__c == 1);
        }
    }

    static testmethod void testCreateSelectMultipleQuestion(){
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        //Assign corresponding perm sets
        TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');

        System.runAs(adminUsers.get(0)){

            //Create quiz learnings
            List<Learning__c> quizLearnings = TestLearningData.createTestLearning(1, 'Quiz', true);
            //create quiz
            List<Quiz__c> quiz = TestLearningData.createTestQuiz(quizLearnings);
            //create question line
            List<Question_Line__c> qline = TestLearningData.createTestQuestionLine(quiz, 1);

            //go to QuestionNew page
            PageReference pageRef = Page.QuestionNew;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('retURL', '/'+qline.get(0).Id);
            ApexPages.Standardcontroller stdcontroller = new ApexPages.StandardController(new Question__c());
            QuestionNewController extension = new QuestionNewController(stdcontroller);
            System.assert(extension.question != null, 'extension.question is not initialized');
            extension.question.Description__c = 'What Blur songs are part of The Great Escape?';
            extension.question.Type__c = 'SelectMultipleQuestion';
            extension.question.Order__c = 1;
            extension.questiontype = 'SelectMultipleQuestion';
            extension.answerseqenabler();

            extension.lanswerseqitems.get(0).Item_Id__c = '#ans1';
            extension.lanswerseqitems.get(0).Answer_Text__c = 'Coffee & TV';
            extension.lanswerseqitems.get(0).Order__c = 1;
            extension.lanswerseqitems.get(0).Is_Correct_Answer__c = false;

            extension.addanswerseqitem();
            extension.lanswerseqitems.get(1).Item_Id__c = '#ans2';
            extension.lanswerseqitems.get(1).Answer_Text__c = 'Charmless Man';
            extension.lanswerseqitems.get(1).Order__c = 1;
            extension.lanswerseqitems.get(1).Is_Correct_Answer__c = true;

            extension.addanswerseqitem();
            extension.lanswerseqitems.get(2).Item_Id__c = '#ans3';
            extension.lanswerseqitems.get(2).Answer_Text__c = 'The Universal';
            extension.lanswerseqitems.get(2).Order__c = 1;
            extension.lanswerseqitems.get(2).Is_Correct_Answer__c = true;

            extension.c_save();

            List<Answer_Sequence__c> lansseq = [select id from Answer_Sequence__c];
            System.assert(lansseq.size() == 1, 'Answer Sequence is wrong, size = ' + lansseq.size());

            List<Answer_Sequence_Item__c> lasitem = [select id from Answer_Sequence_Item__c where Answer_Sequence__c = :lansseq.get(0).Id];
            System.assert(lasitem.size() == 3, 'Answer Sequence Item is wrong, size = ' + lasitem.size());

            List<Question__c> lquestions = [select Id,
                                                Description__c,
                                                Type__c,
                                                Order__c from Question__c
                                                where Question_Line__c =: qline.get(0).Id and Answer_Sequence__c =: lansseq.get(0).Id];

            System.assert(lquestions.size() == 1, 'issues with question, size = ' + lquestions.size());
            System.assert(lquestions.get(0).Description__c == 'What Blur songs are part of The Great Escape?');
            System.assert(lquestions.get(0).Type__c == 'SelectMultipleQuestion');
            System.assert(lquestions.get(0).Order__c == 1);
        }
    }

    static testmethod void testCancelCreateQuestion(){
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        //Assign corresponding perm sets
        TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');

        System.runAs(adminUsers.get(0)){

            //Create quiz learnings
            List<Learning__c> quizLearnings = TestLearningData.createTestLearning(1, 'Quiz', true);
            //create quiz
            List<Quiz__c> quiz = TestLearningData.createTestQuiz(quizLearnings);
            //create question line
            List<Question_Line__c> qline = TestLearningData.createTestQuestionLine(quiz, 1);

            //go to QuestionNew page
            PageReference pageRef = Page.QuestionNew;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('retURL', '/'+qline.get(0).Id);
            ApexPages.Standardcontroller stdcontroller = new ApexPages.StandardController(new Question__c());
            QuestionNewController extension = new QuestionNewController(stdcontroller);
            System.assert(extension.question != null, 'extension.question is not initialized');
            extension.question.Description__c = 'This is a test of boolean?';
            extension.question.Type__c = 'Boolean';
            extension.question.Order__c = 1;
            extension.questiontype = 'Boolean';
            extension.answerseqenabler();
            extension.question.Correct_Boolean__c = 'true';
            extension.cancel();

            List<Question__c> lquestions = [select Id, Description__c, Type__c, Order__c, Correct_Boolean__c  from Question__c where Question_Line__c =: qline.get(0).Id];
            System.assert(lquestions.size() == 0, 'issues with question, size = ' + lquestions.size());
        }
    }

    static testmethod void testCreateBooleanQuestionAndEdit(){
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        //Assign corresponding perm sets
        TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');

        System.runAs(adminUsers.get(0)){

            //Create quiz learnings
            List<Learning__c> quizLearnings = TestLearningData.createTestLearning(1, 'Quiz', true);
            //create quiz
            List<Quiz__c> quiz = TestLearningData.createTestQuiz(quizLearnings);
            //create question line
            List<Question_Line__c> qline = TestLearningData.createTestQuestionLine(quiz, 1);

            //go to QuestionNew page
            PageReference pageRef = Page.QuestionNew;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('retURL', '/'+qline.get(0).Id);
            ApexPages.Standardcontroller stdcontroller = new ApexPages.StandardController(new Question__c());
            QuestionNewController extension = new QuestionNewController(stdcontroller);
            System.assert(extension.question != null, 'extension.question is not initialized');
            extension.question.Description__c = 'This is a test of boolean?';
            extension.question.Type__c = 'Boolean';
            extension.question.Order__c = 1;
            extension.questiontype = 'Boolean';
            extension.answerseqenabler();
            extension.question.Correct_Boolean__c = 'true';
            extension.c_save();

            List<Question__c> lquestions = [select Id, Description__c, Type__c, Order__c, Correct_Boolean__c  from Question__c where Question_Line__c =: qline.get(0).Id];
            System.assert(lquestions.size() == 1);

            PageReference pageRef2 = Page.QuestionNew;
            Test.setCurrentPage(pageRef2);
            pageRef2.getParameters().put('retURL', '/'+qline.get(0).Id);
            ApexPages.Standardcontroller stdcontroller2 = new ApexPages.StandardController(lquestions.get(0));
            QuestionNewController extension2 = new QuestionNewController(stdcontroller2);

            System.assert(extension2.question.Description__c == 'This is a test of boolean?');
            System.assert(extension2.question.Type__c == 'Boolean');
            System.assert(extension2.question.Order__c == 1);
            System.assert(extension2.question.Correct_Boolean__c == 'true');

            extension2.question.Correct_Boolean__c = 'false';
            extension2.c_save();

            List<Question__c> lquestions2 = [select Id, Description__c, Type__c, Order__c, Correct_Boolean__c  from Question__c where Question_Line__c =: qline.get(0).Id];
            System.assert(lquestions2.size() == 1);
            System.assert(lquestions2.get(0).Correct_Boolean__c == 'false');

        }
    }

    static testmethod void testCreateSelectMultipleQuestionAndEdit(){
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        //Assign corresponding perm sets
        TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');

        System.runAs(adminUsers.get(0)){

            //Create quiz learnings
            List<Learning__c> quizLearnings = TestLearningData.createTestLearning(1, 'Quiz', true);
            //create quiz
            List<Quiz__c> quiz = TestLearningData.createTestQuiz(quizLearnings);
            //create question line
            List<Question_Line__c> qline = TestLearningData.createTestQuestionLine(quiz, 1);

            //go to QuestionNew page
            PageReference pageRef = Page.QuestionNew;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('retURL', '/'+qline.get(0).Id);
            ApexPages.Standardcontroller stdcontroller = new ApexPages.StandardController(new Question__c());
            QuestionNewController extension = new QuestionNewController(stdcontroller);
            System.assert(extension.question != null, 'extension.question is not initialized');
            extension.question.Description__c = 'What Blur songs are part of The Great Escape?';
            extension.question.Type__c = 'SelectMultipleQuestion';
            extension.question.Order__c = 1;
            extension.questiontype = 'SelectMultipleQuestion';
            extension.answerseqenabler();

            extension.lanswerseqitems.get(0).Item_Id__c = '#ans1';
            extension.lanswerseqitems.get(0).Answer_Text__c = 'Coffee & TV';
            extension.lanswerseqitems.get(0).Order__c = 1;
            extension.lanswerseqitems.get(0).Is_Correct_Answer__c = false;

            extension.addanswerseqitem();
            extension.lanswerseqitems.get(1).Item_Id__c = '#ans2';
            extension.lanswerseqitems.get(1).Answer_Text__c = 'Charmless Man';
            extension.lanswerseqitems.get(1).Order__c = 1;
            extension.lanswerseqitems.get(1).Is_Correct_Answer__c = true;

            extension.addanswerseqitem();
            extension.lanswerseqitems.get(2).Item_Id__c = '#ans3';
            extension.lanswerseqitems.get(2).Answer_Text__c = 'The Universal';
            extension.lanswerseqitems.get(2).Order__c = 1;
            extension.lanswerseqitems.get(2).Is_Correct_Answer__c = true;

            extension.c_save();

            List<Answer_Sequence__c> lansseq = [select id from Answer_Sequence__c];
            System.assert(lansseq.size() == 1, 'Answer Sequence is wrong, size = ' + lansseq.size());

            List<Question__c> lquestions = [select Id,
                                                Description__c,
                                                Type__c,
                                                Order__c,
                                                Answer_Sequence__c,
                                                Correct_Number__c,
                                                Correct_Boolean__c from Question__c
                                                where Question_Line__c =: qline.get(0).Id and Answer_Sequence__c =: lansseq.get(0).Id];

            //go to QuestionNew page
            PageReference pageRef2 = Page.QuestionNew;
            Test.setCurrentPage(pageRef2);
            pageRef2.getParameters().put('retURL', '/'+qline.get(0).Id);
            ApexPages.Standardcontroller stdcontroller2 = new ApexPages.StandardController(lquestions.get(0));
            QuestionNewController extension2 = new QuestionNewController(stdcontroller2);

            System.assert(extension2.question.Description__c == 'What Blur songs are part of The Great Escape?');
            System.assert(extension2.question.Type__c == 'SelectMultipleQuestion');
            System.assert(extension2.question.Order__c == 1);

            List<Answer_Sequence_Item__c> lasitem = [select id from Answer_Sequence_Item__c where Answer_Sequence__c = :lansseq.get(0).Id];
            System.assert(lasitem.size() == 3, 'Answer Sequence Item is wrong, size = ' + lasitem.size());
            System.assert(lasitem.size() == extension2.lanswerseqitems.size());

        }
    }

    // TestQuizResultsController
    static testMethod void testPassingResults(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(1,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(1,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        Id learningAssignmentId = createSampleData(adminUsers,lmsUsers,createQuizLearnings());

        List<Learning_Assignment__c> lassignment = [select Id,
                                                            Learning__c, Learning_Version__r.Quiz__c from Learning_Assignment__c
                                                            where Id = :learningAssignmentId];

        System.assert(lassignment.size() == 1, 'Learning Assignment issues, size = ' + lassignment.size());
        System.assert(lassignment.get(0).Learning_Version__r.Quiz__c != null, 'Learning Assignment is not for Quiz');

        //Answer all the quiz questions
        Set<Id> qlineIds = new Set<Id>();
        for(Question_Line__c oql : [select Id from Question_Line__c where Quiz__c =: lassignment.get(0).Learning_Version__r.Quiz__c]){
            qlineIds.add(oql.Id);
        }

        Map<String, Response__c> mResponses = TestLearningData.createTestQuestionResponses(qlineIds, lmsUsers.get(0).Id, lassignment.get(0).Id);

        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                PageReference pageRef = Page.QuizViewer;
                Test.setCurrentPage(pageRef);
                pageRef.getHeaders().put('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:25.0) Gecko/20100101 Firefox/25.0');
                pageRef.getParameters().put('aid', learningAssignmentId);
                QuizViewerController controller = new QuizViewerController();
                controller.initializeQuestions();

                //first section
                List<QuizItem> lqi = controller.quizItemList;

                for(QuizItem qi : lqi){
                    qi.response = mResponses.get(qi.question.Id);
                }
                controller.next();
                controller.initializeQuestions();

                //second section
                List<QuizItem> lqi2 = controller.quizItemList;

                for(QuizItem qi : lqi2){
                	qi.response	 = mResponses.get(qi.question.Id);
                }
                controller.next();
                controller.initializeQuestions();

                //third & final section
                List<QuizItem> lqi3 = controller.quizItemList;

                for(QuizItem qi : lqi3){
                    qi.response	 = mResponses.get(qi.question.Id);
                }
                controller.done();

            }
        Test.stopTest();

        System.runAs(lmsUsers.get(0)){
            //Switch to quiz results page
            PageReference pageRef = Page.QuizResults;
            pageRef.getParameters().put('aid',learningAssignmentId);
            Test.setCurrentPage(pageRef);
            QuizResultsController cont = new QuizResultsController();
            System.assertEquals(LMSConstants.ASSIGNMENT_EVAL_PASSED,cont.evalResult);
            PageReference contRef = cont.quizContinue();
            PageReference dummyRef = new PageReference(cont.redirectURL);
            System.assert(dummyRef.getParameters().get('id') != null,'Result does not contain assignment id');
            System.assert(countAssignmentResponses(learningAssignmentId) > 0, 'No responses were captured');
        }

    }

    static testMethod void testMissingSelectMultipleValues(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(1,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(1,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        List<Learning__c> quizLearnings = createMultipleQuestionQuizLearnings();
        Id learningAssignmentId = createSampleData(adminUsers,lmsUsers,quizLearnings);

        List<Learning_Assignment__c> lassignment = [select Id,
                                                            Learning__c, Learning_Version__r.Quiz__c from Learning_Assignment__c
                                                            where Id = :learningAssignmentId];

        System.assert(lassignment.size() == 1, 'Learning Assignment issues, size = ' + lassignment.size());
        System.assert(lassignment.get(0).Learning_Version__r.Quiz__c != null, 'Learning Assignment is not for Quiz');

        //Create a new answer sequence item for testing purposes
        Answer_Sequence__c oaseq = new Answer_Sequence__c();
        oaseq.Internal_Notes__c = 'dummy internal notes';
        insert oaseq;

        //Create answer sequence items
        List<Answer_Sequence_Item__c> lanswerSequence = new List<Answer_Sequence_Item__c>();

        for(Integer i = 0; i < 3; i++){
            Answer_Sequence_Item__c oasi = new Answer_Sequence_Item__c();
            oasi.Item_Id__c = 'testMPQ'+i;
            oasi.Answer_Sequence__c = oaseq.Id;
            oasi.Answer_Text__c = 'testMPQ'+i;
            oasi.Is_Correct_Answer__c = true;
            oasi.Order__c = i;
            lanswerSequence.add(oasi);
        }
        insert lanswerSequence;

        //Associate the new answer sequence to the quiz question
        List<Question__c> questions = [select id,Answer_Sequence__c from Question__c where Question_Line__r.Quiz__r.Learning__c = :quizLearnings.get(0).id];
        Question__c selectMultipleQ = questions.get(0);
        selectMultipleQ.Answer_Sequence__c = oaseq.Id;
        update selectMultipleQ;

        //Answer the multiple choice question
        Response__c response = new Response__c();
        response.Learning_Assignment__c = lassignment.get(0).Id;
        response.Question__c = selectMultipleQ.Id;
        response.User__c =  lmsUsers.get(0).Id;
        //Respond with only two of the options
        response.Response_Answer_Sequence_Label__c = 'testMPQ0;testMPQ1;';
        response.Response_Answer_Sequence_Long__c = 'testMPQ0;testMPQ1;';

        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                PageReference pageRef = Page.QuizViewer;
                Test.setCurrentPage(pageRef);
                pageRef.getParameters().put('aid', learningAssignmentId);
                QuizViewerController controller = new QuizViewerController();
                controller.initializeQuestions();
                //first section
                List<QuizItem> lqi = controller.quizItemList;
                for(QuizItem qi : lqi){
                	qi.response = response;
                }
                controller.done();
            }
        Test.stopTest();

        System.runAs(lmsUsers.get(0)){
            //Switch to quiz results page
            PageReference pageRef = Page.QuizResults;
            pageRef.getParameters().put('aid',learningAssignmentId);
            Test.setCurrentPage(pageRef);
            QuizResultsController cont = new QuizResultsController();
            System.assertEquals(LMSConstants.ASSIGNMENT_EVAL_FAILED,cont.evalResult);
            PageReference contRef = cont.quizContinue();
            PageReference dummyRef = new PageReference(cont.redirectURL);
            System.assert(dummyRef.getParameters().get('id') != null,'Result does not contain assignment id');
        }
    }

    static testMethod void testCorrectSelectMultipleValues(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(1,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(1,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        List<Learning__c> quizLearnings = createMultipleQuestionQuizLearnings();
        Id learningAssignmentId = createSampleData(adminUsers,lmsUsers,quizLearnings);

        List<Learning_Assignment__c> lassignment = [select Id,
                                                            Learning__c, Learning_Version__r.Quiz__c from Learning_Assignment__c
                                                            where Id = :learningAssignmentId];

        System.assert(lassignment.size() == 1, 'Learning Assignment issues, size = ' + lassignment.size());
        System.assert(lassignment.get(0).Learning_Version__r.Quiz__c != null, 'Learning Assignment is not for Quiz');

        //Create a new answer sequence item for testing purposes
        Answer_Sequence__c oaseq = new Answer_Sequence__c();
        oaseq.Internal_Notes__c = 'dummy internal notes';
        insert oaseq;

        //Create answer sequence items
        List<Answer_Sequence_Item__c> lanswerSequence = new List<Answer_Sequence_Item__c>();

        for(Integer i = 0; i < 3; i++){
            Answer_Sequence_Item__c oasi = new Answer_Sequence_Item__c();
            oasi.Item_Id__c = 'testMPQ'+i;
            oasi.Answer_Sequence__c = oaseq.Id;
            oasi.Answer_Text__c = 'testMPQ'+i;
            oasi.Is_Correct_Answer__c = true;
            oasi.Order__c = i;
            lanswerSequence.add(oasi);
        }
        insert lanswerSequence;

        //Associate the new answer sequence to the quiz question
        List<Question__c> questions = [select id,Answer_Sequence__c from Question__c where Question_Line__r.Quiz__r.Learning__c = :quizLearnings.get(0).id];
        Question__c selectMultipleQ = questions.get(0);
        selectMultipleQ.Answer_Sequence__c = oaseq.Id;
        update selectMultipleQ;

        //Answer the multiple choice question
        Response__c response = new Response__c();
        response.Learning_Assignment__c = lassignment.get(0).Id;
        response.Question__c = selectMultipleQ.Id;
        response.User__c =  lmsUsers.get(0).Id;
        //Respond with only two of the options
        response.Response_Answer_Sequence_Label__c = 'testMPQ0;testMPQ1;testMPQ2;';
        response.Response_Answer_Sequence_Long__c = 'testMPQ0;testMPQ1;testMPQ2;';

        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                PageReference pageRef = Page.QuizViewer;
                Test.setCurrentPage(pageRef);
                pageRef.getParameters().put('aid', learningAssignmentId);
                QuizViewerController controller = new QuizViewerController();
                controller.initializeQuestions();

                //first section
                List<QuizItem> lqi = controller.quizItemList;

                for(QuizItem qi : lqi){
                	qi.response = response;
                }
                controller.done();
            }
        Test.stopTest();

        System.runAs(lmsUsers.get(0)){
            //Switch to quiz results page
            PageReference pageRef = Page.QuizResults;
            pageRef.getParameters().put('aid',learningAssignmentId);
            Test.setCurrentPage(pageRef);
            QuizResultsController cont = new QuizResultsController();
            System.assertEquals(LMSConstants.ASSIGNMENT_EVAL_PASSED,cont.evalResult);
            PageReference contRef = cont.quizContinue();
            PageReference dummyRef = new PageReference(cont.redirectURL);
            System.assert(dummyRef.getParameters().get('id') != null,'Result does not contain assignment id');
        }
    }

    static testMethod void testPassingResultsAndDeletingResponses(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(1,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(1,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        Id learningAssignmentId = createSampleData(adminUsers,lmsUsers,createQuizLearnings());

        List<Learning_Assignment__c> lassignment = [select Id,
                                                            Learning__c, Learning_Version__r.Quiz__c from Learning_Assignment__c
                                                            where Id = :learningAssignmentId];

        System.assert(lassignment.size() == 1, 'Learning Assignment issues, size = ' + lassignment.size());
        System.assert(lassignment.get(0).Learning_Version__r.Quiz__c != null, 'Learning Assignment is not for Quiz');

        //Configure quiz to delete responses on submission
        Quiz__c testQuiz = [select id,Delete_Responses_On_Submission__c from Quiz__c where Id = :lassignment.get(0).Learning_Version__r.Quiz__c limit 1];
        testQuiz.Delete_Responses_On_Submission__c = true;
        update testQuiz;

        //Answer all the quiz questions
        Set<Id> qlineIds = new Set<Id>();
        for(Question_Line__c oql : [select Id from Question_Line__c where Quiz__c =: lassignment.get(0).Learning_Version__r.Quiz__c]){
            qlineIds.add(oql.Id);
        }

        Map<String, Response__c> mResponses = TestLearningData.createTestQuestionResponses(qlineIds, lmsUsers.get(0).Id, lassignment.get(0).Id);

        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                PageReference pageRef = Page.QuizViewer;
                Test.setCurrentPage(pageRef);
                pageRef.getHeaders().put('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:25.0) Gecko/20100101 Firefox/25.0');
                pageRef.getParameters().put('aid', learningAssignmentId);
                QuizViewerController controller = new QuizViewerController();
                controller.initializeQuestions();

                //first section
                List<QuizItem> lqi = controller.quizItemList;

                for(QuizItem qi : lqi){
                	qi.response = mResponses.get(qi.question.Id);
                }
                controller.next();
                controller.initializeQuestions();

                //second section
                List<QuizItem> lqi2 = controller.quizItemList;

                for(QuizItem qi : lqi2){
                	qi.response	 = mResponses.get(qi.question.Id);
                }
                controller.next();
                controller.initializeQuestions();

                //third & final section
                List<QuizItem> lqi3 = controller.quizItemList;

                for(QuizItem qi : lqi3){
                    qi.response	 = mResponses.get(qi.question.Id);
                }
                controller.done();

            }
        Test.stopTest();

        System.runAs(lmsUsers.get(0)){
            //Switch to quiz results page
            PageReference pageRef = Page.QuizResults;
            pageRef.getParameters().put('aid',learningAssignmentId);
            Test.setCurrentPage(pageRef);
            QuizResultsController cont = new QuizResultsController();
            System.assertEquals(LMSConstants.ASSIGNMENT_EVAL_PASSED,cont.evalResult);
            PageReference contRef = cont.quizContinue();
            PageReference dummyRef = new PageReference(cont.redirectURL);
            System.assert(dummyRef.getParameters().get('id') != null,'Result does not contain assignment id');
            System.assert(countAssignmentResponses(learningAssignmentId) == 0, 'Responses were not deleted after submission');
        }

    }

    private static List<Learning__c> createMultipleQuestionQuizLearnings(){
        //create quiz learnings
        List<Learning__c> quizLearnings = TestLearningData.createTestLearning(1, 'Quiz', false);
        //create quiz
        List<Quiz__c> quiz = TestLearningData.createTestQuiz(quizLearnings, new Map<String,Object>{'Passing_Score__c'=>100.0});
        //create question line
        List<Question_Line__c> qline = TestLearningData.createTestQuestionLine(quiz, 1);
        //create question
        List<Question__c> question = TestLearningData.createTestQuestions(qline, 1, 'SelectMultipleQuestion');
        for(Integer i = 0;i < quizLearnings.size();i++){
            TestLearningData.publishLearning(quizLearnings.get(i).Id,'quiz',quiz.get(i).Id,false);
        }
        return quizLearnings;
    }

    private static List<Learning__c> createQuizLearnings(){
        //create quiz learnings
        List<Learning__c> quizLearnings = TestLearningData.createTestLearning(1, 'Quiz', false);
        //create quiz
        List<Quiz__c> quiz = TestLearningData.createTestQuiz(quizLearnings);
        //create question line
        List<Question_Line__c> qline = TestLearningData.createTestQuestionLine(quiz, 2);
        //create question
        List<Question__c> question = TestLearningData.createTestQuestions(qline, 4, null);
        for(Integer i = 0;i < quizLearnings.size();i++){
            TestLearningData.publishLearning(quizLearnings.get(i).Id,'quiz',quiz.get(i).Id,false);
        }
        return quizLearnings;
    }

    private static Id createSampleData(List<User> adminUsers, List<User> lmsUsers,List<Learning__c> quizLearnings){
        //Create training plans
        List<Training_Plan__c> tplans = TestTrainingPlanData.createTrainingPlans(new List<TestParams.TrainingPlanParam>{new TestParams.TrainingPlanParam()});
        //Create training plan sections
        List<Training_Plan_Section__c> tplanSections1 = TestTrainingPlanData.createTrainingPlanSections(tplans.get(0).Id,1);
        //Create training plan section items for quizzes
        List<Training_Plan_Section_Item__c> tplan1SectionItems1 = TestTrainingPlanData.createTrainingPlanSectionItems(tplanSections1.get(0).Id,quizLearnings);

        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());
        Id tplanId = tplan.get(0).Id;

        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        System.runAs(adminUsers.get(0)){
            LMSService.upsertAssignments(selectedUserIds,tplanId,null);
        }

        List<Learning_Assignment__c> assignments = [select id from Learning_Assignment__c where Training_Plan__c = :tplanId];
        System.assertEquals(1,assignments.size());
        return assignments.get(0).Id;
    }

    private static Integer countAssignmentResponses(Id assignmentId){
        return [select count() from Response__c where Learning_Assignment__c = :assignmentId];
    }

    // TestQuizViewer
    static testmethod void testQuizViewerWeb(){
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }
        Test.stopTest();

        List<Training_Plan_Section__c> ltpsec = [select id from Training_Plan_Section__c where Training_Plan__c =: tplanId order by Order__c asc];
        System.assert(ltpsec.size() == 3);

        List<Training_Plan_Section_Item__c> ltpsitem = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(0).Id order by Order__c asc];
        System.assert(ltpsitem.size() == 1, 'Training Plan Section Item issues, size = ' + ltpsitem.size());

        List<Learning_Assignment__c> lassignment = [select Id,
                                                        Learning__c, Learning_Version__r.Quiz__c from Learning_Assignment__c
                                                        where Training_Plan__c =: tplanId
                                                        and Training_Plan_Section__c =:ltpsec.get(0).Id
                                                        and User__c =: lmsUsers.get(0).Id];

        System.assert(lassignment.size() == 1, 'Learning Assignment issues, size = ' + lassignment.size());
        System.assert(lassignment.get(0).Learning_Version__r.Quiz__c != null, 'Learning Assignment is not for Quiz');

        Set<Id> qlineIds = new Set<Id>();
        for(Question_Line__c oql : [select Id from Question_Line__c where Quiz__c =: lassignment.get(0).Learning_Version__r.Quiz__c]){
            qlineIds.add(oql.Id);
        }

        Map<String, Response__c> mResponses = TestLearningData.createTestQuestionResponses(qlineIds, lmsUsers.get(0).Id, lassignment.get(0).Id);


        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.QuizViewer;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:25.0) Gecko/20100101 Firefox/25.0');
            pageRef.getParameters().put('aid', lassignment.get(0).Id);
            QuizViewerController controller = new QuizViewerController();
            controller.initializeQuestions();

            //first section
            List<QuizItem> lqi = controller.quizItemList;

            for(QuizItem qi : lqi){
                qi.response	 = mResponses.get(qi.question.Id);
            }

            controller.next();

            //second section
            List<QuizItem> lqi2 = controller.quizItemList;

            for(QuizItem qi : lqi2){
                qi.response	 = mResponses.get(qi.question.Id);
            }
            //controller.previous();
            controller.next();

            //third & final section
            List<QuizItem> lqi3 = controller.quizItemList;

            for(QuizItem qi : lqi3){
                qi.response	 = mResponses.get(qi.question.Id);
            }
            controller.done();
        }
    }

    static testmethod void testQuizViewerWeb2(){
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }
        Test.stopTest();

        List<Training_Plan_Section__c> ltpsec = [select id from Training_Plan_Section__c where Training_Plan__c =: tplanId order by Order__c asc];
        System.assert(ltpsec.size() == 3);

        List<Training_Plan_Section_Item__c> ltpsitem = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(0).Id order by Order__c asc];
        System.assert(ltpsitem.size() == 1, 'Training Plan Section Item issues, size = ' + ltpsitem.size());

        List<Learning_Assignment__c> lassignment = [select Id,
                                                        Learning__c, Learning_Version__r.Quiz__c from Learning_Assignment__c
                                                        where Training_Plan__c =: tplanId
                                                        and Training_Plan_Section__c =:ltpsec.get(0).Id
                                                        and User__c =: lmsUsers.get(0).Id];

        System.assert(lassignment.size() == 1, 'Learning Assignment issues, size = ' + lassignment.size());
        System.assert(lassignment.get(0).Learning_Version__r.Quiz__c != null, 'Learning Assignment is not for Quiz');

        Set<Id> qlineIds = new Set<Id>();
        for(Question_Line__c oql : [select Id from Question_Line__c where Quiz__c =: lassignment.get(0).Learning_Version__r.Quiz__c]){
            qlineIds.add(oql.Id);
        }

        Map<String, Response__c> mResponses = TestLearningData.createTestQuestionResponses(qlineIds, lmsUsers.get(0).Id, lassignment.get(0).Id);


        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.QuizViewer;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:25.0) Gecko/20100101 Firefox/25.0');
            pageRef.getParameters().put('aid', lassignment.get(0).Id);
            QuizViewerController controller = new QuizViewerController();
            controller.initializeQuestions();

            //first section
            List<QuizItem> lqi = controller.quizItemList;

            for(QuizItem qi : lqi){
                qi.response	 = mResponses.get(qi.question.Id);
            }

            controller.next();
            controller.previous();
            PageReference redirect = controller.backToTrainingPlan();
            System.assert(redirect.getParameters().get('id') == tplanId, 'backToTrainingPlan is not adding params properly');

            //go back to quiz & reset it
            PageReference pageRef2 = Page.QuizViewer;
            Test.setCurrentPage(pageRef2);
            pageRef.getHeaders().put('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:25.0) Gecko/20100101 Firefox/25.0');
            pageRef2.getParameters().put('aid', lassignment.get(0).Id);
            QuizViewerController controller2 = new QuizViewerController();
            controller2.initializeQuestions();
            PageReference redirect2 = controller2.reset();
            System.assert(redirect2.getParameters().get('aid') == lassignment.get(0).Id, 'reset is not adding params properly');


        }
    }

    static testmethod void testQuizViewerMobile(){
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }
        Test.stopTest();

        List<Training_Plan_Section__c> ltpsec = [select id from Training_Plan_Section__c where Training_Plan__c =: tplanId order by Order__c asc];
        System.assert(ltpsec.size() == 3);

        List<Training_Plan_Section_Item__c> ltpsitem = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(0).Id order by Order__c asc];
        System.assert(ltpsitem.size() == 1, 'Training Plan Section Item issues, size = ' + ltpsitem.size());

        List<Learning_Assignment__c> lassignment = [select Id,
                                                        Learning__c, Learning_Version__r.Quiz__c from Learning_Assignment__c
                                                        where Training_Plan__c =: tplanId
                                                        and Training_Plan_Section__c =:ltpsec.get(0).Id
                                                        and User__c =: lmsUsers.get(0).Id];

        System.assert(lassignment.size() == 1, 'Learning Assignment issues, size = ' + lassignment.size());
        System.assert(lassignment.get(0).Learning_Version__r.Quiz__c != null, 'Learning Assignment is not for Quiz');

        Set<Id> qlineIds = new Set<Id>();
        for(Question_Line__c oql : [select Id from Question_Line__c where Quiz__c =: lassignment.get(0).Learning_Version__r.Quiz__c]){
            qlineIds.add(oql.Id);
        }

        Map<String, Response__c> mResponses = TestLearningData.createTestQuestionResponses(qlineIds, lmsUsers.get(0).Id, lassignment.get(0).Id);


        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.QuizViewer;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53');
            pageRef.getParameters().put('aid', lassignment.get(0).Id);
            QuizViewerController controller = new QuizViewerController();
            controller.initializeQuestions();

            //first section
            List<QuizItem> lqi = controller.quizItemList;

            for(QuizItem qi : lqi){
                qi.response	 = mResponses.get(qi.question.Id);
            }

            controller.next();

            //second section
            List<QuizItem> lqi2 = controller.quizItemList;

            for(QuizItem qi : lqi2){
                qi.response	 = mResponses.get(qi.question.Id);
            }
            //controller.previous();
            controller.next();

            //third & final section
            List<QuizItem> lqi3 = controller.quizItemList;

            for(QuizItem qi : lqi3){
                qi.response	 = mResponses.get(qi.question.Id);
            }
            controller.done();
        }
    }

    static testmethod void testQuizViewerMobile2(){
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }
        Test.stopTest();

        List<Training_Plan_Section__c> ltpsec = [select id from Training_Plan_Section__c where Training_Plan__c =: tplanId order by Order__c asc];
        System.assert(ltpsec.size() == 3);

        List<Training_Plan_Section_Item__c> ltpsitem = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(0).Id order by Order__c asc];
        System.assert(ltpsitem.size() == 1, 'Training Plan Section Item issues, size = ' + ltpsitem.size());

        List<Learning_Assignment__c> lassignment = [select Id,
                                                        Learning__c, Learning_Version__r.Quiz__c from Learning_Assignment__c
                                                        where Training_Plan__c =: tplanId
                                                        and Training_Plan_Section__c =:ltpsec.get(0).Id
                                                        and User__c =: lmsUsers.get(0).Id];

        System.assert(lassignment.size() == 1, 'Learning Assignment issues, size = ' + lassignment.size());
        System.assert(lassignment.get(0).Learning_Version__r.Quiz__c != null, 'Learning Assignment is not for Quiz');

        Set<Id> qlineIds = new Set<Id>();
        for(Question_Line__c oql : [select Id from Question_Line__c where Quiz__c =: lassignment.get(0).Learning_Version__r.Quiz__c]){
            qlineIds.add(oql.Id);
        }

        Map<String, Response__c> mResponses = TestLearningData.createTestQuestionResponses(qlineIds, lmsUsers.get(0).Id, lassignment.get(0).Id);


        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.QuizViewer;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53');
            pageRef.getParameters().put('aid', lassignment.get(0).Id);
            QuizViewerController controller = new QuizViewerController();
            controller.initializeQuestions();

            //first section
            List<QuizItem> lqi = controller.quizItemList;

            for(QuizItem qi : lqi){
                qi.response	 = mResponses.get(qi.question.Id);
            }

            controller.next();
            controller.previous();
            PageReference redirect = controller.backToTrainingPlan();
            System.assert(redirect.getParameters().get('id') == tplanId, 'backToTrainingPlan is not adding params properly');

            //go back to quiz & reset it
            PageReference pageRef2 = Page.QuizViewer;
            Test.setCurrentPage(pageRef2);
            pageRef.getHeaders().put('User-Agent', 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53');
            pageRef2.getParameters().put('aid', lassignment.get(0).Id);
            QuizViewerController controller2 = new QuizViewerController();
            controller2.initializeQuestions();
            PageReference redirect2 = controller2.reset();
            System.assert(redirect2.getParameters().get('aid') == lassignment.get(0).Id, 'reset is not adding params properly');
        }
    }

    static testmethod void testQuizViewerPreview(){
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }
        Test.stopTest();

        List<Training_Plan_Section__c> ltpsec = [select id from Training_Plan_Section__c where Training_Plan__c =: tplanId order by Order__c asc];
        System.assert(ltpsec.size() == 3);

        List<Training_Plan_Section_Item__c> ltpsitem = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(0).Id order by Order__c asc];
        System.assert(ltpsitem.size() == 1, 'Training Plan Section Item issues, size = ' + ltpsitem.size());

        List<Learning_Assignment__c> lassignment = [select Id,
                                                        Learning__c, Learning_Version__r.Quiz__c from Learning_Assignment__c
                                                        where Training_Plan__c =: tplanId
                                                        and Training_Plan_Section__c =:ltpsec.get(0).Id
                                                        and User__c =: lmsUsers.get(0).Id];

        System.assert(lassignment.size() == 1, 'Learning Assignment issues, size = ' + lassignment.size());
        System.assert(lassignment.get(0).Learning_Version__r.Quiz__c != null, 'Learning Assignment is not for Quiz');

        Set<Id> qlineIds = new Set<Id>();
        for(Question_Line__c oql : [select Id from Question_Line__c where Quiz__c =: lassignment.get(0).Learning_Version__r.Quiz__c]){
            qlineIds.add(oql.Id);
        }

        Map<String, Response__c> mResponses = TestLearningData.createTestQuestionResponses(qlineIds, lmsUsers.get(0).Id, lassignment.get(0).Id);


        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.QuizViewer;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:25.0) Gecko/20100101 Firefox/25.0');
            pageRef.getParameters().put('aid', lassignment.get(0).Id);
            pageRef.getParameters().put('pMode', 'true');

            QuizViewerController controller = new QuizViewerController();
            controller.initializeQuestions();

            //first section
            List<QuizItem> lqi = controller.quizItemList;

            for(QuizItem qi : lqi){
                qi.response	 = mResponses.get(qi.question.Id);
            }

            controller.next();

            //second section
            List<QuizItem> lqi2 = controller.quizItemList;

            for(QuizItem qi : lqi2){
                qi.response	 = mResponses.get(qi.question.Id);
            }
            //controller.previous();
            controller.next();

            //third & final section
            List<QuizItem> lqi3 = controller.quizItemList;

            for(QuizItem qi : lqi3){
                qi.response	 = mResponses.get(qi.question.Id);
            }
            controller.done();
        }
    }

    // TestTrainingCatalogController
    static testMethod void testCatalogPageWithInvalidCategoryId(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        PageReference ref = Page.TrainingCatalogDetail;
        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
            		System.debug('lmsUsers.get(0) :' + lmsUsers.get(0));
                TrainingCatalogDetailController cont = new TrainingCatalogDetailController();
                System.assertEquals(0,cont.tPlans.size());
            }

        Test.stopTest();

    }
		
    static testMethod void testWithValidCategoryId(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
				
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;
        tplan.Self_Registration_Access__c = 'Public';
        update tplan;

        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));

        List<Training_Plan_Category__c> tplanCategories = [select id
                                                                ,Learning_Category__c
                                                                from Training_Plan_Category__c
                                                                where Training_Plan__c = :tplan.Id];
        PageReference ref = Page.TrainingCatalogDetail;
        ref.getParameters().put('id',tplanCategories.get(0).Learning_Category__c);

        Test.setCurrentPageReference(ref);
        
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingCatalogDetailController cont = new TrainingCatalogDetailController();
                System.assert(cont.tPlans.size()>0);
            }
        Test.stopTest();
				
    }
		
    private static Integer getTrainingPlanAssignmentsCount(Id tplanId){
        return [select count() from Training_Plan_Assignment__c where Training_Plan__c = :tplanId];
    }


    /*
     *Author : JRC
      *Description : method to get all picklist value from target audience field in training plan object
      *Date Created :
      *Last Modified By : 
      *Date Last Modified :
      *Param : 
      *Return : 
    */ 
     static testMethod void getfilterTargetAudienceTest() {
        TrainingCatalogHomeController trainingCatHome = new TrainingCatalogHomeController();
        System.debug(trainingCatHome.getfilterTargetAudience());
     }

    /*
      *Author : JRC
      *Description : method to get all picklist value from Training Plan Type field in training plan object
      *Date Created :
      *Last Modified By : 
      *Date Last Modified :
      *Param : 
      *Return : 
    */ 
      static testMethod void getfilterTrainingPlanTypeTest() {
        TrainingCatalogHomeController trainingCatHome = new TrainingCatalogHomeController();
        System.debug(trainingCatHome.getfilterTrainingPlanType());
    }


        
    /*
      *Author : JRC
      *Description : method to get all picklist value from Category field in training plan object
      *Date Created :
      *Last Modified By : 
      *Date Last Modified :
      *Param : 
      *Return : 
     */ 
    static testMethod void getfilterCategoryTest() {
        TrainingCatalogHomeController trainingCatHome = new TrainingCatalogHomeController();
        System.debug(trainingCatHome.getfilterCategory());
    }

    /*
       *Author : JRC
      *Description : method to get all training plan from filter
      *Date Created :
      *Last Modified By : 
      *Date Last Modified :
      *Param : 
      *Return : 
     */ 
    static testMethod void allFilterTrainingPlanTest() {
        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();

        List<Training_Plan__c> tplans = [select id
        ,Enable_Self_Registration__c
        ,Self_Registration_Access__c
        from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;
        tplan.Self_Registration_Access__c = 'Public';
        update tplan;
  list<String> param = new list<String>{
          '{"TargetAudience":["Industry pharmacist","General practice pharmacist"],"CourseType":["Australian Pharmacist","Blended learning"],"Category":[],"Delivery":[]}'
          ,'dpn'
        };

        TrainingCatalogHomeController.allFilterTrainingPlan(param);

         list<String> param2 = new list<String>{
          '{"TargetAudience":["Industry pharmacist","General practice pharmacist"],"CourseType":["Australian Pharmacist","Blended learning"],"Category":[],"Delivery":[]}'
          ,'dpo'
        };

        TrainingCatalogHomeController.allFilterTrainingPlan(param2);

         list<String> param3 = new list<String>{
          '{"TargetAudience":["Industry pharmacist","General practice pharmacist"],"CourseType":["Australian Pharmacist","Blended learning"],"Category":[],"Delivery":[]}'
          ,'az'
        };

        TrainingCatalogHomeController.allFilterTrainingPlan(param3);

         list<String> param4 = new list<String>{
          '{"TargetAudience":["Industry pharmacist","General practice pharmacist"],"CourseType":["Australian Pharmacist","Blended learning"],"Category":[],"Delivery":[]}'
          ,'za'
        };

        TrainingCatalogHomeController.allFilterTrainingPlan(param4);

        list<String> param5 = new list<String>{
          '{"TargetAudience":["Industry pharmacist","General practice pharmacist"],"CourseType":["Australian Pharmacist","Blended learning"],"Category":[],"Delivery":[]}'
          ,'accExDateOtoN'
        }; 

        TrainingCatalogHomeController.allFilterTrainingPlan(param5);
    }

    // TestTrainingCatalogHomeCtrl
    static testMethod void testCatalogPageWithoutEntries(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        PageReference ref = Page.TrainingCatalogHome;
        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingCatalogHomeController cont = new TrainingCatalogHomeController();
                System.assertEquals(0,cont.lcategories.size());
            }
        Test.stopTest();

    }

    static testMethod void testCatalogPageWithEntries(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();

        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;
        tplan.Self_Registration_Access__c = 'Public';
        update tplan;

        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));

        PageReference ref = Page.TrainingCatalogHome;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingCatalogHomeController cont = new TrainingCatalogHomeController();
                System.assert(cont.lcategories.size()>0);
            }
        Test.stopTest();

    }

    // private static Integer getTrainingPlanAssignmentsCount(Id tplanId){
    //     return [select count() from Training_Plan_Assignment__c where Training_Plan__c = :tplanId];
    // }

    // TestTrainingPlanPreviewCtrl
    static testMethod void testPreviewRedirection(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;
        tplan.Self_Registration_Access__c = 'Public';
        update tplan;

        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));

        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);
        ref.getHeaders().put('User-Agent', 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53');

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                System.debug('Tplan '+cont.tPlan);
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }

    static testMethod void testPreviewRegistration(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size()); 
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;
        tplan.Self_Registration_Access__c = 'Public';
        tplan.type__c = 'Public';
        update tplan;

        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));

        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                //System.assert(cont.tPlan != null);
                //Register for public trainign plan
                cont.registerForTrainingPlan();
                //System.assertEquals(1,getTrainingPlanAssignmentsCount(tplan.Id));
            }

        Test.stopTest();

    }

    static testMethod void testPreviewRegistrationWithApprovalEntries(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;
        tplan.Self_Registration_Access__c = 'Requires Approval';
        update tplan;

        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));

        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id); 

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                //System.assert(cont.tPlan != null);
                PageReference contRef = cont.fetchTrainingPlanInfo();
                //Confirm we don't have any access requests in the system
                //System.assertEquals(0,getTrainingPlanAccessRequestCount(tplan.Id));
                //Submit request
                contRef = cont.requestAccessForTrainingPlan();
                //Confirm request creation
                //System.assertEquals(1,getTrainingPlanAccessRequestCount(tplan.Id));

            }

        Test.stopTest();

    }
    
    // test added by John Hope
    static testMethod void testPreviewOtherCode(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size()); 
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;
        tplan.Self_Registration_Access__c = 'Public';
        tplan.type__c = 'Member Only (Free)';
        update tplan;

        System.debug( 'weeeeeee tplan' + tplan );

        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));

        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();   
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                System.debug('tpLan debug '+cont.tPlan);
                //System.assert(cont.tPlan != null);
                //Register for public trainign plan
                cont.registerForTrainingPlan();
                
                cont.redirectToPlanDetailPage();
                
                cont.hasTrainingPlanAssignment();
                
                cont.createTrainingPlanBookmark();
            }

        Test.stopTest();

    } 

 
    static testMethod void testPreviewRedirectionWithUser(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = DateTime.now().getTime()+'Alpha';
        acc.LastName = DateTime.now().getTime()+'Sys';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'bannegroupuser'+DateTime.now().getTime()+'@testorg.com';
        acc.AS_Membership_Status__pc = 'Current';
        acc.AS_AHPRA_Number__pc = '123456789';
        insert acc;
        
        Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail =:acc.PersonEmail LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        
        User use = new User(Alias = generateRandomString(6), Email=acc.PersonEmail,
                            EmailEncodingKey='UTF-8', LastName=acc.LastName, LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = forMemMatchCon.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true, 
                            UserName=uniqueUserName1);
        
        list<User> lmsUsers  = new List<User>();
        lmsUsers.add(use);
        insert lmsUsers;
        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
     //       TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Only (Free)';
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                //cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }


    static testMethod void testPreviewRedirectionWithUserNonMember(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = DateTime.now().getTime()+'Alpha';
        acc.LastName = DateTime.now().getTime()+'Sys';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'bannegroupuser'+DateTime.now().getTime()+'@testorg.com';
        acc.AS_Membership_Status__pc = 'Current';
        acc.AS_AHPRA_Number__pc = '123456789';
        insert acc;
        
        Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail =:acc.PersonEmail LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Non Member Login User'];
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        
        User use = new User(Alias = generateRandomString(6), Email=acc.PersonEmail,
                            EmailEncodingKey='UTF-8', LastName=acc.LastName, LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = forMemMatchCon.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true, 
                            UserName=uniqueUserName1);
        
        list<User> lmsUsers  = new List<User>();
        lmsUsers.add(use);
        insert lmsUsers;
        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
     //       TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id,Pre_Requisite_1__c,Pre_Requisite_2__c,Pre_Requisite_3__c,Related_Education_1__c,Related_Education_2__c,Related_Education_3__c,Related_Education_4__c
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        TestTrainingTrackData.createSampleData();
        List<Training_Track__c> tracks = [select id,name,PSA_Pre_Requisite_1__c,
                                          PSA_Pre_Requisite_2__c,PSA_Pre_Requisite_3__c,PSA_Related_Education_1__c,PSA_Related_Education_2__c,
                                          PSA_Related_Education_3__c,PSA_Related_Education_4__c from Training_Track__c];
        
        
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, null, 'Achievements');
        List<Training_Plan__c> tplistInsert=new List<Training_Plan__c>();
        for(Integer  i=0;i<8;i++){
            Training_Plan__c tp=new Training_Plan__c();
            tp.Achievement__c=lAchievement[0].Id;
            tp.Name='Training plan';
            tplistInsert.add(tp);
        }
        insert tplistInsert;
        system.debug('tplistInsert data ** '+tplistInsert.size());
        
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Only (Free)';
        tplan.Pre_Requisite_1__c=tplistInsert[0].Id;
        tplan.Pre_Requisite_2__c=tplistInsert[1].Id;
        tplan.Pre_Requisite_3__c=tplistInsert[2].Id;
        tplan.Related_Education_1__c=tplistInsert[3].Id;
        tplan.Related_Education_2__c=tplistInsert[4].Id;
        tplan.Related_Education_3__c=tplistInsert[5].Id;
        tplan.Related_Education_4__c=tplistInsert[6].Id;
        update tplan;
        
        Training_Track__c ttrack = tracks.get(0);
        ttrack.PSA_Pre_Requisite_1__c=tplistInsert[0].Id;
        ttrack.PSA_Pre_Requisite_2__c=tplistInsert[1].Id;
        ttrack.PSA_Pre_Requisite_3__c=tplistInsert[2].Id;
        ttrack.PSA_Related_Education_1__c=tplistInsert[3].Id;
        ttrack.PSA_Related_Education_2__c=tplistInsert[4].Id;
        ttrack.PSA_Related_Education_3__c=tplistInsert[5].Id;
        ttrack.PSA_Related_Education_4__c=tplistInsert[6].Id;
        update ttrack;
        
        // Create Education FAQ Data
		Education_FAQ__c edFAQ=new Education_FAQ__c();
        edFAQ.Type__c ='CPD';
        edFAQ.Answer__c ='test Answer';
      	edFAQ.Question__c ='Test Question';
        insert edFAQ;
        
        // Create Plan FAQ
        Training_Plan_FAQ__c planFAQ =new Training_Plan_FAQ__c();
        planFAQ.Education_FAQ__c=edFAQ.Id;
        planFAQ.Training_Plan__c=tplan.Id;
            insert planFAQ;
        
        // Create Track FAQ
        Training_Track_FAQ__c trackFAQ =new Training_Track_FAQ__c();
        trackFAQ.Education_FAQ__c=edFAQ.Id;
        trackFAQ.Training_Track__c= ttrack.Id;
            insert trackFAQ;
            
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                LMSWrappersService.getTrainingPlanDetails(tplan.Id,lmsUsers[0].Id,true,true);
                LMSWrappersService.getTrainingTrackDetails(tplan.Id);
                //cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }


    static testMethod void testPreviewRedirectionWithUser_PaidError(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = DateTime.now().getTime()+'Alpha';
        acc.LastName = DateTime.now().getTime()+'Sys';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'bannegroupuser'+DateTime.now().getTime()+'@testorg.com';
        acc.AS_Membership_Status__pc = 'Current';
        acc.AS_AHPRA_Number__pc = '123456789';
        insert acc;
        
        Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail =:acc.PersonEmail LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        
        User use = new User(Alias = generateRandomString(6), Email=acc.PersonEmail,
                            EmailEncodingKey='UTF-8', LastName=acc.LastName, LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = forMemMatchCon.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true, 
                            UserName=uniqueUserName1);
        
        list<User> lmsUsers  = new List<User>();
        lmsUsers.add(use);
        insert lmsUsers;
        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
     //       TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        //System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Paid';
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                //cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }

    static testMethod void testPreviewRedirectionWithUser_Paid(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = DateTime.now().getTime()+'Alpha';
        acc.LastName = DateTime.now().getTime()+'Sys';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'bannegroupuser'+DateTime.now().getTime()+'@testorg.com';
        acc.AS_Membership_Status__pc = 'Current';
        acc.AS_AHPRA_Number__pc = '123456789';
        insert acc;
        
        Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail =:acc.PersonEmail LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        
        User use = new User(Alias = generateRandomString(6), Email=acc.PersonEmail,
                            EmailEncodingKey='UTF-8', LastName=acc.LastName, LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = forMemMatchCon.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true, 
                            UserName=uniqueUserName1);
        
        list<User> lmsUsers  = new List<User>();
        lmsUsers.add(use);
        insert lmsUsers;
        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
     //       TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        PriceBook2 pb = new PriceBook2(Name='PSA Member',IsActive=true);
        insert pb;
        
        Product2 prod = new Product2(Name = 'Test', ProductCode = 'test123', IsActive = true);
        insert prod;
        System.assert(prod != null, 'Product is empty');
        
        Id pricebookId = Test.getStandardPricebookId();        
        System.assert(pricebookId != null, 'StandardPricebookId is empty');
        
        List<PricebookEntry> allPbe = new List<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, 
                                                Product2Id = prod.Id,
                                                UnitPrice = 200, 
                                                IsActive = true);
        allPbe.add(pbe);
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                 Product2Id = prod.Id,
                                                 UnitPrice = 200, 
                                                 IsActive = true);
        allPbe.add(pbe2);
        insert allPbe;


        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Paid'; 
        tplan.AS_Product__c                = prod.Id;
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                //cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }


    static testMethod void testPreviewRedirectionWithUser_RTO(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = DateTime.now().getTime()+'Alpha';
        acc.LastName = DateTime.now().getTime()+'Sys';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'bannegroupuser'+DateTime.now().getTime()+'@testorg.com';
        acc.AS_Membership_Status__pc = 'Current';
        acc.AS_AHPRA_Number__pc = '123456789';
        insert acc;
        
        Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail =:acc.PersonEmail LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        
        User use = new User(Alias = generateRandomString(6), Email=acc.PersonEmail,
                            EmailEncodingKey='UTF-8', LastName=acc.LastName, LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = forMemMatchCon.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true, 
                            UserName=uniqueUserName1);
        
        list<User> lmsUsers  = new List<User>();
        lmsUsers.add(use);
        insert lmsUsers;
        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
     //       TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'RTO';
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                //cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }


    static testMethod void testPreviewRedirectionWithNonMemUser_MemberBenefit(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = DateTime.now().getTime()+'Alpha';
        acc.LastName = DateTime.now().getTime()+'Sys';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'bannegroupuser'+DateTime.now().getTime()+'@testorg.com';
        acc.AS_Membership_Status__pc = 'Current';
        acc.AS_AHPRA_Number__pc = '123456789';
        insert acc;
        
        Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail =:acc.PersonEmail LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        
        User use = new User(Alias = generateRandomString(6), Email=acc.PersonEmail,
                            EmailEncodingKey='UTF-8', LastName=acc.LastName, LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = forMemMatchCon.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true, 
                            UserName=uniqueUserName1);
        
        list<User> lmsUsers  = new List<User>();
        lmsUsers.add(use);
        insert lmsUsers;
        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
     //       TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Benefit';
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                //cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }
  
 


    static testMethod void testPreviewRedirectionWithUser_MemberBenefit_withOpp(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = DateTime.now().getTime()+'Alpha';
        acc.LastName = DateTime.now().getTime()+'Sys';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'bannegroupuser'+DateTime.now().getTime()+'@testorg.com';
        acc.AS_Membership_Status__pc = 'Current';
        acc.AS_AHPRA_Number__pc = '123456789';
        insert acc;
        
        Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail =:acc.PersonEmail LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Non Member Login User'];
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        
        User use = new User(Alias = generateRandomString(6), Email=acc.PersonEmail,
                            EmailEncodingKey='UTF-8', LastName=acc.LastName, LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = forMemMatchCon.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true, 
                            UserName=uniqueUserName1);
        
        list<User> lmsUsers  = new List<User>();
        lmsUsers.add(use);
        insert lmsUsers;
        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
     //       TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        PriceBook2 pb = new PriceBook2(Name='PSA Non-Member',IsActive=true);
        insert pb;
        
        Product2 prod = new Product2(Name = 'Test', ProductCode = 'test123', IsActive = true);
        insert prod;
        System.assert(prod != null, 'Product is empty');
        
        Id pricebookId = Test.getStandardPricebookId();        
        System.assert(pricebookId != null, 'StandardPricebookId is empty');
        
        List<PricebookEntry> allPbe = new List<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, 
                                                Product2Id = prod.Id,
                                                UnitPrice = 200, 
                                                IsActive = true);
        allPbe.add(pbe);
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                 Product2Id = prod.Id,
                                                 UnitPrice = 200, 
                                                 IsActive = true);
        allPbe.add(pbe2);
        insert allPbe;


        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Benefit'; 
        tplan.AS_Product__c                = prod.Id;
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                //cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }



    static testMethod void testPreviewRedirectionWithUser_MemberBenefit_withOpp_Error(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = DateTime.now().getTime()+'Alpha';
        acc.LastName = DateTime.now().getTime()+'Sys';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'bannegroupuser'+DateTime.now().getTime()+'@testorg.com';
        acc.AS_Membership_Status__pc = 'Current';
        acc.AS_AHPRA_Number__pc = '123456789';
        insert acc;
        
        Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail =:acc.PersonEmail LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Non Member Login User'];
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        
        User use = new User(Alias = generateRandomString(6), Email=acc.PersonEmail,
                            EmailEncodingKey='UTF-8', LastName=acc.LastName, LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = forMemMatchCon.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true, 
                            UserName=uniqueUserName1);
        
        list<User> lmsUsers  = new List<User>();
        lmsUsers.add(use);
        insert lmsUsers;
        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
     //       TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        PriceBook2 pb = new PriceBook2(Name='PSA Member',IsActive=true);
        insert pb;
        
        Product2 prod = new Product2(Name = 'Test', ProductCode = 'test123', IsActive = true);
        insert prod;
        System.assert(prod != null, 'Product is empty');
        
        Id pricebookId = Test.getStandardPricebookId();        
        System.assert(pricebookId != null, 'StandardPricebookId is empty');
        
        List<PricebookEntry> allPbe = new List<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, 
                                                Product2Id = prod.Id,
                                                UnitPrice = 200, 
                                                IsActive = true);
        allPbe.add(pbe);
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                 Product2Id = prod.Id,
                                                 UnitPrice = 200, 
                                                 IsActive = true);
        allPbe.add(pbe2);
        insert allPbe;


        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Benefit'; 
        tplan.AS_Product__c                = prod.Id;
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                //cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }
 

    static testMethod void testPreviewRedirectionWithUser_MemberOnlyPaidWithOpp(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = DateTime.now().getTime()+'Alpha';
        acc.LastName = DateTime.now().getTime()+'Sys';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'bannegroupuser'+DateTime.now().getTime()+'@testorg.com';
        acc.AS_Membership_Status__pc = 'Current';
        acc.AS_AHPRA_Number__pc = '123456789';
        insert acc;
        
        Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail =:acc.PersonEmail LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        
        User use = new User(Alias = generateRandomString(6), Email=acc.PersonEmail,
                            EmailEncodingKey='UTF-8', LastName=acc.LastName, LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = forMemMatchCon.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true, 
                            UserName=uniqueUserName1);
        
        list<User> lmsUsers  = new List<User>();
        lmsUsers.add(use);
        insert lmsUsers;
        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
     //       TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        PriceBook2 pb = new PriceBook2(Name='PSA Member',IsActive=true);
        insert pb;
        
        Product2 prod = new Product2(Name = 'Test', ProductCode = 'test123', IsActive = true);
        insert prod;
        System.assert(prod != null, 'Product is empty');
        
        Id pricebookId = Test.getStandardPricebookId();        
        System.assert(pricebookId != null, 'StandardPricebookId is empty');
        
        List<PricebookEntry> allPbe = new List<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, 
                                                Product2Id = prod.Id,
                                                UnitPrice = 200, 
                                                IsActive = true);
        allPbe.add(pbe);
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                 Product2Id = prod.Id,
                                                 UnitPrice = 200, 
                                                 IsActive = true);
        allPbe.add(pbe2);
        insert allPbe;


        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Only (Paid)'; 
        tplan.AS_Product__c                = prod.Id;
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                //cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }
 

    static testMethod void testPreviewRedirectionWithUser_MemberOnlyPaidWithWithOutOpp(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = DateTime.now().getTime()+'Alpha';
        acc.LastName = DateTime.now().getTime()+'Sys';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'bannegroupuser'+DateTime.now().getTime()+'@testorg.com';
        acc.AS_Membership_Status__pc = 'Current';
        acc.AS_AHPRA_Number__pc = '123456789';
        insert acc;
        
        Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail =:acc.PersonEmail LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Member Login User'];
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        
        User use = new User(Alias = generateRandomString(6), Email=acc.PersonEmail,
                            EmailEncodingKey='UTF-8', LastName=acc.LastName, LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = forMemMatchCon.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true, 
                            UserName=uniqueUserName1);
        
        list<User> lmsUsers  = new List<User>();
        lmsUsers.add(use);
        insert lmsUsers;
        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
     //       TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        PriceBook2 pb = new PriceBook2(Name='PSA Non-Member',IsActive=true);
        insert pb;
        
        Product2 prod = new Product2(Name = 'Test', ProductCode = 'test123', IsActive = true);
        insert prod;
        System.assert(prod != null, 'Product is empty');
        
        Id pricebookId = Test.getStandardPricebookId();        
        System.assert(pricebookId != null, 'StandardPricebookId is empty');
        
        List<PricebookEntry> allPbe = new List<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, 
                                                Product2Id = prod.Id,
                                                UnitPrice = 200, 
                                                IsActive = true);
        allPbe.add(pbe);
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                 Product2Id = prod.Id,
                                                 UnitPrice = 200, 
                                                 IsActive = true);
        allPbe.add(pbe2);
        insert allPbe;


        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Only (Paid)'; 
        tplan.AS_Product__c                = prod.Id;
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                //cont.eventEnrol(); 
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }


    static testMethod void testPreviewRedirectionWithNonMemberUser_MemberOnlyPaidWithWithOpp(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        Id personAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = DateTime.now().getTime()+'Alpha';
        acc.LastName = DateTime.now().getTime()+'Sys';
        acc.recordTypeId = personAccRecId;
        acc.PersonEmail = 'bannegroupuser'+DateTime.now().getTime()+'@testorg.com';
        acc.AS_Membership_Status__pc = 'Current';
        acc.AS_AHPRA_Number__pc = '123456789';
        insert acc;
        
        Account forMemMatchCon = [Select Id,PersonContactId from Account where PersonEmail =:acc.PersonEmail LIMIT 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Non Member Login User'];
        String uniqueUserName1 = 'memberuser' + DateTime.now().getTime() + '@testorg.com';
        
        User use = new User(Alias = generateRandomString(6), Email=acc.PersonEmail,
                            EmailEncodingKey='UTF-8', LastName=acc.LastName, LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            ContactId = forMemMatchCon.PersonContactId,
                            TimeZoneSidKey='America/Los_Angeles',
                            isActive = true, 
                            UserName=uniqueUserName1);
        
        list<User> lmsUsers  = new List<User>();
        lmsUsers.add(use);
        insert lmsUsers;
        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
     //       TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        PriceBook2 pb = new PriceBook2(Name='PSA Non-Member',IsActive=true);
        insert pb;
        
        Product2 prod = new Product2(Name = 'Test', ProductCode = 'test123', IsActive = true);
        insert prod;
        System.assert(prod != null, 'Product is empty');
        
        Id pricebookId = Test.getStandardPricebookId();        
        System.assert(pricebookId != null, 'StandardPricebookId is empty');
        
        List<PricebookEntry> allPbe = new List<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pricebookId, 
                                                Product2Id = prod.Id,
                                                UnitPrice = 200, 
                                                IsActive = true);
        allPbe.add(pbe);
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                 Product2Id = prod.Id,
                                                 UnitPrice = 200, 
                                                 IsActive = true);
        allPbe.add(pbe2);
        insert allPbe;


        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;  
        tplan.Self_Registration_Access__c = 'External';
        tplan.Type__c = 'Member Only (Paid)'; 
        tplan.AS_Product__c                = prod.Id;
        update tplan;
 
        System.assertEquals(0,getTrainingPlanAssignmentsCount(tplan.Id));
 
        PageReference ref = Page.TrainingPlanPreview;
        ref.getParameters().put('id',tplan.Id);

        Test.setCurrentPageReference(ref);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                TrainingPlanPreviewController cont = new TrainingPlanPreviewController();
                //cont.eventEnrol(); 
                cont.checkAssignment();
                //System.assert(cont.tPlan != null);
            }
        Test.stopTest();

    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    // private static Integer getTrainingPlanAssignmentsCount(Id tplanId){
    //     return [select count() from Training_Plan_Assignment__c where Training_Plan__c = :tplanId];
    // }

    private static Integer getTrainingPlanAccessRequestCount(Id tplanId){
        return [select count() from Training_Plan_Access_Request__c where Training_Plan__c = :tplanId];
    }

    // TestTrainingTrackDetailCtrl
         @TestSetup  
    static void testData(){
        
        Id personAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
        List<Account> AsAccList = new List<Account>();
        
        Account acc = new Account();
        acc.FirstName = 'Sample Person';
        acc.LastName = 'Account';
        acc.PersonEmail = 'person@test.com';
        acc.RecordTypeId = personAccountId;
        AsAccList.add( acc );
        
        Account acc1 = new Account();
        acc1.FirstName = 'Sample Person1';
        acc1.LastName = 'Account1';
        acc1.PersonEmail = 'person1@test.com';
        acc1.RecordTypeId = personAccountId;
        AsAccList.add( acc1 );
        
        insert AsAccList;
        
        List<Profile> pro = [Select Id,Name from Profile where Name='Member Login User' LIMIT 1];
        Account accToUsed = [Select Id,PersonContactId from Account where Id = :AsAccList[0].Id limit 1];
        User indiUser = new User();
        indiUser.ContactId = accToUsed.PersonContactId;
        indiUser.profileid = (pro.size() > 0)?pro[0].Id:null;
        indiUser.FirstName = AsAccList[0].FirstName;
        indiUser.LastName = AsAccList[0].LastName;
        indiUser.Alias =string.valueof(AsAccList[0].FirstName.substring(0,1) + AsAccList[0].LastName.substring(0,2));
        indiUser.Email = 'person@test.com';
        indiUser.Username = 'person@test.com';
        indiUser.CommunityNickname = AsAccList[0].FirstName + AsAccList[0].LastName + AS_commonFunction.generateRandomIntString(2);
        indiUser.emailencodingkey='UTF-8';
        indiUser.languagelocalekey='en_US'; 
        indiUser.localesidkey='en_AU'; 
        indiUser.timezonesidkey='GMT';
        insert indiUser;
        
        List<Profile> pro1 = [Select Id,Name from Profile where Name='Non Member Login User' LIMIT 1];
        Account accToUsed1 = [Select Id,PersonContactId from Account where Id = :AsAccList[1].Id limit 1];
        User indiUser1 = new User();
        indiUser1.ContactId = accToUsed1.PersonContactId;
        indiUser1.profileid = (pro1.size() > 0)?pro1[0].Id:null;
        indiUser1.FirstName = AsAccList[1].FirstName;
        indiUser1.LastName = AsAccList[1].LastName;
        indiUser1.Alias =string.valueof(AsAccList[1].FirstName.substring(0,1) + AsAccList[1].LastName.substring(0,2));
        indiUser1.Email = 'person1@test.com';
        indiUser1.Username = 'person1@test.com';
        indiUser1.CommunityNickname = AsAccList[1].FirstName + AsAccList[1].LastName + AS_commonFunction.generateRandomIntString(2);
        indiUser1.emailencodingkey='UTF-8';
        indiUser1.languagelocalekey='en_US'; 
        indiUser1.localesidkey='en_AU'; 
        indiUser1.timezonesidkey='GMT';
        insert indiUser1;
        
    }

    static testMethod void testSharedTrackDetail(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingTrackData.createSampleData();
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        System.assertEquals(1,tracks.size());
        System.assert(trackItems.size()>0);
		set<id> trackids=new set<id>();
        for(Training_Track__c tt:tracks){
            trackids.add(tt.id);
        }
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = lmsUsers.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;
		// Create Education FAQ Data
		Education_FAQ__c edFAQ=new Education_FAQ__c();
        edFAQ.Type__c ='CPD';
        edFAQ.Answer__c ='test Answer';
      	edFAQ.Question__c ='Test Question';
        insert edFAQ;
        
        // Create Track FAQ
        Training_Track_FAQ__c trackFAQ =new Training_Track_FAQ__c();
        trackFAQ.Education_FAQ__c=edFAQ.Id;
        trackFAQ.Training_Track__c=tracks[0].Id;
            insert trackFAQ;

        Test.startTest();
		LMSService.queryRelatedTrainingTracks(trackids);
        LMSService.getTrainingTrackFAQs(trackids);
        LMSWrappersService.getTrainingTrackDetails(tracks[0].Id);
            PageReference pageRef = Page.TrainingTrackDetail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', tracks.get(0).Id);

            System.runAs(lmsUsers.get(0)){
                TrainingTrackDetailCtrl cont = new TrainingTrackDetailCtrl();
                
                System.assert(cont.track != null);
            }

        Test.stopTest();
        
    }
   
    
    static testMethod void paid() {
        
   
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        
        System.runAs(theUser.get(0)){
            //Assign corresponding perm sets
            //TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
           // TestUtilClass.addPermissionSet(theUser,'LMS_User');
        
        
        
        System.debug( 'testtttt' + theUser );
        
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;
            
        Id psaenrolment = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();

        TestTrainingTrackData.createSampleData();
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
        List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Diploma', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
        PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = true;
        contww.purchase();
        }
    }
    
    static testMethod void paid0() {
        
   
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        
        System.runAs(theUser.get(0)){
            //Assign corresponding perm sets
            //TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
           // TestUtilClass.addPermissionSet(theUser,'LMS_User');
        
        
        
        System.debug( 'testtttt' + theUser );
        
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;
            
        Id psaenrolment = Schema.SObjectType.Enrolment_Form__c.getRecordTypeInfosByName().get('PSA Enrolment').getRecordTypeId();

        TestTrainingTrackData.createSampleData();
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
            
        List<Account> AccListNew = [SELECT Id, Name FROM Account];
            
        Enrolment_Form__c Asenrolform = new Enrolment_Form__c(
            RecordTypeId = psaenrolment,
            AS_Account__c = AccListNew[0].Id,
            Enrolment_Status__c = 'Approved',
            AS_Learning_Package__c = lp.Id,
            AS_Processed__c = false
        );
        insert Asenrolform;
        
        List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Diploma', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
        PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = true;
        contww.purchase();
        }
    }
    
    static testMethod void paid1() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        
        System.runAs(theUser.get(0)){
        
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Member Only (Free)', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
        PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = true;
        contww.purchase();
        }
    }
    
    static testMethod void paid2() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        
        System.runAs(theUser.get(0)){
        
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Member Benefit', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = true;
        contww.purchase();
        }
    }
    
    static testMethod void paid3() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        
        System.runAs(theUser.get(0)){
        
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Member Only (Paid)', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = true;
        contww.purchase();
        }
    }
    
    static testMethod void paid4() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        
        System.runAs(theUser.get(0)){
        
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Paid', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = true;
        contww.purchase();
        }
    }
    
    static testMethod void paid5() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person@test.com' ];
        
        System.runAs(theUser.get(0)){
        
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Public', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = true;
        contww.purchase();
        }
    }

     
    static testMethod void paid6() {
        
   
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person1@test.com' ];
        
        System.runAs(theUser.get(0)){
            //Assign corresponding perm sets
            //TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
           // TestUtilClass.addPermissionSet(theUser,'LMS_User');
        
        
        
        System.debug( 'testtttt' + theUser );
        
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;

        TestTrainingTrackData.createSampleData();
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test',AS_Event_selection__c = true );
        insert lp;
        
        List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Diploma', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
        PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = false;
        contww.purchase();
        }
    }
    
    static testMethod void paid7() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person1@test.com' ];
        
        System.runAs(theUser.get(0)){
        
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Member Only (Free)', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
        PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = false;
        contww.purchase();
        }
    }
    
    static testMethod void paid8() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person1@test.com' ];
        
        System.runAs(theUser.get(0)){
        
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Member Benefit', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = false;
        contww.purchase();
        }
    }
    
    static testMethod void paid9() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person1@test.com' ];
        
        System.runAs(theUser.get(0)){
        
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Member Only (Paid)', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = false;
        contww.purchase();
        }
    }
    
    static testMethod void paid10() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person1@test.com' ];
        
        System.runAs(theUser.get(0)){
        
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Paid', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = false;
        contww.purchase();
        }
    }
    
    static testMethod void paid11() {
        
        List<User> theUser = [Select Id, AccountId,Account.PersonEmail,Contact.AccountId from User where Email = 'person1@test.com' ];
        
        System.runAs(theUser.get(0)){
        
        List<Training_Track__c> tracks = [select id,name from Training_Track__c];
        List<Training_Track_Level_Item__c> trackItems = [select id,name from Training_Track_Level_Item__c];
        
        List<Training_Track__Share> shares = new List<Training_Track__Share>();

        for(Training_Track__c t : tracks){
            Training_Track__Share tShr  = new Training_Track__Share();
            tShr.ParentId = t.Id;
            tShr.UserOrGroupId = theUser.get(0).Id;
            tShr.AccessLevel = 'Read';
            shares.add(tShr);
        }

        insert shares;
        
        Learning_Package__c lp = new Learning_Package__c( Name ='LP Test' );
        insert lp;
        
         List<Training_Track__c> wttt = new List<Training_Track__c>();
		wttt.add( new Training_Track__c( Name = 'TT1', AS_Track_Type__c = 'Public', AS_Learning_Package__c = lp.Id ) );
        insert wttt;
        
         PageReference pageRef = Page.TrainingTrackDetail;
        pageRef.getParameters().put( 'id', wttt[0].Id );
        
        Test.setCurrentPage(pageRef);

        TrainingTrackDetailCtrl contww = new TrainingTrackDetailCtrl();
        contww.canViewTrainPlan = false;
        contww.purchase();
        }
    }

    // TestTrainingPlansSearchCtrl
    static testMethod void testSearchWithEntries(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();

        List<Training_Plan__c> tplans = [select id
                                            ,Name
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans.get(0);
        tplan.Enable_Self_Registration__c = true;
        tplan.Self_Registration_Access__c = 'Public';
        update tplan;


        
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
            	PageReference ref = Page.TrainingPlansSearch;
            	System.debug('tplan : ' + tplan);
        ref.getParameters().put('q',tplan.Name);
        Test.setCurrentPageReference(ref);
                TrainingPlansSearchController cont = new TrainingPlansSearchController();
                
                System.assert(cont.getSearchResults().size()>0);
                System.assert(cont.hasMessages == false);
                System.assert(cont.getHasPrevious() == false);
                System.assert(cont.getHasNext() == false);
                System.assert(cont.getPageNumber() == 1);
                System.assert(cont.getTotalPages() == 1);
                
                cont.doNext();
                cont.doPrevious();
                System.assert(cont.hasMessages == false);
            }

        Test.stopTest();

    }

    // TestResourceViewerController
    static testMethod void testSimpleResource(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(1,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(1,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        Id learningAssignmentId = createResourceViewerData(adminUsers,lmsUsers,false);

        //Test Insert
        PageReference pageRef = Page.ResourceViewer;
        pageRef.getParameters().put('aid',learningAssignmentId);
        Test.setCurrentPage(pageRef);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                ResourceViewerController cont = new ResourceViewerController();
                String contRef = ResourceViewerController.redirectToResource(learningAssignmentId);
                System.assert(contRef != null);
                System.assert(contRef.indexOf('#t=1') != -1);
                List<Learning_Assignment__c> assignments;
                assignments = [select id,Progress__c from Learning_Assignment__c where id = :learningAssignmentId];
                System.assertEquals(LMSConstants.ASSIGNMENT_STATUS_COMPLETED,assignments.get(0).Progress__c);
            }

        Test.stopTest();
    }

    private static Id createResourceViewerData(List<User> adminUsers, List<User> lmsUsers,Boolean preventCompletionOnLaunch){

        //create resource learnings
        List<Learning__c> resourceLearnings = TestLearningData.createTestLearning(1, 'Resource', false);

        //create training resources
        List<Training_Resource__c> tresources = TestLearningData.createTestTrainingResource(resourceLearnings);

        tresources.get(0).Add_training_parameters_to_URL__c = true;
        tresources.get(0).Resource_URL__c = 'www.salesforce.com#t=1'; //forcing no http protocol to cover https replacement
        if(preventCompletionOnLaunch){
            tresources.get(0).Prevent_completion_on_launch__c = true;
        }
        update tresources.get(0);

        for(Integer i = 0;i < resourceLearnings.size();i++){
            TestLearningData.publishLearning(resourceLearnings.get(i).Id,'resource',tresources.get(i).Id,false);
        }

        //Create training plans
        List<Training_Plan__c> tplans = TestTrainingPlanData.createTrainingPlans(new List<TestParams.TrainingPlanParam>{new TestParams.TrainingPlanParam()});
        //Create training plan sections
        List<Training_Plan_Section__c> tplanSections1 = TestTrainingPlanData.createTrainingPlanSections(tplans.get(0).Id,1);
        //Create training plan section items for quizzes
        List<Training_Plan_Section_Item__c> tplan1SectionItems1 = TestTrainingPlanData.createTrainingPlanSectionItems(tplanSections1.get(0).Id,resourceLearnings);

        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());
        Id tplanId = tplan.get(0).Id;

        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        System.runAs(adminUsers.get(0)){
            LMSService.upsertAssignments(selectedUserIds,tplanId,null);
        }

        List<Learning_Assignment__c> assignments = [select id from Learning_Assignment__c where Training_Plan__c = :tplanId];
        System.assertEquals(1,assignments.size());
        return assignments.get(0).Id;

    }

    // TestStringUtils
    static testMethod void testStringUtils1() {
        String a = 'abc';
        String b = ' ';

        System.assert(SFDCStringUtils.isEmpty(a) == false, 'Should be true - SFDCStringUtils.isEmpty(a)');
        System.assert(SFDCStringUtils.notNullOrEmpty(a, false) == true, 'Should be true - SFDCStringUtils.notNullOrEmpty(a, false)');
        System.assert(SFDCStringUtils.notNullOrEmpty(b, true) == false, 'Should be false - SFDCStringUtils.notNullOrEmpty(b, true)');

        String[] digit_arr = new String[]{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' };
        Set<Integer> digits = SFDCStringUtils.stringArrayToIntegerSet(digit_arr);
        System.assert(digits.size() == 10, 'Should be 10 - digits.size()');
        System.assert(digits.contains(48) == true, 'Should be true - digits.contains(48)');

        String[] arr1 = new String[]{ '0', '1'};
        String[] arr2 = new String[]{ '2', '3'};

        String[] arr3 = SFDCStringUtils.unionStringArrays(arr1, arr2);
        System.assert(arr3.size() == 4, 'Should be 4 - arr3.size()');
    }

    // TestTrainingPlans
    static testmethod void testOptionalSectionsValidations(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());
        Id tplanId = tplan.get(0).Id;
        List<Training_Plan_Section__c> tplanSections = [select id,Optional__c from Training_Plan_Section__c where Training_Plan__c = :tplanId];

        //Test Insert
        Test.startTest();

            Training_Plan_Section__c sampleSection = tplanSections.get(0);
            try{
                sampleSection.Optional__c = true;
                update sampleSection;
                System.assert(false,'Section item with optional items cannot be made optional');
            }catch(Exception e){
                System.assert(true);
            }

        Test.stopTest();

    }

    static testmethod void testUpsertTrainingPlanAssignment(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());
        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId, null);
            }

            List<Training_Plan_Assignment__c> assignments = [select id from Training_Plan_Assignment__c where Training_Plan__c = :tplanId];
            System.assertEquals(5,assignments.size());
            List<Learning_Assignment__c> learningAssignments = [select id from Learning_Assignment__c where Training_Plan_Section_Assignment__r.Training_Plan_Section__r.Training_Plan__c = :tplanId];
            System.assert(learningAssignments.size()>0);
            List<Learning__c> resourceLearnings;

            System.runAs(adminUsers.get(0)){
                //Add an additional shared learning
                //create resource learnings
                resourceLearnings = TestLearningData.createTestLearning(1, 'Resource', true);
                //create training resources
                List<Training_Resource__c> tresources = TestLearningData.createTestTrainingResource(resourceLearnings);
                //Publish resource
                TestLearningData.publishLearning(resourceLearnings.get(0).Id,'resource',tresources.get(0).Id,false);
                List<Training_Plan_Section__c> tplanSections = [select id from Training_Plan_Section__c where Training_Plan__c = :tplanId limit 1];
                //Add to training plan section
                List<Training_Plan_Section_Item__c> tplanSectionItemUpdate = TestTrainingPlanData.createTrainingPlanSectionItems(tplanSections.get(0).Id,resourceLearnings);

                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }

        Test.stopTest();

        assignments = [select id from Training_Plan_Assignment__c where Training_Plan__c = :tplanId];
        System.assertEquals(5,assignments.size());
        List<Shared_Learning_Assignment__c> sharedlearningAssignments = [select id from Shared_Learning_Assignment__c where Learning__c in :resourceLearnings];
        System.assertEquals(5,sharedlearningAssignments.size());

    }

    static testmethod void testUpsertTrainingPlanAssignmentWithAchievements(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }
		Set<Id> tplanIdset=new Set<Id>();
        for(Training_Plan__c tp : tplan){
            tplanIdset.add(tp.Id);
        }
        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
                LMSService.getAchievementAssignmentforTrainingPlanAchievements(selectedUserIds,tplanIdset);
            }

            List<Training_Plan_Assignment__c> assignments = [select id from Training_Plan_Assignment__c where Training_Plan__c = :tplanId];
            System.assertEquals(5,assignments.size());
            List<Learning_Assignment__c> learningAssignments = [select id from Learning_Assignment__c where Training_Plan_Section_Assignment__r.Training_Plan_Section__r.Training_Plan__c = :tplanId];
            System.assert(learningAssignments.size()>0);
            List<Learning__c> resourceLearnings;

            System.runAs(adminUsers.get(0)){
                //Add an additional shared learning
                //create resource learnings
                resourceLearnings = TestLearningData.createTestLearning(1, 'Resource', true);
                //create training resources
                List<Training_Resource__c> tresources = TestLearningData.createTestTrainingResource(resourceLearnings);
                //Publish resource
                TestLearningData.publishLearning(resourceLearnings.get(0).Id,'resource',tresources.get(0).Id,false);
                List<Training_Plan_Section__c> tplanSections = [select id from Training_Plan_Section__c where Training_Plan__c = :tplanId limit 1];
                //Add to training plan section
                List<Training_Plan_Section_Item__c> tplanSectionItemUpdate = TestTrainingPlanData.createTrainingPlanSectionItems(tplanSections.get(0).Id,resourceLearnings);

                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }

        Test.stopTest();

        assignments = [select id from Training_Plan_Assignment__c where Training_Plan__c = :tplanId];
        System.assertEquals(5,assignments.size());
        List<Shared_Learning_Assignment__c> sharedlearningAssignments = [select id from Shared_Learning_Assignment__c where Learning__c in :resourceLearnings];
        System.assertEquals(5,sharedlearningAssignments.size());
        List<Achievement_Assignment__c> achievementAssignments = [select Id from Achievement_Assignment__c where Training_Plan_Achievement__c in :lTPlanAchievement and Status__c = 'Eligible'];
        System.assertEquals(lmsUsers.size(), achievementAssignments.size());
    }

      /*static testmethod void testUpsertAndDeleteTrainingPlanAssignment(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());
        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //List<Training_Plan_Assignment__c> assignments = null;
        //List<Learning_Assignment__c> learningAssignments = null;
        List<Training_Plan_Assignment__c> assignments = new List<Training_Plan_Assignment__c>();
        List<Learning_Assignment__c> learningAssignments = new List<Learning_Assignment__c>();

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
                assignments = [select id,Training_Plan__c from Training_Plan_Assignment__c where Training_Plan__c = :tplanId];
                System.assertEquals(5,assignments.size());
                learningAssignments = [select id from Learning_Assignment__c where Training_Plan_Section_Assignment__r.Training_Plan_Section__r.Training_Plan__c = :tplanId];
                System.assert(learningAssignments.size()>0);
                delete assignments;
            }
        List<Training_Plan_Assignment__c> assignmentsList = new List<Training_Plan_Assignment__c> ();
        List<Learning_Assignment__c> learningAssignmentsList = new List<Learning_Assignment__c>();
      assignmentsList = [select id from Training_Plan_Assignment__c where Training_Plan__c = :tplanId ];
        System.assertEquals(0,assignmentsList.size());
        learningAssignmentsList = [select id from Learning_Assignment__c where Training_Plan_Section_Assignment__r.Training_Plan_Section__r.Training_Plan__c = :tplanId];
        System.assertEquals(0,learningAssignmentsList.size());
        Test.stopTest();
    }*/
    static testMethod void testTrainingPlanAchievementUpdates(){

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());
        List<Training_Plan_Section__c> tplanSections = [select id,Training_Plan__c from Training_Plan_Section__c where Training_Plan__c = :tplan.get(0).id];

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievements = TestAchievementData.createAchievements(3, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, new List<Achievement__c>{lAchievements.get(0)});
        List<Training_Plan_Achievement__c> lTPlanSectionAchievements1 = TestTrainingPlanData.createTrainingPlanSectionAchievements(new List<Training_Plan_Section__c>{tplanSections.get(0)},new List<Achievement__c>{lAchievements.get(1)});
        List<Training_Plan_Achievement__c> lTPlanSectionAchievements2 = TestTrainingPlanData.createTrainingPlanSectionAchievements(new List<Training_Plan_Section__c>{tplanSections.get(1)},new List<Achievement__c>{lAchievements.get(2)});

        //Test Insert
        Test.startTest();

            //Update a training plan achievement to a section plan achievement
            Training_Plan_Achievement__c tpAchievement = [select id,Training_Plan_Section__c,Type__c from Training_Plan_Achievement__c where id = :lTPlanAchievement.get(0).Id];
            System.assertEquals('Plan',tpAchievement.Type__c);
            tpAchievement.Training_Plan_Section__c = tplanSections.get(2).Id;
            update tpAchievement;
            tpAchievement = [select id,Training_Plan_Section__c,Type__c from Training_Plan_Achievement__c where id = :lTPlanAchievement.get(0).Id];
            System.assertEquals('Section',tpAchievement.Type__c);

        Test.stopTest();


    }

    static testmethod void testTPlansWithSharedLearningAssignments(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(3,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleDataWithSharedLearnings();

        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(2,tplan.size());

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(2, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Id tplanId2 = tplan.get(1).Id;

        Set<Id> selectedUserIds = new Set<Id>();
        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }
        System.runAs(adminUsers.get(0)){
            //Upsert assignemtns for tplan 1
            LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            //Upsert assignemtns for tplan 2
            LMSService.upsertAssignments(selectedUserIds,tplanId2,null);
        }

        //Test Insert
        Test.startTest();

            List<Learning__c> sharedLearningSample = [select id
                                                    ,Sync_progress__c
                                                    from Learning__c
                                                    where RecordType.DeveloperName = 'Task'];

            Learning__c sharedLearning = sharedLearningSample.get(0);
            System.assert(sharedLearning.Sync_progress__c == true);


            List<Learning_Assignment__c> tplan1LearningAsgmts = [select id
                                                                ,Progress__c
                                                                ,Shared_Learning_Assignment__c
                                                                ,Training_Plan__c
                                                                from Learning_Assignment__c
                                                                where Training_Plan__c = :tplanId
                                                                and Learning__c = :sharedLearning.Id
                                                                and User__c = :lmsUsers.get(0).Id];

            System.assertEquals(1,tplan1LearningAsgmts.size());

            List<Learning_Assignment__c> tplan2LearningAsgmts = [select id
                                                                ,Progress__c
                                                                ,Shared_Learning_Assignment__c
                                                                ,Training_Plan__c
                                                                from Learning_Assignment__c
                                                                where Training_Plan__c = :tplanId2
                                                                and Learning__c = :sharedLearning.Id
                                                                and User__c = :lmsUsers.get(0).Id];

            System.assertEquals(1,tplan2LearningAsgmts.size());

            //Update learning assignment progress in training plan 1
            tplan1LearningAsgmts.get(0).Progress__c = 'Completed';
            update tplan1LearningAsgmts.get(0);

            //Confirm the change has been replicated to the shared learning assignment

            List<Shared_Learning_Assignment__c> sharedLearningAssignments = [select id
                                                                ,Progress__c
                                                                from Shared_Learning_Assignment__c
                                                                where Learning__c = :sharedLearning.Id
                                                                and User__c = :lmsUsers.get(0).Id];
            System.assertEquals(1,sharedLearningAssignments.size());
            System.assertEquals('Completed',sharedLearningAssignments.get(0).Progress__c);

        Test.stopTest();


        //Confirm that learning assignments in training plan 2 have also been updated
        List<Learning_Assignment__c> tplan2LearningAsgmtsUpdated = [select id
                                                            ,Progress__c
                                                            ,Shared_Learning_Assignment__c
                                                            ,Training_Plan__c
                                                            from Learning_Assignment__c
                                                            where Training_Plan__c = :tplanId2
                                                            and Learning__c = :sharedLearning.Id
                                                            and User__c = :lmsUsers.get(0).Id];
        System.assertEquals('Completed',tplan2LearningAsgmtsUpdated.get(0).Progress__c);
    }

    // TestUtilClass
    public static String getTimeStamp(){
        DateTime dtimenow = DateTime.now();
        String ts = dtimenow.second()+''+dtimenow.millisecond();
        return ts;
    }

    public static Integer getRandomInteger(Integer lower, Integer upper){
        return (Integer) Math.floor(Math.random() * (upper - lower)) + lower;
    }

    public static String getRandomQuestionType(){
        Integer option = getRandomInteger(1, 5);
        String sResult;

        if(option == 1)
            sResult = 'Text';
        else if(option == 2)
            sResult = 'Number';
        else if(option == 3)
            sResult = 'SelectOneQuestion';
        else if(option == 4)
            sResult = 'SelectMultipleQuestion';
        else if(option == 5)
            sResult = 'Boolean';
        else
            sResult = 'Text';

        return sResult;
    }

    public static String getRandomSentence(Integer wordNum){
        List<String> wordbank = new List<String>{'Hipster','Ipsum','Lorem','is', 'win', 'hot dog', 'Wes Anderson', 'to', 'do it', 'cupcakes', 'the'};
        String sResult;

        for(Integer i = 0; i < wordNum; i++){
            Integer wbposition = getRandomInteger(0, wordbank.size());
            sResult += wordbank.get(wbposition);
        }

        return sResult;
    }

    public static String getRandomUniqueString(Integer length){
        return EncodingUtil.base64Encode(crypto.generateAesKey(256)).substring(1,length);
    }

    public static Date getRandomFutureDate(){
        DateTime dt = DateTime.now().addDays(getRandomInteger(2, 5));
        return Date.newinstance(dt.year(), dt.month(), dt.day());
    }

    public static List<User> createUsers(Integer iNum,String profileName){
        String localizedProfileName = getLocalizedProfileName(profileName);
        Profile oProfile = [select Id, Name, PermissionsCustomizeApplication from Profile where Name = :localizedProfileName limit 1];

        List<User> lResults = new List<User>();
        for(Integer i = 0; i < iNum; i++){
            User oUser = new User();
            oUser.FirstName = 'Tester';
            oUser.LastName = 'McCoy The '+i;
            oUser.Email = 'tester.mccoy' + getTimeStamp()+''+i+'@salesforce.com.test';
            oUser.Username = 'tester.mccoy' + getTimeStamp()+''+i+'@salesforce.com.test';
            oUser.CommunityNickname = getTimeStamp()+''+i;
            oUser.Alias = 't'+getTimeStamp()+''+i;
            oUser.TimeZoneSidKey = 'America/El_Salvador';
            oUser.LocaleSidKey = 'en_US';
            oUser.EmailEncodingKey = 'UTF-8';
            oUser.ProfileId = oProfile.Id;
            oUser.LanguageLocaleKey = 'en_US';
            oUser.IsActive = true;

            lResults.add(oUser);
        }

        insert lResults;
        return lResults;
    }


    /**
    *Method used to add Permission Sets to Test Users. NOTE: execute this method always inside of a System.runAs(...)
    *
    */
    public static void addPermissionSet(List<User> lusers, String permSetName){
        List<PermissionSetAssignment> lpsa = new List<PermissionSetAssignment>();
        List<PermissionSet> lps = [select id from PermissionSet where Name = :permSetName];

        for(User ouser : lusers){
            PermissionSetAssignment opsa = new PermissionSetAssignment();
            opsa.AssigneeId = ouser.Id;
            opsa.PermissionSetId = lps.get(0).Id;

            lpsa.add(opsa);
        }

        insert lpsa;
    }

    private static String getLocalizedProfileName(String profileName){
        if(UserInfo.getLanguage() == 'en_US'){
            return profileName;
        }else if(profileName == 'System Administrator'){
            return System.Label.ALMS_Sys_Admin_Profile;
        }else if(profileName == 'Standard User'){
            return System.Label.ALMS_Standard_User_Profile;
        }
        return profileName;
    }



    public static User createPortallUser() {

        /* Make sure the running user has a role otherwise an exception will be thrown. */
        Set<String> portalUserTypes = new Set<String>{'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess', 'CustomerSuccess'};

        User userWithRole;

        if(UserInfo.getUserRoleId() == null) {

            UserRole r = new UserRole(name = 'TEST ROLE');
            Database.insert(r);

            userWithRole = new User(alias = 'rl'+getTimeStamp(), email='userwithrole'+getTimeStamp()+'@roletest1.com', userroleid = r.id,
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = UserInfo.getProfileId(),
                                timezonesidkey='America/Los_Angeles', username='userwithrole'+getTimeStamp()+'@testorg.com');
        } else {
            userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
        }

        System.assert(userWithRole.userRoleId != null,'This test requires the target org to have at least one UserRole created. Please create a user role in this organization and try again.');

        Account a;
        Contact c;
        System.runAs(userWithRole) {
            a = new Account(name = 'TEST ACCOUNT');
            Database.insert(a);

            c = new Contact(AccountId = a.id, lastname = 'lastname');
            Database.insert(c);
        }

        /* Get any profile for the given type.*/
        Profile p = [select id from profile where usertype in :portalUserTypes limit 1];

        String testemail = 'puser'+getTimeStamp()+'@amamama.com';
        User pu = new User(profileId = p.id, username = testemail, email = testemail,
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname', contactId = c.id);

        Database.insert(pu);
        return pu;
    }

    // TestLearningAssignmentApproveExtension
    static testMethod void testApprovalAsSysAdmin(){

		//Create users
		List<User> adminUsers = TestUtilClass.createUsers(1,'System Administrator');
		List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

		createTestDataForApproval(adminUsers,lmsUsers);

		List<Learning_Assignment__c> learningAssignments = [select id,approved__c from Learning_Assignment__c];

		Test.startTest();

			LearningAssignmentApproveExtension asgmtApproveExt = new LearningAssignmentApproveExtension(new ApexPages.StandardController(learningAssignments.get(0)));
			asgmtApproveExt.approveAssignment();

		Test.stopTest();
	}

	static testMethod void testApprovalAsManager(){

		//Create users
		List<User> adminUsers = TestUtilClass.createUsers(1,'System Administrator');
		List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

		createTestDataForApproval(adminUsers,lmsUsers);

		Test.startTest();

			System.runAs(lmsUsers.get(1)){

				List<Learning_Assignment__c> learningAssignments = [select id,approved__c from Learning_Assignment__c];
				System.assert(learningAssignments.size() == 1);
				LearningAssignmentApproveExtension asgmtApproveExt = new LearningAssignmentApproveExtension(new ApexPages.StandardController(learningAssignments.get(0)));
				asgmtApproveExt.approveAssignment();

			}

		Test.stopTest();

	}

	private static void createTestDataForApproval(List<User> adminUsers,List<User> lmsUsers){

		System.runAs(adminUsers.get(0)){
			//Assign corresponding perm sets
			TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
			TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
		}

		String taskApproverId = lmsUsers.get(1).Id;

		//Create task learnings
		List<Learning__c> taskLearnings = TestLearningData.createTestLearning(1, 'Task', false);

		//Update learning attributes
		Id learningId = taskLearnings.get(0).Id;

		//Create task resources
		List<Task__c> ttasks = TestLearningData.createTestTask(taskLearnings);

		//Enable manager approval in the task
		Task__c learningTask = [select id,Requires_Manager_Approval__c from Task__c where Learning__c = :learningId];
		learningTask.Requires_Manager_Approval__c = true;
		update learningTask;

		//Add second user as a task approver
		Task_Approver__c ta = new Task_Approver__c();
		ta.Task__c = learningTask.Id;
		ta.User__c = taskApproverId;
		insert ta;

		//Publish learnings
		for(Integer i = 0;i < taskLearnings.size();i++){
			TestLearningData.publishLearning(taskLearnings.get(i).Id,'task',ttasks.get(i).Id,false);
		}

		List<Training_Plan__c> tplans = TestTrainingPlanData.createTrainingPlans(new List<TestParams.TrainingPlanParam>{new TestParams.TrainingPlanParam ()});

		//Create training plan sections
		List<Training_Plan_Section__c> tplanSections = TestTrainingPlanData.createTrainingPlanSections(tplans.get(0).Id,1);

		//Create training plan section items for quizzes
		List<Training_Plan_Section_Item__c> tplanSectionItmes1 = TestTrainingPlanData.createTrainingPlanSectionItems(tplanSections.get(0).Id,taskLearnings);

		//Assign the user to the trainign plan
		List<Training_Plan__c> tplan = [select id from Training_Plan__c];
		System.assertEquals(1,tplan.size());
		Id tplanId = tplan.get(0).Id;

		System.runAs(adminUsers.get(0)){
			Set<Id> selectedUserIds = new Set<Id>{lmsUsers.get(0).Id};
			LMSService.upsertAssignments(selectedUserIds,tplanId,null);
		}

		List<Learning_Assignment__c> learningAssignments = [select id,Approved__c,Progress__c from Learning_Assignment__c];
		System.assertEquals(1,learningAssignments.size());

		Learning_Assignment__c la = learningAssignments.get(0);
		System.assertEquals('Not Started',la.Progress__c);
		la.Progress__c = 'In Review';
		update la;

		//Run sharing logic
		LMSService.WithoutSharingOps wsops = new LMSService.WithoutSharingOps();
		wsops.shareLearningAssignmentsWithApprovers(new Set<Id>{taskApproverId}, new Set<Id>{la.Id});
		
	}

    // TestMyProfileController
    static testMethod void testWithNoAchievements(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        //Update manager for user 1
        User u1 = [select id,managerId from User where id = :lmsUsers.get(0).id];
        u1.managerId = lmsUsers.get(1).Id;
        update u1;

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());
        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        System.runAs(adminUsers.get(0)){
            LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            TrainingPlanSectionItem cntoller=new TrainingPlanSectionItem();
        	cntoller.updateToLatestVersion();
           	cntoller.keepOldVersion();
        }

        PageReference ref = Page.MyProfile;
        Test.setCurrentPageReference(ref);

        Test.startTest();

            System.runAs(lmsUsers.get(0)){

                MyProfileController cont = new MyProfileController();
                //System.assert(cont.oManager != null);
                //System.assert(cont.achievementType == 'Achievements');
                //System.assert(cont.oUser != null);
                System.assertEquals(0,cont.lcategories.size());

                List<MyProfileController.AchievementTypeWrapper> atypes = cont.getAchievementTypes();
                System.assert(atypes.size()>0);


                ref.getParameters().put('aType','Certifications');
                Test.setCurrentPageReference(ref);

                PageReference ctypeRef = cont.changeAchievementType();
                System.assert(ctypeRef != null);

            }

        Test.stopTest();

    }

    static testMethod void testWithAchievements(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        //Update manager for user 1
        User u1 = [select id,managerId from User where id = :lmsUsers.get(0).id];
        u1.managerId = lmsUsers.get(1).Id;
        update u1;

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        System.runAs(adminUsers.get(0)){
            LMSService.upsertAssignments(selectedUserIds,tplanId,null);
        }

        PageReference ref = Page.MyProfile;
        Test.setCurrentPageReference(ref);

        Test.startTest();

            System.runAs(lmsUsers.get(0)){

                MyProfileController cont = new MyProfileController();
                System.assertEquals(0,cont.lcategories.size());

                List<MyProfileController.AchievementTypeWrapper> atypes = cont.getAchievementTypes();
                System.assert(atypes.size()>0);
                ref.getParameters().put('aType','Certifications');
                Test.setCurrentPageReference(ref);

                PageReference ctypeRef = cont.changeAchievementType();
                System.assert(ctypeRef != null);

            }

        Test.stopTest();

    }

    static testMethod void testWithAchievementsAndOverrideURL(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(2,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        //Update manager for user 1
        User u1 = [select id,managerId from User where id = :lmsUsers.get(0).id];
        u1.managerId = lmsUsers.get(1).Id;
        update u1;

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        //Override achievement url
        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        Achievement__c ach = [select id,Override_URL__c from Achievement__c where Id = :lAchievement.get(0).Id];
        ach.Override_URL__c = 'https://www.salesforce.com';
        update ach;


        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        System.runAs(adminUsers.get(0)){
            LMSService.upsertAssignments(selectedUserIds,tplanId,null);
        }


        //Change achievement status
        List<Achievement_Assignment__c> achievementAssignments = [select Id,Status__c from Achievement_Assignment__c where Training_Plan_Achievement__r.Training_Plan__c = :tplanId];
        for(Achievement_Assignment__c aa : achievementAssignments){
            aa.Status__c = LMSConstants.AA_ACQUIRED_STATUS;
        }
        update achievementAssignments;

        PageReference ref = Page.MyProfile;
        Test.setCurrentPageReference(ref);

        Test.startTest();

            System.runAs(lmsUsers.get(0)){

                MyProfileController cont = new MyProfileController();
                System.assertEquals(0,cont.lcategories.size());

                List<MyProfileController.AchievementTypeWrapper> atypes = cont.getAchievementTypes();
                System.assert(atypes.size()>0);
                ref.getParameters().put('aType','Certifications');
                Test.setCurrentPageReference(ref);

                PageReference ctypeRef = cont.changeAchievementType();
                System.assert(ctypeRef != null);

            }

        Test.stopTest();

    }

    // TestTrainingPlanDetail
    static testmethod void testTrainingPlanDetailMobile(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id,Achievement__c from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);
		
		tplan[0].Achievement__c=    lAchievement[0].Id;
        update tplan;
        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }
        Test.stopTest();
				
        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.TrainingPlanDetail;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'iPhone');
            ApexPages.Standardcontroller stdcontroller = New ApexPages.StandardController(tplan.get(0));
            TrainingPlanDetailController extension = new TrainingPlanDetailController(stdcontroller);

            List<Training_Plan_Section__c> ltpsec = [select id from Training_Plan_Section__c where Training_Plan__c =: tplan.get(0).Id order by Order__c asc];
            System.assert(ltpsec.size() == 3);

            List<Training_Plan_Section_Item__c> ltpsitem = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(0).Id order by Order__c asc];
            System.assert(ltpsitem.size() == 1, 'Training Plan Section Item issues, size = ' + ltpsitem.size());
			
            extension.selectedSectionId = ltpsec.get(0).Id;
            extension.selectedItemId = ltpsitem.get(0).Id;
            extension.retrieveItemDetails();
          // extension.launchLearning();
           // System.assert(extension.selectedItemStatusLabel == 'default', 'Error on selectedItemStatusLabel, label = ' + extension.selectedItemStatusLabel);

            List<Learning_Assignment__c> lassignment = [select Id,
                                                            Progress__c from Learning_Assignment__c
                                                            where Training_Plan__c =: tplanId
                                                            and Training_Plan_Section__c =:ltpsec.get(0).Id
                                                            and User__c =: lmsUsers.get(0).Id];
            for(Learning_Assignment__c oa : lassignment){
                oa.Progress__c = 'In Progress';
            }

            upsert lassignment;
						
            extension.init();
            extension.selectedSectionId = ltpsec.get(0).Id;
            extension.selectedItemId = ltpsitem.get(0).Id;
            extension.retrieveItemDetails();
           // extension.launchLearning();
            //System.assert(extension.selectedItemStatusLabel == 'warning', 'Error on selectedItemStatusLabel, label = ' + extension.selectedItemStatusLabel);

            for(Learning_Assignment__c oa : lassignment){
                oa.Progress__c = 'Completed';
            }
            upsert lassignment;
        } 
        
    }

    static testmethod void testTrainingPlanDetailWeb(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());

        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplan, lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }
        Test.stopTest();

        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.TrainingPlanDetail;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'Mozilla');
            ApexPages.Standardcontroller stdcontroller = New ApexPages.StandardController(tplan.get(0));
            TrainingPlanDetailController extension = new TrainingPlanDetailController(stdcontroller);

            List<Training_Plan_Section__c> ltpsec = [select id from Training_Plan_Section__c where Training_Plan__c =: tplan.get(0).Id order by Order__c asc];
            System.assert(ltpsec.size() == 3);

            List<Training_Plan_Section_Item__c> ltpsitem = [select id from Training_Plan_Section_Item__c where Training_Plan_Section__c =: ltpsec.get(0).Id order by Order__c asc];
            System.assert(ltpsitem.size() == 1, 'Training Plan Section Item issues, size = ' + ltpsitem.size());

            extension.selectedSectionId = ltpsec.get(0).Id;
            extension.selectedItemId = ltpsitem.get(0).Id;
            extension.retrieveItemDetails();
            //extension.launchLearning();
            //System.assert(extension.selectedItemStatusLabel == 'default', 'Error on selectedItemStatusLabel, label = ' + extension.selectedItemStatusLabel);

            List<Learning_Assignment__c> lassignment = [select Id,
                                                            Progress__c from Learning_Assignment__c
                                                            where Training_Plan__c =: tplanId
                                                            and Training_Plan_Section__c =:ltpsec.get(0).Id
                                                            and User__c =: lmsUsers.get(0).Id];
            for(Learning_Assignment__c oa : lassignment){
                oa.Progress__c = 'In Progress';
            }

            upsert lassignment;

            extension.init();
            extension.selectedSectionId = ltpsec.get(0).Id;
            extension.selectedItemId = ltpsitem.get(0).Id;
            extension.retrieveItemDetails();
           // extension.launchLearning();
            //System.assert(extension.selectedItemStatusLabel == 'warning', 'Error on selectedItemStatusLabel, label = ' + extension.selectedItemStatusLabel);

            for(Learning_Assignment__c oa : lassignment){
                oa.Progress__c = 'Completed';
            }

            upsert lassignment;

        }
    }


    static testmethod void testTrainingPlanDetailWebnNoMainAchievement(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());
        List<Training_Plan_Section__c> tplanSections = [select id,Training_Plan__c from Training_Plan_Section__c where Training_Plan__c = :tplan.get(0).id];


        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanSectionAchievements = TestTrainingPlanData.createTrainingPlanSectionAchievements(new List<Training_Plan_Section__c>{tplanSections.get(0)},lAchievement);

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }
        Test.stopTest();

        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.TrainingPlanDetail;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'Mozilla');
            ApexPages.Standardcontroller stdcontroller = New ApexPages.StandardController(tplan.get(0));
            TrainingPlanDetailController extension = new TrainingPlanDetailController(stdcontroller);

        }
    }

    static testmethod void testTrainingPlanDetailWithMultipleAchievements(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(2,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(5,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());
        List<Training_Plan_Section__c> tplanSections = [select id,Training_Plan__c from Training_Plan_Section__c where Training_Plan__c = :tplan.get(0).id];


        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        //Create multiple achievments tied to the plan
        List<Achievement__c> lAchievement = TestAchievementData.createAchievements(2, lAchieveCat.get(0).Id, 'Achievements');
        List<Achievement__c> lSectionAchievements = TestAchievementData.createAchievements(2, lAchieveCat.get(0).Id, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement1 = TestTrainingPlanData.createTrainingPlanAchievements(tplan, new List<Achievement__c>{lAchievement.get(0)});
        List<Training_Plan_Achievement__c> lTPlanAchievement2 = TestTrainingPlanData.createTrainingPlanAchievements(tplan, new List<Achievement__c>{lAchievement.get(1)});
        List<Training_Plan_Achievement__c> lTPlanSectionAchievements1 = TestTrainingPlanData.createTrainingPlanSectionAchievements(new List<Training_Plan_Section__c>{tplanSections.get(0)},new List<Achievement__c>{lSectionAchievements.get(0)});
        List<Training_Plan_Achievement__c> lTPlanSectionAchievements2 = TestTrainingPlanData.createTrainingPlanSectionAchievements(new List<Training_Plan_Section__c>{tplanSections.get(0)},new List<Achievement__c>{lSectionAchievements.get(1)});

        Id tplanId = tplan.get(0).Id;
        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        //Test Insert
        Test.startTest();
            System.runAs(adminUsers.get(0)){
                LMSService.upsertAssignments(selectedUserIds,tplanId,null);
            }
        Test.stopTest();

        System.runAs(lmsUsers.get(0)){
            PageReference pageRef = Page.TrainingPlanDetail;
            Test.setCurrentPage(pageRef);
            pageRef.getHeaders().put('User-Agent', 'Mozilla');
            ApexPages.Standardcontroller stdcontroller = New ApexPages.StandardController(tplan.get(0));
            TrainingPlanDetailController extension = new TrainingPlanDetailController(stdcontroller);
            
            extension.campaignStatusButton();
            extension.createTrainingPlanBookmark();

        }
    }

}