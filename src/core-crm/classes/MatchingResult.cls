/**
 * Represents the result of a contact matching process.
 * Contains information about any error encountered, the associated contact record, and the type of matching performed.
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
 *    |--------------------------------|-----------------------|------------------------|------------------------------|
 *    | roy.nino.s.regala              | April 10, 2024        | DEPP-7986              | Created file                 |
 */
public class MatchingResult {
    
    // The type of matching performed e.g.
    // System Key Matching
    // Natural Key Matching
    // Partial Natural Key Matching
    // Maiden Name Matching
    // First Name Stem Matching
    // No DOB Matching
    public String matchingType { get; set; }

    public boolean error {get; set; }

    // Multiple match found
    // Contact Record does not match email and/or mobile provided
    // Insufficient information to match
    public String errorMessage {get; set; }

    public Set<Id> contactIds {get; set; }
    
    public MatchingResult(Set<Contact> matchingContacts, String matchingType) {
        Integer matchCount = matchingContacts.size();

        this.errorMessage = matchCount > 1?'Multiple match found':'';
        this.error = matchCount > 1;
        this.matchingType = matchingType;

        this.contactIds = new Set<Id>();
        for(Contact con: matchingContacts){
            this.contactIds.add(con.Id);
        }    
    }

    public MatchingResult(String matchingType, String errorMessage) {
        this.contactIds = new Set<Id>();
        this.matchingType = matchingType;
        this.errorMessage = errorMessage;
        this.error = String.isNotBlank(errorMessage);
    }
}
