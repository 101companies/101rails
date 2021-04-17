$(function(){

    window.prepareCompareRevisionUI = function () {

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

            var was_checked_before = $(this).prop('checked');

            var data = $(this).data('page-change');

            if (firstVersion == null) {
                if (secondVersion != data) {
                    firstVersion = data;
                    $(this).prop({'checked': true});
                }
            }
            else if (secondVersion == null) {
                if (firstVersion != data) {
                    secondVersion = data;
                    $(this).prop({'checked': true});
                }
            }
            else {

                if ($(this).prop('checked') == was_checked_before) {

                    if (data == firstVersion) {
                        firstVersion = null;
                    }
                    else if (data == secondVersion) {
                        secondVersion = null;
                    }
                    else {
                        humane.log ("You already have chosen two revisions. Deselect one by clicking on it.");
                    }
                    $(this).prop({'checked': false});

                }

            }

            // can we show button?
            (secondVersion!=null && firstVersion!=null) ?
                $('.show_changes_button').removeClass('disabled') : $('.show_changes_button').addClass('disabled');

        });

    };

    window.prepareCompareRevisionUI();

});
