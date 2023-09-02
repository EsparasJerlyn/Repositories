/**
 * @description interface for dml operations
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | April 24, 2023        | DEPP-5567              | Created File                 | 
 */
public interface DmlInterface{
	Schema.SObjectType sObjectType();
	List<Database.SaveResult> insertRecords(List<SObject> records, Boolean allOrNothing, System.AccessLevel accessLevel);
	List<Database.SaveResult> updateRecords(List<SObject> records, Boolean allOrNothing, System.AccessLevel accessLevel);
	List<Database.UpsertResult> upsertRecords(List<SObject> records, Boolean allOrNothing, System.AccessLevel accessLevel);
	List<Database.DeleteResult> deleteRecords(List<SObject> records, Boolean allOrNothing, System.AccessLevel accessLevel);
	List<Database.DeleteResult> deleteRecords(List<Id> recordIds, Boolean allOrNothing, System.AccessLevel accessLevel);
}