import { LightningElement, api, track, wire } from 'lwc';

export default class CustomEditListMember extends LightningElement {
    @api objApiName;
    @api prePopulatedFields;
    @api saveEdit;
    @api modalHeader;
    @api rowId;

    formFields = [];

    connectedCallback() {
        console.log(JSON.parse(JSON.stringify(this.prePopulatedFields)))
    }

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