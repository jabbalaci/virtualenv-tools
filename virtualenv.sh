# START: Jabba's Python virtualenv tools
# heavily inspired by https://github.com/jaapz/virtualenv-tools

# virtualenvs will be created in this directory
# if this variable is not defined, then the virtualenv will be created in the project folder
export WORKON_HOME=$HOME/.virtualenvs

# first call this function to initialize the project folder
# venv_make requires an initialized project folder
function venv_init () {
    if [[ -f ./python_version ]]; then
        echo "Warning! The file \"python_version\" already exists!"
    else
        echo "python3" > ./python_version
        echo "The project was initialized as a Python 3 project."
        echo "If you want a Python 2 project, then edit the file \"python_version\"."
    fi
}

# create a Python 2 or Python 3 virtual environment
# depending on how the folder was initialized
function venv_make () {
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
    if [[ -f ./python_version ]]; then
        read -r py_ver < ./python_version
        virtualenv -p $py_ver "$dir_path"
        echo "cd \"$here\"" > "$dir_path"/cd_project_dir.sh
        echo "cd \"$dir_path\"" > cd_venv_dir.sh
        source "$dir_path"/bin/activate
    else
        echo "Error! The file \"python_version\" doesn't exist!"
        echo "Tip: run venv_init first."
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
    source "$dir_path"/bin/activate
}

# activate the virtual environment
# call this function in the project folder
function on () {
    if [ -z "$WORKON_HOME" ]; then
        base=.
        env="venv"
    else
        base=$WORKON_HOME
        pwd=`which pwd`
        here=`$pwd`
        env=`basename "$here"`
    fi
    dir_path="$base/$env"

    source "$dir_path"/bin/activate
}

# deactivate the virtual environment
alias off='deactivate'

# END: Jabba's Python virtualenv tools
