/**
 * @description Controller Class for custom flow Lookup logic and functionalities
 * @see ../lwc/flowLookup
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------|
 *    | ryan.j.a.dela.cruz             | June 6, 2023          | DEPP-5385              | Created file                   |
 *    | sebastianne.k.trias            | March 22, 2024        | DEPP-8185              | Added SOSL in search method    |
 */
public inherited sharing class FlowLookupController {
    /**
     * Searches for records based on the specified parameters.
     *
     * @param searchTerm           The search term to look for in the records.
     * @param objectName           The name of the object to search in.
     * @param fieldsToSearch       The comma-separated list of fields to search.
     * @param fieldsToReturn       The comma-separated list of fields to return.
     * @param numRecordsToReturn   The maximum number of records to return.
     * @param whereClause          The WHERE clause to filter the records.
     * @param orderByClause        The ORDER BY clause to sort the records.
     * @return                     A list of SObjects that match the search criteria.
     */
    @AuraEnabled
    public static List<SObject> search(
        String searchTerm,
        String objectName,
        String fieldsToSearch,
        String fieldsToReturn,
        Integer numRecordsToReturn,
        String whereClause,
        String orderByClause
    ) {
        List<SObject> returnRecords = new List<SObject>();
        Map<String, Schema.SObjectField> fieldMap = FlowLookupHelper.getFieldMap(objectName);
        String searchFieldString;

        // Refactored code block 1: Prepare fields to search and return
        fieldsToReturn = FlowLookupHelper.prepareFields(fieldsToSearch, fieldsToReturn, objectName);

        // Refactored code block 2: Build search field string
        searchFieldString = FlowLookupHelper.buildSearchFieldString(
            searchTerm,
            fieldsToSearch,
            fieldMap,
            objectName
        );

        if(objectName == 'Contact'){

            String queryStringSOSL = FlowLookupHelper.buildQueryString(
                objectName,
                fieldsToReturn,
                whereClause,
                null,
                orderByClause,
                numRecordsToReturn,
                true,
                searchTerm
            );

            List<String> contactIds = new List<String>();

            if(queryStringSOSL != null){
                List<List<Contact>> soslResult = search.query(queryStringSOSL); 
                for(Contact con : soslResult[0]){
                    contactIds.add('\''+con.Id+'\'');
                }
            }

            if(!contactIds.isEmpty()){
                searchFieldString += ' OR ID IN ('+String.join(contactIds,',')+')';
            }

        }

        // Refactored code block 3: Build the query string
        String queryString = FlowLookupHelper.buildQueryString(
            objectName,
            fieldsToReturn,
            whereClause,
            searchFieldString,
            orderByClause,
            numRecordsToReturn,
            false,
            searchTerm
        );

        returnRecords = Database.query(queryString);
        return returnRecords;
    }

    /**
     * Retrieves records from the specified object by the provided IDs.
     *
     * @param objectName       The name of the object to retrieve records from.
     * @param fieldsToReturn   The fields to return in the query.
     * @param idsToRetrieve    The list of record IDs to retrieve.
     * @return - The list of SObject records matching the provided IDs.
     */
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecordsFromIds(
        String objectName,
        String fieldsToReturn,
        List<String> idsToRetrieve
    ) {
        // return search(null, objectName, )
        List<String> recordIds = new List<String>();
        for (String recordId : idsToRetrieve) {
            recordIds.add('\'' + recordId + '\'');
        }
        String whereClauseString = 'Id IN (' + String.join(recordIds, ',') + ')';
        return search(null, objectName, null, fieldsToReturn, 0, whereClauseString, null);
    }

    /**
     * Retrieves a list of recently viewed records based on the specified criteria.
     *
     * @param objectName           The name of the object for which recently viewed records are to be retrieved.
     * @param fieldsToReturn       The fields to return in the result.
     * @param numRecordsToReturn   The number of records to return.
     * @param whereClause          The additional filter criteria for the records.
     * @return - A list of SObject records that match the specified criteria.
     */
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecentlyViewed(
        String objectName,
        String fieldsToReturn,
        Integer numRecordsToReturn,
        String whereClause
    ) {
        // Check if the number of records to return is less than or equal to 0
        if (numRecordsToReturn <= 0) {
            numRecordsToReturn = 5; // Set the default value to 5
        }

        // Retrieve the list of recently viewed records
        List<RecentlyViewed> recentlyViewedList = search(
            null,
            'RecentlyViewed',
            null,
            'Id',
            numRecordsToReturn,
            'Type = \'' + objectName + '\'',
            'LastReferencedDate DESC'
        );

        // If no recently viewed records found, return an empty list
        if (recentlyViewedList.isEmpty()) {
            return new List<SObject>();
        }

        // Create a list to store the record IDs
        List<String> recordIds = new List<String>();
        for (RecentlyViewed recentlyViewed : recentlyViewedList) {
            recordIds.add('\'' + recentlyViewed.Id + '\'');
        }

        // Construct the WHERE clause for the final search query
        List<String> whereClauseList = new List<String>{
            'Id IN (' +
            String.join(recordIds, ',') +
            ')'
        };
        if (!String.isBlank(whereClause)) {
            whereClauseList.add(whereClause);
        }

        // Join the WHERE clause list with 'AND' separator
        String whereClauseString = String.join(whereClauseList, ' AND ');

        // Perform the final search query and return the results
        return search(
            null,
            objectName,
            null,
            fieldsToReturn,
            numRecordsToReturn,
            whereClauseString,
            'LastReferencedDate DESC'
        );
    }

    /**
     * Retrieves a list of records of the specified object type that match the specified filter criteria.
     *
     * @param objectName           The API name of the object.
     * @param fieldsToReturn       The comma-separated list of fields to include in the returned records.
     * @param numRecordsToReturn   The maximum number of records to return.
     * @param whereClause          The filter criteria for the records.
     * @return - A list of SObjects matching the specified filter criteria.
     */
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecords(
        String objectName,
        String fieldsToReturn,
        Integer numRecordsToReturn,
        String whereClause
    ) {
        // if numRecordsToReturn is not specified, default to 5
        if (!(numRecordsToReturn > 0)) {
            numRecordsToReturn = 5;
        }

        return search(
            null,
            objectName,
            null,
            fieldsToReturn,
            numRecordsToReturn,
            whereClause,
            null
        );
    }

    /**
     * Retrieves the icon URL for the specified object.
     *
     * @param objectName   The API name of the object.
     * @return The URL of the object's icon.
     */
    @AuraEnabled(cacheable=true)
    public static String getObjectIcon(String objectName) {
        String iconUrl = '';
        boolean isStandardObject = Schema.getGlobalDescribe().containsKey(objectName);

        if (isStandardObject) {
            iconUrl = 'standard:' + objectName.toLowerCase();
        } else {
            iconUrl = getCustomObjectIconFromTab(objectName);
        }

        return iconUrl;
    }

    /**
     * Retrieves the icon URL for a custom object.
     *
     * @param objectName The API name of the object.
     * @return The URL of the object's icon.
     */
    private static String getCustomObjectIconFromTab(String objectName) {
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for (Schema.DescribeTabSetResult tsr : tabSetDesc) {
            tabDesc.addAll(tsr.getTabs());
        }

        for (Schema.DescribeTabResult tr : tabDesc) {
            if (objectName == tr.getSobjectName()) {
                if (tr.isCustom()) {
                    iconDesc.addAll(tr.getIcons());
                }
            }
        }

        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml') {
                return 'custom:' +
                    ir.getUrl().substringBetween('custom/', '.svg').substringBefore('_');
            }
        }

        // If no icon is found, return a specific custom icon, e.g., 'custom:custom18'
        return 'custom:custom18'; // This looks like a document with pencil icon
    }

    /**
     * Retrieves the details of the specified object records.
     *
     * @param objectName   The API name of the object.
     * @param recordIds    The comma-separated list of record IDs.
     * @return - A list of SObjects representing the specified records.
     */
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecordDetail(String objectName, String recordIds) {
        List<SObject> returnRecords = new List<SObject>();
        // if recordIds is a single id, wrap it in quotes
        // if there are multiple ids, split them into a list and wrap each one in quotes
        if (recordIds.contains(',')) {
            List<String> recordIdList = FlowLookupHelper.splitAndTrim(recordIds);
            recordIds = '';
            for (String recordId : recordIdList) {
                recordIds += '\'' + String.escapeSingleQuotes(recordId) + '\',';
            }
            recordIds = recordIds.substringBeforeLast(',');
        } else {
            recordIds = '\'' + String.escapeSingleQuotes(recordIds) + '\'';
        }

        // Build the query from Schema.describeSObjects
        // From Schema.DescribeSObjectResult get the fields
        String query = 'SELECT ';
        SObjectType describeObject = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> mfields = describeObject.getDescribe().fields.getMap();
        for (String field : mfields.keySet()) {
            query += field + ',';
        }
        query = query.substringBeforeLast(',');
        query += ' FROM ' + objectName + ' WHERE Id IN (' + recordIds + ')';

        returnRecords = Database.query(query); // NOPMD - recordIds are already escaped, this is a false positive
        return returnRecords;
    }
}
