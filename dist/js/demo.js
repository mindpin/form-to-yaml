(function() {
  jQuery(function() {
    return YamlToForm.load_config("/dist/yaml/config.yaml", function(ytf) {
      var instance;
      return instance = ytf.render_to(jQuery('.container'));
    });
  });

}).call(this);
