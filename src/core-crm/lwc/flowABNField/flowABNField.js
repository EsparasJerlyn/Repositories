/**
 * @description An LWC to check if ABN exists on user type
 * @see ../classes/AccountCtrl
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
 *    |---------------------------|-----------------------|----------------------|----------------------------------------------|
 *    | ryan.j.a.dela.cruz        | June 5, 2023          | DEPP-5385            | Created file                                 |
 *    | ryan.j.a.dela.cruz        | June 26, 2023         | DEPP-5942            | Added ABN Field Form Validation              |
 *    | ryan.j.a.dela.cruz        | August 3, 2023        | DEPP-6093            | Added Retention Of ABN Field Value           |
 */
import { LightningElement, api, track } from "lwc";
import checkABNExists from "@salesforce/apex/AccountCtrl.checkABNExists";
import { loadStyle } from "lightning/platformResourceLoader";
import CustomFlowCSS from "@salesforce/resourceUrl/CustomFlowCSS";

export default class ABNCheckComponent extends LightningElement {
  @api ABN;
  @track errorMessage = "";
  messageValue = "ABN should be unique.";
  abnExists = false;
  isException = false;
  timer;

  connectedCallback() {
    // Get the "uid" parameter from the URL
    const uid = this.getUrlParameter("uid");

    if (uid) {
      const sessionKey = `ABN-${uid}`;

      // Check if the value already exists in session storage
      const existingValue = sessionStorage.getItem(sessionKey);

      if (existingValue !== null) {
        // A value already exists, set it to the ABN property
        this.ABN = existingValue;
        this.checkABN(existingValue); // Initial check if value exists
      }
    }

    window.addEventListener(
      "beforeunload",
      this.beforeUnloadHandler.bind(this)
    );

    // Retrieve the session value
    const sessionValue = sessionStorage.getItem("customCSSLoaded");
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
          sessionStorage.setItem(
            "customCSSLoaded",
            JSON.stringify(this.customCSSLoaded)
          );
        })
        .catch((error) => {
          if (logger) {
            logger.error(
              "Exception caught in method connectedCallback in LWC flowABNField: ",
              JSON.stringify(error)
            );
            logger.saveLog();
          }
        });
    }
  }

  beforeUnloadHandler(event) {
    const uid = this.getUrlParameter("uid");
    if (uid) {
      const sessionKey = `ABN-${uid}`;
      sessionStorage.removeItem(sessionKey);
    }
    sessionStorage.removeItem("customCSSLoaded");
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

  // Handle ABN input change event
  handleABNChange(event) {
    const abnValue = event.target.value.trim().replace(/\s/g, ""); // Update ABN value and remove whitespaces
    clearTimeout(this.timer);

    if (abnValue) {
      // Set a timer to wait for user to finish typing
      this.timer = setTimeout(() => {
        this.checkABN(abnValue);
      }, 300);
    } else {
      // Clear error message when ABN input is empty
      this.clearErrorMessage();
    }

    const uid = this.getUrlParameter("uid");
    if (uid) {
      const sessionKey = `ABN-${uid}`;
      sessionStorage.setItem(sessionKey, abnValue);
    }

    this.ABN = abnValue; // Update ABN value
  }

  // Check if ABN already exists
  checkABN(abnValue) {
    checkABNExists({ abn: abnValue })
      .then((result) => {
        this.abnExists = result;
        this.errorMessage = this.abnExists ? this.messageValue : "";
        this.isException = false;
      })
      .catch((error) => {
        this.errorMessage = error.message || "An error occurred";
        this.isException = true;
      });
  }

  // Validate the ABN input
  @api
  validate() {
    if (this.abnExists) {
      return {
        isValid: false,
        errorMessage: this.messageValue
      };
    } else if (this.isException) {
      return {
        isValid: false,
        errorMessage: this.errorMessage
      };
    } else {
      return {
        isValid: true
      };
    }
  }
}
