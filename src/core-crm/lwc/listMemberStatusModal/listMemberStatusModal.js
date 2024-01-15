import { LightningElement, wire } from 'lwc';
import { getPicklistValues, getObjectInfo} from "lightning/uiObjectInfoApi";
import LightningModal from 'lightning/modal'
import List_Member_OBJECT from '@salesforce/schema/List_Member__c';
 
import List_Member_Status_FIELD from '@salesforce/schema/List_Member__c.List_Member_Status__c';


export default class ListMemberStatusModal extends LightningModal {
    statusOptions;
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
        if(data) {
            this.statusOptions = data.values;
            this.error = undefined;
        }
        if(error) {
            this.error = error;
            this.statusOptions = undefined;
        }
    }

    handleClose(){
        this.close(JSON.stringify({action: 'Close'}));
    }
    handleChange(event) {
        // Get the string of the "value" attribute on the selected option
        this.value = event.detail.value;
    }

    handleSave(){
        this.close(JSON.stringify({action: 'Save', data: this.value}));
    }
}