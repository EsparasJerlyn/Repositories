import { LightningElement, api, track } from 'lwc';
import FACILITY_NAME from '@salesforce/schema/hed__Facility__c.Name';
import updateSessionData from "@salesforce/apex/ProductOfferingCtrl.updateSessionData";

const SESSION_COLUMNS = [
    { 
        label: 'Session Name',
        fieldName: 'Name',
        wrapText: true,
        editable: { fieldName: 'editable' },
    },
    { 
        label: 'Session Type',
        type: 'customPicklistColumn',
        typeAttributes: {
            tableObjectType: 'Session__c',
            rowDraftId: { fieldName: 'rowId' },
            picklistValue: { fieldName: 'Session_Type__c' },
            picklistFieldName: 'Session_Type__c',
            editable: { fieldName: 'editable' } 
        },
        cellAttributes: {
            class: { fieldName: 'customPicklistClass' }
        }
    },
    {
        label: 'Facilitator', 
        fieldName: 'Course_Connection__c', 
        type: 'customSearch', 
        wrapText: true,
        typeAttributes: {
            icon: "standard:orchestrator",
            parentId: { fieldName:'rowId' },
            placeholder: "Search Facilitators...",
            lookupItems: { fieldName:'relatedFacilitators' },
            itemServerName:{ fieldName:'contactName' },
            itemId:{ fieldName:'Course_Connection__c' },
            editable: { fieldName: 'editable' } 
        },
        cellAttributes:{
            class: { fieldName:'customSearchClass' }
        }
    },
    {
        label: "Date",
        fieldName: "Date__c",
        type: "date-local",
        typeAttributes:{
            month: "2-digit",
            day: "2-digit"
        },
        editable: { fieldName: 'editable' },
        wrapText: true  
    },
    { 
        label: 'Start Time',
        type: 'customDatetimeColumn',
        typeAttributes: {
            tableObjectType: 'Session__c',
            rowDraftId: { fieldName: 'rowId' },
            datetimeValue: { fieldName: 'Start_Time_v2__c' },
            datetimeFieldName: 'Start_Time_v2__c',
            editable: { fieldName: 'editable' } 
        },
        cellAttributes: {
            class: { fieldName: 'customStartTimeClass' }
        },
        wrapText: true  
    },
    { 
        label: 'End Time',
        type: 'customDatetimeColumn',
        typeAttributes: {
            tableObjectType: 'Session__c',
            rowDraftId: { fieldName: 'rowId' },
            datetimeValue: { fieldName: 'End_Time_v2__c' },
            datetimeFieldName: 'End_Time_v2__c',
            editable: { fieldName: 'editable' } 
        },
        cellAttributes: {
            class: { fieldName: 'customEndTimeClass' }
        },
        wrapText: true  
    },
    { 
        label: 'Location',
        type: 'customLookupColumn',
        typeAttributes: {
            tableObjectType: 'Session__c',
            rowDraftId: { fieldName: 'rowId' },
            rowRecordId: { fieldName: 'Id' },
            lookupValue: { fieldName: 'Location__c' },
            lookupValueFieldName: [FACILITY_NAME],
            lookupFieldName: 'Location__c',
            editable: { fieldName: 'editable' } 
        },
        cellAttributes: {
            class: { fieldName: 'customLookupClass' }
        }  
    },
    /*{
        label: 'Location Details',
        fieldName: 'Location_Detail_v2__c',
        wrapText: true,
        editable: { fieldName: 'editable' } 
    },*/
    { 
        label: 'Location Details',
        type: 'customRichtextColumn',
        typeAttributes: {
            rowDraftId: { fieldName: 'rowId' },
            richtextValue: { fieldName: 'Location_Detail_v2__c' },
            editable: { fieldName: 'editable' }
        },
        cellAttributes: {
            class: { fieldName: 'customRichtextClass' }
        },
        wrapText: true
    },
    { 
        label: 'IsActive',
        fieldName: 'IsActive__c',
        type:'boolean',
        editable: { fieldName: 'editable' } ,
        initialWidth: 100
    }
];
export default class SessionDetailSection extends LightningElement {
    @api showSessionTable;
    @api offeringId;
    @api disableSession;
    @api showHelp;

    @api
    get relatedSessions() {
        return this._relatedSessions;
    }
    set relatedSessions(value) {
        this.setAttribute('relatedSessions', value);
        this._relatedSessions = value;
        this.relatedSessionsCopy = value;
    }

    @track _relatedSessions;
    @track relatedSessionsCopy;
    sessionColumns = SESSION_COLUMNS;
    draftValues = [];
    datatableErrors = {};
    privateChildren = {}; //used to get the customLookupColumn as private childern 

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
    
    //fires event to add new session
    handleAddSession(event){
        this.dispatchEvent(new CustomEvent('addsession', {
           detail: {
                offeringId : this.offeringId
            }
        }));
    }

