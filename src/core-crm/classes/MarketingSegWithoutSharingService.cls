/**
  * @description without sharing class for MarketingSegmentationWithoutSharingClass
  * @see ..MarketingSegmentationTriggerHelper
  *
  * @author Accenture 
  *
  * @history
  *
  *    | Developer Email                | Date                  | JIRA                   | Change Summary                                 |
  *    |--------------------------------|-----------------------|------------------------|------------------------------------------------|
  *    | roy.nino.s.regala              | Feb 5, 2022           | DEPP-7742              | Created file                                   |
  */

public without sharing class MarketingSegWithoutSharingService{
    
    /** 
      * @description perform contact update without sharing context
      * @param map of contacts to update
      */
    public static List<Database.SaveResult> updateContactRecordsWithoutSharing(List<Contact> contactsToUpdate) {
        return ContactsDAO.newInstance().updateRecords(contactsToUpdate, false, AccessLevel.SYSTEM_MODE);   
    }
    
}