/**
 * @description Lightning Web Component for New and Edit button of Designation Financials Tab.
 *
 * @author Accenture
 *
 *
 * @history
 *    | Developer                 | Date                  | JIRA                  | Change Summary                                                                             |
      |---------------------------|-----------------------|-----------------------|--------------------------------------------------------------------------------------------|
      | kathleen.mae.caceres      | April 23. 2024        | DEPP-8456 & DEPP-8409 | Created file                                                                               |
      | neil.h.lesidan            | April 23. 2024        | DEPP-8456 & DEPP-8409 | Added methods for Edit and New Button                                                      |
 */

import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { loadStyle } from "lightning/platformResourceLoader";
import FIN_GL_ACCNAME from '@salesforce/schema/Finance_GL_Account__c.Name';
import DISTRIBUTION_MANAGEMENT_OBJ from '@salesforce/schema/Distribution_Management__c';
import STATUS_FIELD from '@salesforce/schema/Distribution_Management__c.Status__c';
import insertDistributionManagement from "@salesforce/apex/DistributionManagementModalCtrl.insertDistributionManagement";
import updateDistributionManagement from "@salesforce/apex/DistributionManagementModalCtrl.updateDistributionManagement";
import customDataTableStyle from '@salesforce/resourceUrl/CustomDataTable';
import distributionManagementModalStyle from '@salesforce/resourceUrl/DistributionManagementModal';

const START_DATE_PAST = "The Start Date cannot be in the past.";
const END_DATE_PAST = "End date cannot be in the past.";
const STATUS_REVERTED = "You cannot move the status back to define.";
const SUCCESS_MESSAGE ="Record successfully created!";
const SUCCESS_UPDATE_MESSAGE ="Record successfully updated!";
const DEFINE ="Define";
const READY_FOR_USE ="Ready For Use";
const ACTIVE ="Active";
const INACTIVE ="Inactive";
const STATUS_CHANGE ="Status__c";

const DISTRIBUTION_SPLIT_COLUMNS = [
    {
        label: 'Finance GL Account',
        type: 'customLookupColumn',
        typeAttributes: {
            tableObjectType: 'Distribution_Split__c',
            rowDraftId: { fieldName: 'rowId' },
            rowRecordId: { fieldName: 'Id' },
            lookupValue: { fieldName: 'Finance_GL_Account__c' },
            lookupValueFieldName: [FIN_GL_ACCNAME],
            lookupFieldName: 'Finance_GL_Account__c',
            editable: { fieldName: 'editable' }
        },
        cellAttributes: {
            class: { fieldName: 'financeGlAccClass' }
        }
    },
    {
        label: 'Participating Group',
        fieldName: 'Participating_Group__c',
        type: 'text',
        editable: { fieldName: 'editable' }
    },
    {
        label: 'Percentage Split',
        fieldName: 'Percentage_Split__c',
        editable: { fieldName: 'editable' }
    },
    {
        type: 'button-icon',
        initialWidth: 100,
        typeAttributes:
        {
            iconName: 'utility:delete',
            name: 'delete',
            disabled: { fieldName: 'deleteDisabled' }
        }
    }
];

