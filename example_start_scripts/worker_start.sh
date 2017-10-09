#!/bin/bash

NAME="Test Worker"                               # Name of the application
DJANGODIR=/webapps/[app_name]                    # Django project directory
VIRTUAL_ENV=/opt/[app_name]                      # Virtual Environment base directory
DJANGO_SETTINGS_MODULE=[project_name].settings     # which settings file should Django use

echo "Starting $NAME as `whoami`"

# Activate the virtual environment
cd $DJANGODIR
source ${VIRTUAL_ENV}/bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec ${VIRTUAL_ENV}/bin/python manage.py runworker
