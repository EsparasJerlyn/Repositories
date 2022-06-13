/**
 * @description Lightning Web Component for list of registered learners
 * 
 * @see ../classes/RegisteredLearnersCtrl.cls
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | adrian.c.habasa           | March 24, 2022        | DEPP-1481           | Created file                 | 
      |                           |                       |                      |                              | 
 */
import { LightningElement,api,wire } from 'lwc';
import getRegisteredLearners from '@salesforce/apex/RegisteredLearnersCtrl.getRegisteredLearners';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';

const ERROR_TITLE = 'Error!';
const ERROR_VARIANT = 'error';

export default class RegisteredLearnerRelatedList extends LightningElement {

    @api recordId;
    columns = [
        { label: 'First Name', fieldName: 'firstName', type: 'text', sortable: true },
        { label: 'Last Name', fieldName: 'lastName', type: 'text', sortable: true },
        { label: 'Company', fieldName: 'companyName', type: 'text', sortable: true },
        { label: 'Position', fieldName: 'positionName', type: 'text', sortable: true }       
    ];
    learnerData=[];
    noRegisteredLearner;
    isLoading=true;

    listOfRecords;
    @wire(getRegisteredLearners,{offeringId:'$recordId'})
    relatedRecord(result)
    {   
        if(result.data)
        {
            this.learnerData = result.data;
            this.noRegisteredLearner = this.learnerData.length === 0?true:false;
            this.isLoading=false;
        }
        else if(result.error)
        {
            this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
            this.isLoading=false;
        }
        
    }

    /*
    *generates toasts
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