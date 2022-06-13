/**
 * @description A LWC component to display product child details
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | keno.domienri.dico        | May 24, 2022          | DEPP-2038            | Create payment method lwc                    |
      | marlon.vasquez            | June 10, 2022         | DEPP-2812            | Cart Summary Questionnaire                   |

      */
import { LightningElement, api, wire } from 'lwc';
import getPaymentGatewaySettings from '@salesforce/apex/PaymentGatewayCtrl.getPaymentGatewaySettings';
import updatePaymentMethod from "@salesforce/apex/CartItemCtrl.updatePaymentMethod";
import addRegistration from '@salesforce/apex/ProductDetailsCtrl.addRegistration';

export default class Payment extends LightningElement {

    /**
     * URL variables
     */
    getURL = window.location.origin;
    baseURL;
    formURL;
    error;

    /**
     * Static Parameters
     */
    glCode; 
    transtypeInvoice;
    transtypePayNow;

    /**
     *  Passed Parameters
     */ 
    @api cartId;
    @api cartExternalId; 
    @api disablePayment;
    @api contactFname; 
    @api contactLname; 
    @api contactEmail;
    @api total; 
    @api cartItems; 
    responseDataList;
    fileUploadData = [];
    answerRecordsList = [];
    paymentCartItems = [];
    selectedCourseOffering;
    fullName; 

    /**
     * Labels
     */ 
    header;
    subheader;
    payTitle;
    payLabel;
    invoiceTitle;
    invoiceLabel;
    
    /**
     * Load Page labels
     */
    connectedCallback(){
        /**
         * Get texts
         */ 
        this.header = 'Payment method';
        this.subheader = 'How would you like to pay?';
        this.payTitle = 'Pay now';
        this.payLabel = 'Submit your payment now';
        this.invoiceTitle = 'Invoice';
        this.invoiceLabel = 'Generate an invoice that you can send to your nominated payee';
        this.fullName = this.contactFname + '+' + this.contactLname;
    }

    @wire(getPaymentGatewaySettings)
    handleGetPaymentSettings(result){   
        if(result.data){
            this.baseURL = result.data.Payment_URL__c;
            this.glCode =  result.data.GL_Code__c;
            this.transtypeInvoice =  result.data.TransType_Invoice__c;
            this.transtypePayNow =  result.data.TransType_PayNow__c;
        } else {
            this.error = result.error;
        }
    }

    /**
     * Disable payment buttons if checkbox from Cart Summary is false
     */
    get disableButton(){
        console.log('disablebutton: ' + this.disablePayment);
        return this.disablePayment;
    }

    /**
     * Get Pay Now button link
     */
    get payURL(){
        this.formURL = `tran-type=` + this.transtypePayNow + `&` +
        /** 
         * Passed Parameters 
         **/
            `OPETRANSACTIONID=` + this.cartExternalId + `&` + 
            `EMAIL=` + this.contactEmail.replace('@','%40') + `&` + 
            `FULLNAME=` + this.fullName + `&` + 
            `GLCODE=` + this.glCode + `&` + 
            `UNITAMOUNTINCTAX=` + this.total;

        this.dispatchEvent(new CustomEvent('paynow'));
        return this.baseURL + this.formURL;       
    }

    /**
     * Get Invoice button link
     */
    get invoiceURL(){
        this.formURL = `tran-type=` + this.transtypeInvoice + `&` +  
        /** 
         * Passed Parameters 
         **/
            `OPETRANSACTIONID=` + this.cartExternalId + `&` + 
            `FULLNAME=` + this.fullName + `&` + 
            `GLCODE=` + this.glCode + `&` + 
            `UNITAMOUNTINCTAX=` + this.total;
        return this.baseURL + this.formURL;        
    }

