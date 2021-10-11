from django import template

register = template.Library()

@register.filter(name='off_price')
def off_price(value, arg):
    value = int(value)
    arg = int(arg)
    return int(value * (100 - arg) / 100)

@register.filter(name='bought_percent')
def bought_percent(value, arg):
    value = int(value)
    arg = int(arg)
    return arg * 100 / value

@register.filter(name='translate_category')
def translate_category(value):
    if value == 'RESTAURANT_COFFEESHOP':
    	return 'رستوران و کافی‌شاپ'
    elif value == 'ART_THEATER':
    	return 'هنر و تئاتر'
    elif value == 'ENTERTAINMENT_SPORT':
    	return 'تفریحی و ورزشی'
    elif value == 'EDUCATIONAL':
    	return 'آموزشی'
    elif value == 'HEALTH_MED':
    	return 'سلامتی و پزشکی'
    elif value == 'COSMETIC':
    	return 'زیبایی و آرایشی'
    elif value == 'TRAVEL':
    	return 'مسافرتی'
    elif value == 'GOODS':
    	return 'کالا'