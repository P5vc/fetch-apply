#!/usr/bin/env sh

fa_func_usage() {
printfc "Fetch Apply: the transparent system configuration and management framework\n\n"
printfc "Usage:\n  ${fa_var_launch_command} [command|utility] [OPTION]...\n\n"
cat <<EOF
Commands:
  assignments              Show all assignments for this system
  clear-inits              Allow applied initializers to run one more time
  clear-patches            Allow applied patches to run one more time
  pause                    Set the pause lock to prevent full runs (-f to override)
  recover                  Unset the run lock after an error occurred during a run
  reset                    Reset/clean operations repository to match the remote origin
  resume                   Unset the pause lock and enable Fetch Apply runs
  run                      Perform a full run (default command when none specified)
  run <name>               Run the specified role or module ad hoc (see options -m,-r)
  status                   Display detailed Fetch Apply status information
  update                   Update operations repository by pulling from remote origin

Utilities:
  configure                Generate a Fetch Apply configuration file

Options:
  --dry-run,   -d           Preview a command without actually applying any operations
  --force,     -f           Run even if a pause or run lock is set
  --help,      -h           Show this help message
  --modules,   -m           Only run assigned modules, not roles
  --no-update, -n           Don't update the operations repository while running
  --quiet,     -q           Only print Warning and Error messages
  --roles      -r           Only run modules from assigned roles
EOF
}

fa_func_set_default_configuration() {
    BASH_VERSION=${BASH_VERSION:-}
    if [ -n "$BASH_VERSION" ]
    then
        fa_var_SHELL="$(command -v bash)"
    else
        fa_var_SHELL="unknown"
    fi
    if [ -n "$(command -v hostname)" ]
    then
        fa_var_SYSTEM_ID="$(hostname)"
    else
        fa_var_SYSTEM_ID=""
    fi
    if [ -n "$(command -v git)" ] && [ -d "${fa_var_root}/operations/.git" ]
    then
        fa_var_GIT_ENABLED="true"
        fa_var_OPS_REPO_BRANCH="$(git -C "${fa_var_root}/operations" branch --show-current)"
    else
        fa_var_GIT_ENABLED="false"
        fa_var_OPS_REPO_BRANCH="main"
    fi
    fa_var_CRON_SCHEDULE=""
    fa_var_LOG_FILE="None"
    fa_var_MAX_LOG_LENGTH="25000"
    fa_var_AUTOMATIC_ASSIGNMENT="true"
    fa_var_CASE_SENSITIVE="false"
    fa_var_AUTO_UPDATE="false"
    fa_var_SKIP_UNMODIFIED="false"
    fa_var_IGNORE_ERRORS="true"
    fa_var_UNIQUE="false"
    fa_var_COLOR_PALETTE="Dracula"
}

fa_func_load_configuration() {
    if [ -z "$fa_var_configuration_file" ]
    then
        fa_func_set_default_configuration
    else
        SYSTEM_ID() { # Here in case SYSTEM_ID not defined in configuration file
            printf ""
        }
        . "$fa_var_configuration_file"
        fa_var_SHELL="${RUN_SHELL:-}"
        fa_var_SYSTEM_ID="$(SYSTEM_ID)"
        fa_var_GIT_ENABLED="${GIT_ENABLED:-}"
        fa_var_CRON_SCHEDULE="${CRON_SCHEDULE:-}"
        fa_var_LOG_FILE="${LOG_FILE:-}"
        fa_var_MAX_LOG_LENGTH="${MAX_LOG_LENGTH:-}"
        fa_var_AUTOMATIC_ASSIGNMENT="${AUTOMATIC_ASSIGNMENT:-}"
        fa_var_CASE_SENSITIVE="${CASE_SENSITIVE:-}"
        fa_var_OPS_REPO_BRANCH="${OPS_REPO_BRANCH:-}"
        fa_var_AUTO_UPDATE="${AUTO_UPDATE:-}"
        fa_var_SKIP_UNMODIFIED="${SKIP_UNMODIFIED:-}"
        fa_var_IGNORE_ERRORS="${IGNORE_ERRORS:-}"
        fa_var_UNIQUE="${UNIQUE:-}"
        fa_var_COLOR_PALETTE="${COLOR_PALETTE:-}"
        unset RUN_SHELL
        unset -f SYSTEM_ID
        unset GIT_ENABLED
        unset CRON_SCHEDULE
        unset LOG_FILE
        unset MAX_LOG_LENGTH
        unset AUTOMATIC_ASSIGNMENT
        unset CASE_SENSITIVE
        unset OPS_REPO_BRANCH
        unset AUTO_UPDATE
        unset SKIP_UNMODIFIED
        unset IGNORE_ERRORS
        unset UNIQUE
        unset COLOR_PALETTE
    fi
    fa_func_correct_bools() { # Pass the setting variable value as an argument
        if [ "$1" = 'True' ] || [ "$1" = 'TRUE' ]
        then
            printf 'true'
        elif [ "$1" = 'False' ] || [ "$1" = 'FALSE' ]
        then
            printf 'false'
        else
            printf "$1"
        fi
    }
    fa_var_GIT_ENABLED="$(fa_func_correct_bools "$fa_var_GIT_ENABLED")"
    fa_var_AUTOMATIC_ASSIGNMENT="$(fa_func_correct_bools "$fa_var_AUTOMATIC_ASSIGNMENT")"
    fa_var_CASE_SENSITIVE="$(fa_func_correct_bools "$fa_var_CASE_SENSITIVE")"
    fa_var_AUTO_UPDATE="$(fa_func_correct_bools "$fa_var_AUTO_UPDATE")"
    fa_var_SKIP_UNMODIFIED="$(fa_func_correct_bools "$fa_var_SKIP_UNMODIFIED")"
    fa_var_IGNORE_ERRORS="$(fa_func_correct_bools "$fa_var_IGNORE_ERRORS")"
    fa_var_UNIQUE="$(fa_func_correct_bools "$fa_var_UNIQUE")"
    if [ "$fa_var_IGNORE_ERRORS" = 'true' ]
    then
        set +e
    else
        set -e
    fi
}

fa_func_enable_color() {
    # Set default ANSI escape sequences:
    TERM_ERASE_BELOW_CURSOR=''
    TERM_RESET=''
    TERM_FULL_RESET="${TERM_RESET}${TERM_ERASE_BELOW_CURSOR}"
    TERM_CLEAR=''
    TERM_BOLD=''
    TERM_END_BOLD=''
    TERM_FAINT=''
    TERM_END_FAINT=''
    TERM_ITALIC=''
    TERM_END_ITALIC=''
    TERM_UNDERLINE=''
    TERM_END_UNDERLINE=''
    TERM_BLINKING=''
    TERM_END_BLINKING=''
    TERM_STRIKETHROUGH=''
    TERM_END_STRIKETHROUGH=''
    TERM_BG=''
    TERM_FG=''
    TERM_BLACK=''
    TERM_GRAY=''
    TERM_WHITE=''
    TERM_RED=''
    TERM_ORANGE=''
    TERM_YELLOW=''
    TERM_GREEN=''
    TERM_BLUE=''
    TERM_CYAN=''
    TERM_VIOLET=''
    TERM_MAGENTA=''
    if [ "$fa_var_COLOR_PALETTE" != 'None' ]
    then
        TERM_ERASE_BELOW_CURSOR="\e[0J"
        TERM_RESET="\e[0m"
        TERM_FULL_RESET="${TERM_RESET}${TERM_ERASE_BELOW_CURSOR}"
        TERM_CLEAR="\e[2J\e[H"
        TERM_BOLD="\e[1m"
        TERM_END_BOLD="\e[22m"
        TERM_FAINT="\e[2m"
        TERM_END_FAINT="\e[22m"
        TERM_ITALIC="\e[3m"
        TERM_END_ITALIC="\e[23m"
        TERM_UNDERLINE="\e[4m"
        TERM_END_UNDERLINE="\e[24m"
        TERM_BLINKING="\e[5m"
        TERM_END_BLINKING="\e[25m"
        TERM_STRIKETHROUGH="\e[9m"
        TERM_END_STRIKETHROUGH="\e[29m"
    fi
    if [ "$fa_var_COLOR_PALETTE" = "Dracula" ]
    then # Default, built-in color palette chosen
        # Color palette license (including copyright and permission notice):
        # https://github.com/dracula/dracula-theme/blob/master/LICENSE
        TERM_BLACK="\e[38;5;59m\e[38;2;40;42;54m"
        TERM_GRAY="\e[38;5;60m\e[38;2;68;71;90m"
        TERM_WHITE="\e[38;5;231m\e[38;2;248;248;242m"
        TERM_RED="\e[38;5;210m\e[38;2;255;85;85m"
        TERM_ORANGE="\e[38;5;222m\e[38;2;255;184;108m"
        TERM_YELLOW="\e[38;5;229m\e[38;2;241;250;140m"
        TERM_GREEN="\e[38;5;120m\e[38;2;80;250;123m"
        TERM_BLUE="\e[38;5;103m\e[38;2;98;114;164m"
        TERM_CYAN="\e[38;5;159m\e[38;2;139;233;253m"
        TERM_VIOLET="\e[38;5;183m\e[38;2;189;147;249m"
        TERM_MAGENTA="\e[38;5;212m\e[38;2;255;121;198m"
        TERM_BG="\e[48;5;59m\e[48;2;40;42;54m"
        TERM_FG="$TERM_WHITE"
        TERM_RESET="${TERM_RESET}${TERM_BG}${TERM_FG}"
    elif [ -e "${fa_var_root}/palette" ]
    then
        . "${fa_var_root}/palette"
    fi
    printf "${TERM_RESET}${TERM_ERASE_BELOW_CURSOR}"

    # Create a function to enable easy, colorized printing:
    printfc() {
        printf "${TERM_BG}${TERM_FG}"
        printf "$@"
    }
}

fa_func_log() {
    fa_var_style="$TERM_FG"
    fa_var_log_message=""
    if [ "$1" = "Error" ]
    then
        fa_var_log_message="Error: ${2}"
        fa_var_style="${TERM_RED}${TERM_BOLD}${TERM_UNDERLINE}Error"
        fa_var_style="${fa_var_style}${TERM_END_BOLD}${TERM_END_UNDERLINE}: "
    elif [ "$1" = "Warning" ]
    then
        fa_var_log_message="Warning: ${2}"
        fa_var_style="${TERM_YELLOW}${TERM_ITALIC}${TERM_BOLD}Warning"
        fa_var_style="${fa_var_style}${TERM_END_ITALIC}${TERM_END_BOLD}: "
    elif [ "$1" = "Info" ]
    then
        fa_var_style="${TERM_CYAN}"
    elif [ "$1" = "Action" ]
    then
        fa_var_log_message="Action: ${2}"
        fa_var_style="${TERM_MAGENTA}"
    elif [ "$1" = "Processing" ]
    then
        fa_var_style="${TERM_GRAY}"
    elif [ "$1" = "Success" ]
    then
        fa_var_log_message="Success: ${2}"
        fa_var_style="${TERM_GREEN}${TERM_BOLD}Success${TERM_END_BOLD}: "
    else
        fa_var_style="${TERM_VIOLET}${TERM_BOLD}"
    fi

    if [ -n "$fa_var_log_message" ] && [ "$fa_var_can_write_log_file" = "true" ]
    then
        printf '%s %s\n' "$(date)" "${fa_var_log_message}" >> "$fa_var_LOG_FILE"
    fi
    if [ "$1" = 'Error' ] || [ "$1" = 'Warning' ]
    then
        printfc "${fa_var_style}${2}${TERM_RESET}\n" 1>&2
        printfc "" 1>&2
    else
        if [ "$fa_var_quiet" = 'false' ]
        then
            printfc "${fa_var_style}${2}${TERM_RESET}\n"
            printfc ""
        fi
    fi
}

fa_func_handle_exit() {
    fa_var_exit_code="$?"
    fa_var_failed_command="${BASH_COMMAND:-unknown}"
    printfc "$TERM_END_FAINT"
    if [ -n "$fa_var_status" ] && [ -d "$fa_var_status" ]
    then
        if [ -f "${fa_var_status}/.first_run" ] && \
            [ ! -s "${fa_var_status}/applied-initializers" ] && \
            [ ! -s "${fa_var_status}/applied-patches" ] && \
            [ ! -s "${fa_var_status}/completed-runs" ]
        then
            if [ -z "$(ls -p1 "${fa_var_status}/" | grep '/$' || true)" ]
            then # Extra sure that it's okay to rm -rf this directory
                fa_func_log Action "Removing status directory..."
                rm -rf "${fa_var_status}"
            fi
        else
            rm -f "${fa_var_status}/class-priorities"
            rm -f "${fa_var_status}/fetch-apply-cron"
            rm -f "${fa_var_status}/"*"-variables"
        fi
    fi
    if [ "$fa_var_exit_code" = "0" ]
    then
        if [ "$fa_var_lock_set_this_run" = "true" ] && [ -n "$fa_var_lock_file" ]
        then
            rm -f "$fa_var_lock_file"
        fi
    elif [ "$fa_var_exit_code" = "90" ]
    then
        if [ "$fa_var_lock_set_this_run" = "true" ] && [ -n "$fa_var_lock_file" ]
        then
            rm -f "$fa_var_lock_file"
        fi
        fa_func_log Success "Finished!"
        printf "${TERM_FULL_RESET}"
        printf "${TERM_FULL_RESET}" 1>&2
        cd "$fa_var_starting_directory"
        exit 0
    elif [ "$fa_var_exit_code" = "91" ]
    then
        fa_func_log Action "Exiting..."
    else
        if [ "$(basename "$fa_var_SHELL")" = "bash" ]
        then
            fa_func_log Warning "The command '${fa_var_failed_command}' failed with exit code ${fa_var_exit_code}."
        else
            fa_func_log Warning "A command failed with exit code ${fa_var_exit_code}."
        fi
        fa_func_log Action "Exiting..."
    fi
    printf "${TERM_FULL_RESET}"
    printf "${TERM_FULL_RESET}" 1>&2
    cd "$fa_var_starting_directory"
}

fa_func_handle_interrupt() {
    printfc "${TERM_END_FAINT}\n"
    fa_func_log Warning "An interrupt signal has been caught by Fetch Apply"
    if [ -n "$fa_var_currently_running" ]
    then
        fa_func_log Error "The file '${fa_var_currently_running}' was running when the interrupt occurred"
    fi
    exit 91
}

