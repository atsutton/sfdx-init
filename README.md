# SFDX PROJECT INITIALIZATION

My personal script to initialize an sfdx project for Salesforce development in VS Code.

The script will 
- Create an sfdx project
- Connect it to an org
- Pull the org's code
- Initialize git and commit the code
- Open the project in vscode

A custom manifest can also be generated from a template file. To do this:
- Create an sfdx manifest (in XML) with the desired structure. For the <version> value, use the string '##VERSION_NUMMBER##'
- Create the environment variable 'SFDX_MANIFEST_TEMPLATE_PATH' and set it to the path of the template file

Example usage:
```
sfdx-init -d my-project -a myorg-prod
sfdx-init -d my-project -a myorg-sandbox -sandbox
```
