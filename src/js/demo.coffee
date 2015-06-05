jQuery ->
  YamlToForm.load_config "http://www.mindpin.com/yaml-to-form/dist/yaml/config1.yaml", (ytf)->
    instance = ytf.render_to jQuery('.container')
