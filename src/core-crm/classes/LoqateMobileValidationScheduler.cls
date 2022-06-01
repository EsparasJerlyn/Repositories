/**
 * @description scheduler for LoqateMobileValidationBatch
 *
 * @see LoqateMobileValidationBatch
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA         | Change Summary                              |
      |---------------------------|-----------------------|--------------|---------------------------------------------|
      | roy.nino.s.regala         | May 31, 2022          | DEPP-2105    | Created file                                | 
      |                           |                       |              |                                             | 
*/
public with sharing class LoqateMobileValidationScheduler implements Schedulable {
    
    /**
    * @description Method for calling Publishing End Date batch job
    */
    public void execute (SchedulableContext context){
		Database.executeBatch(new LoqateMobileValidationBatch('Lead'),50);
        if(!Test.isRunningTest()){ Database.executeBatch(new LoqateMobileValidationBatch('Contact'),50);}
            
    }
}