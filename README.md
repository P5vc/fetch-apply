# Fetch Apply

Transparent Server Configuration and Management

###### Inspired by [aviary.sh](https://github.com/team-video/aviary.sh "aviary.sh")

------------

## About

Fetch Apply is a simple system configuration and management framework designed for transparency. Fetch Apply has many, wonderful advantages and features... here are just a few:

- Written in Bash
  - Fetch Apply is written in Bash, the standard language behind most commandlines, allowing for streamlined management in a single, simple language.
- Small codebase
  - Fetch Apply's entire codebase is minuscule, and contained within a single file. Fetch Apply's purpose is to assist with user-auditable, simple, server management, something that can becomes unrealistic with large codebases and dependencies.
- Standardized but customizable
  - Fetch Apply uses a standardized framework, with simple terminology, making it easy to use and eliminating the learning curve. The code is simple and descriptive, meaning that Fetch Apply can be customized to suit your needs in a snap.

## Installation

To install and run Fetch Apply on your system, simply run the following commands:

```bash
curl https://raw.githubusercontent.com/P5vc/FetchApply/master/install -o /tmp/install
sudo bash /tmp/install
sudo fa
```

## Usage

Learning how to use Fetch Apply is extremely easy, and can be boiled-down to two main steps:

1. Learning the command
2. Learning the framework

### Learning the Command

Running Fetch Apply from start to finish is admittedly a bit complicated, and it may take some time to memorize its intricacies. But, if you're willing to put in the time and effort, I can assure you that it will be worth-while.

Are you ready?

Here's what you need to memorize:

```bash
sudo fa
```

Yup. That's it. Just type `fa` into your terminal... and you're done!

The full command documentation, for those of you interested:

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
  fetch                    Update local database by fetching from upstream
  recover                  Reset run lock file after a failure
  pause                    Set the pause lock to avoid periodic runs while debugging
  resume                   Resume periodic runs after a pause
  list-classes             List all classes
  list-modules             List all modules
  list-roles               List all roles
