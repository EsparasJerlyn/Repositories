/**
 * @description Model Class for Event Registration Lead Score Configuration
 * 
 * @author Accenture
 *
 * @history
 *
 *    | Developer                      | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | eccarius.munoz                 | September 22, 2023    | DEPP-5866              | Created file                 |
      |                                |                       |                        |                              |
 */
public with sharing class LeadScoreConfigEventRegistration extends LeadScoreConfigBaseModel{

    private Integer eventRegOpenDayReg = 0;
    private Integer eventRegOtherEventReg = 0;
    private Integer eventRegOtherEventAttendance = 0;

    public Integer getEventRegOpenDayReg() {
        return eventRegOpenDayReg;
    }

    public void setEventRegOpenDayReg(Integer eventRegOpenDayReg) {
        this.eventRegOpenDayReg = eventRegOpenDayReg;
    }

    public Integer getEventRegOtherEventReg() {
        return eventRegOtherEventReg;
    }

    public void setEventRegOtherEventReg(Integer eventRegOtherEventReg) {
        this.eventRegOtherEventReg = eventRegOtherEventReg;
    }

    public Integer getEventRegOtherEventAttendance() {
        return eventRegOtherEventAttendance;
    }

    public void setEventRegOtherEventAttendance(Integer eventRegOtherEventAttendance) {
        this.eventRegOtherEventAttendance = eventRegOtherEventAttendance;
    }

}