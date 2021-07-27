/*Author : Ronald Santander
*Description : This class will run when training plan created and updated
*Date Created : Aug 13,2019
*Last Modified By : 
*Date Last Modified :
*/

public class ASTpLMSCourseHandler {
    
    private static Boolean recursiveVal = false;
	
    //method for insert action
    public static void processAfterInsert(Map<Id,Training_Plan__c> newPlansMap){
        if(recursiveVal == false){
            recursiveVal = true;
            List<Training_Plan__c> filteredPlans = new List<Training_Plan__c>();
            for(Training_Plan__c tp : newPlansMap.values()){
                if(tp.AS_LMS__c == 'Moodle Course' && tp.AS_LMS_Instance__c != null){
                    filteredPlans.add(tp);
                }
            }
            
            if(!filteredPlans.isEmpty()){
                createLMSCourse(filteredPlans);
            }
        }
    }
    
    //method for update action
    public static void processAfterUpdate(Map<Id,Training_Plan__c> oldPlansMap,Map<Id, Training_Plan__c> newPlansMap){
        if(recursiveVal == false){
            recursiveVal = true;
            List<Training_Plan__c> filteredPlans = new List<Training_Plan__c>();
            for(Training_Plan__c tp : newPlansMap.values()){
                Training_Plan__c oldTP = oldPlansMap.get(tp.Id);
                if(tp.AS_LMS__c == 'Moodle Course' && tp.AS_LMS_Instance__c != null && tp.AS_LMS_Instance__c != oldTP.AS_LMS_Instance__c){
                    filteredPlans.add(tp);
                }
            }
            
            if(!filteredPlans.isEmpty()){
                createLMSCourse(filteredPlans);
            }
        }
    }

    /**
    * Generate random number
    **/
    public static String generateRandomNumber() {
        String randomNumber = generate();
        
        if (randomNumber.length() < 10) {
            String randomNumber2 = generate();
            randomNumber = randomNumber + randomNumber2.substring(0, 10 - randomNumber.length());
        }
        
        return randomNumber;
    }

    public static String generate() {
        return String.valueOf(Math.abs(Crypto.getRandomInteger()));
    }
    
    //create lms course
    public static void createLMSCourse(List<Training_Plan__c> filteredTPlan){
        
        Map<String,Id> customMapKey = new Map<String,Id>();
        List<LMS_Course__c> newLMScourse = new List<LMS_Course__c>();
        for(Training_Plan__c tp : filteredTPlan){
            String xID = generateRandomNumber();

        	LMS_Course__c LMScourse = new LMS_Course__c();
            LMScourse.Date__c           = Date.today();
            LMScourse.Description__c    = tp.Description__c;
            LMScourse.Name              = tp.Name;
            LMScourse.LMS_Instance__c   = tp.AS_LMS_Instance__c;
            LMScourse.Status__c         = 'Active';
            LMScourse.AsLmsCrouseExtId__c = xID;
            newLMScourse.add(LMScourse);
            customMapKey.put(tp.Name+tp.AS_LMS_Instance__c+xID,tp.Id);
        }
        
        if(!newLMScourse.isEmpty()){
            //insert newLMScourse;
            Set<Id> insertedLMScourse = new Set<Id>();
            Database.SaveResult[] insertLMScourseList = Database.insert(newLMScourse, false);
            for (Database.SaveResult sr : insertLMScourseList){
                if (sr.isSuccess() == true){
                    insertedLMScourse.add(sr.getId());
                }
            }
            
            if(!insertedLMScourse.isEmpty()){
                updateTplanRecord(insertedLMScourse,customMapKey);
            }
        }
    }
    
    //update training plan by linking it to newly created lms course when lms course successfully inserted
    public static void updateTplanRecord(Set<Id> LMScourseIds,Map<String,Id> LMScourseCustomKey){
        System.debug('inside furture: '+LMScourseCustomKey);
        List<LMS_Course__c> LMSCourseList = [SELECT Id, Name, LMS_Instance__c, AsLmsCrouseExtId__c FROM LMS_Course__c WHERE Id IN: LMScourseIds];
        List<Training_Plan__c> upedateTPList = new List<Training_Plan__c>();
        for(LMS_Course__c singleLMSCourse : LMSCourseList){
            String customKey = singleLMSCourse.Name+singleLMSCourse.LMS_Instance__c+singleLMSCourse.AsLmsCrouseExtId__c;
            if(LMScourseCustomKey.containsKey(customKey)){
                Training_Plan__c updateTP = new Training_Plan__c();
                updateTP.Id = LMScourseCustomKey.get(customKey);
                updateTP.AS_LMS_Course__c = singleLMSCourse.Id;
                upedateTPList.add(updateTP);
            }
        }
        if(!upedateTPList.isEmpty()){
            update upedateTPList;
        }
    }

}