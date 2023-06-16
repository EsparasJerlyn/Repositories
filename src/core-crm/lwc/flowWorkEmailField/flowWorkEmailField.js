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
 */

import { LightningElement,api,track } from 'lwc';
import getExistingContactEmailDuplicatesForWorkEmailInputFlow from "@salesforce/apex/Contactservice.getExistingContactEmailDuplicatesForWorkEmailInputFlow";

export default class FlowWorkEmailField extends LightningElement {

    @api workEmail;
    @api required;
    @track errorMessage = "";
    messageValueExisting = "Work Email must be unique accross the organization.";
    messageWhenValueMissing = "Please enter some valid input. Input is not optional"
    timer;

    // Event function that will get the email input of the user.
    handleWorkEmailChange(event) {
      const workEmailValue = event.target.value;
      const workEmailInput = this.template.querySelector("lightning-input");

      // Clear previous timer
      clearTimeout(this.timer);
      // Check if workEmailValue has a value
      if (workEmailValue) {
        // Set a new timer to wait for user to finish typing
        this.timer = setTimeout(() => {
          // Call Apex method to check if there is exsiting email across the system.
          getExistingContactEmailDuplicatesForWorkEmailInputFlow({ emailInput: workEmailValue })
            .then((result) => {
                if(result){
                    // email exist across the systsm 
                    this.errorMessage = this. messageValueExisting;
                    workEmailInput.setCustomValidity(this.errorMessage);
                }else {
                    // email does not exist and proceed to the normal transactions
                    this.errorMessage = "";
                    workEmailInput.setCustomValidity("");
                }
                workEmailInput.reportValidity();
               // Update the @api work email property
                  this.workEmail = workEmailValue;
            })
            .catch((error) => {
              this.errorMessage = error.message || "An error occurred";
              workEmailInput.setCustomValidity(this.errorMessage);
              workEmailInput.reportValidity();
            });
        }, 300); // Adjust the debounce delay (in milliseconds) as needed
      } else {
        // Clear the error message, reset custom validity, and update ABN
        this.errorMessage = "";
        workEmailInput.setCustomValidity("");
        workEmailInput.reportValidity();
        this.workEmail = workEmailValue;
      }
    }

    @api
    validate() {
      // If it is not valid then return error message and isValid = false
      if (this.required && !this.workEmail) {
        return {
          isValid: false,
          errorMessage: this.messageWhenValueMissing
        };
      } else {
        return { isValid: true };
      }
    }
}