```

### Learning the Framework

Fetch Apply works by fetching the desired system configuration from a repository of your choosing (public or private), and then applying that configuration to the system on which Fetch Apply itself was installed.

#### Base Structure

In order for Fetch Apply to understand your server configuration, you must start with (and maintain) this standard structure:

```
.
├── classes
├── initializers
├── modules
├── roles
└── variables
```

Where `classes`, `initializers`, `modules`, and `roles` are directories and `variables` is a file.

To create this base structure quickly, feel free to run the following command inside of a designated folder:

```
mkdir classes initializers modules roles && touch variables
```

#### Variables

In addition to the global `variables` file, any directory containing code to be executed, must include a `variables` file within it. The specific directories requiring `variables` files are:

1. The base directory
2. Class directories
3. Host directories
4. Module directories

Fetch Apply will automatically scan those directories and load any applicable variables found within them.

- The `variables` file in the base directory is to be used for storing global variables.
- The `variables` file in a class directory is to be used for storing variables that will only apply to systems that fit within that class.
- The `variables` file in a host directory is to be used for storing variables that will only apply to that one, specific host.
- The `variables` file found in a module directory is to be used for storing variables that will only apply to that one, specific module.

All applicable variables will be loaded, and be accessible for use within your code (without the need to "source" anything). That means that not only will you have access to the variables stored in the same directory as, say, a specific host, but you will also be able to reference that host's class's variables, as well as the global variables. In the case that two identical variables are declared, precedence is as follows (from winner to loser): modules -> hosts -> classes -> global

#### Classes

Classes are used to distinguish between types of systems. Within the `classes` directory, you may create specifically-named directories to separate your systems/devices/servers into distinct groups.

Fetch Apply will determine which class applies by searching for the first directory within the `classes` directory, that contains the system it's installed-on's hostname.

For example, let's say that you have the following servers that you need to maintain:

- Webservers
  - `webserver1`
  - `new-york-webserver2`
  - `Webserver-fallback`
- Database Servers
  - `DATABASE-server-1`
  - `database2`
  - `databasethree`

These servers can be easily split-up into the following two categories:

- `webserver`
- `database`

Servers within the `webserver` class will likely share similar maintenance tasks, installation procedures, etc. The same applies to the database servers. Therefore, instead of having to re-write code to set up each server, we can simply create two classes: `webserver` and `database`.

Because each webserver's hostname contains `webserver` somewhere within it, and each database server's hostname contains `database` somewhere within it, yet no webserver's hostname contains `database` within it and no database server's hostname contains `webserver` within it, Fetch Apply will automatically identify and associate each server with its correct class.

Every class directory must contain the following files (although they may be left blank):

- `initializers`
- `modules`
- `roles`
- `variables`

#### Hosts

Host directories are contained within a class directory, and are used to override a class's `initializers`, `modules`, `roles`, and `variables`, for that specific host.

A host directory must be contained within a class directory that applies to the system it is targeting, and the host directory's name must be an exact match to the hostname of the target system.

For the applicable host, all class files (except for class variables) will be ignored, and only files contained within the host directory will be executed.

Every host directory must contain the following files (although they may be left blank):

- `initializers`
- `modules`
- `roles`
- `variables`

#### Initializers

Initializers are installation/set-up scripts that are designed to only be run once, when first configuring a system, and after that shall not be run again.

Initializers are created by adding a file with the desired commands to the `initializers` directory.

#### Modules

Modules are pieces of code that have a specific task or job. Modules are generally related to a single program, and are labeled with that program's name.

To create a module, make a new directory within the `modules` directory. The title of this directory will be the module's name. Within the new directory you just made, create the following two, required files: `variables` and `apply`.

The `variables` file will contain any variables specific to the module. If no extra variables are needed, this file may be left blank. The `apply` module must contain the code to run, in order for the module to be executed. You may create as many additional, supporting files as you wish (such as templates), within the same directory.

#### Roles

A role is a group of modules that work towards completing a specific goal, or share some sort of relation with one another. Roles are created by editing a file within the `roles` directory, and listing, one module per line, the name of each module that makes-up that role. The name of the created role is the name of the file containing its grouped modules.

#### Putting it Together

There is a lot of detail above about the different aspects of the Fetch Apply framework. However, I can assure you that it is much less complicated than it seems. With less than 500 lines of code, there's no way we could make it as overwhelming as it may at first seem to you.

Let's start piecing it all together, and get an overview of how everything works together.

First let's start by looking at an example of a completed configuration:

```
.
├── classes
│   ├── database
│   │   ├── initializers
│   │   ├── modules
│   │   ├── roles
│   │   └── variables
│   └── webserver
│       ├── initializers
│       ├── modules
│       ├── roles
│       ├── variables
│       ├── webserver0
│       │   ├── initializers
│       │   ├── modules
│       │   ├── roles
│       │   └── variables
│       └── webserver1
│           ├── initializers
│           ├── modules
│           ├── roles
│           └── variables
├── initializers
│   └── webserverInit
├── modules
│   └── apt
│       ├── apply
│       └── variables
├── roles
│   └── webserverMaintenance
└── variables
```

As you can see, we have the standard `classes`, `initializers`, `modules`, and `roles` directories. We also have a global `variables` file.

In this simple setup, the global `variables` file is left blank. So far, we do not have any shared variables amongst all hosts.

Under `classes`, we have created two two subdirectories, one that will apply to all of our webservers, and one that will apply to all of our database servers. However, unlike all of our identical database servers, two of our webservers are running separate web applications, and must be set up separately. Therefore we created the `webserver0` and `webserver1` directories, in order to apply custom configurations to them.

We filled in our class and host directories with the required, default files.

Under the `modules` directory, we created an `apt` directory. Within that directory are the required `apply` and `variable` files. Once again, we left the `variables` file blank. The `apply` file, however, contains some simple commands:

```
apt-get update
apt-get upgrade -y
```

This fully-functioning module, when run, will upgrade any existing packages on our system.

Now that our base has been set up, let's start populating all of these blank files.

First, we create an initializer, to set up our webservers. Under the `initializers` directory we create the `webserverInit`, and fill it with some commands that we use to set up and install the correct applications onto our webservers. Then we edit the `./classes/webserver/initializers` file, and add a line with `webserverInit` in it. Now, all of our webservers will automatically run our initialization script, the first time that Fetch Apply is run on them... well, all except for `webserver0` and `webserver1`. They have custom files, which are currently blank... so nothing will be done on those servers.

Next, we create a roll. Under the `roles` directory, we create the `webserverMaintenance` file. Within this file, we add a line that says `apt`. This will mean that any server assigned this roll will run the `apt` module. We plan to add many more modules in the future that will be essential to maintaining our webserver, so we think that making it part of a single roll will be easier. To apply this roll to our webservers, we edit the `./classes/webserver/roles` file, and add a line containing the name of our new role: `webserverMaintenance`. We also add this line to the `roles` file within the `webserver0` host directory, as we would also like it to apply to that webserver. To be honest, now that we think about it, `apt` would be a good module to apply to our database servers as well, however we don't have any other, future modules planned, for us to add to our database servers. So, instead of creating a new role, we're going to add the module ad-hoc. To do this, we simply edit the `./classes/database/modules` file and add a line with the name of our module: `apt`. Now, this module will be applied to our database servers as well.

#### Final Thoughts

It is now up to you to experiment and get creative! If you have any questions, comments, or suggestions, don't hesitate to create issues, pull requests, or email us. We're always looking to better our community (and our documentation, examples, walk-throughs, etc.), and hope that Fetch Apply can help you, as much as it's helped us!
