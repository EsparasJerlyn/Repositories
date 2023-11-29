/**
 * @description An LWC component for Track attendance
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                  | Change Summary                               |
      |---------------------------|-----------------------|-----------------------|----------------------------------------------|
      | adrian.c.habasa           | Febuary 11, 2022      | DEPP-1247             | Created                                      |
      | kathy.cornejo             | July 27, 2022         | DEPP-1771             | Added Section Header                         |
      | kathy.cornejo             | August 31, 2022       | DEPP-2254             | Removed Track Attendance Section from PWP    |
      | alexander.cadalin         | September 05, 2022    | DEPP-4100             | Removed Time from Session Combobox Text      |
      | sebastianne.k.trias       | October 20, 2023      | DEPP-6946             | Fixed lists of registered students           |
 */

import { LightningElement,wire,api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getRelatedCourseOfferingsAndSessions from '@salesforce/apex/TrackAttendanceAndEvaluationCtrl.getRelatedCourseOfferingsAndSessions';
import upsertAttendance  from '@salesforce/apex/TrackAttendanceAndEvaluationCtrl.upsertAttendance';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import RT_ProductRequest_Program from '@salesforce/label/c.RT_ProductRequest_Program';
import RT_ProductRequest_Diagnostic_Tool from '@salesforce/label/c.RT_ProductRequest_Diagnostic_Tool';
import RT_ProductRequest_Indiv_Coaching from '@salesforce/label/c.RT_ProductRequest_Indiv_Coaching';
import RT_ProductRequest_Group_Coaching from '@salesforce/label/c.RT_ProductRequest_Group_Coaching';
import RT_ProductRequest_Program_Without_Pathway from '@salesforce/label/c.RT_ProductRequest_Program_Without_Pathway';
import HAS_PERMISSION from '@salesforce/customPermission/EditDesignAndReleaseTabsOfProductRequest';
import PR_STATUS from '@salesforce/schema/Product_Request__c.Product_Request_Status__c';
import PR_RECORD_TYPE from '@salesforce/schema/Product_Request__c.RecordType.DeveloperName';
import PL_ProductRequest_Completed from '@salesforce/label/c.PL_ProductRequest_Completed';
import PRESCRIBED_CHILD from '@salesforce/schema/Product_Request__c.Child_of_Prescribed_Program__c';

const SUCCESS_TITLE = 'Success!';
const SUCCESS_MSG = 'Record(s) successfully saved.';
const SUCCESS_VARIANT = 'success';
const ERROR_TITLE = 'Error!';
const ERROR_VARIANT = 'error';
const DATE_OPTIONS = { year: 'numeric', month: 'short', day: '2-digit' };
const SECTION_HEADER_OVERVIEW = 'Track Attendance Overview';
const SECTION_HEADER_STUDENTS = 'Registered Students';


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
    columns = [ { label: 'Name', fieldName: 'contactName' }, 
    { label: 'Attendance', fieldName: 'Present__c', type:'boolean', editable: true}];
    activeSections = ['trackAttendance','evaluations'];
    isStatusCompleted;
    showAttendance = false;
    showEvaluation = false;
    recordType;
    
    get hasAccess(){
        return HAS_PERMISSION;
    }
    get sectionHeaderOverview(){ 
        return SECTION_HEADER_OVERVIEW; 
    }
    get sectionHeaderStudents(){ 
        return SECTION_HEADER_STUDENTS; 
    }

    @wire(getRecord, { recordId: '$recordId', fields: [PR_STATUS,PR_RECORD_TYPE,PRESCRIBED_CHILD] })
    handleParentRecord(result){
        if(result.data){
            this.recordType = getFieldValue(result.data,PR_RECORD_TYPE);
            this.isStatusCompleted = getFieldValue(result.data,PR_STATUS) == PL_ProductRequest_Completed;
            this.showAttendance = (getFieldValue(result.data,PR_RECORD_TYPE) !== RT_ProductRequest_Program &&
                                    getFieldValue(result.data,PR_RECORD_TYPE) !== RT_ProductRequest_Program_Without_Pathway);
            this.showEvaluation = !getFieldValue(result.data,PRESCRIBED_CHILD);
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
           if(this.sessionValue){
            this.setOnSessionChange();
           }
           
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
            let itemDateTime = '';
            if(this.recordType === RT_ProductRequest_Indiv_Coaching || this.recordType === RT_ProductRequest_Group_Coaching){
                itemDateTime = item.Date__c!=null? ' (' + this.formatDate(item.Date__c) + ')':'';
            }else if(this.recordType === RT_ProductRequest_Diagnostic_Tool){
                itemDateTime='';
            }else{
                itemDateTime = ' (' + this.formatDate(item.Date__c) + ', ' + this.formatTime(item.Start_Time_v2__c) + ')';
            }

            let newItem = {};
            newItem.value = item.Id;
            newItem.label = item.Name + itemDateTime;
            return newItem;
        });
    }
   
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

    formatTime(milli){
        let time = new Date(milli);
        let hrsMilitary = this.padTimePart(time.getUTCHours());
        let hrs = hrsMilitary === '00' ? 12 : (hrsMilitary >= 13 ? hrsMilitary - 12 : hrsMilitary);
        let min = this.padTimePart(time.getUTCMinutes());
        let meridiem = hrsMilitary < 12 ? 'am' : 'pm';
        return hrs + ":" + min + " " + meridiem;
    }

    padTimePart(timePart){
        return ('00' + timePart).slice(-2);
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

    formatStudentList(connectionList, attendanceList){
        return connectionList.map(item => {
            let attendanceEventRecord = attendanceList.find(attendance => attendance.hed__Course_Connection__r.hed__Contact__c == item.hed__Contact__r.Id);
            let newItem = {};
            newItem.courseConnectionId = item.Id;
            newItem.contactId = item.hed__Contact__r.Id;
            newItem.contactName  = item.hed__Contact__r.Name;
            newItem.sessionId = this.sessionValue;
            newItem.isPresent = attendanceEventRecord ? attendanceEventRecord.Present__c : false;
            newItem.attendanceId= attendanceEventRecord ? attendanceEventRecord.Id : null;
            return newItem;
        });
    }

    sessionChange(event)
    { 
        this.sessionValue = event.detail.value;
        this.setOnSessionChange();
    }

    setOnSessionChange(){
        this.selectedRelatedSessions = this.masterList.find(item => item.id == this.offeringValue).sessions;
        this.selectedSessionData = this.selectedRelatedSessions.find(item => item.Id == this.sessionValue).Attendance_Events__r;
        this.selectedRelatedConnections = this.masterList.find(item => item.id == this.offeringValue).courseConnections;
        this.connectionStudentData = this.formatCourseConnectionStudents(this.selectedRelatedConnections); 
        this.studentData = this.selectedSessionData?this.formatStudentList(this.selectedRelatedConnections, this.selectedSessionData):this.connectionStudentData;
        this.createdAttendance= true;
        this.cantSave = this.connectionStudentData.attendanceId == null?true:false;
    }
    
    handleOfferingChange(event)
    {
        this.offeringValue = event.detail.value;
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


    generateToast(_title,_message,_variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }
}