import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CasePotentialMatches extends NavigationMixin(LightningElement) {
    @api recordId;

    async handleViewAll(methodName, methodArgs) {
        const compDefinition = {
            componentDef: "c:casePotentialMatchesViewAll",
            attributes: {},
            state: {
                c__caseId: this.recordId
            }
        }

        const compBase64 = btoa(JSON.stringify(compDefinition));

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + compBase64
            }
        })
    }
}
