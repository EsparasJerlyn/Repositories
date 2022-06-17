import { LightningElement, api, track, wire } from "lwc";
import getOPEProductCateg from "@salesforce/apex/PaymentConfirmationCtrl.getOPEProductCateg";
import getCartData from "@salesforce/apex/PaymentConfirmationCtrl.getCartData";
import BasePath from "@salesforce/community/basePath";
import userId from "@salesforce/user/Id";
import checkCartOwnerShip from "@salesforce/apex/PaymentConfirmationCtrl.checkCartOwnerShip";
import getUserCartDetails from '@salesforce/apex/ProductDetailsCtrl.getUserCartDetails';
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";



export default class AddToCartConfirmDialog extends LightningElement {

    xButton;
    isModalOpen = true;
     //to get the product category Id
     @wire(getOPEProductCateg)
     productCategData;
      
     connectedCallback(){
        this.xButton = qutResourceImg + "/QUTImages/Icon/xMark.svg";
         //Get the external Id from the cart
         getUserCartDetails({
            userId: userId
          })
            .then((results) => {
              
                this.cartId = results.Id;
              
            })
            .catch((e) => {
              this.generateToast("Error.", LWC_Error_General, "error");
            });
           
     }

    handleClick(event){
        //creates object which will be published to the parent component
        let finalEvent = {
            originalMessage: this.originalMessage,
            status: event.target.name
        };

        //dispatch a 'click' event so the parent component can handle it
        this.dispatchEvent(new CustomEvent('click', {detail: finalEvent}));
    }
    handleClickOnBtn1(){
        //Direct to the product catalog
        window.location.href = BasePath + "/category/products/" + this.productCategData.data.Id;
    }
    handleClickOnBtn2(event){
        //Direct to the cart summary page
        window.location.href = BasePath + "/cart/" + this.cartId;
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.dispatchEvent(new CustomEvent('close'));
    }    
}