/**
 * @description Trigger Event Listener for Address Change Event 
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | July 18, 2024         | DEPP-9942              | Created file                 |
 */

trigger OtherAddressChangeEventListener on Address_Change_Event__e (after insert) {

     OtherAddressChangeEventHandler otherAddressChangeEventHandler = new OtherAddressChangeEventHandler(Trigger.new);
     otherAddressChangeEventHandler.handle();
     
}