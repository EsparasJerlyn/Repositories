/**
 * @description A LWC component to allow learner to register
 *
 * @see ../classes/RegistrationFormCtrl.cls
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                        |
      |---------------------------|-----------------------|----------------------|---------------------------------------|
      | eugene.andrew.abuan       | January 03, 2022      | DEPP-773             | Created file                          |
      | eugene.andrew.abuan       | March 28, 2022        | DEPP-1293            | Modified to meet the requirements for |
      |                           |                       |                      | DEPP-1293                             |
      |                           |                       |                      |                                       |
 */
import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import isEmailExist from "@salesforce/apex/RegistrationFormCtrl.isEmailExist";
import registerUser from "@salesforce/apex/RegistrationFormCtrl.registerUser";
import getCommunityUrl from "@salesforce/apex/RegistrationFormCtrl.getCommunityUrl";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import header from "@salesforce/label/c.QUT_RegistrationForm_Header";
import subHeader from "@salesforce/label/c.QUT_RegistrationForm_subHeader";
import registerWithLinkedIn from "@salesforce/label/c.QUT_RegistrationForm_RegisterWithLinkedIn";
import qutSSOText from "@salesforce/label/c.QUT_RegistrationForm_SSO";
import requiredField from "@salesforce/label/c.QUT_RegistrationForm_IndicatesRequiredField";
import privacyPolicy from "@salesforce/label/c.QUT_RegistrationForm_PrivacyPolicy";
import BasePath from "@salesforce/community/basePath";
import sendRegistrationSMSOTP from "@salesforce/apex/RegistrationFormCtrl.sendRegistrationSMSOTP";
import getOPEProductCateg from "@salesforce/apex/RegistrationFormCtrl.getOPEProductCateg";

//Add text fields in Label from HTML
const SSO = "/services/auth/sso/";
const REQUIRED_ERROR_MESSAGE = "Please populate required field.";
const EMAIL_NOT_VALID = "Please enter a valid email.";
const EMAIL_EXIST = "Your email already exists.";
const BIRTHDATE_FORMAT = "Please check the format";
const BIRTHDATE_INVALID = "Invalid Input";
const SHOW_ERROR_MESSAGE_ATTRIBUTE = "error-message error-message-show";
const SHOW_ERROR_BOARDER_ATTRIBUTE = "slds-input input-element border-error";
const HIDE_ERROR_MESSAGE_ATTRIBUTE = "error-message error-message-hide";
const HIDE_ERROR_BOARDER_ATTRIBUTE = "slds-input input-element";

export default class RegistrationForm extends LightningElement {
  firstName = null;
  lastName = null;
  mobile = null;
  email = null;
  date = null;
  month = null;
  year = null;
  dietaryReq = null;
  checkbox;
  linkedInSSOUrl;
  experienceSSOUrl;
  linkedInLogo;
  xButton;
  emailErrorMessage;
  dateErrorMessage;
  monthErrorMessage;
  yearErrorMessage;
  errorMessage;
  requiredErrorMessage;
  @track requiredDisplayData = {};
  @track requiredInputClass = {};

  hasErrorFN = false;
  hasErrorLN = false;
  hasErrorEmail = false;
  hasErrorMob = false;
  hasErrorDate = false;
  hasErrorMonth = false;
  hasErrorYear = false;
  hasErrorChk = false;
  displayForm = true;
  displayVerification = false;
  displayResendVerification = false;
  userOTP;
  verifyOTP;
  selectionOption;
  startURL;

  label = {
    header,
    subHeader,
    requiredField,
    registerWithLinkedIn,
    qutSSOText,
    privacyPolicy,
  };

  /*
   * Resend OTP Options
   */
  get verifOptions() {
    return [
      { label: "SMS", value: "SMS" },
      { label: "Email", value: "Email" }
    ];
  }

