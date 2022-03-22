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
    handleSubmit(){
        this.isLoading = true;
    }

    /**
     * method for handling succesful save on record edit form
     */
    handleSuccess(){
        this.isLoading = false;
        this.editMode = false;
        this.dispatchEvent(new CustomEvent('recordupdate'));
    }

    /**
     * method for handling record edit form errors
     */
    handleError(){
        this.isLoading = false;
    }

    /**
     * disables edit mode
     */
    handleCancel(){
        this.editMode = false;
    }

}