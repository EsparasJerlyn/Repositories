/**
 * @description Interface for LeadStatus DAO
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | alexander.cadalin              | Jan 03, 2024          | n/a                    | Created file
 */
public interface ILeadStatusesDAO extends DmlInterface {
    LeadStatus getConvertedLeadStatus(AccessLevel accessLevel);
} 