  /*
   * Sets the Attribute on Load of the Registration Modal
   */
  connectedCallback() {
    this.requiredDisplayData.firstName = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    this.requiredDisplayData.lastName = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    this.requiredDisplayData.email = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    this.requiredDisplayData.mobile = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    this.requiredDisplayData.date = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    this.requiredDisplayData.month = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    this.requiredDisplayData.year = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    this.requiredDisplayData.checkbox = HIDE_ERROR_MESSAGE_ATTRIBUTE;

    this.requiredInputClass.firstName = HIDE_ERROR_BOARDER_ATTRIBUTE;
    this.requiredInputClass.lastName = HIDE_ERROR_BOARDER_ATTRIBUTE;
    this.requiredInputClass.email = HIDE_ERROR_BOARDER_ATTRIBUTE;
    this.requiredInputClass.mobile = HIDE_ERROR_BOARDER_ATTRIBUTE;
    this.requiredInputClass.date = HIDE_ERROR_BOARDER_ATTRIBUTE;
    this.requiredInputClass.month = HIDE_ERROR_BOARDER_ATTRIBUTE;
    this.requiredInputClass.year = HIDE_ERROR_BOARDER_ATTRIBUTE;
    this.requiredInputClass.checkbox = "slds-checkbox_faux check-box cursor";
    this.linkedInLogo = qutResourceImg + "/QUTImages/Icon/linkedInLogo.svg";
    this.xButton = qutResourceImg + "/QUTImages/Icon/xMark.svg";
    this.requiredErrorMessage = REQUIRED_ERROR_MESSAGE;

    // Get Product Category Id
    getOPEProductCateg()
      .then((result) => {
        this.startURL = BasePath + "/category/products/" + result.Id;
      })
      .catch((error) => {
        console.log("getOPEProductCateg error");
        console.log(error);
      });

      //Generate Experience SSO Link
      getCommunityUrl()
      .then((res) => {
        this.experienceSSOUrl = res.comSite + SSO + 'QUT_Experience_SSO';
      }).catch((error) => {
        this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
      });
  }

  /*
   * Closes Modal when called
   */
  closeModal() {
    this.dispatchEvent(new CustomEvent("close"));
  }

  /*
   * Handles LinkedIn Button when Clicked
   * Redirects to LinkedIn SSO
   */
  handleLinkedInOnClick() {
    let domain;
    // Sample LinkedIn SSO LINK: https://9devabuan-qut360.aus14s.sfdc-vwfla6.force.com/study/services/auth/sso/LinkedIn
    getCommunityUrl().then((res) => {
      domain = res.comURL[0].Domain.split("-");

      if ("sit" === domain[0].toLowerCase()) {
        this.linkedInSSOUrl = res.comSite + SSO + "QUTSIT_LinkedIn";
      } else if ("uat" === domain[0].toLowerCase()) {
        this.linkedInSSOUrl = res.comSite + SSO + "QUTUAT_LinkedIn";
      } else {
        this.linkedInSSOUrl = res.comSite + SSO + "QUT_LinkedIn";
      }
      window.location.href = this.linkedInSSOUrl;
    });
  }

  /*
   * handler when user clicks Continue
   * Validates User's Input when it's not Empty
   * Creates User for Salesforce once passed in Validations
   */
  handleRegister(event) {
    event.preventDefault();
    this.dietaryReq = this.template.querySelector(
      "textarea[name=dietaryReq]"
    ).value;
    this.checkInputIsEmpty();
    if (
      this.firstName &&
      this.lastName &&
      this.email &&
      this.mobile &&
      this.date &&
      this.month &&
      this.year &&
      this.checkbox
    ) {
      let emailCheck = /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(this.email);
      let checkDate = /[0-9]{1,2}/.test(this.date);
      let checkMonth = /[0-9]{1,2}/.test(this.month);
      let checkYear = /[0-9]{4}/.test(this.year);

      this.date = parseInt(this.date);
      this.month = parseInt(this.month);
      this.year = parseInt(this.year);

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

      //Check Date Validation once date is not null
      if (checkDate == false) {
        this.dateErrorMessage = BIRTHDATE_FORMAT;
        this.requiredDisplayData.date = SHOW_ERROR_MESSAGE_ATTRIBUTE;
        this.requiredInputClass.date = SHOW_ERROR_BOARDER_ATTRIBUTE;
        return;
      } else if (this.date > 31) {
        this.dateErrorMessage = BIRTHDATE_INVALID;
        this.requiredDisplayData.date = SHOW_ERROR_MESSAGE_ATTRIBUTE;
        this.requiredInputClass.date = SHOW_ERROR_BOARDER_ATTRIBUTE;
        return;
      }

      //Check Month Validation once month is not null
      if (checkMonth == false) {
        this.monthErrorMessage = BIRTHDATE_FORMAT;
        this.requiredDisplayData.month = SHOW_ERROR_MESSAGE_ATTRIBUTE;
        this.requiredInputClass.month = SHOW_ERROR_BOARDER_ATTRIBUTE;
        return;
      } else if (this.month > 12) {
        this.monthErrorMessage = BIRTHDATE_INVALID;
        this.requiredDisplayData.month = SHOW_ERROR_MESSAGE_ATTRIBUTE;
        this.requiredInputClass.month = SHOW_ERROR_BOARDER_ATTRIBUTE;
        return;
      }

      //Check Year Validation once Year is not null
      if (checkYear == false) {
        this.yearErrorMessage = BIRTHDATE_FORMAT;
        this.requiredDisplayData.year = SHOW_ERROR_MESSAGE_ATTRIBUTE;
        this.requiredInputClass.year = SHOW_ERROR_BOARDER_ATTRIBUTE;
        return;
      } else if (this.year < 1950 || this.year > new Date().getFullYear()) {
        this.yearErrorMessage = BIRTHDATE_INVALID;
        this.requiredDisplayData.year = SHOW_ERROR_MESSAGE_ATTRIBUTE;
        this.requiredInputClass.year = SHOW_ERROR_BOARDER_ATTRIBUTE;
        return;
      }

      //Checks if Email Exists in Salesforce Org
      //Else, executes Registration Process
      isEmailExist({ email: this.email })
        .then((res) => {
          if (res != null && res != undefined && res == true) {
            this.emailErrorMessage = EMAIL_EXIST;
            this.requiredDisplayData.email = SHOW_ERROR_MESSAGE_ATTRIBUTE;
            this.requiredInputClass.email = SHOW_ERROR_BOARDER_ATTRIBUTE;
          } else {
            // Call Apex to send SMS
            this.displayForm = false;
            this.displayVerification = true;
            this.displayResendVerification = false;
            this.sendSMSOTP();
          }
        })
        .catch((error) => {
          this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
        });
    }
  }

