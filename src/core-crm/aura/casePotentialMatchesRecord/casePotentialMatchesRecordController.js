({
    doInit : function(component, event, helper) {
        // Get the subtabId
        const workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            component.set('v.tabId', tabId);
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})
