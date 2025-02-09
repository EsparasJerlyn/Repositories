import { LightningElement } from 'lwc';
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";

export default class StoreHeader extends LightningElement {
    qutexlogoUrl = qutResourceImg + "/QUTImages/Logo/QUT_logo.png";
    qutMenu= qutResourceImg + "/QUTImages/Icon/icon-menu.svg";	

    connectedCallback(){
        this.qutMenu= qutResourceImg + "/QUTImages/Icon/icon-menu.svg";	
    }
    
}