/**
 * @description A LWC component for reusable Toast Message
 *
 * @see ../lwc/customCorporateLogin
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                   |
      |---------------------------|-----------------------|----------------------|--------------------------------------------------|
      | mary.grace.j.li           | September 12, 2022    | DEPP-4225            | Created file                                     |
*/

import { LightningElement, track, api } from 'lwc';

export default class CustomToast extends LightningElement {

    @track type;
    @track message;
    @track variant;
    @track showToastBar = false;
    @api autoCloseTime = 8000;


    @api
    showToast(type, message, variant) {
        this.type = type;
        this.message = message;
        this.showToastBar = true;
        this.variant = variant;
        setTimeout(() => {
            this.closeModel();
        }, this.autoCloseTime);
    }

    closeModel() {
        this.showToastBar = false;
        this.type;
        this.message;
        this.variant;
    }

    get getIconName() {
        return 'utility:' + this.type;
    }

    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.type + ' slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }

    get outerClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.type;
    }
}