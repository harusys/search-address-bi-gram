# frozen_string_literal: true

# 郵便番号データレコードを扱うクラス
#  0. 全国地方公共団体コード
#  1. 旧）郵便番号(5桁)
#  2. 郵便番号7桁
#  3. 都道府県名(カナ)
#  4. 市区町村名(カナ)
#  5. 町域名(カナ)
#  6. 都道府県名
#  7. 市区町村名
#  8. 町域名
#  9. 一町域が二以上の郵便番号で表される場合の表示(「1」は該当、「0」は該当せず)
#  10.小字毎に番地が起番されている町域の表示(「1」は該当、「0」は該当せず)
#  11.丁目を有する町域の場合の表示(「1」は該当、「0」は該当せず)
#  12.一つの郵便番号で二以上の町域を表す場合の表示(「1」は該当、「0」は該当せず)
#  13.更新の表示(「0」は変更なし、「1」は変更あり、「2」廃止（廃止データのみ使用))
#  14.変更理由(「0」は変更なし、「1」市政・区政・町政・分区・政令指定都市施行、「2」住居表示の実施、「3」区画整理、「4」郵便区調整等、「5」訂正、「6」廃止（廃止データのみ使用))
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
    # TODO: 地割・()付き補足を分解する（例：三ツ木（１～５丁目）-> 三ツ木１丁目、２丁目...）
    # 町域名に特定の文字列が含まれている場合は、町域名を除去する
    @town = '' if @town.include?('以下に掲載がない場合') || @town.include?('の次に番地がくる場合')

    # 不要な文字列は検索のノイズになるので除去する
    @town.delete!('（○○屋敷）') if @town.include?('（○○屋敷）')
    @town.delete!('（地階・階層不明）') if @town.include?('（地階・階層不明）')
    @town.delete!('（無番地を除く）') if @town.include?('（無番地を除く）')
    @town.delete!('（次のビルを除く）') if @town.include?('（次のビルを除く）')
    @town.delete!('（全域）') if @town.include?('（全域）')
    @town.delete!('（丁目）') if @town.include?('（丁目）')
    @town.delete!('（各町）') if @town.include?('（各町）')
    @town.delete!('（番地）') if @town.include?('（番地）')
    @town.delete!('（無番地）') if @town.include?('（無番地）')
    @town.delete!('（大字）') if @town.include?('（大字）')
    @town.delete!('（その他）') if @town.include?('（その他）')

    "#{@prefecture}#{@city}#{@town}"
  end
end
