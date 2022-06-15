/**
 * @description A custom LWC for the Financial Split section of
 *              Product Management tab of OPE Product Requests
 *
 * @author Accenture
 *       
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | February 3, 2022      | DEPP-1257           | Created file                                           |
      | roy.nino.s.regala         | June 6 2022           | DEPP-3092           |  Updated default account, and logic                    |
*/
import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import RT_ProductRequest_Program from '@salesforce/label/c.RT_ProductRequest_Program';
import QUTeX from '@salesforce/label/c.QUT_GSB';
import COURSE_OBJ from '@salesforce/schema/hed__Course__c';
import C_PRODUCT_REQUEST from '@salesforce/schema/hed__Course__c.ProductRequestID__c';
import FS_COURSE from '@salesforce/schema/Financial_Split__c.Course__c';
import FS_PROGRAM_PLAN from '@salesforce/schema/Financial_Split__c.Program_Plan__c';
import PROGRAM_PLAN_OBJ from '@salesforce/schema/hed__Program_Plan__c';
import PP_PRODUCT_REQUEST from '@salesforce/schema/hed__Program_Plan__c.Product_Request__c';
import ACC_NAME from '@salesforce/schema/Account.Name';
import PR_RT_DEV_NAME from '@salesforce/schema/Product_Request__c.RecordType.DeveloperName';
import getQutexId from '@salesforce/apex/FinancialSplitCtrl.getQutexId';
import getParentId from '@salesforce/apex/FinancialSplitCtrl.getParentId';
import getFinancialSplits from '@salesforce/apex/FinancialSplitCtrl.getFinancialSplits';
import upsertFinancialSplits from '@salesforce/apex/FinancialSplitCtrl.upsertFinancialSplits';

