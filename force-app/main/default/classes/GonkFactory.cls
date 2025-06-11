global without sharing class GonkFactory {
    global static List<Gonkulator__c> vGonkList;
    global static Set<String> TURN_GONK_TRIGGER_OFF_FOR_OBJECTTYPE=new Set<String>();
    global static Set<String> TURN_GONK_TRIGGER_OFF=new Set<String>();
    global static Integer NUMBER_OF_BEFORE=0;
    global static Integer NUMBER_OF_AFTER=0;

    global static Set<String> executedInterfaces = new Set<String>();
    //This is a map of GonkulatorModel.Gonk object where the key is the Class Name
    //i.e. one Object Type with all the Gonkulator Triggers
    global static Map<String, GonkulatorModel.Gonk> vExecutionMap;
    //a Meta Map that is a map of the vExecutionMap where the key is the Object Type
    /*--Account
    *       --Gonk1_Impl,GonkulatorModel.Gonk1
    *       --Gonk2_Impl,GonkulatorModel.Gonk1
    *--Contact
    *       --Gonk3_Impl,GonkulatorModel.Gonk3
    *       --Gonk4_Impl,GonkulatorModel.Gonk4
    */
    global static Map<String,Map<String, GonkulatorModel.Gonk>> vExecutionMapAllObjectTypes;

    /**********************************************************
     * Primary method to determin what classes need to be executed and in what order
     ***********************************************************/
    global static void gonkulate(Map<Id,SObject> vNewObjectMap){
        gonkulate(vNewObjectMap.values(), vNewObjectMap, null, null, null);
    }
    global static void gonkulate(Map<Id,SObject> vNewObjectMap, Map<Id,SObject> vOldObjectMap){
        gonkulate(vNewObjectMap.values(), vNewObjectMap, vOldObjectMap, null, null);
    }
    global static void gonkulate(Map<Id,SObject> vNewObjectMap, Map<Id,SObject> vOldObjectMap, String vTriggerOperation){
        gonkulate(vNewObjectMap.values(), vNewObjectMap, vOldObjectMap, vTriggerOperation, null);
    }
    global static void gonkulate(Map<Id,SObject> vNewObjectMap, Map<Id,SObject> vOldObjectMap, String vTriggerOperation, String objectAPIName){
        if(vNewObjectMap==null){
            gonkulate(null, vNewObjectMap, vOldObjectMap, vTriggerOperation, objectAPIName);
        } else {
            gonkulate(vNewObjectMap.values(), vNewObjectMap, vOldObjectMap, vTriggerOperation, objectAPIName);
        }
        
    }
    global static void gonkulate(List<sObject> vNewObjectList, Map<Id,SObject> vNewObjectMap, Map<Id,SObject> vOldObjectMap, String vTriggerOperation, String objectAPIName){
        if(vTriggerOperation!=null){
            if(vTriggerOperation.contains('BEFORE')){
                NUMBER_OF_BEFORE++;
            }
            if(vTriggerOperation.contains('AFTER')){
                NUMBER_OF_AFTER++;
            }
        }
        
        if(objectAPIName==null && vNewObjectList!=null){
            //backwards compatiblity if the objectAPI Name is not passed it get from the objectlist
            SObject vSObj=vNewObjectList.get(0);
            objectAPIName =vSObj.getSObjectType().getDescribe().getName();
        }
        System.debug('Processing objectAPIName: '+objectAPIName +' -> '+vTriggerOperation);

        //what has changed?-DO NO REMOVE
        // SObjectType sObjectType = Schema.getGlobalDescribe().get(objectAPIName);
        // Map<String, Schema.SObjectField> fieldsMap = sObjectType.getDescribe().fields.getMap();
        // for(sObject newObj : Trigger.New){
        //     sObject oldObj = Trigger.OldMap.get(newObj.Id);
        //     for (String key : fieldsMap.keySet()) {
        //         Schema.DescribeFieldResult result = fieldsMap.get(key).getDescribe();
        //         if (oldObj.get(result.getName()) != newObj.get(result.getName())) {
        //             System.debug('Change: '+key+'->'+oldObj.get(result.getName())+'->'+newObj.get(result.getName()));
        //         }
        //     }
        // }
        
        if(vExecutionMapAllObjectTypes==null){//prevents call the Gonk SQL multiple times
            
            vExecutionMap = new Map<String,GonkulatorModel.Gonk>();
            vExecutionMapAllObjectTypes = new Map<String,Map<String, GonkulatorModel.Gonk>>();

            //Get List of Class to Execute
            if(vGonkList==null){
                vGonkList=[SELECT CreatedById, CreatedDate, Active__c, CPU_Limit__c, 
                            Debug__c, Depends_On_Success_of__c, Execute_Class__c, 
                            Execute_On__c, Execution_Count__c, 
                            Execution_Limits__c, Function_Description__c, 
                            Last_Executed_Status__c, 
                            Last_Executed_Time__c, Object_API_Name__c, 
                            Object_List__c, Parameters__c, 
                            Publish_Events__c, Reflection__c, 
                            SOQL_Queries__c, Sort_Order__c, 
                            TestClassFlags__c, Throw_Error__c, Id, 
                            LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate, 
                            LastViewedDate, Name, OwnerId, SystemModstamp 
                FROM Gonkulator__c WHERE Active__c = true Order by Sort_Order__c];
                //Object_API_Name__c =: objectAPINames AND
            }

            
            for(Gonkulator__c vFace: vGonkList){ 
                system.debug('vFace '+vFace.Name);

                
                if(!vExecutionMapAllObjectTypes.containsKey(vFace.Object_API_Name__c)){
                    vExecutionMapAllObjectTypes.put(vFace.Object_API_Name__c, new Map<String, GonkulatorModel.Gonk>());
                }
                vExecutionMap=vExecutionMapAllObjectTypes.get(vFace.Object_API_Name__c);
                String vKey = vFace.Execute_Class__c+'['+vFace.Name+']';

                vExecutionMap.put(vKey, new GonkulatorModel.Gonk());
                // if(!vExecutionMap.containsKey(vFace.Execute_Class__c)){
                    
                // }
                
                GonkulatorModel.Gonk vGonk =vExecutionMap.get(vKey);
                vGonk.className=vFace.Execute_Class__c;
                vGonk.gonkulatorRecord=vFace;
                vGonk.parseJSON(vFace.Parameters__c);
                vGonk.gonkulatorRecord.Last_Executed_Status__c=Null;    
                            
            }

        }
        
            //List to update the Reflection Data
        List<Gonkulator__c> updateGonkList = new List<Gonkulator__c>();
        //List to insert Debug logs
        List<Gonkulator_Log__c> insertLogList = new List<Gonkulator_Log__c>();

        //vExecutionMapAllObjectTypes is Holding all Gonkulators for All Object
        //so that if one object where to update another object in the same thread
        //we don't have go back to the DB get the all the Gonkulator Objects

        //Make a list so we can run the Gonks in Sort Order
        List<GonkulatorModel.Gonk> vGonkExecutionList = new List<GonkulatorModel.Gonk>();
        for(String vGonkObjeAPIName : vExecutionMapAllObjectTypes.keySet()){
            //Run just the Gonkulators for the Current Object Type
            if(vGonkObjeAPIName==objectAPIName){
                Map<String, GonkulatorModel.Gonk> vExecutionMap=vExecutionMapAllObjectTypes.get(vGonkObjeAPIName);
                //populate the ObjectList from the passed in trigger
                //Because we are caching the map subsequent Gonkulators will not get the ObjectList populated
                for(GonkulatorModel.Gonk exeGonk : vExecutionMap.values()){
                    if(vNewObjectList != null){
                        if(!exeGonk.objectList.isEmpty()){
                            //Empty the list because we are running the same Gonkulator on the same Trigger
                            exeGonk.objectList.clear();
                        }
                        exeGonk.objectList.addAll(vNewObjectList);
                    }
                    if(vNewObjectMap!=null){
                        exeGonk.NewObjectMap=vNewObjectMap;
                    }
                    if(vOldObjectMap!=null){
                        exeGonk.OldObjectMap=vOldObjectMap;
                    }
                    if(vTriggerOperation!=null){
                        exeGonk.triggerOperation=GonkulatorModel.TriggerOperation.valueOf(vTriggerOperation);
                    }
                    if(objectAPIName!=null){
                        exeGonk.objectAPIName=objectAPIName;
                    }
                    vGonkExecutionList.add(exeGonk);
                }
            }
        }
        //sort the list
        vGonkExecutionList.sort(new GonkulatorModel.GonkComparator());

        
        for(GonkulatorModel.Gonk vGonk: vGonkExecutionList ){
            try {
                System.debug('executedInterfaces: '+executedInterfaces);
                System.debug('vGonk.objectList: '+vGonk.objectList);
                System.debug('vGonk.gonkulatorRecord.Execute_On__c: '+vGonk.gonkulatorRecord.Execute_On__c);
                System.debug('Trigger.operationType.name(): '+vGonk.triggerOperation);
                System.debug('vGonk.className: '+vGonk.className);
                System.debug('vGonk.gonkulatorRecord.Name: '+vGonk.gonkulatorRecord.Name);
                
            } catch (Exception e) {
                System.debug('e'+e.getMessage());
            }
            String operation=vGonk.triggerOperation.name();
            
            
            if(vGonk.gonkulatorRecord.Execute_On__c.contains(operation) && !executedInterfaces.contains(vGonk.className+'-'+vGonk.gonkulatorRecord.Name)){
                //TURN_GONK_TRIGGER_OFF_FOR_OBJECTTYPE Any ObjectType found in  set will not be run
                if(!TURN_GONK_TRIGGER_OFF_FOR_OBJECTTYPE.contains(objectAPIName) && !TURN_GONK_TRIGGER_OFF.contains(vGonk.className)){
                    vGonk.gonkulatorRecord.Last_Executed_Time__c=Datetime.now();
                    List<String> objectIdList = new List<String>();
                    String objectListAsString;
                    if(vNewObjectMap != null && vNewObjectMap.size()>0){
                        for(Id vId : vNewObjectMap.keySet()){
                            objectIdList.add((String)vId);
                        }
                        objectListAsString =  String.join(objectIdList,',');
                        if(objectListAsString.length()>255){
                            vGonk.gonkulatorRecord.Object_List__c=objectListAsString.substring(0,254);
                        } else {
                            vGonk.gonkulatorRecord.Object_List__c=objectListAsString;
                        }
                    }
                    try {
                        //Check for depentency of previous Gonks
                        if(vGonk.gonkulatorRecord.Depends_On_Success_of__c !=Null){
                            List<String> vDependsOnSuccessList = vGonk.gonkulatorRecord.Depends_On_Success_of__c.split(';');
                            Integer vNumberOfDependencies=vDependsOnSuccessList.size();
                            Integer vNumberOfSuccess=0;
                            for(String vDependsOnSuccess : vDependsOnSuccessList){
                                for(String vObjectKey : GonkFactory.vExecutionMapAllObjectTypes.keySet()){
                                    for(String vKey : GonkFactory.vExecutionMapAllObjectTypes.get(vObjectKey).keySet()){
                                        GonkulatorModel.Gonk iGonk = GonkFactory.vExecutionMapAllObjectTypes.get(vObjectKey).get(vKey);
                                        if(iGonk.gonkulatorRecord.Name==vDependsOnSuccess){
                                            if(iGonk.gonkulatorRecord.Last_Executed_Status__c=='Success'){
                                                vNumberOfSuccess++;     
                                            } else {
                                                //the dependent gonk was not successfull create a log item
                                                vGonk.status='Error';
                                                Gonkulator_Log__c vLog = new Gonkulator_Log__c();
                                                vLog.Gonkulator__c=vGonk.gonkulatorRecord.Id;
                                                vLog.Messages__c='Trigger Operation '+operation+' Failed because Dependent Gonk: '+vDependsOnSuccess +' Did not execute successfully';
                                                vGonk.gonkulatorLogList.add(vLog);
                                            }
                                        } 
                                    } 
                                }

                            }
                            //All dependencies have be successfully completed
                            if(vNumberOfSuccess==vNumberOfDependencies){
                                vGonk.gonkulatorRecord.Last_Executed_Status__c='Success';
                                createAndExecuteHandler(vGonk);
                            }
                        //No Dependencies
                        } else {
                            vGonk.gonkulatorRecord.Last_Executed_Status__c='Success';
                            createAndExecuteHandler(vGonk);
                        }
                    } catch (GonkulatorModel.GonkException ge) {
                        vGonk.gonkulatorRecord.Last_Executed_Status__c='Error';
                        if(vGonk.gonkulatorRecord.Throw_Error__c){
                            throw new GonkulatorModel.GonkException(ge.getGonkMessage());
                        }
                        
                    }
                    if (vGonk.gonkulatorRecord.Reflection__c) {
                        updateGonkList.add(vGonk.gonkulatorRecord);
                    }
                    
                    if (vGonk.gonkulatorRecord.Debug__c) {
                        insertLogList.addAll(vGonk.gonkulatorLogList); 
                    } 

                }
                
            }
        }
        if (!updateGonkList.isEmpty()) {
            System.enqueueJob(new UpdateGonkulatorsQueueable(updateGonkList));
            //updateGonkList=new List<Gonkulator__c>();//prevent queing the list a second time
        }
        
        if (!insertLogList.isEmpty()) {
            System.enqueueJob(new UpdateGonkulatorsQueueable(insertLogList));
            //insertLogList = new List<Gonkulator_Log__c>();//prevent queing the same list again
        } 
    }

     /**********************************************************
     * Make a handler interface and execute the frame work
     ***********************************************************/
    global static void createAndExecuteHandler(GonkulatorModel.Gonk vGonk)
    {
        //
        Gonkiface handler;
        // Get a handler appropriate to the object being processed
        try{
            System.debug('Get Handler for: '+vGonk.className);
            Type t = Type.forName(vGonk.className);
            
            handler = getHandler(t);
        } catch (Exception e){
            throw new GonkulatorModel.GonkException('No Gonkulator Handler found named: ' + e.getMessage());
        }
         
        // Execute the handler to fulfil the trigger
        execute(handler, vGonk);
    }
    

     /**********************************************************
     * Executes the Interface methods
     ***********************************************************/
    global static void execute(Gonkiface handler, GonkulatorModel.Gonk vGonk)
    {
 
        //prevent multiple invocations of the same class during the same thread
        
        handler.init(vGonk);
        try {
            if(vGonk.isInError()){
                handler.getData();
            }
        } catch (GonkulatorModel.GonkException e) {
            vGonk.status='Error';
            Gonkulator_Log__c vLog = new Gonkulator_Log__c();
            vLog.Gonkulator__c=vGonk.gonkulatorRecord.Id;
            vLog.Messages__c=e.getMessage()+'\n'+e.getStackTraceString();
            vGonk.gonkulatorLogList.add(vLog);
            throw new GonkulatorModel.GonkException('*** Error From Class: '+vGonk.className.toUpperCase()+' *** In Method getData() *** In Operation: '+vGonk.triggerOperation+' *** Error Message: '+e.getGonkMessage().toUpperCase()+' *** ');
        }
        try {
            if(vGonk.isInError()){
                handler.validate();
            }
        } catch (GonkulatorModel.GonkException e) {
            vGonk.status='Error';
            Gonkulator_Log__c vLog = new Gonkulator_Log__c();
            vLog.Gonkulator__c=vGonk.gonkulatorRecord.Id;
            vLog.Messages__c=e.getMessage()+'\n'+e.getStackTraceString();
            vGonk.gonkulatorLogList.add(vLog);
            throw new GonkulatorModel.GonkException('*** Error From Class: '+vGonk.className.toUpperCase()+' *** In Method validate() *** In Operation: '+vGonk.triggerOperation+' *** Error Message: '+e.getGonkMessage().toUpperCase()+' *** ');
        }
        try {
            if(vGonk.isInError()){
                handler.execute();
            }
        } catch (GonkulatorModel.GonkException e) {
            vGonk.status='Error';
            Gonkulator_Log__c vLog = new Gonkulator_Log__c();
            vLog.Gonkulator__c=vGonk.gonkulatorRecord.Id;
            vLog.Messages__c=e.getMessage()+'\n'+e.getStackTraceString();
            vGonk.gonkulatorLogList.add(vLog);
            throw new GonkulatorModel.GonkException('*** Error From Class: '+vGonk.className.toUpperCase()+' *** In Method execute() *** In Operation: '+vGonk.triggerOperation+' *** Error Message: '+e.getGonkMessage().toUpperCase()+' *** ');
        }
        try {
            if(vGonk.parameters != null){
                if(vGonk.parameters.get('TURN_GONK_TRIGGER_OFF_FOR_OBJECTTYPE')!=Null){
                    TURN_GONK_TRIGGER_OFF_FOR_OBJECTTYPE.add((String)vGonk.parameters.get('TURN_GONK_TRIGGER_OFF_FOR_OBJECTTYPE'));
                }
                if(vGonk.parameters.get('TURN_GONK_TRIGGER_OFF')!=Null){
                    TURN_GONK_TRIGGER_OFF.add((String)vGonk.parameters.get('TURN_GONK_TRIGGER_OFF'));
                }
            }
            if(vGonk.isInError()){
                handler.dml();
            }
            if(vGonk.parameters != null){
                if(vGonk.parameters.get('TURN_GONK_TRIGGER_OFF_FOR_OBJECTTYPE')!=Null){
                    TURN_GONK_TRIGGER_OFF_FOR_OBJECTTYPE.remove((String)vGonk.parameters.get('TURN_GONK_TRIGGER_OFF_FOR_OBJECTTYPE'));
                }
                if(vGonk.parameters.get('TURN_GONK_TRIGGER_OFF')!=Null){
                    TURN_GONK_TRIGGER_OFF.remove((String)vGonk.parameters.get('TURN_GONK_TRIGGER_OFF'));
                }
            }

        } catch (GonkulatorModel.GonkException e) {
            vGonk.status='Error';
            Gonkulator_Log__c vLog = new Gonkulator_Log__c();
            vLog.Gonkulator__c=vGonk.gonkulatorRecord.Id;
            vLog.Messages__c=e.getMessage()+'\n'+e.getStackTraceString();
            vGonk.gonkulatorLogList.add(vLog);
            throw new GonkulatorModel.GonkException('*** Error From Class: '+vGonk.className.toUpperCase()+' *** In Method dml() *** In Operation: '+vGonk.triggerOperation+' *** Error Message: '+e.getGonkMessage().toUpperCase()+' *** ');
        }
        //executedInterfaces.add(vGonk.className+'-'+vGonk.gonkulatorRecord.Name);// disableing this because sometimes you need to run the class before and after
        vGonk.gonkulatorRecord.Execution_Limits__c='Queries: '+Limits.getQueries()+
                                                    '\n Available Queries: '+Limits.getLimitQueries()+
                                                    '\n Platform Event Publishes: '+Limits.getLimitPublishImmediateDML()+
                                                    '\n Heap Size: '+Limits.getHeapSize()+
                                                    '\n Queueable Jobs: '+Limits.getQueueableJobs()+
                                                    '\n Number of BEFORE: '+NUMBER_OF_BEFORE+
                                                    '\n Number of AFTER: '+NUMBER_OF_AFTER;
        
        
        vGonk.gonkulatorRecord.SOQL_Queries__c=Limits.getQueries();
        vGonk.gonkulatorRecord.CPU_Limit__c=Limits.getCpuTime();
        vGonk.gonkulatorRecord.Publish_Events__c=Limits.getPublishImmediateDML();
        vGonk.gonkulatorRecord.Execution_Count__c=vGonk.gonkulatorRecord.Execution_Count__c+1;
        System.debug(Limits.getLimitQueries());
        //} 
    }

   
     /**********************************************************
     * Instantiate a handler classe
     ***********************************************************/ 
    global static Gonkiface getHandler(Type t)
    {
        // Instantiate the type
        Object o;
        try{
            System.debug('Type: '+t);
            o = t.newInstance();
        } catch (Exception e){
            throw new GonkulatorModel.GonkException('GonkFactory.getHandler(): '+e.getMessage());
        }
        
 
        return (Gonkiface)o;
    }
    
    
}