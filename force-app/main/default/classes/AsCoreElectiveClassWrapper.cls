/**
 * @File Name          : AsCoreElectiveClassWrapper.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/18/2019, 10:04:34 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    9/5/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
global class AsCoreElectiveClassWrapper {
    
    @AuraEnabled public Integer numberOfElectives {get;set;}
    @AuraEnabled public Decimal OrderNo {get;set;}
    //LP
    @AuraEnabled public String LPName {get;set;}
    @AuraEnabled public Id LPId {get;set;}
    @AuraEnabled public Id acctId {get;set;}

    //LP unit
    @AuraEnabled public String LPUName {get;set;}
    @AuraEnabled public Id LPUId {get;set;}
    @AuraEnabled public Id recTypeId {get;set;}
    @AuraEnabled public String LPUTPDescription {get;set;}
    //LPU > Unit
    @AuraEnabled public String UnitState {get;set;}
    @AuraEnabled public String AsCourseCode {get;set;}
    //enrollment
    @AuraEnabled public String enroLLmentState {get;set;}
    @AuraEnabled public String enroLLmentStatus {get;set;}
    //recordTypes
    @AuraEnabled public String eLec {get;set;}
    @AuraEnabled public String core {get;set;}
    //enrolledUnits
    @AuraEnabled public Id enrolledUnitId {get;set;}
    @AuraEnabled public Id enrolledId {get;set;}
    @AuraEnabled public String enrolledUnitName {get;set;}
    @AuraEnabled public String enrolledUnitgetUnitId {get;set;}
    @AuraEnabled public String enrolledUnitDescription {get;set;}
    @AuraEnabled public Integer enroLLedNoUnits {get;set;}
    @AuraEnabled public boolean isElective {get;set;}
    

}