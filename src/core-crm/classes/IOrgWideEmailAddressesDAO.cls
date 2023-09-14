/**
 * @description Interface for OrgWideEmailAddressesDAO
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | August 31, 2023       | DEPP-6138              | Created file                 |
      |                                |                       |                        |                              |
 */
public interface IOrgWideEmailAddressesDAO extends DmlInterface{

    OrgWideEmailAddress getOrgWideEmailAddressByDisplayName(
        String displayName, 
        String accessLevel
    );
    
}