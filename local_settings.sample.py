# -*- coding: utf-8 -*-

# fabric settings
FABRIC = {
    'live': {
        'HOSTS'        : ['domain/ip'],
        'WEB_USER'     : 'webuser',
        'ADMIN_USER'   : 'adminuser',
        'KEY_FILENAME' : ["C:/Users/user/.ssh/id_rsa.pub"],
        'PROJECTS_HOME': '/home/www-data/www/',
        'PROJECT_FOLDER': 'of.xchg.com',
        'PROJECT_NAME' : 'of4',
        'GIT_REPO'     : 'git@github.com:LarryEitel/of4.git'
    }
}
