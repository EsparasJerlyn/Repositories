const fs = require('fs');
const xml2js = require('xml2js');
const shell = require('shelljs');
let parser = new xml2js.Parser();

function exec(cmd, options) {
    const defaultOptions = {silent: true};
    let output = shell.exec(cmd, {...defaultOptions, ...(options || {})});
    if (options && options.toString !== false) {
        output = output.toString();
        output = options.trim ? output.trim() : output;
    }

    return output;
}

const shouldFieldBeAddedToPermissionSet = function(field_file_Result){
    const fieldRequired = field_file_Result?.CustomField?.required?.[0] ?? null;
    const fieldType = field_file_Result?.CustomField?.type?.[0] ?? null;
    if(fieldType != 'MasterDetail' && fieldRequired != 'true'){
        return true;
    }
    return false;
}

const shouldFieldBeReadOnly = function(new_field){
    if(new_field.fieldType == 'Summary' || new_field.fieldFormula){
        return true;
    }
    return false;
}

const start = async function(){
    
    const diff = exec(`git diff --cached --name-only --diff-filter=ACMRTUXB`, {trim: true});
    const lines = diff.split("\n");

    let new_fields = [];
    for (const line of lines){
        let match = line.match('(.+)(objects)(\/)(.+)(\/)(fields\/)(.+)(\.field-meta.xml)');
        if(!match) {
            continue;
        }
        const object_name = match[4];
        const field_name = match[7];
        field_file = fs.readFileSync(`src/core-crm/objects/${object_name}/fields/${field_name}.field-meta.xml`);
        let field_file_Result = await parser.parseStringPromise(field_file);

        const ObjectPlusField = object_name+'.'+field_name
        const fieldFormula = field_file_Result?.CustomField?.formula?.[0] ?? null;
        const fieldType = field_file_Result?.CustomField?.type?.[0] ?? null;
        
        if(shouldFieldBeAddedToPermissionSet(field_file_Result)){
            console.log('Pushing shouldFieldBeAddedToPermissionSet: ',ObjectPlusField)
            new_fields.push({ ObjectPlusField, fieldFormula, fieldType });
        }
    }

    if(new_fields.length == 0){
        return;
    }

    const permissionSets = [
        'src/core-crm/permissionsets/Permission_All_Object_and_FLAs_View_Create_Update_Delete.permissionset-meta.xml',
        'src/core-crm/permissionsets/Permission_All_Object_and_FLAs_View.permissionset-meta.xml'
    ]

    for (let i = 0; i < permissionSets.length; i++) { // Use regular for loop with await inside
        const permissionSet = permissionSets[i];
        permissionSetXml = fs.readFileSync(permissionSet);
        let result = await parser.parseStringPromise(permissionSetXml);

        let field_permissions = result['PermissionSet']['fieldPermissions'];
        for (const new_field of new_fields) {
            let field_name = new_field.FieldName;
            field_permissions = field_permissions.filter(item => item.field[0] !== field_name);
        }

        if(new_fields.length == 0){
            return;
        }

        for(const new_field of new_fields){
            console.log(`Adding field: ${new_field.ObjectPlusField} to ${permissionSet}`);
            var field_permission;
            var fieldReadWriteStatus = 'read'

            if(shouldFieldBeReadOnly(new_field)){
                fieldReadWriteStatus = 'read'
            }else if(permissionSet.includes('Permission_All_Object_and_FLAs_View.permissionset-meta.xml')){
                fieldReadWriteStatus = 'read'
            }else if (permissionSet.includes('Permission_All_Object_and_FLAs_View_Create_Update_Delete.permissionset-meta.xml')){
                fieldReadWriteStatus = 'write'
            }else{
                console.error(`${permissionSet} name not configured. Please seek assistance from DevOps`);
            }

            if(fieldReadWriteStatus == 'read'){
                field_permission = {
                    editable: [ 'false' ],
                    field: [ new_field.ObjectPlusField],
                    readable: [ 'true' ]
                };
            }else{
                field_permission = {
                    editable: [ 'true' ],
                    field: [ new_field.ObjectPlusField],
                    readable: [ 'true' ]
                };
            }
            result['PermissionSet']['fieldPermissions'].push(field_permission);
        }
        
        const fieldPermissions = result.PermissionSet.fieldPermissions;
        fieldPermissions.sort((a, b) => compareNames(a.field[0], b.field[0]))
        
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
        //fs.appendFileSync(permissionSet, '\n');

        exec(`git add "${permissionSet}"`);
    };
    
}

// Compare function for sorting object and field names in a specific order
const compareNames = (nameA, nameB) => {
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