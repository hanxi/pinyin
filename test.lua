local pinyin = require("pinyin")
local begin = os.clock()
for i = 1, 50000 do
    pinyin("速度测试")
end
print(string.format("total time:%.2fms\n", ((os.clock() - begin) * 1000)))

local pinyin = require'pinyin'
print(pinyin("你好世界", true, "-"))

local duoyin,duoyin_sp = pinyin("我要睡觉了", true)
print(duoyin, duoyin_sp)

local serpent = require "serpent"
local duoyin,duoyin_sp = pinyin("我要睡觉了")
print(serpent.line(duoyin,{comment=false}), serpent.line(duoyin_sp,{comment=false}))