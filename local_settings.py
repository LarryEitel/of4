# -*- coding: utf-8 -*-

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
        'PROJECT_FOLDER': 'of.xchg.com',
        'PROJECT_NAME' : 'of4',
        'GIT_REPO'     : 'git@github.com:LarryEitel/of4.git'
    }
}
