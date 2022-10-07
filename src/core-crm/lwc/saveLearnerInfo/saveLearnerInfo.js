/**
 * @description A LWC component to save learner info
 *
 * @see ..
 * @see csvBulkRegistration
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | roy.nino.s.regala         | December 15, 2021     | DEPP-1028            | Created                                      |
      | jessel.bajao              | August 15, 2022       | DEPP-3483            | Map contatcs, corporate Account and added    |                                      |
      | eugene.john.basilan       | September 05, 2022    | DEPP-3479            | Corporate Bundle Bulk Registration Changes   |                                      |
      | john.m.tambasen						| September 12, 2022    | DEPP-3743            | validate duplicate contacts		    			  	|
      | john.m.tambasen           | September 23, 2022    | DEPP-4367            | birthdate validation                         |
      
 */
import { LightningElement, api } from "lwc";
import categoryBulkRegistration from "@salesforce/apex/ProductDetailsCtrl.categoryBulkRegistration";
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import BasePath from "@salesforce/community/basePath";
const MSG_ERROR = LWC_Error_General;
const CURRENTPRODUCTCATEGORY = "current_product_category";
const Corporate_Bundle = 'Corporate Bundle';
import getUserCartDetails from '@salesforce/apex/ProductDetailsCtrl.getUserCartDetails';
import validateContactMatching from "@salesforce/apex/RegistrationMatchingHelper.validateContactMatching";
import userId from "@salesforce/user/Id";
import { birthdateValidation } from 'c/commonUtils';

export default class SaveLearnerInfo extends NavigationMixin(LightningElement) {
  @api contactRecords = []; // list of contacts/learners to be inserted
  @api courseOffering = {}; //the course offering selected on the product details page
  @api productDetails; //the product details data on the product details page
  @api isPrescribed; //the isPrescribed data on the product details page
  @api availableCredit;
  @api disableProceed;
  processingRegistration = false;
  productCategory;
  cartId;



  get isCCEPortal() {
    return BasePath.toLowerCase().includes("cce");
}
  /*
   * handles process when proceed button is clicked
   */
  
  handleClick() {
 
  //map csv contacts
  this.contactRecords = this.contactRecords.map((item, index) => {
    return {
        FirstName: item.FirstName,
        LastName: item.LastName,
        Email: item.Email,
        Registered_Email__c: item.Email,
        ContactMobile_Locale__c: item.MobileLocale,
        MobilePhone: item.MobilePhone,
        Birthdate: item.Birthdate,
        Dietary_Requirement__c: item.DietaryRequirement,
        Accessibility_Requirement__c: item.AccessibilityRequirement
      };
  });

    if(this.isCCEPortal){
         //get current product category
         let currentProductCategory = JSON.parse(
          sessionStorage.getItem(CURRENTPRODUCTCATEGORY)
          );
          this.productCategory = currentProductCategory.category;
         
    }
   
    let wrappedData = this.setupDataWrapper(this.courseOffering.value);
    this.processingRegistration = true;

    this.dispatchEvent(new CustomEvent('processing', {detail: true}));

    //create a set for emails
    const emailsSet = new Set();

    //object to row errors
    let rowsValidation = {};

    //loop on the contacts to check for duplicate email entries
    this.contactRecords.forEach((element, index) => {

      //check if email already added to the set
      if(emailsSet.has(element.Email)){
        //add error to current index
        rowsValidation[index + 1]={
          title: 'We found an error/s.',
          messages: [
            'Duplicate email entered. Please review your csv file or modify the table.'
          ]
        };
      }

      //validate if birthdate is greater than 15 years
      if(!birthdateValidation(element.Birthdate)){

        // //if object error index is already created, just push the message
        if(rowsValidation[index + 1]){

          rowsValidation[index + 1].messages.push('Must be 15 years or older to register');

        //else create the error object
        } else{

          //add error to current index
          rowsValidation[index + 1]={
            title: 'We found an error/s.',
            messages: [
              'Must be 15 years or older to register'
            ]
          };
        }
      }
      
      //add current email to set
      emailsSet.add(element.Email);
    });

    //if no errors
    if(JSON.stringify(rowsValidation) === '{}'){

      //validate contacts before continuing
      validateContactMatching({newContactList: JSON.stringify(this.contactRecords)})
      .then((res) => {

        let validationResult = res;
        let hasErrors = false;
        let rowsValidation = {};

        //loop on the contacts to check for duplicate email entries
        this.contactRecords.forEach((contactElement, index) => {

          let elementTemp = validationResult.find(e => e.email == contactElement.Email);

          //check only if the entered email was found in the database
          if(elementTemp != undefined){

            //if contact record is returned, it means contact exists in the database
            if(elementTemp.contactRecord != undefined){

              //email already exists and names/dob doesnt match
              if(elementTemp.isEmailMatch && elementTemp.isPartialMatch){

                //set has errors to true
                hasErrors = true;

                //add error to current index
                rowsValidation[index + 1]={
                  title: 'We found an error.',
                  messages: [
                    'Your personal details do not match with the email provided. Please check your details or contact QUTeX.'
                  ]
                };

              //email is unique but the names/dob already exists
              } else if(!elementTemp.isEmailMatch && elementTemp.isPartialMatch){

                //set has errors to true
                hasErrors = true;

                //add error to current index
                rowsValidation[index + 1]={
                  title: 'We found an error.',
                  messages: [
                    'The email address doesn’t match the contact details provided. Please contact QUTeX.'
                  ]
                };

              //email and names/dob all matched, reuse the contact
              } else if(elementTemp.isEmailMatch && !elementTemp.isPartialMatch){

                //pass the ID to upsert
                contactElement.Id = elementTemp.contactRecord.Id;
              }
            }
          }
        });

        //if has errors, run the event to pop errors
        if(hasErrors){

          //dispatch event to show errors
          this.dispatchEvent(new CustomEvent('showduplicateerrors', {detail: {
            rows: rowsValidation
          }}));

          this.dispatchEvent(new CustomEvent('processing', {detail: false}));
        } 
        return hasErrors;
      })
      .then((res) =>{
        if(res === false){
          this.saveRecords(this.contactRecords, wrappedData);
        }
      })
      .catch((error) => {
        this.dispatchEvent(new CustomEvent('processing', {detail: false}));
        console.log("error");
        console.log(error);
      });
    
    //else there's an error for duplicate emails
    } else{
      //dispatch event to show errors
      this.dispatchEvent(new CustomEvent('showduplicateerrors', {detail: {
        rows: rowsValidation
      }}));
      
      this.dispatchEvent(new CustomEvent('processing', {detail: false}));
    }
  }
  /*
   * Sets the wrapped data(Ids) that is sent to apex
   */
  setupDataWrapper(courseOfferingId) {
    
    let tempWrappedData = {};
      tempWrappedData.courseOfferingId = courseOfferingId;
      tempWrappedData.isPrescribed = this.isPrescribed;
      tempWrappedData.productName = this.productDetails.Name;
      tempWrappedData.pricebookUnitPrice = this.productCategory == Corporate_Bundle ? this.productDetails?.PricebookEntries[0]?.UnitPrice : '';
      tempWrappedData.pricebookEntryId = this.productCategory == Corporate_Bundle ? this.productDetails?.PricebookEntries[0]?.Id : '';
      tempWrappedData.Pricebook2Id = this.productCategory == Corporate_Bundle ? this.productDetails?.PricebookEntries[0]?.Pricebook2.Id : '';
      tempWrappedData.productId = this.productDetails.Id;
      tempWrappedData.cartId = this.cartId;
      //save product category for category checking purposes
      tempWrappedData.category = this.productCategory;
      //store current user Id to get Corporate account
      tempWrappedData.userId = userId;
    return tempWrappedData;
  }

