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
import getAllRelatedBusinessAccountOfUser from '@salesforce/apex/MainNavigationMenuAccountCtrl.getAllRelatedBusinessAccountOfUser';
import userId from "@salesforce/user/Id";
import { truncateText } from 'c/commonUtils';
import payloadContainerLMS from '@salesforce/messageChannel/AccountId__c';
import { publish, MessageContext } from 'lightning/messageService';
const CHAR_LEN = 2;
const STORED_ACCTID = "storedAccountId";
const STORED_ASSETID = "storedAssetId";
const STORED_BUYERGROUPID = "storedBuyerGroupId";
export default class AccountWrapper extends LightningElement {

    error;
    @api selectedAccount;
    @track selectedAccountName;
    @track fullLabel;
    accountNameOptions;
    @track isSelected;
    @track selected; //new
    @track accountSelected = '';
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

    businessAccounts;
    @wire(getAllRelatedBusinessAccountOfUser, { userId: userId, selectedAccountId: '$accountSelected'})
    wiredBusinessAccounts(result) {        
        if (result.data !=undefined) {
            this.accountNameOptions = result.data.accountOptions;
            this.accountNameOptions.sort((a,b)=>a.label.localeCompare(b.label));
            for (const acct of result.data.accountOptions) {
                if(acct.isPrimaryAccount && !this.accountSelected){
                    this.selectedAccount =  acct.value;
                    this.selectedAccountName =  truncateText(acct.label, CHAR_LEN);
                    this.fullLabel = acct.fullLabel;
                    sessionStorage.setItem(STORED_ACCTID, this.selectedAccount);
                    this.publishLMS();
                }
            }
        } else if (result.error) {
            this.error = result.error;
            console.error('Error: ' + JSON.stringify(result.error));
        }
    }

    getAllRelatedBusinessAccountOfUser(){
        getAllRelatedBusinessAccountOfUser({ userId: userId, selectedAccountId: this.accountSelected })
        .then((result) => {
            this.accountNameOptions = result.accountOptions;
            this.accountNameOptions.sort((a,b)=>a.label.localeCompare(b.label));
      
            for (const acct of result.accountOptions) {

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
    }  

    handleValueChange(event) {
       /* this.accountSelected = event.detail;
        sessionStorage.setItem(
            STORED_ASSETID,
            ''
        );
        sessionStorage.setItem(
            STORED_BUYERGROUPID,
            ''
        );
        this.publishLMS();*/
    }

}