
from flask import Blueprint

charts_blueprint = Blueprint('charts', __name__, template_folder='templates')

from . import routes
