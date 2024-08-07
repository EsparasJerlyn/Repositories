/**
 * @description lwc for registration of Individual and Organisation
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                              |
      |---------------------------|-----------------------|----------------------|-------------------------------------------------------------|
      | nicole.genon              | July 7, 2024          | DEPP-9163            | Created file                                                | 
 */
import { LightningElement, api, track } from 'lwc';
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";

const HEADER ="Tell us about you";
const SUBHEADER = "Register to donate";
const QUT_LOGIN_TEXT = "Previously told us about you? Continue here.";

export default class RegistrationIndividualAndOrganisation extends LightningElement {
    @api isModal;
    @api portalName;
    @api startURL;
    @api title;

    @track header;
    @track subHeader;

    xButton;
    displayForm = true;
    isLoginPage = false;

    label = {
        header: HEADER,
        subHeader: SUBHEADER,
        qutLoginText: QUT_LOGIN_TEXT
    };

    get classContainer() {
        return this.isModal === true ? 'modal-content text px3 pt2' : '';
    }

    get classMainContainer() {
        return this.isModal === true ? 'modal' : '';
    }

    connectedCallback(){
        this.xButton = qutResourceImg + "/QUTImages/Icon/xMark.svg";
    }

    /*
    * Closes Modal when called
    */
    closeModal() {
        if (!this.isLoginPage) {
        this.dispatchEvent(new CustomEvent("close"));
        }
    }

    handleOpenLogin() {
        this.dispatchEvent(
            new CustomEvent("openlogin", {
                detail: {
                    startURL: this.startURL
                }
            })
        );
    }
}