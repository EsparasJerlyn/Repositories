/**
 * @description A custom LWC for the evaluation section of Product Requests under In Delivery
 *
 * @see ../classes/EvaluationSectionCtrl.cls
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                         |
      |---------------------------|-----------------------|--------------|--------------------------------------------------------|
      | angelika.j.s.galang       | March 22, 2022        | DEPP-1502    | Created file                                           | 
      |                           |                       |              |                                                        |
*/
import { LightningElement, wire, track, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import COURSE_OFFERING from '@salesforce/schema/hed__Course_Offering__c';
import PROGRAM_OFFERING from '@salesforce/schema/Program_Offering__c';
import EVALUATION_TYPE from '@salesforce/schema/hed__Course_Offering__c.Evaluation_Type__c';
import getEvaluationFields  from '@salesforce/apex/EvaluationSectionCtrl.getEvaluationFields';
import getRelatedProgramOfferings  from '@salesforce/apex/EvaluationSectionCtrl.getRelatedProgramOfferings';

const DATE_OPTIONS = { year: 'numeric', month: 'short', day: '2-digit' };
export default class EvaluationSection extends LightningElement {
    @api recordId;
    @api offeringData;
    @api isStatusCompleted;
    @api isNonProgram;

    createEvaluation = false;
    isModalLoading = false;
    isLoading = true;
    evaluationTypeUpdated = false;
    selectedOffering;
    selectedEvaluation;
    savedOfferingId;
    offeringInfo;
    evaluationFields = {};
    @track offeringToDisplay = [];

    //decides whether to disable Create Evaluation button
    get disableCreateEvaluation(){
        return this.offeringToEvaluate.length == 0 || this.isStatusCompleted;
    }

    //decides whether to disable Save button on Create Evaluation modal
    get disableSaveOnModal(){
        return this.selectedOffering && this.selectedEvaluation ? false : true;
    }   

    //decides whether to disable confirm icon button when changing evaluation type
    get disableConfirm(){
        return this.selectedEvaluation ? false : true;
    }

    //returns list of offerings that don't have evaluation types yet
    get offeringToEvaluate(){
        return this.offeringData.filter(
            offering => !this.offeringToDisplay.find(
                display => display.value == offering.value
            )
        );
    }

    //decides whether to show no evaluation message
    get noEvaluationFound(){
        return this.offeringToDisplay.length == 0;
    }

    //gets object to evaluate
    get objectToEvaluate(){
        return this.isNonProgram ? COURSE_OFFERING.objectApiName : PROGRAM_OFFERING.objectApiName;
    }

    //gets evaluation type field api name
    get evaluationTypeApiName(){
        return EVALUATION_TYPE.fieldApiName;
    }

    //gets Offering object information
    @wire(getObjectInfo, { objectApiName: '$objectToEvaluate' })
    getOfferingInfo(result) {
        if (result.data){
            this.offeringInfo = result.data;
            this.handleGetEvaluationFields();
        }
    }

    //get Evaluation Type picklist values
    @wire(getPicklistValues,
        {
            recordTypeId: '$offeringInfo.defaultRecordTypeId',
            fieldApiName: EVALUATION_TYPE
        }
    )
    evaluationTypes;

    //gets evaluation fields and its helptexts on load
    handleGetEvaluationFields(){
        getEvaluationFields({})
        .then(result => {
            result.forEach(mdt => {
                this.evaluationFields[mdt.MasterLabel] = mdt.Fields__c.split(/\r?\n/);
            });
            Object.keys(this.evaluationFields).forEach(evalType => {
                this.evaluationFields[evalType] = this.evaluationFields[evalType].map(field => {
                    return {
                        apiName : field,
                        helpText : this.offeringInfo.fields[field].inlineHelpText
                    }
                });
            });
            this.getOfferingData();
        })
        .catch(error => {
            this.generateToast('Error.',LWC_Error_General,'error');
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    //assigns offering data to display
    getOfferingData(){
        if(this.isNonProgram){
            this.formatOfferingToDisplay();
        }else{ //for program offerings
            this.isLoading = true;
            getRelatedProgramOfferings({productRequestId : this.recordId})
            .then(result => {
                this.offeringData = result.map(offering=> {
                    return {
                        ...offering,
                        label: 
                            offering.deliveryType + 
                            ' (' +  this.formatDate(offering.startDate) + 
                            ' to ' + this.formatDate(offering.endDate) + ')'
                    }
                });
                this.formatOfferingToDisplay();
            })
            .catch(error => {
                this.generateToast('Error.',LWC_Error_General,'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
        }
    }

    //gets offerings with evaluation types
    formatOfferingToDisplay(){
        this.offeringToDisplay = this.offeringData.filter(
            offering => offering.evaluationType
        ).map(offering => {
            return {
                ...offering,
                editMode: false,
                evaluationTypeEditMode: false,
                fields: this.evaluationFields[offering.evaluationType]
            };
        });
    }
    
    //formats date to AU format
    formatDate(date){
        return new Date(date).toLocaleDateString('en-AU',DATE_OPTIONS);
    }

    /* Create Evaluation Modal Start */
    handleCreateEvaluation(){
        this.createEvaluation = true;
    }

    handleOfferingChange(event){
        this.selectedOffering = event.detail.value;
    }

    handleEvaluationChange(event){
        this.selectedEvaluation = event.detail.value;
    }

    handleSubmitModal(){
        this.isModalLoading = true;
    }

    handleSuccessModal(){
        this.isModalLoading = false;
        let offeringToAdd = {...this.offeringData.find(offering => offering.value == this.selectedOffering)};
        offeringToAdd.editMode = false;
        offeringToAdd.evaluationTypeEditMode = false;
        offeringToAdd.evaluationType = this.selectedEvaluation;
        offeringToAdd.fields = this.evaluationFields[this.selectedEvaluation];
        this.offeringToDisplay = [...this.offeringToDisplay, offeringToAdd];
        this.handleCloseModal();
    }

    handleErrorModal(){
        this.isModalLoading = false;
        this.generateToast('Error.',LWC_Error_General,'error');
    }

    handleCloseModal(){
        this.createEvaluation = false;
        this.selectedOffering = undefined;
        this.selectedEvaluation = undefined;
    }
    /* Create Evaluation Modal End */
    
    /* Edit Evaluation Type Start */
    handleEditEvaluationType(event){
        this.updateFieldValue(event.target.dataset.name,'evaluationTypeEditMode',true);
    }

    handleShowConfirm(event){
        this.savedOfferingId = event.target.dataset.name;
        this.evaluationTypeUpdated = true;
    }

    handleCancelEvaluationType(event){
        this.selectedEvaluation = undefined;
        this.updateFieldValue(event.target.dataset.name,'evaluationTypeEditMode',false);
    }

    handleCloseConfirm(){
        this.updateFieldValue(this.savedOfferingId,'evaluationTypeEditMode',false);
        this.evaluationTypeUpdated = false;
        this.selectedEvaluation = undefined;
        this.savedOfferingId = undefined;
    }

    handleUpdateEvaluationType(){
        this.isLoading = true;
        let productOfferingToUpdate = this.offeringToDisplay.find(offering => offering.value == this.savedOfferingId);

        const fields = {};
        fields.Id = this.savedOfferingId;
        fields.Evaluation_Type__c = this.selectedEvaluation; 
        productOfferingToUpdate.fields.forEach(field => {
            fields[field.apiName] = '';
        });

        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            this.updateFieldValue(this.savedOfferingId,'evaluationType',this.selectedEvaluation);
            this.updateFieldValue(this.savedOfferingId,'fields',this.evaluationFields[this.selectedEvaluation]);
        })
        .catch(error => {
            this.generateToast('Error.',LWC_Error_General,'error');
        })
        .finally(() => {
            this.isLoading = false;
            this.handleCloseConfirm();
        });
    }

    /* Edit Evaluation Type End */

    /* Edit Evaluation Fields Start */
    handleEdit(event){
        this.updateFieldValue(event.target.dataset.name,'editMode',true);
    }

    handleSave(event){
        this.savedOfferingId = event.target.dataset.name;
    }

    handleSubmit(){
        this.isLoading = true;
    }

    handleSuccess(){
        this.isLoading = false;
        this.updateFieldValue(this.savedOfferingId,'editMode',false);
    }

    handleError(){
        this.isLoading = false;
        this.generateToast('Error.',LWC_Error_General,'error');
    }

    handleCancel(event){
        this.updateFieldValue(event.target.dataset.name,'editMode',false);
    }
    /* Edit Evaluation Fields End */

    //updates field value on offeringToDisplay list
    updateFieldValue(offeringId,prop,value){
        this.offeringToDisplay.forEach(offering => {
            if(offering.value == offeringId){
                offering[prop] = value;
            }
        });
    }

    //creates toast notification
    generateToast(_title, _message, _variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant
        });
        this.dispatchEvent(evt);
    }
}