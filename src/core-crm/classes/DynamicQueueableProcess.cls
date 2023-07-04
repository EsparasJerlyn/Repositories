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

    public DynamicQueueableProcess(List<SObject> objectList,String serviceClassName) {
        this.objectList = objectList;
        this.serviceClassName = serviceClassName;
    }

    public void execute(QueueableContext context) {
        
        if(serviceClassName =='ApplicationService'){
            ApplicationService.enqueueApplicationToExecute((List<hed__Application__c>) objectList,ApplicationsDAO.STUDYLINK_RECTYPE_ID);                               
        }
        
    }
}