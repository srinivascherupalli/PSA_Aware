/*Author : John Hope
*Description : This is a test class for AsKnowledgeController class.
*Date Created : May 15, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : AsKnowledgeController.cls
 */
@isTest
private class AsKnowledgeControllerTest {
		
	static testMethod void contructorTest() {
			AsKnowledgeController knowledge = new AsKnowledgeController();
			
		//	knowledge.JSONCategory = AsKnowledgeController.categoryTree()[0];
	}
	
	static testMethod void categoryTreeTest() {
    AsKnowledgeController.categoryTree();
	}

	static testMethod void getDescribeDataCategoryGroupStructureResultsTest() {
    AsKnowledgeController.getDescribeDataCategoryGroupStructureResults();
	}

	static testMethod void allArticleTypeTest() {
		AsKnowledgeController.allArticleType();
	}
	
	static testMethod void allArticleUnderTypeTest() {
		AsKnowledgeController.allArticleUnderType('Standard__kav');
	}
	
	static testMethod void allArticleUnderCategoryTest() {
		Standard__DataCategorySelection cat = [Select Id,DataCategoryGroupName,DataCategoryName from Standard__DataCategorySelection LIMIT 1];
		AsKnowledgeController.allArticleUnderCategory('{"categoryMap":{"'+cat.DataCategoryGroupName+'":["'+cat.DataCategoryName+'__c"]}}');
	}
	
	static testMethod void singleArticleTest() {
		Standard__kav stan = [Select Id from Standard__kav where Language ='en_US' AND PublishStatus ='Online' LIMIT 1];
		AsKnowledgeController.singleArticle(String.valueOf(stan.Id));
	}
	
	static testMethod void checkUserProfileIfMemberTest() {
		AsKnowledgeController.checkUserProfileIfMember();
	}
	
	static testMethod void getObjFieldMapTest() {
		AsKnowledgeController.getObjFieldMap('Standard__kav');
	}
	
	
	
	@TestSetup
	static void createArticles() {
		//Standard
		
    List<Standard__kav> stanList=new List<Standard__kav>();
    
    Standard__kav stan=new Standard__kav();
    stan.Title='TestArticle';
    stan.UrlName='TestArticle';
    stanList.add(stan);
    insert stanList;
    
    Standard__kav knowId = [SELECT KnowledgeArticleId FROM Standard__kav WHERE Id = :stanList[0].Id];
    
    KbManagement.PublishingService.publishArticle(knowId.KnowledgeArticleId, true);
    
    DescribeDataCategoryGroupResult[] results = Schema.describeDataCategoryGroups(
    new String[] { 'KnowledgeArticleVersion'}
		); 
		
		System.debug('results :' + results);
		
    List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();

   	DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
   	p.setSobject('KnowledgeArticleVersion');
   	p.setDataCategoryGroupName(results[0].getName());
  	pairs.add(p);
    
 		List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
    
    System.debug('describeCategoryStructureResult :' + describeCategoryStructureResult);
    
    DataCategory [] toplevelCategories = describeCategoryStructureResult[0].getTopCategories();
    List<Schema.DataCategory> childCategories = toplevelCategories[0].getChildCategories();
    
    Standard__DataCategorySelection tempCat = new Standard__DataCategorySelection ();
		tempCat.DataCategoryGroupName = results[0].getName(); 
		tempCat.DataCategoryName = childCategories[0].getName(); //m.Category_Path__c;
		tempCat.ParentId = stanList[0].Id;
		
		System.debug('tempCat :' + tempCat);
		insert tempCat;
	}
    
    
    
    
}