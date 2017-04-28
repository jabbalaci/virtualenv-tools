# START: Jabba's Python virtualenv tools
# heavily inspired by https://github.com/jaapz/virtualenv-tools

# virtualenvs will be created in this directory
# if this variable is not defined, then the virtualenv will be created in the project folder
export WORKON_HOME=$HOME/.virtualenvs

# if it's allowed, then when you enter a directory and it has
# an associated virtual env., then the venv will be activated automatically
# possible values: 0 or 1
ALLOW_VIRTUALENV_AUTO_ACTIVATE=1


read -d '' CALLER_SH << "EOF"
#!/usr/bin/env bash;
;
SCRIPT=`realpath -s $0`;
SCRIPTPATH=`dirname $SCRIPT`;
cd $SCRIPTPATH;
;
VENV_DIR=`cat cd_venv_dir.sh | sed -e 's/^cd //' -e 's/"//g'`;
;
export PATH=$VENV_DIR/bin:$PATH;
;
./alap.py "$@"
EOF

read -d '' PY2 << "EOF"
#!/usr/bin/env python2;
# coding: utf-8;
;
from __future__ import (absolute_import, division,;
........................print_function, unicode_literals);
;
;
def main():;
....print('Py2→3');
;
##############################################################################;
;
if __name__ == "__main__":;
....main()
EOF

read -d '' PY3 << "EOF"
#!/usr/bin/env python3;
# coding: utf-8;
;
;
def main():;
....print('Py3');
;
##############################################################################;
;
if __name__ == "__main__":;
....main()
EOF


# init and create the virt. env. in the current directory
# (by overwriting the WORKON_HOME variable)
function venv_init_here () {
    backup=$WORKON_HOME
    #
    export WORKON_HOME=
    venv_init
    #
    export WORKON_HOME=$backup
}


# create the virt. env. in the current directory
# (by overwriting the WORKON_HOME variable)
# prerequisite: the folder is initialized
function venv_make_here () {
    backup=$WORKON_HOME
    #
    export WORKON_HOME=
    venv_make
    #
    export WORKON_HOME=$backup
}


# first call this function to initialize the project folder
# venv_make requires an initialized project folder
function venv_init () {
    if [[ -f ./python_version.txt ]]; then
        echo "Warning! The file \"python_version.txt\" already exists!"
        echo "Tip: run venv_make as a next step."
    else
        echo -n "Do you want a Python 2 or a Python 3 project? (2, 3): "
        read py_ver
        if [[ "$py_ver" != "2" && "$py_ver" != "3" ]]; then
            echo "Invalid option."
            return 1
        fi
        #
        if [[ "$py_ver" == "2" ]]; then
            echo $PY2 | sed -e "s/; /\n/g" -e "s/\./ /g" > ./alap.py
        fi
        if [[ "$py_ver" == "3" ]]; then
            echo $PY3 | sed -e "s/; /\n/g" -e "s/\./ /g" > ./alap.py
        fi
        chmod u+x ./alap.py
        #
        echo "python${py_ver}" > ./python_version.txt
        echo "pip freeze --local" > ./update_requirements.sh
        chmod u+x ./update_requirements.sh
        echo $CALLER_SH | sed -e "s/; /\n/g" > ./caller.sh
        chmod u+x ./caller.sh
        touch requirements.txt
        echo "The project was initialized as a Python ${py_ver} project."
        echo "Calling venv_make for you:"
        venv_make
        echo
        echo "Your new virt. env. is ready and activated!"
    fi
}

# create a Python 2 or Python 3 virtual environment
# depending on how the folder was initialized
function venv_make () {
    if [ -n "$VIRTUAL_ENV" ]; then
        echo "Error! You are in an activated virt. environment!"
        return 1
    fi
    if [ -z "$WORKON_HOME" ]; then
        echo "The variable WORKON_HOME is undefined, thus creating the virt. env. in the current directory."
        base=.
        env="venv"
    else
        base=$WORKON_HOME
        pwd=`which pwd`
        here=`$pwd`
        env=`basename "$here"`
    fi
    dir_path="$base/$env"
    if [[ -d "$dir_path" ]]; then
        echo "Error! The directory $dir_path already exists!"
        return 1
    fi
    if [[ -f ./python_version.txt ]]; then
        read -r py_ver < ./python_version.txt
        virtualenv -p $py_ver "$dir_path"
        echo "cd \"$here\"" > "$dir_path"/cd_project_dir.sh
        echo "cd \"$dir_path\"" > cd_venv_dir.sh
        source "$dir_path"/bin/activate
        pip install pip -U
        if [ -s "requirements.txt" ]; then
            # requirements.txt exists and it's not empty
            echo
            install_requirements
        fi
    else
        echo "Error! The file \"python_version.txt\" doesn't exist!"
        echo "Tip: run venv_init first."
    fi
}

