global without sharing class GonkulatorModel {
    global static String EXECUTION_COUNT='Execution_Count';
    global static Boolean GONK_TRIGGER_SWITCH=true;
    /**********************************************************
     * Inner Class for the Gonkulator
     ***********************************************************/
    global class GonkException extends Exception {
        // Method to return only the custom message without stack trace
        global String getGonkMessage() {
            //System.debug(this.getMessage());
            return this.getMessage();
        }
    }

    global enum TriggerOperation{ 
        BEFORE_INSERT,
        BEFORE_UPDATE,
        BEFORE_DELETE,
        AFTER_INSERT,
        AFTER_UPDATE,
        AFTER_DELETE,
        AFTER_UNDELETE
    }
    global class Gonk{
        global Boolean isBefore(){
            return triggerOperation.name().contains('BEFORE');
        }
        global Boolean isAfter(){
            return triggerOperation.name().contains('AFTER');
        }
        global Boolean isInsert(){
            return triggerOperation.name().contains('INSERT');
        }
        global Boolean isUpdate(){
            return triggerOperation.name().contains('UPDATE');
        }
        global Boolean isDelete(){
            return triggerOperation.name().contains('DELETE');
        }
        global void disableObjectTrigger(String objectAPIName){
            gonkulator.GonkFactory.TURN_GONK_TRIGGER_OFF_FOR_OBJECTTYPE.add(objectAPIName);
        }
        global void enableObjectTrigger(String objectAPIName){
            gonkulator.GonkFactory.TURN_GONK_TRIGGER_OFF_FOR_OBJECTTYPE.remove(objectAPIName);
        }
        global void disableGonkClass(String className){
            gonkulator.GonkFactory.TURN_GONK_TRIGGER_OFF.add(className);
        }
        global void enableGonkClass(String className){
            gonkulator.GonkFactory.TURN_GONK_TRIGGER_OFF.remove(className);
        }

        
        global String status='';
        global Map<sObjectType, Query> queryMap = new Map<sObjectType, Query>();
        global TriggerOperation triggerOperation;
        global String objectAPIName;
        global List<SObject> objectList = new List<sObject>();
        global Map<Id,SObject> OldObjectMap = new Map<Id,SObject>();
        global Map<Id,SObject> NewObjectMap = new Map<Id,SObject>();
        global Map<String, sObject> objectMap;
        global String className;
        global Gonkulator__c gonkulatorRecord= new Gonkulator__c();
        global List<Gonkulator_Log__c> gonkulatorLogList = new List<Gonkulator_Log__c>();
        global Map<String, String> executionStats = new Map<String,String>();
        global Map<String, Object> parameters = new Map<String, Object>();
        global List<String> errorMessages= new List<String>();
        global List<SObject> objectsToUpdate = new List<SObject>();
        global List<SObject> objectsToInsert = new List<sObject>();
        global String getErrorMessages(){
            String vErrors='';
            for(String vError : errorMessages){
                vErrors+=vError+'\n';
            }
            return vErrors;
        }
        global Boolean isInError(){
            if ('error'!= status.toLowerCase()) {
                return true;
            }
            if(errorMessages!=null && !errorMessages.isEmpty()){
                return true;
            }
            return false;
            
        }
        global void parseJSON(String vJson){
            if(vJson!=null){
                try{
                    // Deserialize the JSON string into an untyped object
                    Map<String, Object> jsonObj = (Map<String, Object>) JSON.deserializeUntyped(vJson);
                    Map<String, Object> parsedMap = new Map<String, Object>();
                    // Iterate over the JSON object and add key-value pairs to the parsed map
                        for (String key : jsonObj.keySet()) {
                            parameters.put(key, jsonObj.get(key));
                        }
                    //parameters = (Map<String, Object>)JSON.deserializeUntyped(vJson);
                } catch (Exception e) {
                    System.debug('parseJson error: '+e.getMessage());
                }
            }
        }
        global Map<String, sObject> getObjectMap(String sortField){
            Map<String, sObject> newMap = new Map<String, sObject>();
            if (objectList != null) {
                for(sObject vObj : objectList){
                    if(vObj.get(sortField)!=null){
                        newMap.put((String)vObj.get(sortField), vObj);
                    }

                }

            }
            return newMap;
        }
        global Map<String, sObject> getObjectMap(){
            if (objectMap==null && objectList != null) {
                objectMap= new Map<String, sObject>();
                for(sObject vObj : objectList){
                    if(vObj.Id!=null){
                        objectMap.put(vObj.Id, vObj);
                    }

                }
            }
            return objectMap;
        }
    }
    global class Query{
        global Set<String> children=new Set<String>();
        global Set<String> parents=new Set<String>();
        global sObjectType objectType;
        global String criteriaField;
        global Set<String> criteriaValue;
        global List<sObject> queryResults=new List<sObject>();
        global Set<String> getCriteriaQuoted(){
            Set<String> values = new Set<String>();
            if(criteriaValue!=null && !criteriaValue.isEmpty()){  
                for(String str : criteriaValue){
                    values.add('\''+str+'\'');
                }
            }
            return values;
        }
    }

    global class GonkComparator implements Comparator<GonkulatorModel.Gonk>{
        global Integer compare(GonkulatorModel.Gonk o1, GonkulatorModel.Gonk o2) {
            Integer returnValue = 0;

            if(o1 == null && o2 == null) {
                returnValue = 0;
            } else if(o1 == null) {
                // nulls-first implementation
                returnValue = -1; 
            } else if(o2 == null) {
                // nulls-first implementation
                returnValue = 1;
            } else if ((o1.gonkulatorRecord.Sort_Order__c == null) && (o2.gonkulatorRecord.Sort_Order__c == null)) {
                // both have null Amounts
                returnValue = 0;
            } else if (o1.gonkulatorRecord.Sort_Order__c == null){
                // nulls-first implementation
                returnValue = -1;
            } else if (o2.gonkulatorRecord.Sort_Order__c == null){
                // nulls-first implementation
                returnValue = 1;
            } else if (o1.gonkulatorRecord.Sort_Order__c < o2.gonkulatorRecord.Sort_Order__c) {
                // Set return value to a negative value.
                returnValue = -1;
            } else if (o1.gonkulatorRecord.Sort_Order__c > o2.gonkulatorRecord.Sort_Order__c) {
                // Set return value to a positive value.
                returnValue = 1;
            }


            return returnValue;
        }

    }
}