/**
 * @description Controller for dynamicDataTable.js
 * @see ../lwc/dynamicDataTable
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------|
 *    | roy.nino.s.regala              | June 14, 2023         | DEPP-5391              | Created file                   |
 *    | roy.nino.s.regala              | June 24, 2023         | DEPP-5411              | Added visibility check         |
 *    | roy.nino.s.regala              | July 11, 2023         | DEPP-5459              | added percent value change     |
 *    | roy.nino.s.regala              | July 11, 2023         | DEPP-5459              | fix url issue                  |
 */
public with sharing class DynamicDataTableCtrl { //NOPMD bypassed too many public methods
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

        List<DataTableColumns> parsedRelatedListFields = (List<DataTableColumns>) JSON.deserialize(
            relatedListFields,
            List<DataTableColumns>.class
        );
        List<String> percentFieldNames = new List<String>();
        List<DataTableColumns> tempDataColumns = new List<DataTableColumns>();
        Integer columnCount = 0;
        //build datatable columns
        for (DataTableColumns field : parsedRelatedListFields) {
            relatedFieldApiNames += field.fieldName + ',';

            DataTableColumns datacolumns = new DataTableColumns(
                field.label.trim(),
                field.fieldName.trim(),
                field.type.trim()
            );

            //add typeAttributes for URL fields
            if (field.type.trim() == 'url') {
                datacolumns = new DataTableColumns(
                    field.label.trim(),
                    columnCount,
                    new DataTableTypeAttributes(field.fieldName.trim())
                );
            }
            //collect percent fields
            if (field.type.trim() == 'percent') {
                percentFieldNames.add(field.fieldName);
            }

            tempDataColumns.add(datacolumns);
            columnCount++;
        }

        relatedFieldApiNames += ' UserRecordAccess.HasEditAccess';
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
                parametersMap
            );
        }

        finalWrapper.recordCount = DynamicQueryService.getRelatedRecordsCountWithFilter(
            parametersMap
        );
        finalWrapper.hasVisibility = true;

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
            finalWrapper.hasVisibility = getVisiblityCheckResult(tableWrapperParams);
        }

        return finalWrapper;
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
    private static boolean getVisiblityCheckResult(Map<String, String> paramsMap) {
        List<SObject> parentResult = new List<SObject>();
        List<SObject> userResult = new List<SObject>();
        boolean checkParentVisibility = false;
        boolean checkUserVisibility = false;
        Map<String, String> parametersMap = new Map<String, String>();

        if (!String.isBlank(paramsMap.get('visibilityByParent'))) {
            parametersMap.put('sObjectApiName', paramsMap.get('parentRecord'));
            parametersMap.put('recordId', paramsMap.get('recordId'));
            parametersMap.put('filter', paramsMap.get('visibilityByParent'));
            parentResult = DynamicQueryService.getRecordWithFilter(parametersMap);
            checkParentVisibility = true;
        }

        if (!String.isBlank(paramsMap.get('visibilityByUser'))) {
            parametersMap.put('sObjectApiName', 'User');
            parametersMap.put('recordId', String.escapeSingleQuotes(UserInfo.getUserId()));
            parametersMap.put('filter', paramsMap.get('visibilityByUser'));
            userResult = DynamicQueryService.getRecordWithFilter(parametersMap);
            checkUserVisibility = true;
        }

        if (
            (checkParentVisibility == true && parentResult.isEmpty()) ||
            (checkUserVisibility == true && userResult.isEmpty())
        ) {
            return false; //dont give visibility
        } else {
            return true; //give visibility
        }
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
                parametersMap
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
        @AuraEnabled
        public DataTableCellAttributes cellAttributes { get; set; }

        private DataTableColumns(String label, String fieldName, String type) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.sortable = true;
            this.cellAttributes = new DataTableCellAttributes('left');
        }

        private DataTableColumns(
            String label,
            Integer columnCount,
            DataTableTypeAttributes typeAttribute
        ) {
            this.label = label;
            //assumption is that the name field is always used as a link to the record
            if (typeAttribute.label.fieldName == 'Name') {
                this.fieldName = 'IdUrl';
            //assumption is that this is a parent object's name field which is a link to the parents record
            } else if (
                typeAttribute.label.fieldName.contains('.') &&
                typeAttribute.label.fieldName.substringAfter('.') == 'Name'
            ) {
                this.fieldName = typeAttribute.label.fieldName.substringBefore('.') + '.' + 'IdUrl';
            } else {
                this.fieldName = typeAttribute.label.fieldName;
            }
            this.type = 'url';
            this.typeAttributes = typeAttribute;
            this.sortable = true;
            this.cellAttributes = new DataTableCellAttributes('left');
        }
    }

    private class DataTableTypeAttributes {
        @AuraEnabled
        public DataTableLabel label { get; set; }

        private DataTableTypeAttributes(String urlLabel) {
            this.label = new DataTableLabel(urlLabel);
        }
    }

    private class DataTableLabel {
        @AuraEnabled
        public String fieldName { get; set; }

        private DataTableLabel(String urlLabel) {
            this.fieldName = urlLabel;
        }
    }

    private class DataTableCellAttributes {
        @AuraEnabled
        public String alignment { get; set; }

        private DataTableCellAttributes(String direction) {
            this.alignment = direction;
        }
    }

    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> dataTableColumns { get; set; }
        @AuraEnabled
        public List<sObject> dataTableData { get; set; }
        @AuraEnabled
        public Integer recordCount { get; set; }
        @AuraEnabled
        public boolean hasVisibility { get; set; }
    }
}
