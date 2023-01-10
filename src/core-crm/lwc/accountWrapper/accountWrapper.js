/**
 * @description parent wrapper of accountName component
 *
 * @see ..
 * @see accountName
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | marygrace.li              | November 22, 2022     | DEPP-4693            | Created file                                 |
*/

import { LightningElement, track, api, wire} from 'lwc';
import getAllAccountName from '@salesforce/apex/MainNavigationMenuCtrl.getAllAccountName';
import userId from "@salesforce/user/Id";
import { truncateText } from 'c/commonUtils';
import payloadContainerLMS from '@salesforce/messageChannel/AccountId__c';
import { publish, MessageContext } from 'lightning/messageService';
const CHAR_LEN = 2;
const STORED_ACCTID = "storedAccountId";

export default class AccountWrapper extends LightningElement {

    error;
    @api selectedAccount;
    @track selectedAccountName;
    @track fullLabel;
    accountNameOptions;
    @track isSelected;
    @track selected; //new
    @track accountSelected;
    @track isPrimaryAccount;

    subscription;
    accountId;
    accountName;
    fullLabel;
    hasSession = false;
    
    parameterObject = {
        accountId: '',
        accountName: this.selectedAccountName,
        fullLabel: this.fullLabel,
        storeAccountId: ''
      }


    @wire(MessageContext)
    messageContext;


    renderedCallback(){
        if(sessionStorage.getItem(STORED_ACCTID)){
            //An Id key is in the session Storage
            this.accountSelected = sessionStorage.getItem(STORED_ACCTID);
        } 
        this.getAllAccountName();
    }
    

    getAllAccountName(){
        getAllAccountName({ userId: userId, selectedAccountId: this.accountSelected })
        .then((result) => {
            this.accountNameOptions = result.accountNames;
      
            for (const acct of result.accountNames) {

                //onchange
                if(acct.isSelected && this.accountSelected){
                        
                    this.selectedAccount =  acct.value;
                    this.selectedAccountName =  truncateText(acct.label, CHAR_LEN);
                    this.fullLabel = acct.fullLabel;
                   // this.isSelected = acct.isSelected;

                }else{
                    if(acct.isPrimaryAccount && !this.accountSelected){
                        this.selectedAccount =  acct.value;
                        this.selectedAccountName =  truncateText(acct.label, CHAR_LEN);
                        this.fullLabel = acct.fullLabel;
                        //this.isSelected = acct.isSelected;
                        //this.isPrimaryAccount = acct.isPrimaryAccount;
                    }
                }
            }
          
        }).catch((error) => {
            this.error = error;
        });
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
       // window.location.reload();

    }  

    handleValueChange(event) {
        this.accountSelected = event.detail;
        this.publishLMS();
    }

}