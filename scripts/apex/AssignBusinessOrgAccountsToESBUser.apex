/**
    DEPP-6101 AC2: All existing Account with record type = “Business Organization”,
    owner should be updated to “ESB Integration User“
 */

// Query the User Id for "ESB Integration User"
User esbIntegrationUser = [SELECT Id FROM User WHERE FirstName ='ESB' and LastName = 'Integration User' LIMIT 1];

// Query for Accounts with the specific Record Type Id
List<Account> accountsToUpdate = [SELECT Id, OwnerId FROM Account WHERE RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Organization').getRecordTypeId()];

// Update Account Owner to "ESB Integration User"
for (Account acc : accountsToUpdate) {
    acc.OwnerId = esbIntegrationUser.Id;
}

// Perform DML to update the Accounts
if (!accountsToUpdate.isEmpty()) {
    update accountsToUpdate;
}