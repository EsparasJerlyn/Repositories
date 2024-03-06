/**
 * @description A LWC component for Contact Image Section
 *
 * @see ../classes/ContactHeaderSectionCtrl.cls
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                |
      |---------------------------|-----------------------|--------------|-------------------------------|
      | arsenio.jr.dayrit         | march 04, 2023        | DEPP-5322    | Created file                  | 
      | johanna.a.gibas           | February 16, 2024     | DEPP-7697    | Added Partner Sourced in html | 
 */

import { LightningElement, api, wire } from "lwc";
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import CONTACT_OBJ from "@salesforce/schema/Contact";
import createContentDistribution from "@salesforce/apex/ContactHeaderSectionCtrl.createContentDistribution";
import contactDefaultLogo from "@salesforce/resourceUrl/salesforceLogo";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const FIELDS = ["Contact.Contact_Image__c"];
export default class ContactImageSection extends LightningElement {
  @api recordId;

  contactImage;
  showUploadPhoto = false;
  showLoadingSpinner = false;
  isModalOpen = false;

  contactFields;
  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  wiredRecord({ error, data }) {
    if (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error loading contact image",
          message: "ERROR",
          variant: "error"
        })
      );
    } else if (data) {
      this.contactImage = data.fields.Contact_Image__c.value;
      if (this.contactImage != null) {
        this.showUploadPhoto = true;
      }
    }
  }

  get objectApiName() {
    return CONTACT_OBJ;
  }

  get acceptedFormats() {
    return [".jpg", ".png"];
  }

  handleUploadFinished(event) {
    const logger = this.template.querySelector("c-logger");
    this.showLoadingSpinner = true;
    const files = event.detail.files;

    let contentVId;

    files.forEach((file) => {
      contentVId = file.contentVersionId;
    });

    createContentDistribution({ contentVersionId: contentVId })
      .then((result) => {
        let contactImage = '<p><img src="' + result + '"></img></p>';
        let fields = {};
        this.showUploadPhoto = true;
        fields = {
          Id: this.recordId,
          Contact_Image__c: contactImage
        };

        const recordInput = { fields };
        updateRecord(recordInput)
          .then(() => {
            this.showLoadingSpinner = false;
            refreshApex(this.contactFields);
          })
          .catch((error) => {
            logger.error(
              "Exception caught in method createContentDistribution in LWC contactImageSection: ",
              JSON.stringify(error)
            );
            logger.saveLog();
          });
      })
      .catch((error) => {
        logger.error(
          "Exception caught in method handleUploadFinished in LWC contactImageSection: ",
          JSON.stringify(error)
        );
        logger.saveLog();
      });
  }

  previewHandler() {
    this.isModalOpen = true;
  }

  closeModalAction() {
    this.isModalOpen = false;
  }

  get defaultLogo() {
    return contactDefaultLogo;
  }
}