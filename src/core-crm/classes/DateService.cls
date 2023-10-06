/**
 * @description Service Class for any logic involving Dates
 * 
 * @see CaseService
 * 
 * @author Accenture
 * 
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                |
 *    |--------------------------------|-----------------------|------------------------|-------------------------------|
 *    | roy.nino.s.regala              | October 05,2023       | DEPP-6426	            | Created File                  | 
 */
public inherited sharing class DateService {

    public static Boolean isDateWithinRange(Date fromDate, Date toDate, Date dateToCheck) {
        Boolean trueSoFar = true;
        if (fromDate != null && toDate != null) {
            trueSoFar = fromDate < dateToCheck && toDate > dateToCheck;
        }
        return trueSoFar;
    }
    
}