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
     * relatedRecord - object api name of the records to be queried(e.g. Contact)
     * relatedField - field api name of the lookup field(e.g. AccountId)
     * relatedListFields - JSON string that gives info on what the table should look like (e.g.[{"label":"Name","fieldName":"Name","type":"text"}])
     * relatedListFilters - the where clause of the query(e.g. AND RecordType.DeveloperName = 'Person')
     * rowOffSet - the offset of the query(e.g. 0)
     * rowLimit - the limit of the query(e.g. 10)
     * sortOrder - the order of the query for sort(e.g. DESC)
     * sortField - the field used to order the query for sort(e.g. CreatedDate)
     *
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
            tempDataColumns.add(datacolumns);
            columnCount++;
        }

        relatedFieldApiNames = relatedFieldApiNames.removeEnd(',');

        //finalize query parameters
        Map<String, String> parametersMap = new Map<String, String>();
        parametersMap.putAll(tableWrapperParams);
        parametersMap.put('relatedFieldApiNames', relatedFieldApiNames);

        //finalize datatable return
        DataTableResponse finalWrapper = new DataTableResponse();
        finalWrapper.dataTableColumns = tempDataColumns;
        finalWrapper.dataTableData = DynamicQueryService.getRelatedRecordsWithOffSetInOrder(
            parametersMap
        );
        finalWrapper.recordCount = DynamicQueryService.getRelatedRecordsCountWithFilter(
            parametersMap
        );

        return finalWrapper;
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
            //assumption is that the first column is the record's name field which is a link to the record
            if (columnCount == 0) {
                this.fieldName = 'IdUrl';
                //assumption is that this is a parent object's name field which is a link to the parents record
            } else if (typeAttribute.label.fieldName.contains('.')) {
                this.fieldName = typeAttribute.label.fieldName.substringBefore('.') + '.' + 'IdUrl';
            } else {
                this.fieldName = typeAttribute.label.fieldName + 'Url';
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
    }
}
