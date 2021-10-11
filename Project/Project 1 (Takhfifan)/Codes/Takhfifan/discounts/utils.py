from django.http import HttpResponseBadRequest
from database.database import add_user, check_existance, confirm_user, update_user, change_password
import re

def check_login(func):
    def check(*args, **kwargs):
        request = args[0]
        if 'luser' in request.session:
            return func(*args, **kwargs)
        else:
            return HttpResponseBadRequest('برای دسترسی به این صفحه باید وارد شوید.')
    
    return check

def process_login(request):
    has_error = False
    errors = ''
    
    email = get_field(request, 'email')
    if email is None:
        has_error = True
        errors = errors + '<br />آدرس ایمیل وارد نشده است.'
    else:
        pattern = re.compile('.+[@].+[.].+')
        if pattern.match(email) is None:
            has_error = True
            errors = errors + '<br />ایمیل وارد شده معتبر نیست.'
    
    password = get_field(request, 'pass')
    if password is None:
        has_error = True
        errors = errors + '<br />رمز عبور وارد نشده است.'
    
    if not has_error:
        luser = confirm_user(email, password)
        if luser is not None:
            return (luser, None)
        else:
            has_error = True
            errors = errors + '<br />اطلاعات وارد شده معتبر نیست.'
    errors = errors[6:]
    return (None, errors)

def process_signup(request):
    has_error = False
    errors = ''
    
    first = get_field(request, 'firstname')
    if first is None:
        has_error = True
        errors = errors + '<br />نام وارد نشده است.'
    
    last = get_field(request, 'lastname')
    if last is None:
        has_error = True
        errors = errors + '<br />نام خانوادگی وارد نشده است.'
    
    phone = get_field(request, 'phone')
    if phone is not None:
        if len(phone) != 11:
            has_error = True
            errors = errors + '<br />شماره‌ی تلفن همراه باید یازده رقمی باشد.'
        
        pattern = re.compile('[\d+]')
        if pattern.match(phone) is None:
            has_error = True
            errors = errors + '<br />شماره‌ی تلفن همراه باید فقط از ارقام تشکیل شده باشد.'
    
    email = get_field(request, 'email')
    if email is None:
        has_error = True
        errors = errors + '<br />آدرس ایمیل وارد نشده است.'
    else:
        pattern = re.compile('.+[@].+[.].+')
        if pattern.match(email) is None:
            has_error = True
            errors = errors + '<br />ایمیل وارد شده معتبر نیست.'
        elif check_existance(email):
            has_error = True
            errors = errors + '<br />ایمیل وارد شده تکراری است'
    
    password = get_field(request, 'pass')
    if password is None:
        has_error = True
        errors = errors + '<br />رمز عبور وارد نشده است.'
    elif len(password) < 6:
        has_error = True
        errors = errors + '<br />رمز عبور باید شامل حداقل شش کاراکتر باشد.'
    
    if not has_error:
        name = first + ' ' + last
        if phone is None:
            luser = add_user(name=name, email=email, password=password)
        else:
            luser = add_user(name=name, email=email, cellPhoneNumber=phone, password=password)
        return (luser, None)
    else:
        errors = errors[6:]
        return (None, errors)


def process_add_to_card(request):
    has_error = False
    error = ''
    
    num = get_field(request, 'num')
    if num is None:
        has_error = True
        error = 'تعداد خرید تخفیفان باید تعیین شود.'
    else:
        num = int(num)
        if num <= 0 or num > 10:
            has_error = True
            error = 'تعداد تخفیفان خریداری شده باید حداقل یکی و حداکثر ده عدد باشد.'
    
    if has_error:
        return (None, error)
    else:
        return (num, None)

def process_and_update_user(request, userID):
    has_error = False
    errors = ''
    
    act = get_field(request, 'act')
    if act is None or (act != 'update' and act != 'pass'):
        has_error = True
        errors = errors + '<br />درخواست ارسال شده معتبر نیست.'
    
    if act == 'update':
        name = get_field(request, 'name')
        if name is None:
            has_error = True
            errors = errors + '<br />نام وارد نشده است.'
        
        phone = get_field(request, 'phone')
        if phone is not None:
            if len(phone) != 11:
                has_error = True
                errors = errors + '<br />شماره‌ی تلفن همراه باید یازده رقمی باشد.'
            
            pattern = re.compile('[\d+]')
            if pattern.match(phone) is None:
                has_error = True
                errors = errors + '<br />شماره‌ی تلفن همراه باید فقط از ارقام تشکیل شده باشد.'
        
        if has_error:
            errors = errors[6:]
            return errors
        else:
            update_user(userID, **{'name': name, 'cell': phone})
            return None
    else:
        password = get_field(request, 'pass')
        if password is None:
            has_error = True
            errors = errors + '<br />رمز عبور وارد نشده است.'
        elif len(password) < 6:
            has_error = True
            errors = errors + '<br />رمز عبور باید شامل حداقل شش کاراکتر باشد.'
        
        if has_error:
            errors = errors[6:]
            return errors
        else:
            change_password(userID, password)
            return None

def get_field(request, field):
    ret = request.POST.get(field, None)
    if ret == '':
        ret = None
    return ret