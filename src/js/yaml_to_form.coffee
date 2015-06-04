YamlUtil =
  # yaml 解析出来的数组，并非js原生数组
  # 根据规律，判断方式自定义如下
  get_type: (obj)->
    if typeof(obj) == "string"
      return "string"
    if typeof(obj) == "object" && typeof(obj.__proto__.length) != 'undefined'
      return "array"
    if typeof(obj) == "object" && typeof(obj.__proto__.length) == 'undefined'
      return "hash"

BuildFormUtil =
  build_dom_by_integer: (scope, value)->
    @build_dom_test(scope, value)

  build_dom_by_string: (scope, value)->
    @build_dom_test(scope, value)

  build_dom_by_text: (scope, value)->
    @build_dom_test(scope, value)

  build_dom_by_boolean: (scope, value)->
    @build_dom_test(scope, value)

  build_dom_by_time: (scope, value)->
    @build_dom_test(scope, value)

  build_dom_test: (scope, value)->
    key = scope.join(".")
    label = if value.label then value.label else key
    "
      <div class='form-group'>
        <label class='control-label'>#{key}</label>
        <div class='form-control-warp'>
          <input type='text' class='form-control' name='#{key}' />
        </div>
      </div>
    "

class YamlToForm
  constructor: (config)->
    @config   = @_init_config config
    console.log "@config"
    console.log @config
    @form_dom = @_init_form_dom()

  # date:
  #   format: time
  #   presence: true
  #   label:    日期
  #   default_value: 2015-01-01
  #   regex:    /[0-9]{4}-[0-1][0-9]-[0-3][0-9]/
  # members:
  #   format: array
  #   value:
  #     name:
  #       format: string
  #     begin:
  #       format: array
  #       value:
  #         thread:
  #           format: string
  #         items:
  #           format: array
  #           value:
  #             desc:
  #               format: text
  #             priority:
  #               format: integer
  #             willbedone:
  #               format: boolean
  #             timealloc: 3
  #               format: integer
  #     end:
  #       format: array
  #       value:
  #         thread:
  #           format: string
  #         items:
  #           format: array
  #           value:
  #             desc:
  #               format: string
  #             isdone:
  #               format: boolean
  #             timeused:
  #               format: integer
  #             submits:
  #               format: array
  #               value:
  #                 name:
  #                   format: string
  #                 link:
  #                   format: string
  #                 comment:
  #                   format: text
  #                 note:
  #                   format: text
  _init_config: (config)->
    @_init_config_nested config

  _init_config_nested: (hash)->
    for key, value of hash
      switch YamlUtil.get_type(value)
        when "string"
          new_value = @_parse_string_value(value)
          hash[key] = new_value
        when "array"
          new_value = @_init_config_nested(value[0])
          hash[key] = {format: "array", value: new_value}
        when "hash"
          new_value = @_init_config_nested(value)
          hash[key] = {format: "hash", value: new_value}
    hash

  # integer(*)[年份]<2015>/20[0-9]{2}/
  _parse_string_value: (value)->
    res = value.match(/(integer|string|text|boolean|time)(\(\*\))?(\[[^\]]*\])?(\<[^\>]*\>)?(\/.*\/)?/)
    throw "#{value} 不是有效的格式" if res == null
    new_value =
      format:        if res[1] then res[1]
      presence:      if res[2] then (res[2] == "(*)")
      label:         if res[3] then res[3].match(/\[(.*)\]/)[1]
      default_value: if res[4] then res[4].match(/\<(.*)\>/)[1]
      regex:         if res[4] then res[5]

  _init_form_dom: ->
    @form_dom = jQuery "<form action='javascript:;'>
      #{@_generate_init_form_input_dom()}
    </form>"

  _generate_init_form_input_dom: ->
    @_generate_init_form_input_dom_nested([], @config)

  _generate_init_form_input_dom_nested: (scope, config_hash)->
    dom_str_arr = []
    for key, value of config_hash
      new_scope = scope.slice()
      new_scope.push(key)
      dom_str = switch value.format
        when "array"
          @_generate_init_form_input_dom_nested(new_scope, value.value)
        when "hash"
          @_generate_init_form_input_dom_nested(new_scope, value.value)
        when "integer"
          BuildFormUtil.build_dom_by_integer(new_scope, value)
        when "string"
          BuildFormUtil.build_dom_by_string(new_scope, value)
        when "text"
          BuildFormUtil.build_dom_by_text(new_scope, value)
        when "boolean"
          BuildFormUtil.build_dom_by_boolean(new_scope, value)
        when "time"
          BuildFormUtil.build_dom_by_time(new_scope, value)
      dom_str_arr.push dom_str
    dom_str_arr.join ""
    dom_str_arr


  render_to: ($ele)->
    jQuery(@form_dom).appendTo($ele)


YamlToForm.load_config = (yaml_url, fun)->
  # 读取 yaml 配置
  config = YAML.load('/dist/yaml/config.yaml')
  ytf = new YamlToForm(config)
  fun(ytf)

window.YamlToForm = YamlToForm