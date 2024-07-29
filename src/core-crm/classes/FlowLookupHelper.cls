/**
 * @description Helper Class for FlowLookupController
 * @see ../classes/FlowLookupController
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | ryan.j.a.dela.cruz             | June 7, 2023          | DEPP-5385              | Created file                                   |
 *    | ryan.j.a.dela.cruz             | October 19, 2023      | DEPP-6928/DEPP-6973    | Added fullName and email search                |
 *    | sebastianne.k.trias            | March 22, 2024        | DEPP-8185              | Added SOSL in buildQueryString method          |
 */
public inherited sharing class FlowLookupHelper {
    /**
     * Retrieves the API name of the name field for the specified object.
     *
     * @param objectName   The API name of the object.
     * @return - The API name of the name field, or null if not found.
     */
    public static String getNameField(String objectName) {
        Map<String, Schema.SObjectField> fieldMap = getFieldMap(objectName);
        if (fieldMap.containsKey('Name') && fieldMap.get('Name').getDescribe().IsNameField()) {
            return 'Name';
        }
        for (String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();
            if (fieldResult.IsNameField()) {
                return fieldResult.getName();
            }
        }
        return null;
    }

    /**
     * Retrieves the field map for the specified object.
     *
     * @param objectName   The API name of the object.
     * @return - A map of field API names to their corresponding Schema.SObjectField.
     */
    public static Map<String, Schema.SObjectField> getFieldMap(String objectName) {
        return ((SObject) (Type.forName('Schema.' + objectName).newInstance()))
            .getSObjectType()
            .getDescribe()
            .fields.getMap();
    }

    /**
     * Splits and trims the input string using the default delimiter (comma).
     *
     * @param inputString   The string to split and trim.
     * @return - A list of strings after splitting and trimming the input string.
     */
    public static List<String> splitAndTrim(String inputString) {
        return splitAndTrim(inputString, ',');
    }

    /**
     * Splits and trims the input string using the specified delimiter.
     *
     * @param inputString   The string to split and trim.
     * @param delimiter     The delimiter to use for splitting the string.
     * @return - A list of strings after splitting and trimming the input string.
     */
    public static List<String> splitAndTrim(String inputString, String delimiter) {
        List<String> splitStrings = inputString.split(delimiter);
        for (String splitString : splitStrings) {
            splitString = splitString.trim();
        }

        return splitStrings;
    }

    /**
     * Prepares the fields to search and return.
     *
     * @param fieldsToSearch   The comma-separated list of fields to search.
     * @param fieldsToReturn   The comma-separated list of fields to return.
     * @param objectName       The name of the object.
     * @return - The prepared fields to return.
     */
    public static String prepareFields(
        String fieldsToSearch,
        String fieldsToReturn,
        String objectName
    ) {
        String objectNameField = getNameField(objectName);

        if (String.isBlank(fieldsToSearch)) {
            fieldsToSearch = '';
        }
        fieldsToSearch = fieldsToSearch.replaceAll('(\\s+)', '');

        if (String.isBlank(fieldsToReturn)) {
            fieldsToReturn = '';
        }
        fieldsToReturn = fieldsToReturn.replaceAll('(\\s+)', '');

        if (String.isBlank(fieldsToReturn)) {
            // If no fields to return are specified, return the name field
            fieldsToReturn = objectNameField;
        } else if (!String.isBlank(fieldsToSearch)) {
            // Go through the list of fields to search and add them to the list of fields to return if they are not already there
            for (String searchField : fieldsToSearch.split(',')) {
                if (!fieldsToReturn.contains(searchField)) {
                    fieldsToReturn += ', ' + searchField;
                }
            }
        }

        return fieldsToReturn;
    }

    /**
     * Builds the search field string.
     *
     * @param searchTerm       The search term to look for in the records.
     * @param fieldsToSearch   The comma-separated list of fields to search.
     * @param fieldMap         The map of fields for the object.
     * @param objectName       The name of the object.
     * @return - The search field string.
     */
    public static String buildSearchFieldString(
        String searchTerm,
        String fieldsToSearch,
        Map<String, Schema.SObjectField> fieldMap,
        String objectName
    ) {
        String searchFieldString = '';

        // Check if the search term is blank
        if (!String.isBlank(searchTerm)) {
            // If no specific fields to search are provided, use the object name field
            if (String.isBlank(fieldsToSearch)) {
                // Get the name field of the object
                fieldsToSearch = getNameField(objectName);
            }

            List<String> searchFieldList = processFieldsToSearch(
                fieldsToSearch,
                fieldMap,
                objectName,
                searchTerm
            );

            // Join the search field list with 'OR' operator to form the search field string
            searchFieldString = String.join(searchFieldList, ' OR ');
        }

        // Return the final search field string
        return searchFieldString;
    }

    /**
     * Builds the query string based on the provided parameters.
     *
     * @param objectName           The name of the object to query.
     * @param fieldsToReturn       The fields to return in the query.
     * @param whereClause          The WHERE clause of the query.
     * @param searchFieldString    The search field string for searching specific fields.
     * @param orderByClause        The ORDER BY clause of the query.
     * @param numRecordsToReturn   The maximum number of records to return.
     * @return - The built query string.
     */
    public static String buildQueryString(
        String objectName,
        String fieldsToReturn,
        String whereClause,
        String searchFieldString,
        String orderByClause,
        Integer numRecordsToReturn,
        Boolean useSOSL,
        String searchTerm
    ) {
        String queryString = '';
        if (useSOSL)
        {
            if(searchTerm != null && searchTerm.length() < 2){
                return null;
            }
            searchTerm = '*'+searchTerm+'*';
            queryString = 'FIND \'' +String.escapeSingleQuotes(searchTerm)+ '*\' IN NAME FIELDS RETURNING '+objectName+ '('+fieldsToReturn+'';
            if (!String.isBlank(whereClause) || !String.isBlank(searchFieldString)) {
                queryString += ' WHERE ';
                if (!String.isBlank(whereClause) && !String.isBlank(searchFieldString)) {
                    queryString += '(' + searchFieldString + ') AND (' + whereClause + ')';
                } else {
                    queryString += String.isBlank(searchFieldString) ? whereClause : searchFieldString;
                }
            }
            if (!String.isBlank(orderByClause)) {
                queryString += ' ORDER BY ' + orderByClause;
            }
            if (numRecordsToReturn > 0) {
                queryString += ' LIMIT ' + numRecordsToReturn;
            }
            queryString += ')';
        }
        else
        { 
            queryString = 'SELECT ' + fieldsToReturn + ' FROM ' + objectName;

            if (!String.isBlank(whereClause) || !String.isBlank(searchFieldString)) {
                queryString += ' WHERE ';
                if (!String.isBlank(whereClause) && !String.isBlank(searchFieldString)) {
                    queryString += '(' + searchFieldString + ') AND (' + whereClause + ')';
                } else {
                    queryString += String.isBlank(searchFieldString) ? whereClause : searchFieldString;
                }
            }
            if (!String.isBlank(orderByClause)) {
                queryString += ' ORDER BY ' + orderByClause;
            }
            if (numRecordsToReturn > 0) {
                queryString += ' LIMIT ' + numRecordsToReturn;
            }
        }
        return queryString;
    }

    /**
     * Processes the fields to search and adds them to the search field list.
     *
     * @param fieldsToSearch   The comma-separated list of fields to search.
     * @param fieldMap         The map of fields for the object.
     * @param objectName       The name of the object.
     * @param searchTerm       The search term to look for in the records.
     * @return - The list of processed search fields.
     */
    public static List<String> processFieldsToSearch(
        String fieldsToSearch,
        Map<String, Schema.SObjectField> fieldMap,
        String objectName,
        String searchTerm
    ) {
        List<String> searchFieldList = new List<String>();

        // Split the fields to search by comma and process each field
        for (String searchField : fieldsToSearch.split(',')) {
            if (searchField.contains('.')) {
                processRelationshipField(
                    searchField,
                    fieldMap,
                    objectName,
                    searchTerm,
                    searchFieldList
                );
            } else {
                processRegularField(searchField, fieldMap, searchTerm, searchFieldList);
            }
        }

        return searchFieldList;
    }

    /**
     * Processes a relationship field and adds it to the search field list.
     *
     * @param searchField       The relationship field to process.
     * @param fieldMap          The map of fields for the object.
     * @param objectName        The name of the object.
     * @param searchTerm        The search term to look for in the records.
     * @param searchFieldList   The list of search fields to add to.
     */
    public static void processRelationshipField(
        String searchField,
        Map<String, Schema.SObjectField> fieldMap,
        String objectName,
        String searchTerm,
        List<String> searchFieldList
    ) {
        // Split the relationship field into its parts
        String[] relationshipParts = searchField.split('\\.');
        String relationshipName = relationshipParts[1];
        String relationshipField = relationshipParts[2];
        String relationshipNameConverted = relationshipName;
        String relationshipObjectName = objectName;
        String searchFieldConverted = searchField;

        // Check if the relationship exists in the field map
        if (fieldMap.get(relationshipName) == null) {
            relationshipNameConverted = tryAddingRelationshipSuffix(
                relationshipName,
                fieldMap,
                searchFieldConverted
            );

            if (fieldMap.get(relationshipNameConverted) == null) {
                relationshipNameConverted = tryAddingIdSuffix(
                    relationshipName,
                    fieldMap,
                    relationshipNameConverted
                );
            }
        }

        // Get the token map for the relationship field
        Map<String, Schema.SObjectField> tokenMap = ((SObject) Type.forName('Schema', objectName)
                .newInstance())
            .getSObjectType()
            .getDescribe()
            .fields.getMap();
        Schema.DescribeFieldResult fieldResult = tokenMap.get(relationshipNameConverted)
            .getDescribe();

        // Check if the relationship field is a reference field with only one reference object
        if (fieldResult.getReferenceTo().size() == 1) {
            relationshipObjectName = fieldResult.getReferenceTo()[0].getDescribe().getName();
        }

        // Check if the relationship exists in the field map
        Boolean isRelationshipInFieldmap = fieldMap.get(relationshipName) != null && fieldMap.get(relationshipName).getDescribe().getRelationshipName() != null;
        if (isRelationshipInFieldmap) {
            Map<String, Schema.SObjectField> relationshipFieldMap = getFieldMap(
                relationshipObjectName
            );
            Boolean isRelationshipNameString = relationshipFieldMap.get(relationshipField) != null && relationshipFieldMap.get(relationshipField).getDescribe().getType().name() =='String';
            if (isRelationshipNameString) {
                searchFieldList.add(searchFieldConverted + ' LIKE \'%' + searchTerm + '%\'');
            }
        }  
    }

    /**
     * Tries adding the "__r" suffix to the relationship field name.
     *
     * @param searchField   The relationship field name to try.
     * @param fieldMap      The map of fields for the object.
     * @param objectName    The name of the object.
     * @return - The modified relationship field name if it exists, otherwise the original field name.
     */
    public static String tryAddingRelationshipSuffix(
        String relationshipName,
        Map<String, Schema.SObjectField> fieldMap,
        String searchFieldConverted
    ) {
        String relationshipNameConverted = relationshipName + '__r';

        if (fieldMap.get(relationshipNameConverted) != null) {
            searchFieldConverted = searchFieldConverted.replace(
                relationshipName,
                relationshipNameConverted
            );
            relationshipName = relationshipNameConverted;
        }

        return relationshipName;
    }

    /**
     * Tries adding the 'Id' suffix to the relationship name and checks if it exists in the field map.
     * If the suffixed relationship field exists, it updates the converted relationship name.
     *
     * @param relationshipName            The relationship name to try adding the 'Id' suffix to.
     * @param fieldMap                    The map of field names to SObjectField objects.
     * @param relationshipNameConverted   The converted relationship name (if available).
     * @return - The updated relationship name (if the suffixed field exists), otherwise the original relationship name.
     */
    public static String tryAddingIdSuffix(
        String relationshipName,
        Map<String, Schema.SObjectField> fieldMap,
        String relationshipNameConverted
    ) {
        String relationshipNameWithIdSuffix = relationshipName + 'Id';

        if (fieldMap.get(relationshipNameWithIdSuffix) != null) {
            relationshipNameConverted = relationshipNameWithIdSuffix;
        }

        return relationshipNameConverted;
    }

    /**
     * Processes a regular field by checking if it exists in the field map and has a type of 'String'.
     * If both conditions are met, it adds a LIKE clause for searching.
     *
     * @param searchField       The name of the field to process.
     * @param fieldMap          The map of field names to SObjectField objects.
     * @param searchTerm        The search term used in the LIKE clause.
     * @param searchFieldList   The list to add the search clause to.
     */
    public static void processRegularField(
        String searchField,
        Map<String, Schema.SObjectField> fieldMap,
        String searchTerm,
        List<String> searchFieldList
    ) {
        if (
            fieldMap.get(searchField) != null &&
            (fieldMap.get(searchField).getDescribe().getType().name() == 'String' ||
            fieldMap.get(searchField).getDescribe().getType().name() == 'Email' ||
            fieldMap.get(searchField).getDescribe().getType().name() == 'Picklist')
        ) {
            searchFieldList.add(searchField + ' LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        }
    }
}