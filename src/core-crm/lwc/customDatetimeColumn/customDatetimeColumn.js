/**
 * @description A custom LWC datetime column used in datatable
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

const DATETIME_OPTIONS = { 
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour:'2-digit',
    minute:'2-digit'
};
export default class CustomDatetimeColumn extends LightningElement {
    @api tableObjectType;
    @api rowDraftId;
    @api datetimeFieldName;
    @api editable;

    @api
    get datetimeValue() {
        return this._datetimeValue;
    }
    set datetimeValue(value) {
        this.setAttribute('datetimeValue', value);
        this._datetimeValue = value;
        this.datetimeValueCopy = value;
    }

    @track _datetimeValue;
    @track datetimeValueCopy;
    showDatetime = false;

    get datetimeValueFormatted(){
        if(this.datetimeValueCopy){
            const newDate = new Date(this.datetimeValueCopy);
            newDate.setHours(newDate.getHours());
            return newDate.toLocaleDateString('en-AU',DATETIME_OPTIONS);
        }
        return;
    }

    get showErrorMessage(){
        return !this.datetimeValueCopy;
    }

    handleDatetimeChange(event){
        this.datetimeValueCopy = event.detail.value;
    }

    handleEdit(){
        this.showDatetime = true;
    }

    handleConfirm(){
        this.showDatetime = false;
        if(this.datetimeValue !== this.datetimeValueCopy){
            this.dispatchEvent(new CustomEvent('datetimeedit', {
                composed: true,
                bubbles: true,
                cancelable: true,
                detail: {
                    value : this.datetimeValueCopy,
                    draftId : this.rowDraftId,
                    fieldName: this.datetimeFieldName
                }
            }));
        }
    }

    handleCancel(){
        this.datetimeValueCopy = this.datetimeValue;
        this.showDatetime = false;
    }
}