/**
 * @description Controller for dynamicDataTable.js
 * As per business request, this table shows all related records regardless of user's sharing access
 * UserRecordAccess Object is checked to control user's Edit and Record redirection
 * @see ../lwc/dynamicDataTable
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                                            |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------------------------------------|
 *    | roy.nino.s.regala              | June 14, 2023         | DEPP-5391              | Created file                                                              |
 *    | roy.nino.s.regala              | June 24, 2023         | DEPP-5411              | Added visibility check                                                    |
 *    | roy.nino.s.regala              | July 11, 2023         | DEPP-5459              | added percent value change                                                |
 *    | roy.nino.s.regala              | July 11, 2023         | DEPP-5459              | fix url issue                                                             |
 *    | roy.nino.s.regala              | Aug 25, 2023          | DEPP-6348              | made class in system mode and added user access checker to look up fields |
 *    | roy.nino.s.regala              | Feb 28, 2023          | DEPP-8155              | enable locking of edit button of related list by parent field             |
 */

public without sharing class DynamicDataTableCtrl { //NOPMD bypassed too many public methods, 
    /**
     * Builds the datatable columns and rows. And count the total records in the system.
     * @param tableWrapperParams
     * A map of string key and values
     * contains the parameters to build table columns and data
     * Key value pair are as follows
     * Parent to child relationship(e.g. Account -> Contact):
     * recordId - record id of the parent record(e.g. AccountId)
     * parentRecord - api name of the parent record(e.g. Account)
     * relatedRecord - object api name of the records to be queried(e.g. Contact)
     * relatedField - field api name of the lookup field(e.g. AccountId)
     * relatedListFields - JSON string that gives info on what the table should look like (e.g.[{"label":"Name","fieldName":"Name","type":"text"}])
     * relatedListFilters - the where clause of the query(e.g. AND RecordType.DeveloperName = 'Person')
     * rowOffSet - the offset of the query(e.g. 0)
     * rowLimit - the limit of the query(e.g. 10)
     * sortOrder - the order of the query for sort(e.g. DESC)
     * sortField - the field used to order the query for sort(e.g. CreatedDate)
     * visibilityByParent - filter for parent record(e.g Stage != 'Completed')
     * visibilityByUser - filter for user record(e.g UserRole.DeveloperName = 'Partnership_Manager')
     * @return DataTableResponse   contains the table columns,rows and record count.
     */
    @AuraEnabled
    public static DataTableResponse getTableDataWrapper(Map<String, String> tableWrapperParams) {

        String relatedFieldApiNames = '';
        String relatedListFields = tableWrapperParams.get('relatedListFields');

        Set<String> lookupFields = new Set<String>();
        Set<Id> lookupIds = new Set<Id>();

        List<DataTableColumns> parsedRelatedListFields = (List<DataTableColumns>) JSON.deserialize(
            relatedListFields,
            List<DataTableColumns>.class
        );

        List<String> percentFieldNames = new List<String>();

        List<DataTableColumns> tempDataColumns = new List<DataTableColumns>();
        //build datatable columns
        for (DataTableColumns field : parsedRelatedListFields) {
            relatedFieldApiNames += field.fieldName + ',';

            DataTableColumns dataColumns = new DataTableColumns(
                field.label.trim(),
                field.fieldName.trim(),
                field.type.trim()
            );

            //collect percent type fields
            if (field.type.trim() == 'percent') {
                percentFieldNames.add(field.fieldName);
            }

            tempDataColumns.add(dataColumns);
            //get all look up field api names
            getLookupFieldName(field,lookupFields);
        }

        relatedFieldApiNames = relatedFieldApiNames.removeEnd(',');

        //finalize query parameters
        Map<String, String> parametersMap = new Map<String, String>();
        parametersMap.putAll(tableWrapperParams);
        parametersMap.put('relatedFieldApiNames', relatedFieldApiNames);

        //finalize datatable return
        DataTableResponse finalWrapper = new DataTableResponse();
        finalWrapper.dataTableColumns = tempDataColumns;

        if (!percentFieldNames.isEmpty()) {
            finalWrapper.dataTableData = percentageValueChange(percentFieldNames, parametersMap);
        } else {
            finalWrapper.dataTableData = DynamicQueryService.getRelatedRecordsWithOffSetInOrder(
                parametersMap,
                AccessLevel.SYSTEM_MODE
            );
        }
        
        //get all lookup field id values
        for(SObject record: finalWrapper.dataTableData){
            lookupIds.add((Id)record.get('Id'));
            for(String field: lookupFields){
                lookupIds.add((Id)record.get(field));
            }
        }

        finalWrapper.recordCount = DynamicQueryService.getRelatedRecordsCountWithFilter(
            parametersMap,
            AccessLevel.SYSTEM_MODE
        );
        finalWrapper.hasAcessByUser = true;
        finalWrapper.hasAccessByParent = true;

        //get user record access data
        finalWrapper.userAccessTable =  UserRecordAccessesDAO.newInstance().getUserRecordAccessesBySetRecordIds(lookupIds);

        if (
            //checks if current user is admin, visibility check is bypassed if admin
            !ProfilesDAO.ADMIN_PROFILES.contains(
                ProfilesDAO.newInstance()
                    .getProfileRecordsBySetIds(new Set<Id>{ UserInfo.getProfileId() })
                    .iterator()
                    .next()
                    .Name
            )
        ) {
            finalWrapper.hasAcessByUser = getVisiblityCheckResult(tableWrapperParams).get('User');
            finalWrapper.hasAccessByParent = getVisiblityCheckResult(tableWrapperParams).get('Parent');
        }

        return finalWrapper;
    }


    /**
     * Logic to check if user has visibility to new and edit buttons of the table
     * @param field - field data for table columns
     * @param lookupFields - look up field api names to be populated
     */
    private static void getLookupFieldName(DataTableColumns field, Set<String> lookupFields){
        String lookupFieldApiName = '';

        if (
            field.type.trim() == 'url' &&
            field.fieldName.contains('.Name') &&
            field.fieldName.substringAfter('.') == 'Name'
        ) {
            lookupFieldApiName = field.fieldName.substringBefore('.') + 'Id';
            if (field.fieldName.substringBefore('.').contains('__r')) {
                lookupFieldApiName = field.fieldName.substringBefore('__r') + '__c';
            }

            lookupFields.add(lookupFieldApiName);
        }
    }

    /**
     * Logic to check if user has visibility to new and edit buttons of the table
     * @param paramsMap
     * A map of string key and values
     * contains the parameters to check the visibility of the edit and new buttons of the table
     * Key value pair are as follows
     * recordId - record id of the parent record
     * parentRecord - api name of the parent record(e.g. Account)
     * visibilityByParent - filter for parent record(e.g Stage != 'Completed')
     * visibilityByUser - filter for user record(e.g UserRole.DeveloperName = 'Partnership_Manager')
     *
     * @return DataTableResponse   contains the table columns,rows and record count.
     */
    private static Map<String,Boolean> getVisiblityCheckResult(Map<String, String> paramsMap) {

        Map<String,Boolean> getAccessCheckResultMap = new Map<String,Boolean>{
            'Parent' => true,
            'User' => true
        };

        List<SObject> parentResult = new List<SObject>();
        List<SObject> userResult = new List<SObject>();
        boolean checkParentVisibility = false;
        boolean checkUserVisibility = false;
        Map<String, String> parametersMap = new Map<String, String>();

        if (!String.isBlank(paramsMap.get('visibilityByParent'))) {
            parametersMap.put('sObjectApiName', paramsMap.get('parentRecord'));
            parametersMap.put('recordId', paramsMap.get('recordId'));
            parametersMap.put('filter', paramsMap.get('visibilityByParent'));
            parentResult = DynamicQueryService.getRecordWithFilter(parametersMap,AccessLevel.SYSTEM_MODE);
            checkParentVisibility = true;
        }

        if (!String.isBlank(paramsMap.get('visibilityByUser'))) {
            parametersMap.put('sObjectApiName', 'User');
            parametersMap.put('recordId', String.escapeSingleQuotes(UserInfo.getUserId()));
            parametersMap.put('filter', paramsMap.get('visibilityByUser'));
            userResult = DynamicQueryService.getRecordWithFilter(parametersMap,AccessLevel.SYSTEM_MODE);
            checkUserVisibility = true;
        }

        if(checkParentVisibility == true && parentResult.isEmpty()){
            getAccessCheckResultMap.put('Parent',false);
        }

        if(checkUserVisibility == true && userResult.isEmpty()){
            getAccessCheckResultMap.put('User',false);
        }

        return getAccessCheckResultMap;
       
    }

    /**
     * Logic to update the percent value so the datatable can render it properly
     * @param percentFieldNames - list of field api names of type percent
     * @param parametersMap - Map of strings that is used to retrieve a list of sObject
     * @return List<sObject> - list of sobect with updated percent fields
     */
    private static List<sObject> percentageValueChange(
        List<String> percentFieldNames,
        Map<String, String> parametersMap
    ) {
        List<sObject> tempObjectList = new List<sObject>();
        for (
            sObject tempObject : DynamicQueryService.getRelatedRecordsWithOffSetInOrder(
                parametersMap,
                AccessLevel.SYSTEM_MODE
            )
        ) {
            for (String percentName : percentFieldNames) {
                //divide value by 100.
                //datatable renders percentage 20 -> 2000%
                //this logic will fix this
                if (tempObject.get(percentName) != null) {
                    tempObject.put(percentName, (decimal) tempObject.get(percentName) / 100);
                }
            }
            tempObjectList.add(tempObject);
        }

        return tempObjectList;
    }

    private class DataTableColumns {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public boolean sortable { get; set; }
        @AuraEnabled
        public DataTableTypeAttributes typeAttributes { get; set; }

        private DataTableColumns(String label, String fieldName, String type) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.sortable = true;
            this.typeAttributes = new DataTableTypeAttributes(type, fieldName);

            if (type == 'url' && fieldName == 'Name') {
                this.fieldName = 'IdUrl';
            } else if (type == 'url' && fieldName.contains('.Name')) {
                this.fieldName = fieldName.substringBefore('.Name') + '.' + 'IdUrl';
            }
        }
    }

    private class DataTableTypeAttributes {
        @AuraEnabled
        public DataTableLabel label { get; set; }
        @AuraEnabled
        public DataTableToolTip tooltip { get; set; }
        @AuraEnabled
        public String day { get; set; }
        @AuraEnabled
        public String month { get; set; }
        @AuraEnabled
        public String year { get; set; }

        private DataTableTypeAttributes(String type, String label) {
            if (type == 'url') {
                this.label = new DataTableLabel(label);
                this.tooltip = new DataTableTooltip(label);
            } else if (type == 'date') {
                this.day = 'numeric';
                this.month = 'numeric';
                this.year = 'numeric';
            }
        }
    }

    private class DataTableLabel {
        @AuraEnabled
        public String fieldName { get; set; }

        private DataTableLabel(String urlLabel) {
            this.fieldName = urlLabel;
        }
    }

    private class DataTableTooltip {
        @AuraEnabled
        public String fieldName { get; set; }

        private DataTableTooltip(String tooltip) {
            this.fieldName = tooltip;
        }
    }

    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> dataTableColumns { get; set; }
        @AuraEnabled
        public List<sObject> dataTableData { get; set; }
        @AuraEnabled
        public List<sObject> userAccessTable { get; set; }
        @AuraEnabled
        public Integer recordCount { get; set; }
        @AuraEnabled
        public boolean hasAcessByUser { get; set; }
        @AuraEnabled
        public boolean hasAccessByParent { get; set; }
    }
}
