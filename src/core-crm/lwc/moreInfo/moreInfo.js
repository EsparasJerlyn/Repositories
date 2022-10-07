import { LightningElement } from 'lwc';
import BasePath from "@salesforce/community/basePath";


export default class MoreInfo extends LightningElement {
    connectedCallback(){
        console.log('isCCEPortal =>', this.isCCEPortal);
        console.log('isOPEPortal =>', this.isOPEPortal);
    }

    get isCCEPortal() {
        return BasePath.toLowerCase().includes("cce");
      }
    
      get isOPEPortal() {
        return BasePath.toLowerCase().includes("study");
    } 

    handleOnlick(){
        console.log('isCCEPortal =>', this.isCCEPortal);
        console.log('isOPEPortal =>', this.isOPEPortal);
    }

}