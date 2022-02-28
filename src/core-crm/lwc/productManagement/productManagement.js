/**
 * @description A custom LWC for the Product Management tab of OPE Product Requests
 *
 * @author Accenture
 *       
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | February 3, 2022      | DEPP-1257           | Created file                                           |
      |                           |                       |                     |                                                        |
*/
import { LightningElement, api, wire} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import PR_PARENT_TYPE from '@salesforce/schema/Product_Request__c.Parent_Product_Request__r.OPE_Program_Plan_Type__c';

const PRESCRIBED_PROGRAM = 'Prescribed Program';
export default class ProductManagement extends LightningElement {
    @api recordId;
    @api objectApiName;

    //decides if user has access to this feature
    get hasAccess(){
        return HAS_PERMISSION;
    }

    //decides if user should see pricing options
    get showSection(){
        if(this.productRequest){
            return getFieldValue(this.productRequest.data,PR_PARENT_TYPE) !== PRESCRIBED_PROGRAM;
        }
        return false;
    }

    //gets product request details
    @wire(getRecord, { recordId: '$recordId', fields: [PR_PARENT_TYPE] })
    productRequest;
}