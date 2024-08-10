/**
 * @description A LWC component for Custom Sign-In
 *
 * @see ../classes/RegistrationFormCtrl.cls
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                   |
      |---------------------------|-----------------------|----------------------|--------------------------------------------------|
      | john.bo.a.pineda          | July 07, 2022         | DEPP-3136            | Created file                                     |
      | eugene.andrew.abuan       | August 08, 2022       | DEPP-3705            | Updated error message when email does not exist  |
      | eugene.andrew.abuan       | February 22, 2023     | DEPP-5232            | Updated MobilePhone to Contact.Mobile            |
      | jerlyn.esparas            | July 22, 2024         | DEPP-9138            | Add QUT SSO button When the Portal is Giving     |

*/
import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import isEmailExist from "@salesforce/apex/RegistrationFormCtrl.isEmailExist";
import getCommunityUrl from "@salesforce/apex/RegistrationFormCtrl.getCommunityUrl";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import sendRegistrationSMSOTP from "@salesforce/apex/RegistrationFormCtrl.sendRegistrationSMSOTP";
import sendRegistrationEmailOTP from "@salesforce/apex/RegistrationFormCtrl.sendRegistrationEmailOTP";
import loginExistingUser from "@salesforce/apex/RegistrationFormCtrl.loginExistingUser";

//Add text fields in Label from HTML
const SSO = "/services/auth/sso/";
const REQUIRED_ERROR_MESSAGE = "Field is required.";
const EMAIL_NOT_VALID = "Please enter a valid email.";
const EMAIL_NOT_EXIST = "Email address does not exist. Please";
const SHOW_ERROR_MESSAGE_ATTRIBUTE = "error-message error-message-show";
const SHOW_ERROR_BOARDER_ATTRIBUTE = "slds-input input-element border-error";
const HIDE_ERROR_MESSAGE_ATTRIBUTE = "error-message error-message-hide";
const HIDE_ERROR_BOARDER_ATTRIBUTE = "slds-input input-element";
const HEADER = "Returning to QUTeX?";
const QUT_SSO_TEXT = "Sign-in with QUT SSO";
const QUT_REGISTER = "Tell us about yourself";
const LWC_ERROR_GENERAL =
    "An error has been encountered. Please contact your administrator.";

export default class CustomSignIn extends LightningElement {
    @api startURL;
    @api isModal;
    @api portalName;
    @track requiredDisplayData = {};
    @track requiredInputClass = {};

    email = null;
    experienceSSOUrl;
    xButton;
    emailErrorMessage;
    errorMessage;
    requiredErrorMessage;
    hasErrorEmail = false;
    displayForm = true;
    displayVerification = false;
    displayResendVerification = false;
    userOTP;
    verifyOTP;
    selectionOption;
    isEmail = false;
    loginUser = {};
    loading = false;
    isExistingEmail = false;
    isGivingToCauses = false;

    label = {
        header: HEADER,
        qutSSOText: QUT_SSO_TEXT,
        qutRegister: QUT_REGISTER
    };

    // Resend OTP Options
    get verifOptions() {
        return [
            { label: "SMS", value: "SMS" },
            { label: "Email", value: "Email" }
        ];
    }

    // Portal is Giving
    get isPortalGiving() {
        return this.portalName === 'Giving to Causes' ? true : false;
    }

    connectedCallback() {
        this.requiredDisplayData.email = HIDE_ERROR_MESSAGE_ATTRIBUTE;
        this.requiredInputClass.email = HIDE_ERROR_BOARDER_ATTRIBUTE;
        this.comboBoxUp = qutResourceImg + "/QUTImages/Icon/comboBoxUp.svg";
        this.comboBoxDown = qutResourceImg + "/QUTImages/Icon/comboBoxDown.svg";        
        this.isGivingToCauses = this.portalName === 'Giving to Causes' ? true : false;
        this.xButton = qutResourceImg + "/QUTImages/Icon/xMark.svg";
        this.requiredErrorMessage = REQUIRED_ERROR_MESSAGE;
        if (!this.startURL) {
            this.startURL = window.location.pathname + window.location.search;
        }

        // Generate Experience SSO Link
        getCommunityUrl()
            .then((res) => {
                this.experienceSSOUrl =
                    res.comSite +
                    SSO +
                    "QUT_Experience_SSO" +
                    "/?startURL=" +
                    encodeURIComponent(this.startURL);
            })
            .catch((error) => {
                this.errorMessage =
                    LWC_ERROR_GENERAL + this.generateErrorMessage(error);
            });
    }

