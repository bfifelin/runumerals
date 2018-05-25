# encoding: UTF-8
# Russian nurerals
#
# Copyright (c) 1996 Sergey Abel, (c) 2016 Boris Fifelin
#
# Licensed under the same terms as Ruby. No warranty is provided.
#
# Feci quod potui, faciant meliora potentes :-)
#
# RuNumerals contains methods that convert numeric values to russian numerals.
# The description and comments are in Russian as the use of this module implies
# the knowledge of the Russian language.
#
# Модуль RuNumerals содержит функции для работы с русскими числительными.
# Основное предназначение - преобразование числительных для финансовых документов (не забудьте про capitalize ;-).
# Также иногда требуют нумерацию листов в виде "лист 2 из 35 листов", здесь будет полезна
# способность правильно давать склонение сущесвительного в зависимости от количества.
# Если найдете ещё какие-либо применения, буду только рад.
#
# Общие параметры для ряда функций:
#
# * grammatical_case (+String+), значение по умолчанию: "и" - падеж числительного
# Может принимать значения "и","р","д","в","т" или "п" (первая буква названия падежа)
# * grammar (+String+), значение по умолчанию: "мн",
# описывает грамматику (род, одушевлённость/неодушевлённость, склонение по падежам).
#
# Имеет вид: <tt>"[мжс][но]|И1|Р1|Д1|В1|Т1|П1|И2|Р2|Д2|В2|Т2|П2"</tt> где
# 1. \[мжс\] указывет род ("м" - мужской, "ж" - женский, "с" - средний)
# 2. \[но\] указывет одушевлённость: "н" для неодушевлённых, "о" для одушевлённых
# 3. склонение по падежам (знак | - разделитель между падежными формами):
# "И1" - форма для именительного падежа ед. ч., ... , "П2" - форма предложного падежа мн. ч.
# Если в грамматике не указаны падежные формы, то, соответсвенно, склоняемое с числительным слово не выводится.
#
# Примеры грамматик:
#
#		"мн|этаж|этажа|этажу|этаж|этажом|этаже|этажи|этажей|этажам|этажи|этажами|этажах"
#		"мо|человек|человека|человеку|человека|человеком|человеке|человеки|человек|человекам|человеков|человеками|человеках"
#		"жн" # только согласование числительного по роду
#
#	Замечания:
# - Будьте осторожны с грамматиками, например, множественное число слова <i>человек</i> - <i>люди</i> (супплетивная форма).
# Но с числительными употрбеляется именно <i>человеки</i> (не в именительном падеже, разумеется)
# - Также могут возникнуть проблемы с предложным падежом - в некоторых случаях требуется его другая форма (местный падеж).
# Например, "в 1961 <i>году</i>", а не <i>годе</i>, "в третьем <i>ряду</i>", "в первом <i>часу</i>" и т.п.

require 'version.rb'

