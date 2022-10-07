Id GENERAL_SESSION_REC_TYPE = Schema.SObjectType.Session__c.getRecordTypeInfosByName()
                            .get(Label.RT_Session_General_Session)
                            .getRecordTypeId();
List<Session__c> sessionList = [SELECT Id, RecordTypeId FROM Session__c WHERE RecordTypeId = null];

system.debug('Size: '+ sessionList.size());

if(!sessionList.isEmpty()){
    for(Session__c record : sessionList){
        record.RecordTypeId = GENERAL_SESSION_REC_TYPE;
        system.debug('record.RecordTypeId: '+ record.RecordTypeId);
    }
    update sessionList;
}