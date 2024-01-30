/**
 * @description Lightning Web Component for add from existing list buttons.
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | jerlyn.esparas            | January 22, 2024      | DEPP-7004            | Created file                 | 
 */

import { LightningElement, wire, track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSearchedLists from '@salesforce/apex/ListCtrl.getSearchedLists';

export default class AddFromExistingList extends LightningElement {
    @api recordId;
    error;

    content = 'The modal content';
    header = 'The modal header';
    size = 'slds-modal_medium';
    result;

    selectedList;
    
    selectedListId;
    searchListInProgress = false;
    listSearchItems = [];
    objectLabelName = 'List__c';
    // sets header change
    handleHeaderChange(event) {
        this.header = event.target.value;
    }
    // sets for content change
    handleContentChange(event) {
        this.content = event.target.value;
    }
    // modal size
    handleModalSizeChange(event) {
        this.size = event.target.value;
    }
    // closing the modal
    handleCloseModal() {
        this.dispatchEvent(new CustomEvent('handleshowmodalexistinglist', {detail:false}));
    }
    // sets the list selection
    handleListSelection(event){
        this.selectedList = event.target.value;
    }

    //returns list of list based on input
    handleSearchList(event){
    this.searchListInProgress = true;
    getSearchedLists({ filterString: event.detail.filterString, recordId : this.recordId })
        .then(result =>{
            this.listSearchItems = result;
        })
        .finally(()=>{
            this.searchListInProgress = false;
        })
        .catch(error =>{
            this.showErrorToast();
        });
    }

     //sets selected list id
     handleListSelect(event){
        this.selectedListId = event.detail.value;
    }

    //removes selected list
    handleListRemove(){
        this.selectedListId = undefined;
        this.listSearchItems = [];
    }

    //Toast Message
    showToast(title,message,variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt)
    }
    // sets save existing list 
    handleSaveExistingList(){
        this.dispatchEvent(new CustomEvent('handlesavelistmember', {detail:this.selectedListId}));
        this.handleCloseModal();
    }

}