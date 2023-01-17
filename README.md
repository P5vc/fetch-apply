# Fetch Apply

### Transparent System Configuration and Management

------------

# Table of Contents

- [About](#about "About")
- [Installation](#installation "Installation")
- [Learning the Command](#learning-the-command "Learning the Command")
  - [Basics](#basics "Basics")
  - [Advanced](#advanced "Advanced")
- [Learning the Framework](#learning-the-framework "Learning the Framework")
  - [Base Structure](#base-structure "Base Structure")
  - [Special Files](#special-files "Special Files")
  - [Reserved Elements](#reserved-elements "Reserved Elements")
  - [Variables](#variables "Variables")
  - [Classes](#classes "Classes")
  - [Hosts](#hosts "Hosts")
  - [Initializers](#initializers "Initializers")
  - [Modules](#modules "Modules")
  - [Roles](#roles "Roles")
  - [Patches](#patches "Patches")
- [Examples](#examples "Examples")
  - [Example Operations Repository](#example-operations-repository "Example Operations Repository")
  - [Production Examples](#production-examples "Production Examples")


# About

Fetch Apply is a simple system configuration and management framework designed for transparency, security, efficiency, and auditability. Fetch Apply has many, wonderful advantages over other, similar frameworks... here are just a few:

- Written in Bash
  - Fetch Apply is written entirely in Bash: the standard language behind most commandlines. This allows for streamlined management in a language natively supported by most computing environments.
- Small codebase
  - Fetch Apply's entire codebase is minuscule—less than a thousand lines long—and powered by a single file. As a result, Fetch Apply is easily user-auditable, and capable of providing simple, yet powerful, system management... something that becomes unrealistic with other tools' large codebases and dependencies.
- Standardized but customizable
  - Fetch Apply uses a standardized framework with simple terminology, making it easy to use and eliminating the learning curve. The code is simple and descriptive, meaning that Fetch Apply can be customized to suit your needs in a snap.
- Powered by Git
  - Fetch Apply is powered by git, allowing systems administrators (or anyone else, should you choose to use a public repository) to view a complete history of all configurations, changes, and code introduced into their systems, thus improving security and accountability, and making troubleshooting easier than ever.
- Basically agentless... unless you don't want it to be
  - Fetch Apply does not require some hefty installation process that involves setting up services, reworking permissions, adding new users, etc. Instead, it takes the form of a simple bash script run periodically via cron. From there, it is your choice as to how "agentless" you would like Fetch Apply to be. You can have it poll a centralized server for new changes and updates consistently... or work quietly without even the need for an internet connection. Fetch Apply molds easily to fit any use case.

# Installation

To install Fetch Apply on your system, use the following commands to download the installation script, and then run it:

```bash
curl https://source.priveasy.org/Priveasy/fetch-apply/raw/branch/main/install -o /tmp/install
sudo bash /tmp/install
```

To install Fetch Apply non-interactively, you may supply your installation preferences via any number of commandline arguments, as outlined in the help message:

```
Fetch Apply Installation Script

Usage:
    install [OPTIONS]

Options and Default Values:
    --help
        Show this help message
    --uninstall
        Uninstall Fetch Apply
    --upgrade
        Upgrade Fetch Apply to the latest version
    --installation-path=/var/lib
        Fetch Apply installation location
    --log-file-path=/var/log/fetch-apply.log
        Fetch Apply log location
    --device-hostname=${DEVICE_HOSTNAME}
        Hostname to use
    --operations-repository-url=https://source.priveasy.org/Priveasy/server-configurations.git
        URL to your operations (Fetch Apply configuration) repository
    --operations-repository-branch=main
        Branch of the operations repository to use
    --crontab-entry="0 0 * * *"
        Crontab entry indicating how often to run Fetch Apply; the default is to run
        Fetch Apply once every 24 hours, at a random time generated during installation
```

A non-interactive installation example:

```bash
curl https://source.priveasy.org/Priveasy/fetch-apply/raw/branch/main/install -o /tmp/install
sudo bash /tmp/install --operations-git-url=https://example.com/MyAccount/MyOperationsRepository.git --server-hostname=myServer
```

To upgrade an existing Fetch Apply installation, you can use the following commands to automate the process:

```bash
curl https://source.priveasy.org/Priveasy/fetch-apply/raw/branch/main/install -o /tmp/install
sudo bash /tmp/install --upgrade
```

To uninstall Fetch Apply, use the following commands:

```bash
curl https://source.priveasy.org/Priveasy/fetch-apply/raw/branch/main/install -o /tmp/install
sudo bash /tmp/install --uninstall
```

# Learning the Command

## Basics

Running Fetch Apply from start to finish is admittedly a bit complicated, and it may take some time to memorize its intricacies. But, if you're willing to put in the time and effort, I can assure you that it will be worth-while.

Are you ready?

Here's what you need to memorize:

```bash
sudo fa
```

Yup. That's it. If you want to run Fetch Apply manually, just type `fa` into your terminal... and you're done! Keep in mind, however, that Fetch Apply is designed to be run automatically by `cron` anyways, so you'll likely never even have a reason to run it manually!

When run, `fa` will execute a `git pull` to grab the latest updates to your `operations` repository, and then apply any of the applicable `initializers`, `modules`, or `patches` as outlined therein.

## Advanced

Although Fetch Apply is designed to be simplistic and lightweight, it does also come with quite a few advanced options. These advanced options can be accessed when running the `fa` command, or by manipulating the Fetch Apply configuration file.

#### The full, command documentation:

###### You can access this documentation by running `sudo fa --help`.

```
fa - transparent system configuration and management

Usage:
  fa [options] [command]

Options:
  --fake                   Preview a command without actually applying any operations
  --force                  Run even if a pause or run lock is set
  --help                   Show this help message
  --no-fetch               Don't fetch the inventory before running the command
  --quieter                Suppress log messages

Commands:
  clear-inits              Allow completed initializers to run one more time
  fetch                    Update local operations repository by fetching from upstream
  list-classes             List all classes
  list-modules             List all modules
  list-roles               List all roles
  pause                    Set the pause lock to avoid periodic runs while debugging
  recover                  Remove run lock after a failure
  reset                    Reset/clean operations repository to match the remote origin
  resume                   Resume periodic runs after a pause (unset the pause lock)
  run <module name>        Run a specific module ad hoc (--force automatically set)
  status                   Display detailed Fetch Apply status information
```

#### The full, Fetch Apply configuration file (with default values):

###### This file should be located at `/etc/fetchapply` on your system.

```bash
# Fetch Apply Configuration File

# This file contains global variables used within
# Fetch Apply to modify certain, standard behaviors.

# All possible options, along with their default values,
# are listed within this file.

# Please refrain from removing/renaming any of these variables,
# and maintain proper, Bash syntax at all times.


# Fetch Apply installation location:
fa_var_FA_ROOT=/var/lib/fetch-apply

# Fetch Apply log file path:
fa_var_LOG_FILE_PATH=/var/log/fetch-apply.log

# Fetch Apply maximum log file size (in lines):
fa_var_MAX_LOG_LENGTH=10000

# Operations repository branch to use:
fa_var_OPERATIONS_BRANCH=main

# Allow automatic class assignments:
fa_var_AUTOMATIC_CLASS_ASSIGNMENT=true

# Automatically pull from remote repository with each run:
fa_var_AUTOMATIC_FETCH=true

# Only execute modules/patches/initializers after a change is detected in the remote operations repository:
fa_var_EXECUTE_ON_CHANGE=false

# Only execute modules after they have been modified:
fa_var_EXECUTE_IF_MODIFIED=false

# Ignore errors (pause locks will be honored, but execution will not
# halt for run locks or after any command returns a non-zero exit code):
fa_var_IGNORE_ERRORS=false
```

# Learning the Framework

Fetch Apply works by fetching the desired system configuration from an "operations" repository of your choosing (public or private), and then applying that configuration to the system on which Fetch Apply is installed.

## Base Structure

In order for Fetch Apply to understand your system configuration, you must start with (and maintain) this standard structure:

```
.
├── classes
├── initializers
├── modules
├── roles
└── variables
```

Where `classes`, `initializers`, `modules`, and `roles` are **directories** and `variables` is a **file**.

To create this base structure quickly, feel free to run the following command inside of a designated folder (your "operations" repository):

```
mkdir classes initializers modules roles && touch variables
```

## Special Files

Special Files are the magic that drives Fetch Apply... and they couldn't be any simpler! A Special File is simply a file named for one of the three Fetch Apply components: `initializers`, `modules`, and `roles`. They contain a list of items of that component type, to apply to the system(s) within the file's scope.

Let's break that down a bit, into some bite-sized points:

- Special Files may only have one of the following names:
  - `initializers`
  - `modules`
  - `roles`
- Special Files are required in the following circumstances:
  - All three special files *must* be in every, single class directory
  - Any host directory wishing to supplement or override a Special File in the containing class directory, must also include that type of Special File. If no Special File is found in a host directory, only the class's corresponding Special File will be used.
- Special Files may be left blank if there is nothing to apply, otherwise they must list, one item per line, the items they wish to apply. For example, within a `modules` special file, you may write the following, to apply the `apt`, `scp`, and `ufw` modules:

```
apt
scp
ufw
```

- Special Files will only affect systems that are part of the same class that the Special Files are located in. This allows you to specify and apply different modules, initializers, and roles to different classes of hosts.

## Reserved Elements

In order to prevent errors and unexpected behavior, Fetch Apply must reserve certain file, directory, function, and variable names for official use only.

#### Reserved File and Directory Names

Fetch Apply reserves the file and directory names of all Special Files (`initializers`, `modules`, and `roles`) on a global level. This means that no other type of file or directory within your operations repository's should be given the same name as a Special File. If you do give a different file one of the reserved file/directory names, then Fetch Apply may treat it as if it were that Special File, resulting in errors or unexpected behavior. The `variables` and `classes` file/directory names are also reserved on a global level.

When inside of a class directory, the file/directory name `assignments` is reserved, as this file is used to specify manual class assignments.

When inside of a class or host directory, the file/directory name `patches` is reserved, as this directory is solely used for distributing patches to the applicable classes/hosts, and all of the directly-contained files will be executed.

When inside of a host directory, the file/directory name `override` is reserved, as its existence (or lack thereof) is used as a flag to instruct Fetch Apply to override the class's Special Files with the host's, instead of supplementing them.

When inside of a module, the file/directory name `apply` is reserved, as it is a required file that will be executed by Fetch Apply whenever that module is run.

***To be clear, reserved files/directories are meant to be created by a user, however they may only be formatted and used in accordance with the Fetch Apply documentation.***

#### Reserved Function and Variable Names

Due to limitations with Bash, Fetch Apply must reserve its internal, Bash variable and function names, in order to prevent a user from accidentally redefining a function or reassigning a variable critical to Fetch Apply's proper operation. To make this easy, all variable names used by Fetch Apply begin with `fa_var_`, and all function names begin with `fa_func_`. Therefore, just make sure that the names of any variables or functions you define in Bash inside of your operations repository don't also begin with `fa_var_` or `fa_func_`.

## Variables

In addition to the global `variables` file, any directory containing code to be executed should include a `variables` file within it. The specific directories that can host a `variables` file are:

1. The base directory
2. Class directories
3. Host directories
4. Module directories

Fetch Apply will automatically scan those directories and load any applicable variables found within them.

- The `variables` file in the base directory is to be used for storing global variables.
- The `variables` file in a class directory is to be used for storing variables that will only apply to systems that belong to that class.
- The `variables` file in a host directory is to be used for storing variables that will only apply to that one, specific host.
- The `variables` file found in a module directory is to be used for storing variables that will only apply when that one, specific module is run.

All applicable variables will be automatically loaded and be accessible for use within your code (without the need to "source" anything). That means that not only will you have access to the variables stored in the same directory as, say, a specific host, but you will also be able to reference that host's class's variables, as well as the global variables.

In the case that two identical variables are declared, precedence is as follows (from winner to loser):

`current_module > hosts > classes > global > previously_run_modules`

## Classes

Classes are used to distinguish between types of systems. Within the `classes` directory, you may create specifically-named directories to separate your systems/devices/servers into distinct groups.

Fetch Apply will determine which classes apply by searching for directories within the `classes` directory that contain the hostname of the system it's installed on.

For example, let's say that you have the following servers that you need to maintain:

- Webservers
  - `webserver1`
  - `new-york-webserver2`
  - `Webserver-fallback`
- Database Servers
  - `DATABASE-server-1`
  - `database2`
  - `databasethree`

These servers can be easily split-up into the following two categories (classes):

- `webserver`
- `database`

Servers within the `webserver` class will likely share similar maintenance tasks, installation procedures, etc. The same applies to the database servers. Therefore, instead of having to re-write code to set up each individual server, we can simply create two classes: `webserver` and `database`. Any servers falling into the same class will share the same code.

Because each webserver's hostname contains `webserver` somewhere within it, and each database server's hostname contains `database` somewhere within it, yet no webserver's hostname contains `database` within it and no database server's hostname contains `webserver` within it, Fetch Apply will automatically identify and associate each server with its correct class. Fetch Apply's automatic class identification is case insensitive.

It is possible to make exceptions to Fetch Apply's automatic class identification by including an `assignments` file within a class directory. In this file, you should list, one per line, the hostname of each system to which you would also like the class applied. This will force the class to be applied to any specified hosts, regardless of whether or not their hostname matches with the class name. A host given a specific class assignment will still have any other, applicable classes applied to it, as determined by automatic class detection and assignment. If you wish to disable automatic class detection and assignment, and opt for manually assigning each host to its class(es) via `assignments` files within your class directories, you may set `fa_var_AUTOMATIC_CLASS_ASSIGNMENT` equal to `false` in your Fetch Apply configuration file (located at `/etc/fetch-apply`).

While `assignments` files are optional, keep in mind that every class directory **must** contain the following files (although they may be left blank):

- `initializers`
- `modules`
- `roles`

## Hosts

Host directories are contained within a class directory, and are used to supplement a class's `initializers`, `modules`, `roles`, and `variables`, for a specific host.

A host directory must be contained within a class directory that applies to the system it is targeting, and the host directory's name must be an exact match to the hostname of the target system.

For the applicable host, all **class** Special Files will be executed first, followed by the Special Files contained within the host directory. In the event that a Special File is missing from the host directory, only the class's Special File will be executed.

If you wish for host-specific Special Files to override the class's Special Files (as opposed to supplementing them), preventing the class's corresponding Special Files from being run for that host, create a file in the desired host directory named `override`. This file may be left blank.

If override mode is set for a host, but no overriding Special File is found in the host directory, the class's Special File will still be run. This allows you to specify only certain Special Files that should be overridden/customized for the specific host, while still allowing the host to use the class's "default" Special Files for any Special Files that have not been included in the host directory. If you simply wish to prevent a class's Special File from being run for a specific host, but do not have any actions that you would like to override it with, create a blank Special File of the same type in the host directory and activate override mode for that host.

To review, every host directory **may** contain the following files (and they may be left blank):

- `initializers`
- `modules`
- `override`
- `roles`
- `variables`

## Initializers

Initializers are installation/set-up scripts that are designed to be run only once. Their goal is to "initialize" (configure) a system, and will only be executed the first time that Fetch Apply is run on that system.

Initializers are created by adding a file with the desired commands to be run, to the `initializers` **directory**. The name of the file you create within that directory will be the name of the initializer.

To apply an initializer to a class or host, add the name of the initializer (or list one name per line, if assigning multiple initializers) to the `initializers` Special File in the desired class or host directory.

Note that all initializers will be executed from the context of the `initializers` directory. Therefore, it's possible to create additional, supporting files for that initializer (or better yet, create a single directory within the `initializers` directory for each initializer, to contain its supporting files), and then reference them using their relative paths.

## Modules

Modules are collections of code that share a single, common purpose. Generally, a module will be designated a program or task, and then labeled accordingly. For example, you may have one module to handle firewall rules, another to update the system, and a third to configure a database. If the module will, for the most part, be working with a single program, then the convention is to label the module with that program's name. In this example, the previously-mentioned modules could be named `ufw`, `apt`, and `postgresql`, respectively.

Modules are the only entity containing code/commands designed to be run regularly on your system. By default (unless a different time interval is specified during installation), every module assigned to your system is run once every 24 hours. For this reason, it's usually a good idea to design modules that are idempotent in nature. In other words, modules should work towards maintaining a desired state or configuration, and should be designed to be run more than once without "breaking" anything by doing so. For example, a module might export performance statistics each night, write a configuration file then restart a service, clear cached data, or any other consistent action or maintenance task.

If you have an action that should only be performed once, look into using an initializer or patch instead. If you would like to automate actions that are commonly—but should *not* be consistently—run, it may still be appropriate to create a module. In this case, avoid applying the module to any hosts, and instead just run it ad hoc as needed.

Modules can be run ad hoc (on demand) by specifying the `run` command, followed by the module's name. For example, to run the `apt` module ad hoc, the following command would be used:

```bash
fa run apt
```

Please be careful when running modules ad hoc, as running a module ad hoc is seen as a "manual override", and rules that would normally regulate the eligibility of a module to be run will be ignored.

To create a module, make a new directory within your `modules` directory. The name you give this directory will be the module's name. Within the new directory you just made, create the required `apply` file and the optional `variables` file. When your module is to be run, Fetch Apply will load any module-specific variables from the `variables` file, if it exists, and then run any code/commands you've written (in Bash) in the `apply` file.

Apart from the two reserved files, you may create as many additional, supporting files and directories as you wish within the module's directory. Common supporting files include configuration file templates and custom code. Subdirectories are also frequently used to isolate different versions of the same code, each crafted for a specific operating system or version. Before a modules is run, Fetch Apply first changes the current directory to that of the module, allowing developers to use relative paths in their code.

Remember that the `apply` file is the "command center" for your module, and is the only file (other than an included `variables` file) that Fetch Apply will run. If you use supporting files, they must be referenced or run from the `apply` file.

For example, if you have a Python script that you wish to run as part of the module, make sure to call it from `apply`:

```bash
python3 python_script_name.py
```

If you have logic to determine which subdirectory's code to run, it should also be done from within `apply`. For example:

```bash
if [ "$(lsb_release -rs)" == "22.04" ]
then
    # Run the bash script located within the Ubuntu 22.04 directory:
    source ./ubuntu-22.04/script.sh
elif [ "$(lsb_release -rs)" == "18.04" ]
then
    # Run the main python script located within the Ubuntu 18.04 directory:
    python3 ubuntu-18.04/main.py
else
    # If no match found, run this default script:
    source default_script.sh
    # Note: you could also use a variable instead of grabbing the release version, or you
    # could grep for the description to get the OS instead of just the release number, etc.
fi
```

If you're writing custom configuration files, that would also be done from within `apply`:

```bash
mo config-file.template > /etc/configuration
```

Fetch Apply comes bundled with `mo` by default (and it is sourced automatically, so there is no need to `source mo` in your `apply` file). This allows you to use mustache-style templates with your modules, as demonstrated above. For information on how to format these templates, see the [mo documentation](https://github.com/tests-always-included/mo "mo documentation").

Most Fetch Apply users treat `mo` like a more-powerful version of the `cat` command. It is commonly used to read configuration files provided within an operations repository, and then write them to the desired location on a given system.

To write a basic configuration file to a desired location, all of the following commands would be functionally identical:

```bash
cp example.conf /etc/example.conf
cat example.conf > /etc/example.conf
mo example.conf > /etc/example.conf
```

However, where `mo` differs from `cat`, is that it allows for more-advanced mustache-style templates to be used. These templates can contain variables, loop over arrays, and more.

Note: While `mo` does come built-in for convenience, it is not required, and any of the alternate commands listed above would work just as well, if you don't need bash templating functionality.

The final consideration to make when creating or updating your modules is how you would like them to run. By default, each applicable module will be executed every time Fetch Apply runs. For the vast majority of users, this is best practice. It allows you to ensure that your system will always maintain the desired state. For example, if you upgrade a package and accidentally choose to install the package maintainer's default version of the configuration file, instead of keeping your custom version, Fetch Apply will automatically correct this error the next time that package's module runs. The same goes for any other tinkering that may occur on your system, allowing Fetch Apply to automatically reset and maintain firewall rules, always rotate log files, consistently send out scheduled emails, etc. By enforcing your system's state through consistently-executed Fetch Apply modules, you ensure that no permanent changes happen to parts of your system for which you've written a module, unless those changes are committed to your operations repository. This means that you will always have a timestamped, user-attributable, complete version history of all changes to your system, aiding with compliance, error identification and recovery, and more. That being said, there are some users for whom this approach doesn't work. These users may be working in high-availability environments, have modules that cannot be efficiently executed, and/or need the flexibility to make persistent changes in their environments for extended periods of time, before committing them to the operations repository. In these cases, Fetch Apply includes two settings in its configuration file which may be activated to better suite the needs of these types of environments. The first setting, `fa_var_EXECUTE_ON_CHANGE`, when set to `true`, will automatically check the remote origin of the operations repository for any changes since the last time Fetch Apply was run. If no changes are found, then no operations (initializers, modules, or patches) will be run. On the other hand, if *any* updates have been made to the repository, then all operations (all applicable new initializers, modules, and new patches) will be run. The second setting, `fa_var_EXECUTE_IF_MODIFIED`, when set to `true`, takes the previous setting a step further, and will only execute the specific operations that have been modified since the last time Fetch Apply was run, if any. This means that only new initializers, new or modified modules, and new patches will be executed. Be careful when activating this setting immediately after installing Fetch Apply, because none of the assigned modules will run on that system until they have been updated in the operations repository's remote origin.

## Roles

A role is a group of modules that frequently work together towards completing a general goal, or have some sort of relationship with one another. Roles are made by creating a file within the `roles` directory and listing, one module per line, the name of each module that makes-up that role. The name of the file created in the `roles` directory will be the name of that new role.

For example, to create a "security" role, we would create a file named `security` within the `roles` directory, and then add all of our security-related modules to it, as such:

```
nftables
sshd
fail2ban
motd
```

To apply a role to a class or host (and therefore, by extension, run all of the role's modules on the applicable class/host system(s)), simply include the name of the role (or list one name per line, if assigning multiple roles) to the `roles` Special File in the desired class or host directory.

## Patches

Patches are "quick and dirty" scripts that are designed to be run first, but only once, on an applicable system. Their goal is to apply quick fixes and modifications to alleviate security issues or correct unexpected bugs that could not be planned for ahead of time (i.e. mitigated during initialization) and must be fixed in a one-off manner (i.e. cannot be included as part of an idempotent module).

Patches can be deployed by creating a `patches` directory within the class or host directory that you would like to apply the patch to, and then adding a patch in the form of a Bash script within that directory. A host will immediately attempt to execute any new files found within a `patches` directory applicable to that host. This means that you may name your patches whatever you'd like (as long as each patch's name is unique across all `patches` directories that may apply to a host)... however it also means that you may **not** include supporting files directly within the `patches` directory. Instead, a subdirectory (inside of the `patches` directory) should be made for each patch file that relies upon supporting files, and then those supporting files should be placed in that subdirectory. All patches will be run from the context of the containing `patches` directory, meaning that relative paths may be used in your code. Although patch scripts must be written in Bash, just like with modules, it's perfectly valid to just use a patch file to run a script (included as a "supporting file") in another language, or to execute a binary.

Unlike initializers and modules, which are meant to be well-developed and modified/optimized over time, patches are designed to provide quick, one-time fixes. For that reason, once a patch has been run, Fetch Apply will never run that patch again. By design, all new patches need to be represented by separate files. Simply modifying a current patch file that has already been run by Fetch Apply will not work, and will not result in that updated code being applied. For compliance and troubleshooting purposes, most organizations retain all of the files in their `patches` directories for at least six months, keeping the patches easily and readily accessible. Because patches are usually retained for a class, the first time Fetch Apply is installed and run on a system, it will automatically mark any already-existing patches as completed, so that they will not be applied to the new system. It is assumed that whatever the issue was that required a patch in the first place, is resolved before a new system is stood up. Therefore, the `fa status` command will still list old, applicable patches as having been applied. If you need to apply an old patch to the new system, you will need to copy it (with a new name) to the `patches` directory for that specific host.

You are welcome to delete a patch at any point, however make sure that the deletion has time to sync with the Fetch Apply instances on all applicable systems before creating a new patch with the same name, otherwise the new patch will not be run. Similarly, make sure that any patch you create has enough time to sync and be executed on all applicable Fetch Apply instances, before deleting it. With a default installation (designed to automatically run Fetch Apply once every 24 hours), you should plan for a sync time of at least 24 hours (unless you manually run Fetch Apply from all applicable systems sooner).

Note: just like with Special Files, class patches may be ignored/overridden for a specific host by including the `patches` directory and an `override` file in the host directory.

# Examples

## Example Operations Repository

This is an overview of an example "operations" repository for a small organization with the following systems:

- Webservers
  - `ws01.example.com`
  - `nyc-ws02.example.com`
  - `StaticWS.cdn.example.net`
  - `new-webserver.example.com`
- Database Servers
  - `db01.example.com`
  - `db-backup.example.com`
- DNS Servers
  - `primary-dns.example.com`
  - `secondary-dns.example.com`

Example content that an administrator may include in a very basic operations repository for the above organization:

```
operations/ ----------------------------> The base, operations repository
├── classes/ ---------------------------> The classes directory
│   ├── db/ ----------------------------> A class directory whose contents will apply to all database servers
│   │   ├── initializers ---------------> List of initializers to apply to the database servers
│   │   ├── modules --------------------> List of individual modules to apply to the database servers
│   │   ├── roles ----------------------> List of roles to apply to the database servers
│   │   └── variables ------------------> Contains the non-global variables specific to the database servers
│   ├── dns/ ---------------------------> A class directory whose contents will apply to all dns servers
│   │   ├── initializers ---------------> List of initializers to apply to the dns servers
│   │   ├── modules --------------------> List of individual modules to apply to the dns servers
│   │   ├── primary-dns.example.com/ ---> A host directory whose contents will only be applied to the specified host
│   │   │   └── patches/ ---------------> A patches directory containing patches to be executed just for this host
│   │   │       ├── fix-record ---------> A patch written in bash that will be executed, because it is a file
│   │   │       └── fix-record-files/ --> A directory corresponding to the above patch, containing its supporting files
│   │   │           └── example.com.db -> Supporting files for the patch, which are not meant to be directly executed
│   │   └── roles ----------------------> List of roles to apply to the dns servers
│   └── ws/ ----------------------------> A class directory whose contents will apply to all webservers
│       ├── assignments ----------------> An assignments file to explicitly assign new-webserver.example.com to this class
│       ├── initializers ---------------> List of initializers to apply to the webservers
│       ├── modules --------------------> List of individual modules to apply to the webservers
│       ├── patches/ -------------------> A patches directory containing patches to be executed for all webservers
│       │   └── restart-nginx ----------> A patch that will be executed, because it is a file directly under the patches directory
│       ├── roles ----------------------> List of roles to apply to the webservers
│       └── StaticWS.cdn.example.net/ --> A host directory whose contents will only be applied to the specified host
│           ├── initializers -----------> List of initializers to apply only to this host
│           └── override ---------------> Flag to make any included files override (instead of supplement) those in the ws class
├── initializers/ ----------------------> The initializers directory, containing any initializers and their supporting files
│   ├── db -----------------------------> An initializer to be run on database servers (when listed in the db class's initializers file)
│   ├── django-ws ----------------------> An initializer designed to be run on the dynamic webservers
│   ├── dns ----------------------------> An initializer designed to be run on the dns servers
│   ├── server -------------------------> A basic initializer designed to be run on all servers
│   └── static-ws ----------------------> An initializer designed to be run only on the static webserver
├── modules/ ---------------------------> The modules directory, creating all modules (code meant to be run regularly)
│   ├── nginx/ -------------------------> A module named "nginx", which will be run when listed in a modules or (activated) roles file
│   │   ├── apply ----------------------> The Bash script within a module that Fetch Apply will execute when that module is run
│   │   ├── nginx.conf -----------------> A supporting file within the module (in this case, likely a mo template of the nginx config.)
│   │   ├── variables ------------------> Module-specific variables that Fetch Apply will automatically load when the module is run
│   │   └── website.conf ---------------> A supporting file within the module (in this case, likely a mo template of an enabled site)
│   └── sshd/ --------------------------> A module named "sshd", which will be run when listed in a modules or (activated) roles file
│       ├── apply ----------------------> The Bash script within a module that Fetch Apply will execute when that module is run
│       └── sshd_config ----------------> A supporting file within the module (in this case, likely a mo template of the SSHd config.)
├── roles/ -----------------------------> The roles directory, defining all roles that can be activated via a class's/host's roles file
│   ├── core-maintenance ---------------> File that defines a role named "core-maintenance" that lists all modules belonging to this role
│   ├── db-maintenance -----------------> File that defines a role named "db-maintenance" that lists all modules belonging to this role
│   ├── dns-maintenance ----------------> File that defines a role named "dns-maintenance" that lists all modules belonging to this role
│   └── ws-maintenance -----------------> File that defines a role named "ws-maintenance" that lists all modules belonging to this role
└── variables --------------------------> The global variables file, containing variables that will be loaded for all hosts

14 directories, 32 files
```

## Production Examples:

- [Priveasy Server Configurations](https://source.priveasy.org/Priveasy/server-configurations "Priveasy Server Configurations")
