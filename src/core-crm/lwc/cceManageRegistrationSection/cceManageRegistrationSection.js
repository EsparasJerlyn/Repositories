/**
 * @description Lightning Web Component for manage registration section for SOA and Corporate Bundle
 *
 * @see ../classes/CceManageRegistrationSectionCtrl.cls
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | roy.nino.s.regala         | August 05, 2022       | DEPP-2498            | Created file                 |
*/

import { api, LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord} from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";
import getLearnerDetails from '@salesforce/apex/CceManageRegistrationSectionCtrl.getLearnerDetails';
import updateLearners from '@salesforce/apex/CceManageRegistrationSectionCtrl.updateLearners';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import customDataTableStyle from '@salesforce/resourceUrl/CustomDataTable';
import { loadStyle } from "lightning/platformResourceLoader";


const NO_REC_FOUND = 'No record(s) found.';
const DISPLAY_TBL_ERROR = 'Unable to display record(s).';
export default class ManageRegistrationSection extends NavigationMixin(LightningElement) {

    @api recordId;
    @api isStatusCompleted;
    @api tab;
    @api recordType;

    activeSections = 'Manage Registrations';
    isLoading = false;
    empty = false;
    error;
    sortBy = 'contactName';
    sortDirection = 'asc';
    @track draftValues = [];
    @track learnerDetailsList;
    @track learnerDetailsListCopy;
    @track learnerDetails;

    columns = [
        { label: 'Learner Name', fieldName: 'contactName', type: 'text', sortable: true},
        { label: 'Product Name', fieldName: 'productName', type: 'text',sortable: true},
        { label: 'Registration Date', fieldName: 'registrationDate', type: 'date',sortable: true },
        { 
            label: 'Registration Status',
            type: 'customPicklistColumn',
            typeAttributes: {
                tableObjectType: 'hed__Course_Enrollment__c',
                rowDraftId: { fieldName: 'id' },
                picklistValue: { fieldName: 'status' },
                picklistFieldName: 'hed__Status__c',
                editable: { fieldName: 'isEditable' } 
            },
            cellAttributes: {
                class: { fieldName: 'customPicklistClass' }
            },
            wrapText: true
        },    
        { label: 'Price', fieldName: 'price', type: 'currency',sortable:true,typeAttributes: 
        {
            currencyCode:'AUD', 
            step: '0.001'
        }}
    ];

    connectedCallback(){
        Promise.all([
            loadStyle(this, customDataTableStyle)
        ]).then(() => {
        });
    }

    //Retrieves list of active OPE products
    registeredLearnerList;
    @wire(getLearnerDetails, {productReqId : "$recordId"})
    wiredLearnerDetails(result) {
        this.isLoading = true;
        this.learnerDetails = result;
        if(result.data){            

            if(JSON.parse(JSON.stringify(result.data))){
                this.learnerDetailsList = JSON.parse(JSON.stringify(result.data)).map(row => {
                    row.isEditable = HAS_PERMISSION && !this.isStatusCompleted;
                    return row;
                }); 
                this.learnerDetailsListCopy = this.learnerDetailsList;
            }
            this.isLoading = false;
            if(this.learnerDetailsList.length === 0){
                this.empty = true;
            }else{
                this.empty = false;
            }
            this.error = undefined;
        } else if(result.error){
            this.isLoading = false;
            this.error = result.error;
        }    
    } 

    //Sorts column for datatable
    handleSort(event) {       
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {        
        let parseData = JSON.parse(JSON.stringify(this.learnerDetailsListCopy));       
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.learnerDetailsList = parseData;
    }

    //updates draft values if table cell is changed
    handleCellChange(event){
        this.updateDraftValues(event.detail.draftValues[0]);
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

    //updates data and drafts to edited values 
    //if custom picklist is changed
    handlePicklistSelect(event){
    this.handleCustomColumnEdit(
            event.detail.draftId,
            'status',
            event.detail.value,
            'customPicklistClass'
        );
    }

    //updates data and drafts to edited values
    handleCustomColumnEdit(rowId,prop,value,classProp){
        this.learnerDetailsListCopy = this.learnerDetailsListCopy.map(data => {
            let updatedItem = {...data};
            if(data.id == rowId){
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

    //cancels datatabel edits
    handleCancel(){
        this.learnerDetailsListCopy = this.learnerDetailsListCopy.map(data =>{
            return this.learnerDetailsList.find(orig => orig.id == data.id);
        });
        this.datatableErrors = {};
        this.draftValues = [];
    }

    //saves datatable
    handleSave(){
    
        if(this.draftValues.length > 0){
            this.isLoading = true;

            let learners = [];
            this.draftValues.map( row =>{
                let obj = {};
                obj.Id = row.id;
                obj.hed__Status__c = row.status;
                learners.push(obj);
            });

            updateLearners({learners:learners})
            .then(() =>{
                this.dispatchEvent(new CustomEvent('tablesave'));
                refreshApex(this.learnerDetails);
            })
            .catch(error =>{
                console.log(error);
            })
            .finally(() =>{
                this.draftValues = [];
                this.isLoading = false;
            });
        }
    }



    get noRecordsFound  (){ return NO_REC_FOUND;}
    get displayTableError(){ return DISPLAY_TBL_ERROR;}
    
}