/**
 * @description A custom LWC time column used in datatable
 *
 * @author Accenture
 *       
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | March 3, 2022         | DEPP-1831           | Created file                                           |
      |                           |                       |                     |                                                        |
*/
import { LightningElement, api } from 'lwc';

const UTC_SEC_MILLI = ':00.000Z';
export default class CustomDatetimeColumn extends LightningElement {
    @api tableObjectType;
    @api rowDraftId;
    @api datetimeValue;
    @api datetimeFieldName;
    @api editable;

    showDatetime = false;

    get datetimeValueFormatted(){
        return this.formatTime(this.datetimeValue);
    }
    
    handleEdit(){
        this.showDatetime = true;
    }

    handleDatetimeChange(event){
        this.showDatetime = false;
        this.dispatchEvent(new CustomEvent('datetimeedit', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                value : this.convertTimeToMilliseconds(event.detail.value),
                draftId : this.rowDraftId,
                fieldName: this.datetimeFieldName
            }
        }));
    }

    formatTime(milli){
        let time = new Date(milli);
        let hrs = this.padTimePart(time.getUTCHours());
        let min = this.padTimePart(time.getUTCMinutes());
        return hrs + ":" + min + UTC_SEC_MILLI;
    }

    padTimePart(timePart){
        return ('00' + timePart).slice(-2);
    }

    convertTimeToMilliseconds(time){
        let timeParts = time.split(':');
        let hrs = parseInt(timeParts[0]) * 60 * 60;
        let min = parseInt(timeParts[1]) * 60;
        let sec = parseInt(timeParts[2].split('.')[0]);
        return ((hrs+min+sec)*1000);
    }
}