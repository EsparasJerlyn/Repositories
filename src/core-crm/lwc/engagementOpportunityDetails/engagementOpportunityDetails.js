import { LightningElement, api } from "lwc";
import LIST_OBJECT from "@salesforce/schema/List__c";

export default class EngagementOpportunityDetails extends LightningElement {
  // Flexipage provides recordId and objectApiName
  @api recordId;
  @api objectApiName; // Engagement_Opportunity__c
  listObjectApiName = LIST_OBJECT;
  listRecordId;
  showFooter;
  showEditField = true;
  isLoading;
  error;

  updateShowFooter(event) {
    this.showFooter = event.detail.message;
    this.showEditField = !this.showFooter;
    this.isLoading = false;
  }

  handleListRecordIdUpdate(event) {
    this.listRecordId = event.detail.message;
  }

  label = {
    opportunitySummary: "Opportunity Summary",
    listColumnHeaders: "List Column Headers",
    stageManagement: "Stage Management",
    systemInformation: "System Information"
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

  stageManagement = {
    column1FieldList: [{ name: "Stage__c", editable: true }]
  };

  handleSubmit(event) {
    event.preventDefault();
    this.isLoading = true;
    let count = 0;
    this.template
      .querySelectorAll("c-dynamic-record-edit-form")
      .forEach((form) => {
        // Check if the form has data-id="engagementOpportunityForm" before submitting
        if (form.dataset.id === "engagementOpportunityForm") {
          form.submit();
          count++;
        }
      });

    if (count >= 2) {
      this.template
        .querySelectorAll("c-dynamic-record-edit-form")
        .forEach((form) => {
          // Check if the form has data-id="listForm" before submitting
          if (form.dataset.id === "listForm") {
            form.submit();
          }
        });
    }
  }

  handleCancel(event) {
    this.showFooter = false;
    this.showEditField = true; // This is the pencil icon on read only view
  }

  handleSuccess(event) {
    const message = event.detail;
    this.result = "Success from Child! Message: " + message;
  }

  handleError(event) {
    const error = event.detail;
    this.result = "Error from Child! " + error;
  }
}
