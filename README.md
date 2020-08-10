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
