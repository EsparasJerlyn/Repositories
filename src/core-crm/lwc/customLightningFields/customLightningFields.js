/**
 * @description A custom LWC for showing custom layout stored in metadata
 *
 * @author Accenture
 *       
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                         |
      |---------------------------|-----------------------|---------------------|--------------------------------------------------------|
      | angelika.j.s.galang       | March 3, 2022         | DEPP-1831           | Created file                                           |
      |                           |                       |                     |                                                        |
*/
import { LightningElement, api } from 'lwc';

export default class CustomLightningFields extends LightningElement {
    @api childObjectApiName;
    @api childRecordId;
    @api layoutItem;
    @api showEditButton;

    editMode = false;
    isLoading = true;
    showPopoverIcon = false;
    showPopoverDialog = false;
    popoverErrorMessages = [];
    formFields = [];

    /**
     * stops spinner on form load
     */
    handleLoad(){
        this.isLoading = false;
    }

    /**
     * enables edit mode
     */
    handleEdit(){
        this.editMode = true;
    }

    /**
     * method for handling record edit form submission
     */
    handleSubmit(event){
        this.isLoading = true;
        this.formFields = Object.keys(event.detail.fields);
        this.resetPopover();
    }

    /**
     * method for handling succesful save on record edit form
     */
    handleSuccess(event){
        this.isLoading = false;
        this.editMode = false;
        this.resetPopover();
        this.dispatchEvent(new CustomEvent('recordupdate', {
            detail : event.detail
        }));
    }

    /**
     * method for handling record edit form errors
     */
    handleError(event){
        this.isLoading = false;

        //for error messages not visible on shown fields
        this.popoverErrorMessages = [];
        let fieldErrors = event.detail.output.fieldErrors;
        Object.keys(fieldErrors).forEach(fieldError => {
            if(!this.formFields.includes(fieldErrors[fieldError][0].field)){
                this.popoverErrorMessages.unshift(fieldErrors[fieldError][0].message);
            }
        });
        if(this.popoverErrorMessages.length > 0){  
            this.showPopoverIcon = true;
            this.showPopoverDialog = true;
        }
    }

    /**
     * shows/hides the popover error dialog
     */
    handlePopover(){
        this.showPopoverDialog = this.showPopoverDialog ? false : true;
    }

    /**
     * disables edit mode
     */
    handleCancel(){
        this.editMode = false;
        this.resetPopover();
    }

    /**
     * hides popover
     */
    resetPopover(){
        this.showPopoverIcon = false;
        this.showPopoverDialog = false;
        this.popoverErrorMessages = [];
    }

}