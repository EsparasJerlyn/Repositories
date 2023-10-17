/**
 * @description Model Class for Program Engagement Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | October 05, 2023      | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreConfigProgEngagment extends LeadScoreConfigBaseModel{
    private Integer programEngAttendance = 0;

    public Integer getProgramEngAttendance() {
        return programEngAttendance;
    }

    public void setProgramEngAttendance(Integer programEngAttendance) {
        this.programEngAttendance = programEngAttendance;
    }

}