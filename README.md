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

This project was heavily inspired by
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
information in a file.

Create the virtual environment:

    venv_make

Using the file `python_version.txt` (created during the initialization)
it creates the virtual environment for the project. The virtualenv is
activated automatically.

For convenience, two jump scripts are also created. One of them is in
the project folder and the other one is in the virtualenv folder. If
you type `. cd_venv_dir.sh`, then you find yourself in the virtualenv
folder. Typing `. cd_project_dir.sh` you are redirected back to the
project folder.

Activating / deactivating a virtual environment
-----------------------------------------------
Activate (in the project folder):

    on

Deactivate:

    off

Create a temporary virtual environment
--------------------------------------
It is useful if you want to try a module quickly but you don't want to
install it globally with `sudo pip ...`.

    venv_tmp

You get a temporary project folder and an associated virtual environment
in `/tmp`. Note that when you deactivate it, it is not deleted
automatically!
