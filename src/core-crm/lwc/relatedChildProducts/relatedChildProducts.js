/**
 * @description A custom LWC for the Related Child Products of Release Tab 
 *              of prescribed program product requests
 *
 * @see ../classes/RelatedChildProductsCtrl.cls
 * 
 * @author Accenture
 *      
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                    |
      |---------------------------|-----------------------|--------------|-----------------------------------|
      | angelika.j.s.galang       | May 4, 2022           | DEPP-2342    | Created file                      | 
      |                           |                       |              |                                   |
*/
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LWC_Error_General from "@salesforce/label/c.LWC_Error_General";
import getRelatedChildProducts from '@salesforce/apex/RelatedChildProductsCtrl.getRelatedChildProducts';

const PRODUCT_COLUMNS = [
    {
        fieldName: 'productRequestUrl',
        label: 'Product Name',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'productName'
            }
        }
    },
    {
        fieldName: 'recordTypeName',
        label: 'Product Type'
    },
    {
        fieldName: 'productRequestStatus',
        label: 'Stage',
    }  
]; 
export default class RelatedChildProducts extends LightningElement {
    @api recordId;

    productColumns = PRODUCT_COLUMNS;
    productData = [];

    //queries all related child product requests of program
    connectedCallback(){
        getRelatedChildProducts({productRequestId : this.recordId})
        .then(result => {
            this.productData = result.map(product => {
                return {
                    id: product.Id,
                    productRequestUrl : '/' + product.Course__c,
                    productName : product.Product_Name__c,
                    recordTypeName : product.Course__r.RecordType.Name,
                    productRequestStatus : product.Course__r.Product_Request_Status__c
                }
            });
        })
        .catch(error => {
            const evt = new ShowToastEvent({
                title: 'Error.',
                message: LWC_Error_General,
                variant: 'error'
            });
            this.dispatchEvent(evt);
        })
    }
}