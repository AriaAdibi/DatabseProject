import string
import random

def code_gen():
    chars=string.ascii_uppercase + string.ascii_lowercase + string.digits
    size = 12
    return ''.join(random.choice(chars) for _ in range(size))