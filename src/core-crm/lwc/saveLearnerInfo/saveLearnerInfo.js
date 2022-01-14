/**
 * @description A LWC component to save learner info
 *
 * @see ..
 * @see csvBulkRegistration
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | roy.nino.s.regala         | December 15, 2021     | DEPP-1028            | Created                                     |                                     
 */
import { LightningElement,api } from 'lwc';
import insertLearnerInfo from '@salesforce/apex/ProductDetailsCtrl.insertLearnerInfo';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const MSG_ERROR = LWC_Error_General;

export default class SaveLearnerInfo extends LightningElement {
 
    @api contactRecords = []; // list of contacts/learners to be inserted
    @api courseOffering = {}; //the course offering selected on the product details page
    @api disableProceed = false;
    processingRegistration = false;


    /*
    * handles process when proceed button is clicked
    */
    handleClick(){
        let contactRecordToInsert = this.contactRecords.map(({ id, ...item }) => item);

        let wrappedData = this.setupDataWrapper(
            this.courseOffering.Id
        );
        this.processingRegistration = true;
        this.saveRecords(contactRecordToInsert,wrappedData);
    }

    /*
    * Sets the wrapped data(Ids) that is sent to apex
    */
    setupDataWrapper(courseOfferingId){
        let tempWrappedData = {};
        tempWrappedData.courseOfferingId = courseOfferingId;
        return tempWrappedData;
    }

    /*
    * save the contact records -> learners
    * calls the apex method and create contact records and course connections
    * closes the csv registration modal
    */
    saveRecords(
        contactRecords,
        wrapperData
    ){
        let event = new CustomEvent(
            'processing', 
            {detail: true}
        );

        this.dispatchEvent(event);
        insertLearnerInfo({
            learnerInfoList:contactRecords, 
            wrappedData:wrapperData
        })
        .then(()=>{
            
            this.generateToast(
                'Success!',
                'Registration successful!',
                'success'
            );
            let event = new CustomEvent('closecsvmodal',{
                bubbles: true,
                composed: true
            });
            this.dispatchEvent(event);
        })
        .catch(error=>{
            console.log(error);
            this.generateToast(
                'Error.',
                MSG_ERROR,
                'error'
            );
        })
        .finally(()=>{
            let event = new CustomEvent(
                'processing', 
                {detail: false}
            );
            this.dispatchEvent(event);
        })

    }

    /**
     * creates toast notification
     */
     generateToast(_title,_message,_variant){
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }

    

    
}