/**
 * @description Common Utility Class
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                 | Change Summary               |
      |--------------------------------|-----------------------|----------------------|------------------------------|
      | marygrace.li@qut.edu.au        | December 9, 2021      | DEPP-174             | Created file                 | 
      |                                |                       |                      |                              | 
 */
public with sharing class CommonUtils {

    /**
     * @description Generates Random String
     * @param totalStrLimit - total string limit
     * @return randStr - randomString
     */
    public static String randomString( Integer totalStrLimit ) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';

        while (randStr.length() < totalStrLimit) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
}