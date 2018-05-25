Runumerals: Convertation of numeric values to russian numerals
========
**Authors**: Sergey Abel, Boris Fifelin

**Copyright**: 1996 - 2018

**License**: MIT License

**Latest Version**: 1.0.2

**Ruby Version**:  >= 1.9.2
 
Synopsis
--------
Runumerals is a Ruby module providing methods that convert numeric values to russian numerals.

The rest of this file is in Russian as the use of this module implies the knowledge of the Russian language.

Модуль RuNumerals содержит функции для работы с русскими числительными.
Основное предназначение - преобразование числительных для финансовых документов (не забудьте про capitalize ;-).
Также иногда требуют нумерацию листов в виде "лист 2 из 35 листов", здесь будет полезна способность правильно давать склонение сущесвительного в зависимости от количества.
Если найдете ещё какие-либо применения, буду только рад.


Возможности
--------
1. Преобразование в количественные числительные
2. Преобразование в порядковые числительные
3. Преобразование числовых предствалений дат, времени, денежных единиц, дробей
4. Согласование по роду, падежу; возможность задать свою грамматику
5. Возможность расширения классов Ruby методами модуля RuNumerals (Ruby way?)

Feci quod potui, faciant meliora potentes :-)

Установка
---------

    $ gem install runumerals

Примеры
---------

```

    RuNumerals::ru_numeral(154,'д')                      #=> "ста пятидесяти четырём"
    RuNumerals::ru_numeral(101,'','с',1)                 #=> "ноль тысяч сто одно"
    RuNumerals::ru_numeral(1,'',RuNumerals::RUBGRAM,-1)  #=> "рубль"
    RuNumerals::ru_numeral(2,'',RuNumerals::RUBGRAM,-1)  #=> "рубля"
    RuNumerals::ru_ordinal(1)                 #=> "первый"
    RuNumerals::ru_ordinal(2)                 #=> "второй"		
    RuNumerals::ru_ordinal(250000000,'в','ж') #=> "двухсотпятидесятимиллионную"
    RuNumerals::ru_ordinal(5,'т','ж',true)    #=> "пятыми"
    RuNumerals::ru_ordinal(-5,'в','о')        #=> "минус пятого"
    RuNumerals::ru_date(Time.now)                                #=> "девятое ноября две тысячи шестнадцатого года"
    RuNumerals::ru_date(Time.now,"д",spellyy: false)             #=> "девятому ноября 2016 года"
    RuNumerals::ru_date(Time.now,spelldd: false, spellyy: false) #=> "9 ноября 2016 года"
    RuNumerals::ru_time(Time.now)                                #=> "восемнадцать часов пятьдесят две минуты двадцать секунд"
    RuNumerals::ru_time(Time.now,"д",spellhh: false , spellmm: false , spellss: false)
            #=> "18 часам 52 минутам 20 секундам"
    RuNumerals::ru_time(Time.now,'',spellhh: false , spellmm: false , noseconds: false)
            #=> "18 часов 52 минуты"
    RuNumerals::ru_money(123.029,"и",RuNumerals::RUBGRAM,RuNumerals::KOPGRAM)              #=> "сто двадцать три рубля три копейки"
    RuNumerals::ru_money(123.029,"р",RuNumerals::RUBGRAM,RuNumerals::KOPGRAM, spellkop: false) #=> "ста двадцати трёх рублей 03 копеек"
    RuNumerals::ru_money(123.029,"т",nil,RuNumerals::KOPGRAM)      #=> "двенадцатью тысячами тремястами тремя копейками"
    RuNumerals::ru_fractional(Rational(8,7))              #=> "одна целая одна седьмая"
    RuNumerals::ru_fractional(Rational(8,7),"",improper: true) #=> "восемь седьмых"
    RuNumerals::ru_fractional(Rational(6,2),"т")          #=> "тремя"
    RuNumerals::ru_fractional(1001.02)                    #=> "одна тысяча одна целая две сотых"
    RuNumerals::extend(Integer)                 #=> nil
    1.ru_numeral                                #=> "один"
    1.ru_ordinal("д")                           #=> "первому"
    RuNumerals::extend(Float,:ru_rubleskopecks) #=> nil
    1.25.ru_rubleskopecks("и",spellkop: false)      #=> "один рубль 25 копеек"
```

Замечания
---------
 Общие параметры для ряда функций:

 * gr_casus (<tt>String</tt>), значение по умолчанию: "и" - падеж числительного
  Может принимать значения "и","р","д","в","т" или "п" (первая буква названия падежа)
 
 * grammar (<tt>String</tt>), значение по умолчанию: "мн",
   описывает грамматику (род, одушевлённость/неодушевлённость, склонение по падежам).

 Имеет вид: <tt>"[мжс][но]|И1|Р1|Д1|В1|Т1|П1|И2|Р2|Д2|В2|Т2|П2"</tt> где

  1. \[мжс\] указывет род ("м" - мужской, "ж" - женский, "с" - средний)
  2. \[но\] указывет одушевлённость: "н" для неодушевлённых, "о" для одушевлённых
  3. склонение по падежам (знак | - разделитель между падежными формами):
   "И1" - форма для именительного падежа ед. ч., ... , "П2" - форма предложного падежа мн. ч.
 
 Если в грамматике не указаны падежные формы, то, соответсвенно, склоняемое с числительным слово не выводится.
 
 Примеры грамматик:

```

   "мн|этаж|этажа|этажу|этаж|этажом|этаже|этажи|этажей|этажам|этажи|этажами|этажах"
   "мо|человек|человека|человеку|человека|человеком|человеке|человеки|человек|человекам|человеков|человеками|человеках"
   "жн" # только согласование числительного по роду
```

 * Будьте осторожны с грамматиками. Например, множественное число слова <i>человек</i> - <i>люди</i> (супплетивная форма).
 Но с числительными употрбеляется именно <i>человеки</i> (не в именительном падеже, разумеется)

 * Также могут возникнуть проблемы с предложным падежом - в некоторых случаях требуется его другая форма (местный падеж).
 Например, "в 1965 <i>году</i>", а не "<i>годе</i>", "в третьем <i>ряду</i>", "в первом <i>часу</i>" и т.п.