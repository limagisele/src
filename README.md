## Alternative Payroll App

#### Description
___
This terminal application was created using Ruby language with the purpose of utilising a range of developer tools, going through the processes of conceptualising, designing, planning, testing and implementing the application.

#### Table of Content
____
1. [Purpose](https://github.com/limagisele/terminal-app#purpose)
2. [Features](https://github.com/limagisele/terminal-app#features)
   * Sign In
   * Create Timesheet
   * Edit Timesheet
   * Generate Payroll Report
3. [Documentation](https://github.com/limagisele/terminal-app#documentation)  
    * GitHub Repo  
    * Kanban Board
    * Code Style Guide
4. [Installation Steps](https://github.com/limagisele/terminal-app#installation)
5. [Usage](https://github.com/limagisele/terminal-app#usage)
   * Standard access
   * Management access
6. [CLI Arguments](https://github.com/limagisele/terminal-app#cli-arguments)
7. [Dependencies](https://github.com/limagisele/terminal-app#dependencies)
8. [System requirements](https://github.com/limagisele/terminal-app#system-requirements)

#### Purpose
____
Some companies can struggle to log working hours of their employees when their payroll management software goes out of action for a long period of time, as exemplified in this recent incident here: [Payroll disruption news](https://www.afr.com/work-and-careers/workplace/kronos-hack-creates-employer-nightmare-over-christmas-pay-20211215-p59ht6).  

From that experience, it was originated the idea of creating the Alternative Payroll program, which is a simple program that allows employees to log their working hours independently and managers to generate weekly payroll reports automatically, ready to be sent for payment processing, without the need to record hours on paper timecards or using spreadsheets.

Reference:  
Marin-Guzman, D. (2021). *Kronos hack creates employer ‘nightmare’ over Christmas pay*. [online] Australian Financial Review. Available at: https://www.afr.com/work-and-careers/workplace/kronos-hack-creates-employer-nightmare-over-christmas-pay-20211215-p59ht6 [Accessed 2 Apr. 2022].

#### Features
____
* **Sign In**  
  Users have their access authorised via validation of their employee ID and password. This features is responsible to identify the type of access the employee has as well, being either standard or management level.
* **Create Timesheet**  
  New timesheets can be generated in this feature, as long as the date entered by the user belongs to the current payroll week and there is no other timesheet already stored in the file for that user.  
  Once data is entered, it is displayed at the terminal and user is prompted to confirm it so it can be saved.  
* **Edit Timesheet**  
  Before starting to edit, this feature checks if there is a timesheet for the date requested by the user. When found, it accepts the new data, displays the updated version and asks for confirmation before saving it.  
* **Generate Payroll Report**  
  This feature is only available to the management team, who can select the option to create a csv file with all timesheet entries stored in the file.  
  After that, managers have the option to reset the timesheets storage JSON file so it is blank again and ready to start a new payroll cycle/week.

  All the above features contain error handling messages to indicate if the conditions mentioned are not met by the data entered.

#### Documentation
____
* [GitHub Repo](https://github.com/limagisele/xxx)
* [Kanban Board](https://trello.com/b/wF75LZtz/alternative-payroll)  
  Trello was the project management platform used for the implementation plan, from start to finish of the this application.
* [Code Style](https://rubystyle.guide/)
  * The source code contained here adheres to The Ruby Style Guide.
  * Reference:  
  The Ruby Style Guide. (2022). *The Ruby Style Guide*. [online] Available at: https://rubystyle.guide/ [Accessed 29 Mar. 2022].

#### Installation Steps
____
1. Download this [zip file](https://github.com/limagisele/terminal-app/archive/refs/heads/master.zip) from the GitHub repository
2. Unzip the file
3. Move folder to the directory where you would like the program to save the files
4. If you **don't** have Bundler set up yet, open a terminal window and run the command `gem install bundler`. *If you already do, please skip this step as it only needs to be done once.*
5. In the terminal, go to the directory where the folder is and run the command `./run_app.sh` to install all required gems and start the program.

#### Usage
____
As soon as the program starts it asks for an employee ID and a password. Once they are validated, the user's access leave is automatically identified and the features will behave differently depending if the access is standard or management.  

* Standard Access  
  Access level for any employee that requires a timesheet to log their hours and is not a manager.  
  At this level the accepted menu options and access are:  
  1. Create Timesheet  
    Users can only view and create their own timesheet.
  2. Edit Timesheet  
    Users can only edit an existing timesheet of their own.
  3. *Access Manager's Options (***Not Applicable***)*
  4. Exit

* Management Access  
  This is a restricted access due to employees' privacy and data integrity.
  For this level the menu options and functionalities are:
  1. Create Timesheet  
    This function allows the user to create timesheets for any employee included in the list of employees.  
    Once this option is selected, it prompts the user which employee they want to access by asking for the employee's ID.  
    After employee required is found, the program will follow the standard steps of creating a timesheet.
  2. Edit Timesheet  
   Here users can edit timesheets for any employee included in the list of employees.  
   Similarly to the create option, the manager will be asked for the employee ID who needs to have the timesheet altered.  
   When employee is found, the program will follow the standard steps of editing a timesheet.
  3. Access Manager's Options  
   It displays a menu with two options:
      * Create Payroll Report - A confirmation will be prompted before proceeding. If typed 'yes', a csv file will be saved as `report.csv`
      * RESET Timesheet File - It has the power to erase the `timesheets.json` file so a confirmation will be asked before proceeding. If 'yes' is selected a blank file will be ready to be used at the start of a next pay cycle.
  4. Exit

#### CLI Arguments
____
Some Command Line Arguments are available at the terminal window by running the command `ruby payroll.rb [argument]`.  

The arguments used here are:

`-a` or `--access` -> List an overview of each type of access level  
`-h` or `--help` -> Access help documentation for data entry  
`-g` or `--gems` -> Output list of gems required

#### Dependencies
____
In order to run and test this application successfully, it requires all the gems listed below to be installed.  
However, if you initiate the program by following the [Installation Steps](https://github.com/limagisele/terminal-app#installation) you don't need to worry about installing gems manually and they will be all set and ready to go for you.

```ruby
gem "rspec", "~> 3.11"

gem "rainbow", "~> 3.1"

gem "tty-prompt", "~> 0.23.1"

source "https://rubygems.org"
```
Besides the ones above, this program also uses few built-in gems, such as:
```ruby
gem "csv"

gem "date"

gem "json"

gem "time"
```

#### System Requirements
____
This program runs in any operating system. However it is worth mentioning that the gem `tty-promp` has some limitations on the `select` function when running from Git Bash. The function mentioned is used in this app uses for displaying menu options.
If you require more information about the limitation above, please check the [TTY-prompt README.md](https://github.com/piotrmurach/tty-prompt#windows-support).