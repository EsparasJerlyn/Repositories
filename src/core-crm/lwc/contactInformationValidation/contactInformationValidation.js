/**
 * @description A LWC component for validating Contact Information using Loqate
 *
 * @see ../classes/ContactInformationValidationCtrl.cls
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                                              |
      |---------------------------|-----------------------|--------------|-------------------------------------------------------------|
      | angelika.j.s.galang       | September 3, 2021     | DEP1-156     | Created file                                                | 
      | angelika.j.s.galang       | September 8, 2021     | DEP1-157,172 | Added error message for conversion and validation handler   | 
      | kathy.cornejo             | May 31, 2022          | DEPP-2729    | Pilot 1 Optimisations                                       | 
      | eccarius.munoz            | March 28, 2023        | DEPP-5325    | Updated for Contact Layout only. Transferred under Contact  |                                       
      |                           |                       |              | Details Tab. Same functionality, changes are for UI only.   |
      | johanna.a.gibas           | May 12, 2023          | DEPP-5631    | Updated Section Title - for UI only.                        |
      
 */

import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { publish, MessageContext } from "lightning/messageService";
import { loadStyle } from "lightning/platformResourceLoader";

import customSR from "@salesforce/resourceUrl/QUTInternalCSS";
import STATUSES_CHANNEL from "@salesforce/messageChannel/StatusesMessageChannel__c";
import LEAD_SCHEMA from "@salesforce/schema/Lead";
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import getMapping from "@salesforce/apex/ContactInformationValidationCtrl.getMapping";
import validateFields from "@salesforce/apex/ContactInformationValidationCtrl.validateFields";

const CONTACT_VERIFICATION_SECTION_HEADER = "Contact Verification";
const LEAD_VERIFICATION_SECTION_HEADER = "Lead Contact Verification";
const STR_NONE = "None";
const STR_NOT_VALID = "Not Valid";
const STR_UNVALIDATED = "Unvalidated";
const STR_VALID = "Valid";
const STR_DOT = ".";
const STR_AU = "Australia (+61)";
const STR_NZ = "New Zealand (+64)";
const FIELD_MAPPING_API_NAME = "Field_Mapping__c";
const VALID_STATUSES = [
  STR_VALID.toUpperCase(),
  "Active",
  "connected|Network confirmed connection"
];
const LOCALE_MAP = {
  [STR_AU]: "AU",
  [STR_NZ]: "NZ"
};

export default class ContactInformationValidation extends LightningElement {
  @api recordId;
  @api objectApiName;
  fieldsMapping = [];
  fieldsToQuery = [];
  fieldsToValidate = [];
  isLoading;
  disableEditButton;

  /**
   * getter for UI properties
   */
  get disableValidateButton() {
    return this.fieldsToValidate.length == 0 ? true : false;
  }

  get invalidConvert() {
    return (
      this.fieldsToValidate.filter((field) => field.apiName == "Phone").length >
        0 &&
      this.fieldsToValidate.filter((field) => field.apiName == "MobilePhone")
        .length > 0 &&
      this.objectApiName == LEAD_SCHEMA.objectApiName
    );
  }

  get fieldSize() {
    return this.disableEditButton ? "4" : "6";
  }

  get statusFieldSize() {
    return this.disableEditButton ? "4" : "6";
  }

  get statusBorderBottomClass() {
    return this.disableEditButton ? "" : "slds-border_bottom";
  }

  get statusClass() {
    return this.disableEditButton
      ? "slds-align-middle"
      : "slds-align-bottom slds-p-right_small slds-p-left_medium";
  }

  get sectionTitle() {
    switch(this.objectApiName){ 
      case 'Lead': 
        return LEAD_VERIFICATION_SECTION_HEADER;
      default : 
        return CONTACT_VERIFICATION_SECTION_HEADER;
    }
  }

  //for LMS
  @wire(MessageContext)
  messageContext;

  /**
   * calls Apex method 'getMapping' and stores all fields to be queried
   */
  @wire(getMapping, {
    objApiName: "$objectApiName",
    fieldsToQuery: FIELD_MAPPING_API_NAME
  })
  handleFieldMapping({ error, data }) {
    if (data) {
      let result = JSON.parse(data);
      this.fieldsMapping = JSON.parse(result[FIELD_MAPPING_API_NAME]);
      this.fieldsToQuery = [
        ...this.fieldsMapping.map((fieldMap) =>
          this.generateFieldName(fieldMap.apiNameNoLocale)
        ),
        ...this.fieldsMapping.map((fieldMap) =>
          this.generateFieldName(fieldMap.statusValidationField)
        ),
        ...this.fieldsMapping.map((fieldMap) =>
          this.generateFieldName(fieldMap.localeField)
        )
      ];
    } else if (error) {
      this.generateToast("Error.", LWC_Error_General, "error");
    }
  }

