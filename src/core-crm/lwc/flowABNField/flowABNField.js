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
 */
import { LightningElement, api, track } from "lwc";
import checkABNExists from "@salesforce/apex/AccountCtrl.checkABNExists";

export default class ABNCheckComponent extends LightningElement {
  @api ABN;
  @track abnExists = false;
  @track errorMessage = "";
  messageValue = "ABN should be unique.";
  timer;

  handleABNChange(event) {
    const abnValue = event.target.value;
    const abnInput = this.template.querySelector("lightning-input");

    // Clear previous timer
    clearTimeout(this.timer);

    // Check if abnValue has a value
    if (abnValue) {
      // Set a new timer to wait for user to finish typing
      this.timer = setTimeout(() => {
        // Call Apex method to check if ABN already exists
        checkABNExists({ abn: abnValue })
          .then((result) => {
            this.abnExists = result;
            if (this.abnExists) {
              this.errorMessage = this.messageValue;
              abnInput.setCustomValidity(this.errorMessage);
            } else {
              this.errorMessage = "";
              abnInput.setCustomValidity("");
            }
            abnInput.reportValidity();

            // Update the @api ABN property
            this.ABN = abnValue;
          })
          .catch((error) => {
            // Handle error and set error message
            this.errorMessage = error.message || "An error occurred";
            abnInput.setCustomValidity(this.errorMessage);
            abnInput.reportValidity();
          });
      }, 300); // Adjust the debounce delay (in milliseconds) as needed
    } else {
      // Clear the error message, reset custom validity, and update ABN
      this.errorMessage = "";
      abnInput.setCustomValidity("");
      abnInput.reportValidity();
      this.ABN = abnValue;
    }
  }

  @api
  validate() {
    if (this.errorMessage === this.messageValue) {
      return {
        isValid: false,
        errorMessage: "Please enter a unique ABN value."
      };
    } else {
      return {
        isValid: true
      };
    }
  }
}
