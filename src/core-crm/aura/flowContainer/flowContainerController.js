/**
 * @description A dynamic container for flows with a standard look and feel ui
 *
 * @author Accenture
 *
 * @history
 *
 *    | Developer Email                | Date                  | JIRA                   | Change Summary                              |
 *    |--------------------------------|-----------------------|------------------------|---------------------------------------------|
 *    | ryan.j.a.dela.cruz             | June 6, 2023          | DEPP-5385              | Created file                                |
 *    | ryan.j.a.dela.cruz             | August 3, 2023        | DEPP-6093              | Added sessionStorage cleanup on close tab   |
 *    | ryan.j.a.dela.cruz             | August 9, 2023        | DEPP-6082              | Added sessionStorage cleanup for LOOKUP     |
 */
({
  init: function (component) {
    const flow = component.find("flowData");
    const flowApiName = component.get("v.flowApiName");
    const inputVariables = component.get("v.inputVariables");

    // Start the flow with input variables if they are provided
    if (inputVariables && inputVariables.length > 0) {
      flow.startFlow(flowApiName, inputVariables);
    } else {
      flow.startFlow(flowApiName);
    }
  },
  handleStatusChange: function (component, event) {
    // Get the status parameter from the event
    const status = event.getParam("status");

    if (status === "STARTED") {
      // Retrieve outputVariables set from flow
      const outputVariables = event.getParam("outputVariables") || [];
      const outputVar = outputVariables.find((e) => e.name === "modalTitle");
      if (outputVar) {
        // Set the modalTitle attribute on the component
        component.set("v.modalTitle", outputVar.value);
      }

      // Get the workspace API component
      const workspaceAPI = component.find("workspace");
      workspaceAPI
        .getTabInfo()
        .then(function (response) {
          // Get the ID of the focused tab
          const focusedTabId = response.tabId;
          // Get the modalTitle from the component
          const modalTitle = component.get("v.modalTitle");
          // Set the tab label and icon using the modalTitle
          workspaceAPI.setTabLabel({
            tabId: focusedTabId,
            label: modalTitle
          });
          workspaceAPI.setTabIcon({
            tabId: focusedTabId,
            icon: "standard:record_create",
            iconAlt: modalTitle
          });
        })
        .catch(function (error) {
          console.log(error);
        });
    } else if (status === "FINISHED") {
      // Get the closeTab action from the component
      const closeFocusedTabAction = component.get("c.closeTab");
      // Enqueue the action to close the workspace tab
      $A.enqueueAction(closeFocusedTabAction);
    }
  },
  sessionCleanup: function (component, event, helper) {
    helper.removeSessionStorageItems(["ABN-", "EMAIL-", "LOOKUP-"], ["customCSSLoaded"]);
  },
  closeTab: function (component, event, helper) {
    // close workspace tab when close button is clicked
    var workspaceAPI = component.find("workspace");
    workspaceAPI
      .getTabInfo()
      .then(function (response) {
        var focusedTabId = response.tabId;
        workspaceAPI.refreshTab({
          tabId: response.parentTabId,
          includeAllSubtabs: true
        });
        return focusedTabId;
      })
      .then(function (response) {
        workspaceAPI.closeTab({ tabId: response });
      })
      .catch(function (error) {
        console.log(error);
      })
      .finally(function () {
        // Get the sessionCleanup action from the component
        const sessionCleanupAction = component.get("c.sessionCleanup");
        // Enqueue the action to clean the session
        $A.enqueueAction(sessionCleanupAction);
      });
  }
});
