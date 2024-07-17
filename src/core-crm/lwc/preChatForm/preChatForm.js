import { LightningElement, track, api } from 'lwc';
import BasePrechat from 'lightningsnapin/basePrechat';

export default class PreChatForm extends BasePrechat  {
    /**
    * Deployment configuration data.
    * @type {Object}
    */
    @api configuration = {};
    @api prechatFields;
    @api backgroundImgURL;
    @track fields;
    @track namelist;
    startChatLabel;

    startConversationLabel;

    // get prechatForm() {
    //     const forms = this.configuration.forms || [];
    //     console.log('forms: ', forms);
    //     return forms.find(form => form.formType === "PreChat") || {};
    // }

    // get prechatFormFields() {
    //     console.log('this.prechatForm.formFields: ', this.prechatForm.formFields);
    //     return this.prechatForm.formFields || [];
    // }

    form() {
        const forms = this.configuration.forms || [];
        const preChatForm = forms.find(form => form.formType === "PreChat") || {};
        return preChatForm.formFields || [];
    }

    formHiddenFields() {
        const forms = this.configuration.forms || [];
        const preChatForm = forms.find(form => form.formType === "PreChat") || {};
        return JSON.parse(JSON.stringify(preChatForm.hiddenFormFields)) || [];
    }

    connectedCallback() {
        this.startConversationLabel = "Start Conversation";
        this.fields = JSON.parse(JSON.stringify(this.form()));
    }

    /**
    * Adds values to choiceList (dropdown) fields.
    */
    addChoiceListValues(fields) {
        for (let field of fields) {
            if (field.type === "ChoiceList") {
                const valueList = this.configuration.choiceListConfig.choiceList.find(list => list.choiceListId === field.choiceListId) || {};
                field.choiceListValues = valueList.choiceListValues || [];
            }
        }
    }

    /**
    * Iterates over and validates each form field. Returns true if all the fields are valid.
    * @type {boolean}
    */
    isValid() {
        let isFormValid = true;
        this.template.querySelectorAll("c-pre-chat-form-field").forEach(formField => {
            if (!formField.reportValidity()) {
                isFormValid = false;
            }
        });
        return isFormValid;
    }

    /**
    * Gathers and submits pre-chat data to the app on start-conversation-button click.
    * @type {boolean}
    */
    onStartConversationClick() {
        const prechatData = {};
        const hiddenFields = JSON.parse(JSON.stringify(this.formHiddenFields()));
        if (this.isValid()) {
            this.template.querySelectorAll("c-pre-chat-form-field").forEach(formField => {
                prechatData[formField.name] = String(formField.value);
            });

            for (let i=0; i<hiddenFields.length; i++){
                if (hiddenFields[i].name == 'Case_Origin') {
                    prechatData[hiddenFields[i].name] = 'Website';
                }
            }
            this.dispatchEvent(new CustomEvent(
                "prechatsubmit",
                {
                    detail: { value: prechatData }
                }
            ));
        }
    }
}