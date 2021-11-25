/**
 * @description A custom LWC for creating Courses under Product Request
 *
 * @see ../classes/CreateCoursesCtrl.cls
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                         |
      |---------------------------|-----------------------|--------------|--------------------------------------------------------|
      | angelika.j.s.galang       | October 14, 2021      | DEPP-383     | Created file                                           | 
      |                           |                       |              |                                                        |
*/
import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, createRecord, updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import COURSE_SCHEMA from '@salesforce/schema/hed__Course__c';
import RECORD_TYPE from '@salesforce/schema/Product_Request__c.RecordType.Name';
import PR_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c';
import getCourses from '@salesforce/apex/CreateCoursesCtrl.getCourses';

const COACHING_REQUEST = 'Coaching Request';
export default class CreateCourses extends LightningElement {
    @api recordId;
    @api objectApiName;

    openModal;
    courseIdToEdit;
    courseListToDisplay = [];
    courseListToUpsert = [];

    /**
     * gets object info of Course
     */
    @wire(getObjectInfo, { objectApiName: COURSE_SCHEMA.objectApiName })
    courseInfo;

    /**
     * gets Product Request data
     */
    productRequestRecordType;
    productRequestStatus;
    @wire(getRecord, { recordId: '$recordId', fields: [RECORD_TYPE,PR_STATUS] })
    handleProductRequest(result){
        if(result.data){
            this.productRequestRecordType = getFieldValue(result.data, RECORD_TYPE);
            this.productRequestStatus = getFieldValue(result.data, PR_STATUS);
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    /**
     * gets list of Courses
     */
    courseList;
    @wire(getCourses, {productRequestId : '$recordId'})
    handleGetCourses(result){
        if(result.data){
            this.courseList = result;
            this.courseListToDisplay = this.courseList.data.map(course => {
                let courseItem = {};
                
                courseItem.id = course.Id;
                courseItem.recordUrl = '/' + course.Id;
                courseItem.name = course.Name;
                courseItem.recordType = course.RecordType.Name;
                courseItem.startDate = course.Start_Date__c ? new Date(course.Start_Date__c).toLocaleDateString('en-US') : '';
                courseItem.endDate = course.End_Date__c ? new Date(course.End_Date__c).toLocaleDateString('en-US') : '';

                return courseItem;
            });
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }

    /**
     * return api name of Course
     */
    get courseApiName(){
        return COURSE_SCHEMA.objectApiName;
    }

    /**
     * returns record type id of Course
     */
    get courseRecordTypeId(){
        const rtis = this.courseInfo.data.recordTypeInfos;
        let rtId;

        if(this.productRequestRecordType !== COACHING_REQUEST && !this.courseIdToEdit){
            rtId = Object.keys(rtis).find(rti => rtis[rti].name == this.courseRecordTypeName);
        }else if(this.courseIdToEdit){
            rtId = this.courseList.data.find(course => course.Id == this.courseIdToEdit).RecordType.Id;
        }
        
        return rtId;
    }

    /**
     * returns record type name of Course
     */
    get courseRecordTypeName(){
        let rtApiName;

        if(!this.courseIdToEdit && this.productRequestRecordType == COACHING_REQUEST){
            rtApiName = null;
        }else if(this.courseIdToEdit){
            rtApiName = this.courseList.data.find(course => course.Id == this.courseIdToEdit).RecordType.Name;
        }else{
            rtApiName = this.productRequestRecordType.replace(' Request','');
        }

        return rtApiName;
    }

    /**
     * returns parent record type name of Course
     */
    get parentRecordTypeName(){
        return this.productRequestRecordType == COACHING_REQUEST && !this.courseIdToEdit ? 
            COACHING_REQUEST : null;
    }

    /**
     * returns boolean that determines if record type selection is needed
     */
    get withRecTypeSelection(){
        return this.parentRecordTypeName == COACHING_REQUEST ? true : false;
    }

    /**
     * returns prepopulated fields needed in creation
     */
    get prepopulatedCourseFields(){
        let fields = {};

        fields['ProductRequestID__c'] = this.recordId;
        if(this.courseRecordTypeId){
            fields['RecordTypeId'] = this.courseRecordTypeId;
        }

        return fields;
    }
    
    /**
     * returns boolean that determines of mark as complete button should be disabled
     */
    get disableMarkAsComplete(){
        return this.courseListToDisplay.length == 0 || this.productRequestStatus !== 'Design' ? true : false;
    }

    /**
     * returns boolean that determines if Create Courses/Edit buttons should be disabled
     */
    get disableButton(){
        return this.productRequestStatus !== 'Design' ? true : false;
    }

    /**
     * returns boolean to check if there courses to display
     */
    get showEmptyCourseMessage(){
        return this.courseListToDisplay.length > 0 ? false : true;
    }

    /**
     * updates status to Release if mark as completed button is selected
     */
    handleMarkAsComplete(){
        if(this.courseListToDisplay.length > 0){
            const fields = {};
            fields.Id = this.recordId;
            fields.Product_Request_Status__c = 'Release';
            this.handleUpdateRecord(fields,true);
        }else{
            this.generateToast('Oops!','Please enter at least one (1) Course record to proceed.','warning')
        }
    }

    /**
     * stores id of record to be edited and opens modal
     */
    handleEdit(event){
        this.courseIdToEdit = event.target.dataset.name;
        this.openModal = true;
    }

    /**
     * opens modal when creating a course
     */
    handleCreateCourse(){
        this.openModal = true;
    }

    /**
     * closes modal and sets course id to null
     */
    closeModal(event){
        this.openModal = event.detail;
        this.courseIdToEdit = null;
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

    /**
     * checks whether Course record is for Create or Update
     */
    upsertCourseRecord(event){
        if(event.detail.Id){
            this.handleUpdateRecord(event.detail,false);
        }else{
            this.handleCreateRecord(COURSE_SCHEMA.objectApiName,event.detail);
        }
    }

    /**
     * creates record given object api name and fields
     */
    handleCreateRecord(objApiName,fieldsToCreate){
        this.isLoading = true;
        const fields = {...fieldsToCreate};
        const recordInput = { apiName: objApiName, fields };

        createRecord(recordInput)
        .then(record => {
            this.generateToast('Success!','Record created.','success')
        })
        .catch(error => {
            this.generateToast('Error.',LWC_Error_General,'error');
        })
        .finally(() => {
            this.isLoading = false;
            refreshApex(this.courseList);
        });
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
                this.generateToast('Success!','Design marked as completed.','success')
            }else{
                this.generateToast('Success!','Record updated.','success')
            }
            
        })
        .catch(error => {
            this.generateToast('Error.',LWC_Error_General,'error');
        })
        .finally(() => {
            this.isLoading = false;
            refreshApex(this.courseList);
        });
    }
}