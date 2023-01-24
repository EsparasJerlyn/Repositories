/**
 * @description A LWC component to display account name  selection
 *
 * @see ..
 * @see accountWrapper
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | marygrace.li              | November 22, 2022     | DEPP-4693            | Created file                                 |
*/
import { LightningElement, wire, api} from 'lwc';
import customSR from "@salesforce/resourceUrl/QUTMainCSS";
import { loadStyle } from "lightning/platformResourceLoader";
import { publish, MessageContext } from 'lightning/messageService';
import payloadContainerLMS from '@salesforce/messageChannel/AccountId__c';
const STORED_ACCTID = "storedAccountId";
export default class AccountName extends LightningElement {

    @api accountNameOptions = [];
    @api selectedAccount;
    @api selectedAccountName;
    @api fullLabel;
    @api isSelected;
    @api isPrimaryAccount;
    accountName;

    @api accountSelected;
    showAccount;

    @wire(MessageContext)
    messageContext;

    renderedCallback(){
        Promise.all([loadStyle(this, customSR + "/QUTCSS.css")]);
        this.publishLMS();

        if(this.selectedAccount && this.showAccount){
            const selected = this.template.querySelector(`a[data-id="${this.selectedAccount}"]`)
            selected.classList.add('selectedValue');
        }
    }

    handleAccountSelected(event) {
        this.accountSelected = event.target.dataset.id;
        this.selectedAccount = event.target.dataset.id;
        this.selectedAccountName = event.target.dataset.name;
        this.fullLabel = event.target.dataset.fullname;
        this.isSelected = true;

        sessionStorage.setItem(STORED_ACCTID,this.accountSelected);

         // Creates the event with the data.
        const selectedEvent = new CustomEvent("valuechange", {
            detail: this.selectedAccount,
            
        });
  
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        this.publishLMS();

        const prevSelected = this.template.querySelector(".selectedValue")
        prevSelected.classList.remove('selectedValue');

        const selected = this.template.querySelector(`a[data-id="${this.selectedAccount}"]`)
        selected.classList.add('selectedValue');

        window.location.reload();

    }

    handleAccountSelectedMobile(event) {
        this.accountSelected = event.detail.value;
        this.selectedAccount = event.detail.value;
        this.selectedAccountName =  event.detail.label;
        this.fullLabel = event.detail.fullLabel;
        this.isSelected = true;

        sessionStorage.setItem(STORED_ACCTID,this.accountSelected);

        // Creates the event with the data.
       const selectedEvent = new CustomEvent("valuechange", {
           detail: this.selectedAccount,
           
       });
  
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        this.publishLMS();
        window.location.reload();
    }

    publishLMS() {
        let paramObj = {
            accountId: this.selectedAccount,
            accountName: this.selectedAccountName,
            fullLabel: this.fullLabel
        }
    
        const payLoad = {
            accountIdParameter: JSON.stringify(paramObj)
        };
    
        publish(this.messageContext, payloadContainerLMS, payLoad);
    } 

    handleToggle(){
        this.showAccount = !this.showAccount;
    }
}