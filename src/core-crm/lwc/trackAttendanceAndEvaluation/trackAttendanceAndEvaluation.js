/**
 * @description An LWC component for Track attendance
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                            | Change Summary                       |
      |---------------------------|-----------------------|---------------------------------|--------------------------------------|
      | adrian.c.habasa           | Febuary 11, 2022      | DEPP-1247                       | Created                              |
 */

import { LightningElement,wire,api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getRelatedCourseOfferingsAndSessions from '@salesforce/apex/TrackAttendanceAndEvaluationCtrl.getRelatedCourseOfferingsAndSessions';
import upsertAttendance  from '@salesforce/apex/TrackAttendanceAndEvaluationCtrl.upsertAttendance';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import PRODUCT_REQUEST_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c';
import PL_ProductRequest_Completed from '@salesforce/label/c.PL_ProductRequest_Completed';

const SUCCESS_TITLE = 'Success!';
const SUCCESS_MSG = 'Record(s) successfully saved.';
const SUCCESS_VARIANT = 'success';
const ERROR_TITLE = 'Error!';
const ERROR_VARIANT = 'error';
const DATE_OPTIONS = { year: 'numeric', month: 'short', day: '2-digit' };



export default class TrackAttendanceAndEvaluation extends LightningElement {

    @api recordId;
    isSaving=false;
    createdAttendance=false;
    isLoading=true;
    draftMasterList=[];
    selectedRelatedSessions={};
    selectedSessionData={};
    cantSave = true;
    offeringValue='';
    sessionValue='';
    offeringTemp={};
    offeringData=[];
    sessionData=[];
    masterList=[];
    connectionStudentData=[];
    selectedRelatedConnections={};
    studentData = [];
    columns = [ { label: 'Name', fieldName: 'name' }, 
    { label: 'Present', fieldName: 'Present__c', type:'boolean', editable: true}];
    activeSections = ['trackAttendance','evaluations'];
    isStatusCompleted;
    
    get hasAccess(){
        return HAS_PERMISSION;
    }

    /**
     * gets product request status
    */
    @wire(getRecord, { recordId: '$recordId', fields: [PRODUCT_REQUEST_STATUS] })
    handleParentRecord(result){
        if(result.data){
            this.isStatusCompleted = getFieldValue(result.data,PRODUCT_REQUEST_STATUS) == PL_ProductRequest_Completed;
        }
    }

    listOfRecords;
    @wire(getRelatedCourseOfferingsAndSessions,{productRequestId:'$recordId'})
    relatedRecord(result)
    {
        this.isSaving =true;
        if(result.data)
        {
           this.listOfRecords = result;
           this.masterList=result.data;
           this.offeringTemp = this.masterList;
           this.offeringData = this.formatCourseOffering(this.offeringTemp);
           this.isLoading= false;
           this.isSaving =false;
           
        }
        else if(result.error)
        {
            this.isLoading= false;
            this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
            
        }
    }
    
    formatCourseOffering(listToFormat)
    {
        return listToFormat.map(item =>{
            let newItem = {};
            newItem.value = item.id;
            newItem.label = item.deliveryType + ' (' +  this.formatDate(item.startDate) + ' to ' + this.formatDate(item.endDate) + ')' ;
            newItem.evaluationType = item.evaluationType;
            return newItem;
        });
    }
    
 
    formatSession(sessionList)
    {
        return sessionList.map(item =>{
            let newItem = {};
            newItem.value = item.Id;
            newItem.label = item.Name + ' (' +this.formatDate(item.Start_Time__c) + ', ' + this.formatTime(String(item.Start_Time__c)) + ')';
            return newItem;
        });
    }
   
    //Student that has attendance
    formatStudent(studentList)
    {
        return studentList.filter((filter) => filter.hed__Course_Connection__c && filter.hed__Course_Connection__r.hed__Contact__c).map(item =>{
            let newItem={};
            newItem.courseConnectionId = item.hed__Course_Connection__c;
            newItem.contactName = item.hed__Course_Connection__r.hed__Contact__r.Name;
            newItem.contactId = item.hed__Course_Connection__r.hed__Contact__r.Id;
            newItem.isPresent = item.Present__c;
            newItem.attendanceId= item.Id;
            newItem.sessionId= item.Session__c;
            return newItem;
        }); 
    }

    formatDate(date){
        return new Date(date).toLocaleDateString('en-AU',DATE_OPTIONS);
    }

    formatTime(time){
        return new Date(time).toLocaleTimeString('en-AU');
    }

     formatCourseConnectionStudents(connectionList)
    {
        return connectionList.map(item =>{
            let newItem = {};
            newItem.courseConnectionId = item.Id;
            newItem.contactId = item.hed__Contact__r.Id;
            newItem.contactName  = item.hed__Contact__r.Name;
            newItem.sessionId = this.sessionValue;
            newItem.isPresent = false;
            newItem.attendanceId= null;
            return newItem;
        });
    } 

    //Student that has attendance
    sessionChange(event)
    { 
        this.sessionValue = event.detail.value;
        this.selectedRelatedSessions = this.masterList.find(item => item.id == this.offeringValue).sessions;

        //find existing attendance record from session record
        this.selectedSessionData = this.selectedRelatedSessions.find(item => item.Id == this.sessionValue).Attendance_Events__r;     

        //find courseConnection Students from masterlist
        this.selectedRelatedConnections = this.masterList.find(item => item.id == this.offeringValue).courseConnections;

        //format course connection data to desired format
        this.connectionStudentData = this.formatCourseConnectionStudents(this.selectedRelatedConnections);
       
        //if existing attendance data found display record from session, else display record from course connection
        this.studentData = this.selectedSessionData?this.formatStudent(this.selectedSessionData):this.connectionStudentData;
        this.createdAttendance= true;
        this.cantSave = this.connectionStudentData.attendanceId == null?true:false;
    }
    
    handleOfferingChange(event)
    {
        this.offeringValue = event.detail.value;
        //find session
        this.selectedRelatedSessions = this.masterList.find(item => item.id == this.offeringValue).sessions;
        this.sessionData =this.formatSession(this.selectedRelatedSessions);
        this.createdAttendance= false;    
        this.cantSave= true;
    }

    handleAttendanceChange(event)
    {
        
        this.studentData = this.studentData.map(item=>({
            ...item,isPresent:event.target.name === item.courseConnectionId?event.target.checked:item.isPresent,
        }));
        this.cantSave= false;
    }
    
    handleSave()
    {
        this.isSaving=true;
        upsertAttendance({recordsToUpsert:this.createObjectRecord()})
        .then(()=>{
        })
        .finally(()=>{
            refreshApex(this.listOfRecords);
            this.isSaving =false;
            this.generateToast(SUCCESS_TITLE, SUCCESS_MSG, SUCCESS_VARIANT);
            this.cantSave=true;
        })
        .catch(error =>{
            this.generateToast(ERROR_TITLE, LWC_Error_General, ERROR_VARIANT);
            this.isSaving =false;
            this.cantSave=true;
        });``
    }
    
    createObjectRecord(){
        let recordsToUpsert = {};
        recordsToUpsert = this.studentData.map(result =>{
           let attendanceEvent = {};
           if(result.attendanceId){
            attendanceEvent['Id'] = result.attendanceId;
           }
           attendanceEvent['Present__c'] = result.isPresent;
           attendanceEvent['hed__Contact__c'] = result.contactId;
           attendanceEvent['Session__c'] = result.sessionId;
           attendanceEvent['hed__Course_Connection__c'] = result.courseConnectionId; 
           return attendanceEvent;
       })
       return recordsToUpsert; 
   }

   handleCancel()
   {
    this.template.querySelectorAll('lightning-combobox').forEach(each => {
        each.value = null;
    });
    this.createdAttendance= false;
   }

   
    /*
    * generates toasts
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