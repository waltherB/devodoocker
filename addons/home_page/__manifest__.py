# -*- coding: utf-8 -*-
# Part of Odoo. See LICENSE file for full copyright and licensing details.


{
    'name': 'Home Page',
    'version': '1.0',
    'category': 'Apps',
    'description': """

        This module provides the home page for Odoo, which includes the dashboard and various widgets.
        """,
    'data': [
        'security/ir.model.access.csv',
        'views/home_page_views.xml',

    ],
    'demo': [

    ],
    'assets': {
        'web.assets_tests': [

        ],
    },
    'installable': True,
    'auto_install': False,
    'license': 'LGPL-3',
}
