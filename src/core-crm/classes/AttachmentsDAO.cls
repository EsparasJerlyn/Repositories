/**
 * @description DAO Class for Attachment object. Contains soql and constants related to the Attachment object.
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
 *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
 *    | arsenio.jr.dayrit              | May 13, 2024          | DEPP-8743              | Created file                                   |
 *    |                                |                       |                        |                                                |
 */
public inherited sharing class AttachmentsDAO extends DmlBase implements IAttachmentsDAO {
    
    public static IAttachmentsDAO newInstance() {
        return (IAttachmentsDAO) ImplementationSelector.DAO.newInstance(
            Attachment.SObjectType
        );
    }
    public Schema.SObjectType getSObjectType() {
        return 	Attachment.SObjectType;
    }
    public List<Attachment> findByName(String name, AccessLevel accessLevel){
        if(String.isBlank(name)){
            return new List<Attachment>();
        }
        return Database.query(
            'SELECT Id, ' +
            'Name ' +
            'FROM Attachment ' +
            'WHERE Name =: name',
            accessLevel
        ); 
    }
}