/**
 * @description A custom LWC for custom datatable of financial split
 *
 * @author Accenture
 *       
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | February 3, 2022      | DEPP-1257           | Created file                                           |
      |                           |                       |                     |                                                        |
*/
import LightningDatatable from 'lightning/datatable';
import customLookupColumn from './customLookupColumn';

export default class FinancialSplitDataTable extends LightningDatatable {
    static customTypes = {
        customLookupColumn: {
            template: customLookupColumn,
            typeAttributes: [
                'tableObjectType',
                'rowDraftId', 
                'rowRecordId',
                'lookupValue',
                'lookupValueFieldName',
                'lookupFieldName'
            ]
        }
    }
}