fa_func_validate_settings() {
    fa_func_check_blank_setting() { # Pass the setting variable name and value as arguments
        if [ -z "$2" ]
        then
            fa_func_log Error "The '${1}' setting is required and cannot be blank!"
            exit 91
        fi
    }

    fa_func_check_bool_setting() { # Pass the setting variable name and value as arguments
        if [ "$2" != "true" ] && [ "$2" != "false" ]
        then
            fa_func_check_blank_setting "$1" "$2"
            fa_func_log Error "The '${1}' setting must be equal to either 'true' or 'false'!"
            exit 91
        fi
    }

    fa_func_check_blank_setting "RUN_SHELL" "$fa_var_SHELL"
    fa_func_check_bool_setting "GIT_ENABLED" "$fa_var_GIT_ENABLED"
    fa_func_check_blank_setting "OPS_REPO_BRANCH" "$fa_var_OPS_REPO_BRANCH"
    fa_func_check_bool_setting "AUTO_UPDATE" "$fa_var_AUTO_UPDATE"
    fa_func_check_bool_setting "SKIP_UNMODIFIED" "$fa_var_SKIP_UNMODIFIED"
    fa_func_check_blank_setting "LOG_FILE" "$fa_var_LOG_FILE"
    fa_func_check_blank_setting "MAX_LOG_LENGTH" "$fa_var_MAX_LOG_LENGTH"
    fa_func_check_bool_setting "AUTOMATIC_ASSIGNMENT" "$fa_var_AUTOMATIC_ASSIGNMENT"
    fa_func_check_bool_setting "CASE_SENSITIVE" "$fa_var_CASE_SENSITIVE"
    fa_func_check_blank_setting "COLOR_PALETTE" "$fa_var_COLOR_PALETTE"
    fa_func_check_bool_setting "UNIQUE" "$fa_var_UNIQUE"
    fa_func_check_bool_setting "IGNORE_ERRORS" "$fa_var_IGNORE_ERRORS"

    if [ ! -w "$fa_var_root" ]
    then
        fa_func_log Info "Cannot create or modify files in Fetch Apply directory ('${fa_var_root}')"
        fa_func_log Error "Insufficient permissions"
        fa_func_log Info "Try running Fetch Apply with 'sudo'"
        exit 91
    fi

    if [ -z "$fa_var_SYSTEM_ID" ] && [ "$fa_var_running_utility" = "false" ]
    then
        if [ -z "$fa_var_configuration_file" ]
        then
            fa_func_log Info "The 'hostname' command could not be found"
            fa_func_log Info "The 'SYSTEM_ID' setting must be configured in order to continue"
            fa_func_log Error "Unable to set a default System ID"
            exit 91
        else
            fa_func_log Error "The 'SYSTEM_ID' setting cannot resolve to a blank value"
            exit 91
        fi
    else
        if [ -z "$fa_var_configuration_file" ] && [ "$fa_var_running_utility" = "false" ]
        then
            fa_func_log Info "Using hostname '$fa_var_SYSTEM_ID' as default 'SYSTEM_ID' value"
        fi
    fi
    if [ "$fa_var_GIT_ENABLED" = "true" ] && [ -z "$(command -v git)" ]
    then
        fa_func_log Info "The setting 'GIT_ENABLED' is set to 'true'"
        fa_func_log Error "The 'git' command could not be found"
        exit 91
    fi
    if [ "$fa_var_GIT_ENABLED" = "true" ] && [ ! -d "${fa_var_operations}/.git" ] && \
        [ "$fa_var_running_utility" = "false" ] && [ -n "$(ls "${fa_var_operations}")" ]
    then
        fa_func_log Info "The setting 'GIT_ENABLED' is set to 'true'"
        fa_func_log Error "No git repository detected in '${fa_var_operations}'"
        exit 91
    fi
    if [ "$fa_var_AUTO_UPDATE" = "true" ] && [ "$fa_var_GIT_ENABLED" != "true" ]
    then
        fa_func_log Error "The 'AUTO_UPDATE' setting cannot be set to 'true' if 'GIT_ENABLED' is 'false'"
        exit 91
    fi
    if [ "$fa_var_SKIP_UNMODIFIED" = "true" ] && [ "$fa_var_AUTO_UPDATE" != "true" ]
    then
        fa_func_log Error "The 'SKIP_UNMODIFIED' setting cannot be set to 'true' if 'AUTO_UPDATE' is 'false'"
        exit 91
    fi
    if [ "$fa_var_LOG_FILE" != 'None' ]
    then
        touch "$fa_var_LOG_FILE" 2>/dev/null
        if [ ! -w "$fa_var_LOG_FILE" ]
        then
            fa_func_log Info "Cannot write to log file ('${fa_var_LOG_FILE}')"
            fa_func_log Error "Insufficient permissions"
            fa_func_log Info "Try running Fetch Apply with 'sudo'"
            exit 91
        fi
    fi
    if [ "$fa_var_MAX_LOG_LENGTH" != "-1" ] && [ "$fa_var_MAX_LOG_LENGTH" -lt "4" ] && [ "$fa_var_LOG_FILE" != "None" ]
    then
        if [ "$fa_var_running_utility" = "true" ]
        then
            fa_func_log Error "The 'MAX_LOG_LENGTH' setting cannot be set to a whole number less than '4'"
        else
            fa_func_log Warning "The 'MAX_LOG_LENGTH' setting cannot be set to a whole number less than '4'"
            fa_func_log Action "Setting 'MAX_LOG_LENGTH' equal to '4' for this run..."
            fa_var_MAX_LOG_LENGTH="4"
        fi
    fi
    if [ -n "$fa_var_configuration_file" ] && [ -d "/etc/cron.d" ] && [ "$fa_var_running_utility" = "false" ]
    then # Update cron job to use latest CRON_SCHEDULE from a configuration
        if [ -n "$fa_var_CRON_SCHEDULE" ]
        then
            if [ -e "/etc/cron.d/fetch-apply" ]
            then
                printf "SHELL=${fa_var_SHELL}\nPATH=${PATH}\n" > "${fa_var_status}/fetch-apply-cron"
                printf "${fa_var_CRON_SCHEDULE} root ${fa_var_launch_command}\n" >> "${fa_var_status}/fetch-apply-cron"
                if [ "$(cat "/etc/cron.d/fetch-apply")" != "$(cat "${fa_var_status}/fetch-apply-cron")" ]
                then
                    if [ -w "/etc/cron.d" ]
                    then
                        fa_func_log Action "Updating Fetch Apply cron job schedule..."
                        printf "SHELL=${fa_var_SHELL}\nPATH=${PATH}\n" > "/etc/cron.d/fetch-apply"
                        printf "${fa_var_CRON_SCHEDULE} root ${fa_var_launch_command}\n" >> "/etc/cron.d/fetch-apply"
                    else
                        fa_func_log Info "Cannot create or modify files in '/etc/cron.d'"
                        fa_func_log Error "Insufficient permissions to update cron job"
                        fa_func_log Info "Try running Fetch Apply with 'sudo'"
                    fi
                fi
            else
                if [ -w "/etc/cron.d" ]
                then
                    fa_func_log Action "Creating Fetch Apply cron job..."
                    printf "SHELL=${fa_var_SHELL}\nPATH=${PATH}\n" > "/etc/cron.d/fetch-apply"
                    printf "${fa_var_CRON_SCHEDULE} root ${fa_var_launch_command}\n" >> "/etc/cron.d/fetch-apply"
                else
                    fa_func_log Info "Cannot create or modify files in '/etc/cron.d'"
                    fa_func_log Error "Insufficient permissions to create cron job"
                    fa_func_log Info "Try running Fetch Apply with 'sudo'"
                fi
            fi
            rm -f "${fa_var_status}/fetch-apply-cron"
        else
            if [ -e '/etc/cron.d/fetch-apply' ]
            then
                fa_func_log Info "The 'CRON_SCHEDULE' setting is blank"
                if [ -w '/etc/cron.d/fetch-apply' ]
                then
                    fa_func_log Action "Deleting Fetch Apply cron job..."
                    rm -f '/etc/cron.d/fetch-apply'
                else
                    fa_func_log Info "Cannot delete Fetch Apply cron job"
                    fa_func_log Error "Insufficient permissions to remove '/etc/cron.d/fetch-apply'"
                    fa_func_log Info "Try running Fetch Apply with 'sudo'"
                fi
            fi
        fi
    fi
}

fa_func_log_trim() {
    if [ "$fa_var_MAX_LOG_LENGTH" = '-1' ]
    then
        fa_func_log Info "Skipping log check: maximum size set to unlimited..."
    else
        if [ "$fa_var_LOG_FILE" = "None" ]
        then
            fa_func_log Info "Skipping log check: logging disabled..."
        else
            fa_func_log Info "Inspecting Fetch Apply log..."
            if [ ! -e "$fa_var_LOG_FILE" ]
            then
                touch "$fa_var_LOG_FILE"
            fi
            if [ "$(cat "$fa_var_LOG_FILE" | wc -l)" -ge "$fa_var_MAX_LOG_LENGTH" ]
            then
                fa_func_log Action "Rotating Fetch Apply log..."
                rm -f "${fa_var_LOG_FILE}.old"
                mv "${fa_var_LOG_FILE}" "${fa_var_LOG_FILE}.old"
                touch "${fa_var_LOG_FILE}"
                fa_func_log Success "The Fetch Apply log was rotated..."
            fi
            if [ "$(cat "${fa_var_status}/completed-runs" | wc -l)" -ge "$fa_var_MAX_LOG_LENGTH" ]
            then
                fa_func_log Action "Trimming Fetch Apply status file..."
                sed -i "1,$(($fa_var_MAX_LOG_LENGTH / 2))d" "${fa_var_status}/completed-runs"
                fa_func_log Success "The Fetch Apply status file has been trimmed..."
            fi
        fi
    fi
}

fa_func_repo_maintenance() {
    if [ -z "$(ls -1 "${fa_var_operations}")" ]
    then
        fa_func_log Error "Operations repository is empty"
        exit 91
    fi
    if [ "$fa_var_GIT_ENABLED" = "true" ]
    then
        if [ "$fa_var_OPS_REPO_BRANCH" != "$(git -C "${fa_var_operations}" branch --show-current)" ]
        then
            fa_var_current_branch="$(git -C "${fa_var_operations}" branch --show-current)"
            fa_func_log Action "Switching operations repository branch from '${fa_var_current_branch}' to '${fa_var_OPS_REPO_BRANCH}'..."
            git -C "${fa_var_operations}" checkout "$fa_var_OPS_REPO_BRANCH"
            if [ "$fa_var_OPS_REPO_BRANCH" != "$(git -C "${fa_var_operations}" branch --show-current)" ]
            then
                fa_func_log Error "Unable to switch operations repository to branch '${fa_var_OPS_REPO_BRANCH}'"
                exit 91
            fi
        fi

        if [ "$fa_var_AUTO_UPDATE" = "true" ] && [ "$fa_var_dry_run" = "false" ]
        then
            fa_func_log Action "Updating the operations repository..."
            printfc "${TERM_FAINT}"
            if [ -z "$(git -C "${fa_var_operations}" status --porcelain)" ]
            then
                git -C "${fa_var_operations}" pull
            else
                fa_func_log Warning "Operations repository checkout is dirty"
                fa_func_log Error "Unable to pull the remote operations repository"
                exit 91
            fi
            printfc "${TERM_END_FAINT}"
        else
            fa_func_log Info "Skipping automatic update for operations repository..."
        fi
    fi
}

fa_func_handle_locks() {
    if [ -e "$fa_var_lock_file" ]
    then
        fa_func_log Info "Detected run lock from '$(cat "$fa_var_lock_file")'..."
        if [ "$fa_var_IGNORE_ERRORS" = "false" ]
        then
            fa_func_log Warning "An unresolved error occurred during a previous run"
            fa_func_log Info "Run '${fa_var_launch_command} recover' to mark as resolved and unset the run lock"
        fi
        if [ "$fa_var_force" = "true" ] || [ "$fa_var_IGNORE_ERRORS" = "true" ]
        then
            fa_func_log Info "Ignoring run lock and continuing..."
        else
            fa_func_log Error "Run lock is set"
            exit 91
        fi
    else
        printf "$(date)" > "$fa_var_lock_file"
        fa_var_lock_set_this_run="true"
    fi
    if [ -e "$fa_var_pause_file" ]
    then
        fa_func_log Info "Detected pause lock set on '$(cat "$fa_var_pause_file")'..."
        fa_func_log Info "Run '${fa_var_launch_command} resume' to unset the pause lock"
        if [ "$fa_var_force" = "true" ]
        then
            fa_func_log Info "Ignoring pause lock and continuing..."
        else
            fa_func_log Error "Pause lock is set"
            exit 91
        fi
    fi
}

