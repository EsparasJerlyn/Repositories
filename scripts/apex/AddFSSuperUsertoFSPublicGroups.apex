// Future Students Public Group Record Ids
List<Group> fsPubGrpRecIds = [
    SELECT Id FROM Group
    WHERE DeveloperName IN ('Future_Students_International', 'Future_Students_Domestic')
    AND Type = 'Regular'];

// Future Student Super User Role Record Id
Id fssuRoleId = [
    SELECT Id FROM Group 
    WHERE DeveloperName = 'Future_Student_Super_User' 
    AND Type = 'Role' 
    LIMIT 1].Id;

List<GroupMember> grpMbrList = new List<GroupMember>();

for (Group grp : fsPubGrpRecIds) {
    GroupMember grpMbr = new GroupMember(
        GroupId = grp.Id, 
        UserOrGroupId = fssuRoleId);
    grpMbrList.add(grpMbr);
}

try {
    insert grpMbrList;
} catch(DmlException dmlE) {
    System.debug(LoggingLevel.ERROR, 'A DML Exception occured: ' + dmlE.getMessage());
}