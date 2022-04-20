# Vantiq Organization Migration Guide

This instruction describes the steps for migrating a Vantiq Organization from one Vantiq Cloud to another.

## Scenario
One company is currently using Vantiq Cloud (dev.vantiq.co.jp)  as a development environment (As-Is), and is going to migrate the development space to a private Vantiq environment in its own cloud environment (To-Be), hence the need for migrating the Organization, its users, applications under development, etc.  

## Assumptions
The following Modules and Resources are described on the assumption that they are not used and are not included in the steps (They should be added to the steps as needed).   

- Vantiq mobile
- Vantiq Calatog
- Node (Deployment)  
- Assembly  

## Steps

### Organization Admin

In the AS-IS installation,
1. Identify users who have the account in dev.vantiq.co.jp. Filter the ones to be migrated.  
1. Identify the Namespaces in the Organization of dev.vantiq.co.jp. Filter the ones in use that are to be migrated. Assign the Developer for each Namespace.
1. Track the migration status of the target Users and Namespaces to be migrated. Once all the Users and Namespaces have been migrated, Request Vantiq Support to delete the Organization.  

In the TO-BE Installation,
1. Accept an invite to the Organization Root Namespace as Organization Admin, followed by getting granted system admin and Keycloak admin.      
1. Configure Organization Namespace and Keycloak security policies.
1. Send invites to the target Users to the Organization Root Namespace as `User (Developer)`.

#### Checklist
- [ ] All users are identified and migrated to new Namespace.  
     - Extract the list of users from Keycloak, who are belong to Namespaces in the AS-IS installation with a certain domain.  
     - Extract the list of users from Namespaces in the AS-IS installation (This may not cover all the users. Some users are homed in developer).     
- [ ] Identify all Namespaces and its owner users and track the migration completion status with them (As Organization Admin in Root Namespace, Menu >> Administer >> Namespaces).

### Developer

Each invited User performs the following:  
1. Accept the invite from Organization Admin, and creates the account in the TO-BE installation.  

Each Developer performs the following:
1. Create a Namespace in the To-Be installation.
1. Set Non-Active the all sources, export the projects & data from the As-Is installation.
1. If any exported resource contains the URL of the As-Is installation, rewrite it to that of the To-Be installation.  
1. Import projects in to the target Namespace in the To-Be installation.  
1. Reset Secrets in the target Namespaces if any.  
1. Recreate custom Profiles in the target Namespace if any, to be used in generating Access Tokens and inviting other Users.  
1. Regenerate access tokens in the target Namespaces.  Reset Vantiq endpoint URL and access tokens reference found in the external apps that connect to Vantiq via REST API.  
1. Set Sources as active and smoke test whether the imported projects function as intended.  
1. Re-invite the other Developers/Users to the target Namespaces.  
1. Report the completion of Namespace migration to the Organization Admin.  

#### Checklist
- [ ] To Export all projects in the Namespaces (Menu >> Projects >> Manage Projects)
- [ ] That All required resources are included in projects (Project Settings >> Show All Resources, Project Settings >> Show Orphan Resources)
- If they have resources/configuration that cannot be exported as part of the project.
  - [ ] Secrets (Menu >> Administer >> Advanced >> Secrets )
  - [ ] Access Tokens (Menu >> Administer >> Advanced >> Access Tokens )
  - [ ] Custom Profiles (Menu >> Administer >> Advanced >> Profile )
  - [ ] Groups (Menu >> Administer >> Advanced >> Groups )
  - [ ] Catalog (Menu >> Administer >> Advanced >> Catalog)
  - [ ] Deployments (Menu >> Deploy >> Configurations, Nodes, Node Configurations, Deployments, Environments, Clusters)
  - [ ] Users that are not homed in Org Root Namespace (Menu >> Administer >> Users)
