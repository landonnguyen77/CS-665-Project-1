import os
from flask import Flask
from . import db
from . import auth

def create_app(test_confige=None):
    app = Flask(__name__, instance_relative_config=True)
    app.config.from_mapping(
        SECRET_KEY='dev',
        DATABASE=os.path.join(app.instance_path, 'flaskr.sqlite'),
    )

    if test_confige is None:
        app.config.from_pyfile('config.py', silent=True)
    else:
        app.config.from_mapping(test_confige)

    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    @app.route('/')
    def index():
        return 'Welcome to Flaskr!'

    @app.route('/hello')
    def hello():
        return 'Hello, World!'

    db.init_app(app)
    app.register_blueprint(auth.bp)

    return app
    