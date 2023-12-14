import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class PotentialMatchesViewAll extends LightningElement {
    @track objectId;
    @track objectName;
    isTriggerViewAll = true;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference && !this.objectId) {
            const { c__objectId, c__objectName } = currentPageReference.state;
            if (c__objectId) {
                this.objectId = c__objectId;
            }

            if (c__objectId) {
                this.objectName = c__objectName;
            }
       }
    }

    handleClosetab() {
        this.dispatchEvent(new CustomEvent('closetab'));
    }
}