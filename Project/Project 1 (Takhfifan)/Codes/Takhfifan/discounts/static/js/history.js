$(document).ready(function() {
    $('.date').each(function() {
        $(this).text(moment($(this).text(), 'LL').locale('fa').format('LL'));
    });
});