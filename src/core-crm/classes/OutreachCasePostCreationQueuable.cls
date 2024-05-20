/**
 * @description Service Class for OutreachCasePostCreationQueuable class
 *
 * @see OutreachCasePostCreationQueuable
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------|
 *    | arsenio.jr.dayrit              | May 20,2024           | DEPP-8821	            | Created File                  |
 */
public class OutreachCasePostCreationQueuable {
    private List<Case> caseList = new List<Case>();

    public OutreachCasePostCreationQueuable(List<Case> cases) {
        this.caseList = cases;
    }

    public void execute(QueueableContext context) {
            
        if(!caseList.isEmpty()){
            //email enqueue method
        }
    }
}