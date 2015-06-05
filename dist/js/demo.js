(function() {
  jQuery(function() {
    // 为了兼容 gh-pages
    return YamlToForm.load_config("/yaml-to-form/dist/yaml/config.yaml", function(ytf) {
      var instance;
      return instance = ytf.render_to(jQuery('.container'));
    });
  });

}).call(this);
