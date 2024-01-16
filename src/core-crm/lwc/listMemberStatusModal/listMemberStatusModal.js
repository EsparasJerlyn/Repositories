/**
 * @description Modal for Bulk Change Status button for list members
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                            |
      |---------------------------|-----------------------|----------------------|-------------------------------------------|
      | kenneth.f.alsay           | January 12, 2024      | DEPP-6964            | Created file                              |  
      |                           |                       |                      |                                           | 
 */
import { LightningElement, wire, api} from 'lwc';
import { getPicklistValues, getObjectInfo} from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import List_Member_OBJECT from '@salesforce/schema/List_Member__c';
import List_Member_Status_FIELD from '@salesforce/schema/List_Member__c.List_Member_Status__c';
import updateListMembers from '@salesforce/apex/ListMemberStatusModalCtrl.updateListMemberStatus';
export default class ListMemberStatusModal extends LightningElement {
    statusOptions;
    value;
    @wire(getObjectInfo, { objectApiName: List_Member_OBJECT })
    listMemberMetadata;
    @api itemsSelected;
    @api isShowModal;
    @wire(getPicklistValues,
        {
            recordTypeId: '$listMemberMetadata.data.defaultRecordTypeId', 
            fieldApiName: List_Member_Status_FIELD
        } 
    )
    listMemberStatusPicklist({data, error}){
        if(data) {
            this.statusOptions = data.values;
            this.error = undefined;
        }
        if(error) {
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
        updateListMembers({listMembers: JSON.parse(JSON.stringify(this.itemsSelected)), status: this.value})
        .then((result) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message : `List Member(s) updated succesfully!`,
                    variant : 'success',
                }),
             );
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
}