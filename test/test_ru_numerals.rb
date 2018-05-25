# encoding: UTF-8
require "test/unit"
require_relative "../lib/ru_numerals.rb"

MUZHI_GRAM="мо|мужик|мужика|мужику|мужика|мужиком|мужике|мужики|мужиков|мужикам|мужиков|мужиками|мужиках"
DEV_GRAM="жо|девушка|девушки|девушке|девушку|девушкой|девушке|девушки|девушек|девушкам|девушек|девушками|девушках"

=begin
1000000.upto(1000025) { |i| puts RuNumerals.ru_numeral(i,'в',DEV_GRAM)}
=end
class Test_RuNumerals < Test::Unit::TestCase
	def test_ru_numeral
		assert_raises(ArgumentError) {RuNumerals::ru_numeral('0')}
		assert_equal('ноль',RuNumerals::ru_numeral(0))
		assert_equal('ноль тысяч сто одно',RuNumerals::ru_numeral(101,'','с',1))
		assert_equal('рубля',RuNumerals::ru_numeral(2,'',RuNumerals::RUBGRAM,-1))
		assert_equal('трёх',RuNumerals::ru_numeral(3,'в','мо'))
		assert_equal('двадцать три',RuNumerals::ru_numeral(23,'в','мо'))
		assert_equal('один',RuNumerals::ru_numeral(1,'в','мн'))
		assert_equal('одного',RuNumerals::ru_numeral(1,'в','мо'))
		assert_equal('двух',RuNumerals::ru_numeral(2,'в','мо'))
		assert_equal('трёх',RuNumerals::ru_numeral(3,'в','мо'))
		assert_equal('двадцать одного',RuNumerals::ru_numeral(21,'в','мо'))
		assert_equal('двадцать два',RuNumerals::ru_numeral(22,'в','мн'))
		assert_equal('одну',RuNumerals::ru_numeral(1,'в','жо'))
		assert_equal('двух',RuNumerals::ru_numeral(2,'в','жо'))
		assert_equal('трёх',RuNumerals::ru_numeral(3,'в','жо'))
		assert_equal('двадцать одну',RuNumerals::ru_numeral(21,'в','жн'))
		assert_equal('двадцать две',RuNumerals::ru_numeral(22,'в','жн'))
	end
	
	def test_ru_ordinal
		assert_raises(ArgumentError) {RuNumerals::ru_ordinal('0')}
		assert_equal('нулевой',RuNumerals::ru_ordinal(0))
		assert_equal('первого',RuNumerals::ru_ordinal(1,'в','мо'))
		assert_equal('второго',RuNumerals::ru_ordinal(2,'в','мо'))
		assert_equal('третьих',RuNumerals::ru_ordinal(3,'в','мо',true))
		assert_equal('первый',RuNumerals::ru_ordinal(1,'в','м'))
		assert_equal('второй',RuNumerals::ru_ordinal(2,'в','м'))
		assert_equal('третьи',RuNumerals::ru_ordinal(3,'в','м',true))
	end
	
	def test_ru_date
		assert_raises(ArgumentError) {RuNumerals::ru_date('0')}
		assert_equal('первое февраля две тысячи двенадцатого года',RuNumerals::ru_date(Time.new(2012,2,1)))
		assert_equal('1 февраля две тысячи двенадцатого года',RuNumerals::ru_date(Time.new(2012,2,1), spelldd: false))
		assert_equal('1 февраля 2012 года',RuNumerals::ru_date(Time.new(2012,2,1), spelldd: false, spellyy: false))
	end
	
	def test_ru_time
		assert_raises(ArgumentError) {RuNumerals::ru_time('0')}
		assert_equal('два часа одна минута десять секунд',RuNumerals::ru_time(Time.new(2012,2,1,2,1,10)))
		assert_equal('2 часа одна минута десять секунд',RuNumerals::ru_time(Time.new(2012,2,1,2,1,10),spellhh: false))
		assert_equal('2 часами 1 минутой',RuNumerals::ru_time(Time.new(2012,2,1,2,1,10),"т", spellhh: false, spellmm: false, seconds: false))
	end
	
	def test_ru_money
		assert_raises(ArgumentError) {RuNumerals::ru_money('0')}
		assert_equal('один рубль десять копеек',RuNumerals::ru_money(1.10,'',RuNumerals::RUBGRAM,RuNumerals::KOPGRAM))
		assert_equal('одного рубля десяти копеек',RuNumerals::ru_money(1.10,'р',RuNumerals::RUBGRAM,RuNumerals::KOPGRAM))
		assert_equal('ста десяти копейкам',RuNumerals::ru_money(1.10,'д',nil,RuNumerals::KOPGRAM))
		assert_equal('1 рублём',RuNumerals::ru_money(1.10,'т',RuNumerals::RUBGRAM,nil,spellrub: false))
	end
	
	def test_ru_fractional
		assert_raises(ArgumentError) {RuNumerals::ru_fractional('0')}
		assert_equal('семь восьмых',RuNumerals::ru_fractional(Rational(7,8)))
		assert_equal('двумя целыми семью восьмыми',RuNumerals::ru_fractional(Rational(23,8),'т'))
		assert_equal('минус двадцатью тремя восьмыми',RuNumerals::ru_fractional(Rational(-23,8),'т',nil,improper: true))
	end

	def test_extend
		assert_raises(ArgumentError) {RuNumerals::extend(String)}
		RuNumerals::extend(Integer)
		assert_equal('один',1.ru_numeral)
		RuNumerals::extend(Float,:ru_rubleskopecks)
		assert_equal('один рубль 25 копеек',1.25.ru_rubleskopecks("и",spellkop: false))
		RuNumerals::extend(Integer,:ru_numeral,:ru_ordinal)
		assert_equal('одной девушке',1.ru_numeral('д',DEV_GRAM))
		assert_equal('девушке',1.ru_numeral('д',DEV_GRAM,-1))
		RuNumerals::extend(Rational)
		assert_equal('восемь седьмых',Rational(8,7).ru_fractional(improper: true))
	end
end
