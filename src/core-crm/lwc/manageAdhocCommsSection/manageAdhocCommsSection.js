/**
 * @description A custom LWC for the Manage Ad-hoc Communication under Product Offering
 *
 * @see ../classes/ManageAdhocCommsSectionCtrl.cls
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                         |
      |---------------------------|-----------------------|--------------|--------------------------------------------------------|
      | angelika.j.s.galang       | April 6, 2022         | DEPP-2229    | Created file                                           | 
      | eugene.andrew.abuan       | October 10, 2023      | DEPP-6612    | Removed action send button and added Send Date         |
      |                           |                       |              |                                                        |

*/
import { LightningElement, api, wire, track } from 'lwc';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import DOC_Email_Header from "@salesforce/label/c.DOC_Email_Header";
import DOC_Email_Footer from "@salesforce/label/c.DOC_Email_Footer";
import ADHOC_COMMS from "@salesforce/schema/Adhoc_Communication__c";
import AC_COURSE_OFFERING from '@salesforce/schema/Adhoc_Communication__c.Course_Offering__c';
import AC_PROGRAM_OFFERING from '@salesforce/schema/Adhoc_Communication__c.Program_Offering__c';
import getAdhocCommunications from '@salesforce/apex/ManageAdhocCommsSectionCtrl.getAdhocCommunications';
import getHeaderAndFooterImageUrls from '@salesforce/apex/ManageAdhocCommsSectionCtrl.getHeaderAndFooterImageUrls';

const DATE_OPTIONS = { year: 'numeric', month: '2-digit', day: '2-digit' };
const ADHOC_ACTIONS = [
    { label: 'Edit', name: 'edit' }
];
const ADHOC_COLUMNS = [
    {
        fieldName: 'Name',
        label: 'Name',
        initialWidth: 200
    },
    {
        fieldName: 'Subject__c',
        label: 'Subject'
    },
    {
        fieldName: 'Send_Date__c',
        label: 'Send Date',
        type:'Date',
        initialWidth: 200
    },
    {
        fieldName: 'IsSent__c',
        label: 'IsSent',
        type:'boolean',
        initialWidth: 100
    },
    {
        fieldName: 'CreatedDate',
        label: 'Created Date',
        initialWidth: 200
    },
    {
        type: 'action',
        typeAttributes: { rowActions: ADHOC_ACTIONS }
    },     
]; 
const EMAIL_CONTENTS = {
    header : DOC_Email_Header,
    footer : DOC_Email_Footer
};
export default class ManageAdhocCommsSection extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api offeringId;
    @api isStatusCompleted;
    @api isProgram;

    adhocColumns = ADHOC_COLUMNS;
    adhocData = [];
    showComms = false;
    isLoading = false;
    adhocIdToEdit;
    defaultEmailContent;
    
    //returns offering from field from adhoc depending on product request record type
    get adhocOfferingField(){
        return this.isProgram ? AC_PROGRAM_OFFERING.fieldApiName : AC_COURSE_OFFERING.fieldApiName;
    }

    //returns adhoc communication object api name
    get adhocApiName(){
        return ADHOC_COMMS.objectApiName;
    }

    //returns true when adhoc data is empty
    get isAdhocDataEmpty(){
        return this.adhocData.length == 0;
    }

    //fetches related adhoc communication records via apex
    adhocResult = [];
    @wire(getAdhocCommunications, { 
        productOfferingId : "$offeringId", 
        offeringField : "$adhocOfferingField"
    })
    handleGetAdhocCommunications(result){
        if(result.data){
            this.adhocResult = result;
            this.adhocData = this.adhocResult.data.map(adhoc => {
                return {
                    ...adhoc,
                    Send_Date__c : new Date(adhoc.Send_Date__c).toLocaleDateString('en-AU',DATE_OPTIONS),
                    CreatedDate : new Date(adhoc.CreatedDate).toLocaleDateString('en-AU',DATE_OPTIONS)
                }
            });
        }else if(result.error){
            this.generateToast('Error.',LWC_Error_General,'error');
        }
    }
    
    //fetches the document id of email header & footer via apex
    //and sets it as default value of Email Content field on create of adhoc comms
    connectedCallback(){
        let _imageInfos = [
            {
                imageName : EMAIL_CONTENTS.header
            },
            {
                imageName : EMAIL_CONTENTS.footer
            }
        ];
        getHeaderAndFooterImageUrls({ imageInfos : JSON.stringify(_imageInfos) })
        .then(result => {
            let emailHeaderUrl = result.find(res => res.imageUrl.includes(EMAIL_CONTENTS.header)).imageUrl;
            let emailFooterUrl = result.find(res => res.imageUrl.includes(EMAIL_CONTENTS.footer)).imageUrl
            this.defaultEmailContent = {
                Email_Content__c : 
                    '<img src="' + emailHeaderUrl + '"><br><br><br><br>' +
                    '<img src="' + emailFooterUrl + '">'
            };
        })
        .catch(error => {
            this.generateToast("Error.", LWC_Error_General, "error");
        });
    }

    //shows create modal
    handleNewComms(){
        this.showComms = true;
    }

    //saves adhoc comms record
    handleSaveComms(event){
        if(event.detail.Id){
            this.handleUpdateRecord(event.detail,'Adhoc Communication updated.');
        }else{
            const fields = {...event.detail};
            fields[this.adhocOfferingField] = this.offeringId;
            this.handleCreateRecord(fields,this.adhocApiName);
        }
    }

    //hides create modal
    handleCloseComms(){
        this.showComms = false;
        this.adhocIdToEdit = undefined;
    }

    //handles row actions of datatable
    handleRowAction(event){
        let row = event.detail.row;
        let actionName = event.detail.action.name;
        //opens edit modal for adhoc comms
        if(actionName == 'edit'){
            this.adhocIdToEdit = row.Id;
            this.showComms = true;
        }
    }

    //handler for creating adhoc comms records
    handleCreateRecord(fields,objectType){
        this.isLoading = true;
        const recordInput = { apiName: objectType, fields };
        createRecord(recordInput)
        .then(record => {
            this.generateToast("Success!", 'Adhoc Communication created.', "success");
        })
        .catch(error => {
            this.generateToast("Error.", LWC_Error_General, "error");
        })
        .finally(() => {
            refreshApex(this.adhocResult);
            this.isLoading = false;
        });
    }

    //updates adhoc comms record and saves to the database
    handleUpdateRecord(fields,toastMsg){
        this.isLoading = true;
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            this.generateToast("Success!", toastMsg, "success");
        })
         .catch((error) => {
            this.generateToast("Error.", LWC_Error_General, "error");
        })
        .finally(() => {
            refreshApex(this.adhocResult);
            this.isLoading = false;
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