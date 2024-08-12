/**
 * @description Class for Sync Operating Hours to AWS Callouts
 *  
 * @author Accenture
 * 
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary                      |
      |---------------------------|-----------------------|----------------------|-------------------------------------|
      | kathleen.mae.caceres      | July 12, 2024         | DEPP-9834            | Created File                        |
      | john.aldric.s.seril       | July 23, 2024         | DEPP-9834            | Add Request and Response Wrapper    |
 */
public with sharing class AmazonHttpCallout {

    private static final String AMAZON_CONNECT_HOURS_OPERATIONS_ENDPOINT = System.Label.AmazonConnectHoursOfOperation;

    public class RequestBody{
        public List<config> Config;
        public String Description;
        public String Name;
        public String TimeZone;
    }
    
    public class Config{
        public String Day;
        public hoursAndMinutes EndTime;
        public hoursAndMinutes StartTime;
        public config (String day, hoursAndMinutes endTime, hoursAndMinutes startTime){
            this.Day = day;
            this.EndTime = endTime;
            this.StartTime = startTime;
        }
    }
    
    public class HoursAndMinutes{
        public Integer Hours;
        public Integer Minutes;
        public hoursAndMinutes(Integer hours, Integer minutes){
            this.Hours = hours;
            this.Minutes = minutes;
        }
    }
    
    public class ResponseBody{
        public String HoursOfOperationArn;
        public String HoursOfOperationId;
    }
    
    public class ResponseStatus{
        public List<OperatingHours> successCallout;
        public List<OperatingHours> failedCallout;
    }
    
    public class CustomException extends Exception{}
    
    @AuraEnabled
    public static String syncOperatingHours(Id operatingHrsId) {
        String statusResponse = 'Success';
        if(operatingHrsId == null) {
            throw new CustomException('Missing operating hour id');        
    	}
        
        //getOperatingHoursMap
        List<OperatingHours> operatingHoursList = OperatingHoursDAO.newInstance().getOperatingHoursByIdAndChannel(
            new Set<Id>{operatingHrsId}, 
            OperatingHoursDAO.TYPE_VOICE, 
            AccessLevel.USER_MODE
        );
        
		if(operatingHoursList.isEmpty()){
            throw new CustomException('Could not find Operating Hours for Voice');
        }         
 
        //Send the request and get response
        responseStatus calloutStatus = syncToAWSCallout(operatingHoursList);
        
        if(!calloutStatus.successCallout.isEmpty()){
        	update calloutStatus.successCallout; 
        }
        
        if(!calloutStatus.failedCallout.isEmpty()){
        	statusResponse = 'Failed';
        }
        
        return statusResponse;
    }
    
    /**
    * Request Callout for Operating Hours Record to AWS
    *
    * @param operatingHoursRecord.
    * @return responseStatus Wrapper for Success and Failed list.
    */
    public static responseStatus syncToAWSCallout(List<OperatingHours> operatingHoursRecordList){
        String setMethod = 'PUT';
        String requestBody;
        String externalId = '';        
        responseStatus responseStatusWrapper = new responseStatus();
        List<OperatingHours> successSync = new List<OperatingHours>();
        List<OperatingHours> failedSync = new List<OperatingHours>();
        Map<Id, String> operatingHoursHolidayMap = new Map<Id, String>(); 
        Map<Id, List<Config>> timeSlotMap = new Map<Id, List<Config>>();
        
        operatingHoursHolidayMap = getOperatingHoursHoliday(operatingHoursRecordList);
        timeSlotMap = getTimeSlot(operatingHoursRecordList, operatingHoursHolidayMap);
        
        for(OperatingHours operatingHoursRecord: operatingHoursRecordList){
            
            //contruct requestbody
            requestBody = constructRequestBody(operatingHoursRecord, timeSlotMap);        
            
            //set Integration Method
            if(operatingHoursRecord.AWS_Business_Hour_External_ID__c != null){
                setMethod = 'POST';
                externalId = '/' + operatingHoursRecord.AWS_Business_Hour_External_ID__c;
            }
            
            //Send the request and get a response
            String amazonInstanceId = 'a43d221c-c330-4c4a-b6b4-bfdf429bf92f';
            String endpoint = 'callout:AmazonConnect' + AMAZON_CONNECT_HOURS_OPERATIONS_ENDPOINT + amazonInstanceId;    
            HttpResponse postResponse = IntegrationCallOutCtrl.doCallout(endpoint + externalId, setMethod, requestBody);
            
            if(postResponse.getStatusCode() != 200) {
                failedSync.add(operatingHoursRecord);
            } else {
                if(!String.isBlank(postResponse.getBody())){
                    responseBody responseBodyObject = (responseBody)JSON.deserialize(postResponse.getBody(), responseBody.class);
                    operatingHoursRecord.AWS_Business_Hour_External_ID__c = responseBodyObject.HoursOfOperationId;
                    successSync.add(operatingHoursRecord);
                }
            }
        }
        
        responseStatusWrapper.successCallout = successSync;
        responseStatusWrapper.failedCallout = failedSync;
        return responseStatusWrapper;    
    }    

    /**
    * Retrieve Operating Hours with Time Slots Record 
    *
    * @param operatingHoursIdList, operating Hours Record List
    * @param operatingHoursHolidayMap, operating Hours Holiday Record Map
    * @return Map<Id,List<Config>> (OperatingHoursId,List of Config wrapper)
    */
    public static Map<Id,List<Config>> getTimeSlot(List<OperatingHours> operatingHoursIdList, Map<Id, String> operatingHoursHolidayMap){
        Map<Id, List<Config>> timeSlotMap = new Map<Id,List<Config>>();
        for(TimeSlot timeSlotRecord: TimeSlotsDAO.newInstance().getTimeSlotRecords(operatingHoursIdList, AccessLevel.USER_MODE)){
			if(timeSlotRecord.DayOfWeek.toUpperCase() == operatingHoursHolidayMap?.get(timeSlotRecord.OperatingHoursId)?.toUpperCase()){
                continue;
            }
                                          
            Config configRecord = new config(timeSlotRecord.DayOfWeek.toUpperCase(), 
                                      new hoursAndMinutes(timeSlotRecord.EndTime?.hour(),timeSlotRecord.EndTime?.minute()), 
                                      new hoursAndMinutes(timeSlotRecord.StartTime?.hour(),timeSlotRecord.StartTime?.minute())  
                                     );   
                                          
            if(timeSlotMap.containsKey(timeSlotRecord.OperatingHoursId)){                              
        		timeSlotMap.get(timeSlotRecord.OperatingHoursId).add(configRecord);                                  
            }else{
                timeSlotMap.put(timeSlotRecord.OperatingHoursId, new List<Config>{configRecord});                                  
            }
                                          
        }	
        return timeSlotMap;
    }
    
    /**
    * Retrieve Operating Hours with Operating Hours Holiday
    *
    * @param operatingHoursList.
    * @return Map<Id, String> operating Hours and day of Week of the holiday.
    */    
    public static Map<Id, String> getOperatingHoursHoliday(List<OperatingHours> operatingHoursList){
        
        Map<Id, String> dayOfWeekMap = new Map<Id, String>();
        for(OperatingHoursHoliday operatingHrsHolidayRecord: OperatingHoursHolidaysDAO.newInstance().getOperatingHoursHolidayRecords(operatingHoursList, AccessLevel.USER_MODE)){
            DateTime dateTimeValue = (dateTime)operatingHrsHolidayRecord.Holiday.ActivityDate;                                                        
            if(dateTimeValue == (DateTime)Date.today()){                                                        
            	dayOfWeekMap.put(operatingHrsHolidayRecord.OperatingHoursId, dateTimeValue.format('EEEE'));                                                        
            }    
        }
        return dayOfWeekMap;
    }
    
    /**
    * Construct Request Body for AWS Callout
    *
    * @param operatingHours, operating Hours Record to Construct Request Body.
    * @param timeSlotMap, time Slot Records to include in Constructing Request Body.
    * @return String JSON.
    */
    public static String constructRequestBody(OperatingHours operatingHoursRecord, Map<Id, List<Config>> timeSlotMap){
        List<config> configList = new List<config>();
        
        if(timeSlotMap.containsKey(operatingHoursRecord.Id)){
        	configList = timeSlotMap.get(operatingHoursRecord.Id);	    
        }
        
        requestBody rqstBody = new requestBody();
        rqstBody.config = configList;
        rqstBody.description = operatingHoursRecord.Description;
        rqstBody.name = operatingHoursRecord.Name;
        rqstBody.timeZone = operatingHoursRecord.TimeZone;

        return JSON.serialize(rqstBody);
    }

}