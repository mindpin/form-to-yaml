(function() {
  var BuildFormUtil, YamlToForm, YamlUtil;

  YamlUtil = {
    get_type: function(obj) {
      if (typeof obj === "string") {
        return "string";
      }
      if (typeof obj === "object" && typeof obj.__proto__.length !== 'undefined') {
        return "array";
      }
      if (typeof obj === "object" && typeof obj.__proto__.length === 'undefined') {
        return "hash";
      }
    }
  };

  BuildFormUtil = {
    build_dom_by_integer: function(scope, value) {
      return this.build_dom_test(scope, value);
    },
    build_dom_by_string: function(scope, value) {
      return this.build_dom_test(scope, value);
    },
    build_dom_by_text: function(scope, value) {
      return this.build_dom_test(scope, value);
    },
    build_dom_by_boolean: function(scope, value) {
      return this.build_dom_test(scope, value);
    },
    build_dom_by_time: function(scope, value) {
      return this.build_dom_test(scope, value);
    },
    build_dom_test: function(scope, value) {
      var key, label;
      key = scope.join(".");
      label = value.label ? value.label : key;
      return "<div class='form-group'> <label class='control-label'>" + key + "</label> <div class='form-control-warp'> <input type='text' class='form-control' name='" + key + "' /> </div> </div>";
    }
  };

  YamlToForm = (function() {
    function YamlToForm(config) {
      this.config = this._init_config(config);
      console.log("@config");
      console.log(this.config);
      this.form_dom = this._init_form_dom();
    }

    YamlToForm.prototype._init_config = function(config) {
      return this._init_config_nested(config);
    };

    YamlToForm.prototype._init_config_nested = function(hash) {
      var key, new_value, value;
      for (key in hash) {
        value = hash[key];
        switch (YamlUtil.get_type(value)) {
          case "string":
            new_value = this._parse_string_value(value);
            hash[key] = new_value;
            break;
          case "array":
            new_value = this._init_config_nested(value[0]);
            hash[key] = {
              format: "array",
              value: new_value
            };
            break;
          case "hash":
            new_value = this._init_config_nested(value);
            hash[key] = {
              format: "hash",
              value: new_value
            };
        }
      }
      return hash;
    };

    YamlToForm.prototype._parse_string_value = function(value) {
      var new_value, res;
      res = value.match(/(integer|string|text|boolean|time)(\(\*\))?(\[[^\]]*\])?(\<[^\>]*\>)?(\/.*\/)?/);
      if (res === null) {
        throw value + " 不是有效的格式";
      }
      return new_value = {
        format: res[1] ? res[1] : void 0,
        presence: res[2] ? res[2] === "(*)" : void 0,
        label: res[3] ? res[3].match(/\[(.*)\]/)[1] : void 0,
        default_value: res[4] ? res[4].match(/\<(.*)\>/)[1] : void 0,
        regex: res[4] ? res[5] : void 0
      };
    };

    YamlToForm.prototype._init_form_dom = function() {
      return this.form_dom = jQuery("<form action='javascript:;'> " + (this._generate_init_form_input_dom()) + " </form>");
    };

    YamlToForm.prototype._generate_init_form_input_dom = function() {
      return this._generate_init_form_input_dom_nested([], this.config);
    };

    YamlToForm.prototype._generate_init_form_input_dom_nested = function(scope, config_hash) {
      var dom_str, dom_str_arr, key, new_scope, value;
      dom_str_arr = [];
      for (key in config_hash) {
        value = config_hash[key];
        new_scope = scope.slice();
        new_scope.push(key);
        dom_str = (function() {
          switch (value.format) {
            case "array":
              return this._generate_init_form_input_dom_nested(new_scope, value.value);
            case "hash":
              return this._generate_init_form_input_dom_nested(new_scope, value.value);
            case "integer":
              return BuildFormUtil.build_dom_by_integer(new_scope, value);
            case "string":
              return BuildFormUtil.build_dom_by_string(new_scope, value);
            case "text":
              return BuildFormUtil.build_dom_by_text(new_scope, value);
            case "boolean":
              return BuildFormUtil.build_dom_by_boolean(new_scope, value);
            case "time":
              return BuildFormUtil.build_dom_by_time(new_scope, value);
          }
        }).call(this);
        dom_str_arr.push(dom_str);
      }
      dom_str_arr.join("");
      return dom_str_arr;
    };

    YamlToForm.prototype.render_to = function($ele) {
      return jQuery(this.form_dom).appendTo($ele);
    };

    return YamlToForm;

  })();

  YamlToForm.load_config = function(yaml_url, fun) {
    var config, ytf;
    config = YAML.load(yaml_url);
    ytf = new YamlToForm(config);
    return fun(ytf);
  };

  window.YamlToForm = YamlToForm;

}).call(this);
