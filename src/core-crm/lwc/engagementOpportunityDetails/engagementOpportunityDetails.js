/**
 * @description The parent Lightning Web Component to show a customized sectional record details page of Engagement Opportunity object
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                  |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------|
 *    | ryan.j.a.dela.cruz             | February 2, 2024      | DEPP-6950              | Created file                    |
 *    |                                |                       |                        |                                 |
 */

import { LightningElement, api } from "lwc";
import { RefreshEvent } from "lightning/refresh";
import findListRecordIdByEngagementOpportunityId from "@salesforce/apex/ListsCtrl.findListRecordIdByEngagementOpportunityId";

export default class EngagementOpportunityDetails extends LightningElement {
  // Flexipage provides recordId and objectApiName
  @api recordId;
  @api objectApiName; // Engagement_Opportunity__c
  listObjectApiName = "List__c";
  listRecordId;
  showFooter;
  showEditField = true;
  isLoading;
  error;

  label = {
    opportunitySummary: "Opportunity Summary",
    listColumnHeaders: "List Column Headers",
    stageManagement: "Stage Management",
    systemInformation: "System Information"
  };

  fieldListToOverride = {
    engagementOpportunityId: "Engagement_Opportunity__c",
    listName: "List_Name__c",
    listPurpose: "List_Purpose__c",
    recordTypeId: "RecordTypeId",
    stage: "Stage__c"
  };

  // Set active sessions here on page load
  activeSections = [
    "opportunitySummary",
    "listColumnHeaders",
    "stageManagement",
    "systemInformation"
  ];

  // It's possible to move these fields in a field set, however a new class is required to be built for field set retrieval
  opportunitySummary = {
    column1FieldList: [
      { name: "Name", editable: false },
      {
        name: "Engagement_Opportunity_Type__c",
        editable: true
      },
      {
        name: "Score_Category__c",
        editable: true
      },
      {
        name: "Start_Date__c",
        editable: true
      },
      {
        name: "Requestor_Name__c",
        editable: true
      },
      { name: "Summary__c", editable: true }
    ],
    column2FieldList: [
      {
        name: "Engagement_Opportunity_Name__c",
        editable: true
      },
      {
        name: "Coordinating_Team__c",
        editable: true
      },
      {
        name: "Score_Subcategory__c",
        editable: true
      },
      {
        name: "Close_Date__c",
        editable: true
      },
      {
        name: "Requesting_Faculty__c",
        editable: true
      },
      {
        name: "Stage__c",
        editable: true
      }
    ]
  };

  listColumnHeaders = {
    column1FieldList: [
      { name: "Column_1__c", editable: true },
      { name: "Column_3__c", editable: true },
      { name: "Column_5__c", editable: true },
      { name: "Column_7__c", editable: true },
      { name: "Column_9__c", editable: true }
    ],
    column2FieldList: [
      { name: "Column_2__c", editable: true },
      { name: "Column_4__c", editable: true },
      { name: "Column_6__c", editable: true },
      { name: "Column_8__c", editable: true },
      { name: "Column_10__c", editable: true }
    ],
    hiddenFieldList: [
      {
        name: "Engagement_Opportunity__c",
        value: ""
      },
      {
        name: "RecordTypeId",
        value: ""
      },
      {
        name: "List_Name__c",
        value: ""
      },
      {
        name: "List_Purpose__c",
        value: ""
      },
      {
        name: "Stage__c",
        value: "In Progress"
      }
    ]
  };

  updateShowFooter(event) {
    this.showFooter = event.detail.message;
    this.showEditField = !this.showFooter;
    this.isLoading = false;
  }

  handleListRecordIdUpdate(event) {
    this.listRecordId = event.detail.message;
    console.log("[4] List Record Id", this.listRecordId);
    // const subForm = this.template.querySelector(
    //   "c-dynamic-record-edit-form[data-id='engagementOpportunitySubForm']"
    // );
    // subForm.submit();
  }

  connectedCallback() {
    this.isLoading = true;
    if (this.recordId) {
      findListRecordIdByEngagementOpportunityId({
        engagementOpportunityIdString: this.recordId
      })
        .then((result) => {
          if (result) {
            this.listRecordId = result;
            console.log("List Record Found: ", this.listRecordId);

            this.isLoading = false;
          }
        })
        .catch((error) => {
          const logger = this.template.querySelector("c-logger");
          if (logger) {
            logger.error(
              "Exception caught in method connectedCallback in LWC engagementOpportunityDetails: ",
              JSON.stringify(error)
            );
            logger.saveLog();
          }
          this.isLoading = false;
        });
    }
  }

  stageManagement = {
    column1FieldList: [{ name: "Stage__c", editable: true }]
  };

  handleSubmit(event) {
    event.preventDefault();
    this.isLoading = true;
    let hasError = false;

    const mainForm = this.template.querySelector(
      "c-dynamic-record-edit-form[data-id='engagementOpportunityMainForm']"
    );
    const subForm = this.template.querySelector(
      "c-dynamic-record-edit-form[data-id='engagementOpportunitySubForm']"
    );
    const listForm = this.template.querySelector(
      "c-dynamic-record-edit-form[data-id='listForm']"
    );

    let errorSession = sessionStorage.getItem("dynamicErrors");

    // Submit the first form
    mainForm.submit();

    // Check for error before submitting the sub form
    if (!errorSession && subForm) {
      if (this.error) {
        hasError = true;
      } else {
        // subForm.submit();
      }
    }

    // Check for error before submitting the list form
    if (!errorSession && listForm) {
      if (this.error) {
        hasError = true;
      } else {
        // listForm.submit();
      }
    }
  }

  handleCancel(event) {
    this.showFooter = false;
    this.showEditField = true; // This is the pencil icon on read only view
    this.error = "";
    this.isLoading = false;
    sessionStorage.setItem("dynamicErrors", "");
  }

  handleSuccess(event) {
    const message = JSON.parse(JSON.stringify(event.detail));
    console.log("[3] Parent Received Success: ", message);
    this.isLoading = false;

    // const _event = JSON.parse(JSON.stringify(event));
    // console.log("[3.1] Parent Received _event: ", _event);

    // Since the main form submission is successful, we can trigger the next one.
    if (event.detail.apiName === this.objectApiName) {
      const listForm = this.template.querySelector(
        "c-dynamic-record-edit-form[data-id='listForm']"
      );
      listForm.submit();
    }

    // const subForm = this.template.querySelector(
    //   "c-dynamic-record-edit-form[data-id='engagementOpportunitySubForm']"
    // );
    // subForm.submit();
  }

  handleError(event) {
    const error = event.detail.message;
    this.error = error;
    const message = JSON.parse(JSON.stringify(event.detail));
    console.log("[3] Parent Received Error: ", message);
    this.isLoading = false;
  }
}
