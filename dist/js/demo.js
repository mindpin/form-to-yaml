(function() {
  jQuery(function() {
    // 为了兼容 gh-pages
    return YamlToForm.load_config("http://www.mindpin.com/yaml-to-form/dist/yaml/config1.yaml", function(ytf) {
      var instance;
      return instance = ytf.render_to(jQuery('.container'));
    });
  });

}).call(this);
