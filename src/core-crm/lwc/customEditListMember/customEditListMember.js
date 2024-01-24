/**
 * @description Lightning Web Component for custom buttons.
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | neil.s.h.lesidan          | January 24, 2024      | DEPP-7005            | Created file                 |
      |                           |                       |                      |                              |
 */
import { LightningElement, api, track, wire } from 'lwc';

export default class CustomEditListMember extends LightningElement {
    @api objApiName;
    @api prePopulatedFields;
    @api saveEdit;
    @api modalHeader;
    @api rowId;

    formFields = [];

    onHandleChange(e) {
        let formFields = this.formFields;
        if (!formFields.length) {
            formFields = JSON.parse(JSON.stringify(this.prePopulatedFields));
        }

        formFields.forEach(key => {
            if (key.fieldName === e.target.name || key.fieldName === e.target.fieldName) {
                key.value = e.target.value;
            }
        })

        this.formFields = formFields;
    }

    onhandleSave() {
        this.dispatchEvent(
            new CustomEvent('handleedit', {
                detail: {
                    id: this.rowId,
                    data: this.formFields,
                }
            })
        );

        this.closeModal();
    }

    closeModal() {
        this.dispatchEvent(
            new CustomEvent('close')
        );
    }
}