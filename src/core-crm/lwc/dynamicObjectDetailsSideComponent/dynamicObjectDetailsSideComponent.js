/**
 * @description A LWC component to display details/fields based on the object from the record page
 * * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary    |
      |---------------------------|-----------------------|--------------|-------------------|
      | eccarius.munoz            | August 05, 2024       | DEPP-10085   | Created file      | 
      |                           |                       |              |                   | 
 */
import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getObjectFieldMapping from '@salesforce/apex/ObjectDetailsSideComponentCtrl.getObjectDetailsMapping';
import LWC_Error_General from '@salesforce/label/c.LWC_Error_General';

export default class DynamicObjectDetailsSideComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;

    //target configs
    @api title;
    @api relatedRecordHeader;
    @api relatedRecord;
    @api relatedField;
    @api relatedRecordFields;

    isLoading;
    relatedRecordId;
    headerValue = '';
    fieldDetails = [];
    hasError = false;

    //Reference map for field icons
    iconTypeMap = {
        'text-id': 'utility:identity',
        'email-primary': 'utility:email',
        'mobile': 'utility:phone_portrait',
        'phone': 'utility:call',
        "email-secondary": "standard:email",
        "info" : "utility:info_alt",
        "http" : "utility:http",
        "world" : "utility:world",
        "event" : "utility:event",
        "event-date" : "utility:event",
        "address" : "utility:location"
    };

    @wire(getObjectFieldMapping, { params: '$params' })
    handleMappingResult({ data, error }) {
        this.isLoading = true;
        const logger = this.template.querySelector("c-logger");
        if (data) {
            try {
                const parsedResult = JSON.parse(data);
                const parsedFields = parsedResult.relatedRecordFields[0];
                
                this.headerValue = parsedResult.componentHeader;
                this.relatedRecordId = parsedResult.relatedRecordId;
                this.fieldDetails = this.parseRelatedRecordFields(parsedFields);
            } catch (parseError) {
                this.hasError = true;
                logger.error(
                    "Error in parsing data.",
                    JSON.stringify(parseError)
                );
            }
        } else if (error) {
            this.hasError = true;
            logger.error(
                "Error in retrieving object and field mapping.",
                JSON.stringify(error)
            );
        }
        this.isLoading = false;
    }    

    parseRelatedRecordFields(parsedFields) {

        const processedRecords = JSON.parse(this.relatedRecordFields).map(record => {

            let additionalProps = {
                value: parsedFields[record.fieldName] ? parsedFields[record.fieldName] : '',
                icon: this.iconTypeMap[record.type],
                isText: true
            };
        
            if (record.type === 'email-primary' || record.type === 'email-secondary') {
                additionalProps = {
                    ...additionalProps,
                    isEmail: true,
                    isText: false
                };
            } else if (record.type === 'number') {
                additionalProps = {
                    ...additionalProps,
                    isNumber: true,
                    isText: false
                };
            } else if(record.type === 'event-date') {
                additionalProps = {
                    ...additionalProps,
                    isDate: true,
                    isText: false
                };
            } else if(record.type === 'address' && parsedFields[record.fieldName] != null) {
                const addressObj = parsedFields[record.fieldName];

                additionalProps = {
                    ...additionalProps,
                    isAddress: true,
                    isText: false,
                    street : addressObj['street'],
                    city : addressObj['city'],
                    province : addressObj['province'],
                    country : addressObj['country'],
                    postalCode : addressObj['postalCode']
                };
            }
        
            return {
                ...record,
                ...additionalProps
            };
        });
        
        return processedRecords;

    }    

    getFieldNames() {
        return JSON.parse(this.relatedRecordFields).map(field => field.fieldName);
    }

    handleClickHeader() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.relatedRecordId,
                objectApiName: this.relatedRecord,
                actionName: 'view'
            },
        });
    }

    get params() {
        const fieldNames = JSON.stringify(this.getFieldNames());
        return {
            parentRecord: this.objectApiName,
            parentRecordId: this.recordId,
            relatedRecord: this.relatedRecord,
            relatedField: this.relatedField,
            relatedRecordHeader: this.relatedRecordHeader,
            relatedRecordFields: fieldNames,
            relatedRecordFieldsMap: this.relatedRecordFields
        };
    }

    get componentTitle() {
        return this.title;
    }

    get headerIcon() {
        switch (this.relatedRecord) {
            case 'Contact':
                return 'standard:contact';
            case 'Lead':
                return 'standard:lead';
            default:
                return 'standard:related_list';
        }
    }

    get componentErrorMessage(){
        return LWC_Error_General;
    }
}