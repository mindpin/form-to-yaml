# 本地预览方法

命令行运行
```
git clone https://github.com/mindpin/yaml-to-form.git
cd yaml-to-form
ruby -run -e httpd . -p 4000
```

浏览器打开 http://localhost:4000/dist/demo


# 本地开发方式
命令行运行
```
git clone https://github.com/mindpin/yaml-to-form.git
cd yaml-to-form
npm install -g gulp
npm install
gulp watch
```