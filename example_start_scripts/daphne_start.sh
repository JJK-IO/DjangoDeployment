#!/bin/bash

NAME="Test Project"                                   # Name of the application
DJANGODIR=/webapps/[app_name]                         # Django project directory
SOCKFILE=/webapps/[app_name]/run/daphne.sock          # we will communicate using this unix socket
VIRTUAL_ENV=/opt/[app_name]                           # Virtual Environment base directory
DJANGO_SETTINGS_MODULE=[project_name].settings        # which settings file should Django use
DJANGO_ASGI_MODULE=[project_name].asgi                # ASGI/WSGI module name

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
