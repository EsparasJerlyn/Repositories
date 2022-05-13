/**
 * @description Controller Class for generateCode LWC
 * @see ../lwc/generateCode
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                 | Change Summary               |
      |---------------------------|-----------------------|----------------------|------------------------------|
      | eccarius.karl.munoz       | May 11, 2022          | DEPP-2336            | Created file                 |
      |                           |                       |                      |                              |
*/
public with sharing class GenerateCodeCtrl {

    /**
     * Retrieves Course or Program record based on product request.
     * @param String recordId
     * @return CourseProgramDetails
     */
    @AuraEnabled(cacheable=true)
    public static CourseProgramDetails getCourseAndProgDetails(String recordId){
        List<hed__Course__c> courses = [SELECT Id, Name, Course_Code__c, RecordType.DeveloperName FROM hed__Course__c WHERE ProductRequestID__c =: recordId LIMIT 1];
        List<hed__Program_Plan__c> programs = [SELECT Id, Name, Code__c, RecordType.DeveloperName FROM hed__Program_Plan__c WHERE Product_Request__c  =: recordId LIMIT 1];
        CourseProgramDetails response = new CourseProgramDetails();
        for(hed__Course__c course: courses){
            response.recordId = course.Id;
            response.recordCode = course.Course_Code__c;
            response.recordType = course.RecordType.DeveloperName;
        }
        for(hed__Program_Plan__c program: programs){
            response.recordId = program.Id;
            response.recordCode = program.Code__c;
            response.recordType = program.RecordType.DeveloperName;
        }        
        return response;
    }

    /**
     * Generates code with a specific format based on record type
     * @param String recordType
     * @return String codeGenerated
     */
    @AuraEnabled
    public static String generateCode(String recordType){
        String codeGenerated = '';
        String numStr = '';
        String nameC = '';
        switch on recordType {
            when 'Activity'     { nameC = 'EXOA'; }
            when 'Module'       { nameC = 'EXOM'; }
            when 'Short_Course' { nameC = 'EXOS'; }
            when 'Program'      { nameC = 'EXOP'; }
            when else { nameC = ''; }
        }
        
        AggregateResult aggRes = [SELECT COUNT(Id) FROM Course_Code_Numbering__c WHERE Name__c =: recordType];
        Integer rowCount = Integer.valueOf(aggRes.get('expr0'));
        if(rowCount < 0){
            numStr = String.valueOf(1).leftPad(4,'0'); 
        }else{
            if(rowCount < 10000){  
                numStr = String.valueOf(rowCount + 1).leftPad(4,'0');    
            }else{
                numStr = String.valueOf(rowCount + 1);
            }   
        }
        
        codeGenerated = nameC + numStr; 
        List<Course_Code_Numbering__c> courseCodeNumbersToAdd = new List<Course_Code_Numbering__c>();
        Course_Code_Numbering__c courseCodeNumbering = new Course_Code_Numbering__c(
            Name = codeGenerated,
            Name__c = recordType,
            Number__c = numStr
        );
        courseCodeNumbersToAdd.add(courseCodeNumbering);
        insert courseCodeNumbersToAdd;
        
        return codeGenerated;
    }

    public class CourseProgramDetails{
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String recordType;
        @AuraEnabled
        public String recordCode;
    }        
}
