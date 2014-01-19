$(function(){

    var firstVersion = null;
    var secondVersion = null;

    $('.show_changes_button').addClass('disabled');

    $('.one-page-change input').prop({'checked': false});

    $('.show_changes_button').click('on', function(e) {
        e.preventDefault();
        if (!(secondVersion!=null && firstVersion!=null)) return false;
        window.location.href = "/page_changes/diff/" + firstVersion+"/" + secondVersion;
    });

    $('.one-page-change input').on('click', function(e){

        if (firstVersion == null) {
            firstVersion = $(this).data('page-change');
            $(this).prop({'checked': true});
        }
        else if (secondVersion == null) {
            secondVersion = $(this).data('page-change');
            $(this).prop({'checked': true});
        }
        else {
            if ($(this).data('page-change') == firstVersion) {
                firstVersion = null;
            }
            else if ($(this).data('page-change') == secondVersion) {
                secondVersion = null;
            }
            else {
                humane.log ("You already have chosen two revisions. Deselect one by clicking on it.");
            }
            $(this).prop({'checked': false});
        }

        // can we show button?
        (secondVersion!=null && firstVersion!=null) ?
            $('.show_changes_button').removeClass('disabled') : $('.show_changes_button').addClass('disabled');

    });
})();
