/**
 * @description A LWC component to Call Registration Form in Login Page
 *
 * @see ../LWC/registrationForm
 * 
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                        |
      |---------------------------|-----------------------|----------------------|---------------------------------------|
      | eugene.andrew.abuan       | March 28, 2022        | DEPP-1293            | Created file                          |
      |                           |                       |                      |                                       |
 */
import { LightningElement } from 'lwc';

export default class CustomLoginForm extends LightningElement {
    openModal = false;

    /*
    * Opens Modal Onclick 
    */
    handleOnClick(){
        this.openModal = true;
    }

    /*
    * Closes Modal
    */
    handleModalClosed() {
        this.openModal = false;
       }
}