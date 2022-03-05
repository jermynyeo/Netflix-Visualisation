from flask import Flask, render_template


######################################
#### Application Factory Function ####
######################################

def create_app():
    # Create the Flask application
    app = Flask(__name__)

    register_blueprints(app)
    return app


########################
### Helper Functions ###
########################

def register_blueprints(app):
    # Import the blueprints
    from project.charts import charts_blueprint

    # Since the application instance is now created, register each Blueprint
    # with the Flask application instance (app)
    app.register_blueprint(charts_blueprint)
