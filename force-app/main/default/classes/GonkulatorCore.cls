global without sharing class GonkulatorCore {
    /**********************************************************
    * Single SOQL Query to get all parent and childred data for the given Object
      ***********************************************************/
    global static void gonkQuery(GonkulatorModel.Gonk vGonk){
        for(sObjectType vObjectType : vGonk.queryMap.keySet()){
            DescribeSObjectResult description = vObjectType.getDescribe();
            Set<String> fieldSet = new Set<String>();
            //Fields for Main Object
            for(SObjectField vField : description.fields.getMap().values()){
                //First Level Lookup
                DescribeFieldResult vFieldResult = vField.getDescribe();
                //Fields for Main Object Lookup field
                System.debug('getType ' + vFieldResult.getType() + ' references type ' + description.getName()+'.'+vFieldResult.getRelationshipName());
                if (vFieldResult.getType() == DisplayType.Reference && vGonk.queryMap.get(vObjectType).parents.contains(description.getName()+'.'+vFieldResult.getRelationshipName())) {   
                    for (SObjectType vLookupType : vFieldResult.getReferenceTo()) {
                        System.debug('field ' + vFieldResult.getName() + ' references type ' + vLookupType);
                        //collect the lookup field names
                        for(String vLookupField : getFields(vLookupType)){
                            System.debug(vFieldResult.getRelationshipName()+'.'+vLookupField);
                            fieldSet.add(vFieldResult.getRelationshipName()+'.'+vLookupField);
                        }
                        //Second Lookup Fields Lookups (i.e. Second level parents)
                        DescribeSObjectResult description2 = vLookupType.getDescribe();
                        for(SObjectField vField2 : description2.fields.getMap().values()){
                            DescribeFieldResult vFieldResult2 = vField2.getDescribe();
                            if (vFieldResult2.getType() == DisplayType.Reference && vGonk.queryMap.get(vObjectType).parents.contains(description.getName()+'.'+vFieldResult.getRelationshipName()+'.'+vFieldResult2.getRelationshipName())) {  
                                for(sObjectType vLookupType2 : vFieldResult2.getReferenceTo()){
                                    System.debug('field ' + vFieldResult2.getName() + ' references type ' + vLookupType2);
                                    for(String vLookupField2 : getFields(vLookupType2)){
                                        System.debug(vFieldResult.getRelationshipName()+'.'+vFieldResult2.getRelationshipName()+'.'+vLookupField2);
                                        fieldSet.add(vFieldResult.getRelationshipName()+'.'+vFieldResult2.getRelationshipName()+'.'+vLookupField2);
                                    }
                                    //Third Lookup Fields Lookups (i.e. third level parents)
                                    DescribeSObjectResult description3 = vLookupType2.getDescribe();
                                    for(SObjectField vField3 : description3.fields.getMap().values()){
                                        DescribeFieldResult vFieldResult3 = vField3.getDescribe();
                                        if (vFieldResult3.getType() == DisplayType.Reference && vGonk.queryMap.get(vObjectType).parents.contains(description.getName()+'.'+vFieldResult.getRelationshipName()+'.'+vFieldResult2.getRelationshipName()+'.'+vFieldResult3.getRelationshipName())) {  
                                            for(sObjectType vLookupType3 : vFieldResult3.getReferenceTo()){
                                                System.debug('field ' + vFieldResult3.getName() + ' references type ' + vLookupType3);
                                                for(String vLookupField3 : getFields(vLookupType3)){
                                                    System.debug(vFieldResult.getRelationshipName()+'.'+vFieldResult2.getRelationshipName()+'.'+vFieldResult3.getRelationshipName()+'.'+vLookupField3);
                                                    fieldSet.add(vFieldResult.getRelationshipName()+'.'+vFieldResult2.getRelationshipName()+'.'+vFieldResult3.getRelationshipName()+'.'+vLookupField3);
                                                }
                                                //Fourth Lookup Fields Lookups (i.e. fourth level parents)
                                                DescribeSObjectResult description4 = vLookupType3.getDescribe();
                                                for(SObjectField vField4 : description4.fields.getMap().values()){
                                                    DescribeFieldResult vFieldResult4 = vField4.getDescribe();
                                                    if (vFieldResult4.getType() == DisplayType.Reference && vGonk.queryMap.get(vObjectType).parents.contains(description.getName()+'.'+vFieldResult.getRelationshipName()+'.'+vFieldResult2.getRelationshipName()+'.'+vFieldResult3.getRelationshipName()+'.'+vFieldResult4.getRelationshipName())) {  
                                                        for(sObjectType vLookupType4 : vFieldResult4.getReferenceTo()){
                                                            System.debug('field ' + vFieldResult4.getName() + ' references type ' + vLookupType4);
                                                            for(String vLookupField4 : getFields(vLookupType4)){
                                                                System.debug(vFieldResult.getRelationshipName()+'.'+vFieldResult2.getRelationshipName()+'.'+vFieldResult3.getRelationshipName()+'.'+vFieldResult4.getRelationshipName()+'.'+vLookupField4);
                                                                fieldSet.add(vFieldResult.getRelationshipName()+'.'+vFieldResult2.getRelationshipName()+'.'+vFieldResult3.getRelationshipName()+'.'+vFieldResult4.getRelationshipName()+'.'+vLookupField4);
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                } else {
                    fieldSet.add(vFieldResult.getName());
                }
            }
            for (Schema.ChildRelationship vChild: description.getChildRelationships()) {
                String subquery;
                Set<String> vChildFieldSet = new Set<String>();
                system.debug('Child Object Relationship Name:'+vChild.getRelationshipName());
                system.debug('Gonk Children:'+vGonk.queryMap.get(vObjectType).children);
                if (vChild.getRelationshipName() != null && vGonk.queryMap.get(vObjectType).children.contains(vChild.getRelationshipName())){  
                    system.debug('Child Object Relationship Name:'+vChild.getRelationshipName());
                    for(String vChildField : getFields(vChild.getChildSObject())){
                        
                        vChildFieldSet.add(vChildField);
                    }
                    subquery='(SELECT '+String.join(vChildFieldSet, ', ')+' FROM '+vChild.getRelationshipName()+')'; 
                    //SFDC says it supports 5 levels of children but it Does ONLY using the REST API
                    // DescribeSObjectResult childDescription2 = vChild.getChildSObject().getDescribe(); 
                    // Set<String> vChildFieldSet2 = new Set<String>();
                    // for (Schema.ChildRelationship vChild2: childDescription2.getChildRelationships()) {
                    //     system.debug('Child Object Relationship Name:'+vChild2.getRelationshipName());
                    //     if (vChild2.getRelationshipName() != null && vGonk.queryMap.get(vObjectType).children.contains(vChild.getRelationshipName()+'.'+vChild2.getRelationshipName())){        
                    //         for(String vChildField2 : getFields(vChild2.getChildSObject())){  
                    //             vChildFieldSet2.add(vChildField2);
                    //         }
                    //         subquery='(SELECT '+String.join(vChildFieldSet, ', ')+','+'(SELECT '+String.join(vChildFieldSet2, ', ')+' FROM '+vChild2.getRelationshipName()+')'+' FROM '+vChild.getRelationshipName()+')';
                    //     } 
                    // }
                } 
                if(subquery!=null){
                    fieldSet.add(subquery); 
                }
                 
                     
            }
            String soql;
            if (vGonk.queryMap.get(vObjectType).criteriaValue==null) {
                vGonk.queryMap.get(vObjectType).criteriaValue=vGonk.getObjectMap().keySet();  
            } 
            soql='SELECT '+String.join(fieldSet, ', ')+' FROM '+description.getName()+' WHERE '+vGonk.queryMap.get(vObjectType).criteriaField+ ' IN ('+String.join(vGonk.queryMap.get(vObjectType).getCriteriaQuoted(), ', ')+')';
            System.debug('soql: '+soql);
            try {
                vGonk.queryMap.get(vObjectType).queryResults = Database.query(soql);
            } catch (Exception e) {
                system.debug(e.getMessage());
            }
            

        }
    }
    /**********************************************************
    * Given an Sobject Returns the list of fields as string Set
     ***********************************************************/
    global static Set<String> getFields(SObjectType vType){
        Set<String> fields = new Set<String>();
        DescribeSObjectResult description = vType.getDescribe();
        for(SObjectField vField : description.fields.getMap().values()){
            DescribeFieldResult vFieldResult = vField.getDescribe();
            //Don't include binary fields
            if (vFieldResult.getType() != DisplayType.BASE64
                && vFieldResult.isUpdateable()) {
                    fields.add(vFieldResult.getName());
            }            
        }
        if(!fields.contains('CreatedDate')){
            fields.add('CreatedDate');
        }
        if(!fields.contains('LastModifiedDate')){
            fields.add('LastModifiedDate');
        }
        System.debug('\nsoql fields: \n'+vType+' -> '+fields+'\n\n');
        return fields;
    }

    /**********************************************************
     * convenience methd for creating test data, also works with 
     * for creating seed data
     ***********************************************************/
    global static sObject populateObjectData (sObjectType vObjectType ){
        return populateObjectData(vObjectType, null);
    }

    global static sObject populateObjectData (sObjectType vObjectType, String recordTypedevName ){
        Set<String> fieldsToIgnore = new Set<String>{'Jigsaw','ActivatedDate', 'StatusCode', 'EmailBouncedReason','EmailBouncedDate'};
        Set<String> personAccountFields = new Set<String>{'FirstName', 'LastName', 'Salutation', 'PersonMailingAddress', 
                                                            'PersonMailingStreet', 'PersonMailingCity', 'PersonMailingState', 
                                                            'PersonMailingPostalCode', 'PersonOtherAddress', 'PersonMobilePhone',
                                                            'PersonHomePhone', 'PersonOtherPhone', 'PersonAssistantPhone',
                                                            'PersonEmail', 'PersonTitle', 'PersonDepartment', 'PersonAssistantName',
                                                            'PersonLeadSource', 'PersonBirthdate', 'PersonEmailBouncedReason',
                                                            'PersonEmailBouncedDate','PersonMailingCountry','PersonMailingLatitude', 'PersonMailingLongitude',
                                                            'PersonMailingGeocodeAccuracy', 'PersonOtherStreet', 'PersonOtherCity', 
                                                            'PersonOtherState', 'PersonOtherCountry', 'PersonOtherPostalCode','PersonOtherLatitude',
                                                            'PersonOtherLongitude', 'PersonOtherGeocodeAccuracy','PersonBirthdate', 'PersonEmailBouncedDate'};
        
        sObject vNewObject = vObjectType.newSObject();
        DescribeSObjectResult description = vObjectType.getDescribe();
        boolean isPersonAccount=false;

        Schema.RecordTypeInfo rtByName;

        if (recordTypedevName != null) {
            Map<String,Schema.RecordTypeInfo> rtMapByName = description.getRecordTypeInfosByDeveloperName();
            rtByName =rtMapByName.get(recordTypedevName);
            System.debug(rtByName.getRecordTypeId());
            vNewObject = vObjectType.newSObject(rtByName.getRecordTypeId(), false);
            vNewObject.put('recordTypeId', rtByName.getRecordTypeId());
            System.debug(vNewObject);
            
        }

        description = vNewObject.getSObjectType().getDescribe();
       

        for(SObjectField vField : description.fields.getMap().values()){
            DescribeFieldResult vFieldResult = vField.getDescribe();
            System.debug('Field: '+vFieldResult.getName());
            if(vFieldResult.isUpdateable() && !fieldsToIgnore.contains(vFieldResult.getName())){
                if (vNewObject.getSObjectType()== Schema.SObjectType.Account.getSObjectType() && recordTypedevName!='PersonAccount' && personAccountFields.contains(vFieldResult.getName())) {
                    //ignore person account fields if it is not a person account
                    continue;
                }
                switch on vFieldResult.getType() {
                    when base64 {
                        Blob blobKey = crypto.generateAesKey(128);
                        vNewObject.put(vFieldResult.getName(), blobKey);
                    } 
                    when Boolean {
                        Boolean vBoolean = (Boolean) vFieldResult.getDefaultValue();
                        vNewObject.put(vFieldResult.getName(), vBoolean);
                    }
                    when Currency {
                        vNewObject.put(vFieldResult.getName(), Double.valueOf(Math.Random() * 100));
                    }
                    when Date {
                        vNewObject.put(vFieldResult.getName(), Date.today()+1);
                        
                    } 
                    when DateTime {
                        vNewObject.put(vFieldResult.getName(), Datetime.now());
                        
                    }
                    when Time {
                        vNewObject.put(vFieldResult.getName(), Time.newInstance(13, 10, 30, 0));
                        
                    }
                    when Double {
                        vNewObject.put(vFieldResult.getName(), Double.valueOf(Math.Random() * 10));
                        
                    }
                    when Integer { 
                        vNewObject.put(vFieldResult.getName(), Integer.valueOf(Math.Random() * 10));
                    }
                    when URL {
                        String vURL = 'http://www.'+generateString(10)+'.com';
                        vNewObject.put(vFieldResult.getName(), vURL);
                        
                    }
                    when Picklist {
                        if(!vFieldResult.isDependentPicklist() && !vFieldResult.getPicklistValues().isEmpty()){
                            vNewObject.put(vFieldResult.getName(), vFieldResult.getPicklistValues().get(0).getValue());
                        }                        
                        
                    }
                    when String {
                        if(vFieldResult.isUnique()){
                            vNewObject.put(vFieldResult.getName(), generateUniqueString(vFieldResult.getLength()));
                            continue;

                        }
                        if(vFieldResult.getName()=='Name' ){
                            vNewObject.put(vFieldResult.getName(), generateUniqueString(80)); 
                            continue;     
                        }
                        if(vFieldResult.getName().toLowerCase().contains('street')){
                            vNewObject.put(vFieldResult.getName(), Integer.valueOf(Math.Random() * 1000)+' '+ generateString(8)); 
                            continue;     
                        }
                        
                        vNewObject.put(vFieldResult.getName(), generateString(vFieldResult.getLength()));
                        
                        
                        
                    }
                    when Phone {
                        String vTime=String.valueOf(Datetime.now().getTime());
                        String randomPhone=vTime.substring(0, 2)+'-'+vTime.substring(3, 5)+'-'+vTime.substring(6, 9);
                        vNewObject.put(vFieldResult.getName(), randomPhone);
                        
                    }
                    when TextArea {
                        vNewObject.put(vFieldResult.getName(), generateString(100));
                        
                    }
                    when Email {
                        String emailName = generateUniqueString(5);
                        String domain = generateUniqueString(10);
                        vNewObject.put(vFieldResult.getName(), emailName.replaceAll('(\\s+)', '')+'@'+domain.replaceAll('(\\s+)', '')+'.com');
                        
                    }
                    when else {
                        
                    }

            }
        }
        
        }
        System.debug('vNewObject: '+vNewObject);
        return vNewObject;

    } 

    /**********************************************************
     * Random String Generator
     ***********************************************************/
    global static String generateString(Integer length){
        // Define character sets to use
        String alphabet = 'abcdefghijklmnopqrstuvwxyz';
        String upperAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        
        // Initialize the result string
        String result = '';
        Boolean capitalizeNextWord = true;
        
        // Start building the random string
        for (Integer i = 0; i < length; i++) {
            // Generate a random index for each character
            Integer randomIndex;

            // Decide whether to capitalize the next letter (start of a word)
            if (capitalizeNextWord) {
                randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), upperAlphabet.length());
                if(randomIndex==0){
                    result += upperAlphabet.substring(0,1);
                } else {
                    result += upperAlphabet.substring(randomIndex-1,randomIndex);
                }
                capitalizeNextWord = false; // Only capitalize the first letter of a word
            } else {
                randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), alphabet.length());
                if(randomIndex==0){
                    result += alphabet.substring(0,1);
                } else {
                    result += alphabet.substring(randomIndex-1,randomIndex);
                }
                
            }

            // Add a space after every few characters to simulate words (every 5-10 characters)
            if (i > 0 && Math.mod(i, (Integer)(Math.random() * 5) + 5) == 0 && result.length() < length - 1) {
                result += ' ';
                capitalizeNextWord = true; // Capitalize next word after space
            }
        }

        // Ensure the string is trimmed to the exact length if it exceeds the length
        return result.substring(0, Math.min(result.length(), length));
     
         /*
        final String chars = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident sunt in culpa qui officia deserunt mollit anim id est laborum.';
        if(len<256){
            return chars.substring(0, len-2);
        } 
        return chars;
        */
    }

    /**********************************************************
     * Random String Generator - That should be unique
     ***********************************************************/
    global static String generateUniqueString(Integer len){
        final String chars = 'Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
        String vRandom = String.valueOf(Math.roundToLong(Math.random()*10000));

        if(len<256){
            if (len<6) {
                return vRandom;
            }
            return chars.substring(0, len-10)+vRandom;
        } 
        return  chars.substring(0, 240)+vRandom;
    }



    /**********************************************************
     * In progress
     ***********************************************************
    global static void convertChildrentoParents(GonkulatorModel.Gonk vGonk){
        for(sObjectType vObjectType : vGonk.queryMap.keySet()){
            DescribeSObjectResult description = vObjectType.getDescribe();
            for (Schema.ChildRelationship vChild: description.getChildRelationships()) {
                system.debug('Child Object Relationship Name:'+vChild.getRelationshipName());
                if (vChild.getRelationshipName() != null && vGonk.queryMap.get(vObjectType).children.contains(description.getName()+'.'+vChild.getRelationshipName())){  
                    DescribeSObjectResult childDescription1 = vChild.getChildSObject().getDescribe();
                    for(SObjectField vField1 : childDescription1.fields.getMap().values()){
                        //First Level Lookup
                        DescribeFieldResult vFieldResult1 = vField1.getDescribe();
                        if (vFieldResult1.getType() == DisplayType.Reference && vFieldResult1.getReferenceTo().get(0)==vObjectType){
                            System.debug('Leve 1: '+description.getName()+'.'+vFieldResult1.getRelationshipName());
                            for (Schema.ChildRelationship vChild1: childDescription1.getChildRelationships()) {
                                system.debug('Child Object Relationship Name:'+vChild1.getRelationshipName());
                                if (vChild.getRelationshipName() != null && vGonk.queryMap.get(vObjectType).children.contains(description.getName()+'.'+vChild.getRelationshipName()+'.'+vChild1.getRelationshipName())){  
                                    DescribeSObjectResult childDescription2 = vChild1.getChildSObject().getDescribe();
                                    for(SObjectField vField2 : childDescription2.fields.getMap().values()){
                                        //First Level Lookup
                                        DescribeFieldResult vFieldResult2 = vField1.getDescribe();
                                        if (vFieldResult1.getType() == DisplayType.Reference && vFieldResult2.getReferenceTo().get(0)==vChild1.getChildSObject()){
                                            System.debug('Leve 1: '+description.getName()+'.'+vFieldResult1.getRelationshipName()+'.'+vFieldResult2.getRelationshipName());
                
                                        }
                                    }    
                                }
                            }
                        }
                    }    
                }
            }
        }
    }*/
    /**********************************************************
     * CHAT GPT INTEGRATION
     ***********************************************************/
    public static String chatGPTCodeIntegration(String vMessage){
        String STATIC_RESOURCE_NAME='Gonkulator_Documentation';
        String STATIC_RESOURCE_NAME_ORG_SPECIFIC='Gonkulator_Documentation_localOrg';
        // Prepare messages
        List<Map<String, String>> messages = new List<Map<String, String>>();
        try {
            //Retreive Gonkulator specific prompts
            StaticResource resource = [SELECT Body, ContentType FROM StaticResource WHERE Name = :STATIC_RESOURCE_NAME LIMIT 1];
            Blob resourceBlob = resource.Body;
            String resourceContent;

            // Convert Blob to String based on content type
            if (resource.ContentType == 'text/plain' || resource.ContentType == 'text/markdown' || resource.ContentType == 'application/json') {
                resourceContent = resourceBlob.toString();
            } else {
                throw new CalloutException('Unsupported content type: ' + resource.ContentType);
            }

            // Optional: Truncate content to fit within token limits
            //String truncatedContent = truncateContentToTokenLimit(resourceContent, MAX_CONTENT_TOKENS);

            
            // System prompt (optional but recommended)
            messages.add(new Map<String, String>{
                'role' => 'system',
                'content' => 'You are a salesforce.com developer who writes salesforce.com APEX using the Gonkulator (i.e. Goniface) when asked to write Gonkulator Apex Class refer to instruction and example code between the xml tag \'gonkulator\' below. <gonkulator>'+resourceContent+'</gonkulator>'
            });
        } catch (Exception e) {
            throw new CalloutException('Error processing: '+STATIC_RESOURCE_NAME_ORG_SPECIFIC+' -> ' + e.getMessage());
        }

        //Retreive Gonkulator specific prompts
        try{
            StaticResource local_resource = [SELECT Body, ContentType FROM StaticResource WHERE Name = :STATIC_RESOURCE_NAME_ORG_SPECIFIC LIMIT 1];
            if(local_resource!=null){
                Blob local_resourceBlob = local_resource.Body;
                String local_resourceContent;

                // Convert Blob to String based on content type
                if (local_resource.ContentType == 'text/plain' || local_resource.ContentType == 'text/markdown' || local_resource.ContentType == 'application/json') {
                    local_resourceContent = local_resourceBlob.toString();
                    // System prompt (optional but recommended)
                    messages.add(new Map<String, String>{
                        'role' => 'system',
                        'content' => 'As a Salesforce.com APEX developer you have the following information about the Salesfore.com Org you are writing code for: '+local_resourceContent
                    });
                } else {
                    throw new CalloutException('Unsupported content type: ' + local_resource.ContentType);
                }
            }
        } catch (Exception ex){
            system.debug('No Local Prompt defined');
        }
            
            
        try {
            // User message with instruction and content
            messages.add(new Map<String, String>{
                'role' => 'user',
                'content' => vMessage
            });

            String responsebody=sendToChatGPT(messages);
            return responsebody;
            
        } catch (Exception e) {
            throw new CalloutException('AI Callout Exception : ' + e.getMessage());
        }
            
        
    }
    /**********************************************************
     * CHAT GPT Documentation
     ***********************************************************/
    public static String chatGPTDocumentationIntegration(String vMessage){
        String STATIC_RESOURCE_NAME='Gonkulator_Documentation';
        String STATIC_RESOURCE_NAME_ORG_SPECIFIC='Gonkulator_Documentation_localOrg';
        // Prepare messages
        List<Map<String, String>> messages = new List<Map<String, String>>();
        try {
            //Retreive Gonkulator specific prompts
            StaticResource resource = [SELECT Body, ContentType FROM StaticResource WHERE Name = :STATIC_RESOURCE_NAME LIMIT 1];
            Blob resourceBlob = resource.Body;
            String resourceContent;

            // Convert Blob to String based on content type
            if (resource.ContentType == 'text/plain' || resource.ContentType == 'text/markdown' || resource.ContentType == 'application/json') {
                resourceContent = resourceBlob.toString();
            } else {
                throw new CalloutException('Unsupported content type: ' + resource.ContentType);
            }

            
            // System prompt (optional but recommended)
            messages.add(new Map<String, String>{
                'role' => 'system',
                'content' => 'You are a salesforce.com writer that converts technical documents into summarized requirements using laymen business language. refer to the text between the xml tag \'gonkulator\' for information about the Gonkulator frame work. <gonkulator>'+resourceContent+'</gonkulator>'
            });
        } catch (Exception e) {
            throw new CalloutException('Error processing: '+STATIC_RESOURCE_NAME_ORG_SPECIFIC+' -> ' + e.getMessage());
        }

        //Retreive Gonkulator specific prompts
        try{
            StaticResource local_resource = [SELECT Body, ContentType FROM StaticResource WHERE Name = :STATIC_RESOURCE_NAME_ORG_SPECIFIC LIMIT 1];
            if(local_resource!=null){
                Blob local_resourceBlob = local_resource.Body;
                String local_resourceContent;

                // Convert Blob to String based on content type
                if (local_resource.ContentType == 'text/plain' || local_resource.ContentType == 'text/markdown' || local_resource.ContentType == 'application/json') {
                    local_resourceContent = local_resourceBlob.toString();
                    // System prompt (optional but recommended)
                    messages.add(new Map<String, String>{
                        'role' => 'system',
                        'content' => 'As a business writer you also have access to the following information about the Salesforce Org: '+local_resourceContent
                    });
                } else {
                    throw new CalloutException('Unsupported content type: ' + local_resource.ContentType);
                }
            }
        } catch (Exception ex){
            system.debug('No Local Prompt defined');
        }
            
            
        try {
            // User message with instruction and content
            messages.add(new Map<String, String>{
                'role' => 'user',
                'content' => 'summarize the business functionality of the following Gonkulator Apex Class: '+vMessage
            });


            String responsebody=sendToChatGPT(messages);

            return responsebody;
            
        } catch (Exception e) {
            throw new CalloutException('AI Callout Exception : ' + e.getMessage());
        }
            
        
    }
    
    /**********************************************
     * Utility To Send Request to ChatGPT
     ***********************************************/
    public static String sendToChatGPT(List<Map<String, String>> messages){
        String GPT_API_ENDPOINT = 'https://api.openai.com/v1/chat/completions?';
        String GPT_MODEL = 'chatgpt-4o-latest';
        //String GPT_MODEL = 'gpt-4o-mini';
        String API_KEY = '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';  // Replace with your API key
        try {
            // Create the request body
            Map<String, Object> requestBody = new Map<String, Object>{
                'model' => GPT_MODEL,
                'messages' => messages,
                'temperature' => 0.7  // Adjust temperature as needed
            };
            
            // Prepare the HTTP request
            HttpRequest req = new HttpRequest();
            req.setTimeout(60000);
            req.setEndpoint(GPT_API_ENDPOINT);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + API_KEY);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(requestBody));

            // Send the HTTP request
            Http http = new Http();
            HttpResponse res = http.send(req);

            // Check response status
            if (res.getStatusCode() == 200) {
                return res.getBody();
            } else {
                throw new CalloutException('Response Code : '+res.getStatusCode()+' -> ' + res.getBody());
            }
        } catch (Exception e) {
            throw new CalloutException('Http request exception: ' + e.getMessage());
        }
    }
    
     
}