jQuery ->
  YamlToForm.load_config "/dist/yaml/config.yaml", (ytf)->
    instance = ytf.render_to jQuery('.container')
