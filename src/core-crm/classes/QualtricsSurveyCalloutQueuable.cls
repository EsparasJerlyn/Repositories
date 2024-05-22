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
    private List<Qualtrics_Survey__c> qualtricsSurveyList = new List<Case>();
        
        
    public QualtricsSurveyCalloutQueuable(List<Qualtrics_Survey__c> qualtricsSurvey) {
        this.qualtricsSurveyList = qualtricsSurvey;    
    }
        
    public void execute(QueueableContext context) {
            
        if(!qualtricsSurvey.isEmpty()){
            QualtricsSurveyService.updateQualtricsSurveyInfo(qualtricsSurvey);
        }
    }
}