    //updates draft values if table cell is changed
    handleCellChange(event){
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    //updates data and drafts to edited values 
    //if custom picklist is changed
    handlePicklistSelect(event){
        this.handleCustomColumnEdit(
            event.detail.draftId,
            'Session_Type__c',
            event.detail.value,
            'customPicklistClass'
        );
    }

    //updates data and drafts to edited values 
    //if custom search is changed
    handleItemSelect(event){
        this.handleCustomColumnEdit(
            event.detail.parent,
            'Course_Connection__c',
            event.detail.value ? event.detail.value : '',
            'customSearchClass'
        );
    }

    //updates data and drafts to edited values 
    //if custom datetime is changed
    handleDatetimeEdit(event){
        this.handleCustomColumnEdit(
            event.detail.draftId,
            event.detail.fieldName,
            event.detail.value,
            event.detail.fieldName == 'Start_Time_v2__c' ?
                'customStartTimeClass' : 'customEndTimeClass' 
        );
    }

    //updates data and drafts to edited values 
    //if custom lookup is changed
    handleLookupSelect(event){
        this.handleCustomColumnEdit(
            event.detail.draftId,
            'Location__c',
            event.detail.value ? event.detail.value : '',
            'customLookupClass'
        );
    }

    //updates data and drafts to edited values 
    //if custom richtext is changed
    handleRichtextEdit(event){
        this.handleCustomColumnEdit(
            event.detail.draftId,
            'Location_Detail_v2__c',
            event.detail.value ? event.detail.value : '',
            'customRichtextClass'
        );
    }

    //updates data and drafts to edited values
    handleCustomColumnEdit(rowId,prop,value,classProp){
        this.relatedSessionsCopy = this.relatedSessionsCopy.map(data => {
            let updatedItem = {...data};
            if(data.rowId == rowId){
                updatedItem[prop] = value;
                updatedItem[classProp] = 'slds-cell-edit slds-is-edited';
            }
            return updatedItem;
        });
        this.updateDraftValues({
            id:rowId,
            [prop]:value
        });
    }

    //updates draftValues list
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = JSON.parse(JSON.stringify(this.draftValues));
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

    //saves datatable
    handleSave(){
        this.handleWindowOnclick('reset');
        let recordsToValidate = this.draftValues.map(draft => {
            let unsavedItem = this.relatedSessionsCopy.find(val => val.rowId == draft.id);
            return {
                rowId: draft.id,
                Name:
                    draft.Name === undefined ?
                    unsavedItem.Name :
                    draft.Name,
                Date__c:
                    draft.Date__c === undefined ?
                    unsavedItem.Date__c :
                    draft.Date__c,
                Start_Time_v2__c:
                    draft.Start_Time_v2__c === undefined ?
                    unsavedItem.Start_Time_v2__c :
                    draft.Start_Time_v2__c,
                End_Time_v2__c:
                    draft.End_Time_v2__c === undefined ?
                    unsavedItem.End_Time_v2__c :
                    draft.End_Time_v2__c
            };
        });

        this.datatableErrors = this.validateRecordsToUpsert(recordsToValidate);

        if(Object.keys(this.datatableErrors).length == 0){
            if(this.draftValues.length > 0){
                this.isLoading = true;
                updateSessionData({ sessionData:this.draftValues.map(draft =>{
                        draft.Id = this.relatedSessionsCopy.find(sesh => sesh.rowId == draft.id).Id;
                        delete draft.id;
                        return draft;
                    })
                })
                .then(() =>{
                    this.dispatchEvent(new CustomEvent('tablesave'));
                })
                .catch(error =>{
                })
                .finally(() =>{
                    this.draftValues = [];
                    this.datatableErrors = {};
                    this.isLoading = false;
                });
            }
        }
    }

    //validates datatable
    validateRecordsToUpsert(records){
        let rowsValidation={};
        let errors = {};
        records.map(record => {
            let fieldNames = [];
            let messages = [];
            //session name validation
            if(!record.Name){
                fieldNames.push('Name');
                messages.push('Session Name is required');
            }
            //date validation
            if(!record.Date__c){
                fieldNames.push('Date__c');
                messages.push('Date is required');
            }
            //start & end time validation
            if(record.End_Time_v2__c <= record.Start_Time_v2__c){
                fieldNames.push('End_Time_v2__c');
                messages.push('Should be greater than start time');
                this.addErrorOutline(record.rowId,'customEndTimeClass');
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
    addErrorOutline(rowId,prop){
        for (const obj of this.relatedSessionsCopy){
            if(obj.rowId == rowId){
                obj[prop] = 'slds-cell-edit slds-is-edited slds-has-error';
                break;
            }
        }
    }

    //cancels datatabel edits
    handleCancel(){
        this.relatedSessionsCopy = this.relatedSessionsCopy.map(data =>{
            return this.relatedSessions.find(orig => orig.rowId == data.rowId);
        });
        this.datatableErrors = {};
        this.draftValues = [];
        this.handleWindowOnclick('reset');
    }
}