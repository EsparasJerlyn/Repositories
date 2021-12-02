/**
 * @description A custom LWC for getting the integrated curriculum under Product Request
 *
 * @see ../classes/GetCurriculumCtrl.cls
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                         |
      |---------------------------|-----------------------|--------------|--------------------------------------------------------|
      | angelika.j.s.galang       | November 9, 2021      | DEPP-663     | Created file                                           |
      | arsenio.jr.dayrit         | November 16, 2021     | DEPP-76      | Added UI and functions for verification popup modal    | 
      | adrian.c.habasa           | November 16, 2021     | DEPP-707     | Modified UI and functions for verification popup modal |
      | aljohn.motas              | November 19, 2021     | DEPP-649     | Modified to handle Stand Alone records                 |
      | eccarius.karl.munoz       | November 23, 2021     | DEPP-36      | Updated the conditions for Stand Alone records         |
      | eccarius.karl.munoz       | December 1, 2021      | DEPP-1040    | Updated the reference for Implemantation Year to v2    |
*/
import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import LWC_HelpText_GetCurriculumButton from '@salesforce/label/c.LWC_HelpText_GetCurriculumButton';
import getExistingCurriculumItems from '@salesforce/apex/GetCurriculumCtrl.getExistingCurriculumItems';
import COURSE_SCHEMA from '@salesforce/schema/hed__Course__c';
import PROG_PLAN_SCHEMA from '@salesforce/schema/hed__Program_Plan__c';
import PROP_ID from '@salesforce/schema/Product_Request__c.CourseLoop_Full_Proposal_ID__c';
import PROP_URL from '@salesforce/schema/Product_Request__c.CourseLoop_Full_Proposal_URL__c';
import PROP_APPROVED from '@salesforce/schema/Product_Request__c.Is_Curriculum_Approved__c';
import IMP_YR from '@salesforce/schema/Product_Request__c.Implementation_Year_v2__c';
import OWN_FAC from '@salesforce/schema/Product_Request__c.Owning_Faculty__c';
import OWN_FAC_NAME from '@salesforce/schema/Product_Request__c.Owning_Faculty__r.Name';
import PR_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c';
import REC_TYPE from '@salesforce/schema/Product_Request__c.RecordType.DeveloperName';

const COL_CLASS = 'slds-col slds-size_x-of-y';
const CENTER_CLASS = ' slds-text-align_center';
export default class GetCurriculum extends LightningElement {
    @api recordId;
    @api objectApiName;

    programPlanList = [];
    courseList = [];
    curriculumItemsList = [];
    curriculumItemsListVerification = [];
    proposalDetails = [];
    showVerification = false;
    showCurriculumOnModal = false;
    modalEditMode = false;
    isLoading = false;
    showEditModal = false;
    getCurriculumSelected = false;
    editModalObject = '';
    editModalId = '';

    /**
     * columns for verification and main views
     */
    programPlanFieldsVerification = [
        { 'field':'Program Plan','class': COL_CLASS.replace('x','2').replace('y','5') },
        { 'field':'Program Type','class': COL_CLASS.replace('x','1').replace('y','5') },
        { 'field':'Implementation Year','class': COL_CLASS.replace('x','1').replace('y','5') },
        { 'field':'Owning Faculty','class': COL_CLASS.replace('x','1').replace('y','5') }
    ];
    programPlanFields = [
        { 'field':'Program Plan','class': COL_CLASS.replace('x','3').replace('y','12') },
        { 'field':'Program Type','class': COL_CLASS.replace('x','2').replace('y','12') },
        { 'field':'Implementation Year','class': COL_CLASS.replace('x','2').replace('y','12') },
        { 'field':'Owning Faculty','class': COL_CLASS.replace('x','2').replace('y','12') },
        { 'field':'IsComplete','class': COL_CLASS.replace('x','2').replace('y','12') + CENTER_CLASS }
    ];
    courseFieldsVerification = [
        { 'field':'Course Name','class': COL_CLASS.replace('x','2').replace('y','5') },
        { 'field':'Course Code','class': COL_CLASS.replace('x','1').replace('y','5') }, 
        ...this.programPlanFieldsVerification.slice(2)
    ];
    courseFields = [
        { 'field':'Course Name','class': COL_CLASS.replace('x','3').replace('y','12') },
        { 'field':'Course Code','class': COL_CLASS.replace('x','2').replace('y','12') }, 
        ...this.programPlanFields.slice(2)
    ];

    /**
     * getter for UI properties
     */
    get helpText(){
        return LWC_HelpText_GetCurriculumButton;
    }

    get proposalIdApiName(){
        return PROP_ID.fieldApiName;
    }

