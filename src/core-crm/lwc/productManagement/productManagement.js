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
      | kathy.cornejo             | June 30, 2022         | DEPP-3343           | Updated logic for decomission section                  |
      | alexander.cadalin         | September 01, 2022    | DEPP-2253           | Included OPE PWP, hide content section when PR is PWP  |
      | kathy.cornejo             | September 09, 2022    | DEPP-4107           | Removed registration & application section for CCE     |                   |

*/
import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import RT_ProductRequest_Program from '@salesforce/label/c.RT_ProductRequest_Program';
import RT_ProductRequest_PWP from '@salesforce/label/c.RT_ProductRequest_Program_Without_Pathway';
import RT_PS_OPEPROGRAMSPEC from '@salesforce/label/c.RT_ProductSpecification_OPEProgramSpecification';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import PL_ProductRequest_Completed from '@salesforce/label/c.PL_ProductRequest_Completed';
import PL_ProgramPlan_PrescribedProgram from '@salesforce/label/c.PL_ProgramPlan_PrescribedProgram';
import PR_RECORD_TYPE from '@salesforce/schema/Product_Request__c.RecordType.DeveloperName';
import PR_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c';
import PR_PROGRAM_TYPE from '@salesforce/schema/Product_Request__c.OPE_Program_Plan_Type__c';
import PR_PS_RT_DEVNAME from '@salesforce/schema/Product_Request__c.Product_Specification__r.RecordType.DeveloperName';
import checkParentProgramType from '@salesforce/apex/ProductManagementCtrl.checkParentProgramType';
import checkParentIsSOA from '@salesforce/apex/ProductManagementCtrl.checkParentIsSOA';
import checkAvailableOnCart from '@salesforce/apex/ProductManagementCtrl.checkAvailableOnCart';

export default class ProductManagement extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api tab
    
    isAvailbleOnCart = false;
    isOPEProductRequest = false;
    isStatusCompleted = false;
    isPrescribedOrNonProgram = false;
    recordType = undefined;
    parentIsPrescribed = false;
    parentIsSOA = false;

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
        return !this.isStatusCompleted;
    }

    //checks if product request is not program or pwp and shows content section if true
    get showContentSection(){
        return !(this.recordType === RT_ProductRequest_Program || this.recordType === RT_ProductRequest_PWP); 
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

    //hides Set-up Registration and Application section for all CCE Product Request 
    get hideRegistrationAndApplication(){
        return this.isOPEProductRequest && this.isPrescribedOrNonProgram && this.parentIsPrescribed;
    }

    get showPricingandPayment() {
        return this.parentIsSOA || this.isOPEProductRequest;
    }
    
    /**
     * gets product request details
    */
    @wire(getRecord, {recordId: "$recordId",fields: [PR_RECORD_TYPE,PR_STATUS,PR_PROGRAM_TYPE,PR_PS_RT_DEVNAME]})
    productRequestRecordResult(result)
    {
        if(result.data){
            this.recordType = getFieldValue(result.data, PR_RECORD_TYPE);
            this.isStatusCompleted =  getFieldValue(result.data, PR_STATUS) == PL_ProductRequest_Completed;
            this.isPrescribedOrNonProgram = 
                getFieldValue(result.data, PR_PROGRAM_TYPE) == PL_ProgramPlan_PrescribedProgram ||
                getFieldValue(result.data, PR_PROGRAM_TYPE) == null; //for non-Program record types
            this.isOPEProductRequest = getFieldValue(result.data, PR_PS_RT_DEVNAME) == RT_PS_OPEPROGRAMSPEC;
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    /**
     * checks if parent is prescribed via apex call
     */
    parentProgramType;
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
     availableOnCart;
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
     * Check if the parent is a Standing Offer Arrangement 
     */
    parentSOAType;
    @wire(checkParentIsSOA, { productRequestId : '$recordId' })
    checkParentIsSOA(result) {
        if(result.data != undefined) {
            this.parentIsSOA = result.data;
        } else if(result.error) {
            this.generateToast('Error!', LWC_Error_General, 'error');
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