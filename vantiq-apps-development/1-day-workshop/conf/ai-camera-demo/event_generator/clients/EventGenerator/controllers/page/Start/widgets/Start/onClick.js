    var http = new Http();
    http.setVantiqUrlForSystemResource("procedures");
    http.setVantiqHeaders();
    var args = {};
    http.execute(args,"EventGeneratorUi.start",function(response){},
    function(errors)
    {
        client.showHttpErrors(errors,"Executing 'EventGeneratorUi.start()'");
    });