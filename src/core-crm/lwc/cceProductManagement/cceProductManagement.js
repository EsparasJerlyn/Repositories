/**
 * @description A custom LWC for the Product Management tab of Standing Offer and Corporate Bundle Product Requests
 *
 * @author Accenture
 *       
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | roy.nino.s.regala         | May 23, 2021          | DEPP-2498           | created file                                           |

*/
import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import PL_ProductRequest_Completed from '@salesforce/label/c.PL_ProductRequest_Completed';
import PR_RECORD_TYPE from '@salesforce/schema/Product_Request__c.RecordType.DeveloperName';
import PR_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c';
import PR_PROGRAM_TYPE from '@salesforce/schema/Product_Request__c.OPE_Program_Plan_Type__c';


const CHILD_OBJECT = {
    Standing_Offer_Arrangement:
    {
        childObject: 'BuyerGroup',
        parentObject: 'Product_Request__c',
        parentField: 'Product_Request__c'
    },
    Corporate_Bundle:
    {
        childObject: 'Asset',
        parentObject: 'Product_Request__c',
        parentField: 'Product_Request__c'
    }
}

export default class CceProductManagement extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api tab;
    
    isStatusCompleted = false;
    recordType = '';
    sectionObject = {};


    //decides if user has access to this feature
    get hasAccess(){
        return HAS_PERMISSION;
    }

    //decides to show edit buttons
    get showEditButton(){
        return !this.isStatusCompleted;
    }

    /**
     * gets product request details
    */
    @wire(getRecord, {recordId: "$recordId",fields: [PR_RECORD_TYPE,PR_STATUS,PR_PROGRAM_TYPE]})
    productRequestRecordResult(result)
    {
        if(result.data){
            this.recordType =  getFieldValue(result.data, PR_RECORD_TYPE);
            this.sectionObject = CHILD_OBJECT[this.recordType]?CHILD_OBJECT[this.recordType]:{};
            this.isStatusCompleted =  getFieldValue(result.data, PR_STATUS) == PL_ProductRequest_Completed;
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    } 

    handleTableSave(){
        if(this.template.querySelector(`[data-id="creditDetails"]`)){
            this.template.querySelector('[data-id="creditDetails"]').updateSectionRecord();
        }
        
    }

    /**
     * creates toast notification
     */
     generateToast(_title,_message,_variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }

    get isCorporateBundle(){
        return this.recordType === 'Corporate_Bundle'?true:false;
    }
    
}