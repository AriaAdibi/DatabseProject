import psycopg2
from colorama import Fore, Back, init
from .exceptions import NoConnection
from .query import QueryResult, QueryResults
from .passwords import encode, check
from .order_codes import code_gen

# temps
import random
from datetime import datetime


init(autoreset=True)
print(Back.WHITE + Fore.BLUE  + 'Initializing...')
try:
    dbname = 'CouponUserDB'
    user = '\'CouponUser DBA staff\''
    host = 'localhost'
    password = 'mms373'
    connection = psycopg2.connect('dbname={} user={} host={} password={}'.format(dbname, user, host, password))
    cursor = connection.cursor()
    print(Back.BLACK + Fore.GREEN + 'Connection made.')
except Exception as exc:
    cursor = None
    print(Baclk.BLACK + Fore.RED + exc)

def check_connection(func):
    def check(*args, **kwargs):
        if cursor is None:
            raise NoConnection()
        else:
            return func(*args, **kwargs)
    
    return check

# database functions here
# all functions should be decorated with @check_connection

@check_connection
def get_categories():
    ret = QueryResults()
    cursor.execute('SELECT enumlabel FROM pg_enum;')
    results = cursor.fetchall()
    for category in results:
        ret.add(QueryResult(**{'category': category[0]}))
    return ret

@check_connection
def get_all_discounts(s, quantity):
    ret = QueryResults()
    cursor.execute('SELECT CEIL(COUNT(id)::float / %s) FROM "Coupon";', [quantity])
    pages = int(cursor.fetchone()[0])
    cursor.execute('SELECT id, "nameAndAShortDescription", "numOfCoupons", "numOfSoldCoupons", "originalPrice", "percentageOff" FROM "Coupon" LIMIT %s OFFSET %s;', [quantity, s - 1])
    results = cursor.fetchall()
    for discount in results:
        ret.add(QueryResult(**{'id': discount[0], 'title': discount[1], 'total': discount[2], 'count': discount[3], 'price': discount[4][1:-3].replace(',', ''), 'discount':discount[5]}))
    
    return (ret, pages)

@check_connection
def get_new_discounts(s, quantity):
    ret = QueryResults()
    cursor.execute('SELECT CEIL(COUNT("couponId")::float / %s) FROM "NewCoupons";', [quantity])
    pages = int(cursor.fetchone()[0])
    cursor.execute('SELECT id, "nameAndAShortDescription", "numOfCoupons", "numOfSoldCoupons", "originalPrice", "percentageOff" FROM "Coupon" NATURAL JOIN (SELECT "couponId" AS id FROM "NewCoupons") AS news LIMIT %s OFFSET %s;', [quantity, s - 1])
    results = cursor.fetchall()
    for discount in results:
        ret.add(QueryResult(**{'id': discount[0], 'title': discount[1], 'total': discount[2], 'count': discount[3], 'price': discount[4][1:-3].replace(',', ''), 'discount':discount[5]}))
    
    return (ret, pages)

@check_connection
def get_discounts(category, s, quantity):
    ret = QueryResults()
    cursor.execute('SELECT CEIL(COUNT(id)::float / %s) FROM "Coupon" WHERE category = %s;', [quantity, category])
    pages = int(cursor.fetchone()[0])
    cursor.execute('SELECT id, "nameAndAShortDescription", "numOfCoupons", "numOfSoldCoupons", "originalPrice", "percentageOff" FROM "Coupon" WHERE category = %s LIMIT %s OFFSET %s;', [category, quantity, s - 1])
    results = cursor.fetchall()
    for discount in results:
        ret.add(QueryResult(**{'id': discount[0], 'title': discount[1], 'total': discount[2], 'count': discount[3], 'price': discount[4][1:-3].replace(',', ''), 'discount':discount[5]}))
    
    return (ret, pages)

@check_connection
def search_discounts(keyword, s, quantity):
    ret = QueryResults()
    cursor.execute('SELECT CEIL(COUNT(id)::float / %s) FROM "Coupon" WHERE "nameAndAShortDescription" ~~ (\'%%\' || %s || \'%%\') OR "companyName" ~~ (\'%%\' || %s || \'%%\') OR description ~~ (\'%%\' || %s || \'%%\') OR "category"::text ~~ (\'%%\' || %s || \'%%\');', [quantity] + [keyword] * 4)
    pages = int(cursor.fetchone()[0])
    cursor.execute('SELECT id, "nameAndAShortDescription", "numOfCoupons", "numOfSoldCoupons", "originalPrice", "percentageOff" FROM "Coupon" WHERE "nameAndAShortDescription" ~~ (\'%%\' || %s || \'%%\') OR "companyName" ~~ (\'%%\' || %s || \'%%\') OR description ~~ (\'%%\' || %s || \'%%\') OR "category"::text ~~ (\'%%\' || %s || \'%%\') LIMIT %s OFFSET %s;', [keyword] * 4 + [quantity, s - 1])
    results = cursor.fetchall()
    for discount in results:
        ret.add(QueryResult(**{'id': discount[0], 'title': discount[1], 'total': discount[2], 'count': discount[3], 'price': discount[4][1:-3].replace(',', ''), 'discount':discount[5]}))
    
    return (ret, pages)