# User input: yes or no.
# If you simply press ENTER, it will be considered a "yes".
promptyn () {
    while true; do
        read -p "$1 " yn
        if [ "$yn" == "" ]; then
            return 0
        fi
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) return 1;;
        esac
    done
}

# Ask the user if (s)he wants to install the requirements.
function install_requirements () {
    if promptyn "Install packages from requirements.txt ([y] / n)?"; then
        pip install -r requirements.txt
    else
        echo "no"
    fi
}

# create a temporary project folder with an associated virtual environment in the folder /tmp
# It is not deleted automatically!
# However, /tmp is cleaned upon reboot, so that may be enough.
function venv_tmp () {
    echo -n "Create a temp virt. env. with Python 2 or Python 3 (2, 3): "
    read py_ver
    if [[ "$py_ver" != "2" && "$py_ver" != "3" ]]; then
        echo "Invalid option."
        return 1
    fi
    #
    base=`mktemp -d -t venv_XXXXX`
    cd $base
    env="venv"
    dir_path="$base/$env"
    virtualenv -p python$py_ver "$dir_path"
    "$dir_path"/bin/pip install pip -U
    source "$dir_path"/bin/activate
}

# Init. workspace settings for Visual Studio Code. This way, VS Code
# will use the interpreter of the virt. env.
function venv_init_vscode () {
    if [ ! -f "cd_venv_dir.sh" ]; then
        echo "The file cd_venv_dir is missing."
        return 1
    fi
    if [ ! -d ".vscode" ]; then
        mkdir .vscode
        echo "# .vscode dir. was created"
    fi
    python_path=`cat cd_venv_dir.sh | sed -e "s/^cd //" -e 's/"//g'`
    read -d '' settings <<EOL
// Place your settings in this file to overwrite default and user settings.;
{;
,,,,"pythonPath":,"${python_path}/bin/python";
}
EOL
    if [ ! -f ".vscode/settings.json" ]; then
        echo $settings | sed -e "s/; /\n/g" -e "s/,/ /g" > .vscode/settings.json
        echo "# .vscode/settings.json was initialized"
    else
        echo "edit .vscode/settings.json and add the following lines to it"
        echo
        echo $settings | sed -e "s/; /\n/g" -e "s/,/ /g"
    fi
}

# activate the virtual environment
# call this function in the project folder
# OR (new feature):
# if you are in a direct subfolder of the project folder,
# call it with an argument by specifying where the project folder is, ex.: on ..
function on () {
    proj_dir=$1    # passed as a parameter to the function
    if [ -z "$proj_dir" ]; then
        proj_dir=.
    fi
    if [[ "$proj_dir" == "..." ]]; then
        proj_dir=../..
    elif [[ "$proj_dir" == "...." ]]; then
        proj_dir=../../..
    elif [[ "$proj_dir" == "....." ]]; then
        proj_dir=../../../..
    fi
    proj_dir=`realpath "$proj_dir"`
#    echo "# proj_dir: ${proj_dir}"

    if [ -d "${proj_dir}/venv" ] || [ -z "$WORKON_HOME" ]; then
        base=$proj_dir
        env="venv"
    else
        base=$WORKON_HOME
        env=`basename "$proj_dir"`
    fi

    activate="${base}/${env}/bin/activate"
    echo "# calling ${activate}"

    source "${activate}"
}

# deactivate the virtual environment
alias off='deactivate'

# virtualenv auto activation idea borrowed from
# http://toranbillups.com/blog/archive/2012/04/22/Automatically-activate-your-virtualenv/

activate_virtualenv() {
  if [ -f cd_venv_dir.sh ]; then
    off &>/dev/null
    on
  fi
}

virtualenv_cd() {
  cd "$@" && activate_virtualenv
}

if [ "$ALLOW_VIRTUALENV_AUTO_ACTIVATE" -eq "1" ]; then
    alias cd="virtualenv_cd"
fi

# END: Jabba's Python virtualenv tools
