jQuery ->
  YamlToForm.load_config "../../dist/yaml/config.yaml", (ytf)->
    instance = ytf.render_to jQuery('.container')
    console.log(instance.get_string())
