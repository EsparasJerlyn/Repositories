// International Recruitment Public Group Record Id
Id intRecId = [
    SELECT Id FROM Group
    WHERE DeveloperName = 'International_Recruitment'
    AND Type = 'Regular'
    LIMIT 1].Id;

// Roles and Internal Subordinates: International Super User Group Record Id
Id risIsuId = [
    SELECT Id FROM Group 
    WHERE DeveloperName = 'International_Super_User' 
    AND Type = 'RoleAndSubordinatesInternal' 
    LIMIT 1].Id;

GroupMember grpMbr = new GroupMember(
    GroupId = intRecId, 
    UserOrGroupId = risIsuId);
try {
    insert grpMbr;
} catch(DmlException dmlE) {
    System.debug(LoggingLevel.ERROR, 'A DML Exception occured: ' + dmlE.getMessage());
}