/**
 * @description Class to insert virutal users for test classes
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA                | Change Summary                                                          |
 *    |---------------------------|-----------------------|---------------------|-------------------------------------------------------------------------|
 *    | Julie                     | April 16, 2024        | DEP1-8016           | Created file                                                            |
 **/

@isTest
public class InsertUsersQueueable implements Queueable {
    
    private List<UserDTO> userDTOs;
    
    public InsertUsersQueueable(List<UserDTO> userDTOs) {
        this.userDTOs = userDTOs;
    }
    
    public void execute(QueueableContext context) {
        List<User> usersToInsert = new List<User>();
        Set<PermissionSetLicenseAssign> permissionSetLicenceAssignmentSet = new Set<PermissionSetLicenseAssign>();
        Set<PermissionSetAssignment> permissionSetAssignmentSet = new Set<PermissionSetAssignment>();
        Set<GroupMember> groupMemberSet = new Set<GroupMember>();
        
        // Get permission sets to be 
        

        List<String> permissionsetLicenceNames = new List<String>();
        List<String> permissionSetNames = new List<String>();
        List<String> permissionSetGroupNames = new List<String>();
        List<String> publicGroupNames = new List<String>();
        List<String> profiles = new List<String>();
        List<String> roles = new List<String>();
        
        for (UserDTO userDTO : userDTOs) {

            if(userDTO.permissionsetLicenceNames != null) {
                permissionsetLicenceNames.addAll(userDTO.permissionsetLicenceNames);
            }

            if(userDTO.permissionSetNames != null) {
                permissionSetNames.addAll(userDTO.permissionSetNames);
            }
            
            if(userDTO.permissionsetGroupNames != null) {
                permissionSetGroupNames.addAll(userDTO.permissionsetGroupNames);
            }
            
            if(userDTO.publicGroupNames != null) {
                publicGroupNames.addAll(userDTO.publicGroupNames);
            }
            
            profiles.add(userDTO.profileName);
            roles.add(userDTO.role);
        }
        
        // Get profiles using Name-to-Profile map
        Map<String, Id> profileNameToId = new Map<String, Id>();
        for (Profile profile : [SELECT Id, Name FROM Profile WHERE Name IN :profiles]) {
            profileNameToId.put(profile.Name, profile.Id);
        }
        
        // Get roles using Name-to-UserRole map
        Map<String, Id> roleNameToId = new Map<String, Id>();
        for (UserRole role : [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName IN :roles]) {
            roleNameToId.put(role.DeveloperName, role.Id);
        }
        
        
        // Get permissionsetLicenceNames using Name-to-ps map
        Map<String, PermissionSetLicense> permissionsetLicenceNameNameToRecord = new Map<String, PermissionSetLicense>();
        for (PermissionSetLicense permSet : [SELECT Id, DeveloperName FROM PermissionSetLicense WHERE DeveloperName IN :permissionsetLicenceNames]) {
            permissionsetLicenceNameNameToRecord.put(permSet.DeveloperName, permSet);
        }
        
        // Get permissionSets using Name-to-ps map
        Map<String, PermissionSet> permissionSetNameToRecord = new Map<String, PermissionSet>();
        for (PermissionSet permSet : [SELECT Id, Name FROM PermissionSet WHERE Name IN :permissionSetNames]) {
            permissionSetNameToRecord.put(permSet.Name, permSet);
        }
        
        // Get permissionSetGroups using Name-to-psg map
        Map<String, PermissionSetGroup> permissionSetGroupNameToRecord = new Map<String, PermissionSetGroup>();
        for (PermissionSetGroup permSetGroup : [SELECT Id, DeveloperName, Status FROM PermissionSetGroup WHERE DeveloperName IN :permissionSetGroupNames]) {
            if (permSetGroup.Status != 'Updated') {
                Test.calculatePermissionSetGroup(permSetGroup.Id);
            }
            permissionSetGroupNameToRecord.put(permSetGroup.DeveloperName, permSetGroup);
        }
        
        // Get public groups using Name-to-pg map
        Map<String, Group> groupToRecord = new Map<String, Group>();
        for (Group g : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN :publicGroupNames]) {
            groupToRecord.put(g.DeveloperName, g);
        }
        
        Map<String, UserDTO> userNameToUserDTO = new Map<String, UserDTO>();
        // Prepare users
        for (UserDTO userDTO : userDTOs) {
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String uid = h.SubString(0,8);
            
            User futureUser = new User(
                firstname = userDTO.firstName,
                lastname = userDTO.lastName,
                QUT_Persona__c = userDTO.Persona,
                alias = uid,
                email = userDTO.firstName + userDTO.lastName +'@mailinator.com',
                emailencodingkey = 'UTF-8',
                languagelocalekey = 'en_US',
                localesidkey = 'en_AU',
                profileid = profileNameToId.get(userDTO.profileName),
                userroleid = roleNameToId.get(userDTO.role),
                timezonesidkey = 'Australia/Brisbane',
                ContactId = userDTO.contactId,
                username = userDTO.firstName + userDTO.lastName + Math.random() + '@mailinator.com',
                userpermissionsmarketinguser = userDTO.userpermissionsmarketinguser,
                userpermissionsofflineuser = userDTO.userpermissionsofflineuser,
                userpermissionsinteractionuser = userDTO.userpermissionsflowuser,
                userpermissionsknowledgeuser = userDTO.userpermissionsknowledgeuser,
                UserPermissionsSupportUser = userDTO.userpermissionsserviceuser
            );
            usersToInsert.add(futureUser);

            userNameToUserDTO.put(futureUser.username, userDTO);
        }
        
