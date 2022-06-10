import { LightningElement, wire, api, track } from "lwc";
import {getRecord, updateRecord} from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import BasePath from "@salesforce/community/basePath";
import userId from "@salesforce/user/Id";
import communityId from "@salesforce/community/Id";
// import getCartItems from '@salesforce/apex/CartItemCtrl.getCartItems';
// import getCartCoupons from '@salesforce/apex/CartItemCtrl.getCartCoupons';
// import applyCartCoupon from '@salesforce/apex/CartItemCtrl.applyCartCoupon';
import deleteCartItem from "@salesforce/apex/CartItemCtrl.deleteCartItem";
import updateCartStatus from "@salesforce/apex/CartItemCtrl.updateCartStatus";
import getOPEProductCateg from "@salesforce/apex/CartItemCtrl.getOPEProductCateg";

import getCartItemsByCart from "@salesforce/apex/CartItemCtrl.getCartItemsByCart";
import getCartItemDiscount from "@salesforce/apex/CartItemCtrl.getCartItemDiscount";
import updateCartDiscount from "@salesforce/apex/CartItemCtrl.updateCartDiscount";
import {refreshApex} from '@salesforce/apex';

import CART_ID_FIELD from "@salesforce/schema/WebCart.Id";
import CART_STATUS_FIELD from "@salesforce/schema/WebCart.Status";
import ANSWER_ID_FIELD from "@salesforce/schema/Answer__c.Id";
import ANSWER_RESPONSE_FIELD from "@salesforce/schema/Answer__c.Response__c";

import { publish, MessageContext } from 'lightning/messageService';
import payloadContainerLMS from '@salesforce/messageChannel/Breadcrumbs__c';

//USER fields to be updated
// import USER_ID_FIELD from '@salesforce/schema/User.Id';
// import USER_FNAME_FIELD from '@salesforce/schema/User.FirstName';
// import USER_LNAME_FIELD from '@salesforce/schema/User.LastName';
// import USER_EMAIL_FIELD from '@salesforce/schema/User.Email';
// import USER_MOBILE_FIELD from '@salesforce/schema/User.MobilePhone';

//Contact fields
const CONTACT_FIELDS = [
  "User.ContactId",
  "User.Contact.FirstName",
  "User.Contact.LastName",
  "User.Contact.Email",
  "User.Contact.MobilePhone",
  "User.Contact.Dietary_Requirement__c",
  "User.Contact.Company_Name__c",
  "User.Contact.Position__c",
  "User.Contact.Nominated_Employee_ID__c",
  "User.Contact.Nominated_Student_ID__c",
];

export default class CartDetails extends LightningElement {
  @api recordId;
  @track contactId;
  @track contactFname;
  @track contactLname;
  @track contactEmail;
  @track contactMobile;
  @track contactDiet;
  @track contactCompany;
  @track contactPosition;
  @track contactEmpId;
  @track contactStudentId;
  @track error;
  @track subTotal;
  @track discountTotal = 0;
  @track total;
  @track cbDetails = false;
  @track cbTerms = false;
  @track disablePayment = true;
  @track showStaffId;
  @track showStudentId;

  resultData;
  cartItems = [];
  questions = [];
  activeTimeout;
  @track prodCategId;

  editModeFN = false;
  editModeLN = false;
  editModeEmail = false;
  editModeMob = false;
  editModeDietary = false;
  editModeCompany = false;
  editModePosition = false;
  editModeStaff = false;
  editModeStudent = false;   
  cartExternalId; // added for payment parameters
  checkData = false;
  fromCartSummary = true; // checks if from cart summary or group registration
  showInvalidDiscount = false;

  @track readOnly = {
    firstName: true,
    lastName: true,
    email: true,
    mobile: true,
    dietaryReq: true
  };

  @wire(MessageContext)
  messageContext;

