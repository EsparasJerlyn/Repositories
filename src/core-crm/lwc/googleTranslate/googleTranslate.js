/**
 * @description LWC for Google Translate functionality to be used on Case Lightning Record Page
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
 *    |---------------------------|-----------------------|----------------------|----------------------------------------------|
 *    | eccarius.munoz            | November 08, 2022     | DEPP-4231            | Created file                                 |
 *    | ryan.j.a.dela.cruz        | October 17, 2023      | DEPP-5902            | Added translate integration service          |
 *    | alexander.cadalin         | December 11, 2023     | DEPP-7407            | modified for use under service appointments  |
 */

import { LightningElement, track, api, wire } from "lwc";
import { createRecord, getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import GOOGLE_LOGO from "@salesforce/resourceUrl/googleLogo";
import CASE_COMMENT_OBJ from "@salesforce/schema/CaseComment";
import CASE_SUBJECT_FIELD from "@salesforce/schema/Case.Subject";
import CASE_DESCRIPTION_FIELD from "@salesforce/schema/Case.Description";
import SERVAPP_TOPIC_FIELD from "@salesforce/schema/ServiceAppointment.Appointment_Topic__c";
import SERVAPP_DESCRIPTION_FIELD from "@salesforce/schema/ServiceAppointment.Description";

import getSupportedLanguages from "@salesforce/apex/TranslateService.getSupportedLanguages";
import translateText from "@salesforce/apex/TranslateService.translateText";
import detectLanguage from "@salesforce/apex/TranslateService.detectLanguage";

const CASE_FIELDS = [CASE_SUBJECT_FIELD, CASE_DESCRIPTION_FIELD];
const SERVAPP_FIELDS = [SERVAPP_TOPIC_FIELD, SERVAPP_DESCRIPTION_FIELD];

const SUCCESS_TITLE = "Success!";
const SUCCESS_VARIANT = "success";
const SUCCESS_MSG_COMMENT = "Added to case comment.";
const WARNING_TITLE = "Warning";
const WARNING_VARIANT = "warning";
const WARNING_MSG_SAME_LANG =
  "Source and target languages should be different.";
const HEADER_TITLE = "Translate";
const COPY_SUBJ_DESC_BTN_LABEL = "Copy Subject & Description";
const COPY_TOPIC_DESC_BTN_LABEL = "Copy Topic & Description";
const COPY_TRANS_BTN_LABEL = "Copy Translation";
const TRANS_BTN_LABEL = "Translate Text";
const ADD_TO_COMMENT_BTN_LABEL = "Add Translation to Comment";

export default class GoogleTranslate extends LightningElement {
  isShowButtonHidden = false;
  isHideButtonHidden = true;
  displayTranslation = false;

  isLoading = false;

  translateDisabled = true;
  copyTranslationDisabled = true;
  addTranslationToCommentDisabled = true;

  @track options = [];
  sourceValue;
  targetValue;
  sourceTextValue;
  targetTextValue;

  @api recordId;
  @api objectApiName;

  fields;

  /** GETTERS **/
  get googleLogo() {
    return GOOGLE_LOGO;
  }

  get headerTitle() {
    return HEADER_TITLE;
  }

  get copySubjectAndDescriptionButtonLabel() {
    if(this.objectApiName == "Case") {
      return COPY_SUBJ_DESC_BTN_LABEL;
    } else if(this.objectApiName == "ServiceAppointment") {
      return COPY_TOPIC_DESC_BTN_LABEL;
    }
  }

  get translateButtonLabel() {
    return TRANS_BTN_LABEL;
  }

  get copyTranslationButtonLabel() {
    return COPY_TRANS_BTN_LABEL;
  }

  get addTranslationToCommentButtonLabel() {
    return ADD_TO_COMMENT_BTN_LABEL;
  }

  get showAddTranslationButton() {
    return this.objectApiName == "Case" ? true : false;
  }
  /** END GETTERS **/

  connectedCallback() {
    if(this.objectApiName == "Case") {
      this.fields = CASE_FIELDS;
    } else if (this.objectApiName == "ServiceAppointment") {
      this.fields = SERVAPP_FIELDS;
    }
    this.callGetSupportedLanguages();
  }
  
  @wire(getRecord, { recordId: "$recordId", fields: "$fields" })
  currentRecord;

  /** MAIN BUTTONS **/
  /**
   * Handles copying the subject and description to the source text area,
   * detecting the source language, and updating the UI.
   */
  handleCopyFieldValues() {
    if(this.objectApiName == "Case") {
      this.sourceTextValue = this.combineCaseFieldValues();
    } else if(this.objectApiName == "ServiceAppointment") {
      this.sourceTextValue = this.combineServiceAppointmentFieldValues();
    }
    this.translateDisabled = !this.sourceTextValue;

    this.detectAndSetSourceLanguage();
  }

  /**
   * Handles the translation process, sets loading state, and calls the translation method.
   */
  handleTranslate() {
    // Prepare the data to be sent to the callTranslateText method.
    const query = this.sourceTextValue;
    const source = this.sourceValue;
    const target = this.targetValue;

    // Call the translation method
    this.callTranslateText(query, source, target);
  }

  /**
   * Handles copying the translated text to the clipboard and updates the user interface accordingly.
   */
  async handleCopyTranslation() {
    const textValueToCopy = this.targetTextValue;

    // Disable copy and add translation buttons if no target text value
    this.copyTranslationDisabled = this.addTranslationToCommentDisabled =
      !this.targetTextValue;

    try {
      if (navigator.clipboard && window.isSecureContext) {
        // Use modern clipboard API if available
        await navigator.clipboard.writeText(textValueToCopy);
      } else {
        // Fallback method for older or insecure browsers
        await this.copyFallback(textValueToCopy);
      }

      // Select and modify the target text area
      await this.selectTargetTextArea();
    } catch (error) {
      this.handleError(error, "handleCopyTranslation");
    }
  }

  /**
   * Handles saving the translated text as a comment on a case comment record and displays a toast message.
   */
  handleTranslationToComment() {
    let commentToSave = this.template.querySelector(".targetTextArea").value;
    let fields = {};
    fields = {
      ParentId: this.recordId,
      CommentBody: commentToSave
    };
    const recordInput = { apiName: CASE_COMMENT_OBJ.objectApiName, fields };
    createRecord(recordInput)
      .then(() => {
        this.generateToast(SUCCESS_TITLE, SUCCESS_MSG_COMMENT, SUCCESS_VARIANT);
      })
      .catch((error) => {
        this.handleError(error, "createRecord");
      });
  }
  /** END MAIN BUTTONS **/

  /** CALLOUT METHODS **/
  /**
   * Calls the Apex method to fetch a list of supported languages,
   * parses the response, and populates options for a combobox.
   */
  callGetSupportedLanguages() {
    this.isLoading = true;
    const logger = this.template.querySelector("c-logger");
    // Call the Apex method to get supported languages
    getSupportedLanguages()
      .then((result) => {
        // Parse the JSON response and set options for the combobox
        let supportedLanguages = JSON.parse(result);

        this.options = [
          ...Object.keys(supportedLanguages).map((key) => ({
            label: supportedLanguages[key],
            value: key
          }))
        ];

        // Filter out the 'zh' (Chinese), 'iw' (Hebrew), 'fil' (Filipino), and 'jw' (Javanese) options
        this.options = this.options.filter(
          (option) =>
            option.value !== "zh" && // Simplified Chinese
            option.value !== "iw" && // Hebrew
            option.value !== "fil" && // Filipino (Tagalog)
            option.value !== "jw" // Javanese
        );

        // Sort the options alphabetically based on the label property
        this.options.sort((a, b) => a.label.localeCompare(b.label));

        // Set this.sourceValue to the value of the first option (the key of the sorted options)
        if (this.options.length > 0) {
          this.sourceValue = this.options[0].value;
        }

        // Set "English" as the default value for target language
        this.targetValue = "en";
        this.isLoading = false;
      })
      .catch((error) => {
        this.isLoading = false;
        this.handleError(error, "getSupportedLanguages");
      });
  }

  /**
   * Detects the source language of the combined text and sets the sourceValue attribute.
   */
  detectAndSetSourceLanguage() {
    this.isLoading = true;
    const query = this.sourceTextValue;

    detectLanguage({ query })
      .then((result) => {
        this.sourceValue = result;
        this.setSourceTextAreaValue();
        this.isLoading = false;
      })
      .catch((error) => {
        this.isLoading = false;
        this.handleError(error, "detectLanguage");
      });
  }

  /**
   * Calls the Apex method to translate text and handles the result.
   */
  callTranslateText(query, source, target) {
    this.isLoading = true;

    // Check if the source and target languages are the same
    if (source === target) {
      this.isLoading = false;
      this.generateToast(WARNING_TITLE, WARNING_MSG_SAME_LANG, WARNING_VARIANT);
      return;
    }

    // Call the Apex method to translate text if source and target are different
    translateText({ query, source, target })
      .then((result) => {
        // Handle the result from the Apex method here.
        this.targetTextValue = result;
        const targetTextArea = this.template.querySelector(".targetTextArea");
        targetTextArea.value = result;
        // Trigger the 'change' event on the text area
        const changeEvent = new Event("change");
        targetTextArea.dispatchEvent(changeEvent);
        this.isLoading = false;
      })
      .catch((error) => {
        this.isLoading = false;
        this.handleError(error, "translateText");
      });
  }
  /** END CALLOUT METHODS **/

  /** UTILITY METHODS **/
  /**
   * Sets the value of the source text area and ensures it is in focus.
   */
  setSourceTextAreaValue() {
    const sourceTextArea = this.template.querySelector(".sourceTextArea");
    sourceTextArea.value = this.sourceTextValue;
    const start = 0;
    const end = sourceTextArea.value.length;
    const mode = "end";
    sourceTextArea.focus();
    sourceTextArea.setRangeText(this.sourceTextValue, start, end, mode);
  }

  /**
   * Combines subject and description and sets sourceTextValue accordingly.
   */
  combineCaseFieldValues() {
    const subject = this.currentRecord.data.fields.Subject.value;
    const description = this.currentRecord.data.fields.Description.value;

    if (subject && description) {
      return `${subject}\n${description}`;
    } else if (subject) {
      return subject;
    } else if (description) {
      return description;
    }

    return "";
  }

  /**
   * Combines subject and description and sets sourceTextValue accordingly.
   */
  combineServiceAppointmentFieldValues() {
    const topic = this.currentRecord.data.fields.Appointment_Topic__c.value;
    const description = this.currentRecord.data.fields.Description.value;

    if (topic && description) {
      return `${topic}\n${description}`;
    } else if (topic) {
      return topic;
    } else if (description) {
      return description;
    }

    return "";
  }

  /**
   * Function to select and modify the target text area.
   * This function updates the target text area's value, selects its contents, and replaces the selection with new text.
   */
  async selectTargetTextArea() {
    const targetTextArea = this.template.querySelector(".targetTextArea");

    // Set the value of the target text area
    targetTextArea.value = this.targetTextValue;

    // Select the text in the target text area
    const existingText = targetTextArea.value;
    const start = 0;
    const end = existingText.length;
    const mode = "select";

    targetTextArea.focus();
    targetTextArea.setRangeText(this.targetTextValue, start, end, mode);
  }

  /**
   * Fallback copy function for older or insecure browsers.
   * This function creates a temporary textarea, copies text to it, and attempts to copy the text to the clipboard using execCommand.
   * It resolves the promise if successful and rejects if not.
   */
  async copyFallback(textValueToCopy) {
    const textArea = document.createElement("textarea");
    textArea.value = textValueToCopy;

    // Position the temporary textarea offscreen
    textArea.name = "temporaryTextArea";
    textArea.style.position = "fixed";
    textArea.style.left = "-999999px";
    textArea.style.top = "-999999px";

    // Append the temporary textarea to the document body
    document.body.appendChild(textArea);

    // Focus on the textarea and select its contents
    textArea.focus();
    textArea.select();

    // Attempt to copy the text using execCommand
    // Resolve the promise if successful, reject if not
    await new Promise((resolve, reject) => {
      const successful = document.execCommand("copy");
      successful ? resolve() : reject();

      // Remove the temporary textarea from the DOM
      textArea.remove();
    });
  }

  /**
   * Handler for the sourceValue change event.
   */
  handleSourceValueChange(event) {
    this.sourceValue = event.detail.value;
  }

  /**
   * Handler for the targetValue change event.
   */
  handleTargetValueChange(event) {
    this.targetValue = event.detail.value;
  }

  /**
   * Handler for the sourceTextValue change event.
   * This function updates the source text value and manages the translation button's disabled state.
   */
  handleSourceTextValueChange(event) {
    this.sourceTextValue = event.target.value;
    this.translateDisabled = !this.sourceTextValue;
  }

  /**
   * Handler for the targetTextValue change event.
   * This function updates the target text value and manages the copy and add translation buttons' disabled states.
   */
  handleTargetTextValueChange(event) {
    this.targetTextValue = event.target.value;
    this.copyTranslationDisabled = !this.targetTextValue;
    this.addTranslationToCommentDisabled = !this.targetTextValue;
  }

  /**
   * Handler for the show button click event.
   * This function hides the show button, displays the hide button, and shows the translation.
   */
  handleShowButton() {
    this.isShowButtonHidden = true;
    this.isHideButtonHidden = false;
    this.displayTranslation = true;
  }

  /**
   * Handler for the hide button click event.
   * This function hides the hide button, displays the show button, and hides the translation.
   */
  handleHideButton() {
    this.isShowButtonHidden = false;
    this.isHideButtonHidden = true;
    this.displayTranslation = false;
  }

  /**
   * Generates and displays a toast message.
   */
  generateToast(_title, _message, _variant) {
    const evt = new ShowToastEvent({
      title: _title,
      message: _message,
      variant: _variant
    });

    this.dispatchEvent(evt);
  }

  /**
   * Handles errors that occur during callout and logs them.
   * @param {object} error - The error object.
   * @param {string} functionName - The name of the function where the error occurred.
   */
  handleError(error, functionName) {
    const logger = this.template.querySelector("c-logger");
    if (logger) {
      logger.error(
        `Exception caught in method ${functionName} in LWC googleTranslate: `,
        JSON.stringify(error)
      );
      logger.saveLog();
    }
  }
  /** END UTILITY METHODS **/
}