    payNowClick(){
        this.paymentCartItems = JSON.parse(JSON.stringify(this.cartItems));
      
        try {
            this.paymentCartItems.forEach(e=>{

              let fields = {};
              fields.Id =  e.contactId;
              this.contactFields = fields;
              this.selectedCourseOffering = e.CourseOfferingId;
        
                  let answerRecords = [];
                  let responseData = [];
                  let fileUpload = [];
                if (e.relatedAnswers && Array.isArray(e.relatedAnswers) ){
                    e.relatedAnswers.forEach(j=>{        
                             let record = new Object();
                             record.Related_Answer__c = j.Id;
                             record.Response__c = j.Answer;
                             record.Sequence__c = j.Sequence;
                             answerRecords.push(record); 
                    });

                    e.relatedAnswers.forEach(x=>{        
                        let response = new Object();
                        response.Id = x.Id;
                        response.QuestionId =x.QuestionId;
                        response.Label = x.Label;
                        response.MandatoryResponse = x.MandatoryResponse;
                        response.Message = x.Message;
                        response.Type = x.Type;
                        response.IsText = x.IsText;
                        response.IsCheckbox = x.IsCheckbox;
                        response.IsNumber = x.IsNumber;
                        response.IsPicklist = x.IsPicklist;
                        response.IsMultiPicklist = x.IsMultiPicklist;
                        response.IsFileUpload = x.IsFileUpload;
                        response.Answer = x.Answer;
                        response.QuestionnaireId = x.QuestionnaireId;
                        response.Questionnaire__c = x.QuestionnaireId;
                        response.IsCriteria = x.IsCriteria;
                        response.IsQuestion = x.IsQuestion;
                        response.Sequence = x.Sequence;
                        response.ErrorMessage = x.ErrorMessage;
                        response.FileData = x.FileData;
                        responseData.push(response); 
                   });

                   e.relatedAnswers.forEach(k=>{ 
                    if(k.IsFileUpload)
                    {
                        let response2 = new Object();
                        response2.RelatedAnswerId = k.Id;
                        response2.Base64 = k.FileData.base64;
                        response2.FileName = k.FileData.filename;
                        fileUpload.push(response2); 
                    }
                   });


                }
                this.answerRecordsList =  answerRecords;
                this.responseDataList =  responseData;
                this.fileUploadData =  fileUpload;
                this.saveRegistration(this.contactFields, this.selectedCourseOffering,this.responseDataList, this.answerRecordsList,'');
          })
        } catch (error) {
            console.error(error);  
        }

        //update the cart with the payment method selected
        updatePaymentMethod({ cartId: this.cartId, paymentMethod: 'Pay Now' })
        .then(() => { })

            //code

        .catch((error) => {
            console.log("updatePaymentMethod error");
            console.log(error);
        });
    }

    invoiceClick(){
        //update the cart with the payment method selected
        this.paymentCartItems = JSON.parse(JSON.stringify(this.cartItems));
      
        try {
            this.paymentCartItems.forEach(e=>{

              let fields = {};
              fields.Id =  e.contactId;
              this.contactFields = fields;
              this.selectedCourseOffering = e.CourseOfferingId;
        
                  let answerRecords = [];
                  let responseData = [];
                  let fileUpload = [];
                if (e.relatedAnswers && Array.isArray(e.relatedAnswers) ){
                    e.relatedAnswers.forEach(j=>{        
                             let record = new Object();
                             record.Related_Answer__c = j.Id;
                             record.Response__c = j.Answer;
                             record.Sequence__c = j.Sequence;
                             answerRecords.push(record); 
                    });

                    e.relatedAnswers.forEach(x=>{        
                        let response = new Object();
                        response.Id = x.Id;
                        response.QuestionId =x.QuestionId;
                        response.Label = x.Label;
                        response.MandatoryResponse = x.MandatoryResponse;
                        response.Message = x.Message;
                        response.Type = x.Type;
                        response.IsText = x.IsText;
                        response.IsCheckbox = x.IsCheckbox;
                        response.IsNumber = x.IsNumber;
                        response.IsPicklist = x.IsPicklist;
                        response.IsMultiPicklist = x.IsMultiPicklist;
                        response.IsFileUpload = x.IsFileUpload;
                        response.Answer = x.Answer;
                        response.QuestionnaireId = x.QuestionnaireId;
                        response.Questionnaire__c = x.QuestionnaireId;
                        response.IsCriteria = x.IsCriteria;
                        response.IsQuestion = x.IsQuestion;
                        response.Sequence = x.Sequence;
                        response.ErrorMessage = x.ErrorMessage;
                        response.FileData = x.FileData;
                        responseData.push(response); 
                   });

                   e.relatedAnswers.forEach(k=>{ 
                    if(k.IsFileUpload)
                    {
                        let response2 = new Object();
                        response2.RelatedAnswerId = k.Id;
                        response2.Base64 = k.FileData.base64;
                        response2.FileName = k.FileData.filename;
                        fileUpload.push(response2); 
                    }
                   });


                }
                this.answerRecordsList =  answerRecords;
                this.responseDataList =  responseData;
                this.fileUploadData =  fileUpload;
                this.saveRegistration(this.contactFields, this.selectedCourseOffering,this.responseDataList, this.answerRecordsList,'');
          })
        } catch (error) {
            console.error(error);  
        }

        updatePaymentMethod({ cartId: this.cartId, paymentMethod: 'Invoice' })
        .then(() => { })

            //code

        .catch((error) => {
            console.log("updatePaymentMethod error");
            console.log(error);
        });
    }

    saveRegistration(contact,courseOffering,relatedAnswer,answer,fileUpload){
        addRegistration({
            contactRecord:contact,
            courseOfferingId:courseOffering,
            relatedAnswerList:relatedAnswer,
            answerList:answer,
            fileUpload:fileUpload,
            forApplication:false
        })
        .then(() =>{
                this.generateToast(SUCCESS_TITLE, 'Successfully Submitted', SUCCESS_VARIANT);
                //refreshApex(this.tableData);
                
        })
        .finally(()=>{
    
        })
        .catch(error =>{
           
        });
      }
}