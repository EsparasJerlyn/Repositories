/**
 * @description Lightning Web Component for custom searchable Combo box.
 *
 * @author Accenture
 *
 * @history
 *  | Developer                 | Date                  | JIRA                 | Change Summary                            |
    |---------------------------|-----------------------|----------------------|-------------------------------------------|
    | nicole.genon@qut.edu.au   | February 6, 2023      | DEPP-7003            | Created file                              |
*/
import { LightningElement, api, track } from 'lwc';

export default class CustomSearchableCombobox extends LightningElement {
    isSelected = false;
    isOpen = false;
    highlightCounter = null;
    _value = "";

    @api messageWhenInvalid = "Please type or select a value";
    @api required = false;
    @api optionIcon;
    @api defaultValue;
    @api searchInProgress;

    @api
    get value() {
        return this._value;
    }

    set value(val) {
        this.toUpdateValue(val);
    }

    @api label = "";

    @track _options = [];

    @api
    get options() {
        return this._options;
    }

    set options(val) {
        this._options = val || [];
    }

    get tempOptions() {
        let options = this.options;
        let newOptions = options;

        if (this.value) {
            newOptions = [];
            options.forEach((obj) => {
                let isFound = false;

                if (obj.multipleLabel) {
                    const multipleLabel = obj.multipleLabel;
                    multipleLabel.forEach((o) => {
                        if (o.toLowerCase().includes(this.value.toLowerCase())) {
                            isFound = true;
                        }
                    });
                } else {
                    if (obj.label.toLowerCase().includes(this.value.toLowerCase())) {
                        isFound = true;
                    }
                }

                if (isFound) {
                    newOptions.push(obj);
                }
            })
        }

        return this.highLightOption(newOptions);
    }

    get isInvalid() {
        return this.required && !this.value;
    }

    get formElementClasses() {
        let classes = "slds-form-element";
        if (this.isInvalid) {
            classes += " slds-has-error";
        }
        return classes;
    }

    connectedCallback() {
        if (this.defaultValue) {
            this.isSelected = true;
            this.toUpdateValue(this.defaultValue);
        }
    }

    toUpdateValue(val) {
        let newVal = val;
        if (this.isSelected) {
            this.options.forEach(obj => {
            if (obj.value == val) {
                newVal = obj.label;
            }
    });
        }
    this._value = newVal;
    }

    handleChange(event) {
        this._value = event.target.value;
        this.fireChange();
    }

    handleInput(event) {
        this.isOpen = true;
    }

    fireChange() {
        this.dispatchEvent(new CustomEvent("change", {detail: {value: this._value}}));
    }

    fireReturnSelected() {
        this.dispatchEvent(new CustomEvent("selected", {detail: {value: this._value}}));
    }

    get classes() {
        let classes = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
        if (this.isOpen) {
            return classes + " slds-is-open";
        }
        return classes;
    }

    get inputClasses() {
        let inputClasses = "slds-input slds-combobox__input";
        if (this.isOpen) {
            return inputClasses + " slds-has-focus";
        }
        return inputClasses;
    }

    allowBlur() {
        this._cancelBlur = false;
    }

    cancelBlur() {
        this._cancelBlur = true;
    }

    handleDropdownMouseDown(event) {
        const mainButton = 0;
        if (event.button === mainButton) {
            this.cancelBlur();
        }
    }

    handleDropdownMouseUp() {
        this.allowBlur();
    }

    handleDropdownMouseLeave() {
        if (!this._inputHasFocus) {
            this.showList = false;
        }
    }

    handleBlur() {
        this._inputHasFocus = false;
        if (this._cancelBlur) {
            return;
        }
        this.isOpen = false;

        this.highlightCounter = null;
        this.dispatchEvent(new CustomEvent("blur"));
    }

    handleFocus() {
        this._inputHasFocus = true;
        this.isOpen = true;
        this.highlightCounter = null;
        this.dispatchEvent(new CustomEvent("focus"));
    }

    handleSelect(event) {
        this.isSelected = true;
        this.isOpen = false;
        this.allowBlur();
        this._value = event.currentTarget.dataset.value;
        this.fireReturnSelected(event.currentTarget.dataset.value);
    }

    handleClear() {
        this.isSelected = false;
        this.isOpen = false;
        this._value = '';
        this.fireChange();
    }

    handleKeyDown(event) {
        if (event.key == "Escape") {
            this.isOpen = !this.isOpen;
            this.highlightCounter = null;
        } else if (event.key === "Enter" && this.isOpen) {
            if (this.highlightCounter !== null) {
                this.isOpen = false;
                this.allowBlur();
                this._value = this.tempOptions[this.highlightCounter].value;
                this.fireChange();
            }
        } else if (event.key === "Enter") {
            this.handleFocus();
        }

        if (event.key === "ArrowDown" || event.key === "PageDown") {
            this._inputHasFocus = true;
            this.isOpen = true;
            this.highlightCounter = this.highlightCounter === null ? 0 : this.highlightCounter + 1;
        } else if (event.key === "ArrowUp" || event.key === "PageUp") {
            this._inputHasFocus = true;
            this.isOpen = true;
            this.highlightCounter = this.highlightCounter === null || this.highlightCounter === 0 ? this.tempOptions.length - 1 : this.highlightCounter - 1;
        }

        if (event.key === "ArrowDown" || event.key === "ArrowUp") {
            this.highlightCounter = Math.abs(this.highlightCounter) % this.tempOptions.length;
        }

        if (event.key === "Home") {
            this.highlightCounter = 0;
        } else if (event.key === "End") {
            this.highlightCounter = this.tempOptions.length - 1;
        }
    }

    highLightOption(options) {
        let classes = "slds-media slds-listbox__option slds-listbox__option_plain slds-media_small";

        return options.map((option, index) => {
            let cs = classes;
            let focused = "";
            if (index === this.highlightCounter) {
                cs = classes + " slds-has-focus";
                focused = "yes";
            }
    return {classes: cs, focused, ...option};
        });
    }

    renderedCallback() {
        this.template.querySelector("[data-focused='yes']")?.scrollIntoView();
    }
}