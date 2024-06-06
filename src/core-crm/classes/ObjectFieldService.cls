/**
 * @description Service Class for Dynamic Object and Field checking or validation methods
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                                            |
      |--------------------------------|-----------------------|------------------------|-----------------------------------------------------------|
      | roy.nino.s.regala              | Jan 11, 2024          | DEPP-7142              | Created File                                              |
 */
public inherited sharing class ObjectFieldService {
    /**
     * @description Method that checks if one of the fields(Api Name) between two records is different
     * @param {Set<String>} fields -  A set of field Api Names of an object
     * @param SObject newRecord - An Sobject type of a new record
     * @param SObject oldRecord - An Sobject type of a old record
     * @return boolean - returns true if one field of a new record is not the same with the old record
     */
    public static boolean isOneOftheFieldsUpdated(
        Set<String> fields,
        SObject newRecord,
        SObject oldRecord
    ) {
        for (String field : fields) {
            if (newRecord.get(field) != oldRecord.get(field)) {
                return true;
            }
        }
        return false;
    }

    /**
     * @description Method that checks if any of the fields(Api Name) of a new record is populated or is boolean true
     * @param {Set<String>} fields -  A set of field Api Names of an object
     * @param SObject newRecord - An Sobject type of a new record
     * @return boolean - returns true if one field of a new record is populated or if boolean field is true
     */
    public static boolean isOneOfTheFieldsNotBlankAndNotBooleanFalse(
        Set<String> fields,
        SObject newRecord
    ) {
        for (String field : fields) {
            if (newRecord.get(field) != null && newRecord.get(field) != false) {
                return true;
            }
        }
        return false;
    }
}
