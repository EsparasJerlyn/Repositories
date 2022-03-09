/**
 * @description A custom LWC richText column used in datatable
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

export default class CustomRichtextColumn extends LightningElement {
    @api rowDraftId;

    @api
    get richtextValue() {
        return this._richtextValue;
    }
    set richtextValue(value) {
        this.setAttribute('richtextValue', value);
        this._richtextValue = value;
        this.richtextValueCopy = value;
    }

    @track _richtextValue;
    @track richtextValueCopy;
    showRichtext = false;

    handleRichtextChange(event){
        this.richtextValueCopy = event.detail.value;
    }

    handleConfirm(){
       this.showRichtext = false;
        if(this.richtextValue !== this.richtextValueCopy){
            this.dispatchEvent(new CustomEvent('richtextedit', {
                composed: true,
                bubbles: true,
                cancelable: true,
                detail: {
                    value : this.richtextValueCopy,
                    draftId : this.rowDraftId
                }
            }));
        }
    }

    handleCancel(){
        this.showRichtext = false;
    }

    handleEdit(){
        this.showRichtext = true;
    }
    
}