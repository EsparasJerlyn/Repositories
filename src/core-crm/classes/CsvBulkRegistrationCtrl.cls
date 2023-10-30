/**
 * @description Controller Class for addProductRequest LWC
 * @see ../lwc/addProductRequest
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | aljohn.p.motas            | December 6, 2021      | DEPP-1025,42         | Created file                 | 
      | aljohn.p.motas            | December 27, 2021     | DEPP-1025,42         | GetCMSContentDataByName      | 
      | julie.jane.alegre         | September 26, 2023    | DEPP-4762            | Add Position & Company Name  |
      | kenneth.f.alsay           | October 24, 2023      | DEPP-6981            | Aligned Columns with BulkRegistrationCSVTemplate.csv   |  
 */

public with sharing class CsvBulkRegistrationCtrl {

    @AuraEnabled(cacheable=true)
    public static ConnectApi.ManagedContentVersion GetCMSContentDataByName(CMSContentDataFilter filter) {
        ConnectApi.ManagedContentVersion returnList;
        try {
            Integer pageNo = 0;
            Boolean contentFound = false;
            while (!contentFound) {
                ConnectApi.ManagedContentVersionCollection contentList;
                if(!Test.isRunningTest()){
                    contentList = ConnectApi.ManagedContent.getManagedContentByTopics(filter.communityId, null, pageNo, null, filter.language, filter.contentType);
                }
                // Use Total 
                if (contentList == null || contentList.total < 1 ) {
                     break;
                }
    
                for (ConnectApi.ManagedContentVersion c : contentList.items) {
                    //Boolean cnIndex = (c.title == contentNames);
                    if (c.title == filter.contentNames) {  returnList = c ;
                            contentFound = true;
                            break;
                    }
                }
                pageNo += 1;
            }
        } catch (ConnectApi.ConnectApiException e) {                
            Logger.error('Exception "ConnectApiException" caught in method GetCMSContentDataByName in class CsvBlukRegistrationCtrl.')
                .setExceptionDetails(e);
        } finally {
            if(Logger.getBufferSize() > 0) {
                Logger.saveLog();
            }
        }
        return returnList;
    }

    @AuraEnabled
    public static list<FieldDataType> readCSVFile(Id idContentDocument){
        list<FieldDataType> lstAccsToInsert = new list<FieldDataType>();
        if(idContentDocument != null) {
    
            Set<Id> contentDocumentId = new Set<Id>();
            contentDocumentId.add(idContentDocument);
            // getting File Data based on document id 
            List<ContentVersion> objVersionList = ContentVersionsDAO.newInstance().getContentVersionBySetContentDocumentIds(contentDocumentId);

            // split the file data
            list<String> lstCSVLines = objVersionList[0].VersionData.toString().split('\n');

            for(Integer i = 1; i < lstCSVLines.size(); i++){
                FieldDataType objAcc = new FieldDataType();
                list<String> csvRowData = lstCSVLines[i].split(',');
                objAcc.FirstName = csvRowData[0];
                objAcc.LastName = csvRowData[1];
                objAcc.Email = csvRowData[2];
                objAcc.MobileLocale = csvRowData[3];
                objAcc.MobilePhone = csvRowData[4];
                objAcc.Position = csvRowData[5];
                objAcc.CompanyName = csvRowData[6];
                objAcc.Birthdate = csvRowData[7];
                objAcc.DietaryRequirement = csvRowData[8];
                objAcc.AccessibilityRequirement = csvRowData[9];
                lstAccsToInsert.add(objAcc);
            }
        }
        return lstAccsToInsert;    
    }

    public class FieldDataType {
        @AuraEnabled public String FirstName;
        @AuraEnabled public String LastName;
        @AuraEnabled public String Email;
        @AuraEnabled public String MobileLocale;
        @AuraEnabled public String Position;
        @AuraEnabled public String CompanyName;
        @AuraEnabled public String MobilePhone;
        @AuraEnabled public String Birthdate;
        @AuraEnabled public String DietaryRequirement;
        @AuraEnabled public String AccessibilityRequirement;
    }

    public class CMSContentDataFilter {
        @AuraEnabled public String contentNames { get; set; }
        @AuraEnabled public String communityId { get; set; }
        @AuraEnabled public String contentType { get; set; }
        @AuraEnabled public String language { get; set; }
    }
}