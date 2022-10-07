/**
 * @description A LWC component to allow learner to corporate learners to login
 *
 * @see ../classes/RegistrationFormCtrl.cls
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                        |
      |---------------------------|-----------------------|----------------------|---------------------------------------|
      | eugene.andrew.abuan       | September 11, 2022    | DEPP-4225            | Created file                          |
      | dodge.j.palattao          | September 28, 2022    | DEPP-4466            | Fix for mobile input                  |
*/
import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import sendRegistrationEmailOTP from "@salesforce/apex/RegistrationFormCtrl.sendRegistrationEmailOTP";
import loginCorporateUser from "@salesforce/apex/RegistrationFormCtrl.loginCorporateUser";
import getCommunityUrl from "@salesforce/apex/RegistrationFormCtrl.getCommunityUrl";
import loginExistingUser from "@salesforce/apex/RegistrationFormCtrl.loginExistingUser";
import { loadStyle } from "lightning/platformResourceLoader";
// import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import customCSS from "@salesforce/resourceUrl/QUTMainCSS";
import { checkPasteIfNumeric, preventNonNumbersInInput } from 'c/commonUtils';



const REQUIRED_ERROR_MESSAGE = "Field is required.";
const EMAIL_NOT_VALID = "Please enter a valid email.";
const SHOW_ERROR_MESSAGE_ATTRIBUTE = "required-color ";
const SHOW_ERROR_BOARDER_ATTRIBUTE = "slds-input input-element border-error";
const HIDE_ERROR_MESSAGE_ATTRIBUTE = "error-message error-message-hide";
const HIDE_ERROR_BOARDER_ATTRIBUTE = "slds-input input-element";
const LWC_ERROR_GENERAL = "An error has been encountered. Please contact your administrator.";
export default class CustomCorporateLogin extends LightningElement {


    email = null;
    mobile = null;
    displayLogin;
    displayVerification

    //OTP Variables
    loginUser = {};
    userOTP;
    verifyOTP;
    startURL;

    //error variables
    emailErrorMessage;
    hasErrorEmail;
    hasErrorMobile;
    noResults;
    @track requiredDisplayData = {};
    @track requiredInputClass = {};

    /* Load Custom CSS */
    renderedCallback() {
        Promise.all([loadStyle(this, customCSS + "/QUTCSS.css")]);

    }


    connectedCallback() {
        this.displayLogin = true;
        this.displayVerification = false;
        this.noResults = false;
        this.requiredInputClass.email = HIDE_ERROR_BOARDER_ATTRIBUTE;
        this.requiredDisplayData.email = HIDE_ERROR_MESSAGE_ATTRIBUTE;

        this.requiredInputClass.mobile = HIDE_ERROR_BOARDER_ATTRIBUTE;
        this.requiredDisplayData.mobile = HIDE_ERROR_MESSAGE_ATTRIBUTE;
        this.requiredDisplayData.noContact = HIDE_ERROR_MESSAGE_ATTRIBUTE;


        // Generate Start URL
        getCommunityUrl()
            .then((res) => {
                this.startURL = res.comSiteCCE + '/s';
            })
            .catch((error) => {
                this.errorMessage =
                    LWC_ERROR_GENERAL + this.generateErrorMessage(error);
            });
    }

    //Sets the email via event
    handleEmailInput(event) {
        this.email = event.target.value;
    }

    //Sets the mobile via event
    handleMobileInput(event) {
        this.mobile = event.target.value;
    }

    //Handle Login Process when Login button is clicked
    handleLogin(event) {
        event.preventDefault();

        // Check if required fields are empty;
        this.checkInputIsEmpty();

        if (this.email && this.mobile) {
            let emailCheck = /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(this.email);

            if (emailCheck == null || emailCheck == undefined || emailCheck == false) {
                this.hasErrorEmail = true;
                this.emailErrorMessage = EMAIL_NOT_VALID;
                this.requiredDisplayData.email = SHOW_ERROR_MESSAGE_ATTRIBUTE;
                this.requiredInputClass.email = SHOW_ERROR_BOARDER_ATTRIBUTE;
                return;
            }
            this.noResults = false;
            this.mobile = this.mobile.toString();
            loginCorporateUser({ email: this.email, mobile: this.mobile })
                .then((res) => {
                    if (res != null) {
                        //Genereate OTP if Contact Info Match
                        this.loginUser = res[0];
                        this.displayLogin = false;
                        this.displayVerification = true;
                        this.sendEmailOTP();
                    } else {
                        //Generate Error if No Match
                        this.noResults = true;
                        this.requiredDisplayData.noContact = SHOW_ERROR_MESSAGE_ATTRIBUTE
                    }
                })
                .catch((error) => {
                    this.errorMessage =
                        LWC_ERROR_GENERAL + this.generateErrorMessage(error);
                });
        }

    }

