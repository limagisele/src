## Alternative Payroll App

#### Purpose
___
This terminal application was created using Ruby language with the purpose of utilising a range of developer tools, going through the processes of conceptualising, designing, planning, testing and implementing the application.

#### Table of Content
____
1. [Description]()
2. [Features]()
   1. asas
   2. asas
   3. asas
   4. adasd
3. [Documentation]()  
    1. GitHub Repo  
    2. Kanban Board
    3. Code Style Guide
4. [Installation]()
   1. Step 1
   2. Step 2
5. [Usage]()
   1. Standard access
   2. Management access
6. [CLI Arguments]()
7. [Dependencies]()
8. [System requirements]()

#### 1. Purpose
____


#### 2. Features
____


#### 3. Documentation
____
* [GitHub Repo](https://github.com/limagisele/xxx)
* [Kanban Board](https://trello.com/b/wF75LZtz/alternative-payroll)  
  Trello was the project management platform used for the implementation plan, from start to finish of the this application.
* [Code Style](https://rubystyle.guide/)
  * The source code contained here adheres to The Ruby Style Guide.
  * Reference:  
  The Ruby Style Guide. (2022). The Ruby Style Guide. [online] Available at: https://rubystyle.guide/ [Accessed 29 Mar. 2022].

#### 4. Installation
____
1. Download this [zip file](https://github.com/limagisele/terminal-app/archive/refs/heads/master.zip) from the GitHub repository
2. Unzip the file
3. Move folder to the directory where you would like the program to save the files
4. If you **don't** have Bundler set up yet, open a terminal window and run the command `gem install bundler`. *If you already do, please skip this step as it only needs to be done once.*
5. In the terminal, go to the directory where the folder is and run the command `./run_app.sh` to install all required gems and start the program.

#### 5. Usage
____

#### 6. CLI Arguments
____

#### 7. Dependencies
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

#### 8. System Requirements
____
This program runs in any operating system. However it is worth mentioning that the gem `tty-promp` has some limitations on the `select` function when running from Git Bash. The function mentioned is used in this app uses for displaying menu options.
If you require more information about the limitation above, please check the [TTY-prompt README.md](https://github.com/piotrmurach/tty-prompt#windows-support).