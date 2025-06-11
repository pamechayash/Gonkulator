global without sharing class AccountAfterInsertHelper implements gonkulator.Gonkiface {
    global gonkulator.GonkulatorModel.Gonk vGonk;

    // Initialize the Gonkulator with the incoming Gonk model
    global void init(gonkulator.GonkulatorModel.Gonk incomingGonk) {
        vGonk = incomingGonk;
    }

    // Retrieve the necessary data (not used in this implementation)
    global void getData() {
        // No SOQL queries needed for this implementation
    }

    // Validate the Account records
    global void validate() {
        // Custom validation logic if necessary
    }

    // Execute the business logic to create a related contact if the account name contains 'Acc'
    global void execute() {
        for (Account acc : (List<Account>) vGonk.objectList) {
            if (acc.Name != null && acc.Name.containsIgnoreCase('Acc')) {
                // Create a new contact
                Contact con = new Contact(
                    LastName = acc.Name, //Set Lastname of contact to the Account Name
                    AccountId = acc.Id
                );
                // Add the contact to the list of objects to insert
                vGonk.objectsToInsert.add(con);
            }
        }
    }

    // Perform the DML operation to insert the new contact
    global void dml() {
        try {
            if (!vGonk.objectsToInsert.isEmpty()) {
                insert vGonk.objectsToInsert;
            }
        } catch (Exception e) {
            throw new gonkulator.GonkulatorModel.GonkException(e.getMessage());
        }
    }
}