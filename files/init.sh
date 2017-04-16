#!/bin/bash

source /etc/apache2/envvars
exec apache2 -D FOREGROUND

# Create a Django superuser named `root` if it doesn't yet exist
echo "Checking and Creating Django superuser named 'root' if needed"
if [ "$DJANGO_PRODUCTION" != "true" ]; then
    # We're in the dev environment
    if [ "$ROOT_PASSWORD" != "" ]; then
        # Root password environment variable IS set; so, use it
        echo "from ConfigParser import SafeConfigParser; parser = SafeConfigParser(); parser.read('/code/config.ini'); from django.contrib.auth.models import User; print 'Root user already exists' if User.objects.filter(username='root') else User.objects.create_superuser('root', 'admin@example.com', parser.get('general', 'ROOT_PASSWORD'))" | python /django_apps/YOUR-APP-NAME/manage.py shell
    else
        # Root password environment variable IS set; so, use it
        echo "Please set an Environment variable to use in order to create the superuser root user!"
    fi
else
    # We're in production; use root password environment variable
    echo "import os; from django.contrib.auth.models import User; print 'Root user already exists' if User.objects.filter(username='root') else User.objects.create_superuser('root', 'admin@example.com', os.environ['ROOT_PASSWORD'])" | python /django_apps/YOUR-APP-NAME/manage.py shell
fi

# Does the static collection and make migrations

python3 /django_apps/YOUR-APP-NAME/manage.py collectstatic --noinput
python3 /django_apps/YOUR-APP-NAME/manage.py makemigrations
python3 /django_apps/YOUR-APP-NAME/manage.py migrate --noinput

