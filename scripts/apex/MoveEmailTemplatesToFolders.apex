// DEPP-4643

static final String SYSTEM_TEMPLATES_FOLDER_NAME = 'QUTeX System Templates';
static final String OPERATIONAL_TEMPLATES_FOLDER_NAME = 'QUTeX Operational Templates';
List<EmailTemplate> templates = [SELECT Id, FolderId, CreatedById FROM EmailTemplate WHERE UiType = 'SFX'];
List<Folder> fldrs = [SELECT Id, Name FROM Folder WHERE Name IN (:SYSTEM_TEMPLATES_FOLDER_NAME, :OPERATIONAL_TEMPLATES_FOLDER_NAME)];
Map<String, Id> mapFldrNameToId = new Map<String, Id>();
for(Folder fldr : fldrs) {
    mapFldrNameToId.put(fldr.Name, fldr.Id);
}
Id CICDIntegUser = [SELECT Id FROM User WHERE Name = 'CICD Integration User' LIMIT 1].Id;
for(EmailTemplate template : templates) {
    template.FolderId = template.CreatedById == CICDIntegUser ? 
        mapFldrNameToId.get(SYSTEM_TEMPLATES_FOLDER_NAME) : mapFldrNameToId.get(OPERATIONAL_TEMPLATES_FOLDER_NAME);
}
Savepoint sp = Database.setSavepoint();
Database.SaveResult[] sr = Database.update(templates, false);
Integer failed = 0;
for(Database.SaveResult res : sr) {
    failed = res.isSuccess() ? failed : failed + 1;
}
if(failed != 0) {
    System.debug('Failed records: ' + failed + '/' + sr.size());
    Database.rollback(sp);
    System.debug('Rolled back.');
} else {
    System.debug('All records okay.');
}