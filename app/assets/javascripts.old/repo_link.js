$(function() {

    var repoInput = $("#repo_link_user_repo");
    var folderInput = $('#repo_link_folder');
    var updatePageButton = $('#update_page_button');
    var titleInput = $('#repo_link_page_title');

    var populateInput = function (data) {
        var optionsAsString = "";
        for (var i=0; i<data.length; i++) {
            optionsAsString += "<option value='" + data[i] + "'>" + data[i] + "</option>";
        }
        folderInput.html('').append(optionsAsString)
    };

    var makeSelect2 = function (elem) {

        var params = {width: '70%'};

        if (elem.is(repoInput)) {
            params = $.extend(params, {'placeholder': 'Enter repo here ...'});
        }
        else if (elem.is(folderInput)) {
            params = $.extend(params, {'placeholder': 'Enter folder here ...'});
        }

        elem.select2(params);

        usedSelectFirstTime = false;

        $('.select2-input').attr('placeholder', 'Enter to select or search here ...');
    };

    window.load_repo_dirs = function(firstRun) {
        $.ajax({
            url: '/contribute/repo_dirs/'+ repoInput.val(),
            dataType: 'JSON',
            beforeSend: function () {
                populateInput(['Loading folders ...'])
                makeSelect2(folderInput);
                folderInput.select2("readonly", true);
                updatePageButton.prop('disabled', true);
            },
            complete: function () {
                updatePageButton.prop('disabled', false);

                if (typeof(firstRun) != 'undefined') {
                    if (typeof window.Repo != 'unedefined') {
                        repoInput.select2('val', window.Repo);
                        folderInput.select2('val', window.Folder);
                    }
                }


            },
            error: function(){
                humane.error("Failed to retrieve folder of repo.'Please restart the page and try later");
            },
            success: function(data){
                populateInput(data);
                folderInput.select2("readonly", false);
                makeSelect2(folderInput);
                var repo = repoInput.val();
                titleInput.val(repo.substring(repo.lastIndexOf("/") + 1, repo.length));
            }
        })

    }

    makeSelect2(repoInput);
    makeSelect2(folderInput);

    repoInput.on("change", function() {
        load_repo_dirs();
    });

});