const FINANCIAL_SPLIT_COLUMNS = [
    { 
        label: 'Participating School Name',
        type: 'customLookupColumn',
        typeAttributes: {
            tableObjectType: 'Financial_Split__c',
            rowDraftId: { fieldName: 'rowId' },
            rowRecordId: { fieldName: 'Id' },
            lookupValue: { fieldName: 'Participating_School_Name__c' },
            lookupValueFieldName: [ACC_NAME],
            lookupFieldName: 'Participating_School_Name__c',
            editable: { fieldName: 'editable' } 
        },
        cellAttributes: {
            class: { fieldName: 'schoolNameClass' }
        }   
    },
    { 
        label: 'Account Name',
        fieldName: 'Account_Name__c',
        editable: { fieldName: 'editable' } 
    },
    { 
        label: 'Account Code',
        fieldName: 'Account_Code__c',
        type: 'text',
        editable: { fieldName: 'editable' } 
    },
    { 
        label: 'Account GL Code',
        fieldName: 'Account_GL_Code__c',
        type: 'text',
        editable: { fieldName: 'editable' } 
    },
    { 
        label: 'Percentage Split',
        fieldName: 'Percentage_split__c',
        editable: { fieldName: 'editable' } 
    },
    { 
        label: 'Active',
        fieldName: 'IsActive__c',
        type: 'boolean',
        editable: { fieldName: 'editable' } 
    },
    { 
        label: 'Action',
        type: 'button-icon',
        typeAttributes:
        {
            iconName: 'utility:delete',
            name: 'delete',
            disabled: { fieldName: 'deleteDisabled' }
        }
    }
];
export default class FinancialSplit extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api isStatusCompleted;

    financialSplitData = [];
    financialSplitColumns = FINANCIAL_SPLIT_COLUMNS;
    draftValues = [];
    datatableErrors = {};
    qutexId;
    parentId;
    privateChildren = {}; //used to get the customLookupColumn as private childern of financialSplitDataTable

    //decides if product request RT is Program
    get isOpeProgramRequest(){
        if(this.productRequest){
            return getFieldValue(this.productRequest.data,PR_RT_DEV_NAME) == RT_ProductRequest_Program;
        }
        return false;
    }

    //decides whether to show/hide the financial split table
    get showFinancialSplitTable(){
        return this.financialSplitData.length > 0;
    }

    //decides if there are no drafts in the data
    get financialDataNoDrafts(){
        return this.financialSplitData.map(data => {return data.Id}).includes(undefined);
    }

    //gets percentage split active total
    get currentTotal(){
        if(!this.financialDataNoDrafts){
            return this.financialSplitData.filter(
                data => data.IsActive__c
            ).map(data => {
                return parseInt(data.Percentage_split__c);
            }).reduce((a, b) => a + b, 0);
        }
        return 0;
    }

    //decides whether to show/hide percent validation
    get showPercentError(){
        if(!this.financialDataNoDrafts){
           return this.currentTotal !== 100;
        }
        return false;
    }

    //gets necessary field and object info
    get childInfo(){
        if(this.productRequest){
            return {
                parentField : this.isOpeProgramRequest ? 
                    PP_PRODUCT_REQUEST.fieldApiName : C_PRODUCT_REQUEST.fieldApiName,
                childObjectType : this.isOpeProgramRequest ? 
                    PROGRAM_PLAN_OBJ.objectApiName : COURSE_OBJ.objectApiName
            }
        }
        return;
    }

    //decides if financial split is related to course/program plan
    get financialSplitParentField(){
        if(this.productRequest){
            return this.isOpeProgramRequest ?
            FS_PROGRAM_PLAN.fieldApiName: FS_COURSE.fieldApiName;
        }
        return;
    }

    //decides if New button should be disabled
    get disableNewButton(){
        return (
                this.financialSplitData.length == 1 &&
                this.financialSplitData[0].Id == undefined 
            ) ||
            this.isStatusCompleted;
    }
    
    //gets product request details
    @wire(getRecord, { recordId: '$recordId', fields: [PR_RT_DEV_NAME] })
    productRequest;

    //gets related parent id (either Course/Program Plan)
    @wire(getParentId, { 
        parentId : '$recordId', 
        parentField : '$childInfo.parentField', 
        childObjectType : '$childInfo.childObjectType', 
        grandChildInfo : {}
    })
    handleGetParentId(result){
        if(result.data){
            this.parentId = result.data;
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    //gets financial split data
    financialSplitResult = [];
    financialSplitDataCopy = [];
    @wire(getFinancialSplits, { 
        relatedParentField : '$financialSplitParentField', 
        relatedParentId : '$parentId'
    })
    handleGetFinancialSplits(result){
        if(result.data){
            this.financialSplitResult = result;
            this.financialSplitData = this.financialSplitResult.data.map((data,index) => {
                return {
                    ...data,
                    rowId : 'row-' + index,
                    Percentage_split__c : data.Percentage_split__c ? data.Percentage_split__c + '%' : '0%',
                    schoolName:data.Participating_School_Name__r.Name,
                    schoolNameClass: 'slds-cell-edit',
                    deleteDisabled: true,
                    editable: !this.isStatusCompleted
                }
            });
            this.financialSplitDataCopy = this.financialSplitData.map(data =>{
                return {
                    rowId:data.rowId,
                    Participating_School_Name__c:data.Participating_School_Name__c,
                    Account_Code__c:data.Account_Code__c,
                    Account_GL_Code__c:data.Account_GL_Code__c,
                    deleteDisabled: data.deleteDisabled
                }
            });
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }
    
    //gets qutex account id on load
    connectedCallback(){
        getQutexId({qutex : QUTeX})
        .then(result => {
            this.qutexId = result;
        })
        .catch(error => {
            this.generateToast('Error.',LWC_Error_General,'error');
        });
    }

    //add click event listener on load
    renderedCallback() {
        if (!this.isComponentLoaded) {
            /* Add Click event listener to listen to window click to reset the lookup selection 
            to text view if context is out of sync*/
            window.addEventListener('click', (evt) => {
                this.handleWindowOnclick(evt);
            });
            this.isComponentLoaded = true;
        }
    }

    //remove event listener on disconnection
    disconnectedCallback() {
        window.removeEventListener('click', () => { });
    }

    //handles click on current window
    handleWindowOnclick(context) {
        this.resetPopups('c-custom-lookup-column', context);
    }

    //create object value of datatable lookup markup to allow to call callback function with window click event listener
    resetPopups(markup, context) {
        let elementMarkup = this.privateChildren[markup];
        if (elementMarkup) {
            Object.values(elementMarkup).forEach((element) => {
                element.callbacks.reset(context);
            });
        }
    }

    //event to register the datatable lookup mark up.
    handleItemRegister(event) {
        event.stopPropagation(); //stops the window click to propagate to allow to register of markup
        const item = event.detail;
        if (!this.privateChildren.hasOwnProperty(item.name))
            this.privateChildren[item.name] = {};
        this.privateChildren[item.name][item.guid] = item;
    }

    //adds blank row to table
    handleNewFinancialSplit(){
        this.financialSplitData = [
            ...this.financialSplitData,
            this.newRowData(
                this.financialSplitData.length == 0 ?
                this.qutexId : undefined
            )
        ];    
    }

    //returns new row data
    newRowData(schoolId){
        if(schoolId){
            let copyDraftValues = JSON.parse(JSON.stringify(this.draftValues));
            let updateItem = {};
            updateItem.id = 'row-' + this.financialSplitData.length;
            updateItem.Account_GL_Code__c = '';
            updateItem.Percentage_split__c = '';
            this.draftValues = [...copyDraftValues,updateItem];
        }
        return {
            rowId: 'row-' + this.financialSplitData.length,
            Participating_School_Name__c: schoolId,
            schoolName: schoolId ? QUTeX : undefined,
            Account_Name__c: undefined,
            Account_Code__c: undefined,
            Account_GL_Code__c: undefined,
            Percentage_split__c: undefined,
            IsActive__c: true,
            schoolNameClass: 'slds-cell-edit',
            deleteDisabled: false,
            editable: !this.isStatusCompleted
        };
    }

    //handles values passed from custom datatable
    handleItemSelect(event){
        let eventValue = event.detail.value;
        this.handleWindowOnclick(event.detail.recordId);
        this.financialSplitData = this.financialSplitData.map(data => {
            if(data.rowId == event.detail.draftId){
                data.Participating_School_Name__c = eventValue;
                data.schoolNameClass = 'slds-cell-edit slds-is-edited';
            }
            return data;
        });
        this.updateDraftValues({
            id:event.detail.draftId,
            Participating_School_Name__c:eventValue
        });
    }

    //handles name update of selected item from lookup
    handleNameUpdate(event){
        let eventValue = event.detail.value;
        this.financialSplitData = this.financialSplitData.map(data => {
            if(data.rowId == event.detail.draftId && data.schoolNameClass.includes('slds-is-edited')){
                data.schoolName = eventValue;
            }
            return data;
        });
    }

    //updates drafts if cell is changed
    handleCellChange(event){
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    //updates draftValues list
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = JSON.parse(JSON.stringify(this.draftValues));
        //append % if none to sting if discount is populated
        if(updateItem.Percentage_split__c){
            updateItem.Percentage_split__c = updateItem.Percentage_split__c.includes('%')?updateItem.Percentage_split__c:updateItem.Percentage_split__c + '%';
        }

        copyDraftValues.forEach((item) => {
            if (item.id === updateItem.id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }

    //saves the inputted financial split record/s
    handleSaveFinancialSplits(event){
        let draftsList = event.detail.draftValues;
        if(draftsList.length == 0 && this.draftValues.length > 0){
            draftsList = this.draftValues;
        }
        let recordsToUpsert = draftsList.map(draft => {
            let unsavedItem = this.financialSplitData.find(data => data.rowId == draft.id);
            return {
                rowId: draft.id,
                schoolName: unsavedItem.schoolName,
                Id: unsavedItem.Id ? unsavedItem.Id : undefined,
                IsActive__c: draft.IsActive__c,
                [this.financialSplitParentField] : this.parentId,
                Participating_School_Name__c:
                    draft.Participating_School_Name__c === undefined ?
                    unsavedItem.Participating_School_Name__c :
                    draft.Participating_School_Name__c,
                Account_Name__c:
                    draft.Account_Name__c === undefined ?
                    unsavedItem.Account_Name__c :
                    draft.Account_Name__c,
                Account_Code__c:
                    draft.Account_Code__c === undefined ?
                    unsavedItem.Account_Code__c :
                    draft.Account_Code__c,
                Account_GL_Code__c:
                    draft.Account_GL_Code__c === undefined ?
                    unsavedItem.Account_GL_Code__c :
                    draft.Account_GL_Code__c,
                Percentage_split__c:
                    draft.Percentage_split__c === undefined ?
                    unsavedItem.Percentage_split__c :
                    draft.Percentage_split__c
            }
        });
        
        this.datatableErrors = this.validateRecordsToUpsert(recordsToUpsert);

        if(Object.keys(this.datatableErrors).length == 0){
            let dataRefreshed = false;
            upsertFinancialSplits({ financialSplits:recordsToUpsert.map(record=>{
                    delete record.rowId;
                    delete record.schoolName;
                    return record;
                }) 
            })
            .then(() =>{
                refreshApex(this.financialSplitResult)
                .then(() => {
                    dataRefreshed = true;
                    this.draftValues = [];
                })
                .finally(() =>{
                    if(!dataRefreshed){
                        this.financialSplitData = this.financialSplitData.map(data =>{
                            data.schoolNameClass = 'slds-cell-edit';
                            return data;
                        });
                    }
                });
            })
            .catch(error =>{
                this.generateToast('Error.',LWC_Error_General,'error');
            })
            .finally(() =>{
                this.datatableErrors = {};
            });
        }
    }

    //validates datatable
    validateRecordsToUpsert(records){
        let percentRegex = /^\d{0,18}%$/;
        let rowsValidation={};
        let errors = {};

        records.map(record => {
            let fieldNames = [];
            let messages = [];
            let isQutex = record.schoolName == QUTeX;
            //participating school validation
            if(!record.Participating_School_Name__c){
                fieldNames.push('Participating_School_Name__c');
                messages.push('Participating School Name is required');
                this.addErrorOutline(record.rowId);
            }else{
                //qutex validation
                if(!this.financialSplitData.find(row => row.schoolName === QUTeX)){
                    fieldNames.push('Participating_School_Name__c');
                    messages.push(QUTeX + ' is required to be the first entry');
                    this.addErrorOutline(record.rowId);
                }
                if(isQutex){
                    //check if there is an existing QUT GSB and user creates new
                    //check if user edit existing QUT GSB and user creates new
                    if( this.financialSplitData && 
                        this.financialSplitData.filter(row => row.schoolName === QUTeX) && 
                        this.financialSplitData.filter(row => row.schoolName === QUTeX).length > 1) { 
                        fieldNames.push('Participating_School_Name__c');
                        messages.push(QUTeX + ' has already been added');
                        this.addErrorOutline(record.rowId);
                    }else{
                        if(!record.Account_GL_Code__c){
                            fieldNames.push('Account_GL_Code__c');
                            messages.push('Account GL Code is required for ' + QUTeX);
                        }
                        if(record.Account_Code__c){
                            fieldNames.push('Account_Code__c');
                            messages.push('Please remove the Account Code for ' + QUTeX);
                        }
                    }
                }else{
                    if(record.Percentage_split__c && parseInt(record.Percentage_split__c) == 0){
                        fieldNames.push('Percentage_split__c');
                        messages.push('Percentage Split must not be zero');
                    }
                }
            }
            //percentage split validation
            if(!record.Percentage_split__c){
                fieldNames.push('Percentage_split__c');
                messages.push('Percentage Split is required');
            }
            if(record.Percentage_split__c && !percentRegex.test(record.Percentage_split__c)){
                fieldNames.push('Percentage_split__c');
                messages.push('Please follow correct percent format (e.g. 50%)');
            }
            
            if(fieldNames.length > 0){
                rowsValidation[record.rowId] =
                {
                    title: 'We found an error/s.',
                    messages,
                    fieldNames
                };
            }
        });

        if(Object.keys(rowsValidation).length !== 0){
            errors = { rows:rowsValidation };
        }
        return errors;
    }

    //adds error outline to custom column
    addErrorOutline(rowId){
        for (const obj of this.financialSplitData){
            if(obj.rowId == rowId){
                obj.schoolNameClass = 'slds-cell-edit slds-is-edited slds-has-error';
                break;
            }
        }
    }

    //resets data when cancel is clicked
    handleCancel(){
        this.financialSplitData = this.financialSplitData.map(data =>{
            data.schoolNameClass = 'slds-cell-edit';
            if(!data.Id && data.Participating_School_Name__c && this.getRowInteger(data.rowId) !== 0){
                data.Participating_School_Name__c = undefined;  
                data.deleteDisabled = false;
            }else if(data.Id){
                let originalData = this.financialSplitDataCopy.find(copy => copy.rowId == data.rowId);
                data.Participating_School_Name__c = originalData.Participating_School_Name__c;
                data.Account_Code__c = originalData.Account_Code__c;
                data.Account_GL_Code__c = originalData.Account_GL_Code__c;
                data.deleteDisabled = originalData.deleteDisabled;
            }
            return data;
        });
        this.datatableErrors = {};
        this.draftValues = [];
        this.handleWindowOnclick('reset');
    }

    //deletes row selected
    handleDeleteRow(event){
        let rowId = event.detail.row.rowId;
        this.financialSplitData = this.updateRows(this.financialSplitData,rowId,'rowId');
        this.draftValues = this.updateRows(this.draftValues,rowId,'id');
        this.datatableErrors = {};
    }

    //removes row from data
    updateRows(dataList,dataRowId,prop){
        let itemsBefore = dataList.filter(data => 
            this.getRowInteger(data[prop]) < this.getRowInteger(dataRowId)
        );
        let itemsAfter = dataList.filter(data => 
            this.getRowInteger(data[prop]) > this.getRowInteger(dataRowId)
        ).map(data => {
            return {
                ...data,
                [prop]: 'row-' + (this.getRowInteger(data[prop]) - 1)
            }
        });

        return [...itemsBefore,...itemsAfter];
    }

    //gets number attached to rowId
    getRowInteger(rowId){
        return parseInt(rowId.split('-')[1]);
    }

    //creates toast notification
    generateToast(_title,_message,_variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }
}