    get isAllComplete(){
        let allData = [];
        this.curriculumItemsList.forEach(item => {
            allData.push(...item.data);
        });
        return allData.map(data => {return data.isComplete}).includes(false) ? false : true;
    }

    get isProgramRequest(){
        return this.productRequest['recordType'] == 'Program_Request';
    }

    get isNotDesign(){
        return this.productRequest['status'] !== 'Design';
    }

    get incompleteProposalDetails(){
        return !this.productRequest['proposalId'] || !this.productRequest['proposalUrl'] || !this.productRequest['proposalApproved'];
    }

    get curriculumMessage(){
        let message = '';
        if(this.proposalDetails.length > 0){
            let verb = this.proposalDetails.length == 1 ? ' is' : ' are';
            message = this.proposalDetails.join(', ') + verb + ' required to click on Get Curriculum button.';
        }else if(this.curriculumItemsList.length == 0){
            message = this.getCurriculumSelected || this.isNotDesign ? 'No Curriculum Items found.' : 'Select the Get Curriculum button to proceed.';
        }
        return message;
    }

    get courseRecordTypeName(){
        if(this.editModalObject == COURSE_SCHEMA.objectApiName){
            return this.courseList.find(course => course.id == this.editModalId).recordType;
        }
    }

    get disableMarkAsComplete(){
        return this.curriculumItemsList.length == 0 || !this.isAllComplete || this.isNotDesign ? true : false;
    }

    get disableCurriculumButton(){
        return this.incompleteProposalDetails || this.isNotDesign ? true : false;
    }

    get disableCurriculumModalButton(){
        return this.incompleteProposalDetails || this.showCurriculumOnModal || this.modalEditMode ? true : false;
    }

    get disableSaveModalButton(){
        return this.modalEditMode ? false : true;
    }

    get disableConfirmModalButton(){
        return this.modalEditMode || !this.showCurriculumOnModal ? true : false;
    }

