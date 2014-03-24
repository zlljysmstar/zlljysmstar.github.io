---
layout: post
title: "Python字符编码详解"
date: 2014-03-23 21:48:31 +0800
comments: true
categories: Python CCode
---

##字符编码简介<br/>
1.1 ASCII<br/><br/>
ASCII(American Standard Code for Information Interchange)，是一种单字节的编码。计算机世界里一开始只有英文，而单字节可以表示256个不同的字符，可以表示所有的英文字符和许多的控制符号。不过ASCII只用到了其中的一半（\x80以下），这也是MBCS得以实现的基础。<br/><br/>
1.2 MBCS<br/>
<!--more-->
然而计算机世界里很快就有了其他语言，单字节的ASCII已无法满足需求。后来每个语言就制定了一套自己的编码，由于单字节能表示的字符太少，而且同时也需要与ASCII编码保持兼容，所以这些编码纷纷使用了多字节来表示字符，如GBxxx、BIGxxx等等，他们的规则是，如果第一个字节是\x80以下，则仍然表示ASCII字符；而如果是\x80以上，则跟下一个字节一起（共两个字节）表示一个字符，然后跳过下一个字节，继续往下判断。<br/><br/>
这里，IBM发明了一个叫Code Page的概念，将这些编码都收入囊中并分配页码，GBK是第936页，也就是CP936。所以，也可以使用CP936表示GBK。<br/><br/>
MBCS(Multi-Byte Character Set)是这些编码的统称。目前为止大家都是用了双字节，所以有时候也叫做DBCS(Double-Byte Character Set)。必须明确的是，MBCS并不是某一种特定的编码，Windows里根据你设定的区域不同，MBCS指代不同的编码，而Linux里无法使用MBCS作为编码。在Windows中你看不到MBCS这几个字符，因为微软为了更加洋气，使用了ANSI来吓唬人，记事本的另存为对话框里编码ANSI就是MBCS。同时，在简体中文Windows默认的区域设定里，指代GBK。<br/><br/>
1.3 Unicode<br/><br/>
后来，有人开始觉得太多编码导致世界变得过于复杂了，让人脑袋疼，于是大家坐在一起拍脑袋想出来一个方法：所有语言的字符都用同一种字符集来表示，这就是Unicode。<br/><br/>
最初的Unicode标准UCS-2使用两个字节表示一个字符，所以你常常可以听到Unicode使用两个字节表示一个字符的说法。但过了不久有人觉得256*256太少了，还是不够用，于是出现了UCS-4标准，它使用4个字节表示一个字符，不过我们用的最多的仍然是UCS-2。<br/><br/>
UCS(Unicode Character Set)还仅仅是字符对应码位的一张表而已，比如"汉"这个字的码位是6C49。字符具体如何传输和储存则是由UTF(UCS Transformation Format)来负责。<br/><br/>
一开始这事很简单，直接使用UCS的码位来保存，这就是UTF-16，比如，"汉"直接使用\x6C\x49保存(UTF-16-BE)，或是倒过来使用\x49\x6C保存(UTF-16-LE)。但用着用着美国人觉得自己吃了大亏，以前英文字母只需要一个字节就能保存了，现在大锅饭一吃变成了两个字节，空间消耗大了一倍……于是UTF-8横空出世。<br/><br/>
UTF-8是一种很别扭的编码，具体表现在他是变长的，并且兼容ASCII，ASCII字符使用1字节表示。然而这里省了的必定是从别的地方抠出来的，你肯定也听说过UTF-8里中文字符使用3个字节来保存吧？4个字节保存的字符更是在泪奔……（具体UCS-2是怎么变成UTF-8的请自行搜索）<br/><br/>
另外值得一提的是BOM(Byte Order Mark)。我们在储存文件时，文件使用的编码并没有保存，打开时则需要我们记住原先保存时使用的编码并使用这个编码打开，这样一来就产生了许多麻烦。（你可能想说记事本打开文件时并没有让选编码？不妨先打开记事本再使用文件->打开看看）而UTF则引入了BOM来表示自身编码，如果一开始读入的几个字节是其中之一，则代表接下来要读取的文字使用的编码是相应的编码：<br/>
```plain BOM Header
BOM_UTF8 '\xef\xbb\xbf'
BOM_UTF16_LE '\xff\xfe'
BOM_UTF16_BE '\xfe\xff'
```
并不是所有的编辑器都会写入BOM，但即使没有BOM，Unicode还是可以读取的，只是像MBCS的编码一样，需要另行指定具体的编码，否则解码将会失败。<br/><br/>
你可能听说过UTF-8不需要BOM，这种说法是不对的，只是绝大多数编辑器在没有BOM时都是以UTF-8作为默认编码读取。即使是保存时默认使用ANSI(MBCS)的记事本，在读取文件时也是先使用UTF-8测试编码，如果可以成功解码，则使用UTF-8解码。记事本这个别扭的做法造成了一个BUG：如果你新建文本文件并输入"姹塧"然后使用ANSI(MBCS)保存，再打开就会变成"汉a"，你不妨试试：）<br/><br/>
##Python 2.x中的编码问题<br/>
2.1 str和unicode<br/><br/>
str和unicode都是basestring的子类。严格意义上说，str其实是字节串，它是unicode经过编码后的字节组成的序列。对UTF-8编码的str'汉'使用len()函数时，结果是3，因为实际上，UTF-8编码的'汉' == '\xE6\xB1\x89'。<br/><br/>
unicode才是真正意义上的字符串，对字节串str使用正确的字符编码进行解码后获得，并且len(u'汉') == 1。<br/><br/>
再来看看encode()和decode()两个basestring的实例方法，理解了str和unicode的区别后，这两个方法就不会再混淆了：<br/>
```python example 1
# coding: UTF-8
 
u = u'汉'
print repr(u) # u'\u6c49'
s = u.encode('UTF-8')
print repr(s) # '\xe6\xb1\x89'
u2 = s.decode('UTF-8')
print repr(u2) # u'\u6c49'
 
# 对unicode进行解码是错误的
# s2 = u.decode('UTF-8')
# 同样，对str进行编码也是错误的
# u2 = s.encode('UTF-8')
```
需要注意的是，虽然对str调用encode()方法是错误的，但实际上Python不会抛出异常，而是返回另外一个相同内容但不同id的str；对unicode调用decode()方法也是这样。很不理解为什么不把encode()和decode()分别放在unicode和str中而是都放在basestring中，但既然已经这样了，我们就小心避免犯错吧。<br/><br/>
2.2 字符编码声明<br/><br/>
源代码文件中，如果有用到非ASCII字符，则需要在文件头部进行字符编码的声明，如下：
```python example 2
#-*- coding: UTF-8 -*-
```
实际上Python只检查#、coding和编码字符串，其他的字符都是为了美观加上的。另外，Python中可用的字符编码有很多，并且还有许多别名，还不区分大小写，比如UTF-8可以写成u8。参见http://docs.python.org/library/codecs.html#standard-encodings。<br/><br/>
另外需要注意的是声明的编码必须与文件实际保存时用的编码一致，否则很大几率会出现代码解析异常。现在的IDE一般会自动处理这种情况，改变声明后同时换成声明的编码保存，但文本编辑器控们需要小心 ：）<br/><>br/>
2.3 读写文件<br/><br/>
内置的open()方法打开文件时，read()读取的是str，读取后需要使用正确的编码格式进行decode()。write()写入时，如果参数是unicode，则需要使用你希望写入的编码进行encode()，如果是其他编码格式的str，则需要先用该str的编码进行decode()，转成unicode后再使用写入的编码进行encode()。如果直接将unicode作为参数传入write()方法，Python将先使用源代码文件声明的字符编码进行编码然后写入。<br/><br/>
```python example 3
# coding: UTF-8
 
f = open('test.txt')
s = f.read()
f.close()
print type(s) # <type 'str'>
# 已知是GBK编码，解码成unicode
u = s.decode('GBK')
 
f = open('test.txt', 'w')
# 编码成UTF-8编码的str
s = u.encode('UTF-8')
f.write(s)
f.close()
```
另外，模块codecs提供了一个open()方法，可以指定一个编码打开文件，使用这个方法打开的文件读取返回的将是unicode。写入时，如果参数是unicode，则使用open()时指定的编码进行编码后写入；如果是str，则先根据源代码文件声明的字符编码，解码成unicode后再进行前述操作。相对内置的open()来说，这个方法比较不容易在编码上出现问题。<br/>
```python example 4
# coding: GBK
 
import codecs
 
f = codecs.open('test.txt', encoding='UTF-8')
u = f.read()
f.close()
print type(u) # <type 'unicode'>
 
f = codecs.open('test.txt', 'a', encoding='UTF-8')
# 写入unicode
f.write(u)
 
# 写入str，自动进行解码编码操作
# GBK编码的str
s = '汉'
print repr(s) # '\xba\xba'
# 这里会先将GBK编码的str解码为unicode再编码为UTF-8写入
f.write(s) 
f.close()
```
2.4 与编码相关的方法<br/>
sys/locale模块中提供了一些获取当前环境下的默认编码的方法。<br/>
```python example 5
# coding:gbk
 
import sys
import locale
 
def p(f):
    print '%s.%s(): %s' % (f.__module__, f.__name__, f())
 
# 返回当前系统所使用的默认字符编码
p(sys.getdefaultencoding)
 
# 返回用于转换Unicode文件名至系统文件名所使用的编码
p(sys.getfilesystemencoding)
 
# 获取默认的区域设置并返回元祖(语言, 编码)
p(locale.getdefaultlocale)
 
# 返回用户设定的文本数据编码
# 文档提到this function only returns a guess
p(locale.getpreferredencoding)
 
# \xba\xba是'汉'的GBK编码
# mbcs是不推荐使用的编码，这里仅作测试表明为什么不应该用
print r"'\xba\xba'.decode('mbcs'):", repr('\xba\xba'.decode('mbcs'))
 
#在笔者的Windows上的结果(区域设置为中文(简体, 中国))
#sys.getdefaultencoding(): gbk
#sys.getfilesystemencoding(): mbcs
#locale.getdefaultlocale(): ('zh_CN', 'cp936')
#locale.getpreferredencoding(): cp936
#'\xba\xba'.decode('mbcs'): u'\u6c49'
```
##3 一些建议<br/>
3.1. 使用字符编码声明，并且同一工程中的所有源代码文件使用相同的字符编码声明。<br/><br/>
这点是一定要做到的。<br/><br/>
3.2. 抛弃str，全部使用unicode。<br/><br/>
按引号前先按一下u最初做起来确实很不习惯而且经常会忘记再跑回去补，但如果这么做可以减少90%的编码问题。如果编码困扰不严重，可以不参考此条。<br/><br/>
3.3. 使用codecs.open()替代内置的open()。<br/><br/>
如果编码困扰不严重，可以不参考此条。<br/><br/>
3.4. 绝对需要避免使用的字符编码：MBCS/DBCS和UTF-16。<br/><br/>
这里说的MBCS不是指GBK什么的都不能用，而是不要使用Python里名为'MBCS'的编码，除非程序完全不移植。<br/><br/>
Python中编码'MBCS'与'DBCS'是同义词，指当前Windows环境中MBCS指代的编码。Linux的Python实现中没有这种编码，所以一旦移植到Linux一定会出现异常！另外，只要设定的Windows系统区域不同，MBCS指代的编码也是不一样的。分别设定不同的区域运行2.4小节中的代码的结果：<br/>
```python example 6
#中文(简体, 中国)
#sys.getdefaultencoding(): gbk
#sys.getfilesystemencoding(): mbcs
#locale.getdefaultlocale(): ('zh_CN', 'cp936')
#locale.getpreferredencoding(): cp936
#'\xba\xba'.decode('mbcs'): u'\u6c49'
 
#英语(美国)
#sys.getdefaultencoding(): UTF-8
#sys.getfilesystemencoding(): mbcs
#locale.getdefaultlocale(): ('zh_CN', 'cp1252')
#locale.getpreferredencoding(): cp1252
#'\xba\xba'.decode('mbcs'): u'\xba\xba'
 
#德语(德国)
#sys.getdefaultencoding(): gbk
#sys.getfilesystemencoding(): mbcs
#locale.getdefaultlocale(): ('zh_CN', 'cp1252')
#locale.getpreferredencoding(): cp1252
#'\xba\xba'.decode('mbcs'): u'\xba\xba'
 
#日语(日本)
#sys.getdefaultencoding(): gbk
#sys.getfilesystemencoding(): mbcs
#locale.getdefaultlocale(): ('zh_CN', 'cp932')
#locale.getpreferredencoding(): cp932
#'\xba\xba'.decode('mbcs'): u'\uff7a\uff7a'
```
可见，更改区域后，使用mbcs解码得到了不正确的结果，所以，当我们需要使用'GBK'时，应该直接写'GBK'，不要写成'MBCS'。<br/><br/>
UTF-16同理，虽然绝大多数操作系统中'UTF-16'是'UTF-16-LE'的同义词，但直接写'UTF-16-LE'只是多写3个字符而已，而万一某个操作系统中'UTF-16'变成了'UTF-16-BE'的同义词，就会有错误的结果。实际上，UTF-16用的相当少，但用到的时候还是需要注意。<br/><br/>
