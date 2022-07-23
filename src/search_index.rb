require 'csv' # csvライブラリを読み込み
require 'kconv' # 日本語文字コードの変換を手軽に行うためのライブラリ

# メモリリークを避けるために、一度に読み込む CSV 行数を定義
BATCH_SIZE = 100
DATA_PATH = File.expand_path('../data/KEN_ALL_PART.CSV', __dir__)

# N-Gram 作成
class String
  def to_ngram(n)
    each_char
      .each_cons(n)
      .map(&:join)
  end
end

def search_index(word)
  # インデックス作成
  index = Hash.new { |h, k| h[k] = [] }
  CSV.foreach(DATA_PATH, encoding: 'SJIS:UTF-8').each_slice(BATCH_SIZE) do |rows|
    rows.each do |row|
      postal_code = row[2]
      address = "#{row[6]}#{row[7]}#{row[8]}"
      # 住所をバイグラムで分割
      address.to_ngram(2).each do |ngram|
        index[ngram] << postal_code
      end
    end
  end

  # クエリ
  # TODO: 三文字以上のクエリを指定できるようにする
  query = word

  # 検索
  # メモリリークを避けるため、全量をメモリにのせず、地道に検索する
  CSV.foreach(DATA_PATH, encoding: 'SJIS:UTF-8').each_slice(BATCH_SIZE) do |rows|
    rows.each do |row|
      p row if index[query].include?(row[2])
    end
  end
end

# 関数実行
search_index('京都')
