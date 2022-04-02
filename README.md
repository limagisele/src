## Alternative Payroll App

#### Description
___
This terminal application was created using Ruby language with the purpose of utilising a range of developer tools, going through the processes of conceptualising, designing, planning, testing and implementing the application.

#### Table of Content
____
1. [Purpose](https://github.com/limagisele/terminal-app#description)
2. [Features](https://github.com/limagisele/terminal-app#features)
   1. asas
   2. asas
   3. asas
   4. adasd
3. [Documentation](https://github.com/limagisele/terminal-app#documentation)  
    1. GitHub Repo  
    2. Kanban Board
    3. Code Style Guide
4. [Installation](https://github.com/limagisele/terminal-app#installation)
   1. Step 1
   2. Step 2
5. [Usage](https://github.com/limagisele/terminal-app#usage)
   1. Standard access
   2. Management access
6. [CLI Arguments](https://github.com/limagisele/terminal-app#cli-arguments)
7. [Dependencies](https://github.com/limagisele/terminal-app#dependencies)
8. [System requirements](https://github.com/limagisele/terminal-app#system-requirements)

#### Purpose
____
Some companies can struggle to log working hours of their employees when their payroll management software goes out of action for a long period of time, as exemplified in this recent incident here: [Payroll disruption news](https://www.afr.com/work-and-careers/workplace/kronos-hack-creates-employer-nightmare-over-christmas-pay-20211215-p59ht6).  

From that experience, it came the idea to create a simple program that can allow employees to log their working hours independently and managers to generate weekly payroll reports automatically to be sent for payment processing, without the need to record hours on paper timecards or using spreadsheets.

Reference:  
Marin-Guzman, D. (2021). *Kronos hack creates employer ‘nightmare’ over Christmas pay*. [online] Australian Financial Review. Available at: https://www.afr.com/work-and-careers/workplace/kronos-hack-creates-employer-nightmare-over-christmas-pay-20211215-p59ht6 [Accessed 2 Apr. 2022].

#### Features
____


#### Documentation
____
* [GitHub Repo](https://github.com/limagisele/xxx)
* [Kanban Board](https://trello.com/b/wF75LZtz/alternative-payroll)  
  Trello was the project management platform used for the implementation plan, from start to finish of the this application.
* [Code Style](https://rubystyle.guide/)
  * The source code contained here adheres to The Ruby Style Guide.
  * Reference:  
  The Ruby Style Guide. (2022). *The Ruby Style Guide*. [online] Available at: https://rubystyle.guide/ [Accessed 29 Mar. 2022].

#### Installation
____
1. Download this [zip file](https://github.com/limagisele/terminal-app/archive/refs/heads/master.zip) from the GitHub repository
2. Unzip the file
3. Move folder to the directory where you would like the program to save the files
4. If you **don't** have Bundler set up yet, open a terminal window and run the command `gem install bundler`. *If you already do, please skip this step as it only needs to be done once.*
5. In the terminal, go to the directory where the folder is and run the command `./run_app.sh` to install all required gems and start the program.

#### Usage
____

#### CLI Arguments
____
Some Command Line Arguments are available at the terminal window by running the command `ruby payroll.rb [argument]`.  

The arguments used here are:

`-h` or `--help` -> Access help documentation  
`-g` or `--gems` -> Output list of gems required

#### Dependencies
____
In order to run and test this application successfully, it requires all the gems listed below to be installed.  
However, if you initiate the program by following the [Installation Steps]() you don't need to worry about installing gems manually and they will be all set and ready to go for you.

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