# 为lua创造的快速中文转拼音库

先对于原版加了多音字支持

## 安装使用指南

直接将 pinyin.lua 复制到您的项目或者 LUA_PATH 中

## 代码指南

```lua
local pinyin = require'pinyin'
pinyin(chars, is_string, separator)
```

@参数1为您要转换的字符串
@参数2如果为 true 则返回字符串,否则返回为表
@参数3为参数2的增加选项制定拼音间字符

## 代码示例

```lua
local pinyin = require'pinyin'
print(pinyin("你好世界", true, "-"))
-- 输出: ni-hao-shi-jie  n-h-s-j
```

有两个返回值，第一个返回值为全部拼音，第二个为首拼.

## 多音字示例

```lua
local duoyin,duoyin_sp = pinyin("我要睡觉了", true)
print(duoyin, duoyin_sp)
-- 输出: wo yao shui jiao/jue le/liao    w y s j/j l/l
```