@check_connection
def get_one_discount(ID):
    cursor.execute('SELECT * FROM "Coupon" WHERE id = %s;', [ID])
    result = cursor.fetchone()
    discount = list(result)
    
    names = ['id', 'category', 'description', 'lineaments', 'companyName', 'companyAddress', 'conditions', 'title', 'total', 'count', 'expire', 'price', 'discount', 'phones']
    discount[-2] = discount[-2][1:-3].replace(',', '')
    
    cursor.execute('SELECT "companyPhoneNumber" FROM "CouponCompanyPhoneNumber" WHERE "couponId" = %s;', [ID])
    results = cursor.fetchall()
    phones = []
    for phone in results:
        phones.append(phone[0])
    discount.append(phones)
    return QueryResults(QueryResult(**dict(zip(names, discount))))

@check_connection
def confirm_user(email, password):
    cursor.execute('SELECT id, password FROM "User" WHERE email = %s;', [email])
    result = cursor.fetchone()
    
    if result is None:
        return None
    elif check(password, result[1]):
        return result[0]
    else:
        return None
    

@check_connection
def check_existance(email):
    cursor.execute('SELECT 1 FROM "User" WHERE email = %s;', [email])
    result = cursor.fetchone()
    return result is not None

@check_connection
def add_user(**data):
    data['password'] = encode(data['password'])
    if len(data) == 3:
        cursor.execute('INSERT INTO "User"(name, email, password) VALUES(%s, %s, %s) RETURNING id;', [data['name'], data['email'], data['password']])
    else:
        cursor.execute('INSERT INTO "User"(name, email, "cellPhoneNumber", password) VALUES(%s, %s, %s, %s) RETURNING id;', [data['name'], data['email'], data['cellPhoneNumber'], data['password']])
    
    result = cursor.fetchone()
    connection.commit()
    return result[0]

@check_connection
def get_user(ID):
    cursor.execute('SELECT name, email, "cellPhoneNumber" FROM "User" WHERE id = %s;', [ID])
    
    result = cursor.fetchone()
    return QueryResults(QueryResult(**{'name': result[0], 'cell': result[2], 'email': result[1]}))

@check_connection
def update_user(ID, **data):
    print(ID)
    cursor.execute('UPDATE "User" SET "name" = %s, "cellPhoneNumber" = %s WHERE id = %s;', [data['name'], data['cell'], ID])
    
    connection.commit()

@check_connection
def change_password(ID, password):
    password = encode(password)
    cursor.execute('UPDATE "User" SET "password" = %s WHERE id = %s;', [password, ID])
    connection.commit()

@check_connection
def submit_order(userID, couponID, count):
    cursor.execute('SELECT 1 FROM "Order" WHERE "userId" = %s AND "couponId" = %s;', [userID, couponID])
    check = cursor.fetchone()
    if check is None:
        success = False
        while not success:
            try:
                order_code = code_gen()
                cursor.execute('INSERT INTO "Order"("userId", "couponId", "cardinality", "code") VALUES(%s, %s, %s, %s);', [userID, couponID, count, order_code])
                success = True
            except:
                connection.rollback()
                success = False
        connection.commit()
        

@check_connection
def get_orders(ID, s, quantity):
    ret = QueryResults()
    cursor.execute('SELECT CEIL(COUNT(code)::float / %s) FROM "Order" WHERE "userId" = %s;', [quantity, ID])
    pages = int(cursor.fetchone()[0])
    cursor.execute('SELECT "purchaseTime", "cardinality", "code", "nameAndAShortDescription" FROM "Order" NATURAL JOIN (SELECT id AS "couponId", "nameAndAShortDescription" FROM "Coupon") AS coupons WHERE "userId" = %s LIMIT %s OFFSET %s;', [ID, quantity, s - 1])
    results = cursor.fetchall()
    for order in results:
        ret.add(QueryResult(**{'date': order[0], 'count': order[1], 'code': order[2], 'title': order[3]}))
    
    return (ret, pages)