  //set the cart status to checkout when opening this page
  connectedCallback() {
    
    //create global variable
    window.isCartSumDisconnected = false;

    // Set Cart to Checkout
    updateCartStatus({ cartId: this.recordId, cartStatus: "Checkout" })
      .then(() => {})
      .catch((error) => {
        console.log("cart update error");
        console.log(error);
      });

    // Get Product Category Id
    getOPEProductCateg()
      .then((result) => {
        this.prodCategId = result.Id;
        // Idle Timer
        this.idleRedirect();
      })
      .catch((error) => {
        console.log("getOPEProductCateg error");
        console.log(error);
      });

    //refresh the cart items
    refreshApex(this.resultData);
    this.publishLMS();
  }

  //set the status back to active when disconnecting
  disconnectedCallback() {
    
    //create global variable
    window.isCartSumDisconnected = true;

    //remove 
    window.onload = null;
    window.onmousemove = null;
    window.onmousedown = null;
    window.ontouchstart = null;
    window.ontouchmove = null;
    window.onclick = null;
    window.onkeydown = null;

    //clear the timeout for changing the screen
    clearTimeout(this.activeTimeout)

    //set the status back to active
    updateCartStatus({ cartId: this.recordId, cartStatus: "Active" })
    .then(() => {})
    .catch((error) => {
      console.log("cart update error");
      console.log(error);
    });
  }

  idleRedirect() {
    // Init Variables
    var categId = this.prodCategId;
    var updateCartId = this.recordId;

    // Listeners
    window.onload = resetTimer;
    window.onmousemove = resetTimer;
    window.onmousedown = resetTimer;
    window.ontouchstart = resetTimer;
    window.ontouchmove = resetTimer;
    window.onclick = resetTimer;
    window.onkeydown = resetTimer;
    // window.addEventListener("scroll", resetTimer, true);

    // Update Cart to Active & Redirect to Home
    function redirectToHome() {

      //run the redirect only if not yet disconnected
      if(!window.isCartSumDisconnected){
        //function to update the cart status
        updateCartStatus({cartId: updateCartId, cartStatus: "Active"})
        .then(() => {

          window.location.href = BasePath + "/category/products/" + categId;
        })
        .catch((error) => {
            console.log("cart update error");
            console.log(error)
        });
      }
    }

    // Reset Timer
    function resetTimer() {
      clearTimeout(this.activeTimeout);
      // this.activeTimeout = setTimeout(redirectToHome, 5000); //0.125 minute
      this.activeTimeout = setTimeout(redirectToHome, 600000); //10 minutes
    }
  }

  // // get cart items data
  // @wire(getCartItems, {communityId: communityId, activeCartOrId: "$recordId"})
  // testCart({ error, data }) {

  //     //if data is retrieved successfully
  //     if (data) {

  //         console.log("get cart data");
  //         console.log(data);

  //     //else if error
  //     } else if(error){
  //         this.error = error;

  //         console.log("err");
  //         console.log(error);
  //     }
  // }

  // // get cart items data
  // @wire(getCartCoupons, {communityId: communityId, activeCartOrId: "$recordId"})
  // testCoup({ error, data }) {

  //     //if data is retrieved successfully
  //     if (data) {

  //         console.log("get coup data");
  //         console.log(data);

  //     //else if error
  //     } else if(error){
  //         this.error = error;

  //         console.log("err");
  //         console.log(error);
  //     }
  // }

  //get contact data
  @wire(getRecord, { recordId: userId, fields: CONTACT_FIELDS })
  wiredContact({ error, data }) {
    //if data is retrieved successfully
    if (data) {
      //populate the variables
      this.contactId = data.fields.ContactId.value;
      this.contactFname = data.fields.Contact.value.fields.FirstName.value;
      this.contactLname = data.fields.Contact.value.fields.LastName.value;
      this.contactEmail = data.fields.Contact.value.fields.Email.value;
      this.contactMobile = data.fields.Contact.value.fields.MobilePhone.value;
      this.contactDiet = data.fields.Contact.value.fields.Dietary_Requirement__c.value;
      this.contactCompany = data.fields.Contact.value.fields.Company_Name__c.value;
      this.contactPosition = data.fields.Contact.value.fields.Position__c.value;
      this.contactEmpId = data.fields.Contact.value.fields.Nominated_Employee_ID__c.value;
      this.contactStudentId = data.fields.Contact.value.fields.Nominated_Student_ID__c.value;

      this.checkData = true;
      this.fromCartSummary = true;

      //else if error
    } else if (error) {
      this.error = error;
      this.checkData = false;
    }
  }

