
var net = {

  init: function () {
    $.ajaxSetup({url: server_url(),
                 type: 'POST',
                 processData: 0});
  },
  send: function(msg, on_resp) { 
    $.ajax({url: server_url(),
            type: 'POST',
            processData: 0,
            crossDomain: true,
            data: JSON.stringify(msg),
            complete: this._on_resp_wrapper(on_resp)});
  },
  _on_resp_wrapper: function(fun) {
    return function(data, textStatus, jqXHR) {
      /* TODO: process server errors 
         if (data.status != 200 ) {
           log.d.err('server is down');
           log.ui.err('server is down');
         }
      */
      //var text = data.;
      //JSON.parse(str)
      return fun(JSON.parse(data.responseText));
    };
  }

};
