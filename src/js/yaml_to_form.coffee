# 用来判断 yaml obj 类型的工具类
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

# 用来生成 dom str 的工具类
BuildFormUtil =
  build_dom_by_integer: (scope, value)->
    key = scope.join(".")
    label = if value.label then value.label else key
    presence_str      = if value.presence then "data-presence='true'" else ""
    default_value_str = if value.default_value then "value='#{value.default_value}'" else ""
    regex_str         = if value.regex then "data-regex='#{value.regex}'" else ""
    format_str        = "data-format='integer'"
    "
      <div class='form-group'>
        <label class='control-label'>#{label}</label>
        <input type='text' class='form-control' name='#{key}' #{regex_str} #{presence_str} #{default_value_str} #{format_str} />
      </div>
    "

  build_dom_by_string: (scope, value)->
    key = scope.join(".")
    label = if value.label then value.label else key
    presence_str      = if value.presence then "data-presence='true'" else ""
    default_value_str = if value.default_value then "value='#{value.default_value}'" else ""
    regex_str         = if value.regex then "data-regex='#{value.regex}'" else ""
    format_str        = "data-format='string'"
    "
      <div class='form-group'>
        <label class='control-label'>#{label}</label>
        <input type='text' class='form-control' name='#{key}' #{regex_str} #{presence_str} #{default_value_str} #{format_str}/>
      </div>
    "

  build_dom_by_boolean: (scope, value)->
    key = scope.join(".")
    label = if value.label then value.label else key
    default_value_str = if value.default_value then "checked='checked'" else ""
    "
      <div class='checkbox'>
        <input name='#{key}' type='hidden' value='false' />
        <label>
          <input name='#{key}' type='checkbox' value='true' #{default_value_str}>
          <span>#{label}</span>
        </label>
      </div>
    "

  build_dom_by_time: (scope, value)->
    key = scope.join(".")
    label = if value.label then value.label else key
    presence_str      = if value.presence then "data-presence='true'" else ""
    default_value_str = if value.default_value then "value='#{value.default_value}'" else ""
    regex_str         = if value.regex then "data-regex='#{value.regex}'" else ""
    format_str        = "data-format='time'"
    "
      <div class='form-group'>
        <label class='control-label'>#{label}</label>
        <input type='text' class='form-control' name='#{key}' #{regex_str} #{presence_str} #{default_value_str} #{format_str}/>
      </div>
    "

  build_dom_by_text: (scope, value)->
    key = scope.join(".")
    label = if value.label then value.label else key
    presence_str      = if value.presence then "data-presence='true'" else ""
    default_value_str = if value.default_value then value.default_value else ""
    regex_str         = if value.regex then "data-regex='#{value.regex}'" else ""
    "
      <div class='form-group'>
        <label class='control-label'>#{label}</label>
        <textarea class='form-control' rows='4' name='#{key}' #{presence_str} #{regex_str}>#{default_value_str}</textarea>
      </div>
    "

