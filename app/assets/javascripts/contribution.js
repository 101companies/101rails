$(function() {
    var folderInput = $('#page_contribution_folder');
    var updatePageButton = $('#update_page_button');
    folderInput.select2({width: '70%'}).select2('readonly', true);
    $("#page_contribution_url").select2({width: '70%'}).on("change", function(e) {
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
                folderInput.select2("readonly", false);
                populateInput(data);
                folderInput.select2({width: '70%'});
            }
        })
    });
});
