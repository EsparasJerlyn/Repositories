import { LightningElement } from 'lwc';
import qutResourceImg from "@salesforce/resourceUrl/QUTImages";

export default class NotificationMessage extends LightningElement {


    connectedCallback(){
        this.bell = qutResourceImg + "/QUTImages/Icon/notificationBell.svg";
    }

}