  /**
   * gets the actual field values and assigns them for the fields to display
   */
  @wire(getRecord, { recordId: "$recordId", fields: "$fieldsToQuery" })
  handleFieldValues({ error, data }) {
    if (data) {
      //get all non-empty fields with 'None' validation status
      const fieldsMapping = this.fieldsMapping;
      const fieldsToValidate = fieldsMapping
        .filter(
          (field) =>
            getFieldValue(
              data,
              this.generateFieldName(field.statusValidationField)
            ) == STR_NONE &&
            getFieldValue(data, this.generateFieldName(field.apiNameNoLocale))
        )
        .map((field) => {
          let _field = {};

          _field.apiName = field.apiName;
          _field.loqateRequest = field.loqateRequest;
          _field.loqateResponse = field.loqateResponse;
          _field.statusValidationField = field.statusValidationField;
          _field.locale =
            LOCALE_MAP[
              getFieldValue(data, this.generateFieldName(field.localeField))
            ];
          _field.value = getFieldValue(
            data,
            this.generateFieldName(field.apiNameNoLocale)
          );
          _field.localePicklistValue = getFieldValue(
            data,
            this.generateFieldName(field.localeField)
          );

          return _field;
        });

      fieldsMapping.forEach(field => {
        const localeFieldValue = getFieldValue(
          data,
          this.generateFieldName(field.localeField)
        );

        let isValidated = false;
        let fieldStatus = getFieldValue(
          data,
          this.generateFieldName(field.statusValidationField)
        );

        if (fieldStatus == STR_VALID || fieldStatus == STR_UNVALIDATED || fieldStatus == STR_NOT_VALID) {
          isValidated = true;
        }

        field.isValidated = isValidated;
        field.localeFieldValue = localeFieldValue;
      });

      this.fieldsMapping = fieldsMapping;

      this.fieldsToValidate = fieldsToValidate;
      this.publishMessage();
    } else if (error) {
      this.generateToast("Error.", LWC_Error_General, "error");
    }
  }

  connectedCallback() {
    this.publishMessage();
  }

  renderedCallback() {
    Promise.all([loadStyle(this, customSR + "/QUTCRMCSS.css")]);
  }

  /**
   * concatenates object and field api name
   */
  generateFieldName(field) {
    return this.objectApiName + STR_DOT + field;
  }

  /**
   * creates toast notification
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
   * publishes the LMS
   */
  publishMessage() {
    const payload = { invalidConvert: this.invalidConvert };
    publish(this.messageContext, STATUSES_CHANNEL, payload);
  }

  /**
   * triggers spinner to show when Save is clicked and updates record
   */
  handleSaveButton(event) {
    this.isLoading = true;
    event.preventDefault();
    let fields = event.detail.fields;
    fields.Id = this.recordId;

    this.fieldsMapping.forEach((field) => {
      let apiName = '';

      if (fields[field.apiNameNoLocale]) {
        apiName= this.combineLocaleAndNumber(
          fields[field.localeField],
          fields[field.apiNameNoLocale]
        );
      }

      fields[field.apiName] = apiName;
    });

    this.template.querySelector("lightning-record-edit-form").submit(fields);
  }

  combineLocaleAndNumber(locale, number) {
    let localeFormatted = locale.replace(/[^0-9\.]+/g, "");
    let num = number.replace(/\D/g, "");
    if (locale) {
      let tempNum = num.slice(0, 2);
      if (localeFormatted == tempNum) {
        num = num.slice(2);
      }
      return localeFormatted + parseInt(num);
    }
    return parseInt(num).toString();
  }

  /**
   * hides spinner and shows toast when save is successful
   */
  handleSuccess() {
    this.isLoading = false;
    this.successfulSave();
  }

  successfulSave() {
    this.disableEditButton = false;
    this.generateToast("Success!", "Record updated.", "success");
  }

  /**
   * hides spinner and shows toast when record edit form fails
   */
  handleError(event) {
    
    if(event.detail && event.detail.output && event.detail.output.errors){
      this.generateToast("Error.", event.detail.output.errors[0].message, "error");
    }else{
      this.generateToast("Error.", LWC_Error_General, "error");
    }
    this.isLoading = false;
    
  }

  /**
   * resets input fields when cancelled
   */
  handleCancelButton() {
    this.disableEditButton = false;

    const inputFields = this.template.querySelectorAll("lightning-input-field");
    if (inputFields) {
      inputFields.forEach((field) => {
        field.reset();
      });
    }
  }

  /**
   * disables edit button
   */
  handleEditButton() {
    this.disableEditButton = true;
  }

  /**
   * calls Apex method 'validateFields' and assigns results
   */
  handleValidateButton() {
    this.isLoading = true;

    validateFields({
      validateRequestList: JSON.stringify(this.fieldsToValidate)
    })
      .then((result) => {
        let payload = JSON.parse(result); //list of payloads
        let fieldsToUpdate = {};

        this.fieldsToValidate.forEach((field) => {
          let _statusValue;
          let payloadResponseForField = payload.find(
            (payloadItem) =>
              payloadItem[field.loqateRequest] == field.value &&
              payloadItem[field.locale] == field.country
          );

          _statusValue = payloadResponseForField[field.loqateResponse];
          if (VALID_STATUSES.includes(_statusValue)) {
            fieldsToUpdate[field.statusValidationField] = STR_VALID;
            fieldsToUpdate[field.apiName] = this.combineLocaleAndNumber(
              field.localePicklistValue,
              field.value
            );
          } else {
            fieldsToUpdate[field.statusValidationField] = STR_NOT_VALID;
            fieldsToUpdate[field.apiName] = null;
          }
        });
        this.handleUpdateFields(fieldsToUpdate, true);
      })
      .catch((error) => {
        this.generateToast("Error.", LWC_Error_General, "error");
        this.isLoading = false;
      });
  }

  /**
   * updates fields
   */
  handleUpdateFields(fieldsToUpdate, forValidate) {
    this.isLoading = true;

    const fields = { ...fieldsToUpdate };
    fields.Id = this.recordId;

    const recordInput = { fields };
    updateRecord(recordInput)
      .then(() => {
        if (forValidate) {
          this.generateToast(
            "Success!",
            this.fieldsToValidate.length + " field/s validated.",
            "success"
          );
        }
      })
      .catch(() => {
        this.generateToast("Error.", LWC_Error_General, "error");
      })
      .finally(() => {
        this.isLoading = false;
      });
  }
}
