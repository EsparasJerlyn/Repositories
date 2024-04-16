const fs = require('fs');
const xml2js = require('xml2js');
const shell = require('shelljs');
let parser = new xml2js.Parser();


const permissionSets = [
    'src/core-crm/permissionsets/Permission_All_Object_and_FLAs_View_Create_Update_Delete.permissionset-meta.xml'
    ,'src/core-crm/permissionsets/Permission_All_Object_and_FLAs_View.permissionset-meta.xml'
]

const readPermSet = "Permission_All_Object_and_FLAs_View.permissionset-meta.xml"
const readWritePermSet = "Permission_All_Object_and_FLAs_View_Create_Update_Delete.permissionset-meta.xml"


function exec(cmd, options) {
    const defaultOptions = {silent: true};
    let output = shell.exec(cmd, {...defaultOptions, ...(options || {})});
    if (options && options.toString !== false) {
        output = output.toString();
        output = options.trim ? output.trim() : output;
    }
    return output;
}



/********************
 * Start
 *******************/
const start = async function(){
    
    // Only analyse files that are staged (but not committed)
    const diff = exec(`git diff --cached --name-only --diff-filter=ACMRTUXB`, {trim: true});
    const lines = diff.split("\n");

    // Analyse files
    let check_fields = [];
    let check_objects = [];
    let check_recordTypes = [];
    for (const line of lines){

        // Analyse Fields
        let fieldMatch = line.match('(.+)(objects)(\/)(.+)(\/)(fields\/)(.+)(\.field-meta.xml)');
        if(fieldMatch) {
            const object_name = fieldMatch[4];
            const field_name = fieldMatch[7];
            const fieldFilePath = `src/core-crm/objects/${object_name}/fields/${field_name}.field-meta.xml`
            field_file = fs.readFileSync(line);
            let field_file_Result = await parser.parseStringPromise(field_file);
            const ObjectPlusField = object_name+'.'+field_name
            const fieldFormula = field_file_Result?.CustomField?.formula?.[0] ?? null;
            const fieldType = field_file_Result?.CustomField?.type?.[0] ?? null;
            if(shouldFieldBeAddedToPermissionSet(field_file_Result)){
                console.log('Adding field to analyze: ',ObjectPlusField)
                check_fields.push({ ObjectPlusField, fieldFormula, fieldType });
            }
        }

        // Analyse Object
        let objectMatch = line.match('(.+)(objects)\/(.+)\/(.+)(\.object-meta.xml)');
        if(objectMatch) {
            const [, , , object_name] = objectMatch;
            const objectFilePath = `src/core-crm/objects/${object_name}/${object_name}.object-meta.xml`
            const object_file = fs.readFileSync(line);
            let object_file_Result = await parser.parseStringPromise(object_file);
            const objectLabel = object_file_Result?.CustomObject?.label?.[0] ?? null;
            console.log('Adding object to analyze: ',object_name)
            check_objects.push({ object_name, objectLabel, objectLabel });
            
        }

        // Analyze Record Type
        let recordTypeMatch = line.match('(.+)(objects)(\/)(.+)(\/)(recordTypes\/)(.+)(\.recordType-meta.xml)');
        if (recordTypeMatch) {
            const object_name = recordTypeMatch[4];
            const recordType_name = recordTypeMatch[7];
            const objectPlusRecordTypeName = object_name + '.' + recordType_name;
            const recordTypeFilePath = `src/core-crm/objects/${object_name}/recordTypes/${recordType_name}.recordType-meta.xml`;

            // Read and parse the record type file
            try {
                const recordTypeFile = fs.readFileSync(line);
                const recordTypeFileResult = await parser.parseStringPromise(recordTypeFile);
                
                // Access and analyze record type metadata here
                console.log('Adding record type to analyze:', objectPlusRecordTypeName, object_name, recordType_name);
                check_recordTypes.push({ objectPlusRecordTypeName, object_name, recordType_name });

            } catch (error) {
                console.error(`Error reading or parsing record type file: ${error.message}`);
            }
        }
    }

    // end if nothing to do
    if(check_fields.length == 0 && check_objects.length == 0 && check_recordTypes.length == 0){
        return;
    }

    // Remove components already on perm set
    for (let i = 0; i < permissionSets.length; i++) {
        const permissionSet = permissionSets[i];
        permissionSetXml = fs.readFileSync(permissionSet);
        let result = await parser.parseStringPromise(permissionSetXml);

        // Remove fields already on permission set.
        let field_permissions = result['PermissionSet']['fieldPermissions'];
        if(field_permissions){
            for (const check_field of check_fields) {
                let field_name = check_field.ObjectPlusField;
                let targetRecord = field_permissions.find(record => {
                    return record.field[0] === field_name;
                });
                if (targetRecord) {
                    check_fields = check_fields.filter(record => {
                        return !(record.ObjectPlusField === field_name);
                    });
                }
            }
        }

        // Remove Objects already on permission set.
        let object_permissions = result['PermissionSet']['objectPermissions'];
        if(object_permissions){
            for (const check_object of check_objects) {
                let object_name = check_object.object_name;
                let targetRecord = object_permissions.find(record => {
                    return record.object[0] === object_name;
                });
                if (targetRecord) {
                    check_objects = check_objects.filter(record => {
                        return !(record.object_name === object_name);
                    });
                }
            }
        }
        
        // Remove recordtypes already on permission set.
        let recordTypeVisibilities_permissions = result['PermissionSet']['recordTypeVisibilities'];
        if(recordTypeVisibilities_permissions){
            for (const check_recordType of check_recordTypes) {
                let objectPlusRecordTypeName = check_recordType.objectPlusRecordTypeName;
                let targetRecord = recordTypeVisibilities_permissions.find(record => {
                    return record.recordType[0] === objectPlusRecordTypeName;
                });
                if (targetRecord) {
                    check_recordTypes = check_recordTypes.filter(record => {
                        return !(record.objectPlusRecordTypeName === objectPlusRecordTypeName);
                    });
                }
            }
        }

        if(check_fields.length == 0 && check_objects.length == 0 && check_recordTypes.length == 0){
            return;
        }
        
        // Add fields to permission set
        for(const check_field of check_fields){
            console.log(`Adding field: ${check_field.ObjectPlusField} to ${permissionSet}`);
            var field_permission;
            var fieldReadWriteStatus = 'read'

            if(shouldFieldBeReadOnly(check_field)){
                fieldReadWriteStatus = 'read'
            }else if(permissionSet.includes(readPermSet)){
                fieldReadWriteStatus = 'read'
            }else if (permissionSet.includes(readWritePermSet)){
                fieldReadWriteStatus = 'write'
            }else{
                console.error(`${permissionSet} name not configured. Please seek assistance from DevOps`);
            }

            if(fieldReadWriteStatus == 'read'){
                field_permission = {
                    editable: [ 'false' ],
                    field: [ check_field.ObjectPlusField],
                    readable: [ 'true' ]
                };
            }else{
                field_permission = {
                    editable: [ 'true' ],
                    field: [ check_field.ObjectPlusField],
                    readable: [ 'true' ]
                };
            }
            result['PermissionSet']['fieldPermissions'].push(field_permission);
        }
        
        const fieldPermissions = result.PermissionSet.fieldPermissions;
        if(fieldPermissions && fieldPermissions.length > 0){
            fieldPermissions.sort((a, b) => compareFieldNames(a.field[0], b.field[0]))
        }

        // Add objects to permission set
        for(const check_object of check_objects){
            console.log(`Adding object: ${check_object.object_name} to ${permissionSet}`);
            var object_permission;
            var objectReadWriteStatus = 'read'

            if(objectIsPlatformEvent(check_object) && permissionSet.includes(readPermSet)){
                objectReadWriteStatus = 'platformEventRead'
            }else if(objectIsPlatformEvent(check_object) && permissionSet.includes(readWritePermSet)){
                objectReadWriteStatus = 'platformEventWrite'
            }else if(permissionSet.includes(readPermSet)){
                objectReadWriteStatus = 'read'
            }else if (permissionSet.includes(readWritePermSet)){
                objectReadWriteStatus = 'write'
            }else{
                console.error(`${permissionSet} name not configured. Please seek assistance from DevOps`);
            }

            if(objectReadWriteStatus == 'platformEventRead'){
                object_permission = {
                    allowCreate: [ 'false' ],
                    allowDelete: [ 'false' ],
                    allowEdit: [ 'false' ],
                    allowRead: [ 'true' ],
                    modifyAllRecords: [ 'false' ],
                    object: [ check_object.object_name],
                    viewAllRecords: [ 'false' ]
                };
            }else if(objectReadWriteStatus == 'platformEventWrite'){
                object_permission = {
                    allowCreate: [ 'true' ],
                    allowDelete: [ 'false' ],
                    allowEdit: [ 'false' ],
                    allowRead: [ 'true' ],
                    modifyAllRecords: [ 'false' ],
                    object: [ check_object.object_name],
                    viewAllRecords: [ 'false' ]
                };
            }else if(objectReadWriteStatus == 'read'){
                object_permission = {
                    allowCreate: [ 'false' ],
                    allowDelete: [ 'false' ],
                    allowEdit: [ 'false' ],
                    allowRead: [ 'true' ],
                    modifyAllRecords: [ 'false' ],
                    object: [ check_object.object_name],
                    viewAllRecords: [ 'true' ]
                };
            }else{
                object_permission = {
                    allowCreate: [ 'true' ],
                    allowDelete: [ 'true' ],
                    allowEdit: [ 'true' ],
                    allowRead: [ 'true' ],
                    modifyAllRecords: [ 'true' ],
                    object: [ check_object.object_name],
                    viewAllRecords: [ 'true' ]
                };
            }
            result['PermissionSet']['objectPermissions'].push(object_permission);
        }
        
        const objectPermissions = result.PermissionSet.objectPermissions;
        if(objectPermissions && objectPermissions.length > 0){
            objectPermissions.sort((a, b) => compareObjectNames(a.object[0], b.object[0]))
        }
        
        // Add record types to permission set
        for(const check_recordType of check_recordTypes){
            console.log(`Adding record type: ${check_recordType.objectPlusRecordTypeName} to ${permissionSet}`);
            var field_permission;
            var recordTypeVisability = 'none'

            if(permissionSet.includes(readPermSet)){
                recordTypeVisability = 'none'
            }else if (permissionSet.includes(readWritePermSet)){
                recordTypeVisability = 'visible'
            }else{
                console.error(`${permissionSet} name not configured. Please seek assistance from DevOps`);
            }

            if(recordTypeVisability == 'visible'){
                let recordTypeVisability_permission = {
                    recordType: [ check_recordType.objectPlusRecordTypeName],
                    visible: [ 'true' ]
                };
                result['PermissionSet']['recordTypeVisibilities'].push(recordTypeVisability_permission);
            }
            
        }
        const recordTypeVisabilityPermissions = result.PermissionSet.recordTypeVisibilities;
        if(recordTypeVisabilityPermissions && recordTypeVisabilityPermissions.length > 0){
            recordTypeVisabilityPermissions.sort((a, b) => compareFieldNames(a.recordType[0], b.recordType[0]))
        }

        // rebuild perm set file
        const builder = new xml2js.Builder({
            headless: true,  // Exclude standalone="yes" attribute
            renderOpts: {
                pretty: true,
                indent: '    ',
                newline: '\n'
            }
        });
        
        const xml = builder.buildObject(result);
        fs.writeFileSync(permissionSet, '<?xml version="1.0" encoding="UTF-8"?>\n'+xml+'\n');
        
        // stage file before commit
        exec(`git add "${permissionSet}"`);
    };
    
}


