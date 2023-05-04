/**
 * @description Mock class for dml operations
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2023        |DEPP-5567               | Created File                 | 
 */
public abstract class DmlBaseMock implements DmlInterface {
    protected Map<Id, SObject> records;
    public MockIdGenerator builder;
    private static final String ID_FIELD = 'Id';

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

    public DmlBaseMock(Map<Id, SObject> records, Schema.SObjectType objectType) {
        this.records = records;
        this.builder = new MockIdGenerator(objectType);
    }

    public List<SObject> getRecords() {
        return this.records.values();
    }

    public List<Database.SaveResult> insertRecords(
        List<SObject> records,
        Boolean allOrNothing,
        System.AccessLevel accessLevel
    ) {
        List<Database.SaveResult> resultList = new List<Database.SaveResult>();
        for (SObject record : records) {
            Boolean isSuccess = true;
            Id recordId;
            if (record.get(ID_FIELD) == null) {
                recordId = builder.getMockId();
            }
            record.put(ID_FIELD, recordId);
            this.records.put((Id) recordId, record);
            Database.SaveResult result = (Database.SaveResult) JSON.deserialize(
                '{"success":' + isSuccess + ',"id":"' + recordId + '"}',
                Database.SaveResult.class
            );
            resultList.add(result);
        }

        return resultList;
    }

    public List<Database.SaveResult> updateRecords(
        List<SObject> records,
        Boolean allOrNothing,
        System.AccessLevel accessLevel
    ) {
        List<Database.SaveResult> resultList = new List<Database.SaveResult>();
        for (SObject record : records) {
            Boolean isSuccess = true;
            Id recordId;
            recordId = (Id) record.get(ID_FIELD);
            this.records.put((Id) recordId, record);
            Database.SaveResult result = (Database.SaveResult) JSON.deserialize(
                '{"success":' + isSuccess + ',"id":"' + recordId + '"}',
                Database.SaveResult.class
            );
            resultList.add(result);
        }

        return resultList;
    }

    public List<Database.UpsertResult> upsertRecords(
        List<SObject> records,
        Boolean allOrNothing,
        System.AccessLevel accessLevel
    ) {
        List<Database.UpsertResult> resultList = new List<Database.UpsertResult>();
        for (SObject record : records) {
            Boolean isSuccess = true;
            Boolean isCreated = false;
            Id recordId;
            if (record.get(ID_FIELD) == null) {
                isCreated = true;
                recordId = builder.getMockId();
            } else {
                recordId = (Id) record.get(ID_FIELD);
            }
            record.put(ID_FIELD, recordId);
            this.records.put((Id) recordId, record);
            Database.UpsertResult result = (Database.UpsertResult) JSON.deserialize(
                '{"created":' + isCreated + ',"success":' + isSuccess + ',"id":"' + recordId + '"}',
                Database.UpsertResult.class
            );
            resultList.add(result);
        }

        return resultList;
    }

    public List<Database.DeleteResult> deleteRecords(
        List<SObject> records,
        Boolean allOrNothing,
        System.AccessLevel accessLevel
    ) {
        List<Database.DeleteResult> resultList = new List<Database.DeleteResult>();
        for (SObject record : records) {
            Boolean isSuccess = true;
            Id recordId;
            recordId = (Id) record.get(ID_FIELD);
            this.records.remove((Id) recordId);
            Database.DeleteResult result = (Database.DeleteResult) JSON.deserialize(
                '{"success":' + isSuccess + ',"id":"' + recordId + '"}',
                Database.DeleteResult.class
            );
            resultList.add(result);
        }

        return resultList;
    }

    public List<Database.DeleteResult> deleteRecords(
        List<Id> recordIds,
        Boolean allOrNothing,
        System.AccessLevel accessLevel
    ) {
        List<Database.DeleteResult> resultList = new List<Database.DeleteResult>();
        for (Id recordId : recordIds) {
            Boolean isSuccess = true;
            this.records.remove(recordId);
            Database.DeleteResult result = (Database.DeleteResult) JSON.deserialize(
                '{"success":' + isSuccess + ',"id":"' + recordId + '"}',
                Database.DeleteResult.class
            );
            resultList.add(result);
        }

        return resultList;
    }
}
