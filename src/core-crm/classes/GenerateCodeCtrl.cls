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
      | eccarius.karl.munoz       | June 28, 2022         | DEPP-3272            | Created Custom Settings per  |
      |                           |                       |                      | per record type.             |
      |                           |                       |                      |                              |
      |                           |                       |                      | Removed saving of multiple   |
      |                           |                       |                      | records into the custom      |
      |                           |                       |                      | settings.                    |
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
        List<hed__Course__c> courses = [SELECT Id, Name, Course_Code__c, RecordType.DeveloperName, ProductRequestID__r.Name, ProductRequestID__r.Id FROM hed__Course__c WHERE ProductRequestID__c =: recordId LIMIT 1];
        List<hed__Program_Plan__c> programs = [SELECT Id, Name, Code__c, RecordType.DeveloperName, Product_Request__r.Name, Product_Request__r.Id FROM hed__Program_Plan__c WHERE Product_Request__c  =: recordId LIMIT 1];
        CourseProgramDetails response = new CourseProgramDetails();
        for(hed__Course__c course: courses){
            response.recordId = course.Id;
            response.recordCode = course.Course_Code__c;
            response.recordType = course.RecordType.DeveloperName;
            response.recordProgCourseName = course.Name;
        }
        for(hed__Program_Plan__c program: programs){
            response.recordId = program.Id;
            response.recordCode = program.Code__c;
            response.recordType = program.RecordType.DeveloperName;
            response.recordProgCourseName = program.Name;
        }        
        return response;
    }

    /**
     * Generates code with a specific format based on record type
     * @param String recordType
     * @return String codeGenerated
     */
    @AuraEnabled
    public static CourseProgramDetails generateCode(String recordType){
        CourseProgramDetails response = new CourseProgramDetails();
        String codeGenerated = '';
        String codePrefix = '';
        Decimal num;
        if(recordType == 'Activity'){  
            List<Activity_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM Activity_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
            for(Activity_Code_Generator__c codeGen : codeGenList){
                response.recordId = codeGen.Id;
                response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                num = codeGen.Number__c;                
            }
            codePrefix = 'EXOA'; 
            codeGenerated = getCode(codePrefix, num);    
            response.recordCode = codeGenerated;
        } 
        
        if(recordType == 'Module'){  
            List<Module_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM Module_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
            for(Module_Code_Generator__c codeGen : codeGenList){
                response.recordId = codeGen.Id;
                response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                num = codeGen.Number__c;                
            }
            codePrefix = 'EXOM'; 
            codeGenerated = getCode(codePrefix, num);    
            response.recordCode = codeGenerated;
        }

        if(recordType == 'Short_Course'){  
            List<Short_Course_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM Short_Course_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
            for(Short_Course_Code_Generator__c codeGen : codeGenList){
                response.recordId = codeGen.Id;
                response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                num = codeGen.Number__c;                
            }
            codePrefix = 'EXOS'; 
            codeGenerated = getCode(codePrefix, num);   
            response.recordCode = codeGenerated;
        }
        
        if(recordType == 'Program'){  
            List<Program_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM Program_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
            for(Program_Code_Generator__c codeGen : codeGenList){
                response.recordId = codeGen.Id;
                response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                num = codeGen.Number__c;                
            }
            codePrefix = 'EXOP'; 
            codeGenerated = getCode(codePrefix, num);    
            response.recordCode = codeGenerated;
        }
        
        return response;
    }

    @AuraEnabled
    public static CourseProgramDetails getDuplicateDetails(String recordCode, String recordType){
        CourseProgramDetails response = new CourseProgramDetails();
        if(recordType != 'Program'){
            List<hed__Course__c> courses = [SELECT Name, ProductRequestID__r.Name, ProductRequestID__r.Id FROM hed__Course__c WHERE Course_Code__c =: recordCode LIMIT 1];
            for(hed__Course__c course : courses){
                response.recordProdReqId = course.ProductRequestID__r.Id;
                response.recordProdReqName = course.ProductRequestID__r.Name;
                response.recordProgCourseName = course.Name;                
            }
        }else{
            List<hed__Program_Plan__c> programs = [SELECT Name, Product_Request__r.Name, Product_Request__r.Id FROM hed__Program_Plan__c WHERE Code__c =: recordCode LIMIT 1];
            for(hed__Program_Plan__c program : programs){
                response.recordProdReqId = program.Product_Request__r.Id;
                response.recordProdReqName = program.Product_Request__r.Name;
                response.recordProgCourseName = program.Name;    
            }
        }
        return response;
    }
    
    @AuraEnabled
    public static String updateCodeGenerator(String recordType, String recordId, Integer recordNumber, String recordCode){
        
        String response = '';

        if(recordType == 'Activity'){
            List<Activity_Code_Generator__c> codeGenList = new List<Activity_Code_Generator__c>();
            codeGenList.add(new Activity_Code_Generator__c(
                Id = recordId, 
                Number__c = recordNumber,
                Name = recordCode
            ));
            update codeGenList;
        }   

        if(recordType == 'Module'){
            List<Module_Code_Generator__c> codeGenList = new List<Module_Code_Generator__c>();
            codeGenList.add(new Module_Code_Generator__c(
                Id = recordId, 
                Number__c = recordNumber,
                Name = recordCode
            ));
            update codeGenList;
        }

        if(recordType == 'Short_Course'){
            List<Short_Course_Code_Generator__c> codeGenList = new List<Short_Course_Code_Generator__c>();
            codeGenList.add(new Short_Course_Code_Generator__c(
                Id = recordId, 
                Number__c = recordNumber,
                Name = recordCode
            ));
            update codeGenList;
        }

        if(recordType == 'Program'){
            List<Program_Code_Generator__c> codeGenList = new List<Program_Code_Generator__c>();
            codeGenList.add(new Program_Code_Generator__c(
                Id = recordId, 
                Number__c = recordNumber,
                Name = recordCode
            ));
            update codeGenList;
        }
        
        
        response = 'Success';

        return response;
    }

    private static String getCode(String codePrefix, Decimal num){
        String numStr = '';
        Integer latestNum = Integer.valueOf(num);
        if(latestNum < 0){
            numStr = String.valueOf(1).leftPad(4,'0');
        }else{
            if(latestNum < 10000){  
                numStr = String.valueOf(latestNum + 1).leftPad(4,'0');    
            }else{
                numStr = String.valueOf(latestNum + 1);
            }   
        }
        return codePrefix + numStr; 
        
    }

    public class CourseProgramDetails{
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String recordType;
        @AuraEnabled
        public String recordCode;
        @AuraEnabled
        public Decimal recordNumber;
        @AuraEnabled
        public String recordProgCourseName;
        @AuraEnabled
        public String recordProdReqName;
        @AuraEnabled
        public String recordProdReqId;
    } 
}
