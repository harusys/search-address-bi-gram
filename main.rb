# frozen_string_literal: true

require './src/address_index'

address_idx = AddressIndex.new

case ARGV.length
when 0
  address_idx.rebuild
when 1
  address_idx.search(ARGV[0])
else
  puts 'コマンドライン引数は "空" または "検索したい文字列を１つ" を指定してください。'
  puts '例１） Create Index: ruby search_index.rb'
  puts '例２） Search:       ruby search_index.rb 京都'
end
