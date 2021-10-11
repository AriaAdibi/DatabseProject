from django.shortcuts import render, redirect
from django.http import HttpResponseBadRequest, HttpResponseRedirect

from .utils import *
from database.database import *

# Create your views here.
def show_category(request, category, page):
    page = int(page)
    
    luser = request.session.get('luser', None)
    
    categories = get_categories().all()
    quantity = 20
    s = (page - 1) * quantity + 1
    
    if category == 'all':
        (discounts, pages) = get_all_discounts(s, quantity)
        discounts = discounts.all()
    elif category == 'new':
        (discounts, pages) = get_new_discounts(s, quantity)
        discounts = discounts.all()
    else:
        (discounts, pages) = get_discounts(category, s, quantity)
        discounts = discounts.all()
    
    if page > 1 and page > pages:
        return HttpResponseBadRequest('صفحه‌ی درخواست شده وجود ندارد.')
    
    empty = len(discounts) == 0
    cartNum = int(request.COOKIES.get('cart-num', 0))
    
    return render(request, 'category.html', {
        'categories': categories,
        'discounts': discounts,
        'currentpage': page,
        'pagerange': range(1, pages + 1),
        'currentcategory': category,
        'empty': empty,
        'luser': luser,
        'cartNum': cartNum
    })

def show_discount(request, discount_id):
    luser = request.session.get('luser', None)
    
    categories = get_categories().all()
    
    discount = get_one_discount(discount_id).one()
    
    cartNum = int(request.COOKIES.get('cart-num', 0))
    return render(request, 'discount.html', {
        'categories': categories,
        'discount': discount,
        'luser': luser,
        'cartNum': cartNum
    })

def search(request, page):
    page = int(page)
    keyword = request.GET.get('q', None)
    
    luser = request.session.get('luser', None)
    
    categories = get_categories().all()
    
    quantity = 20
    s = (page - 1) * quantity + 1
    (discounts, pages) = search_discounts(keyword, s, quantity)
    discounts = discounts.all()
    
    if page > 1 and page > pages:
        return HttpResponseBadRequest('صفحه‌ی درخواست شده وجود ندارد.')
    
    empty = len(discounts) == 0
    cartNum = int(request.COOKIES.get('cart-num', 0))
    
    return render(request, 'category.html', {
        'categories': categories,
        'discounts': discounts,
        'currentpage': page,
        'pagerange': range(1, pages + 1),
        'query_string': '?{}'.format(request.META.get('QUERY_STRING')),
        'empty': empty,
        'luser': luser,
        'cartNum': cartNum
    })

def login(request):
    if request.method == 'POST':
        luser, errors = process_login(request)
        if errors is not None:
            return HttpResponseBadRequest('خطاهای زیر در ورود رخ داده است:<br />{}'.format(errors))
        
        request.session['luser'] = luser
        nextPage = request.GET.get('next', None)
        if nextPage is not None:
            return HttpResponseRedirect(nextPage)
        return HttpResponseRedirect('/')
    else:
        categories = get_categories().all()
        nextPage = request.GET.get('next', None)
        return render(request, 'login.html', {
            'categories': categories,
            'next': nextPage
        })

@check_login
def logout(request):
    del request.session['luser']
    
    response = HttpResponseRedirect('/')
    cartNum = int(request.COOKIES.get('cart-num', 0))
    response.delete_cookie('cart-num')
    for i in range(1, cartNum + 1):
        response.delete_cookie('cart-obj{}'.format(i))
        response.delete_cookie('cart-cnt{}'.format(i))
    
    return response

def signup(request):
    if request.method == 'POST':
        luser, errors = process_signup(request)
        if errors is not None:
            return HttpResponseBadRequest('خطاهای زیر در ثبت نام رخ داده است:<br />{}'.format(errors))
        
        request.session['luser'] = luser
        nextPage = request.GET.get('next', None)
        if nextPage is not None:
            return HttpResponseRedirect(nextPage)
        return HttpResponseRedirect('/')
    else:
        categories = get_categories().all()
        nextPage = request.GET.get('next', None)
        return render(request, 'signup.html', {
            'categories': categories,
            'next': nextPage
        })

