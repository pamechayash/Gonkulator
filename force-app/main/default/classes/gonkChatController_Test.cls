@isTest
public class gonkChatController_Test {
    @testSetup
    static void setupTestData() {
        // Create a sample Gonkulator__c record
        gonkulator__Gonkulator__c gonk = new gonkulator__Gonkulator__c(
            gonkulator__Requirement__c = 'Test Requirement',
            gonkulator__Code__c = 'public class TestClass {}',
            gonkulator__Test_Class_Code__c = 'public class TestClass_Test {}',
            gonkulator__Execute_Class__c = 'TestClass'
        );
        insert gonk;
    }

    @isTest
    static void testProcessChatGPTIntegration_Success() {
        // Fetch the test data
        gonkulator__Gonkulator__c gonk = [SELECT Id FROM gonkulator__Gonkulator__c LIMIT 1];
        String requirement = 'Write an Apex class using the gonkulator interface class demo_gonk_GonkImpl that updates Case.Status_updated__c field with current timestamp when the Case.status field changes';

        // Set the mock response class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        // Call the method
        gonkChatController.processChatGPTIntegration(gonk.Id, requirement);
        Test.stopTest();

        // Fetch the updated record
        gonkulator__Gonkulator__c updatedGonk = [SELECT gonkulator__Requirement__c, gonkulator__Code__c FROM gonkulator__Gonkulator__c WHERE Id = :gonk.Id LIMIT 1];

    }

    @isTest
    static void testProcessChatGPTIntegration_EmptyRequirement() {
        // Fetch the test data
        gonkulator__Gonkulator__c gonk = [SELECT Id FROM gonkulator__Gonkulator__c LIMIT 1];

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            // Call the method with null requirement
            gonkChatController.processChatGPTIntegration(gonk.Id, null);
        } catch (AuraHandledException e) {
            // Exception is caught as expected
            exceptionThrown = true;
        }
        Test.stopTest();

        // Confirm that an exception was thrown
        System.assert(exceptionThrown, 'An AuraHandledException should have been thrown for a null requirement');
    }

    @isTest
    static void testProcessChatGPTTestClass_Success() {
        // Fetch the test data
        gonkulator__Gonkulator__c gonk = [SELECT Id FROM gonkulator__Gonkulator__c LIMIT 1];

        // Set the mock response class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        // Call the method
        gonkChatController.processChatGPTTestClass(gonk.Id);
        Test.stopTest();

        // Fetch the updated record
        gonkulator__Gonkulator__c updatedGonk = [SELECT gonkulator__Test_Class_Code__c FROM gonkulator__Gonkulator__c WHERE Id = :gonk.Id LIMIT 1];

    }

    
    @isTest
    static void testProcessChatGPTDocumentation_Success() {
        // Fetch the test data
        gonkulator__Gonkulator__c gonk = [SELECT Id FROM gonkulator__Gonkulator__c LIMIT 1];
        String requirement = 'Generate user documentation for the Apex class';

        // Set the mock response class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        // Call the method
        gonkChatController.processChatGPTDocumentation(gonk.Id, requirement);
        // Manually call formatContentForRichTextField to verify the formatting
        String vformattedContent = '{"choices":[{"message":{"content":"# Sample Documentation\\nThis is **bold text** and *italic text*."}}]}';
        String formattedContent = gonkChatController.formatContentForRichTextField(vformattedContent);
        // Manually call parseGPTResponse to verify parsing logic
        String vparsedCode = '{"choices":[{"message":{"content":"```apex\\npublic class SampleClass {\\n    // Sample method\\n    public void sampleMethod() {\\n        System.debug(\'Hello World\');\\n    }\\n}\\n```"}}]}';
        String parsedCode = gonkChatController.parseGPTResponse(vparsedCode);
        Test.stopTest();

        // Fetch the updated record
        gonkulator__Gonkulator__c updatedGonk = [SELECT gonkulator__Function_Description__c FROM gonkulator__Gonkulator__c WHERE Id = :gonk.Id LIMIT 1];

     
    }

 @isTest
static void testProcessClearCode() {
    // Fetch the test data
    gonkulator__Gonkulator__c gonk = [SELECT Id FROM gonkulator__Gonkulator__c LIMIT 1];

    // Test success scenario
    Test.startTest();
    gonkChatController.processClearCode(gonk.Id);
    Test.stopTest();


}


    @isTest
    static void testProcessClearTestClass() {
        // Fetch the test data
        gonkulator__Gonkulator__c gonk = [SELECT Id FROM gonkulator__Gonkulator__c LIMIT 1];

        Test.startTest();
        gonkChatController.processClearTestClass(gonk.Id);
        Test.stopTest();

        // Fetch the updated record
        gonkulator__Gonkulator__c updatedGonk = [SELECT gonkulator__Test_Class_Code__c FROM gonkulator__Gonkulator__c WHERE Id = :gonk.Id LIMIT 1];
    }

    @isTest
    static void testProcessClearDocument() {
        // Fetch the test data
        gonkulator__Gonkulator__c gonk = [SELECT Id FROM gonkulator__Gonkulator__c LIMIT 1];

        Test.startTest();
        gonkChatController.processClearDocument(gonk.Id);
        Test.stopTest();

        // Fetch the updated record
        gonkulator__Gonkulator__c updatedGonk = [SELECT gonkulator__Function_Description__c FROM gonkulator__Gonkulator__c WHERE Id = :gonk.Id LIMIT 1];

    }

    @isTest
    static void testCreateApexClass_Success() {
        // Fetch the test data
        gonkulator__Gonkulator__c gonk = [SELECT Id FROM gonkulator__Gonkulator__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        // Call the method
        gonkChatController.createApexClass(gonk.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetGonkulatorData() {
        // Fetch the test data
        gonkulator__Gonkulator__c gonk = [SELECT Id FROM gonkulator__Gonkulator__c LIMIT 1];

        Test.startTest();
        // Call the method
        gonkulator__Gonkulator__c result = gonkChatController.getGonkulatorData(gonk.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetObjectNames() {
        Test.startTest();
        // Call the method
        List<AggregateResult> result = gonkChatController.getObjectNames();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(0, result.size(), 'Result should not be empty');
    }

    @isTest
    static void testGetObjectWithSameAPINames() {
        Test.startTest();
        // Call the method
        List<gonkulator__Gonkulator__c> result = gonkChatController.getGonkulatorsWithSameObjAPINames('Account');
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
    }
     @isTest
    static void testcompile() {
        // Fetch the test data
        gonkulator__Gonkulator__c gonk = [SELECT Id FROM gonkulator__Gonkulator__c LIMIT 1];
         // Set the mock response class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        gonkChatController.getGonkulatorCompile(gonk.Id);
        Test.stopTest();
    }

}