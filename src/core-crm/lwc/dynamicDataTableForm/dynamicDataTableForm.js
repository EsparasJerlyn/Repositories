/**
 * @description LWC that handles the edit and new forms for the dynamicdatatable
 * @see ../lwc/dynamicDataTable
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
 *    |---------------------------|-----------------------|----------------------|----------------------------------------------|
 *    | roy.nino.s.regala         | June 15, 2023         | DEPP-5391            | Created file                                 |
 */
import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class DynamicDataTableForm extends LightningElement {
  @api showModal = false;
  @api showCloseButton = false;
  @api sobjectLabel;
  @api sobjectApiName;
  @api recordId;
  @api recordName;
  @api parentId;
  @api relatedListLabel;
  @api parentObjectApiName;
  @api actionType;
  @api screenFlowApiName;
  @api recordTypeId;
  @api dynamicDataTableInput;
  modalHeader = '';

  @api show() {
    this.showModal = true;
  }

  @api hide() {
    this.showModal = false;
  }

  handleClose() {
    this.showModal = false;
  }
  handleDialogClose() {
    this.handleClose();
  }

  isNew() {
    return this.recordId == null || this.recordId == "";
  }
  get header() {
    return this.isNew()
      ? this.modalHeader
      : `Edit ${this.recordName}`;
  }

  get isScreenFlow() {
    return this.actionType == "Screen Flow" ? true : false;
  }

  get isLWC() {
    return this.actionType == "LWC" ? true : false;
  }

  get inputVariables() {
    return this.recordId
      ? [
          {
            name: "RecordId",
            type: "String",
            value: this.recordId
          },
          {
            name: "DynamicDataTableInput",
            type: "String",
            value: this.dynamicDataTableInput
          }
        ]
      : [
          {
            name: "ParentId",
            type: "String",
            value: this.parentId
          },
          {
            name: "DynamicDataTableInput",
            type: "String",
            value: this.dynamicDataTableInput
          },
          {
            name: "ParentObjectApiName",
            type: "String",
            value: this.parentObjectApiName
          },
          {
            name: "RecordTypeId",
            type: "String",
            value: this.recordTypeId ? this.recordTypeId : ""
          }
        ];
  }

  handleStatusChange(event) {
    if (event.detail.status === "STARTED") {
      let outputVariables = event.detail.outputVariables;
      let ouputVar = outputVariables?outputVariables.find((e) => e.name === "modalTitle"):{};
        this.modalHeader = ouputVar?ouputVar.value:'New ' + this.sobjectLabel;
    }

    if (event.detail.status === "FINISHED") {
      const message = `${
        this.isNew() ? this.sobjectLabel : this.recordName
      } was ${this.isNew() ? "created" : "saved"}.`;
      const evt = new ShowToastEvent({
        title: message,
        variant: "success"
      });
      this.dispatchEvent(evt);
      this.dispatchEvent(new CustomEvent("refreshdata"));
      this.handleClose();
      // set behavior after a finished flow interview
    }
  }
}