  //get questions
  @wire(getCartItemsByCart, { cartId: "$recordId", userId: userId })
  cartItemsData(result) {
    //if data is retrieved successfully
    if (result.data) {

      //variable to use in refresh apex
      this.resultData = result;

      //set variable if we are showing the staff and/or student ID
      this.showStaffId = result.data.showStaffId;
      this.showStudentId = result.data.showStudentId;

      //set the cart items data and questions
      this.cartItems = result.data.cartItemsList;
      this.questions = result.data.questionsList;

      //get totals
      this.total = this.calculateSubTotal() - this.discountTotal;
      this.cartExternalId = this.cartItems[0].externalId; // added for payment parameters

      //if the pay buttons are disabled
      if (this.disablePayment) {
        //disable payment if no seats are available
        this.disablePayment = !this.checkSeatsAvailable();
      }

      //redirect to products if no more cart items
      if(this.cartItems.length == 0){
        window.location.href = BasePath + "/category/products/" + this.prodCategId;

      }

      //else if there's an error
    } else if (result.error) {
      this.error = error;
    }
  }

  //function for removing the cart item
  removeCartItem(event) {
    let cartItemId = event.target.dataset.id;

    //function to delete the specific cart item
    deleteCartItem({
      communityId: communityId,
      activeCartOrId: this.recordId,
      cartItemId: cartItemId
    })
    .then(() => {

      //custom event to update the cart item counter
      this.dispatchEvent(new CustomEvent("cartchanged", {
        bubbles: true,
        composed: true
      }));

      //refresh the cart items
      refreshApex(this.resultData);

    })
    .catch((error) => {
      console.log("delete error");
      console.log(error);
    });
  }

  //calculate the subtotal of cart items
  calculateSubTotal() {
    this.subTotal = 0;

    //loop through the current cart items
    for (let i = 0; i < this.cartItems.length; i++) {
      this.subTotal = this.subTotal + this.cartItems[i].unitPrice;
    }

    return this.subTotal;
  }

  //checkes the availability of seats and if checkboxes are ticked
  checkEnablePaymentCB(event) {
    //only proceed with checking the checkboxes if all cart items has seat avaialble
    if (this.checkSeatsAvailable()) {
      let name = event.target.name;

      //set the global variables for the checkboxes
      if (name == "cbDetails") {
        this.cbDetails = event.target.checked;
      } else if (name == "cbTerms") {
        this.cbTerms = event.target.checked;
      }

      //if both checkboxes are ticked
      if (this.cbDetails && this.cbTerms) {
        //enable the payment buttons
        this.disablePayment = false;

        //else at least 1 is not ticked
      } else {
        //disable the payment buttons
        this.disablePayment = true;
      }
    }
  }

  //function for checking if all cart items has available seats
  checkSeatsAvailable() {
    //loop through the current cart items
    for (let i = 0; i < this.cartItems.length; i++) {
      //check if the product has available seats
      if (!this.cartItems[i].seatsAvailable) {
        return false;
      }
    }

    //return true if all cart items has seats available
    return true;
  }

  //function for updating the contact fields
  updateContactFields() {
    this.template
      .querySelectorAll("lightning-record-edit-form")
      .forEach((form) => {
        form.submit();
      });
  }

