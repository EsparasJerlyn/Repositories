import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CasePotentialMatches extends NavigationMixin(LightningElement) {
    @api recordId;

    async handleViewAll(methodName, methodArgs) {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: "c__casePotentialMatchesRecord"
            },
            state: {
                c__caseId: this.recordId
            }
        })
    }
}
