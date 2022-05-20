/**
 * @description A LWC component to display product banner
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                         |
      |---------------------------|-----------------------|----------------------|----------------------------------------|
      | xenia.gaerlan             | November 2, 2021      | DEPP-618             | Created file                           |
      | roy.nino.s.regala         | December 6, 2021      | DEPP-116             | Updated to get product name dynamically| 
 */
import {  LightningElement, wire, api} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Product2.Name';
import BANNER_IMAGE from '@salesforce/resourceUrl/ProductDetailsPageBanner';

export default class ProductBodyDetails extends LightningElement {
    banner = BANNER_IMAGE;
    @api
    recordId;

    /**
     * fetches product data
     */
    @wire(getRecord, { recordId:'$recordId', fields: [NAME_FIELD]})
    product;

    /**
     * gets product name
     */
    get name() {
        return this.product.data?getFieldValue(this.product.data, NAME_FIELD):'';
    }
}