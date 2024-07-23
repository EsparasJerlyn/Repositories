/**
 * @description LWC that handles the display of record sibling of the dynamicdatatable
 * @see ../lwc/dynamicDataTableSiblingDisplay
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
 *    |---------------------------|-----------------------|----------------------|----------------------------------------------|
 *    | nicole.genon              | May 8, 2023           | DEPP-8163            | Created file                                 |
 */
import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from 'lightning/uiRecordApi';

export default class DynamicDataTableSiblingDisplay extends NavigationMixin(
    LightningElement
) {

  @api recordId;
  @api lookupId;
  @api icon;
  @api relatedListLabel;
  @api parentRecord;
  @api relatedRecord;
  @api siblingLookupField;
  @api lookupField;
  @api relatedListFields;
  @api relatedListFilters;
  @api sortOrder;
  @api sortField;
  @api objectApiName;

  get reactiveParentId(){
    return [this.objectApiName + '.' + this.lookupField];
  }

  get hasLookupId(){ 
    return (this.lookupId)? true : false;
  }

  @wire(getRecord,{recordId: '$recordId', fields: '$reactiveParentId'})
    wiredRecord({ error, data }){
      if (error) {
        NebulaLoggerService.logExceptionDetails('Exception caught in wiredRecord dynamicDataTableSiblingDisplay.js',error);
      } else if (data) {
          this.lookupId = data.fields[this.lookupField].value;
      }
  }

}