    // Close Modal
    closeModal() {
        this.dispatchEvent(new CustomEvent("close"));
    }

    // Handle Email Input
    handleEmailChange(event) {
        this.email = event.target.value;
    }

    // Handle Continue
    handleContinue(event) {
        event.preventDefault();

        // Check if Required Fields are blank
        this.checkInputIsEmpty();

        if (this.email) {
            let emailCheck = /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(this.email);
            //Email Valitaion once email is not null
            if (
                emailCheck == null ||
                emailCheck == undefined ||
                emailCheck == false
            ) {
                this.emailErrorMessage = EMAIL_NOT_VALID;
                this.requiredDisplayData.email = SHOW_ERROR_MESSAGE_ATTRIBUTE;
                this.requiredInputClass.email = SHOW_ERROR_BOARDER_ATTRIBUTE;
                return;
            }

            //Checks if Email Exists in Salesforce Org
            isEmailExist({ email: this.email })
                .then((res) => {
                    if (res.length > 0) {
                        // If Exists, execute login
                        this.loginUser = res[0];
                        this.displayForm = false;
                        this.displayVerification = true;
                        this.displayResendVerification = false;
                        this.mobileFull = this.loginUser.Contact.MobilePhone;
                        this.sendSMSOTP();
                    } else {
                        // If not Exists, display Email not exist
                        this.isExistingEmail = true;
                        this.emailErrorMessage = EMAIL_NOT_EXIST;
                        this.requiredDisplayData.email =
                            SHOW_ERROR_MESSAGE_ATTRIBUTE;
                        this.requiredInputClass.email =
                            SHOW_ERROR_BOARDER_ATTRIBUTE;
                    }
                })
                .catch((error) => {
                    this.errorMessage =
                        LWC_ERROR_GENERAL + this.generateErrorMessage(error);
                });
        }
    }

    // Checks Input of the fields if null/empty and sets error message
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
    }

    // Handle Display of Resend Screen
    handleDisplayResend(event) {
        event.preventDefault();
        this.displayForm = false;
        this.displayVerification = false;
        this.displayResendVerification = true;
    }

    // Handle Selected Resend Option
    handleSelectedOption(event) {
        this.selectionOption = event.target.value;
    }

    // Handle SMS OTP Send
    sendSMSOTP() {
        sendRegistrationSMSOTP({ mobile: this.mobileFull })
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

    // Handle Resend Code
    handleResendCode(event) {
        if (this.selectionOption == "Email") {
            this.sendEmailOTP();
            this.generateToast("Success!", "Email Sent", "success");
            this.selectionOption = null;
            this.displayForm = false;
            this.displayVerification = true;
            this.displayResendVerification = false;
            this.isEmail = true;
        } else if (this.selectionOption == "SMS") {
            this.sendSMSOTP();
            this.generateToast("Success!", "SMS Sent", "success");
            this.displayForm = false;
            this.displayVerification = true;
            this.displayResendVerification = false;
            this.selectionOption = null;
            this.isEmail = false;
        } else if (this.selectionOption == null) {
            this.generateToast("Error.", "Please Select Option", "warning");
        }
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
                this.generateToast(
                    "Success!",
                    "Successfully Submitted",
                    "success"
                );
                this.loading = true;
                this.handleLogin();
            } else {
                this.generateToast("Error.", "Invalid OTP", "warning");
            }
        } else {
            this.generateToast(
                "Error.",
                "Please enter verification code",
                "warning"
            );
        }
    }

    // Handle Login
    handleLogin() {
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

    // Creates toast notification
    generateToast(_title, _message, _variant) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant
        });
        this.dispatchEvent(evt);
    }

    handleOpenRegister() {
        this.dispatchEvent(new CustomEvent("openregister"));
    }
}