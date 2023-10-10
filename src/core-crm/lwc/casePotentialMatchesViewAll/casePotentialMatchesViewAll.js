import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { setTabIcon, setTabLabel, closeTab } from 'lightning/platformWorkspaceApi';

export default class CasePotentialMatchesViewAll extends LightningElement {
    @track caseId;
    isTriggerViewAll = true;
    _tabid = '';

    @api
    set tabid(value) {
        if (value) {
            this._tabid = value;
            setTabIcon(this._tabid, "utility:people");
            setTabLabel(this._tabid, "Potential Matches");
        }
    }
    get tabid() {
        return this._tabid;
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference && !this.caseId) {
            const { c__caseId } = currentPageReference.state;
            if (c__caseId) {
                this.caseId = c__caseId;
            }
       }
    }

    handleClosetab() {
        const tabId = this._tabid;
        closeTab(tabId);
    }
}