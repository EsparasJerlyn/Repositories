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
 *    | ryan.j.a.dela.cruz        | June 26, 2023         | DEPP-5942            | Work Email Field Form Validation             |
 */

import { LightningElement, api, track } from "lwc";
import getExistingContactEmailDuplicatesForWorkEmailInputFlow from "@salesforce/apex/ContactService.getExistingContactEmailDuplicatesForWorkEmailInputFlow";
import { loadStyle } from "lightning/platformResourceLoader";
import CustomFlowCSS from "@salesforce/resourceUrl/CustomFlowCSS";

export default class FlowWorkEmailField extends LightningElement {
  @api workEmail;
  @api required;
  @track errorMessage = "";
  messageValue = "Work email must be unique across the organization.";
  @track isDuplicate = false;
  @track isException = false;
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

  handleWorkEmailChange(event) {
    const workEmailValue = event.target.value;

    clearTimeout(this.timer);

    if (workEmailValue) {
      this.timer = setTimeout(async () => {
        try {
          const result =
            await getExistingContactEmailDuplicatesForWorkEmailInputFlow({
              emailInput: workEmailValue
            });

          this.errorMessage = result ? this.messageValue : "";
          this.isDuplicate = result;
          this.workEmail = workEmailValue;
          this.isException = false;
        } catch (error) {
          this.errorMessage = error.message || "An error occurred";
          this.isException = true;
        }
      }, 300);
    } else {
      this.errorMessage = "";
      this.workEmail = workEmailValue;
    }
  }

  @api
  validate() {
    if (this.required && (!this.workEmail || this.isDuplicate)) {
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
      return { isValid: true };
    }
  }
}
