import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createBuyerGroupMember from '@salesforce/apex/BuyerGroupMemberRelatedListCtrl.createBuyerGroupMember';
import getBuyerGroupRecord from '@salesforce/apex/BuyerGroupMemberRelatedListCtrl.getBuyerGroupRecord';
import getRelatedBuyerGroupMembersList from '@salesforce/apex/BuyerGroupMemberRelatedListCtrl.getRelatedBuyerGroupMembersList';
import getSearchedAccounts from '@salesforce/apex/BuyerGroupMemberRelatedListCtrl.getSearchedAccounts';
import BGM_DEVNAME from '@salesforce/schema/BuyerGroupMember';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';

const COLUMNS = [
    { label: 'Name', fieldName: 'BuyerName' }
];

export default class BuyerGroupMembersRelatedList extends LightningElement {
    @api recordId;

    isAddButtonDisabled = true;
    isAddingRecord = false;
    isEmptyList = true;
    isLoading = false;
    searchAccountInProgress = false;
    showOwnerError = false;
    
    error;

    selectedAccountId;
    buyerGroupId;
    listCount = 0;

    buyerGroupMembersList = [];
    lookupItemsFormatted = [];
    accountSearchItems = [];

    connectedCallback() {
        this.isLoading = true;
        getBuyerGroupRecord({ recordId: this.recordId })
            .then(result => {
                this.buyerGroupId = result;
            })
            .catch(error => {
                this.buyerGroupMembersList = undefined
                this.isAddButtonDisabled = true;
                this.showErrorToast();
            })
            .finally(() => {
                this.isLoading = false;
            });
        this.getRelatedBuyerGroupMembersListHandler();
    }

    getRelatedBuyerGroupMembersListHandler() {
        this.isLoading = true;
        getRelatedBuyerGroupMembersList({ recordId: this.recordId })
            .then(result => {
                if(result.length === 0) {
                    this.isEmptyList = true;
                } else {
                    this.isEmptyList = false;
                    this.listCount = result.length;
                    let groomedResultList = [];
                    result.forEach(element => {
                        let groomedResultItem = {};
                        groomedResultItem.Id = element.Id;
                        groomedResultItem.BuyerName = element.Buyer.Name;
                        groomedResultList.push(groomedResultItem);
                    });
                    groomedResultList.sort();
                    this.buyerGroupMembersList = groomedResultList;
                }
                this.isAddButtonDisabled = false;
                this.error = undefined;
            })
            .catch(error => {
                this.buyerGroupMembersList = undefined;
                this.isAddButtonDisabled = true;
                this.error = error;
                this.showErrorToast();
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleOnClickAdd() {
        this.isAddingRecord = true;
    }

    handleModalCancel() {
        this.isAddingRecord = false;
    }

    handleModalSave() {
        this.isLoading = true;
        createBuyerGroupMember({ buyerId: this.selectedAccountId, buyerGroupId: this.buyerGroupId })
            .then((result) => {
                this.buyerGroupMembersList = [];
                this.getRelatedBuyerGroupMembersListHandler();
                this.error = undefined;
            })
            .catch(error => {
                this.buyerGroupMembersList = undefined;
                this.isAddButtonDisabled = true;
                this.error = error;
                this.showErrorToast();
            })
            .finally(() => {
                this.isAddingRecord = false;
                this.handleAccountRemove();
            });
    }

    //returns list of accounts based on input
    handleAccountSearch(event){
        this.searchAccountInProgress = true;
        getSearchedAccounts({ filterString: event.detail.filterString, recordId: this.recordId })
            .then(result =>{
                this.accountSearchItems = result;
            })
            .finally(()=>{
                this.searchAccountInProgress = false;
            })
            .catch(error =>{
                this.showErrorToast();
            });
    }

    //sets selected account id
    handleAccountSelect(event){
        this.showOwnerError = false;
        this.selectedAccountId = event.detail.value;
    }

    //removes selected account
    handleAccountRemove(){
        this.selectedAccountId = undefined;
        this.accountSearchItems = [];
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: LWC_Error_General,
            variant: 'error'
        })
        this.dispatchEvent(event);
    }

    get columns() { return COLUMNS; }
    get buyerGroupMemberApiName() { return BGM_DEVNAME; }
}