/**
 * @description Trigger Event Listener for Outreach Communication Processed Platform Event 
 * @see OutreachCommunicationProcessedEventListener
 *
 * @author Accenture
 *
 * @history
 *    | Developer Email                | Date                  | JIRA                   | Change Summary               |
      |--------------------------------|-----------------------|------------------------|------------------------------|
      | mark.j.mahilum                 | May 21, 2024          | DEPP-8823              | Created file                 |
 */
trigger OutreachCommunicationProcessedEventListener on Communication_Processed__e (after insert) {
      
    OutreachCommunicationProcessedHandler outreachEvent = new OutreachCommunicationProcessedHandler(Trigger.new);
    outreachEvent.handle();

}