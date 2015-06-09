jQuery ->
  YamlToForm.load_config "../../dist/yaml/config.yaml", (ytf)->
    instance = ytf.render_to jQuery('.container')
    jQuery(".submit").on "click", ->
      instance.validate()
      console.log(instance.get_string())
