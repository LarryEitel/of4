import time
import os, sys
from fabric.api import local, cd, run, env, sudo, require
from local_settings import *

fab               = FABRIC['live']

env.hosts         = fab['HOSTS']
env.projects_home = '%s' % fab['PROJECTS_HOME']
env.project_home  = '%s%s' % (fab['PROJECTS_HOME'], fab['PROJECT_NAME'])

if 'ADMIN_PW' in fab: env.password = fab['ADMIN_PW']
env.key_filename = ["C:/Users/Larry/.ssh/id_rsa.pub"]

# unsuccessful attempt to switch between servers
# only live for now
def deploy(msg="No Msg", dest="live"):
    global env

    try:
        commit(msg)
    except:
        pass

    if dest == "local":
        fab            = FABRIC['local']
        update_local(fab)
    else:
        fab            = FABRIC['live']
        update_remote(fab)


    env.hosts      = fab['HOSTS']
    env.user       = fab['ADMIN_USER']
    env.admin_     = fab['ADMIN_USER']
    env.admin_user = fab['ADMIN_USER']
    # env.password   = fab['ADMIN_PW']
    env.key_filename = ["C:/Users/Larry/.ssh/id_rsa.pub"]


    #run_tests()
    #reload_uwsgi()



def commit(msg):
    with cd(os.path.abspath(os.path.dirname(__file__))):
        local('git add .')
        local('git commit -am"%s"' % msg)
        local('git push origin master') # push local to repository

def update_local(fab):

    env.user       = fab['WEB_USER']
    with cd(env.project_home):
        run('git pull origin master') # pull from repository to remote

def update_remote(fab):
    env.user       = fab['WEB_USER']
    with cd(env.project_home):
        run('git pull origin master') # pull from repository to remote
        # run("kill -9 `ps -ef | grep 'exi\..*gunicorn' | grep -v grep | awk '{print $2}'`") # pull from repository to remote
        # restart_gunicorn()                    


def reload_nginx_conf():
    sudo('/etc/init.d/nginx check')
    sudo('/etc/init.d/nginx reload')

def restart():
    sudo('/etc/init.d/nginx restart')


def pushpull():
    local('git push') # runs the command on the local environment
    run('cd /path/to/project/; git pull') # runs the command on the remote environment
