@isTest(SeeAllData=false)
public class Gonkulator_Test {
    @TestSetup
    static void createTestData(){ 
        Account vAccount = (Account)GonkulatorCore.populateObjectData(Account.getSObjectType());
        vAccount.Name='TestClassAccount';
        Insert vAccount;
        
        try{
			Account pAccount = (Account)GonkulatorCore.populateObjectData(Account.getSObjectType(), 'PersonAccount');
            pAccount.Name='PersonAccount';
            Insert pAccount;            
        }catch(Exception e){
            system.debug(e.getMessage());
        }
        
        
        Contact vContact =(Contact)GonkulatorCore.populateObjectData(Schema.SObjectType.Contact.getSObjectType());
        vContact.AccountId=vAccount.Id;
        insert vContact;

        Lead vLead = (Lead)GonkulatorCore.populateObjectData(Schema.SObjectType.Lead.getSObjectType());
        insert vLead;
        
        Opportunity vOpportunity = (Opportunity)GonkulatorCore.populateObjectData(Schema.SObjectType.Opportunity.getSObjectType());
        vOpportunity.AccountId=vAccount.Id;
        Insert vOpportunity;
        
        Order vOrder = (Order)GonkulatorCore.populateObjectData(Schema.SObjectType.Order.getSObjectType());
        vOrder.Pricebook2Id=Test.getStandardPricebookId();
        vOrder.OpportunityId=vOpportunity.Id;
        vOrder.AccountId=vAccount.Id;
        insert vOrder;
        
        Product2 vProduct2 = (Product2)GonkulatorCore.populateObjectData(Schema.SObjectType.Product2.getSObjectType());
        insert vProduct2;
        
        PricebookEntry vPricebookEntry = new PricebookEntry();
        vPricebookEntry.Product2Id=vProduct2.Id;
        vPricebookEntry.Pricebook2Id=vOrder.Pricebook2Id;
        vPricebookEntry.UnitPrice=100.00;
        insert vPricebookEntry;
        
        OrderItem vOrderItem = (OrderItem)GonkulatorCore.populateObjectData(Schema.SObjectType.OrderItem.getSObjectType());
        vOrderItem.Description ='TEST';
        vOrderItem.OrderId=vOrder.Id;
        vOrderItem.PricebookEntryId=vPricebookEntry.Id;
        insert vOrderItem;
        
        //Create a Gonkulator Entry
        Gonkulator__c vGonkulator = new Gonkulator__c();
        vGonkulator.Execute_On__c='AFTER_UPDATE';
        vGonkulator.Execute_Class__c='Gonkulator_Test.test_gonkImpl';
        vGonkulator.Object_API_Name__c='Account';
        vGonkulator.Active__c=true;
        vGonkulator.Reflection__c=true;
        vGonkulator.Debug__c=true;
        vGonkulator.Throw_Error__c=false;
        vGonkulator.Sort_Order__c=100;
        vGonkulator.TestClassFlags__c='Standard';
        insert vGonkulator;

        //Create a Gonkulator Entry
        vGonkulator = new Gonkulator__c();
        vGonkulator.Execute_On__c='AFTER_UPDATE';
        vGonkulator.Execute_Class__c='Demo_GonkImpl';
        vGonkulator.Object_API_Name__c='Account';
        vGonkulator.Active__c=true;
        vGonkulator.Reflection__c=true;
        vGonkulator.Debug__c=true;
        vGonkulator.Throw_Error__c=false;
        vGonkulator.Depends_On_Success_of__c='1001';
        vGonkulator.Sort_Order__c=100;
        vGonkulator.TestClassFlags__c='Standard';
        vGonkulator.Parameters__c='{\"field\":\"nameoffield\"}';
        // vGonkulator.Depends_On_Success_of__c='00001';
        insert vGonkulator;

    }
    
