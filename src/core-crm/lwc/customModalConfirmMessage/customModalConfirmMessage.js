/**
 * @description A LWC component to display confirmation message
 *
 * @see ../classes/ProductDetailsCtrl.cls,PaymentConfirmationCtrl.cls
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
	  |---------------------------|-----------------------|----------------------|----------------------------------------------|
	  | keno.domienri.dico        | June 28, 2022         | DEPP-3302            | Create lwc                                   |
      | eugene.andrew.abuan       | July 29, 2022         | DEPP-2730            | Added OK button for Employee self-reg        |

*/
   
import { LightningElement, api, wire } from "lwc";
import getOPEProductCateg from "@salesforce/apex/PaymentConfirmationCtrl.getOPEProductCateg";
import BasePath from "@salesforce/community/basePath";
import userId from "@salesforce/user/Id";
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";
import getUserCartDetails from '@salesforce/apex/ProductDetailsCtrl.getUserCartDetails';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';

export default class CustomModalConfirmMessage extends LightningElement {

	//passed parameters
	@api isModalMessage;
	@api message1;
	@api message2;
	@api isContinueToPayment;
	@api isContinueBrowsing;
	@api isOkay;

	//close button
	xButton;

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

	handleContinueBrowsing(){
		//Direct to the product catalog
		window.location.href = BasePath + "/category/products/" + this.productCategData.data.Id;
	}

	handleContinueToPayment(event){
		//Direct to the cart summary page
		window.location.href = BasePath + "/cart/" + this.cartId;
	}

	closeModalMessage() {
		// to close modal set isModalOpen tarck value as false
		this.isModalMessage = false;
		this.dispatchEvent(new CustomEvent('close'));
	}    
}