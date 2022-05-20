/**
 * @description Lightning Web Component for Generation of Code under OPE Product Request Design Tab
 * @see ../classes/GenerateCodeCtrl.cls
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | May 11, 2022          | DEPP-2336            | Created file                 |
      |                           |                       |                      |                              |
 */

import { api, LightningElement, wire } from 'lwc';
import { getRecordNotifyChange, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCourseAndProgDetails from '@salesforce/apex/GenerateCodeCtrl.getCourseAndProgDetails';
import generateCode from '@salesforce/apex/GenerateCodeCtrl.generateCode';
import PROGRAM_RT from '@salesforce/label/c.RT_ProductRequest_Program';

const SUCCESS_MSG = 'Code successfully generated!';
const SUCCESS_TITLE = 'Success!';
const ERROR_TITLE = 'Error!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';
const ERROR_MSG = 'Failed to generate code.';

export default class GenerateCode extends LightningElement {

    @api recordId;

    isLoading = false;
    isDisable = false;

    courseAndProgDtls;
    @wire(getCourseAndProgDetails, {recordId : '$recordId'})
    getCourseAndProgDetails(result) {
        if(result.data){
            this.courseAndProgDtls = result.data;
            console.log(JSON.stringify(result.data.recordCode));
            if(this.courseAndProgDtls.recordCode){
                this.isDisable = true;
            }
        }        
    }
    
    handleGenerateCode(){  
        this.isLoading = true;         
        generateCode({'recordType' : this.courseAndProgDtls.recordType}).then(result => { 
            this.isDisable = true;                  
            let fields = {};    
            if(this.courseAndProgDtls.recordType == PROGRAM_RT){
                fields = {
                    Id : this.courseAndProgDtls.recordId,
                    Code__c : result
                };
            }else{
                fields = {
                    Id : this.courseAndProgDtls.recordId,
                    Course_Code__c : result
                };
            }
            const recordInput = { fields };            
            updateRecord(recordInput)
            .then(() => {                    
                this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);                            
            })
            .catch(error => {
                this.isDisable = false;
                this.generateToast(ERROR_TITLE, ERROR_MSG, ERROR_VARIANT);
                console.error('Error: ' + JSON.stringify(error));
            });

        }).catch(error => {
            this.isDisable = false;
            this.generateToast(ERROR_TITLE, ERROR_MSG, ERROR_VARIANT);
            console.error('Error: ' + JSON.stringify(error));            
        }).finally(() => {   
            this.isLoading = false;                
            getRecordNotifyChange([{recordId: this.courseAndProgDtls.recordId}]);            
        });       
    }

    generateToast(_title, _message, _variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }
}