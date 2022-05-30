import { LightningElement, api, track } from "lwc";

export default class SortCourse extends LightningElement {
  value = 'comingUp';
  @api sortCourseBy;

    get options() {
        return [
            { label: 'Coming Up', value: 'comingUp' },
            { label: 'Newly Added', value: 'newlyAdded' },
            { label: 'Price low to high', value: 'priceLowToHigh' },
            { label: 'Price high to low', value: 'priceHighToLow' }
        ];
    }

    handleChange(event) {
      this.value = event.detail.value;
      this.sortCourseBy = this.value;
      const selectedEvent = new CustomEvent("sortbycourse", {
        detail: this.sortCourseBy
      });
      this.dispatchEvent(selectedEvent);
      console.log('Sort by: ' + this.sortCourseBy);
    }
}