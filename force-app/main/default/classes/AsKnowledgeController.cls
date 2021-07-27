/*Author : John Hope
*Description : This is a class for salesforce Knowledge
*Date Created : May 30, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : 
*/
global class AsKnowledgeController {
	
	
 	/*
 	*Author : John Hope
  *Description : constructor
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
	global AsKnowledgeController(){
	}
  
  /*
 	*Author : John Hope
  *Description : method to get all category including sub category
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
  @remoteAction
	global Static List<JSONCategory> categoryTree(){
 		/*
 		String finalCategory = JSON.serialize(AsKnowledgeController.getDescribeDataCategoryGroupStructureResults());
	 
	 	//extract value of 'All' i.e. first child
	 	System.debug('final :' + finalCategory);
	 	return finalCategory; 
	 	*/
	 	
	 	List<JSONCategory> categories = (List<JSONCategory>)JSON.deserialize(JSON.serialize(getDescribeDataCategoryGroupStructureResults()),List<JSONCategory>.class);
		System.debug('categories :' + categories);
		return categories;
		
	}
	 
	global static List<DescribeDataCategoryGroupStructureResult> getDescribeDataCategoryGroupStructureResults(){
		List<DescribeDataCategoryGroupResult> describeCategoryResult;
    List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
    try {
        //Making the call to the describeDataCategoryGroups to
        //get the list of category groups associated
        List<String> objType = new List<String>();
        objType.add('KnowledgeArticleVersion');
        describeCategoryResult = Schema.describeDataCategoryGroups(objType);

        //Creating a list of pair objects to use as a parameter
        //for the describe call
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();

        //Looping throught the first describe result to create
        //the list of pairs for the second describe call
        for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
           DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
           p.setSobject(singleResult.getSobject());
           p.setDataCategoryGroupName(singleResult.getName());
           pairs.add(p);
         }

        //describeDataCategoryGroupStructures()
        describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);

         //Getting data from the result
         for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
            //Get name of the associated Sobject

            //Get the name of the data category group
            singleResult.getName();

            //Get the top level categories
            DataCategory [] toplevelCategories =  singleResult.getTopCategories();

            //Recursively get all the categories
            List<DataCategory> allCategories = AsKnowledgeController.getAllCategories(toplevelCategories);

            for(DataCategory category : allCategories) {
               //Get the name of the category
               category.getName();

            }
         }
   	} catch (Exception e){

		}
		System.debug('describeCategoryStructureResult : ' + describeCategoryStructureResult);
		return describeCategoryStructureResult;
	}

	public  static DataCategory[] getAllCategories(DataCategory [] categories){
	  if(categories.isEmpty()){
	     return new DataCategory[]{};
	  } else {
	     DataCategory [] categoriesClone = categories.clone();
	     DataCategory category = categoriesClone[0];
	     DataCategory[] allCategories = new DataCategory[]{category};
	     categoriesClone.remove(0);
	     categoriesClone.addAll(category.getChildCategories());
	     allCategories.addAll(getAllCategories(categoriesClone));
	     return allCategories;
	  }
	}

	global class JSONCategory{
	    public String label{set;get;}
	    public String name{set;get;}
	    public String description{set;get;}
	    public List<TopLevelCategory> topCategories{set;get;}
	}
	
	global class TopLevelCategory{
	    public List<ChildLevelCategory> childCategories{set;get;}
	}
	
	global class ChildLevelCategory{
	    public List<ChildLevelCategory> childCategories{set;get;}
	    public String label{set;get;}
	    public String name{set;get;}
	}

    
	/*
 	*Author : John Hope
  *Description : method to get all article type
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
  @remoteAction
	global static Map<String,String> allArticleType() {
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		Set<String> keySet = gd.keySet();
		
		Map<String,String> articleTypeMap = new Map<String,String>();
		for (String key : keySet) {
	    Schema.SObjectType objectType = gd.get(key);
	    System.debug('objectType key : ' + key);
	   // if (key.endsWith('__kav') || key.endsWith('__ka') || key.endsWith('__kb')) {
	    if (key.endsWith('kav')) {
        articleTypeMap.put(objectType.getDescribe().getLabel(), key);
	    }
		}
		System.debug('articleTypeMap : ' + articleTypeMap);
		return articleTypeMap;
	}
	
	/*
 	*Author : John Hope
  *Description : method to get all article that belong to article type
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
  @remoteAction
	global static List<Object> allArticleUnderType(String theType) {
		String articleType = String.escapeSingleQuotes(theType);
		String theQuery = 'SELECT ArticleType,Document_Date__c,Id,FirstPublishedDate,PublishStatus,Title FROM '+ articleType +' WHERE Language =\'en_US\' AND PublishStatus =\'Online\' Limit 999';
		List<Object> res = database.query(theQuery);
		System.debug('theQuery :' + res.size());
		return res;
	}
	
	/*
 	*Author : John Hope
  *Description : method to get all article that belong to category type
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
  @remoteAction
	global static List<Object> allArticleUnderCategory(String filterString) {
		System.debug('ORIG filterString :' + filterString);
		JSONArticleUnderCategory filterCategory = (JSONArticleUnderCategory)JSON.deserializeStrict(filterString,JSONArticleUnderCategory.class);
		System.debug('NEW filterString :' + filterCategory);
		Map<String,List<String>> categoryMap = filterCategory.categoryMap;
		
		System.debug('filterCategory.categoryMap :' + filterCategory.categoryMap);
		String theQuery = '';
		String finalQuery = '';
		
		theQuery += 'SELECT KnowledgeArticleId,ArticleType,Summary FROM KnowledgeArticleVersion WHERE Language =\'en_US\' AND PublishStatus =\'Online\' ';
		
		if(categoryMap.size() > 0) {
			theQuery += ' WITH DATA CATEGORY ';
			
			for( String catKey :  categoryMap.KeySet()) {
				if(categoryMap.get(catKey).size() > 0 ) {
			//	theQuery +=  catKey+'__c AT ' + categoryMap.get(catKey) + ' AND '; // commented because of some error when using dynamic list
				theQuery +=  catKey+'__c AT (' + String.join(categoryMap.get(catKey), ',') + ') AND ';
				
				}
			}
			
			Integer strLength = theQuery.length();
			finalQuery = theQuery.substring(0, strLength-4);
		} else {
			finalQuery = theQuery;
		}
		
		System.debug('finalQuery : ' + finalQuery);
		List<Object> res = database.query(finalQuery);
		
		Set<Id> allArticleIdSet = new Set<Id>();
		Set<String> allArtTypeSet = new Set<String>();
		for( KnowledgeArticleVersion know : (List<KnowledgeArticleVersion>) res ) {
			allArticleIdSet.add(know.KnowledgeArticleId);
			allArtTypeSet.add(know.ArticleType);
		}
		
		transient List<Object> allArticleList = new List<Object>();
		for( String articleType :  allArtTypeSet) {
			String theQueryArticleType = 'SELECT ArticleType,Document_Date__c,Id,FirstPublishedDate,PublishStatus,Summary,Title,(Select Id,DataCategoryGroupName,DataCategoryName from DataCategorySelections) FROM '+ articleType +' WHERE Language =\'en_US\' AND PublishStatus =\'Online\' AND KnowledgeArticleId IN :allArticleIdSet Limit 999';
			transient List<Object> resArticleType = database.query(theQueryArticleType);	
			allArticleList.addAll(resArticleType);
		}
		return allArticleList;
	}
	
	/*
 	*Author : John Hope
  *Description : JSON that received the value of filtered category
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified :
  *Param : 
  *Return : 
  */ 
	global class JSONArticleUnderCategory{
	    public Map<String,List<String>> categoryMap{set;get;}
	}
	
	/*
 	*Author : John Hope
  *Description : method to get article data
  *Date Created :
  *Last Modified By : John Hope
  *Date Last Modified :
  *Param : String
  *Return : Object
  */ 
  @remoteAction @auraEnabled
  global static Object singleArticle(String articleId) {
		
		//String articleId = String.escapeSingleQuotes(article[1]);
		
		String firstQuery = 'SELECT KnowledgeArticleId,ArticleType,Id FROM KnowledgeArticleVersion WHERE Id=:articleId LIMIT 1';
		KnowledgeArticleVersion singleArticle = database.query(firstQuery);
		
		String articleType = (String) singleArticle.ArticleType;
		String artId = (String) singleArticle.Id;
		
		if(articleType != null) {
			List<String> allFields = AsKnowledgeController.getObjFieldMap(articleType);
			String theQueryArticleString = 'select '+String.join(allFields,',')+',(Select Id,DataCategoryGroupName,DataCategoryName from DataCategorySelections) FROM '+ articleType +' WHERE Id  = :articleId';
			System.debug('theQueryArticleString :' + theQueryArticleString);
			List<Object> resArticle = database.query(theQueryArticleString);
			System.debug('resArticle :' + resArticle.size() + ' - ' + resArticle);
			return resArticle;
		} else {
			return null;
		}
	}
	
	/*Author : John Hope
  *Description : method to check if user profile is Non Member Login User or not.
  *Date Created : June 1, 2018
  *Last Modified By : John Hope
  *Date Last Modified : 
  *Param : String
  *Return : Id
  */  
  @remoteAction 
	global static Boolean checkUserProfileIfMember() {  
    List<User> user = [SELECT Id,Name,ProfileId,Profile.Name FROM User where Id = :userinfo.getuserId() Limit 1];
   	if(user[0].Profile.Name == 'Non Member Login User' || userinfo.getuserId() == null) {
   		return false;
   	} else {
   		return true;
   	}
	}
	
	/*Author : John Hope
  *Description : Retrieves all the fields of a particular sObject
  *Date Created : June 1, 2018
  *Last Modified By : John Hope
  *Date Last Modified : 
  *Param : String
  *Return : List<String>
  */  
  global static List<String> getObjFieldMap(String objNameStr) {

   List<String> allFieldList = new List<String>();
    Map<String, Schema.SObjectType> globalDescMap = Schema.getGlobalDescribe();    
    Map <String, Schema.SObjectField> sObjFieldMap = globalDescMap.get(objNameStr).getDescribe().fields.getMap();
      
    for(Schema.SObjectField sObjField : sObjFieldMap.values()){  
      Schema.DescribeFieldResult sObjDescField = sObjField.getDescribe();
      if(String.valueOf(sObjDescField.getType()) != 'BASE64'){
      	allFieldList.add(String.valueOf(sObjDescField.getname()));
      }
      
    } 

    return allFieldList;

  }

}