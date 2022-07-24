require 'csv' # csvライブラリを読み込み
require 'kconv' # 日本語文字コードの変換を手軽に行うためのライブラリ
require_relative './postal_source'

# メモリリークを避けるために、一度に読み込む CSV 行数を定義
BATCH_SIZE = 100
DATA_PATH = File.expand_path('../data/KEN_ALL_PART.CSV', __dir__)

# N-Gram 作成
class String
  def to_ngram(n_str)
    each_char
      .each_cons(n_str)
      .map(&:join)
      .uniq # 重複を除去（例：京都府京都市 -> "京都"インデックスは１つ）
  end
end

# クエリ
# TODO: 三文字以上のクエリを指定できるようにする
query = ARGV[0]

# パラメータがない or ２つ以上の場合、使用法を表示
if ARGV.size != 1
  puts 'コマンドライン引数に検索したい文字列を１つ指定してください。'
  puts '例）ruby search_index.rb 京都'
  return
end

# インデックス作成
# TODO: 郵便番号の重複処理（例：4980000）　※全国地方公共団体コードと複合キーで検索する？
# TODO: 複数行に分割されるレコード処理（例：0330072）　※（ が始まり ）で終わるまでが分割されたレコードと判定する
index = Hash.new { |h, k| h[k] = [] }
CSV.foreach(DATA_PATH, encoding: 'SJIS:UTF-8').each_slice(BATCH_SIZE) do |rows|
  rows.each.with_index(1) do |row, idx|
    # 住所をバイグラムで分割
    postal_data = PostalSource.new(row)
    postal_data.get_address.to_ngram(2).each do |ngram|
      index[ngram].push(idx)
    end
  end
  puts index
end

# 検索
# メモリリークを避けるため、全量をメモリにのせず、地道に検索する
CSV.foreach(DATA_PATH, encoding: 'SJIS:UTF-8').each_slice(BATCH_SIZE) do |rows|
  rows.each.with_index(1) do |row, idx|
    p row if index[query].include?(idx)
  end
  puts '検索が終了しました'
end