fa_func_enable_tmpl() {
    tmpl() {
        fa_func_tmpl_usage() {
cat <<EOF 1>&2
Fetch Apply Templating Engine

Usage:
    tmpl [OPTION]... [FILE]

Options:
    --append,    -a           Append to output file instead of overwriting it
    --help,      -h           Show this help message
    --out-file,  -o <file>    Write output to the specified file
EOF
        }

        fa_func_tmpl_get_input() {
            # Get input from input file if specified, otherwise from stdin:
            fa_var_tmpl_input="$(cat "${fa_var_tmpl_input_file:-"-"}"; printf '/')"
            fa_var_tmpl_input="${fa_var_tmpl_input%/}"
            # Trailing slash added and then removed as a trick to preserve any newlines
            # that may exist at the end of the file
        }

        fa_func_tmpl_parse_next_tag() { # Pass text to search as argument
            fa_var_tmpl_text_to_search="$1"
            fa_var_tmpl_before_tag="${fa_var_tmpl_text_to_search%%"$fa_var_tmpl_open_delimiter"*}"
            fa_var_tmpl_after_tag="${fa_var_tmpl_text_to_search#*"$fa_var_tmpl_close_delimiter"}"
            fa_var_tmpl_tag="${fa_var_tmpl_text_to_search#"$fa_var_tmpl_before_tag"}"
            fa_var_tmpl_tag="${fa_var_tmpl_tag%"$fa_var_tmpl_after_tag"}"
        }

        fa_func_tmpl_render_tag() {
            fa_var_tmpl_key="${fa_var_tmpl_tag#"$fa_var_tmpl_open_delimiter"}"
            fa_var_tmpl_key="${fa_var_tmpl_key%"$fa_var_tmpl_close_delimiter"}"
            fa_var_tmpl_key="$(printf "%s" "$fa_var_tmpl_key" | tr -cd '[:print:]')"
            fa_var_tmpl_key_with_space="$fa_var_tmpl_key"
            fa_var_tmpl_key="$(printf "%s" "$fa_var_tmpl_key" | tr -d '[:space:]')"
            if [ -z "$fa_var_tmpl_key" ]
            then
                return
            fi
            if [ -z "${fa_var_tmpl_key%%"&"*}" ]
            then # This is an unescaped variable tag
                fa_func_unescaped_tag
            elif [ -z "${fa_var_tmpl_key%%"{"*}" ] && [ "$fa_var_tmpl_open_delimiter" = '{{' ]
            then # This is an unescaped variable tag
                fa_func_unescaped_tag
            elif [ -z "${fa_var_tmpl_key%%"#"*}" ]
            then # This is a section opening tag
                fa_func_tmpl_section_open
            elif [ -z "${fa_var_tmpl_key%%"^"*}" ]
            then # This is an inverted section opening tag
                fa_func_tmpl_section_open
                fa_func_tmpl_section_is_inverted
            elif [ -z "${fa_var_tmpl_key%%"/"*}" ]
            then # This is a section closing tag
                fa_func_tmpl_section_close
            elif [ -z "${fa_var_tmpl_key%%"!"*}" ]
            then # This is a comment tag
                return # Comments should not be rendered into the output
            elif [ -z "${fa_var_tmpl_key%%">"*}" ]
            then # This is a partial tag
                fa_func_tmpl_partial_tag
            elif [ -z "${fa_var_tmpl_key%%"="*}" ]
            then # This is a set delimiter tag
                fa_func_tmpl_set_deliminater_tag
            else # This must be a variable tag
                fa_func_tmpl_variable_tag
            fi
        }

        fa_func_tmpl_partial_tag() {
            fa_var_tmpl_key="${fa_var_tmpl_key#">"}"
            if [ -f "$fa_var_tmpl_key" ]
            then # Prepend the contents of the file indicated by the partial tag, to the remaining input:
                fa_var_tmpl_partial_input="$(cat "$fa_var_tmpl_key"; printf '/')"
                fa_var_tmpl_partial_input="${fa_var_tmpl_partial_input%/}"
                fa_var_tmpl_after_tag="${fa_var_tmpl_partial_input}${fa_var_tmpl_after_tag}"
                fa_var_tmpl_rendered_tag=''
            else
                fa_var_tmpl_tag_error='true'
                printf "Error: tmpl could not find the file specified by a partial!\n" 1>&2
                printf "%s\n" "The '${fa_var_tmpl_tag}' partial is invalid" 1>&2
                return 91
            fi
        }

        fa_func_tmpl_section_close() {
            fa_var_tmpl_section_close_key="$(printf "%s" "$fa_var_tmpl_key" | tr -cd '[:alnum:]_')"
            if [ "$fa_var_tmpl_section_close_key" != "$fa_var_tmpl_section_key" ]
            then
                fa_var_tmpl_tag_error='true'
                printf "Error: tmpl never began a '${fa_var_tmpl_key}' section!\n" 1>&2
                printf "%s\n" "The '${fa_var_tmpl_tag}' section closing tag is invalid" 1>&2
                return 91
            fi
            if [ "$fa_var_tmpl_render_section" = 'true' ] && [ "$fa_var_tmpl_section_is_function" = 'false' ]
            then # This isn't a function section and is meant to be rendered:
                for fa_var_tmpl_section_value_list_item in $fa_var_tmpl_section_value_list
                do # End of section reached, so remove current iteration value from list:
                    fa_var_tmpl_section_value_list="${fa_var_tmpl_section_value_list#*"${fa_var_tmpl_section_value_list_item}"}"
                    break
                done
                fa_var_tmpl_section_value_list_continues='false'
                for fa_var_tmpl_section_value_list_item in $fa_var_tmpl_section_value_list
                do
                    fa_var_tmpl_section_value_list_continues='true'
                    break
                done
                if [ "$fa_var_tmpl_section_value_list_continues" = 'true' ]
                then # More values in list, so restart section rendering with new value
                    fa_var_tmpl_after_tag="$fa_var_tmpl_after_section_open_tag"
                    return
                fi
            elif [ "$fa_var_tmpl_render_section" = 'false' ]
            then # This section isn't meant to be rendered, so clear text before closing tag
                fa_var_tmpl_before_tag=''
            fi
            if [ "$fa_var_tmpl_section_is_function" = 'true' ]
            then # This is a function section, so pass the section contents to the function to get rendered output
                fa_var_tmpl_rendered_tag="$(eval $fa_var_tmpl_section_key $fa_var_tmpl_section_content)"
            else # Done with iterations, so now save rendered contents for printing
                fa_var_tmpl_rendered_tag="${fa_var_tmpl_section_content}${fa_var_tmpl_before_tag}"
                fa_var_tmpl_before_tag=''
                fa_var_tmpl_section_content=''
                fa_var_tmpl_after_section_open_tag=''
                fa_var_tmpl_section_key_value=''
                fa_var_tmpl_section_value_list=''
                fa_var_tmpl_section_key=''
            fi
        }

        fa_func_tmpl_section_is_inverted() {
            if [ "$fa_var_tmpl_section_is_function" = 'true' ]
            then # This is a function section
                fa_var_tmpl_tag_error='true'
                printf "Error: tmpl does not support inverted function section tags!\n" 1>&2
                printf "%s\n" "The '${fa_var_tmpl_tag}' tag is invalid" 1>&2
                return 91
            else # This isn't a function section so invert the render rules:
                if [ "$fa_var_tmpl_render_section" = 'true' ]
                then
                    fa_var_tmpl_render_section='false'
                    fa_var_tmpl_section_value_list=''
                    # Manually Save before tag content for opening tag, since write_output func will skip it:
                    fa_var_tmpl_section_content="$fa_var_tmpl_before_tag"
                else
                    fa_var_tmpl_render_section='true'
                    fa_var_tmpl_after_section_open_tag="$fa_var_tmpl_after_tag"
                    fa_var_tmpl_section_value_list="$fa_var_tmpl_section_key_value"
                    fa_var_tmpl_section_content=''
                fi
            fi
        }

        fa_func_tmpl_section_open() {
            if [ -n "$fa_var_tmpl_section_key" ]
            then # Another section is still open
                fa_var_tmpl_tag_error='true'
                printf "Error: tmpl does not support nested section tags!\n" 1>&2
                printf "%s" "The '${fa_var_tmpl_tag}' tag is invalid" 1>&2
                return 91
            fi
            fa_var_tmpl_section_key="$(printf "%s" "$fa_var_tmpl_key" | tr -cd '[:alnum:]_')"
            fa_var_tmpl_section_content=''
            fa_var_tmpl_render_section='true'
            fa_var_tmpl_section_is_function='false'
            if [ -z "${fa_var_tmpl_key##*"()"}" ]
            then
                fa_var_tmpl_section_is_function='true'
            elif [ -n "$fa_var_tmpl_section_key" ]
            then # This isn't a function section, and the name is still valid after sanitization
                eval fa_var_tmpl_section_key_value="\${${fa_var_tmpl_section_key}:-}"
                if [ -z "$fa_var_tmpl_section_key_value" ] || [ "$fa_var_tmpl_section_key_value" = 'false' ]
                then
                    fa_var_tmpl_render_section='false'
                    fa_var_tmpl_section_value_list=''
                    # Manually Save before tag content for opening tag, since write_output func will skip it:
                    fa_var_tmpl_section_content="$fa_var_tmpl_before_tag"
                else
                    fa_var_tmpl_after_section_open_tag="$fa_var_tmpl_after_tag"
                    fa_var_tmpl_section_value_list="$fa_var_tmpl_section_key_value"
                fi
            fi
        }

        fa_func_tmpl_set_deliminater_tag() {
            # Change the delimiters to the specified values:
            fa_var_tmpl_key_with_space="$(printf "%s" "$fa_var_tmpl_key_with_space" | tr '[:space:]' ' ')"
            fa_var_tmpl_open_delimiter="$(printf "%s" "${fa_var_tmpl_key_with_space% *=*}" | tr -d '[:space:]' | tr -d '=')"
            fa_var_tmpl_close_delimiter="$(printf "%s" "${fa_var_tmpl_key_with_space#*=* }" | tr -d '[:space:]' | tr -d '=')"
            # Perform some error checking on the new delimiters before accepting them:
            if [ "$fa_var_tmpl_open_delimiter" = "$fa_var_tmpl_close_delimiter" ]
            then # The provided opening and closing delimiters are the same
                fa_var_tmpl_tag_error='true'
                printf "%s\n" "Error: tmpl cannot use identical opening and closing delimiters ('${fa_var_tmpl_open_delimiter}')\n" 1>&2
                return 91
            fi
            for fa_var_tmpl_opening_char in '&' '#' '^' '/' '!' '>' '='
            do
                fa_var_tmpl_test_tag="${fa_var_tmpl_open_delimiter}${fa_var_tmpl_opening_char}"
                if [ "$fa_var_tmpl_test_tag" != "${fa_var_tmpl_test_tag%*"$fa_var_tmpl_close_delimiter"*}" ]
                then # When the new opening delimiter is combined with the special characters used in the tag syntax,
                     # a pattern matching the new closing delimiter is created, which could cause runtime errors
                    fa_var_tmpl_tag_error='true'
                    printf "Error: tmpl cannot use the provided opening and closing delimiters\n" 1>&2
                    printf "%s" "When used with tag syntax, '${fa_var_tmpl_open_delimiter}' and '$fa_var_tmpl_close_delimiter' " 1>&2
                    printf "%s\n" "could create overlapping patterns" 1>&2
                    return 91
                fi
            done
        }

        fa_func_unescaped_tag() {
            printf "Warning: tmpl does not HTML escape variables!\n" 1>&2
            if [ -z "${fa_var_tmpl_key%%"&"*}" ]
            then
                printf "The '&' in the '${fa_var_tmpl_tag}' tag is redundant\n" 1>&2
                fa_var_tmpl_key="${fa_var_tmpl_key#"&"}"
            elif [ -z "${fa_var_tmpl_key%%"{"*}" ]
            then
                printf "The extra curly brace in the '${fa_var_tmpl_tag}' tag is redundant\n" 1>&2
                fa_var_tmpl_key="${fa_var_tmpl_key#"{"}"
            fi
            fa_func_tmpl_variable_tag
        }

        fa_func_tmpl_variable_tag() {
            # Replace the variable tags with the values stored by those variables
            fa_var_tmpl_sanitized_key="$(printf "%s" "$fa_var_tmpl_key" | tr -cd '[:alnum:]_')"
            if [ -n "$fa_var_tmpl_section_value_list" ] && [ "$fa_var_tmpl_sanitized_key" = "$fa_var_tmpl_section_key" ]
            then # Variable has the same name as the section variable
                for fa_var_tmpl_section_value_list_item in $fa_var_tmpl_section_value_list
                do # Use current list item from section variable as the value:
                    fa_var_tmpl_rendered_tag="$fa_var_tmpl_section_value_list_item"
                    break
                done
            else # This is a normal variable
                if [ -n "$fa_var_tmpl_sanitized_key" ]
                then # Variable still valid after sanitization; get its value:
                    eval fa_var_tmpl_rendered_tag="\${${fa_var_tmpl_sanitized_key}:-}"
                fi
            fi
        }

        fa_func_tmpl_write_output() {
            if [ -z "$fa_var_tmpl_section_key" ]
            then # Not currently within a section
                if [ -z "$fa_var_tmpl_output_file" ]
                then
                    printf "%s" "${fa_var_tmpl_before_tag}${fa_var_tmpl_rendered_tag}"
                elif [ "$fa_var_tmpl_append" = 'true' ]
                then
                    printf "%s" "${fa_var_tmpl_before_tag}${fa_var_tmpl_rendered_tag}" >> "$fa_var_tmpl_output_file"
                else
                    printf "%s" "${fa_var_tmpl_before_tag}${fa_var_tmpl_rendered_tag}" > "$fa_var_tmpl_output_file"
                    fa_var_tmpl_append='true'
                fi
            elif [ "$fa_var_tmpl_render_section" = 'true' ]
            then # Currently within a section that should be rendered
                # Save this section's newly-rendered contents to a variable for writing after the section closes:
                fa_var_tmpl_new_section_content="${fa_var_tmpl_before_tag}${fa_var_tmpl_rendered_tag}"
                fa_var_tmpl_section_content="${fa_var_tmpl_section_content}${fa_var_tmpl_new_section_content}"
            fi
            fa_var_tmpl_rendered_tag=''
        }

        fa_var_tmpl_append=''
        fa_var_tmpl_input_file=''
        fa_var_tmpl_output_file=''
        for fa_var_tmpl_argument in "$@"
        do
            case "$fa_var_tmpl_argument" in
                ('-a' | '--append')
                    fa_var_tmpl_append='true';;
                ('-h' | '--help')
                    fa_func_tmpl_usage
                    return;;
                ('-o' | '--out-file')
                    fa_var_tmpl_output_file='/';;
                (*)
                    if [ "$fa_var_tmpl_output_file" != '/' ] && [ -z "$fa_var_tmpl_input_file" ]
                    then
                        if [ ! -f "$fa_var_tmpl_argument" ]
                        then
                            printf "Error: The tmpl input file ('${fa_var_tmpl_argument}') does not exist\n" 1>&2
                            return 91
                        fi
                        fa_var_tmpl_input_file="$fa_var_tmpl_argument"
                    elif [ "$fa_var_tmpl_output_file" = '/' ]
                    then
                        if [ -d "$fa_var_tmpl_argument" ] || [ -z "${fa_var_tmpl_argument##*/}" ]
                        then
                            printf "Error: The tmpl output file ('${fa_var_tmpl_argument}') cannot be a directory\n" 1>&2
                            return 91
                        fi
                        fa_var_tmpl_output_file="$fa_var_tmpl_argument"
                    else
                        printf "%s" "Error: The tmpl option '${fa_var_tmpl_argument}' is invalid" 1>&2
                        printf "Please review the usage information below:\n\n" 1>&2
                        fa_func_tmpl_usage
                        return 91
                    fi;;
            esac
        done

        fa_var_tmpl_tag_error='false'
        fa_var_tmpl_open_delimiter='{{'
        fa_var_tmpl_close_delimiter='}}'
        fa_var_tmpl_before_tag=''
        fa_var_tmpl_tag=''
        fa_var_tmpl_key=''
        fa_var_tmpl_after_tag=''
        fa_var_tmpl_rendered_tag=''
        fa_var_tmpl_after_section_open_tag=''
        fa_var_tmpl_section_is_function='false'
        fa_var_tmpl_section_key=''
        fa_var_tmpl_section_key_value=''
        fa_var_tmpl_render_section='true'
        fa_var_tmpl_section_value_list=''
        fa_var_tmpl_section_content=''
        fa_func_tmpl_get_input
        fa_var_tmpl_remaining_input="$fa_var_tmpl_input"
        while true
        do
            fa_func_tmpl_parse_next_tag "$fa_var_tmpl_remaining_input"
            fa_func_tmpl_render_tag
            if [ "$fa_var_tmpl_tag_error" = 'true' ]
            then
                return 91
            fi
            fa_var_tmpl_remaining_input="$fa_var_tmpl_after_tag"
            fa_func_tmpl_write_output
            if [ -z "$fa_var_tmpl_tag" ]
            then
                break
            fi
        done
    }
}

fa_func_replace_spaces() { # Pass item to replace spaces in, as an argument
    printf "$1" | sed 'sl/l///lg' | sed 'sl l/lg'
}
fa_func_recover_spaces() {
    printf "$1" | sed 'sl/l lg' | sed 'sl   l/lg'
}

fa_func_get_assignments() {
    fa_func_log Action "Getting assignments..."
    touch "${fa_var_status}/class-priorities"
    if [ "$fa_var_CASE_SENSITIVE" = "true" ]
    then
        fa_var_grep_command="grep"
    else
        fa_var_grep_command="grep -i"
    fi
    for fa_var_class in "${fa_var_classes_dir}"/*
    do
        if [ "$fa_var_class" = "${fa_var_classes_dir}/*" ]
        then
            fa_func_log Error "No classes found in the operations repository"
            exit 91
        fi
        fa_var_class_base="$(basename "$fa_var_class")"
        fa_var_sanitized_class="$(fa_func_replace_spaces "$fa_var_class_base")"
        fa_var_class_assigned="false"
        if [ -e "${fa_var_class}/assignments" ]
        then
            if [ -n "$(cat "${fa_var_class}/assignments" | $fa_var_grep_command "^${fa_var_SYSTEM_ID}\$" || true)" ]
            then
                fa_var_class_assigned="true"
            fi
        fi
        if [ "$fa_var_AUTOMATIC_ASSIGNMENT" = "true" ]
        then
            if [ -n "$(printf "$fa_var_SYSTEM_ID" | $fa_var_grep_command "$fa_var_class_base" || true)" ]
            then
                if [ "$fa_var_class_assigned" = "false" ]
                then
                    fa_var_class_assigned="true"
                fi
            fi
        fi
        if [ "$fa_var_class_assigned" = "true" ]
        then
            if [ -e "${fa_var_class}/priority" ] && \
                [ -n "$(cat "${fa_var_class}/priority" | grep "^-\?[0-9]*\$" | grep -v "^\$" || true)" ]
            then
                fa_var_priority="$(cat "${fa_var_class}/priority" | grep "^-\?[0-9]*\$" | grep -v "^\$" | head -n 1)"
            else
                fa_var_priority="0"
            fi
            printf "%s\n" "${fa_var_priority} ${fa_var_sanitized_class}" > "${fa_var_status}/class-priorities"
            fa_func_log Info "The '${fa_var_class_base}' class has been assigned with priority '${fa_var_priority}'..."
            if [ -n "$(ls -p1 "${fa_var_class}/" | $fa_var_grep_command "^${fa_var_SYSTEM_ID}/\$" || true)" ]
            then
                fa_func_log Info "A system directory in the '${fa_var_class_base}' class has been assigned..."
            fi
        fi
    done
    cat "${fa_var_status}/class-priorities" | sort -n > "${fa_var_status}/ordered-class-priorities"
    while IFS='' read -r fa_var_prioritized_class <&3 || [ -n "$fa_var_prioritized_class" ]
    do
        if [ -z "$fa_var_prioritized_class" ]
        then
            continue
        fi
        fa_var_sanitized_class="$(printf "$fa_var_prioritized_class" | cut -d ' ' -f 2)"
        fa_var_class_base="$(fa_func_recover_spaces "$fa_var_sanitized_class")"
        fa_var_assignments="${fa_var_assignments}${fa_var_sanitized_class} "
        if [ -n "$(ls -p1 "${fa_var_classes_dir}/${fa_var_class_base}/" \
            | $fa_var_grep_command "^${fa_var_SYSTEM_ID}/\$" || true)" ]
        then
            fa_var_case_adjusted_system="$(ls -p1 "${fa_var_classes_dir}/${fa_var_class_base}/" \
                | grep -i "^${fa_var_SYSTEM_ID}/\$")"
            fa_var_case_adjusted_system="${fa_var_case_adjusted_system%/}"
            fa_var_sanitized_system="$(fa_func_replace_spaces "${fa_var_class_base}/${fa_var_case_adjusted_system}")"
            fa_var_assignments="${fa_var_assignments}${fa_var_sanitized_system} "
        fi
    done 3< "${fa_var_status}/ordered-class-priorities"
    rm -f "${fa_var_status}/class-priorities" "${fa_var_status}/ordered-class-priorities"
    if [ -z "${fa_var_assignments}" ]
    then
        fa_func_log Warning "No assignments found for this system"
        exit 91
    fi
}

fa_func_run() {
    if [ "$fa_var_dry_run" = 'false' ] && [ -e "$1" ]
    then
        fa_var_currently_running="$1"
        printfc "${TERM_FAINT}"
        . "$1"
        printfc "${TERM_END_FAINT}"
        fa_var_currently_running=''
    fi
}

fa_func_refresh_variables() { # Pass current assignment as an argument, or "" if N/A
    fa_func_log Action "Refreshing variables..."
    if [ -e "${fa_var_status}/base-variables" ]
    then # Must revert back to the base state before loading more variables
        set | sort > "${fa_var_status}/current-variables"
        comm -13 "${fa_var_status}/base-variables" "${fa_var_status}/current-variables" \
            | grep "=" | grep -v "^ " | grep -v "^fa_var_" | grep -v "^fa_func_" \
            > "${fa_var_status}/new-variables"
        # Unset all of the new, non-fa variables that are detected:
        while IFS='' read -r fa_var_new_variable <&3 || [ -n "$fa_var_new_variable" ]
        do
            if [ -z "$fa_var_new_variable" ]
            then
                continue
            fi
            fa_var_new_variable="${fa_var_new_variable%%=*}"
            unset "$fa_var_new_variable" 2>/dev/null || true
        done 3< "${fa_var_status}/new-variables"
    fi

    # Refresh any non-fa variables that are liable to having been shadowed:
    fa_func_enable_color
    fa_func_enable_tmpl

    # Record the base variables before loading any new variables:
    set | sort > "${fa_var_status}/base-variables"

    # Load the variables applicable to the system and assignment:
    fa_func_run "${fa_var_operations}/variables" # Load global variables
    if [ -n "$1" ] # Load assignment variables
    then # Specific, originating assignment exists (so not ad hoc role/module)
        if [ -n "$(printf '%s' "${1}" | grep '/' || true)" ]
        then # This is a system directory, so load the class variables first
            fa_func_run "${fa_var_classes_dir}/${1}/../variables"
        fi
        fa_func_run "${fa_var_classes_dir}/${1}/variables"
        if [ -z "$(printf '%s' "${1}" | grep '/' || true)" ]
        then # This is a class directory, so look for any potential system directory variables to load last:
            if [ "$fa_var_CASE_SENSITIVE" = "true" ]
            then
                fa_var_case_adjusted_system="$fa_var_SYSTEM_ID"
            else # Get any potential alternate casing of the system directory, if it exists
                if [ -n "$(ls -p1 "${fa_var_classes_dir}/${1}/" | grep -i "^${fa_var_SYSTEM_ID}/\$" || true)" ]
                then
                    fa_var_case_adjusted_system="$(ls -p1 "${fa_var_classes_dir}/${1}/" | grep -i "^${fa_var_SYSTEM_ID}/\$")"
                    fa_var_case_adjusted_system="${fa_var_case_adjusted_system%/}"
                else
                    fa_var_case_adjusted_system="$fa_var_SYSTEM_ID"
                fi
            fi
            fa_func_run "${fa_var_classes_dir}/${1}/${fa_var_case_adjusted_system}/variables"
        fi
    fi
}

fa_func_check_overridden() { # Pass the assignment and the source file as arguments
    fa_var_overridden="false"
    if [ -z "$(echo "${1}" | grep '/' || true)" ]
    then # This is a class directory, not a system directory
        if [ "$fa_var_CASE_SENSITIVE" = "true" ]
        then
            fa_var_case_adjusted_system="$fa_var_SYSTEM_ID"
        else # Get any potential alternate casing of the system directory, if it exists
            if [ -n "$(ls -p1 "${fa_var_classes_dir}/${1}/" | grep -i "^${fa_var_SYSTEM_ID}/\$" || true)" ]
            then
                fa_var_case_adjusted_system="$(ls -p1 "${fa_var_classes_dir}/${1}/" | grep -i "^${fa_var_SYSTEM_ID}/\$")"
                fa_var_case_adjusted_system="${fa_var_case_adjusted_system%/}"
            else
                fa_var_case_adjusted_system="$fa_var_SYSTEM_ID"
            fi
        fi
        if [ -e "${fa_var_classes_dir}/${1}/${fa_var_case_adjusted_system}/override" ]
        then # Override flag is set
            if [ -e "${fa_var_classes_dir}/${1}/${fa_var_case_adjusted_system}/${2}" ]
            then
                fa_func_log Info "The '${1}' class's ${2} are overridden in a system directory"
                fa_func_log Info "Skipping these ${2}..."
                fa_var_overridden="true"
            fi
        fi
    fi
}

fa_func_apply_patches() {
    fa_func_log Info "Checking for patches to apply..."
    for fa_var_assignment in $fa_var_assignments
    do
        fa_var_assignment="$(fa_func_recover_spaces "$fa_var_assignment")"
        if [ ! -e "${fa_var_classes_dir}/${fa_var_assignment}/patches" ]
        then
            continue
        fi
        fa_func_check_overridden "$fa_var_assignment" "patches"
        if [ "$fa_var_overridden" = "true" ]
        then
            continue
        fi

        for fa_var_patch in "${fa_var_classes_dir}/${fa_var_assignment}/patches"/*
        do
            fa_var_patch_base="$(basename "$fa_var_patch")"
            if [ "$fa_var_patch_base" = "*" ] || [ -d "$fa_var_patch" ]
            then # No patches found, or current patch is a directory
                continue
            fi
            if [ -n "$(cat "${fa_var_status}/applied-patches" | \
                grep "^${fa_var_assignment}/patches/${fa_var_patch_base}\$" || true)" ]
            then # Patch already applied
                continue
            fi
            if [ -e "${fa_var_status}/.first_run" ]
            then # This is the first run, so just record the pre-existing patches
                if [ "$fa_var_dry_run" = "false" ]
                then
                    printf "${fa_var_assignment}/patches/${fa_var_patch_base}\n" \
                        >> "${fa_var_status}/applied-patches"
                fi
                continue
            fi

            fa_func_log Action "Applying the '${fa_var_patch_base}' patch..."
            fa_func_refresh_variables "$fa_var_assignment"
            cd "${fa_var_classes_dir}/${fa_var_assignment}/patches"
            fa_func_run "./${fa_var_patch_base}"
            if [ "$fa_var_dry_run" = "false" ]
            then
                printf "${fa_var_assignment}/patches/${fa_var_patch_base}\n" \
                    >> "${fa_var_status}/applied-patches"
            fi
            fa_func_log Success "The '${fa_var_patch_base}' patch has been applied..."
            cd "${fa_var_root}"
        done
    done
    if [ -e "${fa_var_status}/.first_run" ] && [ "$fa_var_dry_run" = "false" ]
    then # This was the first run, and now the flag can be removed
        rm -f "${fa_var_status}/.first_run"
    fi

    fa_func_log Info "Checking for removed patches..."
    while IFS='' read -r fa_var_patch <&3 || [ -n "$fa_var_patch" ]
    do
        if [ -z "$fa_var_patch" ]
        then
            continue
        fi
        if [ ! -e "${fa_var_classes_dir}/${fa_var_patch}" ]
        then
            sed -i "/^${fa_var_patch}\$/d" "${fa_var_status}/applied-patches"
            fa_func_log Success "The removed '$(basename "$fa_var_patch")' patch is now available for reuse..."
        fi
    done 3< "${fa_var_status}/applied-patches"
}

fa_func_apply_initializers() {
    fa_func_log Info "Checking for initializers to apply..."
    for fa_var_assignment in $fa_var_assignments
    do
        fa_var_assignment="$(fa_func_recover_spaces "$fa_var_assignment")"
        if [ ! -e "${fa_var_classes_dir}/${fa_var_assignment}/initializers" ]
        then
            continue
        fi
        fa_func_check_overridden "$fa_var_assignment" "initializers"
        if [ "$fa_var_overridden" = "true" ]
        then
            continue
        fi

        while IFS='' read -r fa_var_initializer <&3 || [ -n "$fa_var_initializer" ]
        do
            if [ -z "$fa_var_initializer" ]
            then
                continue
            fi
            if [ ! -e "${fa_var_operations}/initializers/${fa_var_initializer}" ]
            then
                fa_func_log Error "The '${fa_var_initializer}' initializer does not exist."
                exit 91
            fi
            if [ -n "$(cat "${fa_var_status}/applied-initializers" | \
                grep "^${fa_var_initializer}\$" || true)" ]
            then # Initializer already applied
                fa_func_log Info "Skipping the already-applied '${fa_var_initializer}' initializer..."
                continue
            fi

            fa_func_log Action "Applying the '${fa_var_initializer}' initializer..."
            fa_func_refresh_variables "$fa_var_assignment"
            cd "${fa_var_operations}/initializers"
            fa_func_run "./${fa_var_initializer}"
            if [ "$fa_var_dry_run" = "false" ]
            then
                printf "${fa_var_initializer}\n" >> "${fa_var_status}/applied-initializers"
            fi
            fa_func_log Success "The '${fa_var_initializer}' initializer has been applied"
            cd "${fa_var_root}"
        done 3< "${fa_var_classes_dir}/${fa_var_assignment}/initializers"
    done
}

fa_func_apply_module() { # Pass module and assignment (if known, else "") as arguments
    if [ ! -d "${fa_var_operations}/modules/${1}" ]
    then
        fa_func_log Error "The '${1}' module does not exist"
        exit 91
    fi

    if [ "$fa_var_UNIQUE" = "true" ]
    then
        fa_var_sanitized_module="$(fa_func_replace_spaces "$1")"
        fa_var_module_already_applied="false"
        for fa_var_applied_module in $fa_var_applied_modules
        do
            if [ "$fa_var_applied_module" = "$fa_var_sanitized_module" ]
            then
                fa_var_module_already_applied="true"
                break
            fi
        done
        if [ "$fa_var_module_already_applied" = "true" ]
        then
            fa_func_log Info "The '${1}' module has already been applied during this run"
            fa_func_log Info "Skipping the '${1}' module..."
            return
        else
            fa_var_applied_modules="${fa_var_applied_modules}${fa_var_sanitized_module} "
        fi
    fi

    cd "${fa_var_operations}/modules/${1}"
    if [ "$fa_var_GIT_ENABLED" = "true" ] && [ "$fa_var_SKIP_UNMODIFIED" = "true" ] && [ -z "$fa_var_command_arg" ]
    then
        if [ -z "$(git diff $(git log -n 1 --format='%H') ${fa_var_last_commit} ./)" ]
        then
            fa_func_log Info "The '${1}' module has not been modified"
            fa_func_log Info "Skipping the '${1}' module..."
            cd "${fa_var_root}"
            return
        fi
    fi

    if [ -n "$fa_var_command_arg" ]
    then
        fa_func_log Action "Applying the '${1}' module ad hoc..."
    else
        fa_func_log Action "Applying the '${1}' module..."
    fi
    fa_func_refresh_variables "$2"
    fa_func_run "./variables"
    fa_func_run "./apply"
    fa_func_log Success "The '${1}' module has been applied"
    cd "$fa_var_root"
}

fa_func_apply_modules() {
    if [ "$fa_var_modules_or_roles" = "roles" ]
    then
        fa_func_log Info "Skipping modules..."
    else
        fa_func_log Info "Checking for modules to apply..."
        for fa_var_assignment in $fa_var_assignments
        do
            fa_var_assignment="$(fa_func_recover_spaces "$fa_var_assignment")"
            if [ ! -e "${fa_var_classes_dir}/${fa_var_assignment}/modules" ]
            then
                continue
            fi
            fa_func_check_overridden "$fa_var_assignment" "modules"
            if [ "$fa_var_overridden" = "true" ]
            then
                continue
            fi

            while IFS='' read -r fa_var_module <&3 || [ -n "$fa_var_module" ]
            do
                if [ -z "$fa_var_module" ]
                then
                    continue
                fi
                fa_func_apply_module "$fa_var_module" "$fa_var_assignment"
            done 3< "${fa_var_classes_dir}/${fa_var_assignment}/modules"
        done
    fi
}

fa_func_apply_role() { # Pass role and assignment (if known, else "") as arguments
    if [ ! -e "${fa_var_operations}/roles/${1}" ]
    then
        fa_func_log Error "The '${1}' role does not exist"
        exit 91
    fi

    if [ "$fa_var_UNIQUE" = "true" ]
    then
        fa_var_sanitized_role="$(fa_func_replace_spaces "$1")"
        fa_var_role_already_applied="false"
        for fa_var_applied_role in $fa_var_applied_roles
        do
            if [ "$fa_var_applied_role" = "$fa_var_sanitized_role" ]
            then
                fa_var_role_already_applied="true"
                break
            fi
        done
        if [ "$fa_var_role_already_applied" = "true" ]
        then
            fa_func_log Info "The '${1}' role has already been applied during this run"
            fa_func_log Info "Skipping the '${1}' role..."
            return
        else
            fa_var_applied_roles="${fa_var_applied_roles}${fa_var_sanitized_role} "
        fi
    fi

    if [ -n "$fa_var_command_arg" ]
    then
        fa_func_log Action "Applying the '${1}' role ad hoc..."
    else
        fa_func_log Action "Applying the '${1}' role..."
    fi
    while IFS='' read -r fa_var_module <&3 || [ -n "$fa_var_module" ]
    do
        if [ -z "$fa_var_module" ]
        then
            continue
        fi
        fa_func_apply_module "$fa_var_module" "$2"
    done 3< "${fa_var_operations}/roles/${1}"
    fa_func_log Success "The '${1}' role has been applied"
}

fa_func_apply_roles() {
    if [ "$fa_var_modules_or_roles" = "modules" ]
    then
        fa_func_log Info "Skipping roles..."
    else
        fa_func_log Info "Checking for roles to apply..."
        for fa_var_assignment in $fa_var_assignments
        do
            fa_var_assignment="$(fa_func_recover_spaces "$fa_var_assignment")"
            if [ ! -e "${fa_var_classes_dir}/${fa_var_assignment}/roles" ]
            then
                continue
            fi
            fa_func_check_overridden "$fa_var_assignment" "roles"
            if [ "$fa_var_overridden" = "true" ]
            then
                continue
            fi

            while IFS='' read -r fa_var_role <&3 || [ -n "$fa_var_role" ]
            do
                if [ -z "${fa_var_role}" ]
                then
                    continue
                fi
                fa_func_apply_role "$fa_var_role" "$fa_var_assignment"
            done 3< "${fa_var_classes_dir}/${fa_var_assignment}/roles"
        done
    fi
}

fa_func_full_run() {
    fa_func_handle_locks
    fa_func_get_assignments
    fa_func_apply_patches
    fa_func_apply_initializers
    fa_func_apply_roles
    fa_func_apply_modules
    if [ "$fa_var_dry_run" = "false" ] && [ "$fa_var_LOG_FILE" != "None" ]
    then
        printf "$(date)\n" >> "${fa_var_status}/completed-runs"
    fi
}


fa_func_configure_utility() {
    fa_func_config_usage() {
printfc "Fetch Apply Configuration Utility\n\n"
printfc "Usage:\n    ${fa_var_launch_command} configure [OPTION]...\n\n"
cat <<EOF
Options:
    --help
        Show this help message
    -0
        Disable the configuration utility's interactive mode
    -a {true|false}
        Enable automatic class assignment
    -b <branch>
        Use this branch of the operations repository
    -c {true|false}
        Enable case sensitivity when determining assignments
    -d {true|false}
        Don't apply unmodified modules during a full run
    -f {true|false}
        Automatically update operations repository from remote origin
    -g {true|false}
        Enable git for the operations repository
    -h
        Show this help message
    -i {true|false}
        Ignore errors if they occur, and continue applying operations
    -j <cron schedule>
        Use this cron schedule to run Fetch Apply automatically
    -l <log file>
        Write Fetch Apply logs to this file
    -m <max log entries>
        Rotate the Fetch Apply log file after this many entries
    -o <output file>
        Write the generated configuration to this file
    -p <palette>
        Use this palette to colorize terminal output
    -r <command>
        Run this command to get the system identifier
    -s <shell>
        Run Fetch Apply operations with this shell
    -u {true|false}
        Ensure assigned modules and roles are only applied once per run
EOF
    }

    fa_func_config_banner() {
        if [ "$fa_var_interactive" = "true" ]
        then
            printfc "$TERM_CLEAR"
            printfc "###################################################################\n"
            printfc "#############    ${TERM_UNDERLINE}"
            printfc "${TERM_VIOLET}${TERM_BOLD}Fetch Apply Configuration Utility${TERM_END_BOLD}"
            printfc "${TERM_END_UNDERLINE}    #############\n"
            printfc "###################################################################\n\n"
        fi
    }

    fa_func_default_config_settings() {
        # Override some settings' initial values with the preferred
        # defaults for a new configuration:
        if [ "$fa_var_SHELL" = "unknown" ]
        then
            if [ -n "$(command -v bash)" ]
            then
                fa_var_SHELL="$(command -v bash)"
            elif [ -n "$(command -v dash)" ]
            then
                fa_var_SHELL="$(command -v dash)"
            elif [ -n "$(command -v zsh)" ]
            then
                fa_var_SHELL="$(command -v zsh)"
            else
                fa_var_SHELL="/usr/bin/env sh"
            fi
        fi
        if [ -n "$(command -v hostname)" ]
        then
            fa_var_SYSTEM_ID="$(command -v hostname)"
        else
            fa_var_SYSTEM_ID=""
        fi
        if [ -n "$(command -v git)" ]
        then
            fa_var_GIT_ENABLED="true"
        else
            fa_var_GIT_ENABLED="false"
        fi
        if [ "$(basename "$fa_var_SHELL")" = "bash" ] && [ -n "${RANDOM:-}" ]
        then
            fa_var_CRON_SCHEDULE="$(( $RANDOM % 60 )) $(( $RANDOM % 24 )) * * *"
        else
            fa_var_CRON_SCHEDULE="0 0 * * *"
        fi
        fa_var_config_LOG_FILE="/var/log/fetch-apply.log"
        fa_var_AUTO_UPDATE="true"
        fa_var_SKIP_UNMODIFIED="false"
        fa_var_IGNORE_ERRORS="false"
        fa_var_COLOR_PALETTE="Dracula"
        if [ ! -e "$(pwd)/fetch-apply.conf" ] && [ "$fa_var_interactive" = "true" ]
        then
            fa_var_config_output_file="$(pwd)/fetch-apply.conf"
        else
            fa_var_config_output_file=""
        fi
    }

    fa_func_validate_config_settings() {
        fa_func_config_banner
        fa_func_validate_settings
        printf "echo 'This is a test.'\n" > "${fa_var_root}/fetch-apply-shell-test"
        set +e
        fa_var_shell_test_result="$(eval "$fa_var_SHELL" "${fa_var_root}/fetch-apply-shell-test" \
            1>/dev/null 2>/dev/null; printf "$?")"
        if [ "$fa_var_IGNORE_ERRORS" = 'false' ]
        then
            set -e
        fi
        rm -f "${fa_var_root}/fetch-apply-shell-test"
        if [ "$fa_var_shell_test_result" != "0" ]
        then
            fa_func_config_banner
            fa_func_log Info "The command '${fa_var_SHELL} \"${fa_var_root}/fetch-apply-shell-test\"' returned a non-zero exit code"
            fa_func_log Error "The setting 'RUN_SHELL' may be invalid"
            exit 91
        fi
        printf "SYSTEM_ID() {\n    ${fa_var_SYSTEM_ID}\n}\n\nSYSTEM_ID\n" > "${fa_var_root}/fetch-apply-system-test"
        set +e
        fa_var_system_test_result="$(eval "$fa_var_SHELL" "${fa_var_root}/fetch-apply-system-test" \
            1>/dev/null 2>/dev/null; printf "$?")"
        if [ "$fa_var_IGNORE_ERRORS" = 'false' ]
        then
            set -e
        fi
        fa_var_system_test_output="$(eval "$fa_var_SHELL" "${fa_var_root}/fetch-apply-system-test" \
            2>/dev/null)"
        rm -f "${fa_var_root}/fetch-apply-system-test"
        if [ "$fa_var_system_test_result" != "0" ]
        then
            fa_func_config_banner
            fa_func_log Info "The 'SYSTEM_ID' setting returned a non-zero exit code"
            fa_func_log Error "The setting 'SYSTEM_ID' may be invalid"
            exit 91
        fi
        if [ -z "$fa_var_system_test_output" ]
        then
            fa_func_config_banner
            fa_func_log Info "The 'SYSTEM_ID' command(s) returned zero output"
            fa_func_log Error "The setting 'SYSTEM_ID' may be invalid"
            exit 91
        fi
        if [ "$fa_var_config_LOG_FILE" != 'None' ] && [ -e "$fa_var_config_LOG_FILE" ] && \
            [ ! -w "$fa_var_config_LOG_FILE" ]
        then
            fa_func_log Info "No write permissions for 'LOG_FILE' path '${fa_var_config_LOG_FILE}'"
            fa_func_log Error "The setting 'LOG_FILE' may be invalid"
            fa_func_log Info "Try running Fetch Apply with 'sudo'"
            exit 91
        elif [ "$fa_var_config_LOG_FILE" != 'None' ] && [ -e "$(dirname "$fa_var_config_LOG_FILE")" ] && \
            [ ! -w "$(dirname "$fa_var_config_LOG_FILE")" ]
        then
            fa_func_log Info "No write permissions for 'LOG_FILE' path '${fa_var_config_LOG_FILE}'"
            fa_func_log Error "The setting 'LOG_FILE' may be invalid"
            fa_func_log Info "Try running Fetch Apply with 'sudo'"
            exit 91
        fi
        if [ -n "$fa_var_CRON_SCHEDULE" ] && [ ! -d "/etc/cron.d" ]
        then
            fa_func_config_banner
            fa_func_log Info "The 'CRON_SCHEDULE' setting has been configured but '/etc/cron.d' doesn't exist"
            fa_func_log Error "The setting 'CRON_SCHEDULE' may be invalid"
            exit 91
        fi
    }

    fa_func_settings_prompt() { # Pass setting name, default value, prompt, and description strings
        fa_func_config_banner
        fa_var_current_settings_prompt="$(($fa_var_current_settings_prompt + 1))"
        fa_var_default_value="$2"
        fa_var_prompt="$3"
        printfc "${TERM_BOLD}Setting${TERM_END_BOLD} (%s/%s): ${TERM_GREEN}%s\n" \
            "$fa_var_current_settings_prompt" "$fa_var_total_settings_prompts" "$1"
        printfc "${TERM_BOLD}Default Value${TERM_END_BOLD}: ${TERM_CYAN}'%s'\n" \
            "$fa_var_default_value"
        shift
        shift
        shift
        printfc "${TERM_BOLD}Description${TERM_END_BOLD}:\n"
        while [ "$#" -gt "0" ]
        do
            printfc "${TERM_ITALIC}${TERM_MAGENTA}  %s\n" "$1"
            shift
        done
        printfc "${TERM_END_ITALIC}\n"
        printfc "${TERM_BOLD}%s${TERM_END_BOLD}: ${TERM_CYAN}" "$fa_var_prompt"
        read fa_var_prompt_response
        fa_var_prompt_response="${fa_var_prompt_response:-"$fa_var_default_value"}"
    }

    fa_func_interactive_configure() {
        fa_var_current_settings_prompt="0"
        fa_var_total_settings_prompts="14"
        fa_func_config_banner
        printfc "${TERM_BOLD}Welcome to the Fetch Apply Interactive Configuration Utility!${TERM_END_BOLD}\n\n"
        printfc "This utility will walk you through generating a custom\n"
        printfc "configuration for your Fetch Apply instance.\n\n"
        printfc "When presented with a settings prompt, you may enter a custom\n"
        printfc "value, or leave the input blank to use the default value.\n\n"
        printfc "${TERM_ITALIC}When you are ready to begin, press enter...${TERM_END_ITALIC}\n"
        read fa_var_enter_pressed
        fa_func_settings_prompt "RUN_SHELL" "${fa_var_SHELL}" "Shell" \
            "The shell that Fetch Apply will use to apply operations" \
            "from your operations repository"
        fa_var_SHELL="$fa_var_prompt_response"
        fa_func_settings_prompt "SYSTEM_ID" "${fa_var_SYSTEM_ID}" "Command" \
            "A command that will return a unique identifier for this" \
            "system, to be used when determining class assignments" "" \
            "If more advanced logic than a single command is required," \
            "use a placeholder command for now (such as 'echo \"SYSTEMID\"')," \
            "and just replace it later in the generated configuration file"
        fa_var_SYSTEM_ID="$fa_var_prompt_response"
        fa_func_settings_prompt "GIT_ENABLED" "${fa_var_GIT_ENABLED}" "Enable Git" \
            "Enable git support and features for your operations repository"
        fa_var_GIT_ENABLED="$fa_var_prompt_response"
        if [ "$fa_var_GIT_ENABLED" = "true" ]
        then
            fa_func_settings_prompt "OPS_REPO_BRANCH" "${fa_var_OPS_REPO_BRANCH}" \
                "Operations Repository Branch" \
                "The branch of the operations git repository to use"
            fa_var_OPS_REPO_BRANCH="$fa_var_prompt_response"
            fa_func_settings_prompt "AUTO_UPDATE" "${fa_var_AUTO_UPDATE}" "Update Operations" \
                "Automatically update the operations repository from the" \
                "remote origin every time Fetch Apply is run"
            fa_var_AUTO_UPDATE="$fa_var_prompt_response"
            if [ "$fa_var_AUTO_UPDATE" = "true" ]
            then
                fa_func_settings_prompt "SKIP_UNMODIFIED" "${fa_var_SKIP_UNMODIFIED}" \
                    "Only Run Modified Modules" \
                    "Only apply modules that have been modified (in the remote" \
                    "origin) since the last time Fetch Apply was run"
                fa_var_SKIP_UNMODIFIED="$fa_var_prompt_response"
            else
                fa_var_SKIP_UNMODIFIED="false"
                fa_var_current_settings_prompt="$(($fa_var_current_settings_prompt + 1))"
            fi
        else
            fa_var_OPS_REPO_BRANCH="main"
            fa_var_AUTO_UPDATE="false"
            fa_var_SKIP_UNMODIFIED="false"
            fa_var_current_settings_prompt="$(($fa_var_current_settings_prompt + 3))"
        fi
        fa_func_settings_prompt "CRON_SCHEDULE" "${fa_var_CRON_SCHEDULE}" "Cron Schedule" \
            "The cron schedule to use for running Fetch Apply in the" \
            "background automatically" "" \
            "Set equal to 'None' to disable cron support for Fetch Apply"
        fa_var_CRON_SCHEDULE="$fa_var_prompt_response"
        if [ "$fa_var_CRON_SCHEDULE" = "None" ] || [ "$fa_var_CRON_SCHEDULE" = "none" ]
        then
            fa_var_CRON_SCHEDULE=""
        fi
        fa_func_settings_prompt "LOG_FILE" "${fa_var_config_LOG_FILE}" "Log File" \
            "The full path of the dedicated log file Fetch Apply should use" "" \
            "Set equal to 'None' to disable all logging"
        fa_var_config_LOG_FILE="$fa_var_prompt_response"
        fa_func_settings_prompt "MAX_LOG_LENGTH" "${fa_var_MAX_LOG_LENGTH}" "Maximum Log Length" \
            "The maximum number of entries (lines) that Fetch Apply" \
            "will write to its log file, before rotating it" "" \
            "Set equal to '-1' for unlimited entries"
        fa_var_MAX_LOG_LENGTH="$fa_var_prompt_response"
        fa_func_settings_prompt "AUTOMATIC_ASSIGNMENT" "${fa_var_AUTOMATIC_ASSIGNMENT}" \
            "Enable Automatic Class Assignment" \
            "Enable automatic class assignment based on the output" \
            "of the 'SYSTEM_ID' setting"
        fa_var_AUTOMATIC_ASSIGNMENT="$fa_var_prompt_response"
        fa_func_settings_prompt "CASE_SENSITIVE" "${fa_var_CASE_SENSITIVE}" "Enable Case Sensitivity" \
            "Enable case sensitivity when determining assignments"
        fa_var_CASE_SENSITIVE="$fa_var_prompt_response"
        fa_func_settings_prompt "IGNORE_ERRORS" "${fa_var_IGNORE_ERRORS}" "Ignore Errors" \
            "Ignore errors when they occur, and continue applying the" \
            "rest of the assigned operations, instead of exiting"
        fa_var_IGNORE_ERRORS="$fa_var_prompt_response"
        fa_func_settings_prompt "UNIQUE" "${fa_var_UNIQUE}" "Ignore Duplicates" \
            "Ensure that each module is applied only once per run," \
            "and any duplicate assignments are ignored"
        fa_var_UNIQUE="$fa_var_prompt_response"
        fa_func_settings_prompt "COLOR_PALETTE" "${fa_var_COLOR_PALETTE}" "Color Palette" \
            "The palette to use for colorizing terminal output and" \
            "to make available for use in operations scripts" "" \
            "Set equal to 'No Color' to prevent colorized output but leave" \
            "graphic mode enabled, or 'None' to disable all stylized output."
        fa_var_COLOR_PALETTE="$fa_var_prompt_response"
    }

    fa_func_print_configuration() {
        printf "# Fetch Apply Configuration File\n"
        printf "# This file contains the variables and functions used to customize Fetch Apply\n\n"
        printf "# When editing this configuration file, please be careful to maintain proper shell\n"
        printf "# syntax and refrain from removing or renaming any of the variables or functions.\n\n"
        printf "# Run Fetch Apply operations with this shell:\nRUN_SHELL='${fa_var_SHELL}'\n\n"
        printf "# Run this function to print the system identifier:\nSYSTEM_ID() {\n    ${fa_var_SYSTEM_ID}\n}\n\n"
        printf "# Enable git for the operations repository:\nGIT_ENABLED='${fa_var_GIT_ENABLED}'\n\n"
        printf "# Automatically run Fetch Apply using this cron schedule:\nCRON_SCHEDULE='${fa_var_CRON_SCHEDULE}'\n\n"
        printf "# Write Fetch Apply logs to this file:\nLOG_FILE='${fa_var_config_LOG_FILE}'\n\n"
        printf "# Rotate the Fetch Apply log file after it reaches this length:\nMAX_LOG_LENGTH='${fa_var_MAX_LOG_LENGTH}'\n\n"
        printf "# Enable automatic class assignment:\nAUTOMATIC_ASSIGNMENT='${fa_var_AUTOMATIC_ASSIGNMENT}'\n\n"
        printf "# Use this branch of the operations repository:\nOPS_REPO_BRANCH='${fa_var_OPS_REPO_BRANCH}'\n\n"
        printf "# Automatically update operations repository from the remote origin:\nAUTO_UPDATE='${fa_var_AUTO_UPDATE}'\n\n"
        printf "# Skip unmodified modules when running:\nSKIP_UNMODIFIED='${fa_var_SKIP_UNMODIFIED}'\n\n"
        printf "# Enable case sensitivity when determining assignments:\nCASE_SENSITIVE='${fa_var_CASE_SENSITIVE}'\n\n"
        printf "# Ignore errors if they occur, and continue applying operations:\nIGNORE_ERRORS='${fa_var_IGNORE_ERRORS}'\n\n"
        printf "# Ensure assigned modules are only applied once per run:\nUNIQUE='${fa_var_UNIQUE}'\n\n"
        printf "# Use this palette to colorize terminal output:\nCOLOR_PALETTE='${fa_var_COLOR_PALETTE}'\n"
    }

    fa_func_write_configuration() {
        if [ -z "$fa_var_config_output_file" ] && [ "$fa_var_interactive" = "true" ]
        then
            fa_func_config_banner
            printfc "Please enter the full path of the file you would like to\n"
            printfc "write the generated configuration to. Or, input a blank value\n"
            printfc "to print the generated configuration to the screen and exit.\n\n"
            printfc "${TERM_BOLD}Output File${TERM_END_BOLD}: ${TERM_CYAN}"
            read fa_var_config_output_file
        fi
        if [ -z "$fa_var_config_output_file" ]
        then
            printf "${TERM_CLEAR}"
            fa_func_print_configuration
            printfc "\n"
        else
            fa_func_config_banner
            touch "$fa_var_config_output_file" 2>/dev/null
            if [ -w "$fa_var_config_output_file" ]
            then
                set +e
                fa_func_print_configuration > "$fa_var_config_output_file"
                if [ "$?" = "0" ]
                then
                    fa_func_log Info "Fetch Apply configuration saved to '$fa_var_config_output_file'"
                else
                    fa_func_log Error "Could not save Fetch Apply configuration to '$fa_var_config_output_file'"
                    fa_func_log Action "Printing configuration to screen instead..."
                    printfc "\n"
                    fa_func_print_configuration
                    printfc "\n"
                    fa_var_config_output_file=''
                fi
                if [ "$fa_var_IGNORE_ERRORS" = 'false' ]
                then
                    set -e
                fi
            else
                fa_func_log Info "No write permissions for output file ('${fa_var_config_output_file}')"
                fa_func_log Error "Could not save Fetch Apply configuration to '$fa_var_config_output_file'"
                fa_func_log Action "Printing configuration to screen instead..."
                printfc "\n"
                fa_func_print_configuration
                printfc "\n"
                fa_var_config_output_file=''
            fi
        fi
    }
}


fa_func_install_utility() {
    fa_func_install_usage() {
printfc "Fetch Apply Installation Utility\n\n"
printfc "Usage:\n    ${fa_var_launch_command} install [OPTION]...\n\n"
cat <<EOF
Options:
    --help
        Show this help message
    -0
        Disable the configuration utility's interactive mode
    -c <config file>
        Install Fetch Apply using this configuration
    -d <install path>
        Install Fetch Apply in this (empty or nonexistent) directory
    -h
        Show this help message
    -u <URL>
        Operations repository git URL
    -x <symlink in PATH>
        Symlink this file in PATH to Fetch Apply
EOF
    }

    fa_func_install_banner() {
        if [ "$fa_var_interactive" = "true" ]
        then
            printfc "$TERM_CLEAR"
            printfc "##################################################################\n"
            printfc "#############    ${TERM_UNDERLINE}"
            printfc "${TERM_VIOLET}${TERM_BOLD}Fetch Apply Installation Utility${TERM_END_BOLD}"
            printfc "${TERM_END_UNDERLINE}    #############\n"
            printfc "##################################################################\n\n"
        fi
    }

    fa_func_options_prompt() { # Pass option name, default value, prompt, and description strings
        fa_func_install_banner
        fa_var_current_options_prompt="$(($fa_var_current_options_prompt + 1))"
        fa_var_default_value="$2"
        fa_var_prompt="$3"
        printfc "${TERM_BOLD}Option${TERM_END_BOLD} (%s/%s): ${TERM_GREEN}%s\n" \
            "$fa_var_current_options_prompt" "$fa_var_total_options_prompts" "$1"
        printfc "${TERM_BOLD}Default Choice${TERM_END_BOLD}: ${TERM_CYAN}'%s'\n" \
            "$fa_var_default_value"
        shift
        shift
        shift
        printfc "${TERM_BOLD}Description${TERM_END_BOLD}:\n"
        while [ "$#" -gt "0" ]
        do
            printfc "${TERM_ITALIC}${TERM_MAGENTA}  %s\n" "$1"
            shift
        done
        printfc "${TERM_END_ITALIC}\n"
        printfc "${TERM_BOLD}%s${TERM_END_BOLD}: ${TERM_CYAN}" "$fa_var_prompt"
        read fa_var_prompt_response
        fa_var_prompt_response="${fa_var_prompt_response:-"$fa_var_default_value"}"
    }

    fa_func_interactive_install() {
        fa_var_current_options_prompt="0"
        fa_var_total_options_prompts="4"
        fa_func_install_banner
        printfc "${TERM_BOLD}Welcome to the Fetch Apply Interactive Installation Utility!${TERM_END_BOLD}\n\n"
        printfc "This utility will walk you through installing Fetch Apply\n"
        printfc "on your system.\n\n"
        printfc "When presented with a options prompt, you may enter a custom\n"
        printfc "value, or leave the input blank to use the default choice.\n\n"
        printfc "${TERM_ITALIC}When you are ready to begin, press enter...${TERM_END_ITALIC}\n"
        read fa_var_enter_pressed
        while true
        do
            fa_var_configuration_file="${fa_var_configuration_file:-"New"}"
            fa_func_options_prompt "Installation Configuration" "$fa_var_configuration_file" "Configuration File" \
            "A file containing the desired Fetch Apply configuration," \
            "which will be used to customize the installation" "" \
            "To create a new configuration for this installation," \
            "type 'New', then press enter"
            fa_var_configuration_file="$fa_var_prompt_response"
            if [ "$fa_var_configuration_file" = 'New' ] || [ "$fa_var_configuration_file" = 'new' ]
            then
                fa_func_configure_utility
                fa_func_default_config_settings
                fa_func_interactive_configure
                fa_func_validate_config_settings
                fa_func_write_configuration
                fa_var_configuration_file="$fa_var_config_output_file"
                printfc "\n\n${TERM_ITALIC}Press enter to resume installation...${TERM_END_ITALIC}"
                read fa_var_enter_pressed
            fi
            if [ -n "$fa_var_configuration_file" ] && [ -f "$fa_var_configuration_file" ]
            then
                break
            else
                fa_var_current_options_prompt="$(($fa_var_current_options_prompt - 1))"
                fa_func_log Error "The configuration file '${fa_var_configuration_file}' was not found"
                printfc "\n${TERM_ITALIC}Press enter to try again...${TERM_END_ITALIC}\n"
                fa_var_configuration_file=''
                read fa_var_enter_pressed
            fi
        done
        if [ ! -d "$(dirname "$fa_var_new_root")" ]
        then
            fa_var_new_root="${fa_var_root}/fetch-apply"
        fi
        fa_func_options_prompt "Installation Location" "$fa_var_new_root" "Installation Path" \
        "The full path to an empty or nonexistent directory in which" \
        "Fetch Apply should be installed"
        fa_var_new_root="$fa_var_prompt_response"
        if [ ! -d "$(dirname "$fa_var_launch_file")" ]
        then
            fa_var_launch_file=""
        fi
        fa_func_options_prompt "Location in PATH" "$fa_var_launch_file" "File in PATH" \
        "The full path to a nonexistent file in PATH that should be" \
        "symbollically linked to Fetch Apply" "" \
        "The basename of this file will become the command " \
        "used to run Fetch Apply"
        fa_var_launch_file="$fa_var_prompt_response"
        if [ "$fa_var_GIT_ENABLED" = "true" ]
        then
            fa_func_options_prompt "Clone Operations Repository" "$fa_var_ops_repo_url" "Operations Repository URL" \
            "Automatically clone the operations repository from this" \
            "URL during installation" "" \
            "Leave this value blank if you would prefer to manually copy" \
            "your operations repository to" "" "    '${fa_var_new_root}/operations/'" \
            "" "after the installation completes"
            fa_var_ops_repo_url="$fa_var_prompt_response"
        fi
    }

    fa_func_validate_install_options() {
        fa_func_install_banner
        fa_func_log Action "Validating settings from the provided configuration file..."
        if [ -z "$fa_var_configuration_file" ] || [ ! -f "$fa_var_configuration_file" ]
        then
            fa_func_log Info "The specified configuration file ('${fa_var_configuration_file}') does not exist"
            fa_func_log Error "The 'Installation Configuration' choice is invalid"
            exit 91
        fi
        fa_var_current_LOG_FILE="$fa_var_LOG_FILE"
        fa_func_load_configuration
        fa_var_new_LOG_FILE="$fa_var_LOG_FILE"
        fa_var_LOG_FILE="$fa_var_current_LOG_FILE"
        fa_func_validate_settings
        if [ -n "$fa_var_CRON_SCHEDULE" ] && [ ! -d '/etc/cron.d' ]
        then
            fa_func_log Info "Cannot create cron job when '/etc/cron.d' does not exist"
            fa_func_log Error "The 'CRON_SCHEDULE' setting is invalid"
            exit 91
        elif [ -n "$fa_var_CRON_SCHEDULE" ] && [ ! -w '/etc/cron.d' ]
        then
            fa_func_log Info "Cannot create or modify files in '/etc/cron.d'"
            fa_func_log Warning "The 'CRON_SCHEDULE' setting is invalid"
            fa_func_log Error "Insufficient permissions to create cron job"
            fa_func_log Info "Try running the Fetch Apply install utility with 'sudo'"
            exit 91
        fi
        if [ "$fa_var_new_LOG_FILE" != 'None' ]
        then
            if [ -e "$(dirname "$fa_var_new_LOG_FILE")" ] && [ ! -w "$(dirname "$fa_var_new_LOG_FILE")" ]
            then
                fa_func_log Info "Cannot create or modify files in '$(dirname "$fa_var_new_LOG_FILE")'"
                fa_func_log Error "Insufficient permissions to create log file"
                fa_func_log Warning "The 'LOG_FILE' setting is invalid"
                fa_func_log Info "Try running Fetch Apply with 'sudo'"
                exit 91
            fi
        fi
        fa_func_log Action "Validating installation preferences..."
        if [ -e "$fa_var_new_root" ] && [ -n "$(ls -1 "$fa_var_new_root")" ]
        then
            fa_func_log Info "'${fa_var_new_root}' is not an empty or nonexistent directory"
            fa_func_log Error "The 'Installation Location' choice is invalid"
            exit 91
        fi
        if [ -d "$fa_var_new_root" ] && [ ! -w "$fa_var_new_root" ]
        then
            fa_func_log Info "No write permissions for the installation path ('${fa_var_new_root}')"
            fa_func_log Error "The 'Installation Location' choice is invalid"
            exit 91
        elif [ ! -e "$fa_var_new_root" ] && [ -e "$(dirname "$fa_var_new_root")"] && \
            [ ! -w "$(dirname "$fa_var_new_root")" ]
        then
            fa_func_log Info "No write permissions for the installation path parent directory ('$(dirname "${fa_var_new_root}")')"
            fa_func_log Error "The 'Installation Location' choice is invalid"
            exit 91
        fi
        if [ -e "$fa_var_launch_file" ]
        then
            fa_func_log Info "The file '$fa_var_launch_file' already exists"
            fa_func_log Error "The 'Location in PATH' choice is invalid"
            exit 91
        fi
        if [ ! -w "$(dirname "$fa_var_launch_file")" ]
        then
            fa_func_log Info "No write permissions for the directory '$(dirname "${fa_var_launch_file}")' in PATH)"
            fa_func_log Error "The 'Location in PATH' choice is invalid"
            exit 91
        fi
    }

    fa_func_install() {
        if [ -d '/etc' ] && [ -w '/etc' ]
        then
            fa_var_configuration_file_destination='/etc/fetch-apply.conf'
        else
            fa_var_configuration_file_destination="${fa_var_new_root}/fetch-apply.conf"
        fi
        fa_func_install_banner
        if [ "$fa_var_interactive" = "true" ]
        then
            printfc "${TERM_GREEN}${TERM_BOLD}READY FOR INSTALLATION${TERM_END_BOLD}\n\n"
            printfc "${TERM_ORANGE}Files and Directories to be Created or Overwritten:\n"
            printfc "${TERM_ITALIC}"
            printfc "  - ${TERM_MAGENTA}${fa_var_new_root}/\n"
            printfc "  - ${TERM_MAGENTA}${fa_var_new_root}/fa.sh\n"
            if [ -f "${fa_var_root}/palette" ]
            then
                printfc "  - ${TERM_MAGENTA}${fa_var_new_root}/palette\n"
            fi
            printfc "  - ${TERM_MAGENTA}${fa_var_new_root}/operations/\n"
            printfc "  - ${TERM_MAGENTA}${fa_var_new_root}/status/\n"
            printfc "  - ${TERM_MAGENTA}${fa_var_new_root}/status/.first_run\n"
            printfc "  - ${TERM_MAGENTA}${fa_var_new_root}/status/applied-initializers\n"
            printfc "  - ${TERM_MAGENTA}${fa_var_new_root}/status/applied-patches\n"
            printfc "  - ${TERM_MAGENTA}${fa_var_new_root}/status/applied-runs\n"
            printfc "  - ${TERM_MAGENTA}${fa_var_configuration_file_destination}\n"
            printfc "  - ${TERM_MAGENTA}${fa_var_new_LOG_FILE}\n"
            if [ -n "$fa_var_CRON_SCHEDULE" ]
            then
                printfc "  - ${TERM_MAGENTA}/etc/cron.d/fetch-apply\n"
            fi
            printfc "  - ${TERM_MAGENTA}${fa_var_launch_file}\n\n"
            if [ ! -f "${fa_var_root}/palette" ]
            then
                fa_func_log Info "The file '${fa_var_root}/palette' does not exist"
                fa_func_log Warning "This installation will not include support for colorized terminal output"
                printfc "\n"
            fi
            printfc "\n${TERM_ITALIC}Press enter to install Fetch Apply...${TERM_END_ITALIC}\n"
            read fa_var_enter_pressed
            fa_func_install_banner
        fi
        fa_func_log Action "Installing Fetch Apply..."
        fa_var_config_output_file=""
        fa_func_log Action "Making directory structure..."
        mkdir -p "${fa_var_new_root}/operations"
        mkdir -p "${fa_var_new_root}/status"
        fa_func_log Action "Copying configuration file..."
        cp "$fa_var_configuration_file" "$fa_var_configuration_file_destination" 2>/dev/null
        fa_func_log Action "Creating log file..."
        touch "$fa_var_new_LOG_FILE"
        fa_func_log Action "Creating status files..."
        touch "${fa_var_new_root}/status/.first_run"
        touch "${fa_var_new_root}/status/applied-initializers"
        touch "${fa_var_new_root}/status/applied-patches"
        touch "${fa_var_new_root}/status/completed-runs"
        fa_func_log Action "Copying Fetch Apply script..."
        cp "$fa_var_self" "${fa_var_new_root}/fa.sh"
        if [ -f "${fa_var_root}/palette" ]
        then
            fa_func_log Action "Enabling colorized output..."
            cp "${fa_var_root}/palette" "${fa_var_new_root}/palette"
        fi
        if [ -n "$fa_var_ops_repo_url" ]
        then
            fa_func_log Action "Cloning operations repository..."
            printfc "$TERM_FAINT"
            git clone "$fa_var_ops_repo_url" "${fa_var_new_root}/operations"
            printfc "$TERM_END_FAINT"
        fi
        fa_func_log Action "Adding Fetch Apply to PATH..."
        ln -sf "${fa_var_new_root}/fa.sh" "$fa_var_launch_file"
        if [ -n "$fa_var_CRON_SCHEDULE" ]
        then
            fa_func_log Action "Creating cron job..."
            printf "SHELL=${fa_var_SHELL}\nPATH=${PATH}\n" > '/etc/cron.d/fetch-apply'
            printf "${fa_var_CRON_SCHEDULE} root ${fa_var_launch_command}\n" >> '/etc/cron.d/fetch-apply'
        fi
        printfc "\n\n"
        fa_func_log Success "INSTALLATION COMPLETE!"
        printfc "\n"
        printfc "You can now run Fetch Apply using the command: "
        printfc "${TERM_MAGENTA}${TERM_BOLD}$(basename "${fa_var_launch_file}")${TERM_END_BOLD}\n\n"
        if [ "$fa_var_GIT_ENABLED" != "true" ] || [ -z "$fa_var_ops_repo_url" ]
        then
            printfc "$TERM_ITALIC"
            printfc "${TERM_YELLOW}Don't forget to copy your operations repository to:\n\n"
            printfc "${TERM_YELLOW}    '${fa_var_new_root}/operations'\n\n"
            printfc "$TERM_BOLD"
            printfc "${TERM_YELLOW}Fetch Apply will "
            printfc "${TERM_YELLOW}${TERM_UNDERLINE}NOT WORK${TERM_END_UNDERLINE} "
            printfc "${TERM_YELLOW}until you do so!\n\n"
            printfc "${TERM_END_BOLD}${TERM_END_ITALIC}"
        fi
    }
}


# Initialize Fetch Apply:
set -u
fa_var_starting_directory="$(pwd)"
fa_var_self="$0"
if [ -n "$(command -v "$fa_var_self")" ]
then # The launch command can be shortened, as it appears to be in PATH
    fa_var_launch_command="$(basename "$fa_var_self")"
else
    fa_var_launch_command="$fa_var_self"
fi
fa_var_configuration_file=""
if [ "$#" = "0" ] || [ "$1" != "relaunched-with-specified-shell" ]
then # This is the initial launch of Fetch Apply
    # Get root directory of Fetch Apply script, dereferencing any symlinks:
    while [ -L "$fa_var_self" ]
    do
        fa_var_dereferenced="$(ls -l "${fa_var_self}")"
        fa_var_self="${fa_var_dereferenced#*"${fa_var_self} -> "}"
    done
    cd "$(dirname "$fa_var_self")"
    fa_var_root="$(pwd -P)"
    fa_var_self="${fa_var_root}/$(basename "$fa_var_self")"

    # Check for a configuration file and, if found, relaunch with specified shell:
    if [ -e "${fa_var_root}/fetch-apply.conf" ]
    then
        fa_var_configuration_file="${fa_var_root}/fetch-apply.conf"
    elif [ -e "/etc/fetch-apply.conf" ]
    then
        fa_var_configuration_file="/etc/fetch-apply.conf"
    fi
    fa_func_load_configuration
    if [ -n "$fa_var_configuration_file" ] && [ -n "$fa_var_SHELL" ]
    then
        eval "$fa_var_SHELL" "$fa_var_self" "relaunched-with-specified-shell" "$fa_var_launch_command" \
            "$fa_var_configuration_file" "$fa_var_root" "$@"
        fa_var_exit_code="$?"
        cd "$fa_var_starting_directory"
        exit "$fa_var_exit_code"
    fi
else
    fa_var_launch_command="$2"
    fa_var_configuration_file="$3"
    fa_var_root="$4"
    shift
    shift
    shift
    shift
    fa_func_load_configuration
fi
fa_func_enable_color
fa_var_currently_running=''
fa_var_lock_set_this_run='false'
fa_var_lock_file=''
fa_var_operations="${fa_var_root}/operations"
fa_var_quiet='false'
fa_var_status=''
fa_var_can_write_log_file='false'
if [ "$fa_var_LOG_FILE" != 'None' ] && [ -n "$fa_var_LOG_FILE" ]
then
    touch "$fa_var_LOG_FILE" 2>/dev/null
    if [ -w "$fa_var_LOG_FILE" ]
    then
        fa_var_can_write_log_file='true'
    fi
fi
trap fa_func_handle_exit EXIT
trap fa_func_handle_interrupt INT


# Handle utilities:
fa_var_running_utility='false'
if [ "$#" -gt "0" ]
then
    case "$1" in
        ('configure')
            shift
            fa_var_running_utility='true'
            fa_var_interactive='true'
            fa_func_configure_utility
            fa_func_default_config_settings
            for fa_var_config_argument in "$@"
            do
                if [ "$fa_var_config_argument" = '--help' ]
                then
                    fa_func_config_usage
                    exit 0
                fi
            done
            while getopts '0a:b:c:d:f:g:hi:j:l:m:o:p:r:s:u:' fa_var_option
            do
                case "$fa_var_option" in
                    ('0')
                        fa_var_interactive='false';;
                    ('a')
                        fa_var_AUTOMATIC_ASSIGNMENT="$OPTARG";;
                    ('b')
                        fa_var_OPS_REPO_BRANCH="$OPTARG";;
                    ('c')
                        fa_var_CASE_SENSITIVE="$OPTARG";;
                    ('d')
                        fa_var_SKIP_UNMODIFIED="$OPTARG";;
                    ('f')
                        fa_var_AUTO_UPDATE="$OPTARG";;
                    ('g')
                        fa_var_GIT_ENABLED="$OPTARG";;
                    ('h')
                        fa_func_config_usage
                        exit 0;;
                    ('i')
                        fa_var_IGNORE_ERRORS="$OPTARG";;
                    ('j')
                        fa_var_CRON_SCHEDULE="$OPTARG";;
                    ('l')
                        fa_var_config_LOG_FILE="$OPTARG";;
                    ('m')
                        fa_var_config_MAX_LOG_LENGTH="$OPTARG";;
                    ('o')
                        fa_var_config_output_file="$OPTARG";;
                    ('p')
                        fa_var_COLOR_PALETTE="$OPTARG";;
                    ('r')
                        fa_var_SYSTEM_ID="$OPTARG";;
                    ('s')
                        fa_var_SHELL="$OPTARG";;
                    ('u')
                        fa_var_UNIQUE="$OPTARG";;
                    ('?')
                        fa_func_log Error "The command or option '$fa_var_option' is invalid."
                        printfc "${TERM_ITALIC}"
                        printfc "${TERM_VIOLET}Please review the usage information below:${TERM_END_ITALIC}\n"
                        printfc "\n"
                        fa_func_config_usage
                        printfc "\n"
                        fa_var_quiet='true'
                        exit 91;;
                esac
            done
            if [ "$fa_var_interactive" != 'false' ]
            then
                fa_func_interactive_configure
            fi
            fa_func_validate_config_settings
            fa_func_write_configuration
            exit 90;;
        ('install')
            shift
            fa_var_running_utility='true'
            fa_var_interactive='true'
            fa_var_launch_file='/usr/sbin/fa'
            fa_var_new_root='/var/lib/fetch-apply'
            fa_var_ops_repo_url=''
            fa_func_install_utility
            for fa_var_config_argument in "$@"
            do
                if [ "$fa_var_config_argument" = '--help' ]
                then
                    fa_func_install_usage
                    exit 0
                fi
            done
            while getopts '0c:d:hu:x:' fa_var_option
            do
                case "$fa_var_option" in
                    ('0')
                        fa_var_interactive='false';;
                    ('c')
                        fa_var_configuration_file="$OPTARG";;
                    ('d')
                        fa_var_new_root="$OPTARG";;
                    ('h')
                        fa_func_install_usage
                        exit 0;;
                    ('u')
                        fa_var_ops_repo_url="$OPTARG";;
                    ('x')
                        fa_var_launch_file="$OPTARG";;
                    ('?')
                        fa_func_log Error "The command or option '$fa_var_option' is invalid."
                        printfc "${TERM_ITALIC}"
                        printfc "${TERM_VIOLET}Please review the usage information below:${TERM_END_ITALIC}\n"
                        printfc "\n"
                        fa_func_install_usage
                        printfc "\n"
                        fa_var_quiet='true'
                        exit 91;;
                esac
            done
            if [ "$fa_var_interactive" != 'false' ]
            then
                fa_func_interactive_install
            fi
            fa_func_validate_install_options
            fa_func_install
            exit 90;;
    esac
fi


# Handle commands:
for fa_var_argument in "$@"
do # Handle help and quiet options before logging or potential changes begin:
    if [ "$fa_var_argument" = '-h' ] || [ "$fa_var_argument" = '--help' ]
    then
        fa_func_usage
        exit 0
    elif [ "$fa_var_argument" = '-q' ] || [ "$fa_var_argument" = '--quiet' ]
    then
        fa_var_quiet='true'
    fi
done
if [ -z "$fa_var_configuration_file" ]
then
    fa_func_log Warning "Configuration file not found"
    fa_func_log Info "Run '${fa_var_launch_command} configure' to generate a custom configuration"
    fa_func_log Action "Continuing with default settings..."
    fa_var_status="${fa_var_root}/fetch-apply-status"
else
    fa_func_log Success "Configuration loaded"
    fa_var_status="${fa_var_root}/status"
fi
# Create the status directory, if it doesn't exist:
if [ -f "${fa_var_status}" ]
then
    fa_func_log Info "'${fa_var_status}' already exists and is a file"
    fa_func_log Error "Cannot create status directory '${fa_var_status}'"
    exit 91
else
    if [ ! -d "${fa_var_status}" ]
    then
        fa_func_log Action "Creating status directory..."
        mkdir -p "${fa_var_status}"
        touch "${fa_var_status}/.first_run"
    elif [ ! -s "${fa_var_status}/applied-initializers" ] && \
        [ ! -s "${fa_var_status}/applied-patches" ] && \
        [ ! -s "${fa_var_status}/completed-runs" ]
    then
        touch "${fa_var_status}/.first_run"
    fi
    rm -f "${fa_var_status}/class-priorities"
    rm -f "${fa_var_status}/"*"-variables"
    touch "${fa_var_status}/applied-initializers"
    touch "${fa_var_status}/applied-patches"
    touch "${fa_var_status}/completed-runs"
fi
fa_func_validate_settings

# Create the operations directory, if it doesn't exist:
if [ -f "${fa_var_operations}" ]
then
    fa_func_log Info "'${fa_var_operations}' already exists and is a file"
    fa_func_log Error "Cannot create operations directory"
    exit 91
else
    if [ ! -d "${fa_var_operations}" ]
    then
        fa_func_log Action "Creating operations directory..."
        mkdir -p "${fa_var_operations}"
    fi
fi

fa_var_applied_modules=''
fa_var_applied_roles=''
fa_var_assignments=''
fa_var_classes_dir="${fa_var_operations}/classes"
fa_var_dry_run='false'
fa_var_force='false'
if [ "$fa_var_GIT_ENABLED" = 'true' ] && [ -d "${fa_var_operations}/.git" ]
then
    fa_var_last_commit="$(cd "${fa_var_operations}" && git log -n 1 --format='%H')"
else
    fa_var_last_commit=''
fi
fa_var_lock_file="${fa_var_status}/lock"
fa_var_modules_or_roles=''
fa_var_overriden='false'
fa_var_pause_file="${fa_var_status}/pause"

cd "$fa_var_root"

# Parse any commandline arguments:
fa_var_command=""
fa_var_command_arg=""
for fa_var_argument in "$@"
do
    case "$fa_var_argument" in
        ('-d' | '--dry-run')
            fa_var_dry_run="true";;
        ('-f' | '--force')
            fa_var_force="true";;
        ('-m' | '--modules')
            fa_var_modules_or_roles="modules";;
        ('-n' | '--no-update')
            fa_var_AUTO_UPDATE="false";;
        ('-q' | '--quiet')
            fa_var_quiet="true";;
        ('-r' | '--roles')
            fa_var_modules_or_roles="roles";;
        (*)
            if [ -z "$fa_var_command" ]
            then
                fa_var_command="$fa_var_argument"
            elif [ -z "$fa_var_command_arg" ] && [ "$fa_var_command" = "run" ]
            then
                fa_var_command_arg="$fa_var_argument"
            else
                fa_func_log Error "The command or option '$fa_var_argument' is invalid."
                printfc "${TERM_ITALIC}"
                printfc "${TERM_VIOLET}Please review the usage information below:${TERM_END_ITALIC}\n"
                printfc "\n"
                fa_func_usage
                printfc "\n"
                fa_var_quiet='true'
                exit 91
            fi;;
    esac
done

fa_func_log_trim
case "$fa_var_command" in
    ('' | 'run')
        if [ -z "$fa_var_command_arg" ]
        then
            fa_func_repo_maintenance
            fa_func_full_run
            exit 90
        else
            fa_var_force="true"
            fa_func_handle_locks
            fa_func_get_assignments
            if [ "$fa_var_modules_or_roles" = "roles" ]
            then
                fa_func_apply_role "$fa_var_command_arg" ""
            elif [ "$fa_var_modules_or_roles" = "modules" ]
            then
                fa_func_apply_module "$fa_var_command_arg" ""
            else
                if [ -e "${fa_var_operations}/modules/${fa_var_command_arg}" ]
                then
                    fa_func_apply_module "$fa_var_command_arg" ""
                else
                    fa_func_log Info "The '${1}' module does not exist..."
                    if [ -e "${fa_var_operations}/roles/${fa_var_command_arg}" ]
                    then
                        fa_func_apply_role "$fa_var_command_arg" ""
                    else
                        fa_func_log Info "The '${1}' role does not exist..."
                        fa_func_log Error "The ad hoc role or module '${fa_var_command_arg}' does not exist"
                        exit 91
                    fi
                fi
            fi
            exit 90
        fi;;
    ('assignments')
        fa_func_log Action "Fetching this system's assignments..."
        fa_var_dry_run="true"
        fa_var_original_quiet="$fa_var_quiet"
        fa_var_quiet="true"
        fa_var_UNIQUE="true"
        fa_func_full_run
        fa_var_quiet="false"
        fa_func_log Info "Assigned Classes and System Directories:"
        if [ -n "$fa_var_assignments" ]
        then
            printfc "\t"
            for fa_var_assignment in $fa_var_assignments
            do
                printfc "'$(fa_func_recover_spaces "$fa_var_assignment")' "
            done
            printfc "\n\n"
        else
            printfc "\tNone.\n\n"
        fi
        fa_func_log Info "Roles to be Applied:"
        if [ -n "$fa_var_applied_roles" ]
        then
            printfc "\t"
            for fa_var_applied_role in $fa_var_applied_roles
            do
                printfc "'$(fa_func_recover_spaces "$fa_var_applied_role")' "
            done
            printfc "\n\n"
        else
            printfc "\tNone.\n\n"
        fi
        fa_func_log Info "Modules to be Applied:"
        if [ -n "$fa_var_applied_modules" ]
        then
            printfc "\t"
            for fa_var_applied_module in $fa_var_applied_modules
            do
                printfc "'$(fa_func_recover_spaces "$fa_var_applied_module")' "
            done
            printfc "\n\n"
        else
            printfc "\tNone.\n\n"
        fi
        fa_var_quiet="$fa_var_original_quiet"
        exit 0;;
    ('clear-inits')
        fa_func_log Action "Resetting applied initializers..."
        if [ "$fa_var_dry_run" = "false" ]
        then
            printf "" > "${fa_var_status}/applied-initializers"
        fi
        fa_func_log Success "Applied initializers reset..."
        exit 90;;
    ('clear-patches')
        fa_func_log Action "Resetting applied patches..."
        if [ "$fa_var_dry_run" = "false" ]
        then
            printf "" > "${fa_var_status}/applied-patches"
        fi
        fa_func_log Success "Applied patches reset..."
        exit 90;;
    ('pause')
        if [ -e "$fa_var_pause_file" ]
        then
            fa_func_log Warning "Cannot pause Fetch Apply"
            fa_func_log Info "Fetch Apply was already paused on '$(cat "$fa_var_pause_file")'"
            exit 91
        else
            fa_func_log Action "Pausing Fetch Apply..."
            if [ "$fa_var_dry_run" = "false" ]
            then
                printf "$(date)" > "$fa_var_pause_file"
            fi
            fa_func_log Success "Fetch Apply paused"
            exit 90
        fi;;
    ('recover')
        if [ -e "$fa_var_lock_file" ]
        then
            fa_func_log Action "Unsetting run lock from '$(cat "$fa_var_lock_file")'..."
            if [ "$fa_var_dry_run" = "false" ]
            then
                rm -f "$fa_var_lock_file"
            fi
            fa_func_log Success "Run lock unset"
            exit 90
        else
            fa_func_log Warning "The run lock is not set"
            exit 91
        fi;;
    ('reset')
        if [ "$fa_var_GIT_ENABLED" = "true" ]
        then
            fa_func_log Action "Hard resetting operations repository..."
            if [ "$fa_var_dry_run" = "false" ]
            then
                printfc "$TERM_FAINT"
                cd "${fa_var_operations}"
                git fetch origin
                git reset --hard origin
                git clean -dfx
                printfc "$TERM_END_FAINT"
            fi
            fa_func_log Success "Operations repository hard reset"
            exit 90
        else
            fa_func_log Error "Cannot reset operations repository"
            fa_func_log Info "Git is not enabled in your settings..."
            exit 91
        fi;;
    ('resume')
        if [ -e "$fa_var_pause_file" ]
        then
            fa_func_log Action "Unsetting pause lock from '$(cat "$fa_var_pause_file")'..."
            if [ "$fa_var_dry_run" = "false" ]
            then
                rm -f "$fa_var_pause_file"
            fi
            fa_func_log Success "Fetch Apply unpaused"
            exit 90
        else
            fa_func_log Warning "Fetch Apply is not paused"
            exit 91
        fi;;
    ('status')
        fa_func_log Action "Getting Fetch Apply status..."
        printf "\n${TERM_VIOLET}${TERM_UNDERLINE}Fetch Apply Status:${TERM_END_UNDERLINE}\n"
        printf "\n"
        printf "${TERM_BOLD}${TERM_BLUE}System ID:${TERM_END_BOLD}${TERM_MAGENTA} ${fa_var_SYSTEM_ID}\n"
        printf "${TERM_BOLD}${TERM_BLUE}Applied Initializers:${TERM_END_BOLD}${TERM_MAGENTA} "
        printf "$(cat "${fa_var_status}/applied-initializers" | tr '\n' ' ')\n"
        printf "${TERM_BOLD}${TERM_BLUE}Last Five Patches:${TERM_END_BOLD}${TERM_MAGENTA} "
        printf "$(cat "${fa_var_status}/applied-patches" | tail -n 5 | tr '\n' ' ')\n"
        printf "\n"
        printf "${TERM_BOLD}${TERM_BLUE}Pause Lock:${TERM_END_BOLD}${TERM_MAGENTA} "
        if [ -e "$fa_var_pause_file" ]
        then
            printf "Set ${TERM_ITALIC}($(cat "$fa_var_pause_file"))${TERM_END_ITALIC}\n"
        else
            printf "Unset\n"
        fi
        printf "${TERM_BOLD}${TERM_BLUE}Run Lock:${TERM_END_BOLD}${TERM_MAGENTA} "
        if [ -e "$fa_var_lock_file" ]
        then
            printf "Set ${TERM_ITALIC}($(cat "$fa_var_lock_file"))${TERM_END_ITALIC}\n"
        else
            printf "Unset\n"
        fi
        printf "\n"
        printf "${TERM_BOLD}${TERM_BLUE}Last Full Run:${TERM_END_BOLD}${TERM_MAGENTA} "
        if [ -s "${fa_var_status}/completed-runs" ]
        then
            printf "$(cat "${fa_var_status}/completed-runs" | tail -n 1)\n"
        else
            printf "Never\n"
        fi
        printf "${TERM_BOLD}${TERM_BLUE}Last Logged Activity:${TERM_END_BOLD}${TERM_MAGENTA} "
        if [ "$fa_var_LOG_FILE" != "None" ] && [ -s "$fa_var_LOG_FILE" ]
        then
            printf "$(tail -n1 "$fa_var_LOG_FILE" | cut -d ' ' -f '1-6')\n"
        else
            printf "None\n"
        fi
        if [ "$fa_var_GIT_ENABLED" = "true" ]
        then
            printf "${TERM_BOLD}${TERM_BLUE}Last Operations Repository Update:${TERM_END_BOLD}${TERM_MAGENTA} "
            printf "$(cd "${fa_var_operations}" && git log -1 --pretty='%cd')\n"
        fi
        printf "${TERM_BOLD}${TERM_BLUE}Cron Schedule:${TERM_END_BOLD}${TERM_MAGENTA} "
        if [ -s '/etc/cron.d/fa' ]
        then
            fa_var_last_line_cron="$(tail -n1 '/etc/cron.d/fa')"
            fa_var_cron_entry="${fa_var_last_line_cron%% root*}"
            printf "${fa_var_cron_entry}\n"
        else
            printf "Not Found\n"
        fi;;
    ('update')
        if [ "$fa_var_GIT_ENABLED" = "true" ]
        then
            if [ "$fa_var_SKIP_UNMODIFIED" = "true" ] && [ "$fa_var_force" = "false" ]
            then
                fa_func_log Info "The 'SKIP_UNMODIFIED' setting is set to 'true'"
                fa_func_log Warning "Manually updating the operations repository could cause undesired behavior"
                fa_func_log Error "Refusing to update operations repository"
                fa_func_log Info "Rerun this command with '--force' to override this warning"
                exit 91
            else
                if [ "$fa_var_dry_run" = "false" ]
                then
                    fa_func_repo_maintenance
                fi
                fa_func_log Success "Operations repository updated"
                exit 90
            fi
        else
            fa_func_log Error "Cannot update operations repository"
            fa_func_log Info "Git is not enabled in your settings..."
            exit 91
        fi;;
    (*)
        fa_func_log Error "The command or option '$fa_var_command' is invalid."
        printfc "${TERM_ITALIC}"
        printfc "${TERM_VIOLET}Please review the usage information below:${TERM_END_ITALIC}\n"
        printfc "\n"
        fa_func_usage
        printfc "\n"
        fa_var_quiet='true'
        exit 91;;
esac
exit 0
