# frozen_string_literal: true

require 'benchmark'
require './src/address_index'

address_idx = AddressIndex.new

case ARGV.length
when 0
  duration = Benchmark.realtime do
    address_idx.rebuild
  end
  puts "処理時間 #{duration}s"
when 1
  duration = Benchmark.realtime do
    query = ARGV[0].gsub(/(\s|　)+/, '')
    puts "「#{query}」で検索します　※注※ 空白は無視されます"
    address_idx.search(query) # 検索文字列の全角/半角スペースは一律削除
  end
  puts "処理時間 #{duration}s"
else
  puts 'コマンドライン引数は "空" または "検索したい文字列を１つ" を指定してください。'
  puts '例１） Create Index: ruby search_index.rb'
  puts '例２） Search:       ruby search_index.rb "京都"'
end
