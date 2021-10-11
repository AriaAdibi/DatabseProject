import psycopg2
import random
import string
import datetime
from colorama import Fore, Back, init

init(autoreset=True)
print(Back.WHITE + Fore.BLUE  + 'Initializing connection to database...')
try:
    dbname = 'CouponUserDB'
    user = '\'CouponUser DBA staff\''
    host = 'localhost'
    password = 'mms373'
    connection = psycopg2.connect('dbname={} user={} host={} password={}'.format(dbname, user, host, password))
    cursor = connection.cursor()
    print(Back.BLACK + Fore.GREEN + 'Connection made.')
    print('')
    
    categories = ['RESTAURANT_COFFEESHOP', 'ART_THEATER', 'ENTERTAINMENT_SPORT', 'EDUCATIONAL', 'HEALTH_MED', 'COSMETIC', 'TRAVEL', 'GOODS']
    chars = string.ascii_uppercase + string.ascii_lowercase + string.digits
    
    for i in range(1, random.randint(40, 200)):
        w1 = ''.join(random.choice(chars) for _ in range(random.randint(4, 15)))
        w2 = ''.join(random.choice(chars) for _ in range(random.randint(4, 15)))
        w3 = ''.join(random.choice(chars) for _ in range(random.randint(4, 15)))
        w4 = ''.join(random.choice(chars) for _ in range(random.randint(4, 15)))
        w5 = ''.join(random.choice(chars) for _ in range(random.randint(4, 15)))
        w6 = ''.join(random.choice(chars) for _ in range(random.randint(4, 15)))
        n1 = random.randint(100, 500)
        n1 = random.randint(100, 500)
        n2 = random.randint(10000, 5000000)
        n3 = random.randint(1, 99)
        cursor.execute('INSERT INTO "Coupon"("category", "description", "lineaments", "companyName", "companyAddress", "conditions", "nameAndAShortDescription", "numOfCoupons", "numOfSoldCoupons", "expirationDate", "originalPrice", "percentageOff") VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);', [random.choice(categories), w1, w2, w3, w4, w5, w6, n1, 0, datetime.date(2016, 9, 14), n2, n3])
        print(Back.BLACK + Fore.YELLOW + 'Data number {} inserted.'.format(i))
    
    print(Back.BLACK + Fore.GREEN + 'Done.')
    connection.commit()
    connection.close()
    print(Back.WHITE + Fore.BLUE + 'Connection closed.')
except Exception as exc:
    cursor = None
    print(Baclk.BLACK + Fore.RED + exc)