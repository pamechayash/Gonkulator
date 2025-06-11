public without sharing class Demo_GonkImpl implements Gonkiface{
    public static GonkulatorModel.Gonk vGonk;
    public static GonkulatorModel.Query vAccountQuery;
    public Boolean forceException =false;
/*
    * The GonkulatorModel.Gonk is an inner class that holds all the information to passed INTO the Gonkulator
    * i.e. The list of Task that are being updated. It also Holds the result of what happened during execution
    * of the Gonkulator so you pass error messages back to the User
    *
    * Your implementation of the Gonkiface should declare:
    * GonkulatorModel.Gonk vGonk = new GonkulatorModel.Gonk();
    * You init method should simple set the Class variable
    *
    * void init(GonkulatorModel.Gonk incomingGonk){
    *    vGonk=incomingGonk;
    * }
    */
    public void init(GonkulatorModel.Gonk incomingGonk){
        vGonk=incomingGonk;
    }
    /*
    * Use the getData() Method to do any SOQL Queries and store the result in Class
    * Vaiable for Use in Other methods
    */
    public void getData(){ 
        if (vAccountQuery==null) {
            vAccountQuery = new GonkulatorModel.Query();
            vGonk.queryMap.put(Schema.SObjectType.Account.getSObjectType(), vAccountQuery);
            vAccountQuery.parents.add('Account.Owner');
            vAccountQuery.parents.add('Account.Owner.Profile');
            vAccountQuery.children.add('Contacts');
            vAccountQuery.children.add('Opportunities');
            vAccountQuery.criteriaField='Id';
            vGonk.queryMap.put(Schema.SObjectType.Account.getSObjectType(),vAccountQuery);
            GonkulatorCore.gonkQuery(vGonk);    
        }
    }

    /*
    * The Validate() methods is used for you to check integreity of the data and throw erros back to the user 
    * if need
    */
    public void validate(){
        //check if the number of employees is 100
        //if(vGonk.isBefore() && !vGonk.isDelete()){
            for(Account vAccount : (List<Account>)vGonk.objectList){
                if(vAccount.NumberOfEmployees<100){
                    vAccount.NumberOfEmployees.addError('Employee count must be greater than 100');
                    //throw new GonkulatorModel.GonkException('Less than 100 Employee');
                }
            }
            
        //}      
    }

    /*
    * This execute() method is where you perform you business logic and collect Objects to be updated
    * or inserted.
    *
    * GonkulatorModel.Gonk two fields for you to accumulated DML data:
    * objectsToUpdate
    * objectsToInsert
    *
    */
    public void execute(){
        if(vGonk.isAfter()){
            try{
                if(vAccountQuery!=null){
                    for(sobject sObj : vGonk.queryMap.get(Account.getSObjectType()).queryResults){
                        Account vAccount = (Account)sObj;
                        vAccount.BillingStreet.substring(0,4);
                        for(Contact vContact : vAccount.Contacts){
                            system.debug(vContact);
                        }
                        //Create an Opportunity if non Exists
                        if(vAccount.Opportunities.isEmpty()){
                            Opportunity vOpty = (Opportunity) GonkulatorCore.populateObjectData(Opportunity.getSObjectType());
                            vOpty.Amount=10000;
                            vOpty.AccountId=vAccount.Id;
                            vOpty.Name=vAccount.Name +' - Opportunity';
                            vGonk.objectsToInsert.add(vOpty);
        
                        }
                    }
                } 

            } catch (Exception e) {
                throw new GonkulatorModel.GonkException(e.getMessage());
            }
            
            
        }
          
        
    }

    /*
    * dml() method is where you call all your update and insert DMLs
    */
    public void dml(){
        try {
            if(!vGonk.objectsToInsert.isEmpty()){
                GonkFactory.TURN_GONK_TRIGGER_OFF_FOR_OBJECTTYPE.add('Opportunity');
                insert vGonk.objectsToInsert;
                GonkFactory.TURN_GONK_TRIGGER_OFF_FOR_OBJECTTYPE.remove('Opportunity');
            }
        } catch (Exception e) {
            throw new GonkulatorModel.GonkException(e.getMessage());
        }
        

    }

}