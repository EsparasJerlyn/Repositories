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

import CART_ID_FIELD from "@salesforce/schema/WebCart.Id";
import CART_STATUS_FIELD from "@salesforce/schema/WebCart.Status";
import ANSWER_ID_FIELD from "@salesforce/schema/Answer__c.Id";
import ANSWER_RESPONSE_FIELD from "@salesforce/schema/Answer__c.Response__c";

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
  "User.Contact.MobilePhone"
];

export default class CartDetails extends LightningElement {
  @api recordId;
  @track contactId;
  @track contactFname;
  @track contactLname;
  @track contactEmail;
  @track contactMobile;
  @track error;
  @track subTotal;
  @track discountTotal;
  @track total;
  @track cbDetails = false;
  @track cbTerms = false;
  @track disablePayment = true;
  @track showStaffId;
  @track showStudentId;

  cartItems = [];
  questions = [];
  activeTimeout;
  @track prodCategId;

  cartExternalId; // added for payment parameters
  checkData = false;
  fromCartSummary = true; // checks if from cart summary or group registration

  @track readOnly = {
    firstName: true,
    lastName: true,
    email: true,
    mobile: true,
    dietaryReq: true
  };

  //set the cart status to checkout when opening this page
  connectedCallback() {
    
    //create global variable
    window.isCartSumDisconnected = false;
    console.log(window.isCartSumDisconnected);

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

    // window.addEventListener("beforeunload", beforeUnloadHandler, true);
    // var updateCartId = this.recordId;
    // function beforeUnloadHandler(e) {
    //   e.preventDefault();
    //   updateCartStatus({ cartId: updateCartId, cartStatus: "Active" })
    //     .then(() => {})
    //     .catch((error) => {
    //       console.log("cart update error");
    //       console.log(error);
    //     });

      /* if (!window.location.href == BasePath) {
        e.returnValue = "You may have unsaved Data";
      } else {
        e.returnValue = null;
      } */
    // }
  }

  //set the status back to active when disconnecting
  disconnectedCallback() {
    
    //create global variable
    window.isCartSumDisconnected = true;
    console.log(window.isCartSumDisconnected);

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
  cartItemsData({ error, data }) {
    //if data is retrieved successfully
    if (data) {
      //set variable if we are showing the staff and/or student ID
      this.showStaffId = data.showStaffId;
      this.showStudentId = data.showStudentId;

      //set the cart items data and questions
      this.cartItems = data.cartItemsList;
      this.questions = data.questionsList;

      //get totals
      this.total = this.calculateSubTotal() - this.calculateDiscountTotal();
      this.cartExternalId = this.cartItems[0].externalId; // added for payment parameters

      //else if there's an error
    } else if (error) {
      this.error = error;
    }
  }

  //function for removing the cart item
  removeCartItem(event) {
    let cartItemId = event.target.dataset.id;

    //filter out the element with the current cart item id
    this.cartItems = this.cartItems.filter(function (obj) {
      return obj.cartItemId !== cartItemId;
    });

    //get totals
    this.total = this.calculateSubTotal() - this.calculateDiscountTotal();

    //if the pay buttons are disabled
    if (this.disablePayment) {
      //disable payment if no seats are available
      this.disablePayment = !this.checkSeatsAvailable();
    }

    //function to delete the specific cart item
    deleteCartItem({
      communityId: communityId,
      activeCartOrId: this.recordId,
      cartItemId: cartItemId
    })
      .then(() => {
        //
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

  //calculate the total discount
  calculateDiscountTotal() {
    this.discountTotal = 0;

    //loop through the current cart items
    for (let i = 0; i < this.cartItems.length; i++) {
      this.discountTotal = this.discountTotal + this.cartItems[i].unitDiscount;
    }

    return this.discountTotal;
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
    //update contact fields
    this.updateContactFields();

    //update answer fields
    this.updateQuestionFields();
  }

  //retrieve the discount code
  applyCoupon(event) {
    console.log("start:");
    console.log(this.cartItems);

    //temporry cart items
    let tempCartItems = JSON.parse(JSON.stringify(this.cartItems));

    //get the discount code entered by the user and index from the array
    let couponCode = this.template.querySelector(
      "lightning-input[data-id='" + event.target.dataset.id + "']"
    ).value;
    let currentIndex = this.template.querySelector(
      "lightning-input[data-id='" + event.target.dataset.id + "']"
    ).name;

    //if coupon code field is empty, remove the error and recalutate the totals
    if (couponCode == "") {
      //hide invalid coupon message
      tempCartItems[currentIndex].showInvalidDiscount = false;

      //set the discount for the cart item
      tempCartItems[currentIndex].unitDiscount = 0;

      //reset the cart items
      this.cartItems = tempCartItems;

      //get totals
      this.total = this.calculateSubTotal() - this.calculateDiscountTotal();

      return;
    }

    console.log("disc: " + couponCode);
    console.log("index: " + currentIndex);

    //function to get the total discount for the specific cart item
    getCartItemDiscount({
      productId: this.cartItems[currentIndex].productId,
      couponCode: couponCode,
      unitPrice: this.cartItems[currentIndex].unitPrice
    })
      .then((data) => {
        //set the discount for the cart item
        tempCartItems[currentIndex].unitDiscount = data;

        //if voucher is found
        if (data > 0) {
          //hide the invalid voucher message
          tempCartItems[currentIndex].showInvalidDiscount = false;

          //else voucher is not found
        } else {
          //show the invalid voucher message
          tempCartItems[currentIndex].showInvalidDiscount = true;
        }

        //reset the cart items
        this.cartItems = tempCartItems;

        //get totals
        this.total = this.calculateSubTotal() - this.calculateDiscountTotal();

        console.log("done data");
        console.log(this.cartItems);
      })
      .catch((error) => {
        this.error = error;

        console.log("error");
        console.log(error);
      });

    console.log("end:");
    console.log(this.cartItems);

    // applyCartCoupon({communityId: this.communityId, activeCartOrId: this.recordId, couponCode: couponCode})
    // .then((data) => {

    //     console.log("get apply coup data");
    //     console.log(data);
    // })
    // .catch((error) => {
    //     this.error = error;

    //     console.log("error")
    //     console.log(error);
    // });
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
}
