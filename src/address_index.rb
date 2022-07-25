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
      # OPTIMIZE: uniq は最後にまとめて実施する？
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
  end

  # インデックス再構築（作成 & 上書き保存）
  def rebuild
    puts 'インデックスファイルを再構築します'
    save(create)
  end

  # インデックス作成
  # OPTIMIZE: 多重登録 かつ マージ判定ごとに uniq! で処理が遅い
  def create
    puts 'インデックスファイルを作成します'
    idxs = Hash.new { |h, k| h[k] = [] }
    merge_hash = Hash.new { |h, k| h[k] = [] }
    CSV.foreach(KenAll.new.read, encoding: 'SJIS:UTF-8').each_with_index do |row, idx|
      postal_obj = PostalRecord.new(row)

      # 各レコードの住所をそのままバイグラムで分割してインデックスに追加
      postal_obj.address.to_ngram(2).each do |ngram|
        idxs[ngram].push(idx)
      end

      # マージ判定処理
      if merge_hash.empty?
        merge_hash['idx'] = [idx]
        merge_hash['obj'] = postal_obj
      elsif merge_hash['obj'].postal_code == postal_obj.postal_code
        merge_hash['idx'].push(idx)
        merge_hash['obj'].town.concat(postal_obj.town)
      else
        # マージ後の住所をバイグラムで分割してインデックスに追加（多重登録は uniq! で除去）
        merge_hash['obj'].address.to_ngram(2).each do |ngram|
          idxs[ngram].concat(merge_hash['idx']).uniq!
        end
        # クリア処理
        merge_hash.clear
        merge_hash['idx'] = [idx]
        merge_hash['obj'] = postal_obj
      end
      # p merge_hash
    end
    # p idxs
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
      idxs.store(row[0], row[1..row.length - 1].map(&:to_i))
    end
    idxs
  end

  # インデックスを用いて検索
  def search(query)
    puts 'インデックスを用いて検索します'
    idxs = read
    # p idxs
    # クエリを 2 文字に分解してインデックス番号を AND 検索
    # FIXME: "京都府あああ" で検索すると "京都府" で検索される？
    match_idxs = idxs
                 .slice(*query.to_ngram(2))                                          # クエリに合致するインデックスのみ抽出
                 .values                                                             # Hash -> Array 変換
                 .reduce([]) { |acc, arr| acc.empty? ? acc.concat(arr) : acc & arr } # AND 検索（例：東京都 -> "東京" AND "京都"）
    # p match_idxs
    # 検索条件に合致するインデックス番号の住所を表示
    File.foreach(KenAll.new.csv_path, encoding: 'SJIS:UTF-8').with_index do |line, idx|
      puts line if match_idxs.include?(idx)
    end
  end
end
