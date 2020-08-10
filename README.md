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
2. Learning the framework structure

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

### Learning the Framework Structure

Fetch Apply works by fetching the desired system configuration from a repository of your choosing (public or private), and then applying that configuration to the system on which Fetch Apply itself was installed.

In order for Fetch Apply to understand your server configuration, it must follow the standard structure, as outlined below:

- Variables (File)
  - At the base of your repository, you must include a variables file. This file will be home to any global variables you wish to set, which will apply across all systems and configurations.

Some things to keep in mind:

- While every folder and file mentioned above must be present, they do not necessarily have to be populated. It is perfectly fine to leave as many files and folders as you'd like, blank.
