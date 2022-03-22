/**
 * @description A custom LWC picklist column used in datatable
 *
 * @author Accenture
 *       
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | March 3, 2022         | DEPP-1831           | Created file                                           |
      |                           |                       |                     |                                                        |
*/
import { LightningElement, api, track } from 'lwc';

export default class CustomPicklistColumn extends LightningElement {
    @api tableObjectType;
    @api rowDraftId;
    @api picklistValue;
    @api picklistFieldName;
    @api editable;

    showPicklist = false;

    handleEdit(){
        this.showPicklist = true;
    }

    handlePicklistChange(event){
        this.showPicklist = false;
        this.dispatchEvent(new CustomEvent('picklistselect', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                value : event.detail.value,
                draftId : this.rowDraftId
            }
        }));
        
    }
}