# 把 jQuery(form).SerializeArray() 获取的数据转化成 yaml
class FormParamsBuilder
  constructor: (@form_dom)->

  _expect_template_input_array: (origin_array)->
    expect_template_input_array = []
    for item in origin_array
      if !item.name.match(/\[-1\]/)
        expect_template_input_array.push item
    expect_template_input_array

  _array_to_hash: (array)->
    hash = {}
    for item in array
      name = item.name
      names = name.split(".")
      if names.length == 1
        hash[name] = item.value
      else
        @_set_value_to_hash(hash, names, item.value)
    hash

  _set_value_to_hash: (hash, names, value)->
    data = hash
    while names.length > 1
      name = names.shift()
      arr = name.match(/([^\[]*)(\[.*\])?/)
      if arr[2]
        index = arr[2].match(/\[(.*)\]/)[1]
        if data[arr[1]] == undefined then data[arr[1]] = []
        if data[arr[1]][index] == undefined then data[arr[1]][index] = {}
        data = data[arr[1]][index]
      else
        if data[name] == undefined then data[name] = {}
        data = data[name]
    data[names[0]] = value

  _check_value_for_input_or_textarea: (ele, item)->
    jQuery(ele).closest(".form-group").find(".error-info").remove()

    presence = jQuery(ele).attr("data-presence")
    regex    = jQuery(ele).attr("data-regex")
    format   = jQuery(ele).attr("data-format")

    if presence == "true" && jQuery.trim(item.value).length == 0
      # 增加不能为空的提示
      control_label = jQuery(ele).closest(".form-group").find(".control-label")
      control_label.after("<span class='error-info'>内容不能为空</span>")
      return false

    if jQuery.trim(item.value).length != 0
      switch format
        when "integer"
          if parseInt(item.value).toString() != item.value
            control_label = jQuery(ele).closest(".form-group").find(".control-label")
            control_label.after("<span class='error-info'>内容必须是数字</span>")
            return false
        when "time"
          if !item.value.match(/[0-9]{4}-[0-1][0-9]-[0-3][0-9]/)
            control_label = jQuery(ele).closest(".form-group").find(".control-label")
            control_label.after("<span class='error-info'>内容必须是时间格式</span>")
            return false

      if regex && !item.value.match(eval(regex))
        control_label = jQuery(ele).closest(".form-group").find(".control-label")
        control_label.after("<span class='error-info'>内容格式错误</span>")
        return false

    return true

  _validate_expect_template_input_array: (expect_template_input_array)->
    validate = true
    for item in expect_template_input_array

      name = item.name
      input = jQuery("input[type='text'][name='#{name}']").get(0)
      textarea = jQuery("textarea[type='text'][name='#{name}']").get(0)

      throw '出现未知错误' if input && textarea
      ele = (input || textarea)
      valid = @_check_value_for_input_or_textarea(ele, item)
      validate = false if !valid
    validate

  validate: ()->
    @origin_array = @form_dom.serializeArray()
    @expect_template_input_array = @_expect_template_input_array(@origin_array)
    if @_validate_expect_template_input_array(@expect_template_input_array)
      @hash = @_array_to_hash(@expect_template_input_array)
      @yaml = YAML.stringify(@hash)
      true
    else
      @hash = {}
      @yaml = ""
      false

class YamlToForm
  constructor: (config)->
    @config   = @_init_config config
    @form_dom = @_init_form_dom()
    @_init_event()

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
    @form_dom = jQuery "<form class='yaml-to-form' action='javascript:;'>
      #{@_generate_init_form_input_dom()}
      <div class='temp'>
      </div>
    </form>"

  _generate_init_form_input_dom: ->
    @_generate_init_form_input_dom_nested([], @config)

  _generate_init_form_input_dom_nested: (scope, config_hash)->
    dom_str_arr = []
    for key, value of config_hash
      new_scope = scope.slice()
      dom_str = switch value.format
        when "array"
          template_scope = new_scope.slice()
          new_key = "#{key}[0]"
          new_scope.push(new_key)
          dom_str = @_generate_init_form_input_dom_nested(new_scope, value.value)

          template_key = "#{key}[-1]"
          template_scope.push(template_key)
          template_dom_str = @_generate_init_form_input_dom_nested(template_scope, value.value)
          "
            <div class='form-group-array'>
              <div class='form-template'>
                #{template_dom_str}
              </div>
              <ul>
                <li data-index='0'>#{dom_str}</li>
              </ul>
              <a class='btn btn-default add' href='javascript:;'>增加</a>
            </div>
          "
        when "hash"
          new_scope.push(key)
          dom_str = @_generate_init_form_input_dom_nested(new_scope, value.value)
          "
            <div class='form-group-hash'>
              #{dom_str}
            </div>
          "
        when "integer"
          new_scope.push(key)
          BuildFormUtil.build_dom_by_integer(new_scope, value)
        when "string"
          new_scope.push(key)
          BuildFormUtil.build_dom_by_string(new_scope, value)
        when "text"
          new_scope.push(key)
          BuildFormUtil.build_dom_by_text(new_scope, value)
        when "boolean"
          new_scope.push(key)
          BuildFormUtil.build_dom_by_boolean(new_scope, value)
        when "time"
          new_scope.push(key)
          BuildFormUtil.build_dom_by_time(new_scope, value)
      dom_str_arr.push dom_str
    dom_str_arr.join " "

  _init_event: ()->
    that = this
    jQuery(document).on 'click', 'form.yaml-to-form a.add', ->
      # form-group-array
      form_group_array = jQuery(this).closest('.form-group-array')
      # 获取新创建的元素应该的角标数组
      new_ele_index_arr = []
      that._get_new_ele_index_arr(new_ele_index_arr, form_group_array)
      new_ele_index_arr[new_ele_index_arr.length-1] += 1
      # 获取新创建的 dom
      arr = new_ele_index_arr.slice()
      new_index = new_ele_index_arr[new_ele_index_arr.length-1]
      template = form_group_array.find(".form-template").html()
      template_dom = that._new_ele_dom(template, arr)
      # 插入dom到 li
      new_li = jQuery("
        <li data-index='#{new_index}'></li>
      ")
      new_li.append template_dom
      form_group_array.find(">ul").append new_li

  _new_ele_dom: (template, new_ele_index_arr)->
    template_dom = jQuery(template)
    template_dom.appendTo @form_dom.find(".temp")
    that = this
    @form_dom.find(".temp").find(".form-group input.form-control").each ->
      form_group = jQuery(this).closest(".form-group")
      label = form_group.find("label").text()
      name = form_group.find("input").attr("name")
      arr = new_ele_index_arr.slice()
      new_name = that._get_new_name_by_new_index(name, arr)
      form_group.find("input").attr("name", new_name)
      if name == label
        form_group.find("label").text(new_name)

    @form_dom.find(".temp").find(".checkbox label input").each ->
      checkbox = jQuery(this).closest(".checkbox")
      label = checkbox.find("label span").text()
      name  = checkbox.find("input").attr("name")
      arr = new_ele_index_arr.slice()
      new_name = that._get_new_name_by_new_index(name, arr)
      checkbox.find("input").attr("name", new_name)
      if name == label
        checkbox.find("label span").text(new_name)

    @form_dom.find(".temp").find(".form-group textarea.form-control").each ->
      form_group = jQuery(this).closest(".form-group")
      label = form_group.find("label").text()
      name = form_group.find("textarea").attr("name")
      arr = new_ele_index_arr.slice()
      new_name = that._get_new_name_by_new_index(name, arr)
      form_group.find("textarea").attr("name", new_name)
      if name == label
        form_group.find("label").text(new_name)
    template_dom

  _get_new_name_by_new_index: (name, new_ele_index_arr)->
    while new_ele_index_arr.length > 0
      index = new_ele_index_arr.shift()
      name = name.replace /\[[^_\]]*\]/, "[_#{index}_]"
    name = name.replace /\[_([^\]])_\]/g, "[$1]"
    name

  _get_new_ele_index_arr: (new_ele_index_arr, form_group_array)->
    last_li = form_group_array.find('ul li:last-child')
    if last_li != undefined then new_ele_index_arr.unshift parseInt(last_li.attr('data-index'))
    form_group_array = form_group_array.parent().closest('.form-group-array')
    if form_group_array.length > 0
      @_get_new_ele_index_arr(new_ele_index_arr, form_group_array)

  render_to: ($ele)->
    jQuery(@form_dom).appendTo($ele)
    return this

  validate: ()->
    @sat = (@sat || new FormParamsBuilder(@form_dom))
    @sat.validate()

  get_string: ()->
    return @sat.yaml if @validate()
    ""

YamlToForm.load_config = (yaml_url, fun)->
  # 读取 yaml 配置
  config = YAML.load(yaml_url)
  ytf = new YamlToForm(config)
  window.ytf = ytf
  fun(ytf)

window.YamlToForm = YamlToForm