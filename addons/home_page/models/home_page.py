from odoo import api, fields, models, tools, Command

class HomePage(models.Model):
    _name = 'home.page'
    _description = 'Home Page'
    _order = 'sequence, id'
    _rec_name = 'name'
    _check_company_auto = True
    _sql_constraints = [
        ('name_uniq', 'unique(name)', 'The name of the home page must be unique!'),
    ]
    name = fields.Char(string='Name', required=True, translate=True)
    sequence = fields.Integer(string='Sequence', default=10, help='Used to order the home pages.')


