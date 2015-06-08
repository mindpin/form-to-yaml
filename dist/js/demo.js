(function() {
  jQuery(function() {
    return YamlToForm.load_config("../../dist/yaml/config.yaml", function(ytf) {
      var instance;
      instance = ytf.render_to(jQuery('.container'));
      return console.log(instance.get_string());
    });
  });

}).call(this);
