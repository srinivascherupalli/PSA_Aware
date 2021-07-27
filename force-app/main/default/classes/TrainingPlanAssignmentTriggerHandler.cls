/*
Function Name: TrainingPlanAssignmentTriggeraftercreation
Description:
Author: Michael Vincent L. Largo
Date Created : September 18,2019
Last Updated: 
Params:
Return: N/A
*/
public class TrainingPlanAssignmentTriggerHandler {

 private static Boolean recursiveVal = false;

 public static void TplanAssignmentcreation(List < Training_Plan_Assignment__c > newTPlanList) {

  if (recursiveVal == false) {
    recursiveVal = true;


    Set <Id> TplanIds = new Set <Id> ();
    Set <Id> TplanAssignId = new Set <Id> ();
    
    for (Training_Plan_Assignment__c TPlanAssign: newTPlanList) {
        if (TPlanAssign.Training_Plan__c !=null){
            TplanIds.add(TPlanAssign.Training_Plan__c);
            TplanAssignId.add(TPlanAssign.Id);
        }
    }
 
    Map<Id, String> compositeKey = new Map<Id, String>();
    Map<Id, Training_Plan_Assignment__c> maptplanAssIds = new Map<Id, Training_Plan_Assignment__c>();
    List<Id> contId = new List<Id>();
    List<Id> insId = new List<Id>();
    for (Training_Plan_Assignment__c tpa : [SELECT Id,
        Name,
        User__c,
        User__r.ContactId,
        Training_Plan__c,
        User__r.Contact.Email,
        User__r.Contact.FirstName,
        User__r.Contact.LastName,
        Training_Plan__r.AS_LMS_Course__c,
        Training_Plan__r.AS_LMS_Instance__c,
        CreatedDate
        FROM Training_Plan_Assignment__c
        WHERE Training_Plan__c IN: TplanIds AND Training_Plan__r.AS_LMS__c = 'Moodle Course' AND Training_Plan__r.AS_LMS_Instance__c != NULL AND Id IN:TplanAssignId]) {
        contId.add( tpa.User__r.ContactId );
        insId.add( tpa.Training_Plan__r.AS_LMS_Instance__c );
            compositeKey.put( tpa.Id, tpa.User__r.ContactId + '_' + tpa.Training_Plan__r.AS_LMS_Instance__c );
        maptplanAssIds.put(tpa.Id,tpa);
    }
 
    Map<String, LMS_User__c> uComposite = new Map<String, LMS_User__c>();
    for (LMS_User__c lmsUser: [SELECT AS_Banner_Group_Contact__c, Id, LMS_Instance__c FROM LMS_User__c where AS_Banner_Group_Contact__c IN : contId AND LMS_Instance__c IN : insId]) {
        uComposite.put( lmsUser.AS_Banner_Group_Contact__c + '_' + lmsUser.LMS_Instance__c, lmsUser );

    }

    List < LMS_Course_Enrolment__c > NewLMSEnrolment = new List < LMS_Course_Enrolment__c > ();
    List<LMS_User__c> NewLMSUser = new List<LMS_User__c>();
    Map < String, Id > mapxIDandTpAssign = new Map < String, Id > ();
    Set<Id> tpaIds = compositeKey.keySet();

    for ( Id tpaId : tpaIds ) {
          System.debug( 'tpaId==> '+tpaId );

        String xID = generateRandomNumber();
        LMS_User__c lmsUserRef = new LMS_User__c(AsExtId__c = xID);
        LMS_Course_Enrolment__c lmsCourseEnrolRef = new LMS_Course_Enrolment__c(AsExtId__c = xID);

        Training_Plan_Assignment__c tpamapping = maptplanAssIds.get(tpaId);
        String compKey = compositeKey.get( tpaId );
        LMS_User__c lmsusermapping = uComposite.get( compKey );

        if ( lmsusermapping != null ) {
          
            System.debug( 'create enrollment goes here!' );
            LMS_Course_Enrolment__c Lmscourse = new LMS_Course_Enrolment__c();
            Lmscourse.As_Creation_Status__c = 'In Progress';
            Lmscourse.LMS_Course__c = tpamapping.Training_Plan__r.AS_LMS_Course__c;
            Lmscourse.LMS_Instance__c = tpamapping.Training_Plan__r.AS_LMS_Instance__c;
            Lmscourse.LMS_User__c = lmsusermapping.Id;
            Lmscourse.AsExtId__c = xID;
            Lmscourse.Start_Date__c = date.valueOf(tpamapping.CreatedDate);
            NewLMSEnrolment.add(Lmscourse);
            mapxIDandTpAssign.put(xID, tpamapping.Id);
          
        } else {

            System.debug( 'create goes here!' );
            LMS_User__c LmsUser = new LMS_User__c();
            LmsUser.AS_Banner_Group_Contact__c = tpamapping.User__r.ContactId;
            LmsUser.As_Creation_Status__c = 'In Progress';
            LmsUser.Email__c = tpamapping.User__r.Contact.Email;
            LmsUser.FirstName__c = tpamapping.User__r.Contact.FirstName;
            LmsUser.LastName__c = tpamapping.User__r.Contact.LastName;
            LmsUser.LMS_Instance__c = tpamapping.Training_Plan__r.AS_LMS_Instance__c;
            LmsUser.AsExtId__c = xID;
            NewLMSUser.add(LmsUser);

            LMS_Course_Enrolment__c Lmscourse = new LMS_Course_Enrolment__c();
            Lmscourse.As_Creation_Status__c = 'In Progress';
            Lmscourse.LMS_Course__c = tpamapping.Training_Plan__r.AS_LMS_Course__c;
            Lmscourse.LMS_Instance__c = tpamapping.Training_Plan__r.AS_LMS_Instance__c;
            Lmscourse.AsExtId__c = xID;
            Lmscourse.LMS_User__r = lmsUserRef;
            Lmscourse.Start_Date__c = date.valueOf(tpamapping.CreatedDate);
            NewLMSEnrolment.add(Lmscourse);
            mapxIDandTpAssign.put(xID, tpamapping.Id);   
            
        }
    }


   if (NewLMSUser.size() > 0) {
    system.debug('NewLMSUser==>' + NewLMSUser);
    insert NewLMSUser;
   }

   if (NewLMSEnrolment.size() > 0) {
    system.debug('NewLMSEnrolment==>' + NewLMSEnrolment);
    //insert NewLMSEnrolment;
    Set < Id > insertedLMScourseEnrol = new Set < Id > ();
    Database.SaveResult[] insertLMScourseEnrolList = Database.insert(NewLMSEnrolment, false);
    for (Database.SaveResult sr: insertLMScourseEnrolList) {
     if (sr.isSuccess() == true) {
      insertedLMScourseEnrol.add(sr.getId());
     }
    }
    if (!insertedLMScourseEnrol.isEmpty()) {
     system.enqueueJob(new AS_TrainingPlanAssignmentQueueable(insertedLMScourseEnrol, mapxIDandTpAssign));
    }
   }

  }
 }

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