  //function for updating the question fields
  updateQuestionFields() {
    //variable to compare if record needs to be updated
    let newValue;
    let oldValue;

    //loop through the current cart items
    for (let i = 0; i < this.questions.length; i++) {
      //check for the field type and get the input type for different data type
      if (this.questions[i].isText) {
        //the old value of the answer field
        oldValue = this.questions[i].stringResponse;

        //the current value of the answer field
        newValue = this.template.querySelector(
          "lightning-input[data-id='" + this.questions[i].answerId + "']"
        ).value;
      } else if (this.questions[i].isCheckbox) {
        //the old value of the answer field
        oldValue = this.questions[i].booleanResponse;

        //the current value of the answer field
        newValue = this.template.querySelector(
          "lightning-input[data-id='" + this.questions[i].answerId + "']"
        ).checked;
      } else if (this.questions[i].isPicklist) {
        //the old value of the answer field
        oldValue = this.questions[i].stringResponse;

        //the current value of the answer field
        newValue = this.template.querySelector(
          "lightning-combobox[data-id='" + this.questions[i].answerId + "']"
        ).value;
      } else if (this.questions[i].isMultiPicklist) {
        //the old value of the answer field
        oldValue = this.questions[i].stringResponse;

        //the current value of the answer field
        newValue = this.template
          .querySelector(
            "lightning-dual-listbox[data-id='" +
              this.questions[i].answerId +
              "']"
          )
          .value.toString()
          .replace(/,/g, ";");
      } else if (this.questions[i].isFileUpload) {
        //the old value of the answer field
        oldValue = this.questions[i].stringResponse;

        //the new value of the answer field
        newValue = this.questions[i].newStringResponse;
      }

      //if there are changes, update each record
      if (oldValue != newValue) {
        let fields = {};
        let recordInput = {};

        fields[ANSWER_ID_FIELD.fieldApiName] = this.questions[i].answerId;
        fields[ANSWER_RESPONSE_FIELD.fieldApiName] = newValue.toString();
        recordInput = { fields };

        //update record
        updateRecord(recordInput)
          .then(() => {
            //update success code here
            console.log("update done");
          })
          .catch((error) => {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error answer updating record",
                message: error.body.message,
                variant: "error"
              })
            );
          });
      }
    }
  }

  fileUploadFinished(event) {
    //get the list of uploaded files
    const uploadedFiles = event.detail.files;

    //current index in the questions array
    let currentIndex = event.target.name;

    //tempory questions holder
    let tempQuestions = JSON.parse(JSON.stringify(this.questions));

    //update the value with the new document ID
    tempQuestions[currentIndex].newStringResponse = uploadedFiles[0].documentId;

    //reset the value
    this.questions = tempQuestions;

    console.log(this.questions);
  }

  //pay button is clicked
  paymentNow() {

    //update answer fields
    this.updateQuestionFields();

    //update the cart with the discount applied
    updateCartDiscount({ cartId: this.recordId, discountAmount: this.discountTotal })
      .then(() => { })

        //code

      .catch((error) => {

        console.log("updateCartDiscount error");
        console.log(error);

      });
  }

  //retrieve the discount code
  applyCoupon(event) {

    //get the discount code entered by the user and index from the array
    let couponCode = this.template.querySelector("lightning-input[data-id='discountField']").value;

    //if coupon code field is empty, remove the error and recalutate the totals
    if (couponCode == "") {
      this.discountTotal = 0;

      //hide invalid coupon message
      this.showInvalidDiscount = false;

      //get totals
      this.total = this.calculateSubTotal();

      return;
    }

    //function to get the total discount for the specific cart item
    getCartItemDiscount({
      cartId: this.recordId,
      couponCode: couponCode,
      totalPrice: this.total
    })
      .then((data) => {

        this.discountTotal = data;

        //if voucher is found
        if (data > 0) {
          //hide invalid coupon message
          this.showInvalidDiscount = false;

          //else voucher is not found
        } else {
          //show invalid coupon message
          this.showInvalidDiscount = true;
        }

        //get totals
        this.total = this.calculateSubTotal() - data;

      })
      .catch((error) => {
        this.error = error;

        console.log("error");
        console.log(error);
      });
  }

  //test button
  testFunction(event) {
    // console.log(this.cartItems);
    // console.log("here");
    // // console.log(this.template.querySelector("lightning-file-upload[data-id='a1C9h000000DUacEAG']").value);
    // console.log(this.questions);
    // //the old value of the answer field
    // console.log(this.questions[4].stringResponse);
    // //the current value of the answer field
    // console.log(this.template.querySelector("lightning-file-upload[data-id='a1C9h000000DUacEAG']").files.documentId.toString());
    // //get the discount code entered by the user and index from the array
    // let couponCode = this.template.querySelector("lightning-input[data-id='" + event.target.dataset.id + "']").value;
    // let currentIndex = this.template.querySelector("lightning-input[data-id='" + event.target.dataset.id + "']").name;
  }

  //enables edit mode
  handleEditFirstName(){
    this.editModeFN = true;
  }
  handleEditLastName(){
    this.editModeLN = true;
  }
  handleEditEmail(){
    this.editModeEmail = true;
  }
  handleEditMobile(){
    this.editModeMob = true;
  }
  handleEditDietary(){
    this.editModeDietary = true;
  }
  handleEditCompany(){
    this.editModeCompany = true;
  }
  handleEditPosition(){
    this.editModePosition = true;
  }
  handleEditStaff(){
    this.editModeStaff= true;
  }
  handleEditStudent(){
    this.editModeStudent= true;
  }

  //function called everytime the contact fields are updated
  enableReadMode(event){

    //get the specific field name
    let fieldName = event.target.fieldName;

    //check for the specific field namne
    if(fieldName == 'FirstName'){
      this.editModeFN = false;

    } else if(fieldName == 'LastName'){
      this.editModeLN = false;

    } else if(fieldName == 'Email'){
      this.editModeEmail = false;

    } else if(fieldName == 'MobilePhone'){
      this.editModeMob = false;

    } else if(fieldName == 'Dietary_Requirement__c'){
      this.editModeDietary = false;

    } else if(fieldName == 'Company_Name__c'){
      this.editModeCompany = false;

    } else if(fieldName == 'Position__c'){
      this.editModePosition = false;

    } else if(fieldName == 'Nominated_Employee_ID__c'){
      this.editModeStaff= false;

    } else if(fieldName == 'Nominated_Student_ID__c'){
      this.editModeStudent= false;
    }

    //update the contact fields on mouse out
    this.updateContactFields();
  }

  //function called everytime the contact fields are updated
  contactFieldChanged(event){

    //get the specific field modified and its new value
    let fieldName = event.target.fieldName;
    let newValue = event.target.value;

    //check for the specific field namne
    if(fieldName == 'FirstName'){
      this.contactFname = newValue;

    } else if(fieldName == 'LastName'){
      this.contactLname = newValue;

    } else if(fieldName == 'Email'){
      this.contactEmail = newValue;

    } else if(fieldName == 'MobilePhone'){
      this.contactMobile = newValue;

    } else if(fieldName == 'Dietary_Requirement__c'){
      this.contactDiet = newValue;

    } else if(fieldName == 'Company_Name__c'){
      this.contactCompany = newValue;

    } else if(fieldName == 'Position__c'){
      this.contactPosition = newValue;

    } else if(fieldName == 'Nominated_Employee_ID__c'){
      this.contactEmpId = newValue;

    } else if(fieldName == 'Nominated_Student_ID__c'){
      this.contactStudentId = newValue;
    }
  }

  publishLMS() {
    let paramObj = {
      productId: 1,
      productName: 'Cart Summary',
      clearOtherMenuItems: true
    }
    
    const payLoad = {
      parameterJson: JSON.stringify(paramObj)
    };

    publish(this.messageContext, payloadContainerLMS, payLoad);
  }
}