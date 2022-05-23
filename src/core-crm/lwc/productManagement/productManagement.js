/**
 * @description A custom LWC for the Product Management tab of OPE Product Requests
 *
 * @author Accenture
 *       
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | February 3, 2022      | DEPP-1257           | Created file                                           |
      | arsenio.jr.dayrit         | February 14, 2021     | DEPP-1947           | Added Content Section                                  |
      | roy.nino.s.regala         | May 23, 2021          | DEPP-2663           | Added logic to control editing of decomission section  |
*/
import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import RT_ProductRequest_Program from '@salesforce/label/c.RT_ProductRequest_Program';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import PL_ProductRequest_Completed from '@salesforce/label/c.PL_ProductRequest_Completed';
import PL_ProgramPlan_PrescribedProgram from '@salesforce/label/c.PL_ProgramPlan_PrescribedProgram';
import PR_RECORD_TYPE from '@salesforce/schema/Product_Request__c.RecordType.DeveloperName';
import PR_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c';
import PR_PROGRAM_TYPE from '@salesforce/schema/Product_Request__c.OPE_Program_Plan_Type__c';
import checkParentProgramType from '@salesforce/apex/ProductManagementCtrl.checkParentProgramType';
import checkAvailableOnCart from '@salesforce/apex/ProductManagementCtrl.checkAvailableOnCart';

export default class ProductManagement extends LightningElement {
    @api recordId;
    @api objectApiName;
    
    isPrescribedOrNonProgram = false;
    parentIsPrescribed = false;
    isStatusCompleted = false;
    isAvailbleOnCart = false;
    isProgram;

    //decides if user has access to this feature
    get hasAccess(){
        return HAS_PERMISSION;
    }

    //decides if user should see pricing options
    get showPricingAndCommunication(){
        return this.parentIsPrescribed && this.isPrescribedOrNonProgram;
    }

    //decides to show edit buttons
    get showEditButton(){
        return !this.isStatusCompleted;
    }

    get showEditButtonForDecomission(){
        return !this.isStatusCompleted && this.isAvailbleOnCart;
    }

    //checks if product request is program and hides content section if true
    get hideContentSection(){
        return this.isProgram === RT_ProductRequest_Program;  
    }

    //checks if parent is prescribed and hides decommission section if true
    get hideDecommission(){
        return this.parentIsPrescribed;
    }

    //hides payment options, financial split, set-up certificate, and set-up registration
    //sections if product is prescribed, non program, or the parent is prescribed
    get hideSection(){
        return this.isPrescribedOrNonProgram && this.parentIsPrescribed;
    }

    /**
     * gets product request details
    */
    @wire(getRecord, {recordId: "$recordId",fields: [PR_RECORD_TYPE,PR_STATUS,PR_PROGRAM_TYPE]})
    productRequestRecordResult(result)
    {
        if(result.data){
            this.isProgram =  getFieldValue(result.data, PR_RECORD_TYPE);
            this.isStatusCompleted =  getFieldValue(result.data, PR_STATUS) == PL_ProductRequest_Completed;
            this.isPrescribedOrNonProgram = 
                getFieldValue(result.data, PR_PROGRAM_TYPE) == PL_ProgramPlan_PrescribedProgram ||
                getFieldValue(result.data, PR_PROGRAM_TYPE) == null; //for non-Program record types
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    /**
     * checks if parent is prescribed via apex call
     */
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
     * checks if related product is available on cart
     */
     availableOnCart
     @wire(checkAvailableOnCart,{productRequestId: '$recordId'})
     checkAvailableOnCart(result){
         if(result.data != undefined)
         {
             this.isAvailbleOnCart = result.data;
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
    
}