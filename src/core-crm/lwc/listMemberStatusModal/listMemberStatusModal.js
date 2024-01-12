import { LightningElement, wire } from 'lwc';
import { getPicklistValues, getObjectInfo} from "lightning/uiObjectInfoApi";
import LightningModal from 'lightning/modal'
import List_Member_OBJECT from '@salesforce/schema/List_Member__c';
 
import List_Member_Status_FIELD from '@salesforce/schema/List_Member__c.List_Member_Status__c';


export default class ListMemberStatusModal extends LightningModal {
    statusOptions;
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
            console.log(this.statusOptions);
            this.error = undefined;
        }
        if(error) {
            this.error = error;
            this.statusOptions = undefined;
        }
    }

    
    
    // = [
    //     { value: 'new', label: 'New', description: 'A new item' },
    //     {
    //         value: 'in-progress',
    //         label: 'In Progress',
    //         description: 'Currently working on this item',
    //     },
    //     {
    //         value: 'finished',
    //         label: 'Finished',
    //         description: 'Done working on this item',
    //     },
    // ];

    value = 'new';
    handleClose(){
        this.close('Close');
    }
    handleChange(event) {
        // Get the string of the "value" attribute on the selected option
        this.value = event.detail.value;
    }
}