/**
 * @description Lightning Web Component for custom combobox multiselect items.
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | john.bo.a.pineda          | April 11, 2022        | DEPP-1211            | Created file                 |
      |                           |                       |                      |                              |
 */
import { api, LightningElement } from "lwc";

export default class CustomComboboxMultiItem extends LightningElement {
  // functional properties
  @api item;

  get itemClass() {
    return `slds-listbox__item ${this.item.selected ? "slds-is-selected" : ""}`;
  }

  handleClick() {
    this.dispatchEvent(
      new CustomEvent("change", {
        detail: { item: this.item, selected: !this.item.selected }
      })
    );
  }
}
