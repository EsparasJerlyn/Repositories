/**
 * @description A LWC component to display page banner
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | mary.grace.li             | November 22, 2022     | DEPP-4693            | Updated welcome name account                 |
*/

import { LightningElement } from 'lwc';
import { wire} from 'lwc';
import individualBanner from '@salesforce/resourceUrl/individualBanner';
import homeBanner from '@salesforce/resourceUrl/homeBanner';
import orgBanner from '@salesforce/resourceUrl/orgBanner';
import logo from '@salesforce/resourceUrl/qutexlogo';
import userId from "@salesforce/user/Id";
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import payloadContainerLMS from '@salesforce/messageChannel/AccountId__c';
const STUDY_STORE = 'study';
const STORED_ACCTNAME ="storedAccountName";
export default class PageBanner extends LightningElement {
    accountId;
    name;
    welcomeName;
    accountNameOptions;
    accountId;
    accountName;
    fullLabel;
	subscription;

	@wire(MessageContext)
    messageContext;

    renderedCallback(){
        this.subscribeLMS();
    }

    qutexlogo = logo;
    /**
    * Handles banner for OPE
    */
    get individualBannerStyle() {
        return `background-image:url(${individualBanner})`;
    }

    /**
    * Handles banner for CCE
    */
    get orgBannerStyle() {
        return `background-image:url(${orgBanner})`;
    }

    /**
    * Handles home banner for OPE/CCE
    */
    get homeBannerStyle() {
        return `background-image:url(${homeBanner})`;
    }

    /**
    * Handles store checking
    */
    get showIfStudy() {
        return (window.location.href.indexOf(STUDY_STORE) > -1 ? true : false);
    }

    /**
    * Handles banner text
    */
    get bannerText() {
        let text = '';
        if (this.showIfStudy) {
            text += `Get future fit, fast with our selection of short courses, masterclasses and open programs, designed to help you upskill or reskill to advance your career.`;
        } else {
            text += `Get your team future fit, fast with tailored executive education designed to meet the exact needs of your organisation.`;
        }
        return text;
    }


    get getSelectedAccountName(){
        let label = this.fullLabel !=undefined ?  this.fullLabel : '';
        let welcome = this.welcomeName = 'Welcome ' + label;
        return this.fullLabel !=undefined ? welcome : welcome;
    }

    disconnectedCallback() {
        this.unsubscribeLMS();
    }

    unsubscribeLMS(){
        unsubscribe(this.subscription);
        this.subscription = null;
    }


    subscribeLMS() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext, 
                payloadContainerLMS, 
                (message) => this.validateValue(message));
        }
    }

    validateValue(val) {
        if (val && val.accountIdParameter) {
            let newValObj = JSON.parse(val.accountIdParameter);
    
               this.accountId = newValObj.accountId;
               this.accountName = newValObj.accountName;
               this.fullLabel = newValObj.fullLabel

            this.parameterObject = {
                userId : userId,
                categoryId : "",
                accountId: this.accountId,
                accountName: this.accountName,
                fullLabel: this.fullLabel
              }

              sessionStorage.setItem(STORED_ACCTNAME,this.fullLabel);
        }
    }
}