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
      | eccarius.karl.munoz       | June 28, 2022         | DEPP-3272            | Added handling to display    |
      |                           |                       |                      | error message on course      |
      |                           |                       |                      | or program code duplicates   |
      |                           |                       |                      |                              |
 */

import { api, LightningElement, wire } from 'lwc';
import { getRecordNotifyChange, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCourseAndProgDetails from '@salesforce/apex/GenerateCodeCtrl.getCourseAndProgDetails';
import updateCodeGenerator from '@salesforce/apex/GenerateCodeCtrl.updateCodeGenerator';
import generateCode from '@salesforce/apex/GenerateCodeCtrl.generateCode';
import getDuplicateDetails from '@salesforce/apex/GenerateCodeCtrl.getDuplicateDetails';
import PROGRAM_RT from '@salesforce/label/c.RT_ProductRequest_Program';
import PWP_RT from '@salesforce/label/c.RT_ProductRequest_Program_Without_Pathway';

const SUCCESS_MSG = 'Code successfully generated!';     
const SUCCESS_TITLE = 'Success!';
const ERROR_TITLE = 'Error!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';
const ERROR_MSG = 'Failed to generate code.';

const DUP_ERR_CODE = 'DUPLICATES_DETECTED';

export default class GenerateCode extends LightningElement {

    @api recordId;

    isLoading = false;
    isDisable = false;
    displayDuplicateError = false;

    duplicateErrorMessage;
    duplicateCodeProdReqId;
    duplicateCodeProdReqName;
    duplicateCodeCourseProgName;

    courseAndProgDtls;
    @wire(getCourseAndProgDetails, {recordId : '$recordId'})
    getCourseAndProgDetails(result) {
        if(result.data){
            this.courseAndProgDtls = result.data;
            if(this.courseAndProgDtls.recordCode){
                this.isDisable = true;
            }
        }        
    }
    
    handleGenerateCode(){ 
        this.isLoading = true;       
        generateCode({'recordType' : this.courseAndProgDtls.recordType, 'prodSpecsRecordType' : this.courseAndProgDtls.productSpecsRT}).then(result => {
            this.isDisable = true;                  
            let fields = {};   
            if(this.courseAndProgDtls.recordType == PROGRAM_RT ||
                this.courseAndProgDtls.recordType == PWP_RT
            ){
                fields = {
                    Id : this.courseAndProgDtls.recordId,
                    Code__c : result.recordCode
                };
            }else{
         
                fields = {
                    Id : this.courseAndProgDtls.recordId,
                    Course_Code__c : result.recordCode
                };
            }
            const recordInput = { fields };
            updateRecord(recordInput)
            .then(() => {  
                updateCodeGenerator({
                    'recordType'    : this.courseAndProgDtls.recordType,
                    'recordId'      : result.recordId,
                    'recordNumber'  : result.recordNumber,
                    'recordCode'  : result.recordCode,
                    'prodSpecsRecordType' : this.courseAndProgDtls.productSpecsRT
                }).then(result => {
                    if(result === 'Success'){
                        this.displayDuplicateError = false;
                        this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);
                    }
                }).catch(error => {
                    this.generateToast(ERROR_TITLE, ERROR_MSG, ERROR_VARIANT);
                    console.error('Error in updating custom settings: ' + JSON.stringify(error));
                })
            })
            .catch(error => {
                this.isDisable = false;
                this.generateToast(ERROR_TITLE, ERROR_MSG, ERROR_VARIANT);
               
                let errCode = '';
                let errMsg = '';
                let errorList = [];
                errorList = error.body.output.errors;
                 
                if(errorList.length > 0){
                    errorList.forEach(err => {
                        errCode = err.errorCode;
                        errMsg = err.message;
                    });
                }
                
                if(DUP_ERR_CODE === errCode){
                    getDuplicateDetails({
                        'recordCode'  : result.recordCode,
                        'recordType'  : this.courseAndProgDtls.recordType
                    }).then(res=>{
                        this.duplicateCodeProdReqId = res.recordProdReqId;
                        this.duplicateCodeProdReqName = res.recordProdReqName;
                        this.duplicateCodeCourseProgName = res.recordProgCourseName;
                    }).catch(error=>{
                        console.error('Error: ' + JSON.stringify(error));
                    });
                    this.displayDuplicateError = true;
                    this.duplicateErrorMessage = 'Code already exist for [';
                }else{
                    this.displayDuplicateError = false;
                }
                console.error('Error in course update: ' + JSON.stringify(error));

            });
        }).catch(error => {
            this.isDisable = false;
            this.generateToast(ERROR_TITLE, ERROR_MSG, ERROR_VARIANT);
            console.error('Error in code generation: ' + JSON.stringify(error));           
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

    get dupErrorMessage(){ return this.duplicateErrorMessage; }
    get getProductRequestName() { return this.duplicateCodeProdReqName; }
    get getProgCourseName() { return this.duplicateCodeCourseProgName; }
    get getProdUrl() { return '/' + this.duplicateCodeProdReqId }

}