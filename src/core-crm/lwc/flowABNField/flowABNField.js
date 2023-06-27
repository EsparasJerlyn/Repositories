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
 *    | ryan.j.a.dela.cruz        | June 26, 2023         | DEPP-5942            | ABN Field Form Validation                    |
 */
import { LightningElement, api, track } from "lwc";
import checkABNExists from "@salesforce/apex/AccountCtrl.checkABNExists";
import { loadStyle } from "lightning/platformResourceLoader";
import CustomFlowCSS from "@salesforce/resourceUrl/CustomFlowCSS";

export default class ABNCheckComponent extends LightningElement {
  @api ABN;
  @track abnExists = false;
  @track errorMessage = "";
  messageValue = "ABN should be unique.";
  isException = false;
  timer;

  beforeUnloadHandler(event) {
    window.sessionStorage.removeItem("customCSSLoaded");
  }

  connectedCallback() {
    window.addEventListener(
      "beforeunload",
      this.beforeUnloadHandler.bind(this)
    );

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
            logger.error(JSON.stringify(error));
            logger.saveLog();
          }
        });
    }
  }

  // Handle ABN input change event
  handleABNChange(event) {
    const abnValue = event.target.value;

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

  // Clear error message
  clearErrorMessage() {
    this.errorMessage = "";
  }

  // Validate the ABN input
  @api
  validate() {
    if (this.errorMessage === this.messageValue) {
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
