/**
 * @description Service class for Dynamic Queries contains all reusable dynamic queries.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | roy.nino.s.regala              | June 14, 2023         | DEPP-5391              | Created                      | 
 */

public with sharing class DynamicQueryService {
    /**
     * Query related records with offset in order
     * @param parametersMap
     * A map of string key and values
     * Key value pair are as follows
     * Parent to child relationship(e.g. Account -> Contact):
     * recordId(required) - record id of the parent record(e.g. AccountId)
     * relatedRecord(required) - object api name of the records to be queried(e.g. Contact)
     * relatedField(required) - field api name of the lookup field(e.g. AccountId)
     * relatedFieldApiNames(required) - comma separated field api names to be queried(e.g. Name,Email,Account.Name)
     * relatedListFilters - the where clause of the query(e.g. AND RecordType.DeveloperName = 'Unversity_Department')
     * rowOffSet(required) - the offset of the query(e.g. 0)
     * rowLimit(required) - the limit of the query(e.g. 10)
     * sortOrder(required) - the order of the query for sort(e.g. DESC)
     * sortField(required) - the field used to order the query for sort(e.g. CreatedDate)
     * @return List of records queried
     */
    public static List<SObject> getRelatedRecordsWithOffSetInOrder(
        Map<String, String> parametersMap
    ) {
        String relatedRecordsStringQuery =
            'SELECT ' +
            String.escapeSingleQuotes(parametersMap.get('relatedFieldApiNames')) +
            ' FROM ' +
            String.escapeSingleQuotes(parametersMap.get('relatedRecord')) +
            ' WHERE ' +
            String.escapeSingleQuotes(parametersMap.get('relatedField')) +
            ' = \'' +
            String.escapeSingleQuotes(parametersMap.get('recordId')) +
            '\'' +
            ' ' +
            parametersMap.get('relatedListFilters') +
            ' WITH USER_MODE ' +
            ' Order By ' +
            String.escapeSingleQuotes(parametersMap.get('sortField')) +
            ' ' +
            String.escapeSingleQuotes(parametersMap.get('sortOrder')) +
            ' LIMIT ' +
            String.escapeSingleQuotes(parametersMap.get('rowLimit')) +
            ' OFFSET ' +
            String.escapeSingleQuotes(parametersMap.get('rowOffSet'));

        return Database.query(relatedRecordsStringQuery); //NOPMD
    }

    /**
     * Get the count of related records in the database
     * @param parametersMap
     * A map of string key and values
     * Key value pair are as follows
     * Parent to child relationship(e.g. Account -> Contact):
     * recordId(required) - record id of the parent record(e.g. AccountId)
     * relatedRecord(required) - object api name of the records to be queried(e.g. Contact)
     * relatedField(required) - field api name of the lookup field(e.g. AccountId)
     * relatedListFilters(required) - the where clause of the query(e.g. RecordType.DeveloperName = 'Unversity_Department')
     * @return count of the records queried
     */
    public static Integer getRelatedRecordsCountWithFilter(Map<String, String> parametersMap) {
        String relatedRecordsCountStringQuery =
            'SELECT Count() FROM ' +
            String.escapeSingleQuotes(parametersMap.get('relatedRecord')) +
            ' WHERE ' +
            String.escapeSingleQuotes(parametersMap.get('relatedField')) +
            ' = \'' +
            String.escapeSingleQuotes(parametersMap.get('recordId')) +
            '\'' +
            ' ' +
            parametersMap.get('relatedListFilters') +
            ' WITH USER_MODE ';
        return Database.countQuery(relatedRecordsCountStringQuery); //NOPMD
    }
}
