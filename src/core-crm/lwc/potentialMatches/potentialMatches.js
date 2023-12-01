import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class PotentialMatches extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;

    async handleViewAll(methodName, methodArgs) {
        console.log(this.apiObj)
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: "c__potentialMatchesRecord"
            },
            state: {
                c__objectId: this.recordId,
                c__objectName: this.objectApiName,
            }
        })
    }
}
