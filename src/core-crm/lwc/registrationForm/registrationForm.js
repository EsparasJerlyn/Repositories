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
      | keno.domienri.dico        | June 15, 2022         | DEPP-2758            | Added Accessibility Req field         |
      | john.bo.a.pineda          | June 16, 2022         | DEPP-3114            | Modified to set values after          |
      |                           |                       |                      | registration                          |
      | john.bo.a.pineda          | June 20, 2022         | DEPP-3191            | Modified to add logic for login of    |
      |                           |                       |                      | existing Users                        |
      | john.bo.a.pineda          | July 04, 2022         | DEPP-3384            | Modified to add Boolean parameter to  |
      |                           |                       |                      | verify if action is login             |
      | john.bo.a.pineda          | July 04, 2022         | DEPP-3385            | Added "p" object keyword to URL       |
      | john.bo.a.pineda          | July 05, 2022         | DEPP-3393            | Replaced all special characters to URL|
      |                           |                       |                      | equivalents for startURL              |
      | john.bo.a.pineda          | July 15, 2022         | DEPP-3130            | Set startURL param as API             |
      | julie.jane.alegre         | August 15, 2022       | DEPP-3568            | Added Contact Duplication Handling    |
      | keno.domienri.dico        | September 23, 2022    | DEPP-4367            | birthdate validation                  |
*/
import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from "lightning/navigation";
import QUTeX_Contact_Detail from '@salesforce/label/c.QUTeX_Contact_Detail';
import registerUser from "@salesforce/apex/RegistrationFormCtrl.registerUser";
import getCommunityUrl from "@salesforce/apex/RegistrationFormCtrl.getCommunityUrl";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import BasePath from "@salesforce/community/basePath";
import sendRegistrationSMSOTP from "@salesforce/apex/RegistrationFormCtrl.sendRegistrationSMSOTP";
import getMobileLocaleOptions from "@salesforce/apex/RegistrationFormCtrl.getMobileLocaleOptions";
import sendRegistrationEmailOTP from "@salesforce/apex/RegistrationFormCtrl.sendRegistrationEmailOTP";
import validateContactMatching from "@salesforce/apex/RegistrationMatchingHelper.validateContactMatching";
import loginExistingUser from "@salesforce/apex/RegistrationFormCtrl.loginExistingUser";
import isUserExist from "@salesforce/apex/RegistrationFormCtrl.isUserExist";
import updateContact from "@salesforce/apex/RegistrationFormCtrl.updateContact";
import { birthdateValidation } from 'c/commonUtils';

//Add text fields in Label from HTML
const SSO = "/services/auth/sso/";
const REQUIRED_ERROR_MESSAGE =
  "Please complete the mandatory fields(*) before proceeding.";
const EMAIL_NOT_VALID = "Please enter a valid email.";
const BIRTHDATE_FORMAT = "Please check the format";
const BIRTHDATE_INVALID = "Invalid Input";
const SHOW_ERROR_MESSAGE_ATTRIBUTE = "error-message error-message-show";
const SHOW_ERROR_BOARDER_ATTRIBUTE = "slds-input input-element border-error";
const HIDE_ERROR_MESSAGE_ATTRIBUTE = "error-message error-message-hide";
const HIDE_ERROR_BOARDER_ATTRIBUTE = "slds-input input-element";

const HEADER ="Tell us about you";
const SUBHEADER = "Register to participate in professional and executive education";
const REGISTER_WITH_LINKEDIN = "Register with LinkedIn";
const QUT_SSO_TEXT ="Previously/Currently studied with QUTeX or QUT? Login Instead";
const QUT_LOGIN_TEXT = "Previously told us about you? Continue here.";
const REQ_FIELD = "Indicates a required field";
const ACKNOWLDGE = "I acknowledge and accept the";
const QUT_PRIVACY_POLICY ="QUT Privacy Policy.";
const LWC_ERROR_GENERAL = "An error has been encountered. Please contact your administrator.";
export default class RegistrationForm extends LightningElement {
  firstName = null;
  lastName = null;
  mobile = null;
  email = null;
  date = null;
  month = null;
  year = null;
  dietaryReq = null;
  accessReq = null;
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
  @track locale = null;
  @track paramURLDefaults;

