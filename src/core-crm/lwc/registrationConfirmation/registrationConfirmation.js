/**
 * @description A LWC component for Registration Confirmation
 *
 * @see ..
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                               |
      |---------------------------|-----------------------|----------------------|----------------------------------------------|
      | jessel.bajao              | August 24, 2022       | DEPP-3484            | Created                                      |
      | john.m.tambasen           | September 21, 2022    | DEPP-4388            | UI for other payment status                  |
*/
import { LightningElement, wire, track } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import customSR from "@salesforce/resourceUrl/QUTInternalCSS";
import getRegistrationConfirmationData from "@salesforce/apex/ProductDetailsCtrl.getRegistrationConfirmationData";
import { NavigationMixin } from 'lightning/navigation';
import { publish, MessageContext } from 'lightning/messageService';
import payloadContainerLMS from '@salesforce/messageChannel/Breadcrumbs__c';
export default class RegistrationConfirmation extends NavigationMixin(LightningElement) {

    REGISTRATION_CONFIRMATION = "Registration confirmation";
    currentUrl = new URL(window.location);
    externalId  = this.currentUrl.searchParams.get("Webcart.External_ID__c");
    paymentStatus = this.currentUrl.searchParams.get("Status");
    cartId;
    //externalId  = '0a69p0000000fj7AAA';
    // selectedDeliveryType = this.currentUrl.searchParams.get("DeliveryType");
    selectedDeliveryType = 'Online Classroom';

    courseDate;
    courseName;
    deliveryType;
    totalNumberOfLearnersRegistered;
    employeesRegistered;
    data;
    programOffering;
    courseOffering;

    @track subHeader;
    @track subHeaderClass = 'heading2 pb2 subheader-color-err';
    @track paymentApproved = false;

    @wire(MessageContext)
    messageContext;

    /* Load Custom CSS */
    renderedCallback() {
        Promise.all([loadStyle(this, customSR + "/QUTInternalCSS.css")]);
        let style = document.createElement('style');
        style.innerText = '.slds-th__action{  font-size: 18px !important;font-family:ProximaNova-Bold;font-weight: 700; color: #1c1c1c !important; border-right: 0 !important;} ';
        this.template.querySelector('lightning-datatable').appendChild(style);
    }
      
    columns = [
        { label: "Course Name", fieldName: "Course__c", type: "text" },
        { label: "Date", fieldName: "CreatedDate", type: "text" },
        { label: "Delivery", fieldName: "Delivery", type: "text" },
        {
            label: "Number of Employees Registered",
            fieldName: "Course__c",
            type: "number"
        }
    ];
      
    registeredEmployeesColumns = [
        {label: 'Name', fieldName: 'Name', type: 'text', cellAttributes:{
            class:{fieldName: 'rowStyle'}
        }},
        {label: 'Email', fieldName: 'Email', type: 'email', cellAttributes:{
            class:{fieldName: 'rowStyle'}}},
        {label: 'Mobile Locale', fieldName: 'ContactMobile_Locale__c', type: 'text', cellAttributes:{
            class:{fieldName: 'rowStyle'}}},
        {label: 'Mobile Phone', fieldName: 'MobilePhone', type: 'phone', cellAttributes:{
            class:{fieldName: 'rowStyle'}}},
        {label: 'Date of Birth', fieldName: 'Birthdate', type: 'text', cellAttributes:{
            class:{fieldName: 'rowStyle'}}},
        {label: 'Dietary Requirement', fieldName: 'Dietary_Requirement__c', type: 'text', cellAttributes:{
            class:{fieldName: 'rowStyle'}}},
        {label: 'Accessibility Requirement', fieldName: 'Accessibility_Requirement__c', type: 'text', cellAttributes:{
            class:{fieldName: 'rowStyle'}}},
    ]
      
    connectedCallback() {

        //check the payment status
        if(this.paymentStatus == 'A'){
            this.subHeader = 'Your registration was successful!';
            this.paymentApproved = true;
            this.subHeaderClass = 'heading2 pb2 subheader-color-suc';

        } else if(this.paymentStatus == 'D'){
            this.subHeader = 'Your payment was declined. Please check your payment details.';

        } else if(this.paymentStatus == 'C'){
            this.subHeader = 'Your payment was cancelled. Please check your payment details.';

        } else if(this.paymentStatus == 'V'){
            this.subHeader = 'Your payment has a validation failure. Please check your payment details.';
        }
              
        //get the data for the table
        getRegistrationConfirmationData({ externalId: this.externalId})
        .then((results) => {

            this.cartId = results.cartId;
            this.courseName = results.cartAndCourseDetails.Name;
            this.totalNumberOfLearnersRegistered = results.learners.length;
            this.employeesRegistered = results.learners;

            if(results.cartAndCourseDetails.Course_Offering__c){                                                  
                this.courseOffering = results.cartAndCourseDetails.Course_Offering__r;
                let date = new Date(this.courseOffering.hed__Start_Date__c);
                const formattedDate = date.toLocaleDateString("en-AU", {
                    day: "numeric",
                    month: "short",
                    year: "numeric"
                });
                this.courseDate = formattedDate;
                this.deliveryType = this.courseOffering.Delivery_Type__c;
                // this.totalNumberOfLearnersRegistered = this.courseOffering.Total_Number_of_Registered_Learners__c ;
            }else{              
                this.programOffering = results.cartAndCourseDetails.Program_Offering__r;                   
                let date = new Date(this.programOffering.Start_Date__c);
                const formattedDate = date.toLocaleDateString("en-AU", {
                    day: "numeric",
                    month: "short",
                    year: "numeric"
                });
                
                this.courseDate = formattedDate;
                this.deliveryType = this.programOffering.Delivery_Type__c;
                // this.totalNumberOfLearnersRegistered = this.programOffering.Total_Number_of_Registered_Learners__c ;
            }
                     
            //format the employee data
            this.employeesRegistered = this.employeesRegistered.map((employee) => {
                let birthdate = new Date(employee.Contact__r.Birthdate);
                let rowStyle = "slds-m-around_x-small desc-content bodyRegular" ;
                const formattedBirthDate = birthdate.toLocaleDateString(
                    "en-AU",
                    {
                        day: "numeric",
                        month: "short",
                        year: "numeric"
                    }
                );
                return {
                    ...employee.Contact__r,
                    ContactMobile_Locale__c:
                        employee.Contact__r.ContactMobile_Locale__c.replace(
                            /[^0-9\.]/g,
                            ""
                        ),
                    Birthdate: formattedBirthDate,
                    rowStyle
                };
            });
                  
        })
        .catch((error) => {
            console.log(error);
        })

        //for breadcrumbs
        this.publishLMS();
    }
      
    navigateToHome(){
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                    pageName: 'home'
            }
        }, true);
    }
              
              
    publishLMS() {
        let paramObj = {
            productId: 1,
            productName: 'Registration Confirmation',
            clearOtherMenuItems: true
        }
    
        const payLoad = {
            parameterJson: JSON.stringify(paramObj)
        };
    
        publish(this.messageContext, payloadContainerLMS, payLoad);
    }
}
      