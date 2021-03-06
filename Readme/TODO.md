
# List of tasks that needs to be done

This is a project global list which applies to several or all scripts.

For smaller todo's local to specific scripts and files see individual files, you can use workspace\
recommended extension `todo-tree` to navigate TODO, HACK and NOTE tags.

Note that some todo's listed here are are duplicate of todo's inside individual scripts, this is\
intentionally for important todo's to make is easier to tell where to look at while resolving this list.

todo's in this file are categorized into following sections:

1. **Ongoing**              Never ending or continuous work
2. **High priority**        Must be resolved ASAP
3. **Medium priority**      Important
4. **Low priority**         Not very important
5. **Done**                 It's done and kept here for reference.

## Table of contents

- [List of tasks that needs to be done](#list-of-tasks-that-needs-to-be-done)
  - [Table of contents](#table-of-contents)
  - [Ongoing](#ongoing)
  - [High priority](#high-priority)
  - [Medium priority](#medium-priority)
  - [Low priority](#low-priority)
  - [Done](#done)

## Ongoing

1. Modules

    - 3rd party scripts and modules need to be checked for updates or useful changes
    - Find-Installation function is hungry for constant updates and improvements

2. Project scripts

    - Resolving existing and enabling new/disabled analyzer warnings
    - Spellchecking files
    - Move duplicate and global todo's from scripts here into global todo list

3. Code style

    - Limit code to 100-120 column rule.

4. Project release checklist

    - Cleanup repository:
        - `git clean -d -x --dry-run` `git clean -d -x -f`
        - `git prune --dry-run` `git prune`
        - `git repack -d -F`
    - Module manifests, comment out unit test exports (currently only Ruleset.ProgramInfo)
    - ProjectSettings.ps1 disable variables: Develop, ForceLoad
    - ProjectSettings.ps1 restore variables: TestUser, TestAdmin, DefaultUser, FirewallLogsFolder
    - ProjectSettings.ps1 verify auto updated variables: ProjectCheck, ModulesCheck, ServicesCheck
    - Increment project version in all places mentioning version
    - Run script analyzer
    - Run all tests in both release and develop mode, both Desktop and Core editions
    - Run master script on all target OS editions
    - Update CHANGELOG.md
    - Verify links to repository are pointing to master except if develop branch is wanted,
    links should be then tested on master branch.
    - There are 3 kinds of links to check:\
    WindowsFirewallRuleset/develop\
    WindowsFirewallRuleset/blob/develop\
    WindowsFirewallRuleset/tree/develop

5. Documentation

    - Updating documentation, comment based help and rule description
    - Cleanup global and script scope TODO list

## High priority

1. Modules

    - There are breaks missing for switches all over the place
    - Revisit code and make consistent PSCustomObject properties for all function outputs, consider
    using [formats](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_format.ps1xml?view=powershell-7)
    for custom objects
    - Need to see which functions/commands may throw and setup try catch blocks
    - Revisit parameter validation for functions, specifically acceptance of NULL or empty
    - Registry drilling for some rules are complex and specific, such as for NVIDIA or OneDrive,
    in these and probably most other similar cases we should return installation table which
    would be used inside rule script to get individual paths for individual programs.
    - Revisit function parameters, their types, aliases, names are singular, well known etc..
    - Change bool parameters to switch where possible
    - Revisit naming convention for ConvertFrom/ConvertTo it's not clear what is being converted,
    some other functions also have odd names
    - 3rd party modules should be integrated by separating 3rd party code and generating new GUID
    to avoid confusion due to different versioning and new code

2. Project scripts

    - Apply only rules for which executable exists, Test-File function
    - Auto detect interfaces, ie. to be used with InterfaceAlias parameter
    - For individual runs of rule scripts we should call gpupdate.exe
    - $null corectness, in specific cases just `if (something)` doesn't work as it should

3. Rules

    - Paths to fix: visio, project
    - Rules to fix: vcpkg, msys2, internet browser (auto loads)
    - Now that common parameters are removed need to update the order of rule parameters,
    also not all are the same.
    - Variable to conditionally apply rules for Administrators
    - Allow unicast response to multicast traffic option is there but we have multicast specific
    rules, so it is a bad desing since we break the builtin feature, also it's not clear what effects
    does does option provide.
    - Rule display name, we need some conventional way to name them for sortability reasons and to
    make them easy to spot in firewall GUI
    - Rules for dropped UDP traffic generated by system
    - Setting up WORKGROUP doesn't work with this firewall

4. Test and debugging

    - For Write-Debug $PSBoundParameters.Values check if it's in process block or begin block,
    make sure wanted parameters are shown, make sure values are visible instead of object name
    - We should use try/catch in test scripts to avoid writing errors and write information instead,
    So that `Run-AllTests.ps1` gets clean output, not very useful if testing with PS Core since
    -CIM call will fail, see Get-SystemSKU test
    - Unit tests for private functions in "Ruleset.Firewall" module are missing
    - Unit tests for "Ruleset.Logging" include scripts are missing

5. Code style

    - Need convention for variable naming, such as Group, Groups or User vs Principal, difference is
    that one is expanded property while other can be custom object. Many similar cases for naming.

6. Partially fixed, need testing and/or improvements

    - Most program query functions return multiple program instances,
    need to select latest or add multiple rules.
    - Module functions and rules for OneDrive have partial fix, needs design improvements
    - Installation variables must be empty in development mode only to be able to test program
    search functions, for release providing a path is needed to prevent "fix" info messages
    - Implement Importing/Exporting rules, including rules with no group
    - Rules for store apps for administrators

7. Other

    - Need convention for output streams, when to use which one, and also common format for quoting
    and pointing out local variables, some place are missing streams while others have too many of them,
    Also somewhere same (ie. debug stream) can be put in 2 places in call stack, which one to chose?
    - Need global setting to allow "advanced" warnings, which will show at a minimum function name
    where the warning was generated, or just save this info to logs.

## Medium priority

1. Modules

    - Make it possible to apply rules to remote machine, currently partially supported
    - Provide following keywords in function comments: .DESCRIPTION .LINK .COMPONENT .ROLE .FUNCTIONALITY
    - DefaultParameterSetName for functions with parameter sets is missing but might be desired
    - Revisit how functions return and what they return, return keyword vs Write-Output,
    if pipeline support is needed for that function
    - We probably don't need VSSetup module
    - Line numbers for verbose and debug messages
    - Use begin/process/end to make functions work on pipeline as needed
    - Need to add default error description into catch blocks in addition to our own
    for better description
    - Need to check if WinRM service is started when contacting computers via CIM
    - Functions which use ShouldProcess must not ask for additional input, but use additional
    ShouldProcess instead.
    - Write-Error will fail if -TargetObject is not set, in cases where this is possible we should
    supply string instead. See ComputerInfo\Get-ConfiguredAdapter for example
    - 3rd party modules are not consistent with our own modules regarding folder and structure and
    high level implementation
    - Some function variables such as "ComputerNames" take array of values, make sure this functionality
    actually makes sense, and also for naming consistency for ValueFromPipelineByPropertyName
    - When drilling registry for programs in user profile we need to load user hive into registry
    if the user is not logged into PC, see implementation for OneDrive

2. Project scripts

    - Access is denied randomly while executing rules, need some check around this, ex. catching the
    error and ask to re-run the script.
    - make possible to apply or enable only rules relevant for current firewall profile
    - Add #Requires -Modules to scripts to remove module inclusions and load variables
    - Make $WhatIfPreference for rules, we should skip everything except rules.
    - For remote computers need ComputerName variables/parameters, note this could also be
    learned/specified with PolicyStore parameter
    - Select-Object -Last 1 instead of -First 1 to get highest value, need to verify
    - Rules for services, need to check services are networking services, if not write warning,
    could be implemented in Test-Service function
    - Instead of Approve-Execute we should use ShouldProcess or ShouldContinue passing in context variable.

3. Rules

    - Some rules are missing comments
    - Make display names and groups modular for easy search, ie. group - subgroup, Company - Program,
    This can also prove useful for wfp state logs to determine blocking rule
    - We need some better and unified approach to write rule descriptions, because it looks ugly
    now, since comments must not be formatted, formatting would be visible in GUI.
    - Some rules apply to both IPv4 and IPv6 such as qBittorrent.ps1, for these we should group them
    into "hybrid" folder instead of IPv4 or IPv6 folder which should be IP version specific rules.
    - Need to verify rule display description to include IPv4 or IPv6 in cases where these rules
    apply to specific IP version to avoid confusion to what these rules apply.
    - We handle mostly client rules and no server rules, same case as with IPv4 vs IPv6
    grouping model, we should define a model for server rules (not necessarily Windows Server,
    workstation PC can also act as server)
    - Rules for programs (ex. userprofile) which apply to multiple users should assign specific
    user to LocalUser instead of assigning user group, there are duplicate todo's in code about this,
    This also implies to todo's about returning installation table to rule scripts!
    - If target program does not exist conditionally disable rule and update rule description,
    or insert into rule name that the rule has no effect, or write a list into separate log file.

4. Test and debugging

    - Move Ruleset.IP tests into test folder, clean up directory add streams
    - Many test cases are local to our environment, other people might get different results
    - Test everything on preview Windows
    - Some test outputs will be messed up, ex. some output might be shown prematurely,
    see get-usergroup test for example or RunAllTests
    - there is no test for Get-Permutation in Ruleset.IP
    - Pester tests are out of date and don't work well with Pester 5.x

5. Code style

    - Indentation doesn't work as expected for pipelines, currently using "NoIndentation", and
    there is no indentation for back ticks
    - We need a script to recursively invoke PSScriptAnalyzer formatter for entry project
    - Set code regions where applicable

6. Documentation

    - update FirewallParameters.md with a list of incompatible parameters for reference
    - a lot of comment based documentation is missing comments
    - FirewallParameters.md contains missing mapping
    - FirewallParameters.md contains no info about compartments and IPSec setup
    - Universal and quick setup to install all required modules for all hosts and users.

7. Other

    - Some cmdlets take encoding parameter, we should probably have a variable to specify encoding
    - There are many places where Write-Progress could be useful

## Low priority

1. Modules

    - Function to check executables for signature and virus total hash
    - localhost != `[System.Environment]::MachineName` because strings are not the same
    - Write-Error streams should be extended to include exception record etc.
    - Write-Error categories should be checked, some are inconsistent with error
    - Write-Error in catch blocks should include thrown object, see Set-Permission.ps1
    - Some executables won't be found in cases where installed program didn't finish installing
    it self but is otherwise present on system, examples such as steam, games with launcher,
    or built in store apps.
    We can show additional information about the failure in the console when this is the case
    - Since the scripts are run as Administrator, we need a way to check who is the actual standard
    user, to be able to check for required modules in user directory if not installed system wide.
    - Checking local or remote computers will be performed multiple times in call stack
    slowing down execution.
    - EXAMPLE comments, at least 3 examples and should be in the form of:
    PS> Get-Something
    Something output
    - Function/Table with list of executables that don't exist on specific editions of Windows is
    needed to prevent loading rules for such programs
    - Modules should have updatable help, and, there is no online version for about module topics
    - Need a function to generate a list of files included in module and perform comparison with
    manifest FileList entries

2. Project scripts

    - Detect if script ran manually, to be able to reset errors and warning status, or to
    conditionally run gpuupdate.exe
    - Test already loaded rules if pointing to valid program or service, also query rules which are
    missing Local user owner, InterfaceType and similar for improvement
    - Script to scan registry for rules installed by malware or hackers,
    ex. those not consistent with project rules.
    - Count invalid paths in each script
    - Measure execution time for each or all scripts.
    - We use `Set-NetFirewallSetting` but use only a subset of parameters, other parameters are
    meaningful only with IPSec
    - Write a set of scripts or module for network troubleshooting, such as WORKGROUP troubleshooting
    or generating logs and reports.
    - Replace -Tags "tag_name" with global variable, more granular tags are needed
    - All streams same convention:
    (ex. doing something $Variable v$Version instead of doing $Variable $Version),
    also same convention regarding variable value quoting with '' single quotes
    - Write a script to add context menus for Windows PowerShell
    - Need variables that would avoid prompts and set up firewall with minimum user intervention
    - Adjust all scripts according to templates
    - First time user warnings and notices should be handled with code (ex. ransomware protection setting)
    - Progress line or percentage in script context for master script

3. Rules

    - Apply local IP to all rules, as optional feature because it depends if IP is static
    - Implement unique names and groups for rules, -Name and -Group parameter vs -Display*
    - Many rules are compatible for older system, and can be configured to specify platform for ex.
    Windows 7 or 8
    - Some executables are not exclusive to all editions of Windows, also some rules such as
    Nvidia drivers won't work in virtual machine since driver was not installed or no hardware access

4. Test and debugging

    - Convert tests to use Pester if possible or separate them into pester tests and experiment tests
    - Testing with ISE, different PS hosts and environments
    - Test to test out templates
    - Some tests are very out of date because rarely useful, ex. TestProjectSettings or TestGlobalVariables
    - Almost all tests need more test cases and consistency improvements

5. Code style

    - For variables with no explicitly decalred type, put "Typename" comment from Get-Member output

6. Documentation

   - ManageGPOFirwall.md contains no documentation
   - Predefined rule list in PredefinedRules.md is out of date

7. Other

    - Test for 32bit powershell and OS, some rules are 64bit OS specific, 32bit specifics might be
    missing
    - mTail coloring configuration contains gremlins (bad chars), need to test and deal with them
    - Important Promt's should probably not depend on $InformationPreference
    - See how, could we make use of Plaster for template generation

## Done

1. Modules
    - Importing modules from withing modules should be imported into global scope
    - Versioning of module should be separate from project versioning
    - Modules are named "AllPlatforms" or "Windows" however they contain platform specific or
    non platform specific functions, need to revisit naming convention
    - Some functions return multiple return types, how to use [OutputType()]?
    - User canceling operation should be displayed with warning instead of debug stream

2. Project scripts

    - Information output is not enabled for modules and probably other code
    - Use `Get-NetConnectionProfile` to aks user / set default network profile
    - Take out of deprecated scripts what can be used, remove the rest
    - We should add `Scripts` folder to PS scripts path in ProjectSettings

3. Rules

    - rules to fix: qbittorrent, Steam
    - Rules for NVIDIA need constant updates, software changes are breaking

4. Testing and debugging

    - Need global test variable to set up valid Windows username which is performing tests
    - Some tests fail to run in non "develop" mode due to missing variables
    - A lot of pester tests from Ruleset.IP module require private function export,
    make sure the rest of a module works fine without these private exports

5. Documentation

    - INPUTS and OUTPUTS are not well described, these apply only to pipelines

6. Code style

    - Separate comment based keywords so that there is one line between a comment and next keyword
