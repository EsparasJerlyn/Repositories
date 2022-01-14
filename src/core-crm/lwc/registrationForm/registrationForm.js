/**
 * @description A LWC component to allow learner to register
 *
 * @see ../classes/RegistrationFormCtrl.cls
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                        |
      |---------------------------|-----------------------|----------------------|---------------------------------------|
      | eugene.andrew.abuan       | January 03, 2022      | DEPP-773             | Created file                          |
      |                           |                       |                      |                                       |
 */
import { LightningElement, track } from 'lwc';
import isEmailExist from '@salesforce/apex/RegistrationFormCtrl.isEmailExist';
import registerUser from '@salesforce/apex/RegistrationFormCtrl.registerUser';
import {loadStyle} from 'lightning/platformResourceLoader';
import customSR from '@salesforce/resourceUrl/customLwcCss';
export default class RegistrationForm extends LightningElement {
    @track firstName = null;
    @track lastName = null;
    @track mobile = null;
    @track email = null;
    @track birthdate = null;
    @track errorCheck;
    @track errorMessage;
    @track infoTooltipDisplayData = {};
    @track requiredTooltipDisplayData = {};
    @track errorTooltipDisplayData = {};
    @track emailError;
    loading = false; 

    /*
    *loads CSS style from static resource
    */
    renderedCallback(){
        Promise.all([
            loadStyle(this, customSR)
        ])
    }

    /*
    *Sets value for the tooltip
    */
    connectedCallback(){
        this.requiredTooltipDisplayData.firstName = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.lastName = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.email = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.mobile = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.birthdate = 'tooltiptext tooltipHide';

        this.errorTooltipDisplayData.email = 'tooltiptext tooltipHide';
    }
    
    /*
    *Removes error message once email is valid
    */
    onEmailInput(event){
        event.target.setCustomValidity('')
    }

    /*
    *Sets error message for Invalid Email address
    */
    onEmailInvalid(event){

        if (!event.target.validity.valid) {
            event.target.setCustomValidity('Enter a valid email address')
        }
        
    }

    /*
    *Removes tooltip of email
    */
    onEmailClick(event){
        let parent = event.target.parentElement.parentElement.parentElement;
        parent.classList.remove('tooltipEmail');
    }

    /*
    *Adds tooltip of email
    */
    onEmailBlur(event){
        let parent = event.target.parentElement.parentElement.parentElement;
        parent.classList.add('tooltipEmail');
    }

    /*
    * Checks the email if valid and already exists in salesforce
    * Creates user when all fields are valid
    */
    handleRegister(event){
        this.errorMessage = null;
        this.errorTooltipDisplayData.email = 'tooltiptext tooltipHide';

        if(!this.firstName){
            this.requiredTooltipDisplayData.firstName = 'tooltiptext tooltipShow';
        } else {
            this.requiredTooltipDisplayData.firstName = 'tooltiptext tooltipHide';
        }
        if(!this.lastName){
            this.requiredTooltipDisplayData.lastName = 'tooltiptext tooltipShow';
        } else {
            this.requiredTooltipDisplayData.lastName = 'tooltiptext tooltipHide';
        }
        if(!this.email){
            this.requiredTooltipDisplayData.email = 'tooltiptext tooltipShow';
        } else {
            this.requiredTooltipDisplayData.email = 'tooltiptext tooltipHide';
        }
        if(!this.mobile){
            this.requiredTooltipDisplayData.mobile = 'tooltiptext tooltipShow';
        } else {
            this.requiredTooltipDisplayData.mobile = 'tooltiptext tooltipHide';
        }
        if(!this.birthdate){
            this.requiredTooltipDisplayData.birthdate = 'tooltiptext tooltipShow';
        } else {
            this.requiredTooltipDisplayData.birthdate = 'tooltiptext tooltipHide';
        }

        if(this.firstName && this.lastName && this.email && this.mobile && this.birthdate){
            let emailCheck = /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(this.email);

            if( emailCheck == null || emailCheck == undefined || emailCheck == false ){                
                this.emailError = 'Please enter a valid email address';
                this.errorTooltipDisplayData.email = 'tooltiptext tooltipShow tooltipError';
                return;
            }
            event.preventDefault();

            isEmailExist({email: this.email}).then((res)=>{
                if(res !=null && res!=undefined && res==true){
                    this.emailError = 'Your email already exists.';
                    this.errorTooltipDisplayData.email = 'tooltiptext tooltipShow tooltipError';
                }
                else{
                    this.loading = true;
                    registerUser({
                        firstName: this.firstName, 
                        lastName: this.lastName, 
                        email: this.email, 
                        mobile: this.mobile, 
                        birtdate: this.birthdate})
                        .then((res) =>{
                            if(res){
                                window.location.href = res;
                                this.loading = false;
                            }
                        }).catch((error)=>{
                            this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
                        });
                }
            }).catch((error)=>{
                this.errorMessage = MSG_ERROR + this.generateErrorMessage(error);
            });
        }
    }

    /*
    * Sets the firstName via event
    */
    handleFirstNameChange(event){

        this.firstName = event.target.value;
    }

    /*
    * Sets the lastName via event
    */
    handleLastNameChange(event){

        this.lastName = event.target.value;
    }

    /*
    * Sets the email via event
    */
    handleEmailChange(event){

        this.email = event.target.value;
    }  
    
    /*
    * Sets the mobile via event
    */
    handleMobileChange(event){

        this.mobile = event.target.value;
    }

    /*
    * Sets the birthdate via event
    */
    handleBirthdateChange(event){

        this.birthdate = event.target.value;
    }
    
    /**
     * concatenates error name and message
     */
    generateErrorMessage(err){
        let _errorMsg = ' (';

        _errorMsg += err.name && err.message ? err.name + ': ' + err.message : err.body.message;
        _errorMsg += ')';

        return _errorMsg;
    }
}