@check_login
def remove(request):
    if request.method == 'POST':
        num = get_field(request, 'obj')
        if num is not None:
            response = redirect('show_cart')
            num = int(num)
            cartNum = int(request.COOKIES.get('cart-num', 0))
            if num == cartNum:
                response.delete_cookie('cart-obj{}'.format(num))
                response.delete_cookie('cart-cnt{}'.format(num))
            response.set_cookie('cart-num', cartNum - 1)
            for i in range(num, cartNum):
                response.set_cookie('cart-obj{}'.format(i), request.COOKIES.get('cart-obj{}'.format(i + 1)))
                response.set_cookie('cart-cnt{}'.format(i), request.COOKIES.get('cart-cnt{}'.format(i + 1)))
    
        return response

@check_login
def finalize(request):
    if request.method == 'POST':
        luser = request.session['luser']
        response = redirect('show_cart')
        
        cartNum = int(request.COOKIES.get('cart-num', 0))
        for i in range(1, cartNum + 1):
            ID = get_one_discount(int(request.COOKIES.get('cart-obj{}'.format(i)))).one().id
            count = int(request.COOKIES.get('cart-cnt{}'.format(i)))
            submit_order(luser, ID, count)
            
            response.delete_cookie('cart-obj{}'.format(i))
            response.delete_cookie('cart-cnt{}'.format(i))
        
        response.set_cookie('cart-num', 0)
        
        return response

@check_login
def show_cart(request):
    categories = get_categories().all()
    luser = request.session['luser']
    cartNum = int(request.COOKIES.get('cart-num', 0))
    
    cart = []
    for i in range(1, cartNum + 1):
        title = get_one_discount(int(request.COOKIES.get('cart-obj{}'.format(i)))).one().title
        count = int(request.COOKIES.get('cart-cnt{}'.format(i)))
        cart.append((i, title, count))
    
    empty = cartNum == 0
    
    return render(request, 'cart.html', {
        'categories': categories,
        'cart': cart,
        'empty': empty,
        'luser': luser,
        'cartNum': cartNum
    })

@check_login
def add_to_cart(request, couponID):
    luser = request.session['luser']
    discount = get_one_discount(couponID).one()
    
    if request.method == 'POST':
        num, error = process_add_to_card(request)
        if error is not None:
            return HttpResponseBadRequest('خطای زیر در افزودن به سبد خرید رخ داده است:<br />{}'.format(error))
        
        nextPage = request.GET.get('next', None)
        response = redirect('discount', discount_id=couponID)
            
        cartNum = int(request.COOKIES.get('cart-num', 0))
        response.set_cookie('cart-num', cartNum + 1)
        response.set_cookie('cart-obj{}'.format(cartNum + 1), discount.id)
        response.set_cookie('cart-cnt{}'.format(cartNum + 1), num)
        
        return response
    else:
        categories = get_categories().all()
        cartNum = int(request.COOKIES.get('cart-num', 0))
        
        return render(request, 'add_to_cart.html', {
            'categories': categories,
            'discount': discount,
            'luser': luser,
            'cartNum': cartNum
        })

@check_login
def edit(request):
    luser = request.session['luser']
    if request.method == 'POST':
        error = process_and_update_user(request, luser)
        if error:
            return HttpResponseBadRequest('خطاهای زیر در تغییر مشخصات فردی رخ دادند:<br />{}'.format(error))
    
    categories = get_categories().all()
    the_luser = get_user(luser).one()
    cartNum = int(request.COOKIES.get('cart-num', 0))
    
    return render(request, 'edit.html', {
        'categories': categories,
        'the_luser': the_luser,
        'luser': luser,
        'cartNum': cartNum
    })

@check_login
def history(request, page):
    page = int(page)
    luser = request.session['luser']
    
    categories = get_categories().all()
    
    quantity = 20
    s = (page - 1) * quantity + 1
    (orders, pages) = get_orders(luser, s, quantity)
    orders = orders.all()
    
    if page > 1 and page > pages:
        return HttpResponseBadRequest('صفحه‌ی درخواست شده وجود ندارد.')
    
    empty = len(orders) == 0
    cartNum = int(request.COOKIES.get('cart-num', 0))
    
    return render(request, 'history.html', {
        'categories': categories,
        'orders': orders,
        'currentpage': page,
        'pagerange': range(1, pages + 1),
        'empty': empty,
        'luser': luser,
        'cartNum': cartNum
    })