  sendSMSOTP() {
    sendRegistrationSMSOTP({ mobile: this.mobile })
      .then((result) => {
        if (result) {
          this.verifyOTP = result;
        }
      })
      .catch((error) => {
        this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
      });
  }

  registerPortalUser() {
    registerUser({
      firstName: this.firstName,
      lastName: this.lastName,
      email: this.email,
      mobile: this.mobile,
      day: this.date,
      month: this.month,
      year: this.year,
      dietaryReq: this.dietaryReq,
      startURL: this.startURL
    })
      .then((res) => {
        console.log(res);
        if (res == "CloseModal") {
          this.closeModal();
        } else if (res) {
          window.location.href = res;
        }
      })
      .catch((error) => {
        this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
      });
  }

  handleDisplayResend(event) {
    event.preventDefault();
    this.displayForm = false;
    this.displayVerification = false;
    this.displayResendVerification = true;
  }

  /*
   * Checks Input of the fields if null/empty and sets error message
   */
  checkInputIsEmpty() {
    if (!this.firstName) {
      this.hasErrorFN = !this.firstName;
      this.requiredDisplayData.firstName = SHOW_ERROR_MESSAGE_ATTRIBUTE;
      this.requiredInputClass.firstName = SHOW_ERROR_BOARDER_ATTRIBUTE;
    } else {
      this.hasErrorFN = false;
      this.requiredDisplayData.firstName = HIDE_ERROR_MESSAGE_ATTRIBUTE;
      this.requiredInputClass.firstName = HIDE_ERROR_BOARDER_ATTRIBUTE;
    }

    if (!this.lastName) {
      this.hasErrorLN = !this.lastName;
      this.requiredDisplayData.lastName = SHOW_ERROR_MESSAGE_ATTRIBUTE;
      this.requiredInputClass.lastName = SHOW_ERROR_BOARDER_ATTRIBUTE;
    } else {
      this.hasErrorLN = false;
      this.requiredDisplayData.lastName = HIDE_ERROR_MESSAGE_ATTRIBUTE;
      this.requiredInputClass.lastName = HIDE_ERROR_BOARDER_ATTRIBUTE;
    }

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
      this.hasErrorMob = !this.mobile;
      this.requiredDisplayData.mobile = SHOW_ERROR_MESSAGE_ATTRIBUTE;
      this.requiredInputClass.mobile = SHOW_ERROR_BOARDER_ATTRIBUTE;
    } else {
      this.hasErrorMob = false;
      this.requiredDisplayData.mobile = HIDE_ERROR_MESSAGE_ATTRIBUTE;
      this.requiredInputClass.mobile = HIDE_ERROR_BOARDER_ATTRIBUTE;
    }

