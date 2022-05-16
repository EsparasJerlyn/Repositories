/**
 * @description Controller Class for addProductRequest LWC
 * @see ../lwc/addProductRequest
 * @author Accenture
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | aljohn.p.motas            | December 6, 2021      | DEPP-1025,42         | Created file                 | 
      | aljohn.p.motas            | December 27, 2021     | DEPP-1025,42         | GetCMSContentDataByName      | 
      |                           |                       |                      |                              | 
 */

public with sharing class CsvBulkRegistrationCtrl {

    	@AuraEnabled(cacheable=true)
        public static ConnectApi.ManagedContentVersion GetCMSContentDataByName(
            String contentNames,
            String communityId,
            String contentType, 
            String language
        ) {
            ConnectApi.ManagedContentVersion returnList;
            try {
                Integer pageNo = 0;
                Boolean contentFound = false;
                while (!contentFound) {
                    ConnectApi.ManagedContentVersionCollection contentList;
                    if(!Test.isRunningTest()){
                        contentList = ConnectApi.ManagedContent.getManagedContentByTopics(communityId, null, pageNo, null, language, contentType);
                    }
                    // Use Total 
                    if (contentList == null || contentList.total < 1 ) {
                         break;
                    }
        
                    for (ConnectApi.ManagedContentVersion c : contentList.items) {
                        //Boolean cnIndex = (c.title == contentNames);
                        if (c.title == contentNames) {  returnList = c ;
                                contentFound = true;
                                break;
                        }
                    }
                    pageNo += 1;
                }
            } catch (ConnectApi.ConnectApiException e) {                
                System.debug(LoggingLevel.DEBUG, 'error on CsvBulkRegistrationCtrl.GetCMSContentDataByName'); //NOPMD
            }
            return returnList;
        }
    
 	@AuraEnabled
    public static list<FieldDataType> readCSVFile(Id idContentDocument){
        list<FieldDataType> lstAccsToInsert = new list<FieldDataType>();
        if(idContentDocument != null) {
       
            // getting File Data based on document id 
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
            // split the file data
            list<String> lstCSVLines = objVersion.VersionData.toString().split('\n');

            for(Integer i = 1; i < lstCSVLines.size(); i++){
                FieldDataType objAcc = new FieldDataType();
                list<String> csvRowData = lstCSVLines[i].split(',');
                objAcc.Salutation = csvRowData[0]; // accName
                objAcc.FirstName = csvRowData[1];
                objAcc.MiddleName = csvRowData[2];
                objAcc.LastName = csvRowData[3];
                objAcc.Suffix = csvRowData[4];
                objAcc.Email = csvRowData[5];
                objAcc.MobilePhone = csvRowData[6];
                objAcc.Phone = csvRowData[7];
                objAcc.Birthdate = csvRowData[8];
                lstAccsToInsert.add(objAcc);
            }
        }
        return lstAccsToInsert;    
    }
    
       public class FieldDataType {
	        @AuraEnabled
            public String Salutation;
            @AuraEnabled
            public String FirstName;
            @AuraEnabled
            public String MiddleName;
            @AuraEnabled
            public String LastName;
            @AuraEnabled
            public String Suffix;
            @AuraEnabled
            public String Email;
            @AuraEnabled
            public String MobilePhone;
            @AuraEnabled
            public String Phone;
            @AuraEnabled
            public String Birthdate;
       }
    
}