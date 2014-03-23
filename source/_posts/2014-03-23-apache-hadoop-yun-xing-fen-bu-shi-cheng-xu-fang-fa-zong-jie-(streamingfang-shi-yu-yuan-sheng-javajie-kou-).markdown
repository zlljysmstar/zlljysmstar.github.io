---
layout: post
title: "Apache Hadoop 运行分布式程序方法总结（Streaming方式与原生JAVA接口）"
date: 2014-03-23 13:49:11 +0800
comments: true
categories: 
---

1. Hadoop Streaming方式运行程序<br/>
Hadoop Streaming可以运行除JAVA语言以外，其它的语言编写的程序。其启动脚本示例如下：
{% include_code shell/hadoop_streaming_startup.sh %}
2. JAVA原生接口编写HADOOP程序<br/>
第一步，需要将用JAVA编写的代码打包成JAR包。
{% include_code java/MaxTemperatureMapper.java %}
{% include_code java/MaxTemperatureReducer.java %}
{% include_code java/MaxTemperature.java %}
打包命令：（即会生成MaxTemperate.jar文件，-C参数指定的文件夹目录结构：MaxTemperature/oldapi/*.java）
```bash JAR Command Example
jar cvf MaxTemperature.jar -C MaxTemperature/ .
```
第二步，启动运行。
```bash Run Command Example
sudo -u sniper hadoop jar MaxTemperature.jar oldapi.MaxTemperature /home/sniper/zhuliang/sample.txt
/home/sniper/zhuliang/max-temp-output
```
附：输入文件样例
```plain Input Sample Dataset
0067011990999991950051507004+68750+023550FM-12+038299999V0203301N00671220001CN9999999N9+00001+99999999999
0043011990999991950051512004+68750+023550FM-12+038299999V0203201N00671220001CN9999999N9+00221+99999999999
0043011990999991950051518004+68750+023550FM-12+038299999V0203201N00261220001CN9999999N9-00111+99999999999
0043012650999991949032412004+62300+010750FM-12+048599999V0202701N00461220001CN0500001N9+01111+99999999999
0043012650999991949032418004+62300+010750FM-12+048599999V0202701N00461220001CN0500001N9+00781+99999999999
```