    // Checks if the required fields are empty
    checkInputIsEmpty() {
        if (!this.email) {
            this.hasErrorEmail = !this.email;
            this.emailErrorMessage = REQUIRED_ERROR_MESSAGE;
            this.requiredDisplayData.email = SHOW_ERROR_MESSAGE_ATTRIBUTE;
            this.requiredInputClass.email = SHOW_ERROR_BOARDER_ATTRIBUTE;
        } else {
            this.hasErrorEmail = false;
            this.requiredDisplayData.email = HIDE_ERROR_MESSAGE_ATTRIBUTE;
            this.requiredInputClass.email = HIDE_ERROR_BOARDER_ATTRIBUTE;
        }

        if (!this.mobile) {
            this.hasErrorMobile = !this.mobile;
            this.requriedErrorMessage = REQUIRED_ERROR_MESSAGE;
            this.requiredDisplayData.mobile = SHOW_ERROR_MESSAGE_ATTRIBUTE;
            this.requiredInputClass.mobile = SHOW_ERROR_BOARDER_ATTRIBUTE;
        } else {
            this.hasErrorMobile = false;
            this.requiredDisplayData.mobile = HIDE_ERROR_MESSAGE_ATTRIBUTE;
            this.requiredInputClass.mobile = HIDE_ERROR_BOARDER_ATTRIBUTE;
        }

    }

    // Handle Email OTP Send
    sendEmailOTP() {
        sendRegistrationEmailOTP({ email: this.email })
            .then((result) => {
                if (result) {
                    this.verifyOTP = result;
                }
            })
            .catch((error) => {
                this.errorMessage =
                    LWC_ERROR_GENERAL + this.generateErrorMessage(error);
            });
    }


    // Handle OTP Input
    handleVerifInput(event) {
        let inputVal = event.target.value;
        if (!isFinite(inputVal)) {
            event.target.value = inputVal.toString().slice(0, -1);
        }
        this.userOTP = event.target.value;
    }

    // Handle OTP Verification
    handleVerify(event) {
        if (this.userOTP) {
            if (this.verifyOTP == this.userOTP) {
                this.template.querySelector('c-custom-toast').showToast('success', 'Successfully Submitted.', 'success');
                this.handleLoginAfterOTP();
            } else {
                this.template.querySelector('c-custom-toast').showToast('warning', 'Invalid OTP.', 'warning');
            }
        } else {
            this.template.querySelector('c-custom-toast').showToast('warning', 'Please enter verification code.', 'warning');
        }
    }

    //Handle Login User After receiving OTP
    handleLoginAfterOTP() {
        loginExistingUser({
            userId: this.loginUser.Id,
            userName: this.loginUser.Username,
            startURL: this.startURL
        })
            .then((res) => {
                if (res) {
                    window.location.href = res;
                }
            })
            .catch((error) => {
                this.errorMessage =
                    LWC_ERROR_GENERAL + this.generateErrorMessage(error);
            });
    }

    //handle Resend Code
    handleResendCode() {
        this.sendEmailOTP();
        this.template.querySelector('c-custom-toast').showToast('success', 'Email Sent.', 'success');
    }

    // Concatenates error name and message
    generateErrorMessage(err) {
        let _errorMsg = " (";

        _errorMsg +=
            err.name && err.message
                ? err.name + ": " + err.message
                : err.body.message;
        _errorMsg += ")";

        return _errorMsg;
    }

    onlyNumericAllowed(event) {
        if(!preventNonNumbersInInput(event)){
            event.preventDefault();
        }
    }

    onlyNumericAllowedInPaste(event){
        if(!checkPasteIfNumeric(event)){
            event.preventDefault();
        }

    }

}