module RuNumerals
	# RuNumerals contains methods that convert numeric values to russian numerals.
	# The description and comments are in Russian as the use of this module implies the knowledge of the Russian language.

	EXTEND_MAP={Integer => [:ru_numeral, :ru_ordinal],
		Float => [:ru_fractional, :ru_money, :ru_rubles, :ru_kopecks, :ru_rubleskopecks,
			:ru_dollars, :ru_cents, :ru_dollarscents, :ru_euros, :ru_eurocents, :ru_euroseurocents],
		Rational => [:ru_fractional],
		Time => [:ru_date, :ru_time]}
	private_constant :EXTEND_MAP
	CASUS_STR="ирдвтп"
	private_constant :CASUS_STR
	ORDWORD=[nil,"тысяч","миллион","миллиард","триллион","квадриллион","квинтиллион","секстиллион","септиллион","октиллион","нониллион",
		"дециллион","ундециллион","додециллион","тредециллион","кваттуордециллион",
		"квиндециллион","седециллион","септдециллион","октодециллион","новемдециллион",
		"вигинтиллион","анвигинтиллион","дуовигинтиллион","тревигинтиллион","кватторвигинтиллион",
		"квинвигинтиллион","сексвигинтиллион","септемвигинтиллион","октовигинтиллион","новемвигинтиллион",
		"тригинтиллион","антригинтиллион","дуотригинтиллион","третригинтиллион","кваттортригинтиллион",
		"квинтригинтиллион","секстригинтиллион","септемтригинтиллион","октотригинтиллион","новемтригинтиллион",
		"квадрагинтиллион","анквадрагинтиллион","дуоквадрагинтиллион","треквадрагинтиллион","кватторквадрагинтиллион",
		"квинквадрагинтиллион","сексквадрагинтиллион","септемквадрагинтиллион","октоквадрагинтиллион","новемквадрагинтиллион",
		"квинквагинтиллион","анквинквагинтиллион","дуоквинквагинтиллион","треквинквагинтиллион","кватторквинквагинтиллион",
		"квинквинквагинтиллион","сексквинквагинтиллион","септемквинквагинтиллион","октоквинквагинтиллион","новемквинквагинтиллион",
		"сексагинтиллион","ансексагинтиллион","дуосексагинтиллион","тресексагинтиллион","кватторсексагинтиллион",
		"квинсексагинтиллион","секссексагинтиллион","септемсексагинтиллион","октосексагинтиллион","новемсексагинтиллион",
		"септуагинтиллион","ансептуагинтиллион","дуосептуагинтиллион","тресептуагинтиллион","кватторсептуагинтиллион",
		"квинсептуагинтиллион","секссептуагинтиллион","септемсептуагинтиллион","октосептуагинтиллион","новемсептуагинтиллион",
		"октогинтиллион","аноктогинтиллион","дуооктогинтиллион","треоктогинтиллион","кваттороктогинтиллион",
		"квиноктогинтиллион","сексоктогинтиллион","септемоктогинтиллион","октооктогинтиллион","новемоктогинтиллион",
		"нонагинтиллион","аннонагинтиллион","дуононагинтиллион","тренонагинтиллион","кватторнонагинтиллион",
		"квиннонагинтиллион","секснонагинтиллион","септемнонагинтиллион","октононагинтиллион","новемнонагинтиллион","центиллион"]
	private_constant :ORDWORD
	THOU_ENDING=[["а","и","е","у","ей","е"],["и","","ам","и","ами","ах"]]
	private_constant :THOU_ENDING
	MILLI_ENDING=[["","а","у","","ом","е"],["ы","ов","ам","ы","ами","ах"]]
	private_constant :MILLI_ENDING
	HUNDREDS=[nil,["сто","ста","ста","сто","ста","ста"],
		["двести","двухсот","двумстам","двести","двумястами","двухстах"],
		["триста","трёхсот","трёмстам","триста","тремястами","трёхстах"],
		["четыреста","четырёхсот","четырёмстам","четыреста","четырьмястами","четырёхстах"],
		["пятьсот","пятисот","пятистам","пятьсот","пятьюстами","пятистах"],
		["шестьсот","шестисот","шестистам","шестьсот","шестьюстами","шестистах"],
		["семьсот","семисот","семистам","семьсот","семьюстами","семистах"],
		["восемьсот","восьмисот","восьмистам","восемьсот","восьмьюстами","восьмистах"],
		["девятьсот","девятисот","девятистам","девятьсот","девятьюстами","девятистах"]]
	private_constant :HUNDREDS
	TWENTIES=[nil,nil,
		["двадцать","двадцати","двадцати","двадцать","двадцатью","двадцати"],
		["тридцать","тридцати","тридцати","тридцать","тридцатью","тридцати"],
		["сорок","сорока","сорока","сорок","сорока","сорока"],
		["пятьдесят","пятидесяти","пятидесяти","пятьдесят","пятьюдесятью","пятидесяти"],
		["шестьдесят","шестидесяти","шестидесяти","шестьдесят","шестьюдесятью","шестидесяти"],
		["семьдесят","семидесяти","семидесяти","семьдесят","семьюдесятью","семидесяти"],
		["восемьдесят","восьмидесяти","восьмидесяти","восемьдесят","восьмьюдесятью","восьмидесяти"],
		["девяносто","девяноста","девяноста","девяносто","девяноста","девяноста"]]
	private_constant :TWENTIES
	TEENCASES=["ь","и","и","ь","ью","и"]
	private_constant :TEENCASES
	ONES=[["ноль","нуля","нулю","ноль","нулём","нуле"],
		["один","одного","одному","один","одним","одном"],
		["два","двух","двум","два","двумя","двух"],
		["три","трёх","трём","три","тремя","трёх"],
		["четыре","четырёх","четырём","четыре","четырьмя","четырёх"],
		["пять","пяти","пяти","пять","пятью","пяти"],
		["шесть","шести","шести","шесть","шестью","шести"],
		["семь","семи","семи","семь","семью","семи"],
		["восемь","восьми","восьми","восемь","восемью","восьми"],
		["девять","девяти","девяти","девять","девятью","девяти"]]
	private_constant :ONES
	ONES1=[nil,["одна","одной","одной","одну","одной","одной"],
		["одно","одного","одному","одно","одним","одном"]]
	private_constant :ONES1
	ONES2=[nil,["две","двух","двум","две","двумя","двух"],
		["два","двух","двум","два","двумя","двух"]]
	private_constant :ONES2
	ENDING02678=[["ой","ого","ому","ой","ым","ом"],
		["ая","ой","ой","ую","ой","ой"],
		["ое","ого","ому","ое","ым","ом"],
		["ые","ых","ым","ые","ыми","ых"]]
	private_constant :ENDING02678
	ENDING1459=[["ый","ого","ому","ый","ым","ом"],
		["ая","ой","ой","ую","ой","ой"],
		["ое","ого","ому","ое","ым","ом"],
		["ые","ых","ым","ые","ыми","ых"]]
	private_constant :ENDING1459
	ENDING3=[["ий","ьего","ьему","ий","ьим","ьем"],
		["ья","ьей","ьей","ью","ьей","ьей"],
		["ье","ьего","ьему","ье","ьим","ьем"],
		["ьи","ьих","ьим","ьи","ьими","ьих"]]
	private_constant :ENDING3
	ACCUSATIVE=["ого","ую","ое","ых"]
	private_constant :ACCUSATIVE
	ACCUSATIVE3=["ьего","ью","ье","ьих"]
	private_constant :ACCUSATIVE3
	COMPOUNDS=["одно","двух","трёх","четырёх","пяти","шести","семи","восьми","девяти"]
	private_constant :COMPOUNDS
	TEENS=["десят","одиннадцат","двенадцат","тринадцат","четырнадцат","пятнадцат","шестнадцат","семнадцат","восемнадцат","девятнадцат"]
	private_constant :TEENS
	TIES=[nil,nil,"двадцат","тридцат","сороков","пятидесят","шестидесят","семидесят","восьмидесят","девяност"]
	private_constant :TIES
	ORDINALS=["нулев","перв","втор","трет","четвёрт","пят","шест","седьм","восьм","девят"]
	private_constant :ORDINALS
	MONTAB=["января","февраля","марта","апреля","мая","июня","июля","августа","сентября","октября","ноября","декабря"]
	private_constant :MONTAB
	YEARGRAM="мн|год|года|году|год|годом|годе|годы|годов|годам|годы|годами|годах"
	private_constant :YEARGRAM
	HOURGRAM="мн|час|часа|часу|час|часом|часе|часы|часов|часам|часы|часами|часах"
	private_constant :HOURGRAM
	MINGRAM="жн|минута|минуты|минуте|минуту|минутой|минуте|минуты|минут|минутам|минуты|минутами|минутах"
	private_constant :MINGRAM
	SECGRAM="жн|секунда|секунды|секунде|секунду|секундой|секунде|секунды|секунд|секундам|секунды|секундами|секундах"
	private_constant :SECGRAM
	WHOLEGRAM="жн|целая|целой|целой|целую|целой|целой|целые|целых|целым|целые|целыми|целых"
	private_constant :WHOLEGRAM
	# Грамматика слова "рубль"
	RUBGRAM="мн|рубль|рубля|рублю|рубль|рублём|рубле|рубли|рублей|рублям|рубли|рублями|рублях"
	# Грамматика слова "копейка"
	KOPGRAM="жн|копейка|копейки|копейке|копейку|копейкой|копейке|копейки|копеек|копейкам|копейки|копейками|копейках"
	# Грамматика слова "доллар"
	DOLLARGRAM="мн|доллар|доллара|доллару|доллар|долларом|долларе|доллары|долларов|долларам|доллары|долларами|долларах"
	# Грамматика слова "цент"
	CENTGRAM="мн|цент|цента|центу|цент|центом|центе|центы|центов|центам|центы|центами|центах"
	# Грамматика слова "евро"
	EUROGRAM="мн|евро|евро|евро|евро|евро|евро|евро|евро|евро|евро|евро|евро"
	# Грамматика слова "евроцент"
	EUROCENTGRAM="мн|евроцент|евроцента|евроценту|евроцент|евроцентом|евроценте|евроценты|евроцентов|евроцентам|евроценты|евроцентами|центах"
	class << self
	private
		def get_grammar(order, plural, casus)
			if order == 0 then
				@usergram[plural][casus]
			elsif order == 1  then
				ORDWORD[order] + THOU_ENDING[plural][casus]
			else
				ORDWORD[order] + MILLI_ENDING[plural][casus]
			end
		end
		
		def get_order(n)
			order=1
			order+=1 until n < 10 ** (3*order)
			order-1
		end
		
		def set_grammar(grammar)
			@gender=0
			@animate=false
			@usergram = [["","","","","",""],["","","","","",""]]
			t_ar=grammar.to_s.split("|")
			return if t_ar.empty?
			t_ar[0].downcase.each_char do |c|
				case c
					when "м" then
						@gender=0
					when "ж" then
						@gender=1
					when "с" then
						@gender=2
					when "н"
						@animate=false
					when "о"
						@animate=true
					else
						raise ArgumentError, %Q/Invalid grammar specified "#{s}"/, caller
				end
			end
			0.upto(1) do |i|
				0.upto(5) do |j|
					c_gr=t_ar[6*i + j + 1]
					@usergram[i][j] =  c_gr ? c_gr : ""
				end
			end
		end
		
		def get_tail(n, casus, animate, order)
			return get_grammar(order,1,1) if n.zero?
			t_n=n
			tail=get_grammar(order,1, casus == 0 || casus == 3 ? 1 : casus )
			t_n = t_n%100
			t_n = t_n%10 if t_n >= 20
			return tail if t_n == 0 || t_n >= 10
			if t_n == 1 then
				tail=get_grammar(order,0,casus)
			elsif ( t_n >=2 && t_n <=4 ) && ( casus == 0 || casus == 3 ) then
				tail = get_grammar(order, animate && casus == 3 ? 1 : 0 , 1 )
			else
				tail = get_grammar(order, 1, casus == 0 || casus == 3 ? 1 : casus)
			end
			tail
		end
		
		def milli(n, casus, gender, animate, order)
			t_n=n
			if order != 0 then
				t_gender=(order == 1 ? 1 : 0)
				t_animate=false
			else
				t_gender=gender
				t_animate=animate
			end
			tail=get_tail(t_n,casus,t_animate,order)
			return ONES[0][casus] + " " + tail if t_n.zero?
			t_str=""
			if t_n >= 100 then
				t_str+=HUNDREDS[t_n/100][casus]
				t_n=t_n%100
			end
			if t_n >=20 then
				t_str << " " if not t_str.empty?
				t_str << TWENTIES[t_n/10][casus]
				t_n = t_n%10
			end
			if t_n >=10 then
				t_str << " " if not t_str.empty?
				t_str << TEENS[t_n%10] + TEENCASES[casus]
				t_n = 0
			end
			return t_str + " " + tail if t_n == 0
			t_str << " " if not t_str.empty?
			if t_n == 1 then
				if t_animate && casus == 3 then
					t_str << (t_gender == 0 ? ONES[1][1] : ONES1[t_gender][3])
				else
					t_str << (t_gender == 0 ? ONES[1][casus] : ONES1[t_gender][casus])
				end
			elsif t_n == 2 then
				if t_animate && casus == 3 then
					t_str << (t_gender == 0 ? ONES[2][1] : ONES2[t_gender][1])
				else
					t_str << (t_gender == 0 ? ONES[2][casus] : ONES2[t_gender][casus])
				end
			elsif t_animate && t_n <=4 && casus == 3 then
				t_str << ONES[t_n][1]
			else
				t_str << ONES[t_n][casus]		
			end
			t_str << " " + tail
		end
		
		def get_ending(n, animate, gender, casus)
			if ( animate || gender == 1 ) && casus == 3 then
				return  n == 3 ? ACCUSATIVE3[gender] : ACCUSATIVE[gender]
			end
			case n
				when 0,2,6,7,8 then
					return ENDING02678[gender][casus]
				when 1,4,5,9 then
					return ENDING1459[gender][casus]
				when 3
					return ENDING3[gender][casus]
			end
		end
		
		def first_ordinal(n, animate, gender, casus )
			return "" if n.zero?
			t_str=""
			digit=n/100
			if digit.nonzero? then
				if (n%100).zero? then
					if digit > 1 then
						t_str=ONES[digit][1]
					end
					return t_str + "сот" + get_ending(1,animate,gender,casus)
				end
				t_str=HUNDREDS[digit][0] + " "
			end
			digit=(n%100)/10
			return t_str + TEENS[n%10] + get_ending(1,animate,gender,casus) if digit == 1
			if digit !=0 then
				if (n%10).zero? then
					return t_str + TIES[digit] + (digit == 4 ? get_ending(0,animate,gender,casus) : get_ending(1,animate,gender,casus))
				else
					t_str << TWENTIES[digit][0] + " "
				end
			end
			digit=n%10
			t_str + ORDINALS[digit] + get_ending(digit,animate,gender,casus)
		end
		
		def second_ordinal(n,order,animate, gender, casus )
			return "" if n.zero?
			t_str=""
			if n != 1 then
				digit=n/100
				if digit.nonzero? then
					if digit == 1 
						t_str= (n%100).zero? ? "сто" : "ста"
					else
						t_str= ONES[digit][1] + "сот"
					end
				end
				digit=(n%100)/10
				if digit == 1 then
					t_str << TEENS[n%10] + TEENCASES[1]
				else
					t_str << TWENTIES[digit][1] if digit != 0
					digit=n%10
					t_str << COMPOUNDS[digit] if digit != 0
				end
			end
			t_str + ORDWORD[order] + "н" + get_ending(1,animate,gender,casus)
		end
		
		public
		###
		# Преобразует число в количественное числительное
		#
		# @param [Integer] n число для преобразования
		# @param gr_casus [String] падеж числительного
		# @param grammar [String] грамматика
		# @param minorder [Integer]  минимальный порядок тысяч (см. примеры). Если минимальный порядок  < 0, то собственно числительное не выводится
		# @return [String]
		# @raise [ArgumentError]
		# @example
		#    RuNumerals::ru_numeral(154,'д')                       #=> "ста пятидесяти четырём"
		#    RuNumerals::ru_numeral(101,'','с',1)                  #=> "ноль тысяч сто одно"
		#    RuNumerals::ru_numeral(1,'',RuNumerals::RUBGRAM,-1)   #=> "рубль"
		#    RuNumerals::ru_numeral(2,'',RuNumerals::RUBGRAM,-1)   #=> "рубля"
		#
		def ru_numeral(n,gr_casus = "и", grammar = "мн", minorder = 0)
			if not n.kind_of?(Integer) then
				raise ArgumentError, %Q/The number must be Integer. Argument has class "#{n.class}", value "#{n}"/, caller
			end
			gr_casus="и" if gr_casus.nil? || gr_casus.empty?
			minorder=minorder.to_i
			set_grammar(grammar)
			@animate=false if n > 10 and n%10 != 1
			casus=CASUS_STR.index(gr_casus.downcase)
			if not casus
				raise ArgumentError, %Q/The grammatical case must be one of "ирдвтп". Current value of argument is "#{gr_casus}"/, caller
			end
			if n < 0 then
				is_negative=true
				n=-n
			else
				is_negative=false
			end
			order=get_order(n)
			if order > ORDWORD.length then
				raise ArgumentError, %Q/Too big number #{n}. Max number supported is #{10**((ORDWORD.length+1)*3) - 1}/, caller
			end
			triad=0
			return get_tail(n%1000,casus,@animate,0) if minorder < 0
			t_str= is_negative ? "минус " : ""
			[[minorder,ORDWORD.length].min,order].max.downto(0) do |i|
				triad=(n/(10**(3*i)))%1000
				t_str << milli(triad,casus,@gender,@animate,i) + " " if triad.nonzero? || t_str.empty?
			end
			t_str << get_grammar(0,1,1) if triad.zero? && n.nonzero?
			t_str.rstrip
		end
		
		###
		#Преобразует число в порядковое числительное
		#
		# @param [Integer] n число для преобразования
		# @param gr_casus [String] падеж числительного
		# @param grammar [String] грамматика
		# @param plural [true,false] множественное число
		# @return [String]
		# @raise [ArgumentError]
		# @example
		#
		#    RuNumerals::ru_ordinal(1)                 #=> "первый"
		#    RuNumerals::ru_ordinal(2)                 #=> "второй"		
		#    RuNumerals::ru_ordinal(250000000,'в','ж') #=> "двухсотпятидесятимиллионную"
		#    RuNumerals::ru_ordinal(5,'т','ж',true)    #=> "пятыми"
		#    RuNumerals::ru_ordinal(-5,'в','о')        #=> "минус пятого"
		#    
		def ru_ordinal(n, gr_casus = "и", grammar = "мн", plural = false)
			if not n.kind_of?(Integer) then
				raise ArgumentError, %Q/The number must be Integer. Argument has class "#{n.class}", value "#{n}"/, caller
			end
			gr_casus="и" if gr_casus.nil? || gr_casus.empty?
			set_grammar(grammar)
			casus=CASUS_STR.index(gr_casus.downcase)
			if not casus
				raise ArgumentError, %Q/The grammatical case must be one of "ирдвтп". Current value of argument is "#{gr_casus}"/, caller
			end
			if n < 0 then
				is_negative=true
				n=-n
			else
				is_negative=false
			end
			order=get_order(n)
			if order > ORDWORD.length then
				raise ArgumentError, %Q/Too big number #{n}. Max number supported is  #{10**((ORDWORD.length+1)*3) - 1}/, caller
			end
			@gender=3 if plural
			if n.zero? then
				return (ORDINALS[0] + get_ending(0,@animate, @gender, casus) + " " + get_grammar(0, plural ? 1 : 0 , casus)).rstrip
			end
			t_str = first_ordinal(n%1000,@animate,@gender,casus)
			1.upto(get_order(n)) do |i|
				triad=(n/(10**(3*i)))%1000
				if triad.nonzero? then
					if not t_str.empty? then
						t_str = (triad == 1 ? get_grammar(i,0,0) : milli(triad,0,0,false,i)) + " " + t_str
					else
						t_str = second_ordinal(triad, i, @animate, @gender, casus)
					end
				end
			end
			(( is_negative ? "минус " : "" ) + t_str + " " + get_grammar(0, plural ? 1 : 0, casus)).rstrip
		end
		###
		#Преобразует объект класса +Time+ в текстовое представление даты
		#
		# @param [Time] d объект для преобразования
		# @param gr_casus [String] падеж числительного
		# @param [Hash] options опции
		# @option options [true,false] :spelldd (true) преобразовать в числительное число месяца
		# @option options [true,false] :spellyy (true) преобразовать в числительное год
		# @return [String]
		# @raise [ArgumentError]
		# @example
		#
		#    RuNumerals::ru_date(Time.now)                                 #=> "девятое ноября две тысячи шестнадцатого года"
		#    RuNumerals::ru_date(Time.now, "д",spellyy: false)             #=> "девятому ноября 2016 года"
		#    RuNumerals::ru_date(Time.now, spelldd: false, spellyy: false) #=> "9 ноября 2016 года"
		#     
		def ru_date(d, gr_casus="и", **options )
			if not d.kind_of?(Time) then
				raise ArgumentError, %Q/The argument must be Time class. Argument has class "#{d.class}", value "#{d}"/, caller
			end
			spelldd=true
			spellyy=true
			options.each do |k,v|
				case k
					when :spelldd then spelldd=v
					when :spellyy then spellyy=v
					else raise ArgumentError, %Q/Invalid option key #{k} value "#{v}"/, caller
				end
			end
			if spelldd then
				day_part=ru_ordinal(d.day,gr_casus,"с")
			else
				day_part=d.day.to_s
			end
			day_part + " " + MONTAB[d.mon-1] + " " + (spellyy ? ru_ordinal(d.year,"р",YEARGRAM) : (d.year.to_s + " года"))
		end
		###
		#Преобразует объект класса +Time+ в текстовое представление времени
		#
		# @param [Time] d объект для преобразования
		# @param gr_casus [String] падеж числительного
		# @param [Hash] options опции
		# @option options [true,false] :spellhh (true) преобразовать в числительное часы
		# @option options [true,false] :spellmm (true) преобразовать в числительное минуты
		# @option options [true,false] :spellss (true) преобразовать в числительное секунды
		# @option options [true,false] :seconds (true) показывать секунды
		# @return [String]
		# @raise [ArgumentError]
		# @example
		#
		#    RuNumerals::ru_time(Time.now)                                      
		#            #=> "восемнадцать часов пятьдесят две минуты двадцать секунд"
		#    RuNumerals::ru_time(Time.now,"д",spellhh: false , spellmm: false , spellss: false)
		#            #=> "18 часам 52 минутам 20 секундам"
		#    RuNumerals::ru_time(Time.now,'',spellhh: false , spellmm: false , noseconds: false)
		#            #=> "18 часов 52 минуты"
		#    
		def ru_time(d, gr_casus="и", **options)
			if not d.kind_of?(Time) then
				raise ArgumentError, %Q/The argument must be Time class. Argument has class "#{d.class}", value "#{d}"/, caller
			end
			spellhh=true
			spellmm=true
			spellss=true
			seconds=true
			options.each do |k,v|
				case k
					when :spellhh then spellhh=v
					when :spellmm then spellmm=v
					when :spellss then spellss=v
					when :seconds then seconds=v
					else raise ArgumentError, %Q/Invalid option key #{k} value "#{v}"/, caller
				end
			end
			(spellhh ? ru_numeral(d.hour, gr_casus, HOURGRAM ) : (d.hour.to_s + " " + ru_numeral(d.hour, gr_casus, HOURGRAM, -1 ))) + " " + 
			(spellmm ? ru_numeral(d.min, gr_casus, MINGRAM ) : (d.min.to_s + " "+ ru_numeral(d.min, gr_casus, MINGRAM, -1 ))) + 
			(seconds ?  ( " " + (spellss ? ru_numeral(d.sec, gr_casus, SECGRAM ) : (d.sec.to_s + " " + ru_numeral(d.sec, gr_casus, SECGRAM, -1 )))) : "")
		end
		###
		#Преобразует число в текстовое представление денежной суммы
		#
		# @param [Integer,Float] n объект для преобразования
		# @param gr_casus [String] падеж числительного
		# @param rub_gram [String] грамматика "рублей", если nil или "", то выводятся только "копейки" со значением n*100
		# @param kop_gram [String] грамматика "копеек", если nil или "", то "копейки" не выводятся и их значение отбрасывается
		# @param [Hash] options опции
		# @option options [true,false] :spellrub (true) преобразовать в числительное число "рублей"
		# @option options [true,false] :spellkop (true) преобразовать в числительное число "копеек", значение выводится в формате "%02d"
		# @return [String]
		# @raise [ArgumentError]
		# @example
		#
		#    RuNumerals::ru_money(123.029,"и",RuNumerals::RUBGRAM,RuNumerals::KOPGRAM)
		#             #=> "сто двадцать три рубля три копейки"
		#    RuNumerals::ru_money(123.029,"р",RuNumerals::RUBGRAM,RuNumerals::KOPGRAM, spellkop: false)
		#             #=> "ста двадцати трёх рублей 03 копеек"
		#    RuNumerals::ru_money(123.029,"т",nil,RuNumerals::KOPGRAM)
		#             #=> "двенадцатью тысячами тремястами тремя копейками"
		#    
		def ru_money(n,gr_casus,rub_gram, kop_gram, **options)
			if not (n.kind_of?(Integer) || n.kind_of?(Float)) then
				raise ArgumentError, %Q/The number must be Integer or Float. Argument has class "#{n.class}", value "#{n}"/, caller
			end
			n=n.to_f
			spellrub=true
			spellkop=true
			options.each do |k,v|
				case k
					when :spellrub then spellrub=v
					when :spellkop then spellkop=v
					else raise ArgumentError, %Q/Invalid option key #{k} value "#{v}"/, caller
				end
			end
			if (rub_gram.nil? || rub_gram.empty?) && (kop_gram.nil? || kop_gram.empty? ) then
				raise ArgumentError, %Q/Both grammars are nil/, caller
			end
			if rub_gram.nil? || rub_gram.empty? then
				kops=(n*100).round
				if spellkop then
					return ru_numeral(kops,gr_casus,kop_gram)
				else
					return kops.to_s + " " + ru_numeral(kops,gr_casus,kop_gram,-1)
				end
			end
			rubs=n.truncate
			kops=((n*100)%100).round
			if spellrub then
				rub_s=ru_numeral(rubs,gr_casus,rub_gram)
			else
				rub_s=rubs.to_s + " " + ru_numeral(rubs,gr_casus,rub_gram,-1)
			end
			return rub_s if ( kop_gram.nil? || kop_gram.empty? )
			if spellkop then
				kop_s=ru_numeral(kops,gr_casus,kop_gram)
			else
				kop_s=("%02d" % kops.to_s) + " " + ru_numeral(kops,gr_casus,kop_gram,-1)
			end
			rub_s + " " + kop_s
		end
		###
		#Преобразует дробное число в его текстовое представление
		#
		# @param [Rational, Float, Integer] n объект для преобразования
		# @param gr_casus [String] падеж числительного
		# @param grammar [String] грамматика
		# @param [Hash] options опции
		# @option options [true,false] :improper (false) не преобразовать в правильную дробь
		# @return [String]
		# @raise [ArgumentError]
		# Если знаменатель равен единице (аргумент типа +Integer+ как частный случай),
		# то результатом будет количественное числительное (будет осуществлен вызов ru_numeral)
		#
		# @example
		#
		#    RuNumerals::ru_fractional(Rational(8,7))                   #=> "одна целая одна седьмая"
		#    RuNumerals::ru_fractional(Rational(8,7),"",improper: true) #=> "восемь седьмых"
		#    RuNumerals::ru_fractional(Rational(8,7),improper: true)    #=> "восемь седьмых"
		#    RuNumerals::ru_fractional(Rational(6,2),"т")               #=> "тремя"
		#    RuNumerals::ru_fractional(1001.02)                         #=> "одна тысяча одна целая две сотых"
		#    
		def ru_fractional(n,gr_casus="и",grammar=nil, **options)
			improper=false
			options.each do |k,v|
				case k
					when :improper then improper=v
					else raise ArgumentError, %Q/Invalid option key #{k} value "#{v}"/, caller
				end
			end
			if n.kind_of?(Integer) then
				numer=n
				denom=1
			elsif n.kind_of?(Float) then
				m=n.to_s.match('([-+]?[0-9]+)\.([0-9]+)([eE]([-+][0-9]+))?')
				numer=(m[1] + m[2]).to_i
				denom_order=(m[2].length - (m[3].nil? ? 0 : m[4].to_i))
				while denom_order < 0
					numer*=10
					denom_order+=1
				end
				while numer%10 == 0 && denom_order > 0
					numer/=10
					denom_order-=1
				end
				denom=10**denom_order
			elsif n.kind_of?(Rational) then
				numer=n.numerator
				denom=n.denominator
			else
				raise ArgumentError, %Q/The number must be one of Rational, Float or Integer. Argument has class "#{n.class}", value "#{n}"/, caller
			end
			if denom == 1 then
				return ru_numeral(numer, gr_casus, grammar)
			end
			if (not improper) && numer.abs >= denom then
				t_str=ru_numeral((numer < 0 ? -(numer.abs/denom) : numer/denom),gr_casus,WHOLEGRAM)
				numer=numer.abs%denom
			else
				t_str=""
			end
			if not numer.zero? then
				t_str << " " if not t_str.empty?
				t_str << ru_numeral(numer,gr_casus,"ж") + " "
				if numer%10 == 1 then
					t_str << ru_ordinal(denom,gr_casus,"ж")
				elsif	gr_casus == "и" then
					t_str << ru_ordinal(denom,"р","ж",true)
				else
					t_str << ru_ordinal(denom,gr_casus,"ж",true)
				end
			end
			t_str	+ (grammar.nil? ? "" : (" " + ru_numeral(1,"р",grammar,-1)))
		end
		###
		#Преобразует число в текстовое представление денежной суммы в рублях. Дробная часть отбрасываются.
		# @param [Integer,Float] n объект для преобразования
		# @param gr_casus [String] падеж числительного
		# @param [Hash] options опции
		# @option options [true,false] :spellrub (true) преобразовать в числительное число рублей
		# @return [String]
		# @raise [ArgumentError]
		# @example
		#
		#    RuNumerals::ru_rubles(2123.29)           #=> "две тысячи сто двадцать три рубля"
		#    RuNumerals::ru_rubles(3,"т", spellrub: false) #=> "3 рублями"
		#    
		def ru_rubles(n,gr_casus="и",**options)
			ru_money(n,gr_casus,RUBGRAM,nil,options)
		end
		###
		#Преобразует число в текстовое представление денежной суммы в копейках (n*100)
		# @param [Integer,Float] n объект для преобразования
		# @param gr_casus [String] падеж числительного
		# @param [Hash] options опции
		# @option options [true,false] :spellkop (true) преобразовать в числительное число копеек, значение выводится в формате "%02d"
		# @return [String]
		# @raise [ArgumentError]
		# @example
		#
		#    RuNumerals::ru_kopecks(2123.29)           #=> "двести двенадцать тысяч триста двадцать девять копеек"
		#    RuNumerals::ru_kopecks(3,"т",spellkop: false) #=> "300 копейками"
		#    
		def ru_kopecks(n,gr_casus="и",**options)
			ru_money(n,gr_casus,nil,KOPGRAM,options)
		end
		###
		#Преобразует число в текстовое представление денежной суммы в рублях и копейках
		# @param [Integer,Float] n объект для преобразования
		# @param gr_casus [String] падеж числительного
		# @param [Hash] options опции
		# @option options [true,false] :spellrub (true) преобразовать в числительное число рублей
		# @option options [true,false] :spellkop (true) преобразовать в числительное число копеек, значение выводится в формате "%02d"
		# @return [String]
		# @raise [ArgumentError]
		# @example
		#
		#    RuNumerals::ru_rubleskopecks(2123.29)           #=> "две тысячи сто двадцать три рубля двадцать девять копеек"
		#    RuNumerals::ru_rubleskopecks(3,"т",spellkop: false) #=> "тремя рублями 00 копеек"
		#    
		def ru_rubleskopecks(n,gr_casus="и",**options)
			ru_money(n,gr_casus,RUBGRAM,KOPGRAM,options)
		end
		###
		#Преобразует число в текстовое представление денежной суммы в долларах. Дробная часть отбрасываются.
		# @param [Integer,Float] n объект для преобразования
		# @param gr_casus [String] падеж числительного
		# @param [Hash] options опции
		# @option options [true,false] :spellrub (true) преобразовать в числительное число долларов
		# @return [String]
		# @raise [ArgumentError]
		# @example
		#
		#    RuNumerals::ru_dollars(2123.29)           #=> "две тысячи сто двадцать три доллара"
		#    RuNumerals::ru_dollars(3,"т",spellrub: false) #=> "3 долларами"
		#    
		def ru_dollars(n,gr_casus="и",**options)
			ru_money(n,gr_casus,DOLLARGRAM,nil,options)
		end
		###
		#Преобразует число в текстовое представление денежной суммы в центах (n*100)
		# @param [Integer,Float] n объект для преобразования
		# @param gr_casus [String] падеж числительного
		# @param [Hash] options опции
		# @option options [true,false] :spellkop (true) преобразовать в числительное число центов, значение выводится в формате "%02d"
		# @return [String]
		# @raise [ArgumentError]
		# @example
		#
		#    RuNumerals::ru_cents(2123.29)           #=> "двести двенадцать тысяч триста двадцать девять центов"
		#    RuNumerals::ru_cents(3,"т",spellkop: false) #=> "300 центами"
		#    
		def ru_cents(n,gr_casus="и",**options)
			ru_money(n,gr_casus,nil,CENTGRAM,options)
		end
		###
		#Преобразует число в текстовое представление денежной суммы в долларах и центах
		# @param [Integer,Float] n объект для преобразования
		# @param gr_casus [String] падеж числительного
		# @param [Hash] options опции
		# @option options [true,false] :spellrub (true) преобразовать в числительное число долларов
		# @option options [true,false] :spellkop (true) преобразовать в числительное число центов, значение выводится в формате "%02d"
		# @return [String]
		# @raise [ArgumentError]
		# @example
		#
		#    RuNumerals::ru_dollarscents(2123.29)           #=> "две тысячи сто двадцать три доллара двадцать девять центов"
		#    RuNumerals::ru_dollarscents(3,"т",spellkop: false) #=> "тремя долларами 00 центов"
		#    
		def ru_dollarscents(n,gr_casus="и",**options)
			ru_money(n,gr_casus,DOLLARGRAM,CENTGRAM,options)
		end
		###
		#Преобразует число в текстовое представление денежной суммы в евро. Дробная часть отбрасываются.
		# @param [Integer,Float] n объект для преобразования
		# @param gr_casus [String] падеж числительного
		# @param [Hash] options опции
		# @option options [true,false] :spellrub (true) преобразовать в числительное число евро
		# @return [String]
		# @raise [ArgumentError]
		# @example
		#
		#    RuNumerals::ru_euros(2123.29)           #=> "две тысячи сто двадцать три евро"
		#    RuNumerals::ru_euros(3,"т",spellrub: false) #=> "3 евро"
		#    
		def ru_euros(n,gr_casus="и",**options)
			ru_money(n,gr_casus,EUROGRAM,nil,options)
		end
		###
		#Преобразует число в текстовое представление денежной суммы в евроцентах (n*100)
		# @param [Integer,Float] n объект для преобразования
		# @param gr_casus [String] падеж числительного
		# @param [Hash] options опции
		# @option options [true,false] :spellkop (true) преобразовать в числительное число евроцентов, значение выводится в формате "%02d"
		# @return [String]
		# @raise [ArgumentError]
		# @example
		#
		#    RuNumerals::ru_eurocents(2123.29)           #=> "двести двенадцать тысяч триста двадцать девять евроцентов"
		#    RuNumerals::ru_eurocents(3,"т",spellkop: false) #=> "300 евроцентами"
		#    
		def ru_eurocents(n,gr_casus="и",**options)
			ru_money(n,gr_casus,nil,EUROCENTGRAM,options)
		end
		###
		#Преобразует число в текстовое представление денежной суммы в евро и евроцентах
		# @param [Integer,Float] n объект для преобразования
		# @param gr_casus [String] падеж числительного
		# @param [Hash] options опции
		# @option options [true,false] :spellrub (true) преобразовать в числительное число евро
		# @option options [true,false] :spellkop (true) преобразовать в числительное число евроцентов, значение выводится в формате "%02d"
		# @return [String]
		# @raise [ArgumentError]
		# @example
		#
		#    RuNumerals::ru_euroseurocents(2123.29)           #=> "две тысячи сто двадцать три евро двадцать девять евроцентов"
		#    RuNumerals::ru_euroseurocents(3,"т",spellkop: false) #=> "тремя долларами 00 евроцентов"
		#    
		def ru_euroseurocents(n,gr_casus="и",**options)
			ru_money(n,gr_casus,EUROGRAM,EUROCENTGRAM,options)
		end
		###
		#Добавляет метод или методы RuNumerals классу.
		# @param [Class] cls объект для преобразования
		# @param [Array] methods методы
		#    - :ru_numeral (+Symbol+) - добавить метод ru_numeral (только для +Integer+)
		#    - :ru_ordinal (+Symbol+) - добавить метод ru_ordinal (только для +Integer+)
		#    - :ru_date (+Symbol+) - добавить метод ru_date (только для +Time+)
		#    - :ru_time (+Symbol+) - добавить метод ru_time (только для +Time+)
		#    - :ru_fractional (+Symbol+) - добавить метод ru_fractional (только для +Float+ и +Rational+)
		#    - :ru_money (+Symbol+) - добавить метод ru_money (только для +Float+)
		#    - :ru_rubles (+Symbol+) - добавить метод ru_rubles (только для +Float+)
		#    - :ru_kopecks (+Symbol+) - добавить метод ru_kopecks (только для +Float+)
		#    - :ru_rubleskopecks (+Symbol+) - добавить метод ru_rubleskopecks (только для +Float+)
		#    - :ru_dollars (+Symbol+) - добавить метод ru_dollars (только для +Float+)
		#    - :ru_cents (+Symbol+) - добавить метод ru_cents (только для +Float+)
		#    - :ru_dollarscents (+Symbol+) - добавить метод ru_dollarscents (только для +Float+)
		#    - :ru_euros (+Symbol+) - добавить метод ru_euros (только для +Float+)
		#    - :ru_eurocents (+Symbol+) - добавить метод ru_eurocents (только для +Float+)
		#    - :ru_euroseurocents (+Symbol+) - добавить метод ru_euroseurocents (только для +Float+)
		#
		#Если опции не указаны, то классу добавляются все подходящие функции.
		# @return [nil]
		# @raise [ArgumentError]
		# @example
		#
		#    RuNumerals::extend(Integer)                 #=> nil
		#    1.ru_numeral                                #=> "один"
		#    1.ru_ordinal("д")                           #=> "первому"
		#    RuNumerals::extend(Float,:ru_rubleskopecks) #=> nil
		#    1.25.ru_rubleskopecks("и",:nospellkop)      #=> "один рубль 25 копеек"
		#
		def extend(cls,*methods)
			if ( cls.class != Class ) then
				raise ArgumentError, %Q/Argument must be Class, current argument class is "#{cls.Class}, "/, caller
			end
			if not EXTEND_MAP.keys.include?(cls) then
				raise ArgumentError, %Q/Class "#{cls}" is not supported/, caller
			end
			if methods.nil? or methods.empty? then
				all_methods=true
			else
				all_methods=false
				methods.each do |i|
					if not EXTEND_MAP[cls].include?(i) then
						raise ArgumentError, %Q/Method "#{i}" is not supported for class "#{cls}"/, caller
					end
				end
			end
			methods_to_ext= (all_methods ? EXTEND_MAP[cls] : methods)
			methods_to_ext.each do |i|
				case i 
					when :ru_numeral then
						cls.send(:define_method,i) do |gr_casus='и', grammar='мн', min_order=0|
							RuNumerals::ru_numeral(self, gr_casus, grammar, min_order)
						end
					when :ru_ordinal then
						cls.send(:define_method,i) do |gr_casus='и', grammar='мн', plural=false|
							RuNumerals::ru_ordinal(self, gr_casus, grammar, plural)
						end
					when :ru_money then
						cls.send(:define_method,i) do |gr_casus='и', r_gram=nil,k_gram=nil, **opts|
							RuNumerals::ru_money(self, gr_casus,r_gram,k_gram,opts)
						end
					when :ru_date then
						cls.send(:define_method,i) do |gr_casus='и', **opts|
							RuNumerals::ru_date(self, gr_casus, opts)
						end						
					when :ru_time then
						cls.send(:define_method,i) do |gr_casus='и', **opts|
							RuNumerals::ru_time(self, gr_casus, opts)
						end						
					when :ru_rubles then
						cls.send(:define_method,i) do |gr_casus='и', **opts|
							RuNumerals::ru_rubles(self, gr_casus, opts)
						end						
					when :ru_kopecks then
						cls.send(:define_method,i) do |gr_casus='и', **opts|
							RuNumerals::ru_kopecks(self, gr_casus, opts)
						end						
					when :ru_rubleskopecks then
						cls.send(:define_method,i) do |gr_casus='и', **opts|
							RuNumerals::ru_rubleskopecks(self, gr_casus, opts)
						end						
					when :ru_dollars then
						cls.send(:define_method,i) do |gr_casus='и', **opts|
							RuNumerals::ru_dollars(self, gr_casus, opts)
						end						
					when :ru_cents
						cls.send(:define_method,i) do |gr_casus='и', **opts|
							RuNumerals::ru_cents(self, gr_casus, opts)
						end						
					when :ru_dollarscents then
						cls.send(:define_method,i) do |gr_casus='и', **opts|
							RuNumerals::ru_dollarscents(self, gr_casus, opts)
						end						
					when :ru_euros then
						cls.send(:define_method,i) do |gr_casus='и', **opts|
							RuNumerals::ru_euros(self, gr_casus, opts)
						end						
					when :ru_eurocents then
						cls.send(:define_method,i) do |gr_casus='и', **opts|
							RuNumerals::ru_eurocents(self, gr_casus, opts)
						end						
					when :ru_euroseurocents then
						cls.send(:define_method,i) do |gr_casus='и', **opts|
							RuNumerals::ru_euroseurocents(self, gr_casus, opts)
						end						
					when :ru_fractional then
						cls.send(:define_method,i) do |gr_casus='и', grammar=nil, **opts|
							RuNumerals::ru_fractional(self, gr_casus, grammar, opts)
						end						
				end
			end
			nil
		end
	end
end