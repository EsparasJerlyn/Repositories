This repository contains all the core salesforce code and metadata for project Digital Engagement Platform in QUT

**Development**

This project is using a sandbox development model. In order to contribute you will need to fetch a sandbox with and push all metadata configuration and code.

**Dependencies**

- sfdx cli
- sfpowerkit plugin ( sfdx plugins:install @dxatscale/sfpowerkit)
- @dxatscale/sfpowerscripts plugin( sfdx plugins:install @dxatscale/sfpowerscripts)

**Fetching A Sandbox**




**File structure**

src

Each domain should be represented by a subfolder under this directory. For example, the core schema is defined as src/core-crm.

src-env-specific

Metadata that is specific to a particular org should be stored here, under the relevant org folder e.g. sit.

src-access-management

This folder is comprised of metadata relating to profiles and other access management.

scripts

Container for scripts organised by domain e.g. customer, candidates. Initialisation scripts for scratch orgs are also found here.

forceignores

Container for .forceignore files belonging to different scratchorg configurations.

src-temp

New metadata created in scratch orgs is automatically pulled to this location, and must be moved into a package as it does not get deployed.


