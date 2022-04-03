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
    * TDD
4. [Installation Steps](https://github.com/limagisele/terminal-app#installation-steps)
5. [Usage](https://github.com/limagisele/terminal-app#usage)
   * Standard Access
   * Management Access
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
* [GitHub Repo](https://github.com/limagisele/terminal-app)
* [Kanban Board (Trello)](https://trello.com/b/wF75LZtz/alternative-payroll)  
  Trello was the project management platform used for the implementation plan, from start to finish of the this application.
  The Trello board link provides access to the checklist of tasks for each user story, their prioritisation and deadlines worked on during the development process.
* [Code Style](https://rubystyle.guide/)
  * The source code contained here adheres to The Ruby Style Guide.
  * Reference:  
  The Ruby Style Guide. (2022). *The Ruby Style Guide*. [online] Available at: https://rubystyle.guide/ [Accessed 29 Mar. 2022].
* [TDD](https://github.com/limagisele/terminal-app/tree/master/spec)
  * Test Driven Development cycle was utilised to perform unit tests at start of the development phase. 
  * RSpec was utilised to test methods within classes that are related to critical features, such as Sign In, Create Timesheets and Edit Timesheets.
  * Some mocking tests were completed at start of the development process to ensure the `gets` methods were working as expected. However they were later removed, once the tests became irrelevant after the `gem tty-prompt` was inserted in the source code and already ensuring the right input was being received from the user.

#### Installation Steps
____
1. Download this [zip file](https://github.com/limagisele/terminal-app/archive/refs/heads/master.zip) from the GitHub repository
2. Unzip the file
3. Move folder to the directory where you would like the program to save the files
4. If you **don't** have Bundler set up yet, open a terminal window and run the command `gem install bundler`. *If you already do, please skip this step as it only needs to be done once.*
5. In the terminal, go to the directory where the folder is and run the command `./run_app.sh` to install all required gems and start the program.

#### Usage
____
Start the program then type your employee ID and password.  
For demo purposes, a database containing a list of employees and their respective ID, password and roles can be found in the file `employees.json`.  
Once signed in the program already identified your type of access level and a menu will be displayed with the options and functionalities as per below. 

* Standard Access     
  1. Create Timesheet  
    You can create your own timesheet only.
  2. Edit Timesheet  
    You can edit an existing timesheet of your own only.
  3. *Access Manager's Options (***Not Accessible***)*
  4. Exit

* Management Access  
  This is a restricted access due to employees' privacy and data integrity.
  1. Create Timesheet  
    You can create a new timesheet for any employee.
  2. Edit Timesheet  
    You can edit an existing timesheet for any employee.
  3. Access Manager's Options  
   You will see another menu with two options:
      * Create Payroll Report - You can generate a summary of all data entered which will be saved as `report.csv`
      * RESET Timesheet File - It has the power to erase the `timesheets.json` file so you should only reset it when you want to start tracking hours for a new pay cycle/week.
  4. Exit
##### Data Entry

1. Creating a new timesheet  
   You will be asked to enter the following information:
   1. If you are a manager, you will be asked the employee ID for the person you want to create a timesheet for. If not, you will not see this question.
   2. Date 
       * It needs to be within the current week, which is the considered pay cycle here.
       * Accepted formats are DD/MM/YYYY or DD.MM.YYYY
    1. Start working time
       * Accepted format is HH:MM (24h)
    2. Finish working time
       * Accepted format is HH:MM (24h)
    3. Leave (type 'n' if not applicable and this step will be skipped)
       * Select what type of leave you want to apply
       * Enter how many **minutes** you want to allocate to the leave
    4. Confirmation
       * A summary of the data you entered will be displayed for your confirmation (type 'y' or 'n')
       * If confirmed, a message will informed that the timesheet has been saved in your file.   
2. Editing a timesheet  
   This option follows pretty much the same steps of creating a new timesheet, the only difference is that when you type a date, the program will look for your existing timesheet for that date. If not found, an error message will be displayed.
   

#### CLI Arguments
____
Command line arguments are available at the terminal with the command `ruby payroll.rb [argument]`.  

The arguments used here are:

`-a` or `--access` -> List an overview of each type of access level  
`-h` or `--help` -> Access help documentation for data entry  
`-g` or `--gems` -> Output list of gems required

#### Dependencies
____
In order to run and test this application successfully, it requires all the gems listed below to be installed.  
However, if you initiate the program by following the [Installation Steps](https://github.com/limagisele/terminal-app#installation-steps) you don't need to worry about installing gems manually and they will be all set and ready to go for you.

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