    /**
     * gets Product Request data
     */
    @track productRequest = {};
    @wire(getRecord, { 
        recordId: '$recordId', 
        fields: [PROP_ID,PROP_URL,PROP_APPROVED,IMP_YR,PR_STATUS,OWN_FAC,OWN_FAC_NAME,REC_TYPE] 
    })
    handleProductRequest(result){
        this.isLoading = true;
        if(result.data){
            this.proposalDetails = [];
            this.productRequest['proposalId'] = getFieldValue(result.data,PROP_ID);
            this.productRequest['proposalUrl'] = getFieldValue(result.data,PROP_URL);
            this.productRequest['proposalApproved'] = getFieldValue(result.data,PROP_APPROVED);
            this.productRequest['implementationYear'] = getFieldValue(result.data,IMP_YR);
            this.productRequest['status'] = getFieldValue(result.data,PR_STATUS);
            this.productRequest['owningFacultyUrl'] = '/' + getFieldValue(result.data,OWN_FAC);
            this.productRequest['owningFaculty'] = getFieldValue(result.data,OWN_FAC_NAME);
            this.productRequest['recordType'] = getFieldValue(result.data,REC_TYPE);
            if(!getFieldValue(result.data,PROP_ID)){
                this.proposalDetails.push('"CourseLoop Full Proposal ID"');
            }if(!getFieldValue(result.data,PROP_URL)){
                this.proposalDetails.push('"CourseLoop Full Proposal URL"');
            }if(!getFieldValue(result.data,PROP_APPROVED)){
                this.proposalDetails.push('"Is Curriculum Approved"');   
            }
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
        this.isLoading = false;
    }

    /**
     * gets Program Plan and Course data
     */
    existingCurriculumList;
    @wire(getExistingCurriculumItems, {productRequestId : '$recordId', isRecTypeProgramRequest : '$isProgramRequest'})
    handleGetExistingCurriculumItems(result){
        this.isLoading = true;
        if(result.data){
            this.existingCurriculumList = result;
            if(this.existingCurriculumList.data.courses){
                this.courseList = this.formatCurriculumItems(this.existingCurriculumList.data.courses,true);
            }
            if(this.existingCurriculumList.data.programPlans){
                this.programPlanList = this.formatCurriculumItems(this.existingCurriculumList.data.programPlans,false);
            }
            if(this.isNotDesign){
                this.assignExistingCurriculum();
            }
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
        this.isLoading = false;
    }

    /**
     * formats curriculum items lists
     */
    formatCurriculumItems(items,forCourses){
        return items.map(item => {
            let _item = {};
            _item.id = item.Id;
            _item.nameUrl = '/' + item.Id;
            _item.name = item.Name;
            _item.programTypeOrCourseCode = forCourses ? item.Course_Code__c : item.Program_Type__c;
            _item.recordType = forCourses ? item.RecordType.Name : '';
            _item.implementationYear = item.Implementation_Year__c;
            _item.owningFacultyUrl = item.Owning_Faculty__c ? '/' + item.Owning_Faculty__c : '';
            _item.owningFaculty = item.Owning_Faculty__c ? item.Owning_Faculty__r.Name : '';
            _item.isComplete = item.IsComplete__c;   
            _item.isCompleteDisabled = this.isNotDesign;
            _item.isEditDisabled = this.isNotDesign ? true : item.IsComplete__c;            
            return _item;
        });
    }

    /**
     * combines all items and headers into 1 list
     */
    assignExistingCurriculum(){
        if(this.courseList.length > 0){
            this.curriculumItemsList = [
                { id : COURSE_SCHEMA.objectApiName, headers : this.courseFields, data : this.courseList }
            ];
        }
        if(this.isProgramRequest && this.programPlanList.length > 0){
            this.curriculumItemsList = [
                { id : PROG_PLAN_SCHEMA.objectApiName, headers : this.programPlanFields, data : this.programPlanList },
                ...this.curriculumItemsList
            ]
        }
    }

    /**
     * opens verification view modal
     */
    handleGetCurriculum(){
        this.showVerification = true;
    }

    /**
     * updates record when IsComplete checkbox is ticked/unticked
     */
    handleCheckboxChange(event){
        const fields = {};
        fields.Id = event.target.name;
        fields.IsComplete__c = event.target.checked;
        this.handleUpdateRecord(fields,false);
    }

    /**
     * shows record edit modal when 'Edit' button is selected on main view
     */
    handleEdit(event){
        this.showEditModal = true;
        this.editModalObject = event.target.name;
        this.editModalId = event.target.dataset.name; 
    }

    /**
     * saves edited record from edit modal
     */
    handleSaveOnEditModal(event){
        this.handleUpdateRecord(event.detail,false);
    }

    /**
     * hides edit modal
     */
    handleCloseOnEditModal(event){
        this.showEditModal = event.detail;
        this.editModalObject = '';
        this.editModalId = '';
    }

    /**
     * shows curriculum items on main view
     */
    handleConfirmModalButton(){
        this.showVerification = false;
        this.getCurriculumSelected = true;
        this.assignExistingCurriculum();
    }

    /**
     * makes proposal id editable on verification view modal
     */
    handleEditModalButton(){
        this.modalEditMode = true;
    }

    /**
     * shows curriculum items on verification view modal
     */
    handleGetCurriculumModalButton(){
        if(this.courseList.length > 0){
            this.curriculumItemsListVerification =  [
                { id : COURSE_SCHEMA.objectApiName, headers : this.courseFieldsVerification, data : this.courseList  }
            ];
        }
        if(this.isProgramRequest && this.programPlanList.length > 0){
            this.curriculumItemsListVerification = [
                { id : PROG_PLAN_SCHEMA.objectApiName, headers : this.programPlanFieldsVerification, data : this.programPlanList },
                ...this.curriculumItemsListVerification
            ]
        }
        this.showCurriculumOnModal = true;
    }

    /**
     * resets the proposal id input field when cancelled on verfication view modal
     */
    handleCancelModalButton(){
        this.modalEditMode = false;
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if(inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }

    /**
     * hides and resets curriculum items on verification view modal
     * onsuccess of record edit form submission
     */
    handleSaveModalButton(){
        this.curriculumItemsListVerification = [];
        this.showCurriculumOnModal = false; 
        this.modalEditMode = false;
    }

    /**
     * hides verification view modal
     */
    handleCloseModalButton(){
        this.showVerification = false;
    }

    /**
     * updates status to Release if mark as completed button is selected
     */
    handleMarkAsComplete(){
        if(this.curriculumItemsList.length > 0){
            const fields = {};
            fields.Id = this.recordId;
            fields.Product_Request_Status__c = 'Release';
            this.handleUpdateRecord(fields,true);
        }else{
            this.generateToast('Oops!','Please select the Get Curriculum button to proceed.','warning')
        }
    }

    /**
     * updates record given fields
     * forProductRequest is a boolean to check if record being updated is of type Product Request
     */
    handleUpdateRecord(fieldsToUpdate,forProductRequest){
        this.isLoading = true;
        const fields = {...fieldsToUpdate};
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            if(forProductRequest){
                this.generateToast('Success!','Design marked as completed.','success');
            }else{
                this.generateToast('Success!','Record updated.','success');
            }
        })
        .catch(error => {
            this.generateToast('Error.',LWC_Error_General,'error');
        })
        .finally(() => {
            refreshApex(this.existingCurriculumList)
            .then(() => {
                if(this.getCurriculumSelected){
                    this.assignExistingCurriculum();
                }
                this.isLoading = false;
            });
        });
    }
    
    /**
     * creates toast notification
     */
     generateToast(_title,_message,_variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }
}