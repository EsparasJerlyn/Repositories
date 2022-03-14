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
    
}