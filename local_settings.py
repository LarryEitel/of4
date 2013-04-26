# -*- coding: utf-8 -*-

TESTING          = False
DEBUG            = False
CSRF_ENABLED     = True
    
MONGO_HOST              = 'localhost'
MONGO_PORT              = 27017
MONGO_DBNAME            = 'exi'
MONGO_USERNAME          = None
MONGO_PASSWORD          = None    

# fabric settings
FABRIC = {
    'local': {
        'HOSTS'       : ['of.xchg.com:53'],
        'WEB_USER'    : 'larry',
        'ADMIN_USER'  : 'larry',
        'ADMIN_PW'    : 'Zaq12wsX',
        'PROJECT_ROOT': '/srv/exi/',
        'PYTHONPATH'  : '/srv/venvs/exi/bin/:/srv/venvs/exi/Lib/site-packages/'
    },
    'live': {
        'HOSTS'        : ['xchg.com:53'],
        'WEB_USER'     : 'larry',
        'ADMIN_USER'   : 'larry',
        'KEY_FILENAME' : ["C:/Users/Larry/.ssh/id_rsa.pub"],
        'PROJECTS_HOME': '/home/www-data/www/',
        'PROJECT_NAME' : 'of.xchg.com',
        'GIT_REPO'     : 'git@github.com:LarryEitel/of4.git'
    }
}