    @isTest
    static void gonkQuery(){ 
        Account vAccount = [Select Id, AccountNumber from Account where Name = 'TestClassAccount' Limit 1];
        
        
        //Query for the QuoteRequest
        GonkulatorModel.Query vQuery = new GonkulatorModel.Query();
        vQuery.children.add('Opportunities');
        vQuery.children.add('Contacts');
        vQuery.criteriaField='Id';
        
        GonkulatorModel.Gonk vGonk = new GonkulatorModel.Gonk();
        vGonk.objectList.add(vAccount);
        vGonk.queryMap.put(Account.getSObjectType(), vQuery);
        vGonk.parseJson('{\"Name\":\"Test Value\"');
        vGonk.getObjectMap('Id');
        
        GonkulatorCore.gonkQuery(vGonk);
        
        
        OrderItem vOrderItem = [Select Id from OrderItem where Description ='TEST' Limit 1];
        
        //Query for the QuoteRequest
        vQuery = new GonkulatorModel.Query();
        vQuery.parents.add('OrderItem.Order');
        vQuery.parents.add('OrderItem.Order.Opportunity');
        vQuery.parents.add('OrderItem.Order.Opportunity.Account');
        vQuery.parents.add('OrderItem.Order.Opportunity.Account.LastModifiedBy');
        vQuery.criteriaField='Id';
        
        vGonk = new GonkulatorModel.Gonk();
        vGonk.objectList.add(vOrderItem);
        vGonk.queryMap.put(OrderItem.getSObjectType(), vQuery);
        
        GonkulatorCore.gonkQuery(vGonk);
        
    }
    @isTest
    static void gonkFactory(){ 
        Test.startTest();
        Account vAccount = [Select Id, AccountNumber, NumberOfEmployees from Account where Name = 'TestClassAccount' Limit 1];
        
        Gonkulator__c iGonkulator = [Select Id, TestClassFlags__c, Execute_Class__c, Object_API_Name__c, Name, Parameters__c, Execute_On__c FROM Gonkulator__c where Execute_Class__c='Demo_GonkImpl']; 
        Gonkulator__c iGonkulator2 = [Select Id, TestClassFlags__c, Execute_Class__c, Object_API_Name__c, Name, Parameters__c, Execute_On__c FROM Gonkulator__c where Execute_Class__c='Gonkulator_Test.test_gonkImpl']; 
        
        System.debug(iGonkulator.Name);
        System.debug(iGonkulator2.Name);
        
        iGonkulator2.Last_Executed_Status__c='Success';
        update iGonkulator2;
        
        iGonkulator.Depends_On_Success_of__c=iGonkulator2.Name;
        update iGonkulator;
        
        GonkulatorModel.Gonk vGonk = new GonkulatorModel.Gonk();
        vGonk.objectList.add(vAccount);
        vGonk.gonkulatorRecord=iGonkulator;
        vGonk.className='Demo_GonkImpl';

        Map<Id,sObject> vTriggerMap = new Map<Id,sObject>();
        vTriggerMap.put(vAccount.Id, (sObject)vAccount);
        GonkFactory.gonkulate(vTriggerMap, vTriggerMap, 'AFTER_UPDATE');
        GonkFactory.gonkulate(vTriggerMap, vTriggerMap);
        GonkFactory.gonkulate(vTriggerMap);
        
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
        
        Test.stopTest(); 
    }
    @isTest
    static void gonkFactoryFailedDependency(){ 
        Test.startTest();
        Account vAccount = [Select Id, AccountNumber, NumberOfEmployees from Account where Name = 'TestClassAccount' Limit 1];
        
        Gonkulator__c iGonkulator = [Select Id, TestClassFlags__c, Execute_Class__c, Object_API_Name__c, Name, Parameters__c, Execute_On__c FROM Gonkulator__c where Execute_Class__c='Demo_GonkImpl']; 
        Gonkulator__c iGonkulator2 = [Select Id, TestClassFlags__c, Execute_Class__c, Object_API_Name__c, Name, Parameters__c, Execute_On__c FROM Gonkulator__c where Execute_Class__c='Gonkulator_Test.test_gonkImpl']; 
        
        System.debug(iGonkulator.Name);
        System.debug(iGonkulator2.Name);
        
        iGonkulator2.Last_Executed_Status__c='Error';
        update iGonkulator2;
        
        iGonkulator.Depends_On_Success_of__c=iGonkulator2.Name;
        update iGonkulator;
        
        GonkulatorModel.Gonk vGonk = new GonkulatorModel.Gonk();
        vGonk.objectList.add(vAccount);
        vGonk.gonkulatorRecord=iGonkulator;
        vGonk.className='Demo_GonkImpl';

        Map<Id,sObject> vTriggerMap = new Map<Id,sObject>();
        vTriggerMap.put(vAccount.Id, (sObject)vAccount);
        GonkFactory.gonkulate(vTriggerMap, vTriggerMap, 'AFTER_UPDATE');
        GonkFactory.gonkulate(vTriggerMap, vTriggerMap);
        GonkFactory.gonkulate(vTriggerMap);

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
        
        Test.stopTest(); 
    }
    @isTest
    static void gonkGetDataExceptions(){ 
        Gonkulator__c vGonkulator = [Select Id, TestClassFlags__c, Execute_Class__c, Object_API_Name__c, Name, Parameters__c, Execute_On__c FROM Gonkulator__c where Execute_Class__c='Gonkulator_Test.test_gonkImpl'];
        vGonkulator.TestClassFlags__c='getData Exception';
        update vGonkulator;
 
        GonkulatorModel.Gonk vGonk = new GonkulatorModel.Gonk();
        vGonk.gonkulatorRecord=vGonkulator;
        vGonk.className='Gonkulator_Test.test_gonkImpl';
        
        
        try {
            Gonkiface vGonkiface = (Gonkiface) Type.forName('Gonkulator_Test.test_gonkImpl').newInstance();
            GonkFactory.execute(vGonkiface, vGonk);             
        } catch (Exception e) {
            vGonk.getErrorMessages();
            system.debug(e.getMessage());
        }
   
    }
    @isTest
    static void gonkDMLExceptions(){ 
        Gonkulator__c vGonkulator = [Select Id, TestClassFlags__c, Execute_Class__c, Object_API_Name__c, Name, Parameters__c, Execute_On__c FROM Gonkulator__c where Execute_Class__c='Gonkulator_Test.test_gonkImpl'];
        vGonkulator.TestClassFlags__c='DML Exception';
        update vGonkulator;
 
        GonkulatorModel.Gonk vGonk = new GonkulatorModel.Gonk();
        vGonk.gonkulatorRecord=vGonkulator;
        vGonk.className='Gonkulator_Test.test_gonkImpl';
        
        try {
            Gonkiface vGonkiface = (Gonkiface) Type.forName('Gonkulator_Test.test_gonkImpl').newInstance();
            GonkFactory.execute(vGonkiface, vGonk);             
        } catch (Exception e) {
            system.debug(e.getMessage());
        }
   
    }
    @isTest
    static void gonkValidateExceptions(){ 
        Gonkulator__c vGonkulator = [Select Id, TestClassFlags__c, Execute_Class__c, Object_API_Name__c, Name, Parameters__c, Execute_On__c  FROM Gonkulator__c where Execute_Class__c='Gonkulator_Test.test_gonkImpl'];
        vGonkulator.TestClassFlags__c='Validate Exception';
        update vGonkulator;
 
        GonkulatorModel.Gonk vGonk = new GonkulatorModel.Gonk();
        vGonk.gonkulatorRecord=vGonkulator;
        vGonk.className='DeepClone_Test.test_gonkImpl';
        
        try {
            Gonkiface vGonkiface = (Gonkiface) Type.forName('Gonkulator_Test.test_gonkImpl').newInstance();
            GonkFactory.execute(vGonkiface, vGonk);             
        } catch (Exception e) {
            system.debug(e.getMessage());
        }
   
    }
    @isTest
    static void gonkExecuteExceptions(){ 
        Gonkulator__c vGonkulator = [Select Id, TestClassFlags__c, Execute_Class__c, Object_API_Name__c, Name, Parameters__c, Execute_On__c FROM Gonkulator__c where Execute_Class__c='Gonkulator_Test.test_gonkImpl'];
        vGonkulator.TestClassFlags__c='Execute Exception';
        update vGonkulator;
 
        GonkulatorModel.Gonk vGonk = new GonkulatorModel.Gonk();
        vGonk.gonkulatorRecord=vGonkulator;
        vGonk.className='DeepClone_Test.test_gonkImpl';
        
        try {
            Gonkiface vGonkiface = (Gonkiface) Type.forName('Gonkulator_Test.test_gonkImpl').newInstance();
            GonkFactory.execute(vGonkiface, vGonk);             
        } catch (Exception e) {
            system.debug(e.getMessage());
        }
   
    }
    @isTest
    static void gonkExecute(){ 
       	Gonkulator__c vGonkulator = [Select Id, TestClassFlags__c, Execute_Class__c, Object_API_Name__c, Name, Parameters__c, Execute_On__c  FROM Gonkulator__c where Execute_Class__c='Gonkulator_Test.test_gonkImpl'];
        
        GonkulatorModel.Gonk vGonk = new GonkulatorModel.Gonk();
        vGonk.gonkulatorRecord=vGonkulator;
        vGonk.className='DeepClone_Test.test_gonkImpl';
        
        try {
            Gonkiface vGonkiface = (Gonkiface) Type.forName('Gonkulator_Test.test_gonkImpl').newInstance();
            GonkFactory.execute(vGonkiface, vGonk); 
        } catch (Exception e) {
            system.debug(e.getMessage());
        }
   
    }
    
   
    public class test_gonkImpl implements Gonkiface{
        public GonkulatorModel.Gonk vGonk;
        public void init(GonkulatorModel.Gonk iGonk){
            vGonk=iGonk;
        }
        public void getData(){
            if(vGonk.gonkulatorRecord.TestClassFlags__c=='getData Exception' ){
                throw new GonkulatorModel.GonkException(vGonk.className+' getData Test Class error.');
            }
        }
        public void validate(){
            if(vGonk.gonkulatorRecord.TestClassFlags__c=='Validate Exception' ){
                throw new GonkulatorModel.GonkException(vGonk.className+' Validate Test Class error.');
            }
        }
        public void execute(){
            vGonk.isBefore();
            vGonk.isAfter();
            vGonk.isInsert();
            vGonk.isUpdate();
            vGonk.isDelete();
            vGonk.disableObjectTrigger('Account');
            vGonk.enableObjectTrigger('Account');
            vGonk.disableGonkClass('Gonkulator_Test.test_gonkImpl');
            vGonk.enableGonkClass('Gonkulator_Test.test_gonkImpl');
            if(vGonk.gonkulatorRecord.TestClassFlags__c=='Execute Exception' ){
                throw new GonkulatorModel.GonkException(vGonk.className+' Execute Test Class error.');
            }
            
        }
        public void dml(){
            if(vGonk.gonkulatorRecord.TestClassFlags__c=='DML Exception' ){
                throw new GonkulatorModel.GonkException(vGonk.className+' DML Test Class error.');
            }
        }
    }
    
}