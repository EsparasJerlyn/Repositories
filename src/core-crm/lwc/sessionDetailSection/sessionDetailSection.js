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
        label: 'Start Time',
        type: 'customDatetimeColumn',
        typeAttributes: {
            tableObjectType: 'Session__c',
            rowDraftId: { fieldName: 'rowId' },
            datetimeValue: { fieldName: 'Start_Time__c' },
            datetimeFieldName: 'Start_Time__c',
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
            datetimeValue: { fieldName: 'End_Time__c' },
            datetimeFieldName: 'End_Time__c',
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
    {
        label: 'Location Details',
        fieldName: 'Location_Detail__c',
        wrapText: true,
        editable: { fieldName: 'editable' } 
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
            event.detail.value,
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
            event.detail.fieldName == 'Start_Time__c' ?
                'customStartTimeClass' : 'customEndTimeClass' 
        );
    }

    //updates data and drafts to edited values 
    //if custom lookup is changed
    handleLookupSelect(event){
        this.handleCustomColumnEdit(
            event.detail.draftId,
            'Location__c',
            event.detail.value,
            'customLookupClass'
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
                Location__c: 
                    draft.Location__c === undefined ?
                    unsavedItem.Location__c :
                    draft.Location__c,
                Course_Connection__c: 
                    draft.Course_Connection__c === undefined ?
                    unsavedItem.Course_Connection__c :
                    draft.Course_Connection__c
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
            //location validation
            if(!record.Location__c){
                fieldNames.push('Location__c');
                messages.push('Location is required');
                this.addErrorOutline(record.rowId,'customLookupClass');
            }
            //course connection (facilitator) validation
            if(!record.Course_Connection__c){
                fieldNames.push('Course_Connection__c');
                messages.push('Facilitator is required');
                this.addErrorOutline(record.rowId,'customSearchClass');
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