@isTest
public class duplicateCheck_GonkImpl_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test Contacts linked to the Account
        Contact testContact1 = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'johndoe@example.com', Phone = '1234567890', AccountId = testAccount.Id);
        Contact testContact2 = new Contact(FirstName = 'Jane', LastName = 'Smith', Email = 'janesmith@example.com', Phone = '0987654321', AccountId = testAccount.Id);
        insert new List<Contact>{testContact1, testContact2};

        // Create a Gonkulator Entry
        gonkulator__Gonkulator__c gonkulatorRecord = new gonkulator__Gonkulator__c();
        gonkulatorRecord.gonkulator__Execute_Class__c = 'duplicateCheck_GonkImpl';
        gonkulatorRecord.gonkulator__Execute_On__c = 'BEFORE_INSERT';
        gonkulatorRecord.gonkulator__Object_API_Name__c = 'Contact';
        gonkulatorRecord.gonkulator__Active__c = true;
        insert gonkulatorRecord;
    }

    @isTest
    static void testValidate_NoDuplicates() {
        // Prepare mock Gonkulator data
        Contact newContact = new Contact(FirstName = 'Emily', LastName = 'Brown', Email = 'emilybrown@example.com', Phone = '1122334455');
        
        gonkulator.GonkulatorModel.Gonk gonkData = new gonkulator.GonkulatorModel.Gonk();
        gonkData.objectList.add(newContact);
        gonkData.gonkulatorRecord = [SELECT Id, gonkulator__Execute_Class__c FROM gonkulator__Gonkulator__c WHERE gonkulator__Execute_Class__c = 'duplicateCheck_GonkImpl'];
        gonkData.className = 'duplicateCheck_GonkImpl';
        
        // Instantiate and test the Gonkulator implementation
        duplicateCheck_GonkImpl testImpl = new duplicateCheck_GonkImpl();
        testImpl.init(gonkData);
        testImpl.getData();
        testImpl.validate();
        

    }

    @isTest
    static void testValidate_WithDuplicates() {
        // Prepare mock Gonkulator data with a duplicate email
        Contact newContact = new Contact(FirstName = 'Mark', LastName = 'Doe', Email = 'johndoe@example.com', Phone = '9999999999');
        
        gonkulator.GonkulatorModel.Gonk gonkData = new gonkulator.GonkulatorModel.Gonk();
        gonkData.objectList.add(newContact);
        gonkData.gonkulatorRecord = [SELECT Id, gonkulator__Execute_Class__c FROM gonkulator__Gonkulator__c WHERE gonkulator__Execute_Class__c = 'duplicateCheck_GonkImpl'];
        gonkData.className = 'duplicateCheck_GonkImpl';
        
        // Instantiate and test the Gonkulator implementation
        duplicateCheck_GonkImpl testImpl = new duplicateCheck_GonkImpl();
        testImpl.init(gonkData);
        testImpl.getData();
        testImpl.validate();
        testImpl.execute();
        testImpl.dml();
        
            
    }
}