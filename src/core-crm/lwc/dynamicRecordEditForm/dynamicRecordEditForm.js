/**
 * @description A reusable Lightning Web Component to mimic standard look and feel of a record details page
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                  |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------|
 *    | ryan.j.a.dela.cruz             | February 2, 2024      | DEPP-6950              | Created file                    |
 *    |                                |                       |                        |                                 |
 */

import { LightningElement, api, wire } from "lwc";
import { reduceErrors } from "c/lwcUtility";
import customForm from "@salesforce/resourceUrl/CustomRecordEditForm";
import { loadStyle } from "lightning/platformResourceLoader";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import LIST_OBJECT from "@salesforce/schema/List__c";

export default class DynamicRecordEditForm extends LightningElement {
  @api recordObjectApiName; // FOR DELETION
  @api fieldListToOverride;
  @api passedObjectApiName;
  @api passedRecordId;
  @api column1FieldList;
  @api column2FieldList;
  @api hiddenFieldList;
  @api showEditField;

  detailRecordId;
  error;

  renderedCallback() {
    Promise.all([loadStyle(this, customForm)]).then(() => {});
  }

  handleEdit() {
    // Dispatch showEditField custom event to parent before negation
    this.dispatchEvent(
      new CustomEvent("showfooter", {
        detail: {
          message: this.showEditField
        }
      })
    );

    this.showEditField = !this.showEditField;
  }

  _recordTypeId;
  @wire(getObjectInfo, { objectApiName: LIST_OBJECT })
  objectInfo({ data, error }) {
    if (data) {
      const recordTypes = data.recordTypeInfos;
      this._recordTypeId = Object.keys(recordTypes).find(
        (key) => recordTypes[key].name === "Engagement Opportunity"
      );
    } else if (error) {
      // Handle error
      console.error("Error retrieving object information", error);
    }
  }

  get recordTypeId() {
    return this._recordTypeId;
  }

  @api async submit() {
    const inputFields = this.template.querySelectorAll("lightning-input-field");
    const fields = {};

    // Initialize or retrieve the session object
    let sessionData = sessionStorage.getItem("combinedFields");
    const combinedFields = sessionData ? JSON.parse(sessionData) : {};

    inputFields.forEach((field) => {
      fields[field.fieldName] = field.value;
    });

    // Merge current fields with the existing combinedFields
    const sessionFields = { ...combinedFields, ...fields };

    // Save the updated combinedFields in the session
    sessionStorage.setItem("combinedFields", JSON.stringify(sessionFields));

    if (this.hiddenFieldList) {
      const url = window.location.href;
      this.detailRecordId = url.split("/r/")[1].split("/")[1];

      this.hiddenFieldList.forEach((hiddenField) => {
        switch (hiddenField.name) {
          case this.fieldListToOverride.engagementOpportunityId:
            fields[hiddenField.name] = this.detailRecordId;
            break;
          case this.fieldListToOverride.listName:
            fields[hiddenField.name] =
              sessionFields.Engagement_Opportunity_Name__c;
            break;
          case this.fieldListToOverride.listPurpose:
            fields[hiddenField.name] = sessionFields.Summary__c;
            break;
          case this.fieldListToOverride.recordTypeId:
            fields[hiddenField.name] = this.recordTypeId;
            break;
          default:
            fields[hiddenField.name] = hiddenField.value;
        }
      });
    }

    console.log("[1] Actual Submit: ", JSON.parse(JSON.stringify(fields)));

    // Initialize or retrieve the session object
    let targetForm = this.template.querySelector("lightning-record-edit-form");
    targetForm.submit(fields);
  }

  handleSuccess(event) {
    event.preventDefault();
    console.log(
      "[2] Record saved (",
      event.detail.apiName,
      "):",
      event.detail.id
    );

    if (event.detail.apiName === "List__c") {
      console.log("[3] recordidupdate");

      this.dispatchEvent(
        new CustomEvent("recordidupdate", {
          detail: {
            message: event.detail.id
          }
        })
      );
    } else {
      // console.log("[3] success");
      // this.dispatchEvent(
      //   new CustomEvent("success", {
      //     detail: {
      //       message: true
      //     }
      //   })
      // );
    }

    this.showEditField = true;
    this.dispatchEvent(
      new CustomEvent("showfooter", {
        detail: {
          message: false
        }
      })
    );
  }

  handleError(error) {
    console.log("ERROR Reduced: ", reduceErrors(error).join(", "));
    sessionStorage.setItem("dynamicErrors", reduceErrors(error).join(", "));
    this.dispatchEvent(
      new CustomEvent("error", {
        detail: {
          message: error
        }
      })
    );
  }
}
