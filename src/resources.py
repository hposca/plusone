from flask_restful import Resource, reqparse
from models import UserModel
from flask_jwt_extended import (create_access_token, create_refresh_token, jwt_required, jwt_refresh_token_required, get_jwt_identity)

parser = reqparse.RequestParser()
parser.add_argument('email', help = 'This field cannot be blank', required = True)
parser.add_argument('password', help = 'This field cannot be blank', required = True)

number_parser = reqparse.RequestParser()
number_parser.add_argument('current', help = 'This field cannot be blank', required = True)

class UserRegistration(Resource):
    def post(self):
        data = parser.parse_args()
        email = data['email']
        password = data['password']

        if UserModel.find_by_email(email):
            return {'message': 'User {} already exists'.format(email)}

        new_user = UserModel(
            email = email,
            password = UserModel.generate_hash(password)
        )
        try:
            new_user.save_to_db()
            access_token = create_access_token(identity = email)
            refresh_token = create_refresh_token(identity = email)
            return {
                'message': 'User {} was created.'.format(email),
                'access_token': access_token,
                'refresh_token': refresh_token
            }
        except:
            return {'message': 'Something went wrong.'}, 500


class UserLogin(Resource):
    def post(self):
        data = parser.parse_args()
        email = data['email']
        password = data['password']

        current_user = UserModel.find_by_email(email)
        if not current_user:
            return {'message': 'User {} doesn\'t exist'.format(email)}

        if UserModel.verify_hash(password, current_user.password):
            access_token = create_access_token(identity = email)
            refresh_token = create_refresh_token(identity = email)
            return {
                'message': 'Logged in as {}'.format(email),
                'access_token': access_token,
                'refresh_token': refresh_token
            }
        else:
            return {'message': 'Wrong credentials'}

def fetchUser():
    email = get_jwt_identity()
    return UserModel.find_by_email(email)

class NextNumber(Resource):
    @jwt_required
    def get(self):
        user = fetchUser()
        new_number = user.number + 1
        user.number = new_number

        try:
            user.save_to_db()
        except:
            return {'message': 'Something went wrong when we tried to save the next number.'}, 500

        return {
            'number': new_number
        }

class CurrentNumber(Resource):
    @jwt_required
    def get(self):
        user = fetchUser()

        return {
            'number': user.number
        }

    @jwt_required
    def put(self):
        user = fetchUser()
        data = number_parser.parse_args()
        new_number = data['current']

        if int(new_number) < 0:
            return {'message': 'Number, {}, should not be negative.'.format(new_number)}, 500

        user.number = new_number

        try:
            user.save_to_db()
        except:
            return {'message': 'Something went wrong when we tried to explicitly set the current number.'}, 500

        return {
            'message': 'New current number set successfully.',
            'number': new_number
        }

class TokenRefresh(Resource):
    @jwt_refresh_token_required
    def post(self):
        current_user = get_jwt_identity()
        access_token = create_access_token(identity = current_user)
        return {'access_token': access_token}
