import { LightningElement, api, track } from 'lwc';
import getProduct from '@salesforce/apex/B2BGetInfo.getProduct';
import communityId from '@salesforce/community/Id';
import { generateErrorMessage } from 'c/commonUtils';

const ERROR_TITLE = "Error!";
const ERROR_VARIANT = "error";
const MSG_ERROR = "An error has been encountered. Please contact your Administrator.";

export default class SearchProductDetails extends LightningElement {

    @api
    get accountId() {
        return this._accountId;
    }
    set accountId(value) {
        this._accountId = value;
    }
    @api
    get product() {
        return this._product;
    }
    set product(value) {
        this._product = value;
    }
    @api
    get productId() {
        return this._productId;
    }
    set productId(value) {
        this._productId = value;
    }
    @api
    get categoryName() {
        return this._categoryName;
    }
    set categoryName(value) {
        this._categoryName = value;
    }
    @track productDetail;

    connectedCallback(){
        this.productDetail = {
            ...this.product,
            url: null,
            price: null,
            info: null,
            categoryId: null
        }

        this.getProductInfo();
    }

    @api
    get effectiveAccountId() {
        return this._effectiveAccountId;
    }

    set effectiveAccountId(newId) {
        this._effectiveAccountId = newId;
    }

    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || '';
        let resolved = null;

        if (
            effectiveAccountId.length > 0 &&
            effectiveAccountId !== '000000000000000'
        ) {
            resolved = effectiveAccountId;
        }
        return resolved;
    }

    async getProductInfo() {
        await getProduct({
            communityId: communityId,
            productId: this.productId,
            effectiveAccountId: this.resolvedEffectiveAccountId
        }).then(info => {
            console.log('info', info);
            this.productDetail.info = info;
            const productEvent = new CustomEvent("displayproductdesc", {
                detail: info.fields.Description
            });
            this.dispatchEvent(productEvent);

        }).catch(error => {
            this.productDetail.info = null;
            this.showToast(ERROR_TITLE,MSG_ERROR + generateErrorMessage(error),ERROR_VARIANT);
        });
        
    }

    //shows success or error messages
    showToast(title,message,variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    _accountId;
    _product;
    _productId;
    _categoryName;
    _effectiveAccountId;
}