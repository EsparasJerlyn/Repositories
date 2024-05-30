({
    doInit : function(component, event, helper) {
        // Get the subtabId
        const workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            workspaceAPI.setTabIcon({
                tabId: tabId,
                icon: "standard:case",
                iconAlt: "Cases"
            });

            workspaceAPI.setTabLabel({
                tabId: tabId,
                label: "Cases",
            });

            component.set('v.tabId', tabId);
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    handleClosetab : function(component, event, helper) {
        const workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            workspaceAPI.closeTab({tabId: tabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})
