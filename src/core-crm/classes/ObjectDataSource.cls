/**
 * @description Picklist value for dynamicRecordEditForm input in flexipage
 * @see ../lwc/dynamicRecordEditForm
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | kim.howard.capanas             | March 18, 2024        | DEP1-8203              | Created file                 |
 */
global with sharing class ObjectDataSource extends VisualEditor.DynamicPickList {

    /**
     * @description Logic for generating picklist values
     * @return myValues - default picklist values
     */
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('1', '1');
        return defaultValue;
    }

    /**
     * @description Logic for generating picklist values
     * @return myValues - picklist values of 1 and 2.
     */
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DataRow value1 = new VisualEditor.DataRow('1', '1');
        VisualEditor.DataRow value2 = new VisualEditor.DataRow('2', '2');
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();

        myValues.addRow(value1);
        myValues.addRow(value2);
        return myValues;
    }
}