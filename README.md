# Fetch Apply

### Transparent Server Configuration and Management

###### Inspired by [aviary.sh](https://github.com/team-video/aviary.sh "aviary.sh")

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
  - [Variables](#variables "Variables")
  - [Classes](#classes "Classes")
  - [Hosts](#hosts "Hosts")
  - [Initializers](#initializers "Initializers")
  - [Modules](#modules "Modules")
  - [Roles](#roles "Roles")
- [Examples](#examples "Examples")
- [Final Thoughts](#final-thoughts "Final Thoughts")

# About

Fetch Apply is a simple system configuration and management framework designed for transparency, security, efficiency, and auditability. Fetch Apply has many, wonderful advantages over other, similar frameworks... here are just a few:

- Written in Bash
  - Fetch Apply is written entirely in Bash: the standard language behind most commandlines. This allows for streamlined management in the language natively supported by most server environments.
- Small codebase
  - Fetch Apply's entire codebase is minuscule—less than a thousand lines long—and powered by a single file. As a result, Fetch Apply is easily user-auditable, and capable of providing simple, yet powerful server management... something that becomes unrealistic with other tools' large codebases and dependencies.
- Standardized but customizable
  - Fetch Apply uses a standardized framework with simple terminology, making it easy to use and eliminating the learning curve. The code is simple and descriptive, meaning that Fetch Apply can be customized to suit your needs in a snap.
- Powered by Git
  - Fetch Apply is powered by git, allowing system admins (or anyone else, should you choose to use a public repository) to view a complete history of all configurations, changes, and code introduced into their systems, thus improving security and making troubleshooting easier than ever.
- Agentless... ish
  - Fetch Apply does not require some hefty installation process that involves setting up services, reworking permissions, adding new users, etc. Instead, it takes the form of a simple bash script run by periodically by cron. From there, it is your choice as to how "agentless" you would like Fetch Apply to be. You can have it poll a centralized server for new changes and updates consistently... or work quietly without even the need for an internet connection. Fetch Apply molds easily to fit your needs.

# Installation

To install Fetch Apply on your system, use the following commands (to download the installation script, then run it):

```bash
curl https://raw.githubusercontent.com/P5vc/FetchApply/master/install -o /tmp/install
sudo bash /tmp/install
```

To install Fetch Apply non-interactively, you may supply your installation preferences via any number of commandline arguments, as outlined in the help message, below:

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
    --log-file-path=/var/log/fetchapply.log
        Fetch Apply log location
    --server-hostname=yourCurrentHostname
        Server hostname to use
    --operations-git-url=https://github.com/P5vc/ServerConfigurations.git
        URL to your operations (Fetch Apply configuration) repository
    --crontab-entry="0 0 * * *"
        Crontab entry indicating how often to run Fetch Apply; the default is to run
        Fetch Apply at a random time (determined upon installation), once every 24 hours.
```

A non-interactive installation example:

```bash
curl https://raw.githubusercontent.com/P5vc/FetchApply/master/install -o /tmp/install
sudo bash /tmp/install --operations-git-url=https://example.com/MyAccount/MyOperationsRepository.git --server-hostname=myServer
```

If you wish to perform an automated Fetch Apply upgrade, try the following commands:

```bash
curl https://raw.githubusercontent.com/P5vc/FetchApply/master/install -o /tmp/install
sudo bash /tmp/install --upgrade
```

To uninstall Fetch Apply, use the following commands:

```bash
curl https://raw.githubusercontent.com/P5vc/FetchApply/master/install -o /tmp/install
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

Yup. That's it. If you want to run Fetch Apply manually, just type `fa` into your terminal... and you're done! Keep in mind, however, that Fetch Apply is designed to be run automatically by `cron` anyways, so you never even have to run it manually, if you don't want to!

When run, `fa` will execute a `git pull` to grab the latest updates to your `operations` repository, and then apply any of the applicable `modules` or (new) `initializers` as outlined therein.

## Advanced

Although Fetch Apply is designed to be simplistic and lightweight, it does also come with quite a few advanced options. These advanced options can be accessed when running the `fa` command, or by manipulating the Fetch Apply configuration file. The best resource for learning about these options is to reference the documentation/files themselves.

#### The full, command documentation:

###### You can access this documentation by running `sudo fa --help`.

```
fa - transparent server configuration and management

Usage:
  fa [options] [command]

Options:
  --help                   Show this help message
  --no-fetch               Don't fetch the inventory before running the command
  --force                  Run even if a pause or run lock is set
  --quieter                Suppress log messages

Commands:
  fetch                    Update local operations repository by fetching from upstream
  recover                  Reset run lock file after a failure
  pause                    Set the pause lock to avoid periodic runs while debugging
  resume                   Resume periodic runs after a pause
  list-classes-to-run      List all classes applicable to the local system
  list-classes             List all classes
  list-modules             List all modules
  list-roles               List all roles
  clear-inits              Allow completed initializers to run once more
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
fa_var_FA_ROOT=/var/lib/fetchapply

# Fetch Apply log file path:
fa_var_LOG_FILE_PATH=/var/log/fetchapply.log

# Fetch Apply maximum log file size (in lines):
fa_var_MAX_LOG_LENGTH=10000

# Allow automatic class assignments:
fa_var_AUTOMATIC_CLASS_ASSIGNMENT=true

# Automatically pull from remote repository with each run:
fa_var_AUTOMATIC_FETCH=true

# Only apply modules after a change is detected in the remote operations repository:
fa_var_APPLY_ON_CHANGE=false

# Ignore errors (pause locks will be honored, but execution will not
# halt for run locks or after any command returns a non-zero exit code):
fa_var_IGNORE_ERRORS=false
```

# Learning the Framework

Fetch Apply works by fetching the desired system configuration from a repository of your choosing (public or private), and then applying that configuration to the system on which Fetch Apply was installed.

## Base Structure

In order for Fetch Apply to understand your server configuration, you must start with (and maintain) this standard structure:

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

Special Files are the magic that drives Fetch Apply... and they couldn't be any simpler! A special file is simply a file named for one of the three Fetch Apply components: `initializers`, `modules`, and `roles`. They contain a list of items from within that component, to apply to the system within its scope.

Let's break that down a bit, into some bite-sized points:

- Special Files may only have one of the following names:
  - `initializers`
  - `modules`
  - `roles`
- Special Files are required in the following circumstances:
  - All three special files *must* be in every, single class directory
  - Any host directory wishing to override a special file in the containing class directory must include that same type of special file. If no special file is found in a host directory, the class's corresponding special file will be used.
- Special Files may be left blank if there is nothing to apply, otherwise they must list, one item per line, the items they wish to apply. For example, within a `modules` special file, you may write the following, to apply the `apt`, `scp`, and `ufw` modules:

```
apt
scp
ufw
```

- Special Files will only affect servers that are part of same class or host directory that the special files are located in. This allows you to specify and apply different modules, initializers, and roles to different classes of hosts and individual hosts.

## Variables

In addition to the global `variables` file, any directory containing code to be executed should include a `variables` file within it. The specific directories hosting a `variables` file are:

1. The base directory (required)
2. Class directories (only required if class-specific variables are needed)
3. Host directories (only required if host-specific variables are needed)
4. Module directories (recommended, but not required)

Fetch Apply will automatically scan those directories and load any applicable variables found within them.

- The `variables` file in the base directory is to be used for storing global variables.
- The `variables` file in a class directory is to be used for storing variables that will only apply to systems that fit within that class.
- The `variables` file in a host directory is to be used for storing variables that will only apply to that one, specific host.
- The `variables` file found in a module directory is to be used for storing variables that will only apply when that one, specific module is run.

All applicable variables will be loaded, and be accessible for use within your code (without the need to "source" anything). That means that not only will you have access to the variables stored in the same directory as, say, a specific host, but you will also be able to reference that host's class's variables, as well as the global variables.

In the case that two identical variables are declared, precedence is as follows (from winner to loser):

`modules > hosts > classes > global`

## Classes

Classes are used to distinguish between types of systems. Within the `classes` directory, you may create specifically-named directories to separate your systems/devices/servers into distinct groups.

Fetch Apply will determine which classes apply by searching for directories within the `classes` directory that contain the system it's installed-on's hostname.

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

Because each webserver's hostname contains `webserver` somewhere within it, and each database server's hostname contains `database` somewhere within it, yet no webserver's hostname contains `database` within it and no database server's hostname contains `webserver` within it, Fetch Apply will automatically identify and associate each server with its correct class.

It is possible to make exceptions to Fetch Apply's automatic class identification by including an `assignments` file within a class directory. In this file, you should list, one per line, the hostname of each system to which you would also like the class applied. This will force the class to be applied to any specified hosts, regardless of whether or not their hostname matches with the class name. If you wish to disable automatic class detection and assignment altogether, and opt for manually assigning each host to its class(es) via `assignments` files within your class directories, then you may set `fa_var_AUTOMATIC_CLASS_ASSIGNMENT` equal to `false`, in your Fetch Apply configuration file (located at `/etc/fetchapply`).

While `assignments` files are optional, keep in mind that every class directory **must** contain the following files (although they may be left blank):

- `initializers`
- `modules`
- `roles`

## Hosts

Host directories are contained within a class directory, and are used to override a class's `initializers`, `modules`, `roles`, and `variables`, for a specific host.

A host directory must be contained within a class directory that applies to the system it is targeting, and the host directory's name must be an exact match to the hostname of the target system.

For the applicable host, all class Special Files (except for class variables) will be ignored, and only the Special Files contained within the host directory will be executed. However, in the event that a Special File is missing from the host directory, the class's Special File will be executed instead.

As has been mentioned above, every host directory **may** contain the following files (and they may be left blank):

- `initializers`
- `modules`
- `roles`
- `variables`

## Initializers

Initializers are installation/set-up scripts that are designed to only be run once. Their goal is to "initialize" (configure) a system, and shall only be run once on that system.

Initializers are created by adding a file with the desired commands to be run, to the `initializers` directory. The name of the file you create will be the name of that initializer.

## Modules

Modules are collections of code that share a single, common purpose. Generally, a module will be designated a program or task, and then labeled accordingly. For example, you may have one module to handle firewall rules, another to update the system, and a third to configure a database. If the module will, for the most part, be working with a single program, then the convention is to label the module with that program's name. In this example, the modules may be named `ufw`, `apt`, and `postgresql`, respectively.

Apart from initializers, modules are the only entity containing actual code/commands to be run on your system. By default (unless a different time interval is specified during installation), every (applicable) module is run once every 24 hours. Therefore, it is important to design your modules with redundancy in mind. In other words, make sure that your modules are meant to be run more than once, and will not "break" anything by doing so. If you would only like code to be run once, use an initializer instead.

To create a module, make a new directory within your `modules` directory. The title of this directory will be the module's name. Within the new directory you just made, create the required `apply` file, and the optional `variables` file. When your module is to be run, Fetch Apply will load any module-specific variables from the `variables` file, and then run any code you've written in the `apply` file.

Apart from the two, reserved files, you may create as many additional, supporting files and directories as you wish within the module's directory. Common supporting files include configuration file templates and custom code. Subdirectories are frequently used to isolate different versions of the same code, each crafted for a specific Operating System or version.

Remember that the `apply` file is the "command center" for your module, and is the only file that Fetch Apply will run. If you use supporting files, they must be referenced or run from the `apply` file.

For example, if you have a Python script that you wish to run as part of the module, make sure to call it from `apply`:

```bash
python3 pythonScriptName.py
```

If you have logic to determine which subdirectory's code to run, it should also be done from within `apply`:

```bash
if [ "$(lsb_release -a | grep Release: | awk '{print $2}')" == "20.04" ]
then
    # Run the apply script specified under the Ubuntu 20.04 directory:
    source ./Ubuntu20.04Subdirectory/apply
elif [ "$(lsb_release -a | grep Release: | awk '{print $2}')" == "18.04" ]
then
    # Run the main script specified under the Ubuntu 18.04 directory:
    python3 Ubuntu18.04Subdirectory/main.py
else
    # If no match found, run this default script:
    source defaultApply
    # Note: you could also use a variable instead of grabbing the release version, or you could grep for the description to get the OS instead of just the release number, etc.
fi
```

If you're writing custom configuration files, they should also be done from within `apply`:

```bash
mo configFile.template > /etc/configuration
```

Note: Fetch Apply comes bundled with `mo` by default (and it is sourced automatically, so there is no need to `source mo` in your `apply` file). This allows you to use mustache-style templates with your modules, as demonstrated above. For information on how to format these templates, see the [mo documentation](https://github.com/tests-always-included/mo "mo documentation").

## Roles

A role is a group of modules that frequently work together towards completing a general goal, or share some sort of relation with one another. Roles are made by creating a file within the `roles` directory, and listing, one module per line, the name of each module that makes-up that role. The name of the created role is the name of the file containing its grouped modules.

For example, to create a "security" role, we would create a file named `security` within the `roles` directory, and then add all of our security-related modules to it, as such:

```
iptables
sshd
fail2ban
motd
```

# Examples

### Some current, production examples:

- [Priveasy Server Configurations](https://github.com/P5vc/ServerConfigurations "Priveasy Server Configurations")

# Final Thoughts

It is now up to you to experiment and get creative! If you have any questions, comments, or suggestions, don't hesitate to create issues, pull requests, or email us. We're always looking to better our community (and our documentation, examples, etc.), and hope that Fetch Apply can help you, as much as it's helped us!
