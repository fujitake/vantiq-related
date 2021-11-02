    var http = new Http();
    http.setVantiqUrlForSystemResource("procedures");
    http.setVantiqHeaders();
    var args = {};
    http.execute(args,"EventGeneratorUi.stop",function(response)
    {
        client.data.LastData = "..Please press start button.";
    },
    function(errors)
    {
        client.showHttpErrors(errors,"Executing 'EventGeneratorUi.stop()'");
    });