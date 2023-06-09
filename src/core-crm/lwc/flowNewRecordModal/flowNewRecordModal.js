/**
 * @description An LWC for new record modal look n feel and logic for lookup component
 * @see ../lwc/flowLookup
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
 *    |---------------------------|-----------------------|----------------------|----------------------------------------------|
 *    | ryan.j.a.dela.cruz        | June 5, 2023          | DEPP-5385            | Created file                                 |
 */
import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class FlowNewRecordModal extends LightningModal {
  @api recordTypeId;
  @api fields;
  @api objectApiName;
  @api modalTitle;

  @api isError;
  @api errorMessage;

  handleSuccess(event) {
    let output = {
      status: "success",
      id: event.detail.id,
      fields: event.detail.fields
    };
    this.close(output);
  }

  handleCancel(event) {
    this.close("cancel");
  }
}