  hasErrorFN = false;
  hasErrorLN = false;
  hasErrorEmail = false;
  hasErrorMob = false;
  hasErrorDate = false;
  hasErrorMonth = false;
  hasErrorYear = false;
  hasErrorChk = false;
  hasErrorLocale = false;
  displayForm = true;
  displayVerification = false;
  displayResendVerification = false;
  userOTP;
  verifyOTP;
  selectionOption;
  localeOptions = [];
  localeDisplayName;
  localeConMobile;
  mobileFull;
  isLoginPage = false;
  isEmail = false;
  userExists = false;
  loginUser = {};
  loading = false;
  executeLogin = false;
  displayEmailValidation = false;
  otherEmailError = false;
  noRecordforEmail = false;
  matchedContact;
  fieldsMismatch = [];
  contactId;
  otherEmail;
  contactDetail;

  @api startURL;
  @api recordId;

  @track header;
  @track subHeader;
  @track registerWithLinkedIn;
  @track qutSSOText;
  @track requiredField;
  @track privacyPolicy;
  @track acknowledge;

  label = {
    header: HEADER,
    subHeader: SUBHEADER,
    requiredField: REQ_FIELD,
    registerWithLinkedIn :REGISTER_WITH_LINKEDIN,
    qutSSOText: QUT_SSO_TEXT,
    qutLoginText: QUT_LOGIN_TEXT,
    privacyPolicy: QUT_PRIVACY_POLICY,
    acknowledge: ACKNOWLDGE,
    contactDetail: QUTeX_Contact_Detail
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

  // Get & Set paramURL value
  @api get param() {
    return this.paramURLDefaults;
  }

  set param(value) {
    this.paramURLDefaults = value ? value : "";
  }

  @wire(CurrentPageReference)
  getpageRef(pageRef) {
    if (pageRef && pageRef.state && pageRef.state.startURL) {
      this.startURL = pageRef.state.startURL;
    } else if (pageRef && pageRef.attributes && this.paramURLDefaults) {
      this.startURL =
        BasePath +
        "/product/" +
        pageRef.attributes.recordId +
        this.paramURLDefaults;
    }

    this.isLoginPage =
      pageRef && pageRef.attributes && pageRef.attributes.name === "Login"
        ? true
        : false;
  }
  /*
   * Sets the Attribute on Load of the Registration Modal
   */
  connectedCallback() {
    this.comboBoxUp = qutResourceImg + "/QUTImages/Icon/comboBoxUp.svg";
    this.comboBoxDown = qutResourceImg + "/QUTImages/Icon/comboBoxDown.svg";

    this.requiredDisplayData.firstName = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    this.requiredDisplayData.lastName = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    this.requiredDisplayData.email = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    this.requiredDisplayData.locale = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    this.requiredDisplayData.mobile = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    this.requiredDisplayData.date = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    this.requiredDisplayData.month = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    this.requiredDisplayData.year = HIDE_ERROR_MESSAGE_ATTRIBUTE;
    this.requiredDisplayData.checkbox = HIDE_ERROR_MESSAGE_ATTRIBUTE;

    this.requiredInputClass.firstName = HIDE_ERROR_BOARDER_ATTRIBUTE;
    this.requiredInputClass.lastName = HIDE_ERROR_BOARDER_ATTRIBUTE;
    this.requiredInputClass.email = HIDE_ERROR_BOARDER_ATTRIBUTE;
    this.requiredInputClass.locale = HIDE_ERROR_BOARDER_ATTRIBUTE;
    this.requiredInputClass.mobile = HIDE_ERROR_BOARDER_ATTRIBUTE;
    this.requiredInputClass.date = HIDE_ERROR_BOARDER_ATTRIBUTE;
    this.requiredInputClass.month = HIDE_ERROR_BOARDER_ATTRIBUTE;
    this.requiredInputClass.year = HIDE_ERROR_BOARDER_ATTRIBUTE;
    this.requiredInputClass.checkbox = "slds-checkbox_faux check-box cursor";
    this.linkedInLogo = qutResourceImg + "/QUTImages/Icon/linkedInLogo.svg";
    this.xButton = qutResourceImg + "/QUTImages/Icon/xMark.svg";
    this.requiredErrorMessage = REQUIRED_ERROR_MESSAGE;
    this.fieldsMismatch = [];

    //Generate Experience SSO Link
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
        this.errorMessage = LWC_ERROR_GENERAL + this.generateErrorMessage(error);
      });

