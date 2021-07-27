public with sharing class DL_Fax {
    Private static boolean isCurrentlyFaxableHours(){
        Boolean todayIsNotSunday = System.now().format('EEE') != 'Sun';
        Boolean timeIsBusinessHrs = Integer.valueOf(System.now().format('HH')) >= 9 && Integer.valueOf(System.now().format('HH')) <= 16;
        return (todayIsNotSunday && timeIsBusinessHrs);
    }


    Public static Integer getCreditBalance(){
        String apiToken = checkFaxAPIToken();

        Integer creditBalance;
 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://restful-api.gofax.com.au/v1/Account/CreditBalance?token='+apiToken);
        request.setMethod('GET');
        request.setTimeout(10000);
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            creditBalance = Integer.valueof(results.get('Response'));
        }
        
        else{
            System.debug('Response Code: ' + response.getStatusCode()); 
        }
        
        return creditBalance;
    }

    
    @AuraEnabled
    Public Static List<String> getFaxNumbers(String postCodes){
        postCodes = postCodes.replace(' ','');
        String toPostCode;
        String fromPostCode;
        Boolean postCodeGroup = false;
        Boolean postCodeRange = false;
        Boolean statesGroup = false;
        
        List<Account> accountList = new List<Account>();
        List<String> postCodeList;
        List<String> stateList;
        List<String> faxList = new List<String>();
        List<String> errorList = new List<String>{'No Fax Numbers Found'};
        List<String> stateStrings = new List<String>{'ACT','NSW','VIC','TAS','QLD','WA','SA','NT'};
        RecordType businessAccountRecordType = [SELECT ID,Name FROM RecordType WHERE Name = 'Business Account'];

        if(postCodes.contains(',') && postCodes.contains('-')){
            errorList = new List<String>{'PostCode input cannot be mix of Separated and Range'};
        }

        else if(postCodes.contains('_')){
            stateList = postCodes.split('_');
            statesGroup = true;
        }

        else if(postCodes.contains(',')){
            postCodeList = postCodes.split(',');
            postCodeGroup = true;
        }
        
        else if(postCodes.contains('-')){
            Integer i = postCodes.indexOf('-');
            fromPostCode = postCodes.mid(0,i);
            toPostCode = postCodes.mid((i+1),(postCodes.length()));
            if(fromPostCode.length() == 4 && toPostCode.length() == 4){
                postCodeRange = true;
            }
            else{
                errorList = new List<String>{'PostCode Length Error'};
            }
        }
        
        if(postCodeRange == true){
            accountList = [SELECT Fax FROM Account 
                           WHERE Fax_Opt_Out__c != true 
                           AND PersonHasOptedOutOfFax != true
                           AND (Fax != '' OR Fax != null)
                           AND (BillingPostalCode != '' OR BillingPostalCode != null)
                           AND BillingPostalCode  >= :fromPostCode 
                           AND BillingPostalCode  <= :toPostCode];
        }
        
        else if(postCodeGroup == true){
            accountList = [SELECT Fax FROM Account 
                           WHERE Fax_Opt_Out__c != true 
                           AND PersonHasOptedOutOfFax != true
                           AND Fax != '' 
                           AND BillingPostalCode in :postCodeList];
        }
        
        else if(postCodes.length() == 4){
            accountList = [SELECT Fax FROM Account 
                           WHERE Fax_Opt_Out__c != true 
                           AND PersonHasOptedOutOfFax != true
                           AND Fax != '' 
                           AND BillingPostalCode = :postCodes];
        }

        else if(statesGroup == true){
            accountList = [SELECT Fax FROM Account 
                           WHERE Fax_Opt_Out__c != true 
                           AND PersonHasOptedOutOfFax != true
                           AND Fax != '' 
                           AND BillingState IN :stateList];
        }


        else if(stateStrings.contains(postCodes)){
            accountList = [SELECT Fax FROM Account 
                           WHERE Fax_Opt_Out__c != true 
                           AND PersonHasOptedOutOfFax != true
                           AND Fax != '' 
                           AND BillingState = :postCodes];
        }


     
        For(Account acct : accountList){
            String fax = acct.fax;
            fax = fax.replace('(','');
            fax = fax.replace(')','');
            fax = fax.replace('-','');
            fax = fax.replace(' ','');

            if(!faxList.contains(fax)){
                faxList.add(fax);
            }
            
        }
        return faxList; 
    }
    
    
    @future(callout=true)
    @AuraEnabled
    Public Static void sendFaxToAPI(List<String> faxNumbers, String fileName, String base64Data, String costCode){
        String apiToken = checkFaxAPIToken();

        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        List<Fax__c> faxesList = new List<Fax__c>();
        List<String> successfulFax = new List<String>();
        List<String> failedFax = new List<String>();
    
		String body;        
        
        if(apiToken != null){

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://restful-api.gofax.com.au/v1/SendFax?token='+apiToken);
            request.setMethod('PUT');
            request.setHeader('content-type', 'application/json; charset=utf-8');
            request.setTimeout(60000);
               
            for(String faxNumber : faxNumbers){
                String dateTimeNow = String.valueOf(System.Datetime.now()); //2018-10-19 16:23:57
                
                body = '{"SendTo": "'+ faxNumber +'",' +
                  '"SendFrom": "0262852869",'+
                  '"ScheduledSendTime": "'+ dateTimeNow +'",'+
                  '"IsHighQuality": true,'+
                  '"ClientReference": "'+ costCode +'",'+
                  '"Documents": ['+
                    '{"Filename": "'+ fileName +'",'+
                      '"Data": "'+ base64Data +'"}'+
                  ']}';
                
                request.setBody(body);
                HttpResponse response;

                try{
                    response = http.send(request);

                    if (response.getStatusCode() == 200) {
                        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        String response_Str  = String.valueof(results.get('Response'));
                        
                        if(String.valueof(results.get('Success')) == 'true'){
                            successfulFax.add(faxNumber);

                            Fax__c fax = new Fax__c();
                
                            fax.GoFax_Ref_ID__c = response_Str;
                            fax.Date_Sent__c = System.Datetime.now();
                            fax.Cost_Code__c = costCode;
                            fax.Fax_Number__c = faxNumber;
                            fax.Document_Name__c = fileName;
                            fax.Name = response_Str;

                            faxesList.add(fax);
                        }

                        else if (String.valueof(results.get('Success')) == 'false'){
                            failedFax.add(faxNumber);
                        }
                    }
                    
                    else{
                        System.debug(body);
                        System.debug('Response Code:' + response.getStatusCode());
                    }
                }

                catch(CalloutException e){
                    System.debug(e.getMessage());//Most likely response timeout. Faxes still get processed by GoFax.
                    getUnsavedFaxDetails();
                }
            }


            if(successfulFax.size() > 0 || failedFax.size() > 0){
                System.debug('Successful Faxes:'+successfulFax.size()+',Unsuccessful Faxes:'+failedFax.size());
            }

            try{
                insert faxesList;
                scheduleFaxUpdate();
            }

            catch(Exception e){System.debug(e.getMessage());}
        }

        else{
            System.debug('ERROR: apiToken('+apiToken+')  Invalid');
        }
    }

    
    Private Static String checkFaxAPIToken(){
        String apiToken = '13528d88-6321-42b9-85ae-743ab8ebb2b4';

        String message;
 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://restful-api.gofax.com.au/v1/Account/CheckHaveAccess?token='+apiToken+'&api_key='+apiToken);
        request.setMethod('PUT');
        request.setBody('');
        request.setTimeout(10000);
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            message = String.valueof(results.get('Message'));
        }
        
        else{
            System.debug('Response Code: ' + response.getStatusCode()); 
        }
        
        return message == 'Token valid' ? apiToken:null;
    }


    @AuraEnabled
    Public Static String sendFaxProxy(List<String> faxNumbers, String fileName, String base64Data, String costCode){
        Integer creditBalance = getCreditBalance();

        List<String> faxNumbersChunk = new List<String>();
        Integer faxListSize = faxNumbers.size();
        Integer loopTimes = (Math.floor(faxListSize / 99)).intValue(); 
        Integer leftOver = Math.round(Math.mod(faxListSize,99));
        Integer successCount = 0;

        if(isCurrentlyFaxableHours()){
            if((faxListSize * 1.25) <= creditBalance){  //1 fax is around 1.25 fax credits.
            
                if(faxListSize >= 99){
                    System.debug('faxListSize:'+faxListSize);
                    System.debug('loopTimes:'+loopTimes);
                    System.debug('leftOver:'+leftOver);

                    for(Integer i=0; i < loopTimes; i++){
                        System.debug(successCount);

                        for(Integer j=0; j < 99; j++){
                            faxNumbersChunk.add(faxNumbers.remove(0));
                        }

                        try{
                            System.debug('TotalChunkSize: ' + faxNumbersChunk.size());
                            SendFaxToAPI(faxNumbersChunk, fileName, base64Data, costCode);
                            successCount++;
                        }

                        catch(Exception e){
                            System.debug(e.getMessage());
                        }
                        faxNumbersChunk.clear();
                    }

                    if(leftOver > 0){
                        for(Integer i=0; i < leftOver; i++){
                            faxNumbersChunk.add(faxNumbers.remove(0));
                        }

                        try{
                            System.debug('LeftOverChunkSize: ' + faxNumbersChunk.size());
                            SendFaxToAPI(faxNumbersChunk, fileName, base64Data, costCode);
                            successCount++;
                        }

                        catch(Exception e){
                            System.debug(e.getMessage());
                        }
                    }
                }

                else{
                    try{
                        SendFaxToAPI(faxNumbers, fileName, base64Data, costCode);
                        successCount++;
                    }

                    catch(Exception e){
                        System.debug(e.getMessage());
                    }
                }

                return successCount > 0 ? 'SUCCESS':'FAILED';
            }

            else{
                return 'INSUFFICIENT CREDITS';
            }
        }

        else{
            return 'NOT BUSINESS HOURS';
        }
    }


    Public Static String faxStatusProxy(List<String> faxIDs){
        List<String> faxIDsChunk = new List<String>();
        Integer faxIDsSize = faxIDs.size();
        Integer loopTimes = (Math.floor(faxIDsSize / 99)).intValue();
        Integer leftOver = Math.round(Math.mod(faxIDsSize,99));
        Integer successCount = 0;
        
        if(faxIDsSize >= 99){
            System.debug('faxIDsSize:'+faxIDsSize);
            System.debug('loopTimes:'+loopTimes);
            System.debug('leftOver:'+leftOver);

            for(Integer i=0; i < loopTimes; i++){
                System.debug(successCount);

                for(Integer j=0; j < 99; j++){
                    faxIDsChunk.add(faxIDs.remove(0));
                }

                try{
                    System.debug('TotalChunkSize: ' + faxIDsChunk.size());
                    getFaxStatus(faxIDsChunk);
                    successCount++;
                }

                catch(Exception e){
                    System.debug(e.getMessage());
                }
                faxIDsChunk.clear();
            }

            if(leftOver > 0){
                for(Integer i=0; i < leftOver; i++){
                    faxIDsChunk.add(faxIDs.remove(0));
                }

                try{
                    System.debug('LeftOverChunkSize: ' + faxIDsChunk.size());
                    getFaxStatus(faxIDsChunk);
                    successCount++;
                }

                catch(Exception e){
                    System.debug(e.getMessage());
                }
            }
        }

        else{
            try{
                getFaxStatus(faxIDs);
                successCount++;
            }

            catch(Exception e){
                System.debug(e.getMessage());
            }
        }

        return successCount > 0 ? 'SUCCESS':'FAILED';
    }


    @future(callout=true)
    @AuraEnabled
    Public Static void getFaxStatus(List<String> faxIds){
        List<Fax__c> faxesToUpdate = new List<Fax__c>();
        List<Fax__c> faxes = [SELECT Id, GoFax_Ref_ID__c, Status__c FROM Fax__c WHERE GoFax_Ref_ID__c IN :faxIds];

        String status;
        String inProgress;
        String apiToken = checkFaxAPIToken(); 

        if(apiToken != null){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setTimeout(10000);

            for(Fax__c fax : faxes){
                request.setEndpoint('https://restful-api.gofax.com.au/v1/SendFax/'+fax.GoFax_Ref_ID__c+'/Status?token='+apiToken); 
                //https://restful-api.gofax.com.au/v1/SendFax/18594012/Status?token=13528d88-6321-42b9-85ae-743ab8ebb2b4
                
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() == 200) {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    status = String.valueof(results.get('Message'));
                    inProgress = String.valueof(results.get('InProgress'));
                    
                    if(inProgress == 'false'){
                        fax.Status__c = status;
                        faxesToUpdate.add(fax);
                    }
                    else{
                        ////////////////Fax NOT Added To Update List//////////////////
                        System.debug(status);
                    }
                }
                
                else{
                    System.debug('Response Code: ' + response.getStatusCode()); 
                }
            }
        }

        try{
            update faxesToUpdate;
        }
            
        catch(Exception e){
            System.debug(e.getMessage());
        }

        if([SELECT COUNT() FROM Fax__c WHERE Status__c = '' OR Status__c = null] > 0){
            scheduleFaxUpdate();
        }

        else{
            try{
                getUnsavedFaxDetails();
            }
            catch(Exception e){
                System.debug(e.getMessage());
            }
        }   
    }


    public Static List<String> getUnsavedFaxIDs(){
        String tokenAPI = checkFaxAPIToken();
        List<String> goFaxIDs_String = new List<String>();
        List<Object> goFaxIDs_Object;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setTimeout(10000);
        request.setEndpoint('https://restful-api.gofax.com.au/v1/SendFaxes/IDsForDate?token='+tokenAPI);

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            goFaxIDs_Object = (List<Object>)results.get('Response');
        }

        else{
            goFaxIDs_Object = new List<Object>();
        }


        for(Object o : goFaxIDs_Object){
            goFaxIDs_String.add(String.valueOf(o));
        }

        return goFaxIDs_String;
    }


    Public Static void getUnsavedFaxDetails(){
        List<String> faxIDsChunk = new List<String>();
        List<String> todaysGoFaxIDs = getUnsavedFaxIDs();
        List<String> unsavedGoFaxIDs = new List<String>();
        List<String> savedGoFaxIDs = new List<String>();
        List<Fax__c> faxes = [SELECT ID, GoFax_Ref_ID__c FROM Fax__c];

        for(Fax__c fax : faxes){
           savedGoFaxIDs.add(fax.GoFax_Ref_ID__c);
        }

        System.debug('savedGoFaxIDs: '+savedGoFaxIDs.size());

        for(String goFaxID : todaysGoFaxIDs){
            if(!savedGoFaxIDs.contains(goFaxID)){
                unsavedGoFaxIDs.add(goFaxID);
            }
        }

        System.debug('unsavedGoFaxIDs: '+unsavedGoFaxIDs.size());

        Integer faxIDsSize = unsavedGoFaxIDs.size();
        Integer loopTimes = (Math.floor(faxIDsSize / 99)).intValue();
        Integer leftOver = Math.round(Math.mod(faxIDsSize,99));
        Integer successCount = 0;
        
        if(faxIDsSize >= 99){
            System.debug('faxIDsSize:'+faxIDsSize);
            System.debug('loopTimes:'+loopTimes);
            System.debug('leftOver:'+leftOver);

            for(Integer i=0; i < loopTimes; i++){
                System.debug(successCount);

                for(Integer j=0; j < 99; j++){
                    faxIDsChunk.add(unsavedGoFaxIDs.remove(0));
                }

                try{
                    System.debug('TotalChunkSize: ' + faxIDsChunk.size());
                    getUnsavedFaxes(faxIDsChunk);
                    successCount++;
                }

                catch(Exception e){
                    System.debug(e.getMessage());
                }
                faxIDsChunk.clear();
            }

            if(leftOver > 0){
                for(Integer i=0; i < leftOver; i++){
                    faxIDsChunk.add(unsavedGoFaxIDs.remove(0));
                }

                try{
                    System.debug('LeftOverChunkSize: ' + faxIDsChunk.size());
                    getUnsavedFaxes(faxIDsChunk);
                    successCount++;
                }

                catch(Exception e){
                    System.debug(e.getMessage());
                }
            }
        }

        else{
            try{
                getUnsavedFaxes(unsavedGoFaxIDs);
                successCount++;
            }

            catch(Exception e){
                System.debug(e.getMessage());
            }
        }
    }


    @future(callout=true)
    @AuraEnabled
    Public Static void getUnsavedFaxes(List<String> unsavedGoFaxIDs){
        List<Fax__c> faxesToUpdate = new List<Fax__c>();
        List<Map<String, Object>> returnedObjects = new List<Map<String, Object>>();

        String status;
        String inProgress;
        String apiToken = checkFaxAPIToken(); 

        if(apiToken != null){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setTimeout(12000);

            for(String goFaxID : unsavedGoFaxIDs){
                Fax__c fax = new Fax__c();

                request.setEndpoint('https://restful-api.gofax.com.au/v1/SendFax/'+goFaxID+'/Document?token='+apiToken); 
                
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() == 200) {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    List<Object> result = (List<Object>)results.get('Response');
                    for(Object o : result){
                        Map<String,Object> tempMap = (Map<String,Object>)o;
                        String status_string = String.valueOf(tempMap.get('Status'));
                        fax.GoFax_Ref_ID__c = String.valueOf(tempMap.get('SendFaxTransmissionID'));
                        fax.Name = String.valueOf(tempMap.get('SendFaxTransmissionID'));
                        fax.Status__c = (status_string.contains('Transmission') || status_string.contains('Initialised')) ? null : status_string;
                        fax.Document_Name__c = String.valueOf(tempMap.get('FileName'));
                        fax.Fax_Number__c = String.valueOf(tempMap.get('ToNumber'));
                        fax.Date_Sent__c = (DateTime)Json.deserialize('"'+tempMap.get('TransmissionDate')+'"', DateTime.class);
                        fax.Cost_Code__c = String.valueOf(tempMap.get('ClientID'));
                        faxesToUpdate.add(fax);
                    }
                }
                
                else{
                    System.debug('Response Code: ' + response.getStatusCode()); 
                }
            }

            Insert faxesToUpdate;
        }
    }


    public Static void scheduleFaxUpdate(){
        Integer i = [SELECT COUNT() FROM Fax__c WHERE Status__c = '' OR Status__c = null LIMIT 99];
        Integer minutes = i > 90 ? 10 : 5;
        Datetime executeTime = System.now().addMinutes(minutes); 
        Boolean cronJobExists = false;
        String cronExpression = GetCRONExpression(executeTime);
        List<Id> currentCronJobs =  new List<Id>();
        DL_Fax_Update updateFaxJob = new DL_Fax_Update();

        for(CronTrigger trig : [SELECT Id, CronJobDetailId, NextFireTime FROM CronTrigger WHERE State in ('WAITING','ACQUIRED','EXECUTING') OR NextFireTime != NULL]){
            currentCronJobs.add(trig.CronJobDetailId);
        }

        List<CronJobDetail> currentCronJobNames = [SELECT Id, Name FROM CronJobDetail WHERE ID in :currentCronJobs];
        
        for(CronJobDetail cronJob : currentCronJobNames){
            if(String.valueof(cronJob.Name).contains('Update Fax Status ')){
                cronJobExists = true;
            }
        }

        if(!cronJobExists){
            if(currentCronJobs.size() < 100){
            	System.schedule('Update Fax Status ' + executeTime.getTime(), cronExpression, updateFaxJob);
            }
            else{
                System.debug('Cannot Schedule Update Fax - Current Cron Jobs >= 100');
                System.debug(currentCronJobNames);
            }
        }
    }

    private static String GetCRONExpression(Datetime dt) {
        return ('' + dt.second() + ' ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year());
    }

}