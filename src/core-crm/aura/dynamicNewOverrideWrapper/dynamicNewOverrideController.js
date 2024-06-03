({
    doInit: function(component) {
        console.log('here');
        const workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log('response',JSON.parse(JSON.stringify(response)));
            //Get the object api name
            component.set("v.recordId",response.recordId);
            //Set isInitialized to true after initialization
            component.set("v.isInitialized", true);
        }).catch(function(error) {
            console.log(JSON.stringify(error));
        });
    }
})

