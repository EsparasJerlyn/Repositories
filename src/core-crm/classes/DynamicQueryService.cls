/**
 * @description Service class for Dynamic Queries contains all reusable dynamic queries.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                      |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------------------|
      | roy.nino.s.regala              | June 14, 2023         | DEPP-5391              | Created                                             | 
      | roy.nino.s.regala              | June 24, 2023         | DEPP-5411              | Added Query service for record query with filter    | 
      | roy.nino.s.regala              | Aug 26, 2023          | DEPP-6348              | Added access level paramater                        | 
      | eccarius.munoz                 | September 2, 2023     | DEPP-6138              | added method getRecordsWithFieldsByIdSet            |
 */

public inherited sharing class DynamicQueryService {
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
     * @param accessLevel - access level of the soql.
     * @return List of records queried
     */
    public static List<SObject> getRelatedRecordsWithOffSetInOrder(
        Map<String, String> parametersMap,
        AccessLevel accessLevel
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
            ' Order By ' +
            String.escapeSingleQuotes(parametersMap.get('sortField')) +
            ' ' +
            String.escapeSingleQuotes(parametersMap.get('sortOrder')) +
            ' LIMIT ' +
            String.escapeSingleQuotes(parametersMap.get('rowLimit')) +
            ' OFFSET ' +
            String.escapeSingleQuotes(parametersMap.get('rowOffSet'));

        return Database.query(relatedRecordsStringQuery,accessLevel); //NOPMD
    }

    /**
     * Query records with filter
     * @param parametersMap
     * A map of string key and values
     * Key value pair are as follows
     * recordId(required) - record id of the record
     * sObjectApiName(required) - object api name of the records to be queried(e.g. Contact)
     * filter(required) - where clause of the filter(e.g. Stage != 'Completed')
     * @param accessLevel - access level of the soql.
     * @return List of records queried
     */
    public static List<SObject> getRecordWithFilter(
        Map<String, String> parametersMap,
        AccessLevel accessLevel
    ){
        String recordStringQuery =
        'SELECT Id, Name FROM ' +
        String.escapeSingleQuotes(parametersMap.get('sObjectApiName')) +
        ' WHERE Id ' + 
        ' = \'' +
        String.escapeSingleQuotes(parametersMap.get('recordId')) +
        '\'' +
        ' ' +
        'AND ' + parametersMap.get('filter');
        return Database.query(recordStringQuery,accessLevel); //NOPMD
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
     * @param accessLevel - access level of the soql.
     * @return count of the records queried
     */
    public static Integer getRelatedRecordsCountWithFilter(Map<String, String> parametersMap, AccessLevel accessLevel) {
        String relatedRecordsCountStringQuery =
            'SELECT Count() FROM ' +
            String.escapeSingleQuotes(parametersMap.get('relatedRecord')) +
            ' WHERE ' +
            String.escapeSingleQuotes(parametersMap.get('relatedField')) +
            ' = \'' +
            String.escapeSingleQuotes(parametersMap.get('recordId')) +
            '\'' +
            ' ' +
            parametersMap.get('relatedListFilters');
        return Database.countQuery(relatedRecordsCountStringQuery,accessLevel); //NOPMD
    }

    /**
     * Get filtered records by fields
     * 
     */
    public static List<SObject> getRecordsWithFieldsByIdSet(
        FilterWrapper filterWrapper,
        AccessLevel accessLevel
    ){
        String fieldsToQuery = filterWrapper.fields.size() > 0 ? 'Id, ' + String.join(filterWrapper.fields, ',') : 'Id';
        String sObjectName = filterWrapper.sObjectType.getDescribe(SObjectDescribeOptions.DEFAULT).getName();
        Set<Id> recordIds = filterWrapper.recordIds;    //NOPMD this is used in the query below
        return Database.query(
            'SELECT ' + String.escapeSingleQuotes(fieldsToQuery) + ' ' +
              'FROM ' + String.escapeSingleQuotes(sObjectName) + ' ' +
             'WHERE Id IN: recordIds', accessLevel
        );
    }

    public static String formatStringSetForWhereClause(Set<String> stringSet){
        List<String> formattedStrings = new List<String>();
        for(String stringValue : stringSet){
            formattedStrings.add('\'' + stringValue + '\'');
        }
        return String.join(formattedStrings, ', ');
    }

    public static String formatStringSetForWhereClause(Set<Id> idSet){
        Set<String> stringIdSet = (Set<String>)JSON.deserialize(JSON.serialize(idSet), Set<String>.class);
        List<String> formattedStrings = new List<String>();
        for(String stringValue : stringIdSet){
            formattedStrings.add('\'' + stringValue + '\'');
        }
        return String.join(formattedStrings, ', ');
    }

    public static String convertDatetoDateString(Date varDate){
        String strReturnDate =  DateTime.newInstance(varDate.year(), varDate.month(), varDate.day()).format('YYYY-MM-dd');
        return strReturnDate;
    }

    public static String convertDatetoDateTimeGMTString(Date varDate){
        return DateTime.newInstanceGmt(varDate.year(), varDate.month(), varDate.day()).format('YYYY-MM-dd\'T\'HH:mm:ssZ', 'GMT');
    }

    public class FilterWrapper{
        public Set<Id> recordIds;
        public SObjectType sObjectType;
        public List<String> fields;

        public FilterWrapper(Set<Id> recordIds, SObjectType sObjectType, List<String> fields){
            this.recordIds = recordIds;
            this.sObjectType = sObjectType;
            this.fields = fields;
        }
    }

}
