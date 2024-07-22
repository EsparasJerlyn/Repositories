/**
 * @description contains all dml operations
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2023        |DEPP-5567               | Created File                 | 
 */
public inherited sharing abstract class DmlBase implements DmlInterface {
    /**
     * Implement this method to inform the base class of the SObject (custom or standard) to be queried
     **/
    abstract Schema.SObjectType getSObjectType();

    /**
     * Public access for the getSObjectType during Mock registration
     *   (adding public to the existing method broken base class API backwards compatibility1)
     **/
    public SObjectType sObjectType() {
        return getSObjectType();
    }

    public List<Database.SaveResult> insertRecords(
        List<SObject> records,
        Boolean allOrNothing,
        System.AccessLevel accessLevel
    ) {
        List<Database.SaveResult> saveResult = Database.insert(records, allOrNothing, accessLevel);
        for (Database.SaveResult result : saveResult) {
            if (!result.isSuccess()) {
                Logger.error('Error in inserting records').setDatabaseResult(result);
            }
        }
        if (Logger.getBufferSize() > 0) {
            Logger.saveLog();
        }
        return saveResult;
    }

    public List<Database.SaveResult> updateRecords(
        List<SObject> records,
        Boolean allOrNothing,
        System.AccessLevel accessLevel
    ) {
        List<Database.SaveResult> updateResult = Database.update(
            records,
            allOrNothing,
            accessLevel
        );
        for (Database.SaveResult result : updateResult) {
            if (!result.isSuccess()) {
                Logger.error('Error in updating records').setDatabaseResult(result);
            }
        }
        if (Logger.getBufferSize() > 0) {
            Logger.saveLog();
        }
        return updateResult;
    }

    public List<Database.UpsertResult> upsertRecords(
        List<SObject> records,
        Boolean allOrNothing,
        System.AccessLevel accessLevel
    ) {
        List<Database.UpsertResult> upsertResult = Database.upsert(
            records,
            allOrNothing,
            accessLevel
        );
        for (Database.UpsertResult result : upsertResult) {
            if (!result.isSuccess()) {
                Logger.error('Error in upserting records').setDatabaseResult(result);
            }
        }
        if (Logger.getBufferSize() > 0) {
            Logger.saveLog();
        }
        return upsertResult;
    }

    public List<Database.DeleteResult> deleteRecords(
        List<SObject> records,
        Boolean allOrNothing,
        System.AccessLevel accessLevel
    ) {
        List<Database.DeleteResult> deleteResults = Database.delete(
            records,
            allOrNothing,
            accessLevel
        );
        for (Database.DeleteResult result : deleteResults) {
            if (!result.isSuccess()) {
                Logger.error('Error in deleting records').setDatabaseResult(result);
            }
        }
        if (Logger.getBufferSize() > 0) {
            Logger.saveLog();
        }
        return deleteResults;
    }

    public List<Database.DeleteResult> deleteRecords(
        List<Id> recordIds,
        Boolean allOrNothing,
        System.AccessLevel accessLevel
    ) {
        List<Database.DeleteResult> deleteResults = Database.delete(
            recordIds,
            allOrNothing,
            accessLevel
        );
        for (Database.DeleteResult result : deleteResults) {
            if (!result.isSuccess()) {
                Logger.error('Error in deleting records').setDatabaseResult(result);
            }
        }
        if (Logger.getBufferSize() > 0) {
            Logger.saveLog();
        }
        return deleteResults;
    }
}