/**
 * @description A custom LWC lookup column of datatable
 *
 * @author Accenture
 *       
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | February 3, 2022      | DEPP-1257           | Created file                                           |
      |                           |                       |                     |                                                        |
*/
import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

export default class CustomLookupColumn extends LightningElement {
    @api tableObjectType;
    @api rowDraftId;
    @api rowRecordId;
    @api lookupValue;
    @api lookupValueFieldName;
    @api lookupFieldName;
    @api editable;

    showLookup = false;
    lookupValueName;

    get lookupUrl(){
        return this.lookupValue ? '/' + this.lookupValue : '';
    }

    renderedCallback() {
        if (!this.guid) {
            this.guid = this.template.querySelector('.lookupBlock').getAttribute('id');
            /* Register the event with this component as event payload. 
            Used to identify the window click event and if click is outside the current context of lookup, 
            set the dom to show the text and not the combobox */
            this.dispatchEvent(
                new CustomEvent('itemregister', {
                    bubbles: true,
                    composed: true,
                    detail: {
                        callbacks: {
                            reset: this.reset
                        },
                        template: this.template,
                        guid: this.guid,
                        name: 'c-custom-lookup-column'
                    }
                })
            );
        }
    }

    //show lookup if window click is on the same context, set to text view if outside the context
    reset = (rowRecordId) => {
        if (this.rowRecordId !== rowRecordId) {
            this.showLookup = false;
        }
    }

    @wire(getRecord, { recordId: '$lookupValue', fields: '$lookupValueFieldName' })
    handleRecord(result){
        if(result.data){
            this.lookupValueName = getFieldValue(result.data,this.lookupValueFieldName[0]);
            this.dispatchCustomEvent('nameupdate',this.lookupValueName);
        }
    };

    handleLookupChange(event){
        event.preventDefault();
        this.lookupValue = event.detail.value[0];
        this.showLookup = this.lookupValue ? false : true;
        this.dispatchCustomEvent('lookupselect',this.lookupValue);
    }

    handleEdit(event){
        event.preventDefault();
        event.stopPropagation();
        this.lookupValue = undefined;
        this.showLookup = true;
        this.dispatchCustomEvent('lookupselect',this.lookupValue);
    }

    dispatchCustomEvent(eventName,value){
        this.dispatchEvent(new CustomEvent(eventName, {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                value : value,
                draftId : this.rowDraftId,
                recordId : this.rowRecordId
            }
        }));
    }
}