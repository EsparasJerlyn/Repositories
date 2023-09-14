// DEPP-6570: Separate Future Student roles for Domestic and International

// Get Future Students Public Group Record Ids
Id fsDomPubGrpRecId = [
    SELECT Id FROM Group
    WHERE DeveloperName = 'Future_Students_Domestic'
    AND Type = 'Regular' LIMIT 1].Id;

Id fsIntPubGrpRecId = [
    SELECT Id FROM Group
    WHERE DeveloperName = 'Future_Students_International'
    AND Type = 'Regular' LIMIT 1].Id;

// Get Future Student Role Record Ids
List<Group> fsDomRoleId = [
    SELECT Id FROM Group 
    WHERE DeveloperName LIKE 'Future_Student_%_Domestic' 
    AND Type = 'Role'];

List<Group> fsIntRoleId = [
    SELECT Id FROM Group 
    WHERE DeveloperName LIKE 'Future_Student_%_International' 
    AND Type = 'Role'];

// Assign roles to respective public groups
List<GroupMember> grpMbrList = new List<GroupMember>();

for (Group grp : fsDomRoleId) {
    GroupMember grpMbr = new GroupMember(
        GroupId = fsDomPubGrpRecId, 
        UserOrGroupId = grp.Id);
    grpMbrList.add(grpMbr);
}

for (Group grp : fsIntRoleId) {
    GroupMember grpMbr = new GroupMember(
        GroupId = fsIntPubGrpRecId, 
        UserOrGroupId = grp.Id);
    grpMbrList.add(grpMbr);
}

if(!grpMbrList.isEmpty()){
    Database.SaveResult[] srList = Database.insert(grpMbrList, false);
    for (Database.SaveResult result : srList){
        if(result.isSuccess()){
            System.debug('Successfully added Future Student roles to Future Student public groups.');
        }else{
            System.debug('Database error in adding Future Student roles to Future Student public groups: ' + result.getErrors());
        }            
    }
}