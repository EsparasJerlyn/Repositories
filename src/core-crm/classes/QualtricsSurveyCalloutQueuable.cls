/**
 * @description Service Class for QualtricsSurveyCalloutQueuable class
 *
 * @see QualtricsSurveyCalloutQueuable
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------|
 *    | arsenio.jr.dayrit              | May 20,2024           | DEPP-8821	            | Created File                  |
 */
public class QualtricsSurveyCalloutQueuable implements Queueable{
    private List<Case> caseList = new List<Case>();
        
        
    public QualtricsSurveyCalloutQueuable(List<Case> cases) {
        this.caseList = cases;    
    }
        
    public void execute(QueueableContext context) {
            
        if(!caseList.isEmpty()){
            QualtricsSurveyService.enqueueQualtricsSurveyToProcess(caseList);
        }
    }
}