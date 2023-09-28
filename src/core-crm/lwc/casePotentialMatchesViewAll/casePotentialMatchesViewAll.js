import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class CasePotentialMatchesViewAll extends LightningElement {
    @track caseId;
    isTriggerViewAll = true;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference && !this.caseId) {
            const { c__caseId } = currentPageReference.state;
            if (c__caseId) {
                this.caseId = c__caseId;
            }
       }
    }
}