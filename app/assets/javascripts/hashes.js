$(function() {

    function getHash() {
        var hash = window.location.hash;

        if (!hash.length) {
            hash='#page'
        }
        return hash;
    }

    $("[href=\"" + getHash() + "\"]").trigger("click");

});
