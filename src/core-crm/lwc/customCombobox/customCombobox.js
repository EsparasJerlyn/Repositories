/**
 * @description Lightning Web Component for custom combobox.
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | john.bo.a.pineda          | April 11, 2022        | DEPP-1211            | Created file                 |
      | john.bo.a.pineda          | July 02, 2022         | DEPP-3373            | Changed onclick to mousedown |
      |                           |                       |                      |                              |
 */
import { LightningElement, api, track } from "lwc";

export default class CustomCombobox extends LightningElement {
  // functional properties
  @api fieldLabel;
  @api disabled = false;
  @api useCustomIcon = false;
  @api sldsIconUp = "utility:up";
  @api sldsIconDown = "utility:down";
  @api customIconUp;
  @api customIconDown;
  @api placeholder = "";
  @track openDropDown = false;
  @track label = "";
  @track optionsToDisplay;

  // constructor
  constructor() {
    super();
  }

  @api get value() {
    return this.label;
  }

  set value(value) {
    if (value && value != "") {
      let label = this.getLabel(value);
      if (label && label != "") {
        this.label = label;
      }
    } else {
      this.label = "";
    }
  }

  // Public Method to set options and values
  @api get options() {
    return this.optionsToDisplay;
  }

  set options(value) {
    this.optionsToDisplay = value && value.length > 0 ? value : [];
  }

  // Method to get Label for value provided
  getLabel(value) {
    let selectedObjArray = this.options.filter((obj) => obj.value === value);
    if (selectedObjArray && selectedObjArray.length > 0) {
      return selectedObjArray[0].label;
    }
    return null;
  }

// Method to open listbox dropdown
/*openDropDown(event) {
  this.toggleOpenDropDown(true);
}*/

// Method to close listbox dropdown
  closeDropdown(event) {
    if (this.openDropDown) {
      window.setTimeout(() => {
        this.toggleOpenDropDown(false);
      }, 150);
    }
  }

  // Method to handle readonly input click
  handleInputClick(event) {
    if (this.openDropDown) {
      this.toggleOpenDropDown(false);
    } else {
      this.toggleOpenDropDown(true);
    }
  }

  // Method to handle icon click
  handleInputIconClick(event) {
    if (!this.disabled) {
      let input = this.template.querySelector(".combobox-input-class");

      input.focus();
      this.toggleOpenDropDown(true);
    }
  }

  // Method to handle selected options in listbox
  optionsClickHandler(event) {
    const value = event.target.closest("li").dataset.value;
    const label = event.target.closest("li").dataset.label;
    this.setValues(value, label);
    this.toggleOpenDropDown(false);
    const detail = {};
    detail["value"] = value;
    detail["label"] = label;
    this.dispatchEvent(new CustomEvent("change", { detail: detail }));
  }

  // Method to set label and value based on the parameter provided
  setValues(value, label) {
    this.label = label;
    this.value = value;
  }

  // Method to toggle openDropDown state
  toggleOpenDropDown(toggleState) {
    this.openDropDown = toggleState;
  }

  // getter setter for labelClass
  get labelClass() {
    return this.fieldLabel && this.fieldLabel != ""
      ? "slds-form-element__label slds-show"
      : "slds-form-element__label slds-hide";
  }

  // getter setter for dropDownClass
  get dropDownClass() {
    return this.openDropDown
      ? "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open"
      : "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
  }

  // getter setter for isValueSelected
  get isValueSelected() {
    return this.label && this.label != "" ? true : false;
  }

  get isDropdownOpen() {
    return this.openDropDown ? true : false;
  }
}
