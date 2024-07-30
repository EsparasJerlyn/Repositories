/**
 * @description An LWC to check the work email input in the flow if it's currently existing in the system.
 * @see ../classes/ContactsDAO
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
 *    |---------------------------|-----------------------|----------------------|----------------------------------------------|
 *    | eugene.andrew.abuan       | June 08, 2023         | DEPP-5414            | Created file                                 |
 *    | ryan.j.a.dela.cruz        | June 26, 2023         | DEPP-5942            | Added Work Email Field Form Validation       |
 *    | ryan.j.a.dela.cruz        | August 3, 2023        | DEPP-6093            | Added Retention Of Email Field Value         |
 *    | ryan.j.a.dela.cruz        | October 12, 2023      | DEPP-6642            | Added Mobile Support for Value Retention     |
 *    | neil.s.h.lesidan          | March 4, 2024         | DEPP-7880            | Add setter getter dynamic label value        |
 */

import { LightningElement, api, track } from "lwc";
import getExistingContactEmailDuplicatesForWorkEmailInputFlow from "@salesforce/apex/ContactService.getExistingContactEmailDuplicatesForWorkEmailInputFlow";
import { loadStyle } from "lightning/platformResourceLoader";
import CustomFlowCSS from "@salesforce/resourceUrl/CustomFlowCSS";

const REQUIRED_FIELD_ERROR_MESSAGE = "Complete this field.";
const INVALID_EMAIL_ERROR_MESSAGE = "Please enter a valid email address.";
const EMAIL_MUST_BE_UNIQUE_ERROR_MESSAGE =
  "Work email must be unique across the organization.";

export default class FlowWorkEmailField extends LightningElement {
  @api workEmail;
  @api required;
  @track errorMessage = "";
  workEmailExists = false;
  isException = false;
  timer;
  _label = 'Work Email';
  _requiredFieldErrorMessage = REQUIRED_FIELD_ERROR_MESSAGE;

  @api
  get label() {
    return this._label;
  }
  set label(value) {
    this._label = value || 'Work Email';
  }

  @api
  get requiredFieldErrorMessage() {
    return this._requiredFieldErrorMessage;
  }
  set requiredFieldErrorMessage(value) {
    this._requiredFieldErrorMessage = value || REQUIRED_FIELD_ERROR_MESSAGE;
  }

  connectedCallback() {
    this.retrieveEmailFromSession();

    window.addEventListener(
      "beforeunload",
      this.beforeUnloadHandler.bind(this)
    );

    this.loadCustomCSS();
  }

  beforeUnloadHandler(event) {
    const uid = this.getUrlParameter("uid");
    if (uid) {
      const sessionKey = `EMAIL-${uid}`;
      sessionStorage.removeItem(sessionKey);
    }
    sessionStorage.removeItem("customCSSLoaded");
    sessionStorage.removeItem("EMAIL-MOBILE");
  }

  retrieveEmailFromSession() {
    const uid = this.getUrlParameter("uid");
    let sessionKey;

    if (uid) {
      sessionKey = `EMAIL-${uid}`;
    } else {
      sessionKey = "EMAIL-MOBILE";
    }

    const existingValue = sessionStorage.getItem(sessionKey);

    if (existingValue !== null) {
      // A value already exists, set it to the workEmail property
      this.workEmail = existingValue;
      this.checkWorkEmail(existingValue); // Initial check if value exists
    }
  }

  loadCustomCSS() {
    // Retrieve the session value
    const sessionValue = window.sessionStorage.getItem("customCSSLoaded");
    const logger = this.template.querySelector("c-logger");

    if (sessionValue) {
      // If the session value is available, assign it to this.customCSSLoaded
      this.customCSSLoaded = JSON.parse(sessionValue);
    } else {
      // If the session value is not available, load the CSS
      loadStyle(this, CustomFlowCSS)
        .then(() => {
          this.customCSSLoaded = true;
          console.log("Custom CSS Loaded");
          // Store the value in the session
          window.sessionStorage.setItem(
            "customCSSLoaded",
            JSON.stringify(this.customCSSLoaded)
          );
        })
        .catch((error) => {
          if (logger) {
            logger.error(
              "Exception caught in method loadCustomCSS in LWC flowWorkEmailField: ",
              JSON.stringify(error)
            );
            logger.saveLog();
          }
        });
    }
  }

  // Helper method to get URL parameters
  getUrlParameter(param) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(param);
  }

  // Clear error message
  clearErrorMessage() {
    this.errorMessage = "";
  }

  // Check if work email already exists
  checkWorkEmail(workEmailValue) {
    getExistingContactEmailDuplicatesForWorkEmailInputFlow({
      emailInput: workEmailValue
    })
      .then((result) => {
        this.workEmailExists = result;
        this.errorMessage = this.workEmailExists
          ? EMAIL_MUST_BE_UNIQUE_ERROR_MESSAGE
          : "";
        this.isException = false;
      })
      .catch((error) => {
        this.errorMessage = error.message || "An error occurred";
        this.isException = true;
      });
  }

  handleWorkEmailChange(event) {
    const workEmailValue = event.target.value;
    clearTimeout(this.timer);

    if (workEmailValue) {
      // Set a timer to wait for user to finish typing
      this.timer = setTimeout(async () => {
        this.checkWorkEmail(workEmailValue);
      }, 300);
    } else {
      // Clear error message when email input is empty
      this.clearErrorMessage();
    }

    const uid = this.getUrlParameter("uid");
    if (uid) {
      const sessionKey = `EMAIL-${uid}`;
      sessionStorage.setItem(sessionKey, workEmailValue);
    }
    sessionStorage.setItem("EMAIL-MOBILE", workEmailValue);
    this.workEmail = workEmailValue; // Update Email value
  }

  /**
   * Validates whether the given email address is in a valid format.
   *
   * @param {string} email - The email address to be validated.
   * @returns {boolean} - Returns true if the email is valid; otherwise, returns false.
   */
  validateEmail(email) {
    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return emailRegex.test(email);
  }

  @api
  validate() {
    if (!this.workEmail) {
      return {
        isValid: false,
        errorMessage: this._requiredFieldErrorMessage
      };
    } else if (!this.validateEmail(this.workEmail)) {
      return {
        isValid: false,
        errorMessage: INVALID_EMAIL_ERROR_MESSAGE
      };
    } else if (this.workEmailExists) {
      return {
        isValid: false,
        errorMessage: EMAIL_MUST_BE_UNIQUE_ERROR_MESSAGE
      };
    } else if (this.isException) {
      return {
        isValid: false,
        errorMessage: this.errorMessage
      };
    }

    return { isValid: true };
  }
}
