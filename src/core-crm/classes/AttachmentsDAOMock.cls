/**
 * @description DAO Mock Class for Attachment Object. 
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
@isTest
public inherited sharing class AttachmentsDAOMock extends DmlBaseMock implements IAttachmentsDAO {
    public Map<Id, Attachment> attachmentMap;
    public AttachmentsDAOMock() {
        super(new Map<Id, Attachment>(), Schema.Attachment.SObjectType);
        this.attachmentMap = (Map<Id, Attachment>) super.records;
    }
    public Schema.SObjectType getSObjectType() {
        return Attachment.SObjectType;
    }
    public List<Attachment> findAttachmentsByNames(Set<String> names, AccessLevel accessLevel){
        List<Attachment> attachmentList = new List<Attachment>();
        for(Attachment record : attachmentMap.values()){
            if(names.contains(record.Name)){
                attachmentList.add(record);
            }
        }
        return attachmentList;
    }
}