export default class distributionManagementModal extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api designationRecordId;
    @api closeDistributionModal;
    @track distribManagment = [];
    @track distributionSplitData = [];
    @track prevStatus;

    countInsertRow = 0;
    distributionSplitDataCopy = [];
    datatableErrors = {};
    dateval;
    dbmanagementRecordTypeId;
    distributionSplitColumns = DISTRIBUTION_SPLIT_COLUMNS;
    disabledCancelSave = false;
    draftValues = [];
    isShowTable = true;
    status;
    showPercentError = false;
    toEditDesignationManagement = false;
    _dbmanagement;


    @api
    get dbmanagement() {
        return this._dbmanagement;
    }

    set dbmanagement(value) {
        this._dbmanagement = value;
        if (value) {
            this.toEditDesignationManagement = true;
        }

        return this._dbmanagement;
    } //identifier for edited record



    get distributionDataNoDrafts(){
        return this.distributionSplitData.map(data => {return data.Id}).includes(undefined);
    }

    get getDistributionSplitData() {
        this.distributionSplitData;
    }

    get dateValue(){
        if(this.dateval == undefined) { 
            this.dateval = new Date().toISOString().substring(0, 10);
        } return this.dateval;
    } //used in isInputValid for date validations



    //fetch recordtypeId from object to be used in wire getpicklistvalues
    @wire(getObjectInfo, { objectApiName: DISTRIBUTION_MANAGEMENT_OBJ })
        results({ data,error }) {
        const logger = this.template.querySelector("c-logger");

        if (data) {
            this.dbmanagementRecordTypeId = data.defaultRecordTypeId;

        } else if (error) {
            if (logger) {
                logger.error(
                "Exception caught in wire getObjectInfo in LWC ditributionManagementModal: ",
                JSON.stringify(error)
                );
            }
        }
    }

    //sets the modal picklist values on modal load
    @wire(getPicklistValues, { recordTypeId: "$dbmanagementRecordTypeId", fieldApiName: STATUS_FIELD })
    picklistResults({ data,error }) {
        const dbmanagement = this._dbmanagement;
        const logger = this.template.querySelector("c-logger");

        if (data) {
            const notIncludeStatus = [ACTIVE, INACTIVE];
            const status = [];

            //removes notIncludeStatus from picklist options
            data.values.forEach((obj) => {
                if (!notIncludeStatus.find((e) => e == obj.value)) {
                    status.push(obj);
                }
            })

            //sets default status to define when new
            if (!dbmanagement) {
                this.distribManagment.Status__c =DEFINE;
                this.status = status;

            } else if (dbmanagement){
                this.status = status;
            }

        } else if (error) {
            if (logger) {
                logger.error(
                "Exception caught in wire getPicklistValues in LWC ditributionManagementModal: ",
                JSON.stringify(error)
                );
            }
        }
    }



    //fetch values from financials tab when record is edited
    connectedCallback() {
        const dbmanagement = this._dbmanagement;
        let distributionSplitData = [];

        //fetch value and push to edit form
        if (dbmanagement) {
            const distribManagment = {
                Id: dbmanagement.Id,
                Start_Date__c: dbmanagement.Start_Date__c,
                Designation__c: dbmanagement.Designation__c,
                End_Date__c: dbmanagement.End_Date__c,
                Status__c: dbmanagement.Status__c,
            }

            if (dbmanagement.distributionSplit) {
                dbmanagement.distributionSplit.forEach((obj, index) => {
                    distributionSplitData.push(
                        {
                            rowId: "row-" + index,
                            fieldId: obj.Id,
                            editable : !(dbmanagement.Status__c == READY_FOR_USE),
                            deleteDisabled :dbmanagement.Status__c == READY_FOR_USE,
                            financeGLAccName: obj.financeGLAccount,
                            Is_Soft_Deleted__c : obj.Is_Soft_Deleted__c,
                            Finance_GL_Account__c: obj.Finance_GL_Account__c,
                            Participating_Group__c: obj.Participating_Group__c,
                            Percentage_Split__c: `${obj.Percentage_Split__c}%`,
                        }
                    )
                })
            }

            this.distribManagment = distribManagment;
            this.countInsertRow = distributionSplitData.length - 1;
            this.modalTitle ="Edit";

            //disables start and end date onload for Edit Modal
            if(dbmanagement.Status__c == READY_FOR_USE) {
                this.isStartDateEditable = true;
                this.isEndDateEditable = true;
                this.disableAddButton = true;
            }

        } else {
            this.distribManagment = {Designation__c: this.designationRecordId};

            //adds blank row onload for New Modal
            this.modalTitle = "New";
            this.countInsertRow = distributionSplitData.length;
            distributionSplitData = [
                ...distributionSplitData,
                this.newRowData(distributionSplitData.length)
            ];
        }

        this.distributionSplitData = distributionSplitData;
        this.distributionSplitDataCopy = distributionSplitData;
    }


    //removes info icon/extra space from financeGL lookup
    renderedCallback() {
        Promise.all([
            loadStyle(this, customDataTableStyle),
            loadStyle(this, distributionManagementModalStyle)
            ]).then(() => {
        });
    }


    //fetch distribution management section fields
    handleChange(event){
        const name = event.target.dataset.name;
        this.distribManagment[name] = event.target.value;

        if (name && name == STATUS_CHANGE ){

            if(this.distribManagment[name] == READY_FOR_USE){
                this.prevDefine = event.target.value;

            } else if ((this.distribManagment[name] == DEFINE)){
                this.prevReadyForUse = event.target.value;
            }
        }
    }

    //fetch changes on distribution split data table
    handleCellChange(event) {
        this.updateDraftValues(event.detail.draftValues[0]);
        this.draftValues =[];
    }

    //fetch changes on finance gl lookup only
    handleItemSelect(event) {
        let eventValue = event.detail.value;
        let draftId = event.detail.draftId;

        this.updateDraftValues({
            id: draftId,
            Finance_GL_Account__c:eventValue || ''
        });
    }


    //saves both split and distribution management with 1 second delay
    //to allow handleCellChange to execute and recalculate totalpercentage
    handleSave() {
        this.disabledCancelSave = true;

        setTimeout((e) => {
            const distributionSplitData = JSON.parse(JSON.stringify(this.distributionSplitData));
            const isError = this.validateRecordsToUpsert(this.distributionSplitData);
            let isValid = this.isInputValid();
            this.draftValues = [];

            if (!isError) {
                if (isValid) {
                    let totalPercentage = 0;
                    for (let rownum in distributionSplitData) {
                        //calculates percentage split for final save
                        totalPercentage = totalPercentage + parseInt(distributionSplitData[rownum].Percentage_Split__c);
                    }

                    //if total is 100 for split, execute save/edit
                    if (distributionSplitData.length && totalPercentage === 100) {
                        if (this.toEditDesignationManagement) {
                            this.editManagementRecord();
                        } else {
                            this.saveManagementRecord();
                        }
                    //displays error is distribution split is blank
                    } else {
                        this.total = totalPercentage;
                        this.showPercentError =true;
                        this.disabledCancelSave = false;
                    }
                } else {
                    this.disabledCancelSave = false;
                }
            } else {
                this.disabledCancelSave = false;
            }
        }, 1000, this);
    }


    //adds blank row when clicked
    handleAddRowButton(){
        let distributionSplitData = JSON.parse(JSON.stringify(this.distributionSplitData));
        this.countInsertRow = this.countInsertRow + 1;
        distributionSplitData = [
            ...distributionSplitData,
            this.newRowData(this.countInsertRow)
        ];

        this.distributionSplitData = distributionSplitData;
    }

    //contains blank fields used in handleAddRowButton
    newRowData(count) {
        return {
            rowId: `row-${count}`,
            Finance_GL_Account__c: '',
            Participating_Group__c: '',
            Percentage_Split__c: '',
            deleteDisabled: false,
            editable: true
        };
    }

    //push non-deleted records to distributionSplitData(recordsforUpsert)
    handleDeleteRow(event){
        let rowId = event.detail.row.rowId;
        const distributionSplitData = JSON.parse(JSON.stringify(this.distributionSplitData));

        const newDistributionSplitData = [];

        for (let field in distributionSplitData) {
            if (distributionSplitData[field].rowId !== rowId) {
                newDistributionSplitData.push(distributionSplitData[field]);
            }
        }
        //revalidates splitdata after delete and clears draftvalues
        this.draftValues = [];
        this.distributionSplitData = newDistributionSplitData;
        this.validateRecordsToUpsert(this.distributionSplitData);
    }

    //applies percent formatting on-input and updates
    updateDraftValues(updateItem) {
        let distributionSplitData = JSON.parse(JSON.stringify(this.distributionSplitData));

        //append % if none to string if discount is populated
        if(updateItem.Percentage_Split__c) {
            updateItem.Percentage_Split__c = updateItem.Percentage_Split__c.includes('%')?updateItem.Percentage_Split__c:updateItem.Percentage_Split__c + '%';
        }

        //updates distributionSplitData with new values from handleItemSelect
        if(updateItem.Finance_GL_Account__c || updateItem.Finance_GL_Account__c === '' ){
            distributionSplitData.forEach((item) => {
                if (item.rowId === updateItem.id) {
                    for (let field in updateItem) {
                        if (item[field] != undefined) {
                            item[field] = updateItem[field];
                        }
                    }
                }
                //sets the finance gl cell attribute to edit mode
                if (item.Finance_GL_Account__c || updateItem.Finance_GL_Account__c === '') {
                    item.financeGlAccClass = 'slds-cell-edit'
                } return item;
            });
        }

        //updates distributionSplitData with new values from handleCellChange
        const rowNumber = updateItem.id.replace('row-','');
        if((updateItem.Participating_Group__c || updateItem.Participating_Group__c ==='') ||
            (updateItem.Percentage_Split__c || updateItem.Percentage_Split__c ==='')) {
            distributionSplitData.forEach((item, key) => {
                if (key === parseInt(rowNumber)) {
                    for (let field in updateItem) {
                        if (item[field] != undefined) {
                            item[field] = updateItem[field];
                        }
                    }
                }
                //sets the finance gl cell attribute to edit
                if (item.Finance_GL_Account__c || !item.Finance_GL_Account__c) {
                    item.financeGlAccClass = 'slds-cell-edit';
                } return item;
            });

        }   this.distributionSplitData = distributionSplitData;

        //executes percentage split format validation on update
        const percentErrors = this.validateDataType(this.distributionSplitData);
        this.datatableErrors = {rows: percentErrors};
    }

    //saves newly created records
    saveManagementRecord() {
        const distribManagment = this.distribManagment;
        const distributionSplitData = JSON.parse(JSON.stringify(this.distributionSplitData));
        const logger = this.template.querySelector("c-logger");
        distributionSplitData.forEach((obj) => {
            delete obj.id;
            delete obj.rowId;
            delete obj.deleteDisabled;
            delete obj.financeGLAccName;
            obj.Is_Soft_Deleted__c = false;
        })

        insertDistributionManagement({
            distribManagment: distribManagment,
            distributionSplitData: distributionSplitData
        })
        .then(() => {
            this.disabledCancelSave = false;
            this.generateToast('Success.',SUCCESS_MESSAGE,'success');
            this.reloadFinanceTab();
            this.handleCloseDistributionModal();
        })
        .catch(error => {
            this.disabledCancelSave = false;
            if (logger) {
                logger.error(
                    "Exception caught in method saveManagementRecord in LWC distributionManagementModal: ",
                    JSON.stringify(error)
                );
            }
        });
    }

    //saves edited existing records
    editManagementRecord() {
        const distribManagment = JSON.parse(JSON.stringify(this.distribManagment));
        const distributionSplitData = JSON.parse(JSON.stringify(this.distributionSplitData));

        const distribManagmentUpsert = [];
        // to upsert records
        distributionSplitData.forEach((obj) => {
            const toUpsert = {
                Finance_GL_Account__c: obj.Finance_GL_Account__c,
                Participating_Group__c: obj.Participating_Group__c,
                Percentage_Split__c: obj.Percentage_Split__c,
                Distribution_Management__c: distribManagment.Id,
                Is_Soft_Deleted__c : false
            }

            if (obj.fieldId) {
                toUpsert.Id = obj.fieldId;
            }

            distribManagmentUpsert.push(toUpsert);
        })

        // original distributionSplit records
        const distributionSplitDataCopy = JSON.parse(JSON.stringify(this.distributionSplitDataCopy));
        //compares original and for upsert records, is soft deleted when missing from original
        distributionSplitDataCopy.forEach((obj) => {
            const dataFound = distribManagmentUpsert.find(o => String(o.Id) == String(obj.fieldId));

            if (!dataFound) {
                const toUpsert = {
                    Id: obj.fieldId,
                    Finance_GL_Account__c: obj.Finance_GL_Account__c,
                    Participating_Group__c: obj.Participating_Group__c,
                    Percentage_Split__c: obj.Percentage_Split__c,
                    Distribution_Management__c: distribManagment.Id,
                    Is_Soft_Deleted__c : true
                }
                    delete obj.rowId;
                    delete obj.fieldId;
                    delete obj.editable;
                    delete obj.deleteDisabled;
                    delete obj.financeGLAccName;

                distribManagmentUpsert.push(toUpsert);
            }
        });
        const logger = this.template.querySelector("c-logger");
        updateDistributionManagement({
            distribManagment: distribManagment,
            distribManagmentUpsert: distribManagmentUpsert
        })
        .then(() => {
            this.disabledCancelSave = false;
            this.generateToast('Success.',SUCCESS_UPDATE_MESSAGE,'success');
            this.reloadFinanceTab();
            this.handleCloseDistributionModal();
        })
        .catch(error => {
            this.disabledCancelSave = false;
            if (logger) {
                logger.error(
                "Exception caught in method updateDistributionManagement in LWC distributionManagementModal: ",
                JSON.stringify(error)
                );
            }
        });
    }



    //validation rules for distribution management fields
    isInputValid() {
        let isValid = true;
        const distribManagmentVal = this.distribManagment;

        let inputStartDate = this.template.querySelector('.inputstartDate');
        let inputEndDate = this.template.querySelector('.inputendDate');
        let inputStatus = this.template.querySelector('.inputStatus');

        if(!inputStartDate || !distribManagmentVal.Start_Date__c ){
            isValid = false;
        }   inputStartDate.reportValidity();


        if( distribManagmentVal.Start_Date__c <  this.dateValue) {
            isValid = false;
            inputStartDate.setCustomValidity(START_DATE_PAST);
        } else {
            inputStartDate.setCustomValidity("");
        }   inputStartDate.reportValidity();


        if((
            (distribManagmentVal.End_Date__c < this.dateValue) ||
            (distribManagmentVal.End_Date__c == this.dateValue)) &&
            (distribManagmentVal.Status__c == READY_FOR_USE))
        {
            isValid = false;
            inputEndDate.setCustomValidity(END_DATE_PAST);
        } else {
            inputEndDate.setCustomValidity("")
        }   inputEndDate.reportValidity();


        if( distribManagmentVal.Status__c == DEFINE && 
            this.prevReadyForUse == DEFINE && this.toEditDesignationManagement) 
        {
            isValid = false;
            inputStatus.setCustomValidity(STATUS_REVERTED);
        } else {
            inputStatus.setCustomValidity("")
        }   inputStatus.reportValidity();


        return isValid;
    }


    //returns datatable error when percentage format is incorrect
    validateDataType(record) {
        let rowsValidation = [];
        let datatableErrors = {};
        let fieldNames = [];
        let messages = [];

        record.forEach((obj, key) => {
            if (/^\d+(\.\d+)?%$/.test(obj.Percentage_Split__c) === false && obj.Percentage_Split__c) {
                fieldNames.push('Percentage_Split__c');
                messages.push('Please follow correct percent format (e.g. 50%)');

                if (obj.rowId){
                    rowsValidation[`row-${key}`] =
                        {
                            title: 'We found an error/s.',
                            messages,
                            fieldNames
                        };

                        datatableErrors = {...datatableErrors, ...rowsValidation};
                }

            }
        })

        return datatableErrors;
    }

    //returns datatable errors when distribution split fields are missing or less than 100
    validateRecordsToUpsert(records) {
        let rowsValidation={};
        let errors = {};
        let totalPercentage = 0;
        let rowNumber ='';
        const valDataType = this.validateDataType(records);

        records.forEach((record, key) => {
            let fieldNames = [];
            let messages = [];
            rowNumber = `row-${key}`;

            if(!record.Finance_GL_Account__c){
                fieldNames.push('Finance_GL_Account__c');
                messages.push('Finance GL Account is a mandatory field');
                this.addErrorOutline(key);
            } else {
                this.removeErrorOutline(key);
            }

            if(!record.Participating_Group__c){
                fieldNames.push('Participating_Group__c');
                messages.push('Participating Group is a mandatory field');
            }

            if(!record.Percentage_Split__c){
                fieldNames.push('Percentage_Split__c');
                messages.push('Percentage Split is a mandatory field');
            }

            if(valDataType[rowNumber]){
                fieldNames.push('Percentage_Split__c');
                messages.push('Please follow correct percent format (e.g. 50%)');
            }

            // add total percentage
            if (record.Percentage_Split__c) {
                totalPercentage = totalPercentage + parseInt(record.Percentage_Split__c);
            }

            this.total = totalPercentage;

            if(fieldNames.length > 0){
                rowsValidation[rowNumber] =
                {
                    title: 'We found an error/s.',
                    messages,
                    fieldNames
                };
            }
        });

        let isError = false;

        if (totalPercentage !== 100) {
            isError = true;
            this.showPercentError =true;
        }

        if (Object.keys(rowsValidation).length !== 0) {
            errors = { rows: rowsValidation };
            isError = true;
        }

        this.datatableErrors = errors;

        return isError;
    }


    //adds error to finance gl account when missing
    addErrorOutline(key) {
        const distributionSplit = JSON.parse(JSON.stringify(this.distributionSplitData));
        for (const obj of this.distributionSplitData) {
            distributionSplit.forEach((record, rowNum) => {
                if (record.rowId == obj.rowId && rowNum == key) {
                    obj.financeGlAccClass =  'slds-cell-edit slds-is-edited slds-has-error';
                }
            });
        }
    }

    //removes error outline/focus to finance gl when its present
    removeErrorOutline(key) {
        const distributionSplit = JSON.parse(JSON.stringify(this.distributionSplitData));
        for (const obj of this.distributionSplitData){
            distributionSplit.forEach((record, rowNum) => {
                if (record.rowId == obj.rowId && rowNum == key) {
                    obj.financeGlAccClass = 'slds-cell-edit';
                }
            });
        }
    }

    //closes the modal
    handleCloseDistributionModal () {
        this.dispatchEvent(
            new CustomEvent('closedistributionmodal')
        );
    }

    //refreshes finance details tab, used in final record edit/save
    reloadFinanceTab () {
        this.dispatchEvent(
            new CustomEvent('getdistributionmanagementandsplit')
        );
    }

    handleError(event) {
        const logger = this.template.querySelector("c-logger");
        if (logger) {
            logger.error(
            "Exception caught in handleError of LWC distributionManagementModal: ",
            JSON.stringify(event.detail)
            );
        }
    }

    generateToast(_title,_message,_variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });

        this.dispatchEvent(evt);
    }
}