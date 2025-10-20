# About Project Management

This section explains how to manage Projects you have developed in Vantiq.

## Table of Contents

- [About Project Management](#about-project-management)
  - [Table of Contents](#table-of-contents)
  - [Importing a Project](#importing-a-project)
    - [How to Import a Project](#how-to-import-a-project)
  - [Exporting a Project](#exporting-a-project)
    - [How to Export a Project](#how-to-export-a-project)
  - [Creating an Additional Project](#creating-an-additional-project)
    - [How to Add a New Project](#how-to-add-a-new-project)
  - [Switching Projects](#switching-projects)
    - [How to Switch Projects](#how-to-switch-projects)
  - [Deleting a Project](#deleting-a-project)
    - [How to Delete a Project](#how-to-delete-a-project)

## Importing a Project

You can import a Project created in another Namespace into a different Namespace.  

Here are some examples of when you might import a Project:    

- Importing a Project developed on Vantiq Public Cloud into Vantiq Private Cloud.
- Importing a Project from a development environment to a production environment.
- Importing data generators or implementation samples provided in workshops.

### How to Import a Project

1. From the navigation bar, click `Projects` -> `Import...`.

   ![project_import_01.png](./imgs/project_import_01.png)

1. Drag and drop the Project's `folder` or `zip file` into the dashed area labeled `Drop a folder or zip file here to import`.

   ![project_import_02.png](./imgs/project_import_02.png)

1. Verify that the correct Project is listed for import and click `Import`.

   ![project_import_03.png](./imgs/project_import_03.png)

1. `Click` Reload. 

   ![project_import_04.png](./imgs/project_import_04.png)

1. The imported Project will be displayed.  
   This completes the Project import process.

   ![project_import_05.png](./imgs/project_import_05.png)

## Exporting a Project

You can export a Project that you have developed.  
Exporting a Project allows you to import it into other Namespaces or keep it as a backup.  

### How to Export a Project

1. From the navigation bar, click `Projects` -> `Export...`.

   ![project_export_01.png](./imgs/project_export_01.png)

1. Select the Resources you want to export and click `Export`.
   > To also export data from Types, check the `Export data` box.

   ![project_export_02.png](./imgs/project_export_02.png)

1. The exported Project will be downloaded as a zip file.  
   This completes the Project export process.

## Creating an Additional Project

This section explains how to add a new Project within the same Namespace.  

### How to Add a New Project

1. From the navigation bar, click `Projects` -> `New Project...`.

   ![project_add_01.png](./imgs/project_add_01.png)

1. Select `Add Project` and click `Continue`.

   ![project_add_02.png](./imgs/project_add_02.png)

1. Select `Empty Project` and click `Continue`.

   ![project_add_03.png](./imgs/project_add_03.png)

1. Enter a name for the Project in `Project Name` (e.g., TestProject) and click `Finish`.

   ![project_add_04.png](./imgs/project_add_04.png)

1. Confirm that the IDE has switched to the Project you just created.  
   This completes the process of adding a new Project.

   ![project_add_05.png](./imgs/project_add_05.png)

## Switching Projects

This section explains how to switch between Projects within a Namespace.  

You can create multiple Projects within a single Namespace.  
However, it is recommended to have a separate Namespace for each Project whenever possible.  

### How to Switch Projects

1. From the navigation bar, click `Projects` -> `Manage Projects...`.

   ![project_change_01.png](./imgs/project_change_01.png)

1. Click the `Project Name` you want to switch to (e.g., SampleProject).

   ![project_change_02.png](./imgs/project_change_02.png)

1. Confirm that the Project has been switched.  
   This completes the Project switching process.  

   ![project_change_03.png](./imgs/project_change_03.png)

## Deleting a Project

This section explains how to delete a Project from a Namespace.  

There are two ways to delete a Project.  
> **Caution:** Be aware that you cannot undo the deletion of Projects or Resources.

- **Delete Project and Resources:**
  This method deletes the Project along with all the Resources it contains.
  > **Caution:** This will delete the Resources even if they are being used by other Projects in the same Namespace.  
- **Delete Project:** This method deletes only the Project, leaving its Resources intact.

### How to Delete a Project

1. From the navigation bar, click `Projects` -> `Manage Projects...`.  

   ![project_delete_01.png](./imgs/project_delete_01.png)

1. Check the box next to the Project you want to delete (e.g., TestProject) and click `Delete`.  

   ![project_delete_02.png](./imgs/project_delete_02.png)
  
1. Click either `Delete Project and Resources` or `Delete Project`.  

   ![project_delete_03.png](./imgs/project_delete_03.png)

   Confirm that the Project has been deleted, then click `Done` to close the window.  
   This completes the Project deletion process.  

   ![project_delete_04.png](./imgs/project_delete_04.png)
