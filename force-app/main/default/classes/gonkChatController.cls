/**
 * @description       :
 * @author            :
 * @group             :
 * @last modified on  : 11-08-2024
 * @last modified by  :
 **/
public without sharing class gonkChatController {
    private static final String MODEL = 'gemini-2.0-flash';
    private static final String API_VERSION = 'v1beta';
    private static final String ENDPOINT = 'https://generativelanguage.googleapis.com/' + API_VERSION + '/models/' + MODEL + ':generateContent?key=AIzaSyClG66g36iOFNJ8vUjUm135cEflFnUSfDU';
    /**********************************************
     * to Generate Apex Class
     ***********************************************/
    @AuraEnabled
    public static void processGeminiIntegration(Id gonkulatorId, String requirement) {
        // Query the Gonkulator__c record to get the Requirement__c field
        gonkulator__Gonkulator__c gonk = [SELECT Id, Name, gonkulator__Object_API_Name__c, gonkulator__Requirement__c, 
                                          gonkulator__Code__c, gonkulator__Execute_Class__c, gonkulator__Execute_On__c
                                          FROM gonkulator__Gonkulator__c WHERE Id = :gonkulatorId LIMIT 1];
        try {
            // Ensure the Requirement__c is not null
            if (requirement == null) {
                throw new AuraHandledException('The requirement field is empty.');
            }
            
            String vPrompt;
            // Call GonkulatorCore to get the response
            if(gonk.gonkulator__Execute_Class__c!=null){
                vPrompt='Create a Gonkulator Apex class called: '
                    +'\''+gonk.gonkulator__Execute_Class__c+'\' This class will be triggered from the '
                    +'\''+gonk.gonkulator__Object_API_Name__c+'\' Object. Requirements for the apex class are found between the xml tag \'requirement\''
                    +'the gonkulator class will invoked for: '+gonk.gonkulator__Execute_On__c
                    +' <requirement>'+requirement+'</requirement> '
                    +' return only the code snippet and code comments but no explaination, enclose the code between three quote marks ';
                
            }
            String response = geminiCodeIntegration(vPrompt);
            
            // Update the Gonkulator__c's Code__c field with the response
            gonk.gonkulator__Code__c = cleanGeminiResponse(response);
            gonk.gonkulator__Requirement__c=requirement;
            update gonk;
        } catch (Exception e) {
            // Handle any exceptions
            Gonkulator_Log__c vLog = new Gonkulator_Log__c();
            vLog.Gonkulator__c=gonk.Id;
            vLog.Messages__c='processGeminiIntegration: \n'+e.getMessage()+' \n '+e.getStackTraceString();
            insert vLog;
            throw new AuraHandledException( e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static void processChatGPTIntegration(Id gonkulatorId, String requirement) {
        // Query the Gonkulator__c record to get the Requirement__c field
        gonkulator__Gonkulator__c gonk = [SELECT Id, Name, gonkulator__Object_API_Name__c, gonkulator__Requirement__c, 
                                          gonkulator__Code__c, gonkulator__Execute_Class__c, gonkulator__Execute_On__c
                                          FROM gonkulator__Gonkulator__c WHERE Id = :gonkulatorId LIMIT 1];
        try {
            // Ensure the Requirement__c is not null
            if (requirement == null) {
                throw new AuraHandledException('The requirement field is empty.');
            }
            
            String vPrompt;
            // Call GonkulatorCore to get the response
            if(gonk.gonkulator__Execute_Class__c!=null){
                vPrompt='Create a Gonkulator Apex class called: '
                    +'\''+gonk.gonkulator__Execute_Class__c+'\' This class will be triggered from the '
                    +'\''+gonk.gonkulator__Object_API_Name__c+'\' Object. Requirements for the apex class are found between the xml tag \'requirement\''
                    +'the gonkulator class will invoked for: '+gonk.gonkulator__Execute_On__c
                    +' <requirement>'+requirement+'</requirement> '
                    +' return only the code snippet and code comments but no explaination, enclose the code between three quote marks ';
                
            }
            String response = gonkulator.GonkulatorCore.chatGPTCodeIntegration(vPrompt);
            
            // Update the Gonkulator__c's Code__c field with the response
            gonk.gonkulator__Code__c = parseGPTResponse(response);
            gonk.gonkulator__Requirement__c=requirement;
            update gonk;
        } catch (Exception e) {
            // Handle any exceptions
            Gonkulator_Log__c vLog = new Gonkulator_Log__c();
            vLog.Gonkulator__c=gonk.Id;
            vLog.Messages__c='processChatGPTIntegration: \n'+e.getMessage()+' \n '+e.getStackTraceString();
            insert vLog;
            throw new AuraHandledException( e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void processGeminiRevision(Id gonkulatorId, String requirement) {
        // Query the Gonkulator__c record to get the Requirement__c field
        gonkulator__Gonkulator__c gonk = [SELECT Id, Name, gonkulator__Object_API_Name__c, gonkulator__Requirement__c, 
                                          gonkulator__Code__c, gonkulator__Execute_Class__c, gonkulator__Execute_On__c
                                          FROM gonkulator__Gonkulator__c WHERE Id = :gonkulatorId LIMIT 1];
        try {
            // Ensure the Requirement__c is not null
            if (requirement == null) {
                throw new AuraHandledException('The requirement field is empty.');
            }
            
            String vPrompt;
            // Call GonkulatorCore to get the response
            if(gonk.gonkulator__Execute_Class__c!=null){
                vPrompt='Create a Gonkulator Apex class called: '
                    +'\''+gonk.gonkulator__Execute_Class__c+'\' This class will be triggered from the '
                    +'\''+gonk.gonkulator__Object_API_Name__c+'\' Object. Requirements for the apex class are found between the xml tag \'requirement\''
                    +'the gonkulator class will invoked for: '+gonk.gonkulator__Execute_On__c
                    +' <requirement>'+requirement+'</requirement> '
                    +' return only the code snippet and code comments but no explaination, enclose the code between three quote marks ';
                
            }
            String response = geminiCodeIntegration(vPrompt);
            
            // Update the Gonkulator__c's Code__c field with the response
            gonk.gonkulator__Code__c = cleanGeminiResponse(response);
            gonk.gonkulator__Requirement__c=requirement;
            update gonk;
        } catch (Exception e) {
            // Handle any exceptions
            Gonkulator_Log__c vLog = new Gonkulator_Log__c();
            vLog.Gonkulator__c=gonk.Id;
            vLog.Messages__c='processGeminiIntegration: \n'+e.getMessage()+' \n '+e.getStackTraceString();
            insert vLog;
            throw new AuraHandledException( e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void processChatGPTRevision(Id gonkulatorId, String requirement) {
        // Query the Gonkulator__c record to get the Requirement__c field
        gonkulator__Gonkulator__c gonk = [SELECT Id, Name, gonkulator__Object_API_Name__c, gonkulator__Requirement__c, 
                                          gonkulator__Code__c, gonkulator__Execute_Class__c, gonkulator__Execute_On__c
                                          FROM gonkulator__Gonkulator__c WHERE Id = :gonkulatorId LIMIT 1];
        try {
            // Ensure the Requirement__c is not null
            if (requirement == null) {
                throw new AuraHandledException('The requirement field is empty.');
            }
            
            String vPrompt;
            // Call GonkulatorCore to get the response
            if(gonk.gonkulator__Execute_Class__c!=null){
                vPrompt='Create a Gonkulator Apex class called: '
                    +'\''+gonk.gonkulator__Execute_Class__c+'\' This class will be triggered from the '
                    +'\''+gonk.gonkulator__Object_API_Name__c+'\' Object. Requirements for the apex class are found between the xml tag \'requirement\''
                    +'the gonkulator class will invoked for: '+gonk.gonkulator__Execute_On__c
                    +' <requirement>'+requirement+'</requirement> '
                    +' return only the code snippet and code comments but no explaination, enclose the code between three quote marks ';
                
            }
            String response = gonkulator.GonkulatorCore.chatGPTCodeIntegration(vPrompt);
            
            // Update the Gonkulator__c's Code__c field with the response
            gonk.gonkulator__Code__c = parseGPTResponse(response);
            gonk.gonkulator__Requirement__c=requirement;
            update gonk;
        } catch (Exception e) {
            // Handle any exceptions
            Gonkulator_Log__c vLog = new Gonkulator_Log__c();
            vLog.Gonkulator__c=gonk.Id;
            vLog.Messages__c='processChatGPTIntegration: \n'+e.getMessage()+' \n '+e.getStackTraceString();
            insert vLog;
            throw new AuraHandledException( e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void processGeminiDocumentation(Id gonkulatorId, String requirement) {
        // Query the Gonkulator__c record to get the Requirement__c field
        gonkulator__Gonkulator__c gonk = [SELECT Id, Name, gonkulator__Object_API_Name__c, gonkulator__Requirement__c, 
                                          gonkulator__Code__c, gonkulator__Execute_Class__c, gonkulator__Execute_On__c, gonkulator__Errors__c,
                                          gonkulator__Function_Description__c
                                          FROM gonkulator__Gonkulator__c WHERE Id = :gonkulatorId LIMIT 1];
        try {
            // Ensure the Requirement__c is not null
            if (requirement == null) {
                throw new AuraHandledException('The requirement field is empty.');
            }
            
            
            
            String vPrompt;
            // Call GonkulatorCore to get the response
            if(gonk.gonkulator__Execute_Class__c!=null){
                vPrompt='Create User Documenation for APEX class between the xml tags \'code\' '
                    +' <code>'+gonk.gonkulator__Code__c+'</code> ';
            }
            
            String response = geminiDocumentationIntegration(vPrompt);
            
            // Update the Gonkulator__c's Code__c field with the response
            gonk.gonkulator__Function_Description__c = formatGeminiContentForRichTextField(response);
            update gonk;
        } catch (Exception e) {
            // Handle any exceptions
            Gonkulator_Log__c vLog = new Gonkulator_Log__c();
            vLog.Gonkulator__c=gonk.Id;
            vLog.Messages__c='processGeminiIntegration: \n'+e.getMessage()+' \n '+e.getStackTraceString();
            insert vLog;
            throw new AuraHandledException( e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void processChatGPTDocumentation(Id gonkulatorId, String requirement) {
        // Query the Gonkulator__c record to get the Requirement__c field
        gonkulator__Gonkulator__c gonk = [SELECT Id, Name, gonkulator__Object_API_Name__c, gonkulator__Requirement__c, 
                                          gonkulator__Code__c, gonkulator__Execute_Class__c, gonkulator__Execute_On__c, gonkulator__Errors__c,
                                          gonkulator__Function_Description__c
                                          FROM gonkulator__Gonkulator__c WHERE Id = :gonkulatorId LIMIT 1];
        try {
            // Ensure the Requirement__c is not null
            if (requirement == null) {
                throw new AuraHandledException('The requirement field is empty.');
            }
            
            
            
            String vPrompt;
            // Call GonkulatorCore to get the response
            if(gonk.gonkulator__Execute_Class__c!=null){
                vPrompt='Create User Documenation for APEX class between the xml tags \'code\' '
                    +' <code>'+gonk.gonkulator__Code__c+'</code> ';
            }
            
            String response = gonkulator.GonkulatorCore.chatGPTDocumentationIntegration(vPrompt);
            
            // Update the Gonkulator__c's Code__c field with the response
            gonk.gonkulator__Function_Description__c = formatContentForRichTextField(response);
            update gonk;
        } catch (Exception e) {
            // Handle any exceptions
            Gonkulator_Log__c vLog = new Gonkulator_Log__c();
            vLog.Gonkulator__c=gonk.Id;
            vLog.Messages__c='processChatGPTIntegration: \n'+e.getMessage()+' \n '+e.getStackTraceString();
            insert vLog;
            throw new AuraHandledException( e.getMessage());
        }
    }
    
    /**********************************************
     * Method to create a test class from existing code
     ***********************************************/
    @AuraEnabled
    public static void processGeminiTestClass(Id gonkulatorId) {
        // Query the Gonkulator__c record to get the Requirement__c field
        gonkulator__Gonkulator__c gonk = [SELECT Id, Name, gonkulator__Requirement__c, gonkulator__Code__c, gonkulator__Execute_Class__c, gonkulator__Test_Class_Code__c FROM gonkulator__Gonkulator__c WHERE Id = :gonkulatorId LIMIT 1];
        try {
            // Ensure the Requirement__c is not null
            if (gonk.gonkulator__Code__c == null) {
                throw new AuraHandledException('The Code field is empty.');
            }
            String vMessage = 'Create an Apex Test class called '+gonk.gonkulator__Execute_Class__c+'_Test for the following Apex class: '+gonk.gonkulator__Code__c;
            
            // Call GonkulatorCore to get the response
            String response = geminiCodeIntegration(vMessage);
            
            // Update the Gonkulator__c's Code__c field with the response
            gonk.gonkulator__Test_Class_Code__c = cleanGeminiResponse(response);
            update gonk;
        } catch (Exception e) {
            // Handle any exceptions
            Gonkulator_Log__c vLog = new Gonkulator_Log__c();
            vLog.Gonkulator__c=gonk.Id;
            vLog.Messages__c='processGeminiTestClass: \n'+e.getMessage()+' \n '+e.getStackTraceString();
            insert vLog;
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void processChatGPTTestClass(Id gonkulatorId) {
        // Query the Gonkulator__c record to get the Requirement__c field
        gonkulator__Gonkulator__c gonk = [SELECT Id, Name, gonkulator__Requirement__c, gonkulator__Code__c, gonkulator__Execute_Class__c, gonkulator__Test_Class_Code__c FROM gonkulator__Gonkulator__c WHERE Id = :gonkulatorId LIMIT 1];
        try {
            // Ensure the Requirement__c is not null
            if (gonk.gonkulator__Code__c == null) {
                throw new AuraHandledException('The Code field is empty.');
            }
            String vMessage = 'Create an Apex Test class called '+gonk.gonkulator__Execute_Class__c+'_Test for the following Apex class: '+gonk.gonkulator__Code__c;
            
            // Call GonkulatorCore to get the response
            String response = gonkulator.GonkulatorCore.chatGPTCodeIntegration(vMessage);
            
            // Update the Gonkulator__c's Code__c field with the response
            gonk.gonkulator__Test_Class_Code__c = parseGPTResponse(response);
            update gonk;
        } catch (Exception e) {
            // Handle any exceptions
            Gonkulator_Log__c vLog = new Gonkulator_Log__c();
            vLog.Gonkulator__c=gonk.Id;
            vLog.Messages__c='processChatGPTTestClass: \n'+e.getMessage()+' \n '+e.getStackTraceString();
            insert vLog;
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**********************************************
     * Method to clear gonculator code field
     ***********************************************/
    
    @AuraEnabled
    public static void processClearCode(Id gonkulatorId) {
        gonkulator__Gonkulator__c gonk = new gonkulator__Gonkulator__c();
        gonk.Id = gonkulatorId;
        gonk.gonkulator__Code__c = '';
        
        update gonk;
        
    }
    
    @AuraEnabled
    public static void processClearTestClass(Id gonkulatorId) {
        gonkulator__Gonkulator__c gonk = new gonkulator__Gonkulator__c();
        gonk.Id = gonkulatorId;
        gonk.gonkulator__Test_Class_Code__c = '';
        update gonk;
    }
    
    @AuraEnabled
    public static void processClearDocument(Id gonkulatorId) {
        gonkulator__Gonkulator__c gonk = new gonkulator__Gonkulator__c();
        gonk.Id = gonkulatorId;
        gonk.gonkulator__Function_Description__c  = '';
        update gonk;
    }
    
    @AuraEnabled
    public static gonkulator__Gonkulator__c getGonkulatorData(Id gonkulatorId) {
        return [SELECT Name, gonkulator__Requirement__c,gonkulator__Function_Description__c, gonkulator__Code__c,gonkulator__Test_Class_Code__c, gonkulator__Errors__c FROM gonkulator__Gonkulator__c WHERE Id = :gonkulatorId LIMIT 1];
    }
    
    
    
    
    /**********************************************
     * Create an Apex class
     ***********************************************/
    @Future(callout=true)
    public static void createApexClass(Id gonkulatorId) {
        system.debug(gonkulatorId);
        // Endpoint for Salesforce Tooling API
        String toolingEndpoint = URL.getOrgDomainUrl().toExternalForm() + '/services/data/v57.0/tooling/sobjects/ApexClass';
        
        // Query the Gonkulator__c record to get the Requirement__c field
        gonkulator__Gonkulator__c gonk = [SELECT Id, Name, gonkulator__Requirement__c, gonkulator__Code__c, gonkulator__Execute_Class__c, gonkulator__Test_Class_Code__c FROM gonkulator__Gonkulator__c WHERE Id = :gonkulatorId LIMIT 1];
        
        
        // Request body in JSON format
        String requestBody = JSON.serialize(new Map<String, String>{
            'Name' => gonk.gonkulator__Execute_Class__c,
            'Body' => gonk.gonkulator__Code__c
        });
        
        String sessionId = UserInfo.getSessionId();
        
        // Create HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(toolingEndpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(requestBody);
        
        // Send the request
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // Handle the response
        if (res.getStatusCode() == 201) {
            gonk.gonkulator__Errors__c=null;//clear the errors box
            System.debug('Apex class created successfully: ' + res.getBody());
        } else {
            System.debug('Failed to create Apex class. Response: ' + res.getBody());
            gonk.gonkulator__Errors__c=res.getBody();
            //throw new CustomException('Error creating Apex class: ' + res.getBody());
        }
        update gonk;
        
    }
    /**********************************************
     * Create an Apex Test class
     ***********************************************/
    @Future(callout=true)
    public static void createApexTestClass(Id gonkulatorId) {
        system.debug(gonkulatorId);
        // Endpoint for Salesforce Tooling API
        String toolingEndpoint = URL.getOrgDomainUrl().toExternalForm() + '/services/data/v57.0/tooling/sobjects/ApexClass';
        
        // Query the Gonkulator__c record to get the Requirement__c field
        gonkulator__Gonkulator__c gonk = [SELECT Id, Name, gonkulator__Requirement__c, gonkulator__Code__c, gonkulator__Execute_Class__c, gonkulator__Test_Class_Code__c FROM gonkulator__Gonkulator__c WHERE Id = :gonkulatorId LIMIT 1];
        
        //Send the Test Class
        if(gonk.gonkulator__Test_Class_Code__c!=null){
            String sessionId = UserInfo.getSessionId();
            
            // Request body in JSON format
            String requestBody = JSON.serialize(new Map<String, String>{
                'Name' => gonk.gonkulator__Execute_Class__c+'_Test',
                'Body' => gonk.gonkulator__Test_Class_Code__c
            });
            // Create HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(toolingEndpoint);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + sessionId);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(requestBody);
            
            requestBody=JSON.serialize(new Map<String, String>{
                'Name' => gonk.gonkulator__Execute_Class__c+'_Test',
                'Body' => gonk.gonkulator__Test_Class_Code__c
            });
            // Send the request
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            
            // Handle the response
            if (res.getStatusCode() == 201) {
                System.debug('Apex Test class created successfully: ' + res.getBody());
            } else {
                System.debug('Failed to create Test Class Apex class. Response: ' + res.getBody());
                gonk.gonkulator__Errors__c=res.getBody();
                update gonk;
                //throw new CustomException('Error creating Apex class: ' + res.getBody());
            }
        }
    }
    
    // Custom Exception class
    public class CustomException extends Exception {}
    
    @AuraEnabled(cacheable=true)
    public static list<AggregateResult> getObjectNames(){
        return [SELECT SObjectType FROM ObjectPermissions GROUP BY SObjectType ORDER BY SObjectType ASC ];
    }
    
    @AuraEnabled(cacheable=true)
    public static list<gonkulator__Gonkulator__c> getGonkulatorsWithSameObjAPINames(string objectApiName){
        return [select id, name from gonkulator__Gonkulator__c where gonkulator__Object_API_Name__c = :objectApiName];
        
    }
    @AuraEnabled
    public static void getGonkulatorCompile(Id gonkulatorId){
        try{
            gonkulator__Gonkulator__c gonk = [SELECT Id, gonkulator__Compile__c FROM gonkulator__Gonkulator__c WHERE Id = :gonkulatorId LIMIT 1];
            
            if(gonk != null){
                gonk.gonkulator__Compile__c = true;
            }
            update gonk;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /**********************************************
     * Format RichText Field
     ***********************************************/
    public static String formatGeminiContentForRichTextField(String content){
        String   contentHTML = content.replace('&', '&amp;')
            .replace('<', '&lt;')
            .replace('>', '&gt;')
            .replace('\"', '&quot;')
            .replace('\'', '&#39;');
        
        // Replace line breaks with HTML tags
        contentHTML = contentHTML.replace('\n', '<br/>');
        // Replace Markdown headings with corresponding HTML tags
        contentHtml = contentHtml.replaceAll('(?m)^# (.*?)$', '<h1>$1</h1>')
            .replaceAll('(?m)^## (.*?)$', '<h2>$1</h2>')
            .replaceAll('(?m)^### (.*?)$', '<h3>$1</h3>')
            .replaceAll('(?m)^#### (.*?)$', '<h4>$1</h4>')
            .replaceAll('(?m)^##### (.*?)$', '<h5>$1</h5>')
            .replaceAll('(?m)^###### (.*?)$', '<h6>$1</h6>');
        
        // Replace bold and italic formatting
        contentHtml = contentHtml.replaceAll('\\*\\*(.*?)\\*\\*', '<strong>$1</strong>')
            .replaceAll('\\*(.*?)\\*', '<em>$1</em>');
        
        
        // Replace line breaks with HTML line breaks
        contentHtml = contentHtml.replace('\n', '<br/>');
        
        // Replace code blocks
        contentHtml = contentHtml.replaceAll('```([.*\\S]*?)```', '<pre><code>$1</code></pre>');
        
        // Replace inline code
        contentHtml = contentHtml.replaceAll('`([^`]*)`', '<code>$1</code>');
        
        return contentHtml;
        
    }
    
    public static String formatContentForRichTextField(String jsonPayload) {
        try {
            
            // Deserialize the JSON payload
            Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(jsonPayload);
            
            String contentHTML;
            // Navigate through the JSON structure to get the content
            if (payloadMap.containsKey('choices')) {
                List<Object> choices = (List<Object>) payloadMap.get('choices');
                if (!choices.isEmpty()) {
                    Map<String, Object> choice = (Map<String, Object>) choices[0];
                    if (choice.containsKey('message')) {
                        Map<String, Object> message = (Map<String, Object>) choice.get('message');
                        if (message.containsKey('content')) {
                            String content = (String) message.get('content');
                            if (content != null) {
                                // Escape special HTML characters to prevent any issues in the Rich Text Field
                                contentHTML = content.replace('&', '&amp;')
                                    .replace('<', '&lt;')
                                    .replace('>', '&gt;')
                                    .replace('\"', '&quot;')
                                    .replace('\'', '&#39;');
                                
                                // Replace line breaks with HTML tags
                                contentHTML = contentHTML.replace('\n', '<br/>');
                                // Replace Markdown headings with corresponding HTML tags
                                contentHtml = contentHtml.replaceAll('(?m)^# (.*?)$', '<h1>$1</h1>')
                                    .replaceAll('(?m)^## (.*?)$', '<h2>$1</h2>')
                                    .replaceAll('(?m)^### (.*?)$', '<h3>$1</h3>')
                                    .replaceAll('(?m)^#### (.*?)$', '<h4>$1</h4>')
                                    .replaceAll('(?m)^##### (.*?)$', '<h5>$1</h5>')
                                    .replaceAll('(?m)^###### (.*?)$', '<h6>$1</h6>');
                                
                                // Replace bold and italic formatting
                                contentHtml = contentHtml.replaceAll('\\*\\*(.*?)\\*\\*', '<strong>$1</strong>')
                                    .replaceAll('\\*(.*?)\\*', '<em>$1</em>');
                                
                                
                                // Replace line breaks with HTML line breaks
                                contentHtml = contentHtml.replace('\n', '<br/>');
                                
                                // Replace code blocks
                                contentHtml = contentHtml.replaceAll('```([.*\\S]*?)```', '<pre><code>$1</code></pre>');
                                
                                // Replace inline code
                                contentHtml = contentHtml.replaceAll('`([^`]*)`', '<code>$1</code>');
                            }
                        }
                    }
                }
                
                return contentHTML;
                
            }
        } catch (Exception e) {
            System.debug('Error formatting content for Rich Text Field: ' + e.getMessage());
        }
        return '';
    }
    
    /**********************************************
     * Utility Method to parse the GPT Response
     ***********************************************/
    public static String parseGPTResponse(String jsonPayload) {
        String apexCode = '';
        
        // Deserialize the JSON payload
        Map<String, Object> payloadMap = (Map<String, Object>) JSON.deserializeUntyped(jsonPayload);
        
        // Navigate through the JSON structure to get the content
        if (payloadMap.containsKey('choices')) {
            List<Object> choices = (List<Object>) payloadMap.get('choices');
            if (!choices.isEmpty()) {
                Map<String, Object> choice = (Map<String, Object>) choices[0];
                if (choice.containsKey('message')) {
                    Map<String, Object> message = (Map<String, Object>) choice.get('message');
                    if (message.containsKey('content')) {
                        String content = (String) message.get('content');
                        
                        // Extract the code block between "apex\n" and the next occurrence of "\n\n"
                        Integer codeStart = content.indexOf('```');
                        if (codeStart != -1) {
                            Integer codeEnd = content.lastIndexOf('```');
                            if (codeEnd == -1) {
                                // If no double newline is found, assume the code runs to the end of the content
                                codeEnd = content.length();
                            }
                            apexCode = content.substring(codeStart + 3, codeEnd);
                            
                            // Replace escaped newlines and tabs with actual newlines and tabs
                            apexCode = apexCode.replace('\\n', '\n').replace('\\t', '\t');
                        }
                    }
                }
            }
        }
        
        return apexCode;
    }
    
    private static String cleanGeminiResponse(String rawResponse){
        return rawResponse
            .replaceAll('<gonkulator>', '')
            .replaceAll('</gonkulator>', '')
            .replaceAll('```', '')
            .replaceAll('\\bjava\\b', '') // removes the word 'java' if present
            .trim();
    }
    
    
    // gemini method for gonkulator.GonkulatorCore.chatGPTCodeIntegration
    public static String geminiCodeIntegration(String vMessage) {
        String STATIC_RESOURCE_NAME='Gonkulator_Documentation';
        String STATIC_RESOURCE_NAME_ORG_SPECIFIC='Gonkulator_Documentation_localOrg';
        List<String> messages = new List<String>();
        
        try {
            StaticResource resource = [
                SELECT Body, ContentType 
                FROM StaticResource 
                WHERE Name = :STATIC_RESOURCE_NAME 
                LIMIT 1
            ];
            String resourceContent = getStringFromBlob(resource.Body, resource.ContentType);
            messages.add('You are a salesforce.com developer who writes Salesforce.com APEX using the Gonkulator (i.e. Goniface)... <gonkulator>' + resourceContent + '</gonkulator>');
        } catch (Exception e) {
            throw new CalloutException('Error processing: ' + STATIC_RESOURCE_NAME + ' -> ' + e.getMessage());
        }
        
        try {
            StaticResource local_resource = [
                SELECT Body, ContentType 
                FROM StaticResource 
                WHERE Name = :STATIC_RESOURCE_NAME_ORG_SPECIFIC 
                LIMIT 1
            ];
            String local_resourceContent = getStringFromBlob(local_resource.Body, local_resource.ContentType);
            messages.add('Org-specific context: ' + local_resourceContent);
        } catch (Exception e) {
            System.debug('No Local Prompt defined');
        }
        
        // Add the user message
        messages.add( vMessage
            );
        
        return sendToGemini(messages);
    }
    
    
    // Gemini Callout Function
    private static String sendToGemini(List<String> messages) {
        try {
            List<Object> textParts = new List<Object>();
            
            for (String msg : messages) {
                textParts.add(
                new Map<String, Object>{ 'text' => msg }
                );
                
            }
            
            Map<String, Object> payload = new Map<String, Object>{
                'contents' => new Map<String, Object>{
                    'parts'=> textParts
                }
            };
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(ENDPOINT);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(payload));
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> candidates = (List<Object>) responseMap.get('candidates');
                
                if (!candidates.isEmpty()) {
                    Map<String, Object> content = (Map<String, Object>) ((Map<String, Object>) candidates[0]).get('content');
                    List<Object> parts = (List<Object>) content.get('parts');
                    String resultText = (String) ((Map<String, Object>) parts[0]).get('text');
                    system.debug('resultText'+resultText);
                    return resultText;
                }
            } else {
                throw new CalloutException('Gemini Call Failed: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
            
        } catch (Exception e) {
            throw new CalloutException('Gemini Callout Exception: ' + e.getMessage());
        }
        
        return null;
    }
    
    private static String getStringFromBlob(Blob tblob, String contentType) {
        if (contentType == 'text/plain' || contentType == 'text/markdown' || contentType == 'application/json') {
            return tblob.toString();
        }
        throw new CalloutException('Unsupported content type: ' + contentType);
    }
    
    // gemini method for gonkulator.GonkulatorCore.chatGPTDocumentationIntegration
    public static String geminiDocumentationIntegration(String vMessage){
        String STATIC_RESOURCE_NAME='Gonkulator_Documentation';
        String STATIC_RESOURCE_NAME_ORG_SPECIFIC='Gonkulator_Documentation_localOrg';
        // Prepare messages
        List<String> messages = new List<String>();
        try {
            //Retreive Gonkulator specific prompts
            StaticResource resource = [SELECT Body, ContentType FROM StaticResource WHERE Name = :STATIC_RESOURCE_NAME LIMIT 1];
            Blob resourceBlob = resource.Body;
            
            // Convert Blob to String based on content type
            String resourceContent=getStringFromBlob(resourceBlob, resource.ContentType);
            
            
            // System prompt (optional but recommended)
            messages.add('You are a salesforce.com writer that converts technical documents into summarized requirements using laymen business language. refer to the text between the xml tag \'gonkulator\' for information about the Gonkulator frame work. <gonkulator>'+resourceContent+'</gonkulator>'
                );
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
                    messages.add('As a business writer you also have access to the following information about the Salesforce Org: '+local_resourceContent);
                } else {
                    throw new CalloutException('Unsupported content type: ' + local_resource.ContentType);
                }
            }
        } catch (Exception ex){
            system.debug('No Local Prompt defined');
        }
        
        
        try {
            // User message with instruction and content
            messages.add('summarize the business functionality of the following Gonkulator Apex Class: '+vMessage);
            
            
            String responsebody=sendToGemini(messages);
            
            return responsebody;
            
        } catch (Exception e) {
            throw new CalloutException('AI Callout Exception : ' + e.getMessage());
        }
        
        
    }
    
}