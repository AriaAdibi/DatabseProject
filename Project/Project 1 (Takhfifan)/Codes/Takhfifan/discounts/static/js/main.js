$(document).ready(function() {
    $('.ui.dropdown:not(#profile)').dropdown({
        on: 'hover',
        duration: 300,
        delay: {
            hide: 50,
            show: 0,
            search: 50,
            touch: 50
        },
        action: function(text) {
            if(text == 'تازه‌ها')
                id = '#new';
            else if (text == 'تمامی دسته‌ها')
                id = '#all';
            else if (text == 'رستوران و کافی‌شاپ')
            	id = '#RESTAURANT_COFFEESHOP';
            else if (text == 'هنر و تئاتر')
            	id = '#ART_THEATER';
            else if (text == 'تفریحی و ورزشی')
            	id = '#ENTERTAINMENT_SPORT';
            else if (text == 'آموزشی')
            	id = '#EDUCATIONAL';
            else if (text == 'سلامتی و پزشکی')
            	id = '#HEALTH_MED';
            else if (text == 'زیبایی و آرایشی')
            	id = '#COSMETIC';
            else if (text == 'مسافرتی')
            	id = '#TRAVEL';
            else if (text == 'کالا')
            	id = '#GOODS';
            document.location.href = $(id).attr('url');
        }
    });
    
    $('.ui.dropdown#profile').dropdown({
        on: 'hover',
        duration: 300,
        delay: {
            hide: 50,
            show: 0,
            search: 50,
            touch: 50
        },
        action: function(text) {
            if(text == 'خروج')
                id = '#logout';
            else if (text == 'ویرایش مشخصات فردی')
                id = '#edit';
            else if (text == 'تاریخچه‌ی سفارشات')
                id = '#history';
            document.location.href = $(id).attr('url');
        }
    });
    
    $('.ui.sticky').sticky({
        context: '#content',
        pushing: true,
        onStick: function() {
            $('#site-name').addClass('small');
            $('#logo').css('transform', 'rotate(-90deg)');
        },
        onUnstick: function() {
            $('#logo').css('transform', 'none');
            $('#site-name').removeClass('small');
        }
    });
    
    $('#q-fake').keypress(function(event) {
        if(event.which == 13) {
            $('#searchButton').trigger('click');
        }
    });
});

function searchClick() {
    $('#q').val($('#q-fake').val());
    document.forms['search'].submit();
}