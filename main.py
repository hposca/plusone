#!/usr/bin/env python
# -*- coding: utf-8 -*-

from flask import Flask
from flask_restful import Api
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
import os

app = Flask(__name__)
api = Api(app)

database_uri = "mysql://{username}:{password}@{hostname}:{port}/{database}".format(
    username=os.environ['DATABASE_USERNAME'],
    password=os.environ['DATABASE_PASSWORD'],
    hostname=os.environ['DATABASE_ADDRESS'],
    port=os.environ['DATABASE_PORT'],
    database=os.environ['DATABASE_NAME'])

app.config['SQLALCHEMY_DATABASE_URI'] = database_uri
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'some-secret-string')

jwt = JWTManager(app)

db = SQLAlchemy(app)

@app.before_first_request
def create_tables():
    db.create_all()

import views, resources

api.add_resource(resources.UserRegistration, '/registration')
api.add_resource(resources.UserLogin, '/login')
api.add_resource(resources.NextNumber, '/next')
api.add_resource(resources.CurrentNumber, '/current')
api.add_resource(resources.TokenRefresh, '/token/refresh')
