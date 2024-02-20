import { api, LightningElement, wire } from 'lwc';
import getCertificateDetails from '@salesforce/apex/ManageCertificateSectionCtrl.getCertificateDetails';
import updateCourseConnDetails from '@salesforce/apex/ManageCertificateSectionCtrl.updateCourseConnDetails';
import sendEmail from '@salesforce/apex/ManageCertificateSectionCtrl.sendEmail';
import previewPdf from '@salesforce/apex/ManageCertificateSectionCtrl.previewPdf';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';

const SUCCESS_MSG = 'Record successfully updated.';
const SUCCESS_TITLE = 'Success!';
const ERROR_TITLE = 'Error!';
const SUCCESS_VARIANT = 'success';
const ERROR_VARIANT = 'error';
const NO_REC_FOUND = 'No record(s) found.';
const SECTION_HEADER = 'Manage Certificates Overview';
const NO_CERT_TYPE = 'No Certificate Type set up';

export default class ManageCertificates extends NavigationMixin(LightningElement) {

    @api prodReqId;
    @api offeringId;
    @api prescribedProgram;

    searchField = '';
    markDescValue = '';

    records = [];
    recordsTemp = [];    
    selectedRecords = [];

    showPreview = false;
    isLoading = false;
    empty = false;    
    error = false;    

    columns = [
        { label: 'Full Name', fieldName: 'contactFullName', type: 'text', sortable: true },
        { label: 'Registration Status', fieldName: 'registrationStatus', type: 'text', sortable: true },
        { label: 'Marks', fieldName: 'marks', type: 'text', sortable: true, editable: true },
        { label: 'Marks Description', fieldName: 'marksDesc', type: 'text', sortable: true },
        {
            type: 'action', typeAttributes: {
                rowActions: [
                    { label: 'Preview', name: 'preview' },
                    { label: 'Send Certificate', name: 'send' }
                ]
            }
        }
    ];

    markDescOptions = [
        { value: '', label: 'All' },
        { value: 'Pass', label: 'Pass' },
        { value: 'Credit', label: 'Credit' },
        { value: 'Distinction', label: 'Distinction' },
        { value: 'High Distinction', label: 'High Distinction' }
    ];      

    tableData;
    @wire(getCertificateDetails, { offeringId: '$offeringId', prescribedProgram: '$prescribedProgram'})
    wiredCertDetails(result) {
        this.isLoading = true;
        this.tableData = result;
        if (result.data) {
            this.records = result.data;
            this.recordsTemp = result.data;
            if (this.records.length === 0) {
                this.empty = true;
            }
            this.error = undefined;
            this.isLoading = false;
        } else if (result.error) {
            this.records = undefined;
            this.recordsTemp = undefined;
            this.error = result.error;
            this.isLoading = false;
        }
    }

    async handleSave(event) {
        let programOfferingId = this.prescribedProgram ? this.offeringId : '';
        this.isLoading = true;
        const updatedFields = event.detail;
        try {
            const result = await updateCourseConnDetails({
                data : updatedFields,
                programOfferingId : programOfferingId
            });
            if (result === 'Success') {
                this.isLoading = false;
                this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);
            } else {
                this.isLoading = false;
                this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
            }
            refreshApex(this.tableData);
        } catch (error) {
            this.isLoading = false;
            this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
        };
    }

    handleRowAction(event) {
        this.isLoading = true;
        let actionName = event.detail.action;
        let data = [];
        let record = event.detail.record;
        let checker = true;
        if(!record.certificateType){
            this.generateToast(ERROR_TITLE, NO_CERT_TYPE, ERROR_VARIANT);    
            this.isLoading = false;
        }else{
            if(record.certificateType == 'Certificate of Achievement'){
                if(!record.marks){
                    checker = false;
                    this.generateToast(ERROR_TITLE, 'Please add mark(s)', ERROR_VARIANT);   
                    this.isLoading = false;
                }
            }
            if(checker){
                data.push(record);
                if(actionName == 'send'){
                    this.handleSendCertificate(data);            
                }else if(actionName == 'preview'){
                    this.handlePDFPreview(data);
                }    
            }              
        }
    }
    
    handlePDFPreview(data){
        this.isLoading = true;        
        previewPdf({'data' : data}).then(result=>{
            if(result){
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'filePreview'
                    },
                    state : {
                        selectedRecordId: result
                    }
                })
            }else{
                this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
            }
            
        }).catch(error=>{
            this.isLoading = false;
            console.error('Error: ' + JSON.stringify(error));
            this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
        }).finally(()=>{
            this.isLoading = false;
        })
    }
   
    handleSelectedRows(event){
        this.selectedRecords = event.detail;             
    }

    /**
     * Handles Sending of Bulk Certificates
     */
    handleBulkSend() { 
        this.isLoading = true;
        if(this.selectedRecords.length == 0){
            this.generateToast(ERROR_TITLE, 'Please select learners!', ERROR_VARIANT);
            this.isLoading = false;  
        }else{      
            this.selectedRecords.forEach(rec=>{
                if(rec.certificateType == 'Certificate of Achievement'){
                    if(!rec.marks){
                        this.generateToast(ERROR_TITLE, 'Please add mark(s)', ERROR_VARIANT);   
                        this.isLoading = false;
                    }
                }
            })  
            this.handleSendCertificate(this.selectedRecords); 
        }             
    }

    /**
     * Handles PDF Generation
     * @param data
     */
    handleSendCertificate(data){      
        sendEmail({'data' : data}).then(result => {            
            if(result == 'Success'){
                this.generateToast(SUCCESS_TITLE, 'Email Sent', SUCCESS_VARIANT);
            }else if(result == 'No Certificate Type'){
                this.generateToast(ERROR_TITLE, NO_CERT_TYPE, ERROR_VARIANT);
            }else{
                this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
            }
        }).catch(error => {
            console.error('Error: ' + JSON.stringify(error));
            this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
        }).finally(() => {
            this.isLoading = false;
        })
    }

    handleSearch(event) {
        this.searchField = event.target.value;
        this.searchRecord();
    }

    handleMarkDesc(event) {
        this.markDescValue = event.target.value;
        this.searchRecord();
    }

    //Search records based on search criterias
    searchRecord() {
        if (this.searchField || this.markDescValue) {
            this.empty = false;
            this.records = [...this.recordsTemp];
            this.records = this.markDescValue ? this.records
                .filter( product => product.contactFullName.toLowerCase().includes(this.searchField.toLowerCase()))
                .filter( product => product.marksDesc && product.marksDesc.includes(this.markDescValue)
            ) : this.records.filter( product => product.contactFullName.toLowerCase().includes(this.searchField.toLowerCase()));
        } else {
            this.empty = false;
            this.records = [...this.recordsTemp];
        }
        if (this.records.length === 0) {
            this.empty = true;
        }
    }

    //Resets search criterias
    handleClear() {
        this.searchField = '';
        this.markDescValue = '';
        this.searchRecord();
        this.selectedRecords = [];
    }

    //Function to generate toastmessage
    generateToast(_title, _message, _variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }

    get noRecordsFound() { return NO_REC_FOUND; }
    get sectionHeader() { return SECTION_HEADER; }
}