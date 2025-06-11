global class UpdateGonkulatorsQueueable implements Queueable {

    // List of Gonkulator__c records to update
    global List<Gonkulator__c> gonculatorList;
    List<Gonkulator_Log__c> insertLogList;

    // Constructor to pass the list of Gonkulator__c objects
    global UpdateGonkulatorsQueueable(List<Gonkulator__c> gonkulators) {
        System.debug(gonkulators);
        this.gonculatorList = gonkulators;
    }
    // Constructor to pass the list of Gonkulator_Log__c objects
    global UpdateGonkulatorsQueueable(List<Gonkulator_Log__c> vLogList) {
        System.debug(vLogList);
        this.insertLogList = vLogList;
    }

    // The execute method runs asynchronously when the job is dequeued
    global void execute(QueueableContext context) {
        Integer runningQueueableJobsCount = [
                SELECT COUNT()
                FROM AsyncApexJob
                WHERE JobType = 'Queueable'
                AND Status IN ('Processing', 'Preparing')
            ];
            system.debug('runningQueueableJobsCount:'+runningQueueableJobsCount);
            system.debug('Limits.getLimitQueueableJobs():'+Limits.getLimitQueueableJobs());
            //if (runningQueueableJobsCount <= Limits.getLimitQueueableJobs()) {
                if (gonculatorList != null && !gonculatorList.isEmpty()) {
                    try {
                        // Perform any necessary business logic or updates
                        update gonculatorList;
        
                    } catch (Exception e) {
                        // Handle any exceptions that occur during processing
                        System.debug('Error occurred while updating Gonkulator__c records: ' + e.getMessage());
                    }
                }
                if (insertLogList != null && !insertLogList.isEmpty()) {
                    try {
                        // Perform any necessary business logic or updates
                        List<Gonkulator_Log__c> newInserts = new List<Gonkulator_Log__c>();
                        for (Gonkulator_Log__c vLog : insertLogList) {  
                            if(vLog.Id==Null){
                                newInserts.add(vLog);
                            }
                            System.debug(vLog);
                        }
        
                        // Update the Gonkulator__c records in the database
                        insert newInserts;
        
                    } catch (Exception e) {
                        // Handle any exceptions that occur during processing
                        System.debug('Error occurred while updating Gonkulator_Log__c records: ' + e.getMessage());
                    }
                }
                
           // }
        
    }
}