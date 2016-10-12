# DjangoDeployment
I've only tested this on Debian 8 server environment, but assuming your nginx is set up the same way with `/etc/nginx/sites-available` and `/etc/nginx/sites-enabled` you could modify this to work any any linux distro.

The main thing you will need to just change `sudo apt update` to `sudo pacman -Syyu` etc. 
Package names may be different in different distros too.

### Installation
```sh
$ git clone https://github.com/JesterJK/DjangoDeployment.git
```
or
```sh
$ curl -O https://github.com/JesterJK/DjangoDeployment/archive/master.zip
```

### Usage
```
  usage: $0 [-a app_name] [-s server_name] [-t type] [-r git_url] [-p python_ver] [-h]
  Welcome to the server setup tool!
    -h|--help Display this help menu
    -a|--app app_name Specify the app name, otherwise the tool will be interactive.
    -s|--server server_name Specify the sever name/host name that NGINX will use to server the apion. eg. google.com
    -t|--type [d/G]] d or g for daphne or gunicorn respectively.
    -r|--repository url] URL to the git repository that holds the project.
    -p|--python [2/3]] Python version 2 or 3. Only type 2 or 3.
```

### Example
```sh
init_server -a jjk -s jjk.io -t g -r https://git.repo -p 2
```

### Requirements
This sript will be looking for a couple files inside your project, so make sure you have them to work.
##### Gunicorn
###### gunicorn_start.sh
```sh
#!/bin/bash

NAME="[app_name]"                                   # Name of the application
DJANGODIR=/webapps/[app_name]                       # Django project directory
SOCKFILE=/webapps/[app_name]/run/gunicorn.sock      # we will communicate using this unix socket
VIRTUAL_ENV=/opt/[app_name]                         # Virtual Environment base directory
USER=webapps                                        # the user to run as
GROUP=webapps                                       # the group to run as
NUM_WORKERS=3                                       # how many worker processes should Gunicorn spawn
DJANGO_SETTINGS_MODULE=[django_project].settings    # which settings file should Django use
DJANGO_WSGI_MODULE=[django_project].wsgi            # WSGI module name

echo "Starting $NAME as `whoami`"

# Activate the virtual environment
cd $DJANGODIR
source ${VIRTUAL_ENV}/bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH

# Create the run directory if it doesn't exist
RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec ${VIRTUAL_ENV}/bin/gunicorn ${DJANGO_WSGI_MODULE}:application \
  --name $NAME \
  --workers $NUM_WORKERS \
  --user=$USER --group=$GROUP \
  --bind=unix:$SOCKFILE \
  --log-level=info \
  --log-file=-
```
##### Daphne
To run under daphne you need run daphne and your workers separately, thus you must also have a worker_start.sh script as well as the daphne_start.sh script.
###### daphne_start.sh
```sh
#!/bin/bash

NAME="[app_name]"                                       # Name of the application
DJANGODIR=/webapps/[app_name]                           # Django project directory
SOCKFILE=/webapps/[app_name]/run/daphne.sock            # we will communicate using this unix socket
VIRTUAL_ENV=/opt/[app_name]                             # Virtual Environment base directory
DJANGO_SETTINGS_MODULE=[django_project].settings        # which settings file should Django use
DJANGO_ASGI_MODULE=[django_project].asgi                # WSGI module name

echo "Starting $NAME as `whoami`"

# Activate the virtual environment
cd $DJANGODIR
source ${VIRTUAL_ENV}/bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH

# Create the run directory if it doesn't exist
RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec ${VIRTUAL_ENV}/bin/daphne -u ${SOCKFILE} ${DJANGO_ASGI_MODULE}:channel_layer
```
###### worker_start.sh
```sh
#!/bin/bash

NAME="[app_name]_worker"                                      # Name of the application
DJANGODIR=/webapps/[app_name]                                 # Django project directory
VIRTUAL_ENV=/opt/[app_name]                                   # Virtual Environment base directory
DJANGO_SETTINGS_MODULE=[django_project].settings  # which settings file should Django use

echo "Starting $NAME as `whoami`"

# Activate the virtual environment
cd $DJANGODIR
source ${VIRTUAL_ENV}/bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec ${VIRTUAL_ENV}/bin/python manage.py runworker
```

### Todos
 - Better automation for interaction free installation...
 - Improvements...

### License
GPL 3.0

