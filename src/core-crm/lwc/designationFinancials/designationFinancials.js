/**
 * @description Lightning Web Component for Designation Financials Tab.
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                                                                             |
      |---------------------------|-----------------------|----------------------|--------------------------------------------------------------------------------------------|
      | neil.s.h.lesidan          | April 11, 2024        | DEPP-8392            | Created file                                                                               |                                                           |
      |                           |                       |                      |                                                                                            |                                                           |
 */
import { LightningElement, api, track } from 'lwc';
import getDistributionManagementList from '@salesforce/apex/DesignationFinancialsCtrl.getDistributionManagementList';
import getDistributionSplitList from '@salesforce/apex/DesignationFinancialsCtrl.getDistributionSplitList';
export default class DesignationFinancials extends LightningElement {
    @api recordId;
    data;
    isDataEmpty = false;

    distributionManagement = [];
    distributionSplit = [];
    isLoading = true;
    columns = [
        {
            label: 'Name',
            fieldName: 'financeGLAccount',
            type: 'text',
            editable: false,
            sortable: false,
        },
        {
            label: 'GL Account Code',
            fieldName: 'GL_Account_Code__c',
            type: 'text',
            editable: false,
            sortable: false,
        },
        {
            label: 'Participating Group',
            fieldName: 'Participating_Group__c',
            type: 'text',
            editable: false,
            sortable: false,
        },
        {
            label: 'Percentage Split',
            fieldName: 'Percentage_Split__c',
            type: 'text',
            editable: false,
            sortable: false,
        },
    ];

    get checkLoading() {
        return this.isLoading;
    }

    connectedCallback() {
        if (this.recordId) {
            this.getDistributionManagementAndSplit();
        }
    }

    async getDistributionManagementAndSplit() {
        this.isLoading = true;
        await this.getDistributionManagement();
        await this.getDistributionSplit();
        this.constructData();
        this.isLoading = false;
    }

    async getDistributionManagement() {
        let distributionManagement = await getDistributionManagementList({designationId: this.recordId});
        this.distributionManagement = distributionManagement;
    }

    async getDistributionSplit() {
        let distributionSplit = await getDistributionSplitList({distributionManagement: this.distributionManagement});
        distributionSplit.forEach((obj) => {
            obj.financeGLAccount = obj.Finance_GL_Account__r.Name;
        })

        this.distributionSplit = distributionSplit;
    }

    constructData() {
        let arr = [];
        const distributionSplit = this.distributionSplit;
        const distributionManagement = this.distributionManagement;
        distributionManagement.forEach((obj) => {
            arr.push({distributionSplit: [], ...obj});

            let arrayLength = arr.length - 1;

            arr[arrayLength].isEditActionDisabled = false;

            if (obj.Status__c === 'Archived') {
                arr[arrayLength].isEditActionDisabled = true;
            }

            distributionSplit.forEach((obj) => {
                if (arr[arrayLength].Id === obj.Distribution_Management__c) {
                    arr[arrayLength].distributionSplit.push(obj);
                }
            })
        })

        this.data = arr;
        this.isDataEmpty = arr.length > 0 ? false : true;
    }
}