/********************
 * Objects
 *******************/

const objectIsPlatformEvent = function(check_object){
    if(check_object.object_name.endsWith('__e')){
        return true;
    }
    return false;
}

// Compare function for sorting object and field names in a specific order
const compareObjectNames = (objectA, objectB) => {

    // Compare object names
    if (objectA[0] === objectA[0].toUpperCase() && objectB[0] === objectB[0].toUpperCase()) {
        // Both object names start with uppercase
        if (objectA < objectB) return -1;
        if (objectA > objectB) return 1;
    } else if (objectA[0] === objectA[0].toUpperCase()) {
        // Object A is uppercase, Object B is lowercase
        return -1;
    } else if (objectB[0] === objectB[0].toUpperCase()) {
        // Object B is uppercase, Object A is lowercase
        return 1;
    } else {
        // Both object names start with lowercase
        if (objectA < objectB) return -1;
        if (objectA > objectB) return 1;
    }
    // Names are equal
    return 0;
};




/********************
 * Fields
 *******************/
const shouldFieldBeAddedToPermissionSet = function(field_file_Result){
    const fieldRequired = field_file_Result?.CustomField?.required?.[0] ?? null;
    const fieldType = field_file_Result?.CustomField?.type?.[0] ?? null;
    if(fieldType != 'MasterDetail' && fieldRequired != 'true'){
        return true;
    }
    return false;
}

