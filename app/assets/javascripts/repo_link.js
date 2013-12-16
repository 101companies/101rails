$(function() {

    var repoInput = $("#repo_link_user_repo")
    var folderInput = $('#repo_link_folder');
    var updatePageButton = $('#update_page_button');
    var titleInput = $('#repo_link_page_title');

    folderInput.select2({width: '70%'}).select2('readonly', true);
    repoInput.select2({width: '70%'}).on("change", function(e) {
        var populateInput = function (data) {
            var optionsAsString = "";
            for (var i=0; i<data.length; i++) {
                optionsAsString += "<option value='" + data[i] + "'>" + data[i] + "</option>";
            }
            folderInput.html('').append(optionsAsString)
        };
        $.ajax({
            url: '/contribute/repo_dirs/'+ e.val,
            dataType: 'JSON',
            beforeSend: function () {
                populateInput(['Loading folders ...'])
                folderInput.select2({width: '70%'}).select2("readonly", true);
                updatePageButton.prop('disabled', true);
            },
            complete: function () {
                updatePageButton.prop('disabled', false);
            },
            error: function(){
                $.gritter.add({
                    title: 'Failed to retrieve folder of repo.',
                    text: 'Please restart the page and try later.'
                });
            },
            success: function(data){
                populateInput(data);
                folderInput.select2("readonly", false);
                folderInput.select2({width: '70%'});
                var repo = repoInput.val();
                titleInput.val(repo.substring(repo.lastIndexOf("/") + 1, repo.length));
            }
        })
    });
});