    if (!this.date) {
      this.hasErrorDate = !this.date;
      this.dateErrorMessage = REQUIRED_ERROR_MESSAGE;
      this.requiredDisplayData.date = SHOW_ERROR_MESSAGE_ATTRIBUTE;
      this.requiredInputClass.date = SHOW_ERROR_BOARDER_ATTRIBUTE;
    } else {
      this.hasErrorDate = false;
      this.requiredDisplayData.date = HIDE_ERROR_MESSAGE_ATTRIBUTE;
      this.requiredInputClass.date = HIDE_ERROR_BOARDER_ATTRIBUTE;
    }

    if (!this.month) {
      this.hasErrorMonth = !this.month;
      this.monthErrorMessage = REQUIRED_ERROR_MESSAGE;
      this.requiredDisplayData.month = SHOW_ERROR_MESSAGE_ATTRIBUTE;
      this.requiredInputClass.month = SHOW_ERROR_BOARDER_ATTRIBUTE;
    } else {
      this.hasErrorMonth = false;
      this.requiredDisplayData.month = HIDE_ERROR_MESSAGE_ATTRIBUTE;
      this.requiredInputClass.month = HIDE_ERROR_BOARDER_ATTRIBUTE;
    }

    if (!this.year) {
      this.hasErrorYear = !this.year;
      this.yearErrorMessage = REQUIRED_ERROR_MESSAGE;
      this.requiredDisplayData.year = SHOW_ERROR_MESSAGE_ATTRIBUTE;
      this.requiredInputClass.year = SHOW_ERROR_BOARDER_ATTRIBUTE;
    } else {
      this.hasErrorYear = false;
      this.requiredDisplayData.year = HIDE_ERROR_MESSAGE_ATTRIBUTE;
      this.requiredInputClass.year = HIDE_ERROR_BOARDER_ATTRIBUTE;
    }

    if (this.checkbox === false || !this.checkbox) {
      this.hasErrorChk = this.checkbox === false || !this.checkbox;
      this.requiredInputClass.checkbox =
        "slds-checkbox_faux border-error cursor";
      this.requiredDisplayData.checkbox = SHOW_ERROR_MESSAGE_ATTRIBUTE;
    } else {
      this.hasErrorChk = false;
      this.requiredInputClass.checkbox = "slds-checkbox_faux check-box cursor";
      this.requiredDisplayData.checkbox = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    }
  }

  /*
   * Sets the firstName via event
   */
  handleFirstNameChange(event) {
    this.firstName = event.target.value;
  }

  /*
   * Sets the lastName via event
   */
  handleLastNameChange(event) {
    this.lastName = event.target.value;
  }

  /*
   * Sets the email via event
   */
  handleEmailChange(event) {
    this.email = event.target.value;
  }

  /*
   * Sets the mobile via event
   */
  handleMobileChange(event) {
    this.mobile = event.target.value;
  }

  /*
   * Sets the date via event
   */
  handleDayChange(event) {
    this.date = event.target.value;
  }

  /*
   * Sets the month via event
   */
  handleMonthChange(event) {
    this.month = event.target.value;
  }

  /*
   * Sets the year via event
   */
  handleYearChange(event) {
    this.year = event.target.value;
  }

  handleCheckBox(event) {
    this.checkbox = event.target.checked;
  }

  handleSelectedOption(event) {
    this.selectionOption = event.target.value;
  }

  handleResendCode(event) {
    if (this.selectionOption == "Email") {
      this.generateToast("Success!", "Email Sent", "success");
      this.selectionOption = null;
      this.displayForm = false;
      this.displayVerification = true;
      this.displayResendVerification = false;
    } else if (this.selectionOption == "SMS") {
      this.sendSMSOTP();

      this.generateToast("Success!", "SMS Sent", "success");
      this.displayForm = false;
      this.displayVerification = true;
      this.displayResendVerification = false;
      this.selectionOption = null;
    } else if (this.selectionOption == null) {
      this.generateToast("Error.", "Please Select Option", "error");
    }
  }

  handleVerifInput(event) {
    this.userOTP = event.target.value;
  }
  handleVerify(event) {
    if (this.verifyOTP == this.userOTP) {
      this.generateToast("Success!", "OTP Accepted", "success");
      this.registerPortalUser();
    } else {
      this.generateToast("Error.", "Invalid OTP", "error");
    }
  }

  /**
   * concatenates error name and message
   */
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
}
