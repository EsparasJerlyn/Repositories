/**
 * @description A custom LWC for adding new sessions
 * 
 * @see ../productOffering
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                         |
      |---------------------------|-----------------------|--------------|--------------------------------------------------------|
      | angelika.j.s.galang       | February 11, 2022     | DEPP-1258    | Created file                                           | 
      |                           |                       |              |                                                        |
*/
import { LightningElement, api } from 'lwc';
import SESSION_OBJECT from '@salesforce/schema/Session__c';
import getLayoutMapping from '@salesforce/apex/CustomCreateEditRecordCtrl.getLayoutMapping';
import SESSION_NAME from '@salesforce/schema/Session__c.Name';

const SESSION = 'Session';
export default class AddNewSession extends LightningElement {
    @api courseOfferingId; //id of parent course offering
    @api customLookupItems; //list of search items
    @api courseConnectionId;

    layoutToDisplay = [];
    lookupItemsFormatted = [];
    activeSections = [];
    showFacilitatorError = false;

    get sessionApiName(){
        return SESSION_OBJECT.objectApiName;
    }

    connectedCallback(){
        this.lookupItemsFormatted = this.customLookupItems.map(item =>{
            return {
                id:item.Id,
                label:item.contactName,
                meta:item.Name,
            }
        });
        getLayoutMapping({ objApiName : this.sessionApiName, forOpe : true })
        .then((result) => {
            this.layoutToDisplay = [...result].map((layout) => {
                let layoutItem = {};
                layoutItem.sectionLabel = layout.MasterLabel;
                layoutItem.leftColumn = layout.Left_Column_Long__c ?
                    JSON.parse(layout.Left_Column_Long__c).map(layoutItem => {
                        return {
                            ...layoutItem,
                            value : layoutItem.field == SESSION_NAME.fieldApiName ? SESSION : undefined
                        }
                    }) : null;
                layoutItem.rightColumn = layout.Right_Column_Long__c ?
                    JSON.parse(layout.Right_Column_Long__c) : null;
                layoutItem.singleColumn = layout.Single_Column_Long__c ?
                    JSON.parse(layout.Single_Column_Long__c) : null;
                return layoutItem;
            });
            this.activeSections = this.layoutToDisplay.map(layout => {return layout.sectionLabel});
        })
        .catch((error) => {
        })
    }
    
    handleLookupSelect(event){
        this.courseConnectionId = event.detail.value;
        this.showFacilitatorError = false;
    }

    handleLookupRemove(){
        this.courseConnectionId = '';
    }

    handleSubmitSession(event){
        event.preventDefault();
        let fields = event.detail.fields;
        if(!fields.Is_Managed_Externally__c && !this.courseConnectionId){
            this.showFacilitatorError = true;
        }else{
            let lookupItem = this.customLookupItems.find(item => item.Id == this.courseConnectionId);
            fields.Facilitator__c = lookupItem ? lookupItem.hed__Contact__c : undefined;
            fields.Course_Connection__c = this.courseConnectionId;   
            fields.Course_Offering__c = this.courseOfferingId;
        }
        this.template.querySelector("lightning-record-edit-form").submit(fields);
    }

    handleSuccessSession(){
        const successEvent = new CustomEvent('sessionsuccess');
        this.dispatchEvent(successEvent);
    }

    handleCloseSession(){
        const closeEvent = new CustomEvent('sessionclose');
        this.dispatchEvent(closeEvent);
    }
}