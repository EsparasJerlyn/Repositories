import { LightningElement, api, wire } from "lwc";
import { RefreshEvent } from "lightning/refresh";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { reduceErrors } from "c/lwcUtility";
import customForm from "@salesforce/resourceUrl/CustomRecordEditForm";
import { loadStyle } from "lightning/platformResourceLoader";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import LIST_OBJECT from "@salesforce/schema/List__c";

export default class DynamicRecordEditForm extends LightningElement {
  @api objectApiName;
  @api recordObjectApiName;
  @api recordId;
  @api column1FieldList;
  @api column2FieldList;
  @api hiddenFieldList;
  @api showEditField;

  detailRecordId;

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

  @api submit() {
    const inputFields = this.template.querySelectorAll("lightning-input-field");
    const fields = {};

    inputFields.forEach((field) => {
      fields[field.fieldName] = field.value;
    });

    console.log("HIDDEN", JSON.stringify(this.hiddenFieldList));
    if (this.hiddenFieldList) {
      const url = window.location.href;
      this.detailRecordId = url.split("/r/")[1].split("/")[1];

      this.hiddenFieldList.forEach((hiddenField) => {
        if (hiddenField.name === this.recordObjectApiName) {
          console.log("BEFORE SUBMIT", this.detailRecordId);
          fields[hiddenField.name] = this.detailRecordId;
        } else {
          fields[hiddenField.name] = hiddenField.value;
        }
      });
    }

    console.log("FIELDS", JSON.parse(JSON.stringify(fields)));

    let targetForm = this.template.querySelector("lightning-record-edit-form");
    targetForm.submit(fields);
  }

  handleSubmit() {
    console.log("SUBMITTED");
  }

  handleSuccess(event) {
    event.preventDefault();
    console.log("Record saved (", event.detail.apiName, "):", event.detail.id);

    this.showEditField = true;
    this.dispatchEvent(
      new CustomEvent("showfooter", {
        detail: {
          message: false
        }
      })
    );
    this.dispatchEvent(
      new CustomEvent("recordidupdate", {
        detail: {
          message: this.detailRecordId
        }
      })
    );
    this.dispatchEvent(new RefreshEvent());
  }

  handleError(error) {
    console.log("ERROR", reduceErrors(error).join(", "));
    new ShowToastEvent({
      title: "Error!",
      message: reduceErrors(error).join(", "),
      variant: "error"
    });
  }
}
