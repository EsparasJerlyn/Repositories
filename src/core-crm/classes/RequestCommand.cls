/**
 * @description Invoker Class for Request Command Interface
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 29, 2023       | DEPP-6138              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class RequestCommand {

    private IRequestCommand command;
    
    public void setCommand(IRequestCommand command) {
        this.command = command;
    }
    
    public void executeCommand() {
        if (command != null) {
            command.execute();
        }
    }
}