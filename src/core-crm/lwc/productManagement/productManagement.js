/**
 * @description A custom LWC for the Product Management tab of OPE Product Requests
 *
 * @author Accenture
 *       
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | February 3, 2022      | DEPP-1257           | Created file                                           |
      | arsenio.jr.dayrit         | February 14, 2021     | DEPP-1947           | Added Content Section                                                       |
*/
import { LightningElement, api, wire} from 'lwc';
import{getRecord, getFieldValue} from "lightning/uiRecordApi";
import RECORD_TYPE from '@salesforce/schema/Product_Request__c.RecordType.DeveloperName';
import PR_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c';
import RT_ProductRequest_Program from '@salesforce/label/c.RT_ProductRequest_Program';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import checkParentProgramType from '@salesforce/apex/ProductManagementCtrl.checkParentProgramType';

export default class ProductManagement extends LightningElement {
    @api recordId;
    @api objectApiName;
    
    parentIsPrescribed = false;
    //decides if user has access to this feature
    get hasAccess(){
        return HAS_PERMISSION;
    }

    //decides if user should see pricing options
    get showSection(){
        return this.parentIsPrescribed;
    }

    parentProgramType
    @wire(checkParentProgramType,{productRequestId: '$recordId'})
    checkParentProgramType(result){
        if(result.data != undefined)
        {
            this.parentIsPrescribed = result.data;
        }
        else if(result.error)
        {  
            this.generateToast('Error!',LWC_Error_General,'error');
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
    isStatusCompleted
    isProgram;
    @wire(getRecord, {recordId: "$recordId",fields: [RECORD_TYPE,PR_STATUS]})
    productRequestRecordResult(result)
    {
        if(result.data){
            this.isProgram =  getFieldValue(result.data, RECORD_TYPE);
            this.isStatusCompleted =  getFieldValue(result.data, PR_STATUS);
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    isProgramRt = true;
    isCompleted = true;
    get HideContentSection(){
        
           if(this.isProgram === RT_ProductRequest_Program){
               return this.isProgramRt;
           }else if(this.isStatusCompleted === 'Completed'){
               return this.isCompleted;
           }
    }
    
}