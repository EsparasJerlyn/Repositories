/**
 * @description A new lightning component to navigate to detail page automatically
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                 |
 *    |--------------------------------|-----------------------|------------------------|--------------------------------|
 *    | ryan.j.a.dela.cruz             | June 5, 2023          | DEPP-5385              | Created file                   |
 */
({
  invoke: function (component, event, helper) {
    // Get the record ID attribute
    var record = component.get("v.recordId");

    // Get the Lightning event that opens a record in a new tab
    var redirect = $A.get("e.force:navigateToSObject");

    // Pass the record ID to the event
    redirect.setParams({
      recordId: record
    });

    // Open the record
    redirect.fire();
  }
});
