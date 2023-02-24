List<Contact> contactList = [
    SELECT Id, Work_Email__c, hed__WorkEmail__c
    FROM Contact
    WHERE Work_Email__c = null AND hed__WorkEmail__c != null
    LIMIT 1000
];

System.debug(LoggingLevel.DEBUG, 'Size: '+contactList.size());//NOPMD

if(!contactList.isEmpty()){
    
    for(Contact record : contactList){
        record.Work_Email__c = record.hed__WorkEmail__c;
        System.debug(LoggingLevel.DEBUG, 'record.Work_Email__c: '+record.Work_Email__c);//NOPMD
    }
    update contactList;
}