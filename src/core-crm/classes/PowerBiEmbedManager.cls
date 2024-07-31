/**
 * @description class for PowerBI
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                    |
      |--------------------------------|-----------------------|------------------------|---------------------------------------------------|
      | kenneth.f.alsay                | July 30, 2024         | DEPP-8279              | Created file                                      |
 */

public with sharing class PowerBiEmbedManager {

    public class PowerBiReport    {
        public String id { get; set; } 
        public String reportType { get; set; } 
        public String name { get; set; } 
        public String webUrl { get; set; } 
        public String embedUrl { get; set; } 
        public boolean isFromPbix { get; set; } 
        public boolean isOwnedByMe { get; set; } 
        public String datasetId { get; set; } 
   }
    
    public class PowerBiEmbedToken    {
        public string token { get; set; } 
        public string tokenId { get; set; } 
        public DateTime expiration { get; set; } 
    }
 
    public class PowerBiReportData    {
    	@AuraEnabled
        public String workspaceId { get; set; } 
    	@AuraEnabled
        public String reportId { get; set; } 
    	@AuraEnabled
        public String name { get; set; } 
    	@AuraEnabled
        public String embedUrl { get; set; } 
    	@AuraEnabled
        public String embedToken { get; set; } 
    	@AuraEnabled
        public DateTime embedTokenExpires { get; set; } 
        @AuraEnabled
        public String error { get; set; } 
     }
   
    @AuraEnabled(cacheable=true)
    public static PowerBiReportData getEmbeddingDataForReport(String WorkspaceId, String ReportId) {   

        // Call to Power BI Service API to get report data for embedding        
        HttpRequest reqGetReport = new HttpRequest();
        reqGetReport.setMethod('GET');
        String urlGetReport = 'callout:PowerBI' + '/' + WorkspaceId + '/reports/' + ReportId;
        reqGetReport.setEndpoint(urlGetReport);
        
        Http http = new Http();        
        HttpResponse response = http.send(reqGetReport);
        
        // check response for success
        if(response.getStatusCode()!=200){
            PowerBiReportData getReportError = new PowerBiReportData();
            getReportError.error = 'Get Report Error: ' + response.getStatus();
            return getReportError;            
        }            
    
        // extract Power BI report data from JSON response
        String responseJson = response.getBody();
        PowerBiReport powerBiReport = (PowerBiReport)JSON.deserialize(responseJson, PowerBiReport.class);

	    // Call to Power BI Service API to get embed token for report        
        HttpRequest reqGetEmbedToken = new HttpRequest();
        reqGetEmbedToken.setMethod('POST');
        String urlGetEmbedToken = 'callout:PowerBI' + '/' + WorkspaceId + '/reports/' + ReportId + '/GenerateToken';
        reqGetEmbedToken.setEndpoint(urlGetEmbedToken);   
        reqGetEmbedToken.setBody('{"accessLevel": "View", "datasetId": "' + powerBiReport.datasetId + '"}');
    
        HttpResponse responseEmbedToken = http.send(reqGetEmbedToken);

        // check response for success
        if(responseEmbedToken.getStatusCode()!=200){
            PowerBiReportData getEmbedTokenError = new PowerBiReportData();
            getEmbedTokenError.error = 'Get Embed Token Error: ' + response.getStatus();
            return getEmbedTokenError;            
        }            

        // extract Power BI embed token and expiration
        PowerBiEmbedToken embedToken = (PowerBiEmbedToken)JSON.deserialize(responseEmbedToken.getBody(), PowerBiEmbedToken.class);
        
        // create custom remote-able object to return to caller in browser 
        PowerBiReportData powerBiReportData = new PowerBiReportData();        
        powerBiReportData.workspaceId = WorkspaceId;
        powerBiReportData.reportId = ReportId;
        powerBiReportData.name = powerBiReport.name;
        powerBiReportData.embedUrl = powerBiReport.embedUrl;
        powerBiReportData.embedToken = embedToken.token;
        powerBiReportData.embedTokenExpires = embedToken.expiration;
        
        return powerBiReportData;            
 
    }

}