    // Get Locale Options
    getMobileLocaleOptions()
      .then((resultOptions) => {
        this.localeOptions = resultOptions;
        this.locale = "Australia (+61)";
        this.localeConMobile = "Australia (+61)";
      })
      .catch((error) => {
        this.errorMessage = LWC_ERROR_GENERAL + this.generateErrorMessage(error);
      });
  }

  /*
   * Closes Modal when called
   */
  closeModal() {
    if (!this.isLoginPage) {
      this.dispatchEvent(new CustomEvent("close"));
    }
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
      window.location.href =
        this.linkedInSSOUrl +
        "/?startURL=" +
        this.startURL +
        this.paramURLDefaults;
    });
  }

  /*
   * handler when user clicks Continue
   * Validates User's Input when it's not Empty
   * Creates User for Salesforce once passed in Validations
   */
  handleRegister(event) {
    event.preventDefault();
    this.executeLogin = false;
    this.mobile = this.mobile ? this.mobile.replace(/^0+/, "") : "";

    if(this.localeOptions.find( opt => opt.value === this.locale)){
      this.mobileFull = this.localeOptions.find( opt => opt.value === this.locale).countryCode + this.mobile;
    } else {
      this.mobileFull = '';
    }
    this.dietaryReq = this.template.querySelector(
      "textarea[name=dietaryReq]"
    ).value;
    this.accessReq = this.template.querySelector(
      "textarea[name=accessReq]"
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
      } else if (this.year < 1900 || this.year > new Date().getFullYear()) {
        this.yearErrorMessage = BIRTHDATE_INVALID;
        this.requiredDisplayData.year = SHOW_ERROR_MESSAGE_ATTRIBUTE;
        this.requiredInputClass.year = SHOW_ERROR_BOARDER_ATTRIBUTE;
        return;
      }

      // Check Date of Birth 
      if(!this.checkDOB()){
        let contactList = [];
        let contact = {};
        contact.FirstName = this.firstName;
        contact.LastName = this.lastName;
        contact.Birthdate = this.year + '-'+ this.month + '-' + this.date;
        contact.Registered_Email__c = this.email;
        contactList.push(contact);

          this.fieldsMismatch = [];
          validateContactMatching({newContactList:JSON.stringify(contactList)})
          .then((res) => {
            let validationResult = res[0];
            if( validationResult.isPartialMatch == false &&
                validationResult.isEmailMatch == false){ //email and contact details did not match
                    //Proceed to creating new record
                    this.userExists = false;
                    this.displayForm = false;
                    this.displayVerification = true;
                    this.displayResendVerification = false;
                    this.sendSMSOTP();

            }else if( validationResult.isPartialMatch == false &&
                      validationResult.isEmailMatch == true){ //email and contact details matched
                        //Proceed to log in, existing record
                        this.contactId = validationResult.contactRecord.Id;
                        isUserExist({contactId: this.contactId})
                        .then((res) => {
                            if(res.length > 0){
                                this.userExists = true;
                                this.loginUser = res[0];
                                this.handleExistingUser();
                            }
                            else{
                                //'User does not exist'
                                //Proceed to creating new record
                                this.userExists = false;
                                this.displayForm = false;
                                this.displayVerification = true;
                                this.displayResendVerification = false;
                                this.isEmail = true;
                                this.sendEmailOTP();
                            }
                        })

            }else if( validationResult.isPartialMatch == true &&
                      validationResult.isEmailMatch == false){ //email did not match and contact details matched
                        //Request user to enter email
                        //Tell Me More About You screen is display
                        this.displayForm = false;
                        this.displayEmailValidation = true;

            }else if( validationResult.isPartialMatch == true &&
                      validationResult.isEmailMatch == true){  //email match and contact details did not match
                      //Request update contact details
                      //Display Error on the form
                      this.noRecordforEmail = true;
                      this.fieldsMismatch = validationResult.fieldsMismatch && validationResult.fieldsMismatch.length > 0?validationResult.fieldsMismatch:[];
                      if(validationResult.fieldsMismatch.includes('First Name')){
                          this.requiredInputClass.firstName = SHOW_ERROR_BOARDER_ATTRIBUTE;
                      }
                      if(validationResult.fieldsMismatch.includes('Last Name')){
                          this.requiredInputClass.lastName = SHOW_ERROR_BOARDER_ATTRIBUTE;
                      }
                      if(validationResult.fieldsMismatch.includes('Date of Birth')){
                          this.requiredInputClass.year = SHOW_ERROR_BOARDER_ATTRIBUTE;
                          this.requiredInputClass.month = SHOW_ERROR_BOARDER_ATTRIBUTE;
                          this.requiredInputClass.date = SHOW_ERROR_BOARDER_ATTRIBUTE;
                      }
            }
          })
      }
    }
  }

  // Handle Date of Birth
  checkDOB(){
    let hasInvalidDOB = false;
    let dateOfBirth = this.year + '-'+ this.month + '-' + this.date;
    let dobHasError;
    let dobErrorMessage;
    if(!birthdateValidation(dateOfBirth)){
        dobHasError = true;
        dobErrorMessage = 'Must be 15 years or older to register.';
        hasInvalidDOB = true;
    }else{
      dobHasError = false;
      dobErrorMessage = '';
    }

    if(hasInvalidDOB){
        this.generateToast(
            'Error.',
            dobErrorMessage,
            'warning',
            'dismissable'
        );
    }

    return hasInvalidDOB;
  }

  // Handle Existing User with mobile default
  handleExistingUser() {
    this.executeLogin = true;
   // this.mobileFull = this.loginUser.MobilePhone;
    this.displayForm = false;
    this.displayVerification = true;
    this.displayResendVerification = false;
    this.isEmail = true;
    this.sendEmailOTP();
  }

  sendSMSOTP() {
    sendRegistrationSMSOTP({ mobile: this.mobileFull })
      .then((result) => {
        if (result) {
          this.verifyOTP = result;
        }
      })
      .catch((error) => {
        this.errorMessage = LWC_ERROR_GENERAL + this.generateErrorMessage(error);
      });
  }

  sendEmailOTP() {
    sendRegistrationEmailOTP({ email: this.email })
      .then((result) => {
        if (result) {
          this.verifyOTP = result;
        }
      })
      .catch((error) => {
        this.errorMessage = LWC_ERROR_GENERAL + this.generateErrorMessage(error);
      });
  }

  registerPortalUser() {
    registerUser({
      firstName: this.firstName,
      lastName: this.lastName,
      email: this.email,
      mobile: this.mobileFull,
      day: this.date,
      month: this.month,
      year: this.year,
      dietaryReq: this.dietaryReq,
      accessReq: this.accessReq,
      startURL: this.startURL,
      mobileNoLocale: this.mobile,
      mobileConLocale: this.localeConMobile,
      contactId: this.contactId
    })
    .then((res) => {
      if (res == "CloseModal") {
        this.closeModal();
      } else if (res) {
        window.location.href = res;
      }
    })
    .catch((error) => {
      this.errorMessage = LWC_ERROR_GENERAL + this.generateErrorMessage(error);
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

    if (!this.locale) {
      this.hasErrorLocale = !this.locale;
      this.requiredDisplayData.locale = SHOW_ERROR_MESSAGE_ATTRIBUTE;
      this.requiredInputClass.locale = SHOW_ERROR_BOARDER_ATTRIBUTE;
    } else {
      this.hasErrorLocale = false;
      this.requiredDisplayData.locale = HIDE_ERROR_MESSAGE_ATTRIBUTE;
      this.requiredInputClass.locale = HIDE_ERROR_BOARDER_ATTRIBUTE;
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
  handleLocaleChange(event) {
    this.locale = event.detail.value;
    this.localeDisplayName = event.detail.label;
    this.localeOptions.forEach((localeOption) => {
      if (localeOption.value === this.locale) {
        this.localeConMobile = localeOption.conMobileLocale;
      }
    });
  }
  //Handles the input email on "Tell Me More About You"
  handleOtherEmail(event){
      this.otherEmail = event.detail.value;
  }

  //Handle the other existing email on "Tell Me More About You"
  handleOtherExistEmail(){
      //Pass other email to email
      this.email = this.otherEmail;
      let contactList = [];
      let contact = {};
      contact.FirstName = this.firstName;
      contact.LastName = this.lastName;
      contact.Birthdate = this.year + '-'+ this.month + '-' + this.date;
      contact.Registered_Email__c = this.email;
      contactList.push(contact);
      this.fieldsMismatch = [];

      validateContactMatching({newContactList:JSON.stringify(contactList)})
      .then((res) => {
        let validationResult = res[0];
          if(validationResult.isPartialMatch == false &&
             validationResult.isEmailMatch == true){ //email and contact details matched
                this.contactId = validationResult.contactRecord.Id;
                //Check if the user exist
                isUserExist({contactId: this.contactId})
                .then((res) => {
                    if(res.length > 0){
                        this.displayEmailValidation = false;
                        this.userExists = true;
                        this.loginUser = res[0];
                        this.executeLogin = true;
                        this.displayForm = false;
                        this.displayVerification = true;
                        this.displayResendVerification = false;
                        this.handleExistingUser();
                    }
                    else{
                      //User does not exist
                      this.userExists = false;
                      this.displayForm = false;
                      this.displayVerification = true;
                      this.displayResendVerification = false;
                      this.isEmail = true;
                      this.sendEmailOTP();

                    }
                })

          }else if(validationResult.isPartialMatch == true &&
                   validationResult.isEmailMatch == false){
                   //Show error message
                   this.otherEmailError = true;
                   this.displayEmailValidation = true;
          }

      })
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
      this.generateToast("Error.", "Please Select Option", "error");
    }
  }

  handleVerifInput(event) {
    let inputVal = event.target.value;
    if (!isFinite(inputVal)) {
      event.target.value = inputVal.toString().slice(0, -1);
    }
    this.userOTP = event.target.value;
  }

  handleVerify() {
    if (this.userOTP) {
      if (this.verifyOTP == this.userOTP) {
        this.generateToast("Success!", "Successfully Submitted", "success");
        this.loading = true;
        if (Object.keys(this.loginUser).length > 0 && this.executeLogin) {
          this.loginExistingPortalUser();
        } else {
          this.registerPortalUser();
        }
      } else {
        this.generateToast("Error.", "Invalid OTP", "error");
      }
    } else {
      this.generateToast("Error.", "Please enter verification code", "error");
    }
  }

  loginExistingPortalUser() {
    loginExistingUser({
      userId: this.loginUser.Id,
      userName: this.loginUser.Username,
      startURL: this.startURL
    })
      .then((res) => {
        if (res) {
          window.location.href = res;
          this.updateContactOfExistingUser();
        }
      })
      .catch((error) => {
        this.errorMessage = LWC_ERROR_GENERAL + this.generateErrorMessage(error);
      });
  }
  // Update the existing user contact details
  updateContactOfExistingUser(){
      updateContact({
            contactId: this.contactId,
            email: this.email,
            mobileNoLocale: this.mobile,
            mobileConLocale: this.localeConMobile,
            dietaryReq: this.dietaryReq,
            accessibilityReq: this.accessReq
          })
          .then(()=>{
            //Updated contact...
          })
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