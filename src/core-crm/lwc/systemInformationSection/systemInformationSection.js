/**
 * @description A reusable Lightning Web Component to mimic standard look and feel of system information section
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
import { getRecord } from "lightning/uiRecordApi";

export default class SystemInformationSection extends LightningElement {
  @api recordId;
  @api objectApiName; // Property to accept the object API name dynamically
  createdById;
  createdByName;
  createdDate;
  lastModifiedById;
  lastModifiedByName;
  lastModifiedDate;
  error;

  @wire(getRecord, { recordId: "$recordId", fields: "$dynamicFields" })
  records({ error, data }) {
    if (data) {
      this.createdById = data.fields.CreatedById.value;
      this.createdByName = data.fields.CreatedBy.displayValue;
      this.createdDate = data.fields.CreatedDate.displayValue;
      this.lastModifiedById = data.fields.LastModifiedById.value;
      this.lastModifiedByName = data.fields.LastModifiedBy.displayValue;
      this.lastModifiedDate = data.fields.LastModifiedDate.displayValue;
      this.error = undefined;
    } else if (error) {
      this.error = error;
    }
  }

  label = {
    createdBy: "Created By",
    lastModifiedBy: "Last Modified By"
  };

  get dynamicFields() {
    // Dynamically generate fields based on the object API name
    if (this.objectApiName) {
      console.log("objectApiName: ", this.objectApiName);
      return [
        `${this.objectApiName}.CreatedById`,
        `${this.objectApiName}.CreatedBy.Name`,
        `${this.objectApiName}.CreatedDate`,
        `${this.objectApiName}.LastModifiedById`,
        `${this.objectApiName}.LastModifiedBy.Name`,
        `${this.objectApiName}.LastModifiedDate`
      ];
    }
    return [];
  }

  get createByUrl() {
    return `/lightning/r/${this.objectApiName}/${this.createdById}/view`;
  }

  get modifiedByUrl() {
    return `/lightning/r/${this.objectApiName}/${this.lastModifiedById}/view`;
  }
}