	connectedCallback(){
		getUserCartDetails({
			userId: userId
		})
			.then((results) => {
      
          this.cartId = results.Id;
			})
			.catch((e) => {
      this.cartId = null;
		});
  }


  /*
   * save the contact records -> learners
   * calls the apex method and create contact records and course connections
   * closes the csv registration modal
   */
  saveRecords(
        contactRecords,
        wrapperData
    ){
        let event = new CustomEvent(
            'processing',
            {detail: true}
        );

        this.dispatchEvent(event);
		if(this.productCategory == Corporate_Bundle){
			  let totalAmount = this.productDetails.PricebookEntries[0].UnitPrice * contactRecords.length;
			  if(this.availableCredit < totalAmount){
			  	this.dispatchEvent(
                      new ShowToastEvent({
                          title: "Reminder",
                          message:
                              "Insufficient credit available to complete this transaction.",
                          variant: "warning"
                      })
                  );
			  	let event = new CustomEvent("processing", { detail: false });
			  	this.dispatchEvent(event);
			  }else{
        
			      categoryBulkRegistration({
			      	learnerInfoList: contactRecords,
			      	wrappedData: wrapperData,
			      }).then((results) => {                
			      		let event = new CustomEvent("closecsvmodal", {
			      			bubbles: true,
			      			composed: true
			      		});
			      		this.dispatchEvent(event);
                this[NavigationMixin.Navigate]({
                  type: 'standard__webPage',
                  attributes: {
                    url: BasePath + '/registration-confirmation?Status=A&Webcart.External_ID__c=' + results.externalId
                    }
                  }
                )
			  	  })
			  	  .catch((error) => {
					      this.generateToast("Error.", MSG_ERROR, "error");
			  	        })
			  	        .finally(() => {
					      let event = new CustomEvent("processing", { detail: false });
					      this.dispatchEvent(event);
			  	        });
			  }
      }
		else{
      categoryBulkRegistration({
          learnerInfoList: contactRecords,
          wrappedData: wrapperData
      })
          .then((results) => {             
              let event = new CustomEvent("closecsvmodal", {
                  bubbles: true,
                  composed: true
              });
              this.dispatchEvent(event);

              this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                  url: BasePath + '/registration-confirmation?Status=A&Webcart.External_ID__c=' + results.externalId
                }
              }
            )

          })
          .catch((error) => {
              this.generateToast("Error.", MSG_ERROR, "warning");
          })
          .finally(() => {
              let event = new CustomEvent("processing", { detail: false });
              this.dispatchEvent(event);
          });

        }

    } 

  /**
   * creates toast notification
   */
  generateToast(_title, _message, _variant) {
    const evt = new ShowToastEvent({
      title: _title,
      message: _message,
      variant: _variant
    });
    this.dispatchEvent(evt);
  }
}