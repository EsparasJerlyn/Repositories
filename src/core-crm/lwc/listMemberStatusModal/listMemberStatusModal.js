/**
 * @description Modal for Bulk Change Status button for list members
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                            |
      |---------------------------|-----------------------|----------------------|-------------------------------------------|
      | kenneth.f.alsay           | January 12, 2024      | DEPP-6964            | Created file                              |
      | kenneth.f.alsay           | February 7, 2024      | DEPP-6953            | Added logic for Engage Tab                |
 */
import { LightningElement, wire, api} from 'lwc';
import { getPicklistValues, getObjectInfo} from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import List_Member_OBJECT from '@salesforce/schema/List_Member__c';
import List_Member_Status_FIELD from '@salesforce/schema/List_Member__c.List_Member_Status__c';
import List_Member_Activity_Status_FIELD from '@salesforce/schema/List_Member__c.Activity_Status__c';
import updateListMembers from '@salesforce/apex/ListMemberCtrl.updateListMemberStatus';

export default class ListMemberStatusModal extends LightningElement {
    @api itemsSelected;
    @api isShowModal;
    @api engageTab; 

    statusOptions;
    activityStatusOptions;
    listMemberStatusPicklist;
    activityStatusPicklist;
    value;

    @wire(getObjectInfo, { objectApiName: List_Member_OBJECT })
    listMemberMetadata;
    
    @wire(getPicklistValues,
        {
            recordTypeId: '$listMemberMetadata.data.defaultRecordTypeId',
            fieldApiName: List_Member_Status_FIELD
        }
    )
    listMemberStatusPicklist({data, error}){
        if (!this.engageTab && data) {
            this.statusOptions = data.values;
            this.error = undefined;
        }
        if (error) {
            this.error = error;
            this.statusOptions = undefined;
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$listMemberMetadata.data.defaultRecordTypeId',
            fieldApiName: List_Member_Activity_Status_FIELD
        }
    )
    activityStatusPicklist({data, error}){
        if (data) {
            this.activityStatusOptions = data.values;
            this.error = undefined;
        }
        if (error) {
            this.error = error;
            this.statusOptions = undefined;
        }
    }

    handleCancel(){
        this.dispatchEvent(new CustomEvent('setshowmodal', {
            detail: false
        }));
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    handleSave(){
        updateListMembers({listMembers: JSON.parse(JSON.stringify(this.itemsSelected)), status: this.value, isEngage: this.engageTab})
        .then((result) => {
            this.generateToast('Success', 'List Member(s) updated succesfully!', 'success');

            this.dispatchEvent(new CustomEvent('handlerefresh', {
                detail: true
            }));

            this.error = undefined;
            this.dispatchEvent(new CustomEvent('setshowmodal', {
                detail: false
            }));
        })
        .catch(error => {
            this.error = error;
            console.log("Error in Save call back:", this.error);
        });
    }

    generateToast(_title, _message, _variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }
}