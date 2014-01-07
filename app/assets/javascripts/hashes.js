$(function() {

    function getHash() {
        var hash = window.location.hash;

        if (!hash.length) {
            hash='#page'
        }
        return hash;
    }

    $("[href=\"" + getHash() + "\"]").trigger("click");

    $(window).on('hashchange', function() {

        var hash = getHash()

        $('.tab-pane').removeClass('active');
        $('.nav-tabs li').removeClass('active');

        $(hash+'-tab-link').parent().addClass('active');
        $(hash).addClass('active');

    });

});