const shouldFieldBeReadOnly = function(check_field){
    if(check_field.fieldType == 'Summary' || check_field.fieldFormula){
        return true;
    }
    return false;
}


// Compare function for sorting object and field names in a specific order
const compareFieldNames = (nameA, nameB) => {
    // Get the object and field names
    const [objectA, fieldA] = nameA.split('.');
    const [objectB, fieldB] = nameB.split('.');

    // Compare object names
    if (objectA[0] === objectA[0].toUpperCase() && objectB[0] === objectB[0].toUpperCase()) {
        // Both object names start with uppercase
        if (objectA < objectB) return -1;
        if (objectA > objectB) return 1;
    } else if (objectA[0] === objectA[0].toUpperCase()) {
        // Object A is uppercase, Object B is lowercase
        return -1;
    } else if (objectB[0] === objectB[0].toUpperCase()) {
        // Object B is uppercase, Object A is lowercase
        return 1;
    } else {
        // Both object names start with lowercase
        if (objectA < objectB) return -1;
        if (objectA > objectB) return 1;
    }

    // Compare field names
    if (fieldA[0] === fieldA[0].toUpperCase() && fieldB[0] === fieldB[0].toUpperCase()) {
        // Both field names start with uppercase
        if (fieldA < fieldB) return -1;
        if (fieldA > fieldB) return 1;
    } else if (fieldA[0] === fieldA[0].toUpperCase()) {
        // Field A is uppercase, Field B is lowercase
        return -1;
    } else if (fieldB[0] === fieldB[0].toUpperCase()) {
        // Field B is uppercase, Field A is lowercase
        return 1;
    } else {
        // Both field names start with lowercase
        if (fieldA < fieldB) return -1;
        if (fieldA > fieldB) return 1;
    }

    // Names are equal
    return 0;
};


start()
    .then(() => {
})
.catch((err) => {
    console.error(err);
});