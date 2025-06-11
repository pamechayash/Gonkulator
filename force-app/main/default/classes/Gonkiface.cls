global interface Gonkiface {
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
    void init(GonkulatorModel.Gonk vGonk);


    /*
    * Use the getData() Method to do any SOQL Queries and store the result in Class
    * Vaiable for Use in Other methods
    */
    void getData();

    /*
    * The Validate() methods is used for you to check integreity of the data and throw erros back to the user 
    * if need
    */
    void validate();

    /*
    * This execute() method is where you perform you business logic and collect Objects to be updated
    * or inserted.
    *
    * GonkulatorModel.Gonk two fields for you to accumulated DML data:
    * objectsToUpdate
    * objectsToInsert
    *
    */
    void execute();

    /*
    * dml() method is where you call all your update and insert DMLs
    */
    void dml();

}