from flask_restful import Resource, reqparse
from models import UserModel

parser = reqparse.RequestParser()
parser.add_argument('email', help = 'This field cannot be blank', required = True)
parser.add_argument('password', help = 'This field cannot be blank', required = True)

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
            return {
                'message': 'User {} was created.'.format(email)
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
            return {'message': 'Logged in as {}'.format(email)}
        else:
            return {'message': 'Wrong credentials'}
