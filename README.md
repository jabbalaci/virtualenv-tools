Virtualenv Tools for Bash
=========================

Introduction
------------
This shell script contains some useful functions to work with
Python virtual environments. It can be considered as a minimalistic
[virtualenvwrapper](https://virtualenvwrapper.readthedocs.org/en/latest/)
alternative. I've used virtualenvwrapper for years but I
only needed just a fraction of its features. So I decided
to write my own wrapper functions for the plain old
[virtualenv](https://virtualenv.readthedocs.org/en/latest/) command.

This project was inspired by
<https://github.com/jaapz/virtualenv-tools>. jaapz's work gave me the
idea to write my own wrapper functions.

Usage
-----
This shell script is specific for Bash. First, add the following line
to the end of your `~/.bashrc` file:

    source /path/to/this/virtualenv.sh

I like to separate a project (with my source code) and its virtual
environment (which contains the Python interpreter and the installed
packages). By default, virtualenvs are created in the folder
`~/.virtualenvs`. To change it, just edit the variable `WORKON_HOME`
at the top of `virtualenv.sh`.

Initialize a project folder:

    venv_init

Provide the Python version (2 or 3) interactively and you get a
file called `python_version.txt` whose content is either
"python2" or "python3". I think it's a good idea to store this
information in a file because if you work with Python 2 and
Python 3 projects too, this file will tell you immediately
what Python version the project was written in. This command also
creates a script called `update_requirements.sh` that prints the
installed packages with their versions to the standard output.
This command calls `venv_make` automatically,
so the virtual environment is also created for you. An empty
`requirements.txt` file is also created.

This command adds 2 extra files to your project. One of
them is called `alap.py`, which is a basic skeleton file. The other
file is called `caller.sh`, which launches `alap.py` by default.
You can call `caller.sh` from any directory, and you don't even
need to activate the virt. env. of the project. `caller.sh` will take
care all of that for you.

If you have an initialized folder (that has `python_version.txt`)
in it but the virt. env. is missing, then run this command:

    venv_make

Using the file `python_version.txt` (created during the initialization)
it creates the virtual environment for the project. It updates `pip` to
the latest version and the virtualenv is activated automatically.

If you have a non-empty `requirements.txt` file, then the
script asks if you want to install the packages in this file.

For convenience, two jump scripts are also created. One of them is in
the project folder and the other one is in the virtualenv folder. If
you type `. cd_venv_dir.sh`, then you find yourself in the virtualenv
folder. Typing `. cd_project_dir.sh` you are redirected back to the
project folder. (The `.` is the short form of `source`.)

Activating / deactivating a virtual environment
-----------------------------------------------
Activate (in the project folder):

    on

If you are in a subfolder of your project, then you
don't need to go back to the project's root folder every time when
you want to activate the project! Simply type `on ..` or `on ../..`, etc.,
depending on which subfolder you are in.

Instead of `on ../..`, you can simply type `on ...` too. `on ....` means `on ../../..`, etc.

Deactivate (anywhere):

    off

Automatic activating / deactivating a virtual environment
----------------------------------------------------------------
By default, your virtualenv will be activated automatically when
you enter a directory that has an attached virtual environment.

Prerequisite: the virtual env. must be created with this tool, i.e.
with `venv_init` and `venv_make`. Why? The script checks the presence
of the file `cd_venv_dir.sh`, which is created by `venv_make`.

If you don't need this auto-activation feature, then set the
value of the variable `ALLOW_VIRTUALENV_AUTO_ACTIVATE` to `0`.

Update requirements.txt
-----------------------
Upon initialization a convenience script was created in the project
folder called `update_requirements.sh`. If you installed a new
package, or a package was updated, then use this command to
update your `requirements.txt` file:

    ./update_requirements.sh > requirements.txt

Create a temporary virtual environment
--------------------------------------
It is useful if you want to try a module quickly but you don't want to
install it globally with `sudo pip ...`.

    venv_tmp

You get a temporary project folder and an associated virtual environment
in `/tmp`. Note that when you deactivate it, it is not deleted
automatically!

Visual Studio Code support (NEW!)
---------------------------------
To use VS Code in a virtual environment, you need to specify the
location of the local Python interpreter in your workspace settings
(`.vscode/settings.json`). If you run

    venv_init_vscode

then your workspace settings will be initialized and VS Code will
use the Python interpreter of the virt. env.

Tips
----
All the commands mentioned above start with `venv_`. Thus, you
don't need to memorize their names. Just type `ven<TAB>` or
`venv_<TAB>` and bash will do TAB-completion for you.
