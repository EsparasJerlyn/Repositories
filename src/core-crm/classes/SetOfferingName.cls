/**
* @description helper to Set Course/Program Offering Name -- format: [course/programPlan_code] + '-' + [start_date yyyymmdd] + '-' + [number]
* @see CourseOffering, ProgramOffering TriggerHandlers
*
* @author Accenture
*
* @history
*
| Developer Email                | Date                  | JIRA                   | Change Summary               |
|--------------------------------|-----------------------|------------------------|------------------------------|
| Ana                            | 7/5/22                | DEPP-2545              | Created file                 |
|                                |                       |                        |                              |
*/
public with sharing class SetOfferingName {
    /**
* @description sets name of the Course/Program Offering with format[course/programPlan_code] + '-' + [start_date yyyymmdd] + '-' + [number]
* @param newItems - List of SObjects.Trigger.new
*/
    public static void setName(List<SObject> newItems) {
        Map<String, List<SObject>> parentIdOfferingMap = new Map<String, List<SObject>>();
        String sobjectname = String.valueOf(newItems[0].getSObjectType());
        String objType = sobjectname == 'hed__Course_Offering__c' ? 'hed__Course__c' : 'hed_Program_Plan__c';
        String startDateStr = sobjectname == 'hed__Course_Offering__c' ? 'hed__Start_Date__c' : 'Start_Date__c';
        String recName;
        
        for (SObject obj : newItems) {
            if(obj.get('Name') == null){
                if(parentIdOfferingMap.containsKey(String.valueOf(obj.get(objType)))){
                    parentIdOfferingMap.get(String.valueOf(obj.get(objType))).add(obj);
                }else{
                    parentIdOfferingMap.put(String.valueOf(obj.get(objType)), new List<SObject>{obj});
                }
            }
        }
        
        if(!parentIdOfferingMap.isEmpty()){
            if(sobjectname == 'hed__Course_Offering__c'){
                List<hed__course__c> courses = [Select Id, Course_Code__c,
                                                (Select Id, hed__Start_Date__c, Name from hed__Course_Offerings__r) 
                                                From hed__course__c Where Id IN :parentIdOfferingMap.keySet()];
                List<hed__Course_Offering__c> offerToUpdate;
                Map<String, Integer> existingNames = new Map<String, Integer>();
                List<String> nameSectioned;
                String newName;
                
                for(hed__course__c c: courses){
                    for(hed__Course_Offering__c offer: c.hed__Course_Offerings__r){
                        nameSectioned = offer.Name <> null ? offer.Name.split('-') : null;
                        if(nameSectioned.size() == 3 && (!existingNames.containsKey(nameSectioned[0]+'-'+nameSectioned[1]) ||
                                                         (existingNames.containsKey(nameSectioned[0]+'-'+nameSectioned[1]) && 
                                                          Integer.valueOf(nameSectioned[2]) > existingNames.get(nameSectioned[0]+'-'+nameSectioned[1])))){
                                                              existingNames.put(nameSectioned[0]+'-'+nameSectioned[1], Integer.valueOf(nameSectioned[2]));
                                                          }    
                    }
                    
                    offerToUpdate = (List<hed__Course_Offering__c>) parentIdOfferingMap.get(c.Id);
                    for(hed__Course_Offering__c offering: offerToUpdate){
                        newName = c.Course_Code__c + '-' + offering.hed__Start_Date__c.year() + 
                            String.valueOf(offering.hed__Start_Date__c.month()).leftPad(2,'0') + offering.hed__Start_Date__c.day();
                        
                        if(existingNames.containsKey(newName)){
                            offering.Name = newName + '-' + (existingNames.get(newName) + 1);
                        }else{
                            offering.Name = newName + '-' + 1;
                        }
                    }
                    
                    existingNames = new Map<String, Integer>();
                }
            }
            
            if(sobjectname == 'Program_Offering__c'){
                List<hed__Program_Plan__c> programs = [Select Id, Code__c,
                                                       (Select Id, Start_Date__c, Name from Program_Offering__r) 
                                                       From hed__Program_Plan__c Where Id IN :parentIdOfferingMap.keySet()];
                List<Program_Offering__c> offerToUpdate;
                Map<String, Integer> existingNames = new Map<String, Integer>();
                List<String> nameSectioned;
                String newName;
                
                for(hed__Program_Plan__c program: programs){
                    for(Program_Offering__c offer: program.Program_Offering__r){
                        nameSectioned = offer.Name <> null ? offer.Name.split('-') : null;
                        if(nameSectioned.size() == 3 && (!existingNames.containsKey(nameSectioned[0]+'-'+nameSectioned[1]) ||
                                                         (existingNames.containsKey(nameSectioned[0]+'-'+nameSectioned[1]) && 
                                                          Integer.valueOf(nameSectioned[2]) > existingNames.get(nameSectioned[0]+'-'+nameSectioned[1])))){
                                                              existingNames.put(nameSectioned[0]+'-'+nameSectioned[1], Integer.valueOf(nameSectioned[2]));
                                                          }    
                    }
                    
                    offerToUpdate = (List<Program_Offering__c>) parentIdOfferingMap.get(program.Id);
                    for(Program_Offering__c offering: offerToUpdate){
                        newName = program.Code__c + '-' + offering.Start_Date__c.year() + 
                            String.valueOf(offering.Start_Date__c.month()).leftPad(2,'0') + offering.Start_Date__c.day();
                        
                        if(existingNames.containsKey(newName)){
                            offering.Name = newName + '-' + (existingNames.get(newName) + 1);
                        }else{
                            offering.Name = newName + '-' + 1;
                        }
                    }
                    
                    existingNames = new Map<String, Integer>();
                }
            }
        }
    } 
}