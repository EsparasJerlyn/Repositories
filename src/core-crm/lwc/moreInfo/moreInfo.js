import { LightningElement } from 'lwc';
import BasePath from "@salesforce/community/basePath";


export default class MoreInfo extends LightningElement {

    get isCCEPortal() {
        return BasePath.toLowerCase().includes("cce");
      }
    
      get isOPEPortal() {
        return BasePath.toLowerCase().includes("study");
    } 
}