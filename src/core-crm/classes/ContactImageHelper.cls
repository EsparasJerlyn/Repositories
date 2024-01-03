/**
 * @description helper to validate and generate Contact Image File
 * @see ContactTriggerHandler
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | john.bo.a.pineda               | April 21, 2022        | DEPP-1211              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class ContactImageHelper {
  /**
   * @description validate if there are more than 1 Image File on Contact_Image__c
   * @param conNew - List of Contact.Trigger.new
   */
  public static void validateContactImageFile(List<Contact> conNew) {
    for (Contact conVal : conNew) {
      Integer imageCount = 0;

      if (String.isNotBlank(conVal.Contact_Image__c)) {
        // Count Number of Images on Contact_Image__c
        Matcher imgMatcher = Pattern.compile('<img(.+?)>')
          .matcher(conVal.Contact_Image__c);
        while (imgMatcher.find()) {
          imageCount++;
          // Validate if there is more than 1 Image File on Contact_Image__c
          if (imageCount > 1) {
            conVal.Contact_Image__c.addError(
              Label.QUT_Contact_ContactImageError
            );
            break;
          }
        }
      }
    }
  }

  /**
   * @description update counter for Course Connections
   * @param conNewString - String of Map of Contact.Trigger.new
   * @param conOldString - String of Map of Contact.Trigger.old
   */
  public static void generateContactImageFile(
    List<Contact> conNew,
    Map<Id, Contact> conOld
  ) {
    try {
      // Init
      Map<Id, String> imageURLMap = new Map<Id, String>();
      Set<Id> conIdImageFileDelete = new Set<Id>();

      // Loop through Contact.Trigger.new
      for (Contact con : conNew) {
        String imageURL;

        if (String.isNotBlank(con.Contact_Image__c)) {
          // Get ImageURL on Contact_Image__c
          Matcher imgMatcher = Pattern.compile('<img(.+?)>')
            .matcher(con.Contact_Image__c);
          while (imgMatcher.find()) {
            String imageTag = imgMatcher.group();
            imageURL = imageTag.substringBetween(' src="', '"');
          }
          // Get All Contacts where Contact_Image__c is changed
          Boolean isContactImageChanged = conOld != null && conOld.get(con.Id).Contact_Image__c != con.Contact_Image__c;
          if (isContactImageChanged) {
              conIdImageFileDelete.add(con.Id);
          }  
          if (String.isNotBlank(imageURL)) {
            imageURLMap.put(con.Id, imageURL);
          }


        } else {
          conIdImageFileDelete.add(con.Id);
        }
      }

      // Delete Old Contact Image File on Contact when Contact_Image__c is changed
      if (conIdImageFileDelete.size() > 0) {
        // Get ContentDocumentLink linked to Contact
        List<ContentDocumentLink> contentDocuLinkDelList = [
          SELECT Id, ContentDocumentId
          FROM ContentDocumentLink
          WHERE LinkedEntityId IN :conIdImageFileDelete
        ];

        // Get ContentDocument Id to be deleted
        Set<Id> contentDocu = new Set<Id>();
        for (ContentDocumentLink contentDocuLinkDel : contentDocuLinkDelList) {
          contentDocu.add(contentDocuLinkDel.ContentDocumentId);
        }

        // Delete ContentDocument
        List<ContentDocument> contentDocuList = [
          SELECT Id
          FROM ContentDocument
          WHERE Title = 'ContactImage.jpg' AND Id IN :contentDocu
        ];

        delete contentDocuList;
      }

      // Create Image File
      if (imageURLMap.size() > 0) {
        createContactImageFile(imageURLMap);
      }
    } catch (Exception e) {
      Logger.error('Exception caught in method generateContactImageFile in class ContactImageHelper.')
        .setExceptionDetails(e);
    } finally {
      if(Logger.getBufferSize() > 0) {
        Logger.saveLog();
      }
    }
  }

  @future(callout=true)
  public static void createContactImageFile(Map<Id, String> conImageURLMap) {
    List<ContentVersion> cvList = new List<ContentVersion>();

    // Create Content Version
    for (Id conImgURLId : conImageURLMap.keySet()) {
      Blob imageBlob;
      String imgURL = conImageURLMap.get(conImgURLId);
      PageReference page = new PageReference(imgURL.unescapeHtml4());
      if (Test.isRunningTest()) {
        imageBlob = Blob.valueof('Test Content');
      } else {
        imageBlob = page.getContent();
      }

      ContentVersion cv = new ContentVersion();
      cv.VersionData = imageBlob;
      cv.Title = 'ContactImage.jpg';
      cv.PathOnClient = 'ContactImage.jpg';
      cv.ReasonForChange = conImgURLId;
      cvList.add(cv);
    }

    // Create Related Content Document Objects
    List<ContentDocumentLink> contentDocuLinkList = new List<ContentDocumentLink>();
    List<ContentDistribution> contentDistriList = new List<ContentDistribution>();
    if (cvList.size() > 0) {
      insert cvList;

      Set<Id> cvIdSet = (new Map<Id, ContentVersion>(cvList)).keySet();
      List<ContentVersion> cvContentDocuList = [
        SELECT Id, Title, ContentDocumentId, ReasonForChange
        FROM ContentVersion
        WHERE Id IN :cvIdSet
      ];

      if (cvContentDocuList.size() > 0) {
        for (ContentVersion cvContentDocu : cvContentDocuList) {
          ContentDocumentLink contentDocuLink = new ContentDocumentLink();
          contentDocuLink.ContentDocumentId = cvContentDocu.ContentDocumentId;
          contentDocuLink.LinkedEntityId = cvContentDocu.ReasonForChange;
          contentDocuLink.ShareType = 'V';
          contentDocuLink.Visibility = 'AllUsers';
          contentDocuLinkList.add(contentDocuLink);

          ContentDistribution contentDistri = new ContentDistribution();
          contentDistri.contentVersionId = cvContentDocu.Id;
          contentDistri.Name = cvContentDocu.Title;
          contentDistriList.add(contentDistri);
        }

        insert contentDocuLinkList;
        insert contentDistriList;
      }
    }
  }
}
