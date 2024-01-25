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

    // handleStatusChange(event) {
    //     console.log("event detail",event.detail.status);
     
    //     if(event.detail.status === "FINISHED") {
        
    //         //Get the flow output variable and store it.
    //         const outputVariables = event.detail.outputVariables;
    //             for(let i= 0; i < outputVariables.length; i++) {
    //                 const outputVar = outputVariables[i];
    //                 //contactId is a variable created in flow.
    //                 if(outputVar.name === 'Id') {
    //                     console.log(outputVar.value);
    //                     if(outputVar.value != null){
    //                     //Call ShowToast Function
    //                     this.showToast("Success","List Created Sucessfully","success");
    //                     //Pass the contactId variable value to navigateToRecord.
    //                     this.navigateToRecord(outputVar.value);

    //                     }else{
    //                         console.log('list is not created');
    //                     }
                        
    //                 }
    //             }
    //     }
    //     if(event.detail.status === "ERROR") {
    //         this.showToast("error","Error occurred while creation of list","error");
    //     }
    // }

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