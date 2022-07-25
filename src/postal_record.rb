# frozen_string_literal: true

# 郵便番号データレコードを扱うクラス
class PostalRecord
  attr_accessor :town
  attr_reader :postal_code

  def initialize(row)
    # 引数チェック
    return unless row.instance_of?(Array)
    return if row.size.zero?

    @jititai_code = row[0]
    @postal_code = row[2]
    @prefecture = row[6]
    @city = row[7]
    @town = row[8]
  end

  def address
    # 町域名に特定の文字列が含まれている場合は、町域名を除去する
    @town = '' if @town.include?('以下に掲載がない場合') || @town.include?('の次に番地がくる場合')
    "#{@prefecture}#{@city}#{@town}"
  end
end
