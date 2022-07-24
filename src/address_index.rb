# frozen_string_literal: true

require 'csv'
require_relative './ken_all'
require_relative './postal_record'

# N-Gram 作成
class String
  def to_ngram(n_str)
    each_char
      .each_cons(n_str)
      .map(&:join)
      .uniq # 重複を除去（例：京都府京都市 -> "京都"インデックスは１つ）
  end
end

# 住所レコードのインデックスファイルを扱うクラス
class AddressIndex
  attr_reader :csv_path

  def initialize
    @folder_path = 'data'
    @csv_file_name = 'address_indexes.csv'
    @csv_path = File.expand_path("../#{@folder_path}/#{@csv_file_name}", __dir__)
    @batch_size = 100 # メモリリークを避けるために、一度に読み込む CSV 行数を制御
  end

  # インデックス再構築（作成 & 上書き保存）
  def rebuild
    puts 'インデックスファイルを再構築します'
    save(create)
  end

  # インデックス作成
  # TODO: 郵便番号の重複処理（例：4980000）　※全国地方公共団体コードと複合キーで検索する？
  # TODO: 複数行に分割されるレコード処理（例：0330072）　※（ が始まり ）で終わるまでが分割されたレコードと判定する
  def create
    puts 'インデックスファイルを作成します'
    idxs = Hash.new { |h, k| h[k] = [] }
    CSV.foreach(KenAll.new.read, encoding: 'SJIS:UTF-8').each_slice(@batch_size) do |rows|
      rows.each.with_index(1) do |row, idx|
        # 住所をバイグラムで分割
        PostalRecord.new(row).address.to_ngram(2).each do |ngram|
          idxs[ngram].push(idx)
        end
      end
    end
    idxs
  end

  # インデックス上書き保存
  def save(idxs)
    puts 'インデックスファイルを上書き保存します'
    CSV.open(@csv_path, 'w') do |csv|
      idxs.each do |key, values|
        row = [key]
        values.each do |value|
          row.push(value)
        end
        csv << row
      end
    end
  end

  # インデックス取得
  def read
    puts 'インデックスファイルを取得します'
    # インデックスファイルが存在しない場合は作成
    rebuild unless FileTest.exist?(@csv_path)
    idxs = Hash.new { |h, k| h[k] = [] }
    CSV.foreach(@csv_path) do |row|
      # 1列目はキー、2列目以降は値
      row[1..].each do |idx|
        idxs[row[0]].push(idx.to_i) # インデックスは数値に変換
      end
    end
    idxs
  end

  # インデックスを用いて検索
  def search(query)
    puts 'インデックスを用いて検索します'
    idxs = read
    p idxs
    CSV.foreach(KenAll.new.csv_path, encoding: 'SJIS:UTF-8').each_slice(@batch_size) do |rows|
      rows.each.with_index(1) do |row, idx|
        p row if idxs[query].include?(idx)
      end
    end
  end
end
