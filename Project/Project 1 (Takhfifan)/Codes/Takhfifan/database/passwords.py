from django.contrib.auth.hashers import check_password, make_password

def encode(password):
    return make_password(password)

def check(password, encoded):
    return check_password(password, encoded)