jQuery ->
  YamlToForm.load_config "../../dist/yaml/config1.yaml", (ytf)->
    instance = ytf.render_to jQuery('.container')
