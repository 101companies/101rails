$(function() {
    $("#page_contribution_url").select2({
        width: "70%"
    }).on("change", function(e) {
        $.ajax({
            url: '/contribute/repo_dirs/'+ e.val,
            dataType: 'JSON',
            complete: function() {

            },
            error: function(){

            },
            success: function(data){
                var optionsAsString = "";
                for (var i=0; i<data.length; i++) {
                    optionsAsString += "<option value='" + data[i] + "'>" + data[i] + "</option>";
                }
                $('#page_contribution_folder').html('').append(optionsAsString).select2({
                    width: "70%"
                });
            }
        })
    });
});
