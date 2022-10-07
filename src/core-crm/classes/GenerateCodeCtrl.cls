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
      | arsenio.jr.dayrit         | July 12, 2022         | DEPP-2337            | Added condition for CCE      |
      |                           |                       |                      | generate code                |
      | alexander.cadalin         | September 05, 2022    | DEPP-4094            | + OPE & CCE, PWP Code Gen    |
*/
public with sharing class GenerateCodeCtrl {

    /**
     * Retrieves Course or Program record based on product request.
     * @param String recordId
     * @return CourseProgramDetails
     */
    @AuraEnabled(cacheable=true)
    public static CourseProgramDetails getCourseAndProgDetails(String recordId){
        List<hed__Course__c> courses = [SELECT Id, Name, Course_Code__c, RecordType.DeveloperName, ProductRequestID__r.Name, ProductRequestID__r.Id, 
        ProductRequestID__r.Product_Specification__r.RecordType.DeveloperName FROM hed__Course__c WHERE ProductRequestID__c =: recordId LIMIT 1];
        
        List<hed__Program_Plan__c> programs = [SELECT Id, Name, Code__c, RecordType.DeveloperName, Product_Request__r.Name, Product_Request__r.Id, 
        Product_Request__r.Product_Specification__r.RecordType.DeveloperName FROM hed__Program_Plan__c WHERE Product_Request__c  =: recordId LIMIT 1];

        CourseProgramDetails response = new CourseProgramDetails();
        for(hed__Course__c course: courses){
            response.recordId = course.Id;
            response.recordCode = course.Course_Code__c;
            response.recordType = course.RecordType.DeveloperName;
            response.recordProgCourseName = course.Name;
            response.productSpecsRT = course.ProductRequestID__r.Product_Specification__r.RecordType.DeveloperName;
        }
        for(hed__Program_Plan__c program: programs){
            response.recordId = program.Id;
            response.recordCode = program.Code__c;
            response.recordType = program.RecordType.DeveloperName;
            response.recordProgCourseName = program.Name;
            response.productSpecsRT = program.Product_Request__r.Product_Specification__r.RecordType.DeveloperName;
        }        
        return response;
    }

    /**
     * Generates code with a specific format based on record type
     * @param String recordType
     * @param String prodSpecsRecordType
     * @return String codeGenerated
     */
    @AuraEnabled
    public static CourseProgramDetails generateCode(String recordType, String prodSpecsRecordType){
        CourseProgramDetails response = new CourseProgramDetails();
        String codeGenerated = '';
        String codePrefix = '';
        Decimal num;
        if(recordType == 'Activity'){  
            if(prodSpecsRecordType != 'OPE'){
                List<CCE_Activity_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM CCE_Activity_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
                for(CCE_Activity_Code_Generator__c codeGen : codeGenList){
                    response.recordId = codeGen.Id;
                    response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                    num = codeGen.Number__c;                
                }
                codePrefix = 'EXCA'; 
                
            }else{
                List<Activity_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM Activity_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
                for(Activity_Code_Generator__c codeGen : codeGenList){
                    response.recordId = codeGen.Id;
                    response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                    num = codeGen.Number__c;                
                }
                codePrefix = 'EXOA'; 
            }
            codeGenerated = getCode(codePrefix, num);   
            response.recordCode = codeGenerated;           
        } 
        
        if(recordType == 'Module'){
            if(prodSpecsRecordType != 'OPE'){
                List<CCE_Module_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM CCE_Module_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
                for(CCE_Module_Code_Generator__c codeGen : codeGenList){
                response.recordId = codeGen.Id;
                response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                num = codeGen.Number__c;                
            }
            codePrefix = 'EXCM'; 

            }else{
                List<Module_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM Module_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
                for(Module_Code_Generator__c codeGen : codeGenList){
                    response.recordId = codeGen.Id;
                    response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                    num = codeGen.Number__c;                
                }
                codePrefix = 'EXOM'; 
                
            }
            codeGenerated = getCode(codePrefix, num);    
            response.recordCode = codeGenerated;
        }
    

        if(recordType == 'Short_Course'){
            if(prodSpecsRecordType != 'OPE'){
                List<CCE_Short_Course_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM CCE_Short_Course_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
                for(CCE_Short_Course_Code_Generator__c codeGen : codeGenList){
                    response.recordId = codeGen.Id;
                    response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                    num = codeGen.Number__c;                
                }
                codePrefix = 'EXCS'; 
            }else{
                List<Short_Course_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM Short_Course_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
                for(Short_Course_Code_Generator__c codeGen : codeGenList){
                    response.recordId = codeGen.Id;
                    response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                    num = codeGen.Number__c;                
                }
                codePrefix = 'EXOS'; 
            }
            
            codeGenerated = getCode(codePrefix, num);   
            response.recordCode = codeGenerated;
        }
        
        if(recordType == 'Program'){  
            if(prodSpecsRecordType != 'OPE'){
                List<CCE_Program_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM CCE_Program_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
                for(CCE_Program_Code_Generator__c codeGen : codeGenList){
                    response.recordId = codeGen.Id;
                    response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                    num = codeGen.Number__c;                
                }
                codePrefix = 'EXCP'; 

            }else{
                List<Program_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM Program_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
                for(Program_Code_Generator__c codeGen : codeGenList){
                    response.recordId = codeGen.Id;
                    response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                    num = codeGen.Number__c;                
                }
                codePrefix = 'EXOP'; 
            }
            codeGenerated = getCode(codePrefix, num);    
            response.recordCode = codeGenerated;
        }

        if(recordType == 'Unit'){  
            List<CCE_Unit_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM CCE_Unit_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
            for(CCE_Unit_Code_Generator__c codeGen : codeGenList){
                response.recordId = codeGen.Id;
                response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                num = codeGen.Number__c;                
            }
            codePrefix = 'EXCU'; 
            codeGenerated = getCode(codePrefix, num);    
            response.recordCode = codeGenerated;
        }


        if(recordType == 'Group_Coaching'){  
            List<CCE_Coaching_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM CCE_Coaching_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
            for(CCE_Coaching_Code_Generator__c codeGen : codeGenList){
                response.recordId = codeGen.Id;
                response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                num = codeGen.Number__c;                
            }
            codePrefix = 'EXCG'; 
            codeGenerated = getCode(codePrefix, num);    
            response.recordCode = codeGenerated;
        } 

        if(recordType == 'Diagnostic_Tool'){  
            List<CCE_Diagnostic_Tool_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM CCE_Diagnostic_Tool_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
            for(CCE_Diagnostic_Tool_Code_Generator__c codeGen : codeGenList){
                response.recordId = codeGen.Id;
                response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                num = codeGen.Number__c;                
            }
            codePrefix = 'EXCD'; 
            codeGenerated = getCode(codePrefix, num);    
            response.recordCode = codeGenerated;
        }

        if(recordType == 'Individual_Coaching'){  
            List<CCE_Individual_Coaching_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM CCE_Individual_Coaching_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];  
            for(CCE_Individual_Coaching_Code_Generator__c codeGen : codeGenList){
                response.recordId = codeGen.Id;
                response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;                
                num = codeGen.Number__c;                
            }
            codePrefix = 'EXCI'; 
            codeGenerated = getCode(codePrefix, num);    
            response.recordCode = codeGenerated;
        } 

        if(recordType == 'Program_Without_Pathway') {
            if(prodSpecsRecordType != 'OPE'){
                List<CCE_PWP_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM CCE_PWP_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];
                for(CCE_PWP_Code_Generator__c codeGen : codeGenList) {
                    response.recordId = codeGen.Id;
                    response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;
                    num = codeGen.Number__c;
                }
                codePrefix = 'EXCPWP';
            } else {
                List<PWP_Code_Generator__c> codeGenList = [SELECT Id, Number__c FROM PWP_Code_Generator__c WHERE Type__c =: recordType LIMIT 1];
                for(PWP_Code_Generator__c codeGen : codeGenList) {
                    response.recordId = codeGen.Id;
                    response.recordNumber = Integer.valueOf(codeGen.Number__c) + 1;
                    num = codeGen.Number__c;
                }
                codePrefix = 'EXOPWP';
            }
            codeGenerated = getCode(codePrefix, num);
            response.recordCode = codeGenerated;
        }

        return response;
    }

    @AuraEnabled
    public static CourseProgramDetails getDuplicateDetails(String recordCode, String recordType){
        CourseProgramDetails response = new CourseProgramDetails();
        if(recordType != 'Program'){
            List<hed__Course__c> courses = [SELECT Name, ProductRequestID__r.Name, ProductRequestID__r.Id,ProductRequestID__r.Product_Specification__r.RecordType.DeveloperName  FROM hed__Course__c 
            WHERE Course_Code__c =: recordCode LIMIT 1];
            for(hed__Course__c course : courses){
                response.recordProdReqId = course.ProductRequestID__r.Id;       
                response.recordProdReqName = course.ProductRequestID__r.Name;
                response.recordProgCourseName = course.Name;                
            }
        }else{
            List<hed__Program_Plan__c> programs = [SELECT Name, Product_Request__r.Name, Product_Request__r.Id,  Product_Request__r.Product_Specification__r.RecordType.DeveloperName FROM hed__Program_Plan__c 
            WHERE Code__c =: recordCode LIMIT 1];
            for(hed__Program_Plan__c program : programs){
                response.recordProdReqId = program.Product_Request__r.Id;
                response.recordProdReqName = program.Product_Request__r.Name;
                response.recordProgCourseName = program.Name;    
            }
        }
        return response;
    }
    
    @AuraEnabled
    public static String updateCodeGenerator(String recordType, String recordId, Integer recordNumber, String recordCode, String prodSpecsRecordType){
        
        String response = '';
        if(recordType == 'Activity'){
            if(prodSpecsRecordType != 'OPE'){
              
                List<CCE_Activity_Code_Generator__c> codeGenList = new List<CCE_Activity_Code_Generator__c>();
                codeGenList.add(new CCE_Activity_Code_Generator__c(
                    Id = recordId,
                    Number__c = recordNumber,
                    Name = recordCode
                ));
                update codeGenList;
            }else{
                List<Activity_Code_Generator__c> codeGenList = new List<Activity_Code_Generator__c>();
                codeGenList.add(new Activity_Code_Generator__c(
                    Id = recordId,
                    Number__c = recordNumber,
                    Name = recordCode
                ));
                update codeGenList;
            }
        }

        if(recordType == 'Module'){
            if(prodSpecsRecordType != 'OPE'){
                List<CCE_Module_Code_Generator__c> codeGenList = new List<CCE_Module_Code_Generator__c>();
                codeGenList.add(new CCE_Module_Code_Generator__c(
                    Id = recordId, 
                    Number__c = recordNumber,
                    Name = recordCode
                ));
                update codeGenList;

            }else{

                List<Module_Code_Generator__c> codeGenList = new List<Module_Code_Generator__c>();
                codeGenList.add(new Module_Code_Generator__c(
                    Id = recordId, 
                    Number__c = recordNumber,
                    Name = recordCode
                ));
                update codeGenList;

            }
        }

        if(recordType == 'Short_Course'){
            if(prodSpecsRecordType != 'OPE'){
                List<CCE_Short_Course_Code_Generator__c> codeGenList = new List<CCE_Short_Course_Code_Generator__c>();
                codeGenList.add(new CCE_Short_Course_Code_Generator__c(
                    Id = recordId, 
                    Number__c = recordNumber,
                    Name = recordCode
                ));
                update codeGenList;

            }else{
                List<Short_Course_Code_Generator__c> codeGenList = new List<Short_Course_Code_Generator__c>();
                codeGenList.add(new Short_Course_Code_Generator__c(
                    Id = recordId, 
                    Number__c = recordNumber,
                    Name = recordCode
                ));
                update codeGenList;
            }
           
        }

        if(recordType == 'Program'){
            if(prodSpecsRecordType != 'OPE'){
                List<CCE_Program_Code_Generator__c> codeGenList = new List<CCE_Program_Code_Generator__c>();
                    codeGenList.add(new CCE_Program_Code_Generator__c(
                    Id = recordId, 
                    Number__c = recordNumber,
                    Name = recordCode
                ));
                update codeGenList;
            }else{
                List<Program_Code_Generator__c> codeGenList = new List<Program_Code_Generator__c>();
                codeGenList.add(new Program_Code_Generator__c(
                    Id = recordId, 
                    Number__c = recordNumber,
                    Name = recordCode
                ));
                update codeGenList;
            }
        }

        if(recordType == 'Unit'){
            List<CCE_Unit_Code_Generator__c> codeGenList = new List<CCE_Unit_Code_Generator__c>();
            codeGenList.add(new CCE_Unit_Code_Generator__c(
                Id = recordId, 
                Number__c = recordNumber,
                Name = recordCode
            ));
            update codeGenList;
        }  

        if(recordType == 'Group_Coaching'){
            List<CCE_Coaching_Code_Generator__c> codeGenList = new List<CCE_Coaching_Code_Generator__c>();
            codeGenList.add(new CCE_Coaching_Code_Generator__c(
                Id = recordId, 
                Number__c = recordNumber,
                Name = recordCode
            ));
            update codeGenList;
        }

        if(recordType == 'Diagnostic_Tool'){
            List<CCE_Diagnostic_Tool_Code_Generator__c> codeGenList = new List<CCE_Diagnostic_Tool_Code_Generator__c>();
            codeGenList.add(new CCE_Diagnostic_Tool_Code_Generator__c(
                Id = recordId, 
                Number__c = recordNumber,
                Name = recordCode
            ));
            update codeGenList;
        }
    
        if(recordType == 'Individual_Coaching'){
            List<CCE_Individual_Coaching_Code_Generator__c> codeGenList = new List<CCE_Individual_Coaching_Code_Generator__c>();
            codeGenList.add(new CCE_Individual_Coaching_Code_Generator__c(
                Id = recordId, 
                Number__c = recordNumber,
                Name = recordCode
            ));
            update codeGenList;
        }
        
        if(recordType == 'Program_Without_Pathway') {
            if(prodSpecsRecordType != 'OPE') {
                List<CCE_PWP_Code_Generator__c> codeGenList = new List<CCE_PWP_Code_Generator__c>();
                codeGenList.add(new CCE_PWP_Code_Generator__c(
                    Id = recordId,
                    Number__c = recordNumber,
                    Name = recordCode
                ));
                update codeGenList;
            } else {
                List<PWP_Code_Generator__c> codeGenList = new List<PWP_Code_Generator__c>();
                codeGenList.add(new PWP_Code_Generator__c(
                    Id = recordId,
                    Number__c = recordNumber,
                    Name = recordCode
                ));
                update codeGenList;
            }
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
        @AuraEnabled
        public String productSpecsRT;
    } 
}
