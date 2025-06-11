@isTest(SeeAllData=false)
public without sharing class Demo_GonkImpl_Test {
    @TestSetup
    static void createTestData(){
        Account vAccount = (Account)GonkulatorCore.populateObjectData(Account.getSObjectType());
        vAccount.Name='Demo_GonkImpl';
        vAccount.NumberOfEmployees=500;
        vAccount.BillingStreet='123 E Main Street';
        Insert vAccount;

        Contact vContact =(Contact)GonkulatorCore.populateObjectData(Schema.SObjectType.Contact.getSObjectType());
        vContact.AccountId=vAccount.Id;
        insert vContact;
        
        // Opportunity vOpportunity = (Opportunity)GonkulatorCore.populateObjectData(Schema.SObjectType.Opportunity.getSObjectType());
        // vOpportunity.AccountId=vAccount.Id;
        // Insert vOpportunity;

        
        
        
        //Create a Gonkulator Entry
        Gonkulator__c vGonkulator = new Gonkulator__c();
        vGonkulator.Execute_Class__c='Demo_GonkImpl';
        vGonkulator.Execute_On__c='AFTER_UPDATE;AFTER_INSERT';
        vGonkulator.Object_API_Name__c='Account';
        vGonkulator.Active__c=true;
        vGonkulator.Reflection__c=true;
        vGonkulator.Debug__c=true;
        insert vGonkulator;
    }
    @isTest
    static void gonkExecute(){ 
       	Gonkulator__c vGonkulator = [Select Id, Execute_Class__c FROM Gonkulator__c where Execute_Class__c='Demo_GonkImpl'];
        Account vAccount = [Select Id, NumberOfEmployees from Account where Name='Demo_GonkImpl'];

        Lead vLead = (Lead)GonkulatorCore.populateObjectData(Schema.SObjectType.Lead.getSObjectType());
        insert vLead;
        Contact vContact =(Contact)GonkulatorCore.populateObjectData(Schema.SObjectType.Contact.getSObjectType());
        vContact.AccountId=vAccount.Id;
        insert vContact;
        
        GonkulatorModel.Gonk vGonk = new GonkulatorModel.Gonk();
        vGonk.objectList.add(vAccount);
        vGonk.gonkulatorRecord=vGonkulator;
        vGonk.className='Demo_GonkImpl';
        
        try {
            Demo_GonkImpl vDemo_GonkImpl = new Demo_GonkImpl();
            vDemo_GonkImpl.init(vGonk);
            vDemo_GonkImpl.getData();
            vDemo_GonkImpl.validate();
            vDemo_GonkImpl.execute();
            vDemo_GonkImpl.dml();
        } catch (Exception e) {
            system.debug(e.getMessage());
        }
        

   
    }
    @isTest
    static void gonkValidateException(){ 
       	Gonkulator__c vGonkulator = [Select Id, Execute_Class__c FROM Gonkulator__c where Execute_Class__c='Demo_GonkImpl'];
        Account vAccount = [Select Id, NumberOfEmployees from Account where Name='Demo_GonkImpl'];
        vAccount.NumberOfEmployees=120;
        update vAccount;
        
        GonkulatorModel.Gonk vGonk = new GonkulatorModel.Gonk();
        vGonk.objectList.add(vAccount);
        vGonk.gonkulatorRecord=vGonkulator;
        vGonk.className='Demo_GonkImpl';
        Account badAccount = new Account();
        vGonk.objectsToInsert.add(badAccount);
        
        try {
            Demo_GonkImpl vDemo_GonkImpl = new Demo_GonkImpl();
            vDemo_GonkImpl.init(vGonk);
            vDemo_GonkImpl.getData();
            vDemo_GonkImpl.validate();
            vDemo_GonkImpl.execute();
            vGonk.objectsToInsert=new List<sObject>();
            vGonk.objectsToInsert.add(badAccount);
            vDemo_GonkImpl.dml();
        } catch (Exception e) {
            system.debug(e.getMessage());
        }
        
   
    }

}