/**
 * @description A custom LWC for custom datatable with custom columns
 *
 * @author Accenture
 *       
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                              |
      |---------------------------|-----------------------|---------------------|---------------------------------------------|
      | roy.nino.s.regala         | February 20, 2022     | DEPP-1773,1406,1257 | Created file                                |
      | angelika.j.s.galang       | March 3, 2022         | DEPP-1257,1831      | Modified to handle custom lookup, richtext, |
      |                           |                       |                     | picklist, and datetime columns              |
*/
import LightningDatatable from 'lightning/datatable';
import customSearch from './customSearch.html';
import customLookupColumn from './customLookupColumn';
import customPicklistColumn from './customPicklistColumn';
import customDatetimeColumn from './customDatetimeColumn';
import customRichtextColumn from './customRichtextColumn';

export default class CustomDatatableColumned extends LightningDatatable {
    static customTypes = { 
        customSearch : {
            template: customSearch,
            typeAttributes: [
                'icon',
                'parentId',
                'placeholder',
                'lookupItems',
                'itemServerName',
                'itemId',
                'objectLabelName',
                'newRecordAvailable',
                'showEditButton',
                'editable'
            ],
        },
        customLookupColumn: {
            template: customLookupColumn,
            typeAttributes: [
                'tableObjectType',
                'rowDraftId', 
                'rowRecordId',
                'lookupValue',
                'lookupFieldName',
                'lookupValueFieldName',
                'editable'
            ]
        },
        customPicklistColumn: {
            template: customPicklistColumn,
            typeAttributes: [
                'tableObjectType',
                'rowDraftId', 
                'picklistValue',
                'picklistFieldName',
                'editable'
            ]
        },
        customDatetimeColumn: {
            template: customDatetimeColumn,
            typeAttributes: [
                'tableObjectType',
                'rowDraftId', 
                'datetimeValue',
                'datetimeFieldName',
                'editable'
            ]
        },
        customRichtextColumn: {
            template: customRichtextColumn,
            typeAttributes: [
                'rowDraftId', 
                'richtextValue',
                'editable'
            ]
        }
    }
}