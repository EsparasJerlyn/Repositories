/**
 * @description Controller Class for contactImageSection
 * @see ../lwc/contactImageSection
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                 | Change Summary               |
      |--------------------------------|-----------------------|----------------------|------------------------------|
      | arsenio.jr.dayrit              | March 04, 2023        | DEPP-5322            | Created file                 | 
 */

public with sharing class ContactHeaderSectionCtrl {
    
    private String originalTransactionId;
    @AuraEnabled
    public static String createContentDistribution(String contentVersionId){
        try{
            List<Database.SaveResult> insertResults = new List<Database.SaveResult>();
            List<ContentDistribution> contentDistributionList = new List<ContentDistribution>();
            ContentDistribution contentDistribution = new ContentDistribution();
            contentDistribution.ContentVersionId = contentVersionId;
            contentDistribution.Name = 'PublicShare';
            contentDistributionList.add(contentDistribution);
    
            insertResults = Database.insert(contentDistributionList, false);

            for (Database.SaveResult result : insertResults){
                if (!result.isSuccess()){
                    Logger.error('Error in Inserting Content Distribution').setDatabaseResult(result);
                }            
            }
            if(Logger.getBufferSize() > 0){
                Logger.saveLog();                
            }

            List<ContentDistribution> contentDistributionsWithContentDownloadUrl = [SELECT ContentDownloadUrl FROM ContentDistribution WHERE Id = :contentDistributionList[0].Id WITH USER_MODE LIMIT 1];
    
            String imageURL = contentDistributionsWithContentDownloadUrl[0].ContentDownloadUrl;
            return imageURL;
        }catch(Exception e){
            throw new CustomException(e.getMessage());
                
        }
    }

    public class CustomException extends Exception{

    }

}