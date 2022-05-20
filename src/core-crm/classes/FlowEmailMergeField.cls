/**
 * @description Data Transfer Object used to represent the parameters of merge fields
 *              to be used in Lightning Email Templates with values from Flow
 *
 * @author Accenture
 *
 * @history
 *    | Developer                 | Date                  | JIRA      | Change Summary                  |
      |---------------------------|-----------------------|-----------|---------------------------------|
      | angelika.j.s.galang       | April 22, 2022        | DEPP-2156 | Created file                    | 
      |                           |                       |           |                                 | 
*/
public without sharing class FlowEmailMergeField {
    /**
     * @description - merge field tag set in Lightning Email Template
     * e.g. {fullName}
     */
    @InvocableVariable @AuraEnabled
	public String mergeField;
    /**
     * @description - value of merge field retrieved from Flow
     */
	@InvocableVariable @AuraEnabled
	public String mergeFieldValue;
}