        insert usersToInsert;
        
        // Aassign the perm sets, perm set groups, public groups
        for (User usr : usersToInsert) {
            UserDTO userDTO = userNameToUserDTO.get(usr.username);
            
            if (userDTO.permissionSetLicenceNames != null && !userDTO.permissionSetLicenceNames.isEmpty()) {
                for (String permSetLicenceName : userDTO.permissionSetLicenceNames) {
                    PermissionSetLicense permSetLicence = permissionsetLicenceNameNameToRecord.get(permSetLicenceName);
                    if(permSetLicence != null){
                        permissionSetLicenceAssignmentSet.add(new permissionSetLicenseAssign(PermissionSetLicenseId = permSetLicence.Id, AssigneeId = usr.Id));
                    }
                }
            }

            if (userDTO.permissionSetNames != null && !userDTO.permissionSetNames.isEmpty()) {
                for (String permSetName : userDTO.permissionSetNames) {
                    PermissionSet permSet = permissionSetNameToRecord.get(permSetName);
                    if (permSet != null){
                        permissionSetAssignmentSet.add(new PermissionSetAssignment(PermissionSetId = permSet.Id, AssigneeId = usr.Id));
                    }
                }
            }
            
            if (userDTO.permissionsetGroupNames != null && !userDTO.permissionsetGroupNames.isEmpty()) {
                for (String permSetGroupName : userDTO.permissionsetGroupNames) {
                    PermissionSetGroup permSetGroup = permissionSetGroupNameToRecord.get(permSetGroupName);
                    if (permSetGroup != null){
                        permissionSetAssignmentSet.add(new PermissionSetAssignment(PermissionSetGroupId = permSetGroup.Id, AssigneeId = usr.Id));
                    } 
                }
            }
            
            if (userDTO.publicGroupNames != null && !userDTO.publicGroupNames.isEmpty()) {
                for (String publicGroupName : userDTO.publicGroupNames) {
                    Group pGroup = groupToRecord.get(publicGroupName);
                    if (pGroup != null){
                        groupMemberSet.add(new GroupMember(GroupId = pGroup.Id, UserOrGroupId = usr.Id));
                    }
                }
            }
           
        }

        List<PermissionSetLicenseAssign> permissionSetLicenceAssignList = new List<PermissionSetLicenseAssign>(permissionSetLicenceAssignmentSet);
        List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>(permissionSetAssignmentSet);
        List<GroupMember> groupMemberList = new List<GroupMember>(groupMemberSet);
        
        insert permissionSetLicenceAssignList;
        insert permissionSetAssignmentList;
        insert groupMemberList;
        
    }
    
    public class UserDTO {
        public boolean userpermissionsmarketinguser {get; set;}
        public boolean userpermissionsofflineuser {get; set;}
        public boolean userpermissionsflowuser {get; set;}
        public boolean userpermissionsknowledgeuser {get; set;}
        public boolean userpermissionsserviceuser {get; set;}

        public String profileName {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String role {get; set;}
        public String contactId {get; set;}
        public String persona {get; set;}
        
        public Set<String> permissionsetLicenceNames {get; set;}
        public Set<String> permissionsetNames {get; set;}
        public Set<String> permissionsetGroupNames {get; set;}
        public Set<String> publicGroupNames {get; set;}
    }
    
    @isTest
    static void userCreationTest() {
        UserDTO usr = new UserDTO();
        
        usr.FirstName = 'Test';
        usr.LastName = 'SystemAdministratorTestClass';
        usr.profileName = 'System Administrator';
        usr.Persona = 'System Administrator';
        
        usr.permissionsetGroupNames = new Set<String>{'Persona_System_Administrator'};
        usr.publicGroupNames = new Set<String>{'System_Administrator'};
        List<UserDTO> usersListToCreate = new List<UserDTO>{usr};
        
        Test.startTest();
        InsertUsersQueueable uQ = new InsertUsersQueueable(usersListToCreate);
        System.enqueueJob(uq);
        Test.stopTest();
        
        User systemAdminUser = [SELECT Id FROM User WHERE FirstName = 'Test' AND LastName = 'SystemAdministratorTestClass' LIMIT 1];
        
        Assert.areNotEqual(null, systemAdminUser, 'System Administrator Test User');
    }
}