 /*
 Function Name: TrainingPlanAssignmentTriggeraftercreation
 Description:
 Author: Michael Vincent L. Largo
 Date Created : September 24,2019
 Last Updated: 
 Params:
 Return: N/A
 */

 public static void TplanAssignmentUpdate(List < Training_Plan_Assignment__c > newTPlanupdate) {

  if (recursiveVal == false) {
   recursiveVal = true;

   Set < Id > TpaIds = new Set < Id > ();
   Map < Id, AS_Enrolled_Unit__c > NewEnrolUnitMap = new Map < Id, AS_Enrolled_Unit__c > ();
   Map < Id, Training_Plan_Assignment__c > mapTpanAssign = new Map < Id, Training_Plan_Assignment__c > ();

  
   for (Training_Plan_Assignment__c TPlanAss: newTPlanupdate) {
	    if (TPlanAss.AS_Enrolled_Unit__c != null) {

     if (TPlanAss.Status__c == 'In Progress' || TPlanAss.Status__c == 'Completed') {

      AS_Enrolled_Unit__c enrolledunit = new AS_Enrolled_Unit__c();
      enrolledunit.Id = TPlanAss.AS_Enrolled_Unit__c;
      enrolledunit.AS_Status__c = TPlanAss.Status__c;
      enrolledunit.AS_Result__c = TPlanAss.AS_Result__c;
     if (enrolledunit.AS_Start_Date__c == null) {
         enrolledunit.AS_Start_Date__c = date.today();
     }
      NewEnrolUnitMap.put(enrolledunit.Id, enrolledunit);
     }

     if (TPlanAss.Status__c == 'Completed') {

      TpaIds.add(TPlanAss.Id);
     }

    }
   }

    List<Training_Plan_Section_Assignment__c> TplanSecAssignList = [SELECT Id,Training_Plan_Assignment__c,Training_Plan_Assignment__r.AS_Enrolled_Unit__c,Training_Plan_Assignment__r.Completed_On__c FROM Training_Plan_Section_Assignment__c WHERE Training_Plan_Assignment__c IN:TpaIds];
    Map<Id,Id> maptpa_tpsa = new Map<Id,Id>();
    Map<Id,Id> maptpsa_enrolled = new Map<Id,Id>();
    Set<Id> tpsaIds = new Set<Id>();
    Map<Id,Date> tpaDate = new Map<Id,Date>();

    for (Training_Plan_Section_Assignment__c tlanSecAssign: TplanSecAssignList){

        maptpa_tpsa.put(tlanSecAssign.Id,tlanSecAssign.Training_Plan_Assignment__c);
        maptpsa_enrolled.put(tlanSecAssign.Id,tlanSecAssign.Training_Plan_Assignment__r.AS_Enrolled_Unit__c);
        if (tlanSecAssign.Training_Plan_Assignment__r.Completed_On__c !=null){
             tpaDate.put(tlanSecAssign.Id,tlanSecAssign.Training_Plan_Assignment__r.Completed_On__c);
        }
        tpsaIds.add(tlanSecAssign.Id);

    }
      

 List < Learning_Assignment__c > learningAssignlist = [SELECT Id, AS_Passed__c,Training_Plan_Section_Assignment__c FROM Learning_Assignment__c WHERE /*Progress__c = 'Completed' AND */Training_Plan_Section_Assignment__c IN: tpsaIds];
 Map < Id, List < Learning_Assignment__c >> grpmaplearningAss = new Map < Id, List < Learning_Assignment__c >> ();

      
 for (Learning_Assignment__c learnAss: learningAssignlist) {

    if (grpmaplearningAss.containsKey(learnAss.Training_Plan_Section_Assignment__c)) {
     List < Learning_Assignment__c > maplearnassList = grpmaplearningAss.get(learnAss.Training_Plan_Section_Assignment__c);
     maplearnassList.add(learnAss);
     grpmaplearningAss.put(learnAss.Training_Plan_Section_Assignment__c, maplearnassList);
    } else {
     grpmaplearningAss.put(learnAss.Training_Plan_Section_Assignment__c, new List < Learning_Assignment__c > {
      learnAss
     });
    }
 }
 System.debug('grpmaplearningAss==> :' + grpmaplearningAss);

  if (!grpmaplearningAss.isEmpty()) { 

    Id TpsaID;
    Id EnrolledID;
    Date datecompleted;  
    Boolean ifpassfalse = false;

    for (Id Tpsakey: grpmaplearningAss.keySet()) {

        for (Learning_Assignment__c learnAssign: grpmaplearningAss.get(Tpsakey)) {
            
        if (maptpa_tpsa.containsKey(learnAssign.Training_Plan_Section_Assignment__c)) {

            Boolean Pass = learnAssign.AS_Passed__c;
            TpsaID = maptpa_tpsa.get(learnAssign.Training_Plan_Section_Assignment__c);
            EnrolledID = maptpsa_enrolled.get(learnAssign.Training_Plan_Section_Assignment__c);
            datecompleted = tpaDate.get(learnAssign.Training_Plan_Section_Assignment__c);

            if (!Pass) {
            ifpassfalse = true;
            }
         }
        }

        Training_Plan_Assignment__c updateTplanAssignNotcompetent = new Training_Plan_Assignment__c();
            updateTplanAssignNotcompetent.Id = TpsaID;
            updateTplanAssignNotcompetent.AS_Enrolled_Unit__c = EnrolledID;
            updateTplanAssignNotcompetent.Completed_On__c = datecompleted;
        

        if (ifpassfalse) {

        updateTplanAssignNotcompetent.Status__c = 'Completed';
        updateTplanAssignNotcompetent.AS_Result__c = 'Not competent/fail';

        } else {
            
        updateTplanAssignNotcompetent.Status__c = 'Completed';
        updateTplanAssignNotcompetent.AS_Result__c = 'Competent';
        }
        mapTpanAssign.put(updateTplanAssignNotcompetent.Id, updateTplanAssignNotcompetent);
        }

        if (mapTpanAssign != null && mapTpanAssign.get(TpsaID).AS_Enrolled_Unit__c != null) {
    
        AS_Enrolled_Unit__c updateEnrolUnit = new AS_Enrolled_Unit__c();
        updateEnrolUnit.Id = EnrolledID;
        updateEnrolUnit.AS_Status__c = mapTpanAssign.get(TpsaID).Status__c;
        updateEnrolUnit.AS_Result__c = mapTpanAssign.get(TpsaID).AS_Result__c;
        if ( updateEnrolUnit.AS_Completed_On__c ==null || updateEnrolUnit.AS_Completed_On__c !=null) {
             updateEnrolUnit.AS_Completed_On__c = mapTpanAssign.get(TpsaID).Completed_On__c;         
        }
        if (updateEnrolUnit.AS_Start_Date__c == null || updateEnrolUnit.AS_Start_Date__c != null) {
        updateEnrolUnit.AS_Start_Date__c = date.today();
        }
        NewEnrolUnitMap.put(updateEnrolUnit.Id, updateEnrolUnit);
        }
   }

   if (NewEnrolUnitMap.size() > 0) {
    //system.debug('NewEnrolUnitlist: ' + NewEnrolUnitMap);
    update NewEnrolUnitMap.values();
   }


   if (mapTpanAssign.size() > 0) {
    //system.debug('mapTpanAssign: ' + mapTpanAssign);
    update mapTpanAssign.values();
   }

  }
 }
}