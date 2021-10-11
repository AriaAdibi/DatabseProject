$(document).ready(function() {
    $('.progress').progress();
    $('#info.menu .item').tab();
    var f = function() {
        var left = expire.preciseDiff(moment(), true);
        if(left.months > 0) {
            $('#time').removeClass('three column row');
            $('#time').addClass('four column row');
            $('#time').prepend('<div class="column" id="months"></div>');
            $('#months').text(left.months + ' ماه');
        } else if ($('#time').hasClass('four column row')) {
            $('#time').removeClass('four column row');
            $('#time').addClass('three column row');
            $('#months').remove();
        }
        $('#days').text(left.days + ' روز');
        $('#hours').text(left.hours + ' ساعت');
        $('#minutes').text(left.minutes + ' دقیقه');
    };
    f();
    setInterval(f, 60000);
});