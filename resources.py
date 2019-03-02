from flask_restful import Resource, reqparse

parser = reqparse.RequestParser()
parser.add_argument('email', help = 'This field cannot be blank', required = True)
parser.add_argument('password', help = 'This field cannot be blank', required = True)

class UserRegistration(Resource):
    def post(self):
        data = parser.parse_args()
        return data

class UserLogin(Resource):
    def post(self):
        data = parser.parse_args()
        return data
