# Deployment Run Book for Release 1.0 - Run Once

This document outlines the steps that are required to be run once in each environment we are deploying to.

1. (DEP1-173) Go to Setup > Email > Deliverability. Under "Access to Send Email", select "All Email". Click Save. 
   

      | Environment  | UserName                                  | Email                        | 
      |--------------|-------------------------------------------|------------------------------|
      | ST           |angelika.galang@qut.edu.au.dep.it1sepst    |angelika.galang@qut.edu.au    | 
      | SIT          |                                           |                              | 

2. (DEP1-175) Go to Setup > User Interface > Path Settings. Click Delete for the Path of the Lead object. Click OK.
   
      | Environment  | UserName                                  | Email                        | 
      |--------------|-------------------------------------------|------------------------------|
      | ST           |angelika.galang@qut.edu.au.dep.it1sepst    |angelika.galang@qut.edu.au    | 
      | SIT          |                                           |                              | 

3. (DEP1-336) Go to Setup > Named Credentials > New Named Credentials > Enter Provided Credentials.
   
      | Environment  | UserName                                  | Email                        | 
      |--------------|-------------------------------------------|------------------------------|
      | ST           |roy.regala@qut.edu.au.dep.it1sepst         |roy.regala@qut.edu.au         | 
      | SIT          |                                           |                              | 
4. (DEP1-337) Go to App Launcher > Trigger Handler > Select All- Main Fields for List View > Look for ADDR_Addresses_TDTM and Deactivate
   
      | Environment  | UserName                                  | Email                        | 
      |--------------|-------------------------------------------|------------------------------|
      | ST           |roy.regala@qut.edu.au.dep.it1sepst         |roy.regala@qut.edu.au         | 
      | SIT          |                                           |                              | 
5. (DEP1-338) Go to App Launcher > Education Cloud Settings > Under Products, Click Settings > Look for 'Enable Multiple Addresses for Account Types' > Move to right all record types
   
      | Environment  | UserName                                  | Email                        | 
      |--------------|-------------------------------------------|------------------------------|
      | ST           |roy.regala@qut.edu.au.dep.it1sepst         |roy.regala@qut.edu.au         | 
      | SIT          |                                           |                              | 