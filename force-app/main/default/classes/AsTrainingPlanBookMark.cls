/*Author : Jet R. Compayan
*Description : This is a class that used to Maange Tranining Plan Book Mark 
*Date Created : May 22, 2018
*Last Modified By : 
*Date Last Modified : 
*Related Meta Data : 
*/
public class AsTrainingPlanBookMark {


    /*Author : Jet R. Compayan
    *Description : This method will create Training Plan Bookmark
    *Date Created : May 22, 2018
    *Last Modified By : 
    *Date Last Modified :  
    *Related Meta Data :
    *Param : 0. Id - the userId 
             1. Id - the TraningPlanId
    *Return : Boolean 
    */
    public static Boolean isCreateTrainingPlanBookmark( Id userId , Id trainingPlanId  ) {

        
        list < AsTrainingPlanBookmark__c > planBookMarkList = new list< AsTrainingPlanBookmark__c >();
        for( AsCPDPlanner__c cpdPlanner : [	SELECT AsUser__c,
						                                        AS_Current_CPD_Plan__c,
						                                        Id
						                                FROM AsCPDPlanner__c 
						                                WHERE AsUser__c =:userId 
						                                AND AS_Current_CPD_Plan__c = true ] ){

            AsTrainingPlanBookmark__c planBookmar = new AsTrainingPlanBookmark__c();
            planBookmar.AsCPDPlanner__c = cpdPlanner.Id;
            planBookmar.AsTrainingPlan__c  = trainingPlanId;
            planBookMarkList.add( planBookmar );

        }
        if( planBookMarkList.size() != 0 ){
          insert planBookMarkList;
          return true;
        } else {
        	return false;
        }


    }
 

    /*Author : Jet R. Compayan
    *Description : This method has to check the  AsTrainingPlanBookmark__c if the already exist 
                   and aslo if the AsCPDPlanner__c realed is AS_Current_CPD_Plan__c value is true.
    *Date Created : May 22, 2018
    *Last Modified By : 
    *Date Last Modified :  
    *Related Meta Data :
    *Param : 0. Id - the userId 
             1. Id - the TraningPlanId
    *Return : Boolean 
    */
    public static boolean isCheckTrainingPlanInBookMark( Id userId , Id trainingPlanId ){

        list<AsTrainingPlanBookmark__c> trainingBookMark = [ Select  Id 
                                                                    ,Name 
                                                                    , AsCPDPlanner__c 
                                                                From 
                                                                    AsTrainingPlanBookmark__c 
                                                                WHERE 
                                                                    AsCPDPlanner__r.AsUser__c =:userId
                                                                    and 
                                                                    AsTrainingPlan__c = :trainingPlanId 
                                                            ] ;

        system.debug('trainingBookMark ==>'+ trainingBookMark);                                                    

        list<AsCPDPlanner__c> cpdPlanner = [ SELECT AsUser__c,
                                                AS_Current_CPD_Plan__c,
                                                Id
                                         FROM AsCPDPlanner__c 
                                         WHERE AsUser__c =:userId 
                                         AND AS_Current_CPD_Plan__c = true ];

        system.debug('cpdPlanner ==>'+ cpdPlanner);                                       

        if( cpdPlanner.size() == 1 ){

            if(  trainingBookMark.size() != 0  ){
                return false;
            } else { 
                return true;
            }

        } else {
            return true;
        }
        
    }
}