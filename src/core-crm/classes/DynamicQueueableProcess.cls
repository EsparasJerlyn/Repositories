/**
 * @description Service Class for DynamicQueueableProcess class
 *
 * @see DynamicQueueableProcess
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------|
 *    | mark.j.mahilum                 | June 23,2023          | DEPP-5846	            | Created File                  |
 */
public class DynamicQueueableProcess implements Queueable {
    private List<SObject> objectList;
    private String serviceClassName;
    private AccessLevel accessLevel;
    
    public DynamicQueueableProcess(List<SObject> objectList,String serviceClassName, AccessLevel accessLevel) {
        this.objectList = objectList;
        this.serviceClassName = serviceClassName;
        this.accessLevel = accessLevel;
    }

    public void execute(QueueableContext context) { 
        
		if(serviceClassName =='CaseService'){
            CaseService.enqueueCasesToPrioritize((List<Case>)objectList,accessLevel);
        }
    }
}