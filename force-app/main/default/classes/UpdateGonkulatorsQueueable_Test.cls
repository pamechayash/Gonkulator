@IsTest
public class UpdateGonkulatorsQueueable_Test {

    @IsTest
    static void testUpdateGonkulators() {
        // Start test context
        Test.startTest();

        // Create a list of Gonkulator__c records for testing
        List<Gonkulator__c> gonkulators = new List<Gonkulator__c>();
        for (Integer i = 0; i < 5; i++) {
            Gonkulator__c gonk = new Gonkulator__c(
                Last_Executed_Status__c = 'Pending'
            );
            gonkulators.add(gonk);
        }

        // Insert the test records
        insert gonkulators;

        // Enqueue the UpdateGonkulatorsQueueable job for updating Gonkulator__c records
        System.enqueueJob(new UpdateGonkulatorsQueueable(gonkulators));

        // End test context and execute the enqueued job
        Test.stopTest();

    }

    @IsTest
    static void testInsertGonkulatorLogs() {
        // Start test context
        Test.startTest();

        // Create a list of Gonkulator_Log__c records for testing
        Gonkulator__c gonk = new Gonkulator__c(
                Last_Executed_Status__c = 'Pending');
        insert gonk;
        List<Gonkulator_Log__c> logList = new List<Gonkulator_Log__c>();
        for (Integer i = 0; i < 5; i++) {
            Gonkulator_Log__c log = new Gonkulator_Log__c(
                Messages__c = 'Test Description ' + i,
                Gonkulator__c=gonk.Id
            );
            logList.add(log);
        }

        // Enqueue the UpdateGonkulatorsQueueable job for inserting Gonkulator_Log__c records
        System.enqueueJob(new UpdateGonkulatorsQueueable(logList));

        // End test context and execute the enqueued job
        Test.stopTest();

    }

    @IsTest
    static void testNoActionScenario() {
        // Start test context
        Test.startTest();

        // Test with empty lists to ensure no exceptions are thrown
        List<Gonkulator__c> emptyGonkList = new List<Gonkulator__c>();
        List<Gonkulator_Log__c> emptyLogList = new List<Gonkulator_Log__c>();

        // Enqueue the UpdateGonkulatorsQueueable job with empty lists
        System.enqueueJob(new UpdateGonkulatorsQueueable(emptyGonkList));
        System.enqueueJob(new UpdateGonkulatorsQueueable(emptyLogList));

        // End test context and execute the enqueued job
        Test.stopTest();

        // Verify that no records were updated or inserted
        List<Gonkulator__c> updatedGonkulators = [SELECT Id, Last_Executed_Status__c FROM Gonkulator__c];
        List<Gonkulator_Log__c> insertedLogs = [SELECT Id, Name, Messages__c FROM Gonkulator_Log__c];

        // Both lists should still be empty
        System.assertEquals(0, updatedGonkulators.size(), 'No Gonkulator__c records should have been updated.');
        System.assertEquals(0, insertedLogs.size(), 'No Gonkulator_Log__c records should have been inserted.');
    }
}