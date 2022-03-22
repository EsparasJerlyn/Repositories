import { LightningElement, api, track } from 'lwc';
import CONTACT_NAME from '@salesforce/schema/Contact.Name';
import updateFacilitatorData from "@salesforce/apex/ProductOfferingCtrl.updateFacilitatorData";

const FACILITATOR_COLUMNS = [
    { label: 'ID', fieldName: 'Name', initialWidth: 100 },
    { 
        label: 'Facilitator',
        type: 'customLookupColumn',
        typeAttributes: {
            tableObjectType: 'Facilitator_Bio__c',
            rowRecordId: { fieldName: 'Id' },
            rowDraftId: { fieldName: 'rowId' },
            lookupValue: { fieldName: 'contactId' },
            lookupValueFieldName: [CONTACT_NAME],
            lookupFieldName: 'Facilitator__c',
            editable: { fieldName: 'editable' }
        },
        cellAttributes: {
            class: { fieldName: 'customLookupClass' }
        },
        initialWidth: 200    
    },
    { 
        label: 'Professional Bio',
        type: 'customRichtextColumn',
        typeAttributes: {
            rowDraftId: { fieldName: 'rowId' },
            richtextValue: { fieldName: 'bio' },
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
        editable: { fieldName: 'editable' },
        initialWidth: 100,
        cellAttributes: { alignment: 'center' }
    },
    { 
        label: 'Set As Primary',
        type: 'button-icon',
        typeAttributes:
        {
            iconName: 'utility:favorite',
            title: 'Set As Primary',
            name: 'setAsPrimary',
            disabled: { fieldName: 'disableSetAsPrimary' }
        },
        initialWidth: 120
    }
];
export default class FacilitatorDetailSection extends LightningElement {
    @api biosToSearch;
    @api offeringId;
    @api showFacilitatorTable;
    @api isStatusCompleted;

    @api
    get relatedFacilitators() {
        return this._relatedFacilitators;
    }
    set relatedFacilitators(value) {
        this.setAttribute('relatedFacilitators', value);
        this._relatedFacilitators = value;
        this.relatedFacilitatorsCopy = value;
    }

    @track _relatedFacilitators;
    @track relatedFacilitatorsCopy;
    facilitatorColumns = FACILITATOR_COLUMNS;
    draftValues = [];
    datatableErrors = {};
    isLoading = false;
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

    //dispatches event when search item is selected
    handleSearchSelect(event){
        this.dispatchEvent(new CustomEvent('searchselect',event));
    }

    //dispatches event when row action is triggered
    handleRowAction(event){
        if(event.detail.action.name == 'setAsPrimary'){
            this.dispatchEvent(new CustomEvent('setasprimary', {
                detail: {
                    value : event.detail.row.Id
                }
            }));
        }
    }

    //updates draft values if table cell is changed
    handleCellChange(event){
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    //updates data and drafts to edited values 
    //if custom lookup is changed
    handleLookupSelect(event){
        this.handleCustomColumnEdit(
            event.detail.draftId,
            'contactId',
            event.detail.value,
            'customLookupClass'
        );
    }

    //updates data and drafts to edited values 
    //if custom richtext is changed
    handleRichtextEdit(event){
        this.handleCustomColumnEdit(
            event.detail.draftId,
            'bio',
            event.detail.value,
            'customRichtextClass'
        );
    }

    //updates data and drafts to edited values
    handleCustomColumnEdit(rowId,prop,value,classProp){
        this.relatedFacilitatorsCopy = this.relatedFacilitatorsCopy.map(data => {
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
        let recordsToValidate = this.draftValues.map(draft => {
            let unsavedItem = this.relatedFacilitatorsCopy.find(val => val.rowId == draft.id);
            return {
                rowId: draft.id,
                contactId: 
                    draft.contactId === undefined ?
                    unsavedItem.contactId :
                    draft.contactId,
                bio:
                    draft.bio === undefined ?
                    unsavedItem.bio :
                    draft.bio
            };
        });

        this.datatableErrors = this.validateRecordsToUpsert(recordsToValidate);

        if(Object.keys(this.datatableErrors).length == 0){
            let courseConnections = this.draftValues.filter(draft => 
                draft.IsActive__c !== undefined ||
                draft.contactId !== undefined
            ).map(draft => {
                return {
                    Id:this.relatedFacilitatorsCopy.find(faci => faci.rowId == draft.id).Id,
                    hed__Contact__c:draft.contactId,
                    IsActive__c:draft.IsActive__c
                }
            });
            let facilitatorBios = this.draftValues.filter(draft => 
                draft.contactId !== undefined ||
                draft.bio !== undefined
            ).map(draft => {
                return {
                    Id:this.relatedFacilitatorsCopy.find(faci => faci.rowId == draft.id).Facilitator_Bio__c,
                    Facilitator__c:draft.contactId,
                    Facilitator_Professional_Bio__c:draft.bio
                }
            });
            let updatedData = {
                courseConnections:courseConnections,
                facilitatorBios:facilitatorBios
            };
            if(courseConnections.length > 0 || facilitatorBios.length > 0){
                this.isLoading = true;
                updateFacilitatorData({ facilitatorData: updatedData })
                .then(() =>{
                    this.dispatchEvent(new CustomEvent('tablesave',{
                        detail: {
                            refreshBio : true
                        }
                    }));
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
            //facilitator validation
            if(!record.contactId){
                fieldNames.push('contactId');
                messages.push('Facilitator is required');
                this.addErrorOutline(record.rowId,'customLookupClass');
            }
            //professional bio validation
            if(!record.bio){
                fieldNames.push('bio');
                messages.push('Professional bio is required');
                this.addErrorOutline(record.rowId,'customRichtextClass');
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
        for (const obj of this.relatedFacilitatorsCopy){
            if(obj.rowId == rowId){
                obj[prop] = 'slds-cell-edit slds-is-edited slds-has-error';
                break;
            }
        }
    }

    //cancels datatable edits
    handleCancel(){
        this.relatedFacilitatorsCopy = this.relatedFacilitatorsCopy.map(data =>{
            return this.relatedFacilitators.find(orig => orig.rowId == data.rowId);
        });
        this.datatableErrors = {};
        this.draftValues = [];
        this.handleWindowOnclick('reset');
    }
}