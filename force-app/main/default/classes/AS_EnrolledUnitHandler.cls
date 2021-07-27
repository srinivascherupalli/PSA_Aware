/*Author : Michael Vincent Largo
*Description :  This class will update the Enrolment that connected to Enrolled Unit that being updated.
*Date Created : September 18,2019
*Last Modified By : 
*Date Last Modified :
*/
public class AS_EnrolledUnitHandler {
    
    private static Boolean recursiveVal = false;
    
    public static void updateEnrolmentfromEnrolmentUnit(List<AS_Enrolled_Unit__c> newEnrolled){
        
         if(recursiveVal == false){
            recursiveVal = true;
             
             Set<Id> EnrolmentIds = new Set<Id>();
             Map<Id,Enrolment_Form__c> MapEnrolmentnew = new Map<Id,Enrolment_Form__c>();
             //Map<Id,AS_Enrolled_Unit__c> mapenrolled = new Map<Id,AS_Enrolled_Unit__c>();
             
            for (AS_Enrolled_Unit__c enrolled: newEnrolled){
                
                if (enrolled.AS_Enrolment__c !=null ){
                    if (enrolled.AS_Status__c == 'In Progress'){
                        Enrolment_Form__c newEnrol = new Enrolment_Form__c();
                        newEnrol.Id = enrolled.AS_Enrolment__c;
                        newEnrol.Enrolment_Status__c = 'In Progress';
                        MapEnrolmentnew.put(newEnrol.Id,newEnrol);
                        EnrolmentIds.add(enrolled.AS_Enrolment__c);
                    } else if ( enrolled.AS_Status__c == 'Completed' && enrolled.AS_Result__c == 'Competent'){
                        EnrolmentIds.add(enrolled.AS_Enrolment__c);
                    }/*else if (enrolled.AS_Status__c == 'Completed') {
                        EnrolmentIds.add(enrolled.AS_Enrolment__c);
                    }*/
                }
            }
            
            if(!EnrolmentIds.isEmpty()){
                Map<Id,List<AS_Enrolled_Unit__c>> grpEnrolUnit = new  Map<Id,List<AS_Enrolled_Unit__c>>();
                List<AS_Enrolled_Unit__c> enrolUnilList = [SELECT Id,AS_Enrolment__c,AS_Result__c,AS_Status__c,AS_Training_Plan_Assignment__c,AS_Training_Plan_Assignment__r.AS_Result__c,AS_Training_Plan_Assignment__r.LastModifiedDate FROM AS_Enrolled_Unit__c WHERE AS_Enrolment__c IN: EnrolmentIds];
                
                for(AS_Enrolled_Unit__c enrolUnit : enrolUnilList){
                    if(grpEnrolUnit.containsKey(enrolUnit.AS_Enrolment__c)){
                        List<AS_Enrolled_Unit__c> mapEnrolList = grpEnrolUnit.get(enrolUnit.AS_Enrolment__c);
                        mapEnrolList.add(enrolUnit);        
                        grpEnrolUnit.put(enrolUnit.AS_Enrolment__c, mapEnrolList);
                    }else{
                        grpEnrolUnit.put(enrolUnit.AS_Enrolment__c, new List<AS_Enrolled_Unit__c>{enrolUnit});
                    }
                }
                
                if(!grpEnrolUnit.isEmpty()){
                    
                    for(Id mapkey : grpEnrolUnit.keySet()){
                        Boolean isEnrolComplete = true;
                        //AS_Enrolled_Unit__c oldestLastM = new AS_Enrolled_Unit__c();
                        //AS_Enrolled_Unit__c emptyObjt = new AS_Enrolled_Unit__c();
                        
                        //loop all enrol unit under the same enrolment record
                        for(AS_Enrolled_Unit__c unitList : grpEnrolUnit.get(mapkey)){
                            
                            String status_result =  unitList.AS_Status__c +  unitList.AS_Result__c;
                            if(status_result.toLowerCase() != 'completedcompetent'){
                                isEnrolComplete = false;
                            }
                            
                            /*if(unitList.AS_Result__c == 'Continuing'){
                                
                                if(unitList.AS_Status__c == 'In Progress'){
                                    AS_Enrolled_Unit__c newEnrolUnits = new AS_Enrolled_Unit__c();
                                    newEnrolUnits.Id = unitList.Id;
                                    newEnrolUnits.AS_Result__c = null;
                                    mapenrolled.put(newEnrolUnits.Id,newEnrolUnits);
                                    //updateEnrolUnitlist.add(newEnrolUnits);        
                                }
                            }else{
                                
                                if(unitList.AS_Training_Plan_Assignment__c != null && unitList.AS_Training_Plan_Assignment__r.AS_Result__c  == 'Continuing'){
                                  
                                    if(oldestLastM != null && oldestLastM.AS_Training_Plan_Assignment__r.LastModifiedDate >  unitList.AS_Training_Plan_Assignment__r.LastModifiedDate){
                                        oldestLastM = unitList;
                                    }else oldestLastM = unitList;
                                }
                            }*/
                        }

                        /*if(oldestLastM != null && oldestLastM != emptyObjt){
                            
                            if (mapenrolled !=null) {
                                AS_Enrolled_Unit__c newEnrolUnits = new AS_Enrolled_Unit__c();
                                newEnrolUnits.Id = oldestLastM.Id;
                                newEnrolUnits.AS_Result__c = 'Continuing';
                                mapenrolled.put(newEnrolUnits.Id,newEnrolUnits);
                                
                            }
                            
                        }*/
                        
                        if(isEnrolComplete){
                            Enrolment_Form__c updateEnrol = new Enrolment_Form__c();
                            updateEnrol.Id = mapkey;
                            updateEnrol.Enrolment_Status__c = 'Completed';
                            MapEnrolmentnew.put(updateEnrol.Id,updateEnrol);
                        }
                    }
                }
            }
             
             if (!MapEnrolmentnew.isEmpty()){
                 //system.debug('enrolList: '+enrolList);
                 update MapEnrolmentnew.values();
             }
             
             /*if(!mapenrolled.isEmpty()){
                 //system.debug('updateEnrolUnitlist: '+updateEnrolUnitlist);
                 update mapenrolled.values();
                 
             }*/
        }
	}
}