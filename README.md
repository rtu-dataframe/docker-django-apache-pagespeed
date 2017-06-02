# django-apache--mysql-pagespeed-docker

Clone the repo
Edit the docker-compose.yml and change: Virtualhost, Ports, Volumes. -> only if needed
Edit the requirements.txt file and write the whole list of your app requirements
run docker-compose up -d
Now you'll have a ready-to-deploy Docker container infrastructure with all you need: Mysql, Django, Apache, Mod-Pagespeed...
Deploy your app via sftp
Go into django-apache-pagespeed container and edit the file django_app.conf (under: /etc/apache2/sites-enabled/) with the specific path/name of your app
Reload the apache configuration via the command: service apache2 reload
Open the browser and enjoy your app!