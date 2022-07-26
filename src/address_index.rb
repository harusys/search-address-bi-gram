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
  def create
    puts 'インデックスファイルを作成します'
    idxs = Hash.new { |h, k| h[k] = [] }
    stash = Hash.new { |h, k| h[k] = [] }
    CSV.foreach(KenAll.new.read, encoding: 'SJIS:UTF-8').each_with_index do |row, idx|
      postal_obj = PostalRecord.new(row)

      # マージ判定後に追加すると最終行レコードを追加できないため、マージ判定前にインデックス追加
      # マージ前の N-gram はマージ後の N-gram に包括されるため、多重登録で問題なし（最後に重複排除しておく）
      postal_obj.address.to_ngram(2).each do |ngram|
        idxs[ngram].push(idx)
      end

      # 前レコード退避
      if stash.empty?
        stash['idx'] = [idx]
        stash['obj'] = postal_obj
      # マージ処理
      elsif stash['obj'].postal_code == postal_obj.postal_code
        stash['idx'].push(idx)
        stash['obj'].town.concat(postal_obj.town)
      # 前レコードと不一致の場合はマージ完了としてインデックスに追加
      else
        stash['obj'].address.to_ngram(2).each do |ngram|
          idxs[ngram].concat(stash['idx'])
        end
        # クリア処理
        stash.clear
        stash['idx'] = [idx]
        stash['obj'] = postal_obj
      end
      # p stash
    end
    # 重複したインデックス番号を排除
    idxs.each_key do |key|
      idxs[key].uniq!
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
    match_idxs = Hash.new { |h, k| h[k] = [] }

    # クエリを 2 文字に分解して、合致するインデックスのみ抽出（合致しない場合は空配列）
    query.to_ngram(2).each do |ngram|
      match_idxs[ngram] = idxs.key?(ngram) ? idxs[ngram] : []
    end

    # 各インデックスの値を積集合
    # AND 検索（例：東京都 -> "東京" AND "京都"）
    match_idxs_arr = match_idxs.values.reduce([]) { |acc, arr| acc.empty? ? acc.concat(arr) : acc & arr }

    # 検索条件に合致するインデックス番号の住所を表示
    count = 0
    File.foreach(KenAll.new.csv_path, encoding: 'SJIS:UTF-8').with_index do |line, idx|
      if match_idxs_arr.include?(idx)
        puts line
        count += 1
      end
    end
    puts "#{count}件ヒットしました"
  end
end
