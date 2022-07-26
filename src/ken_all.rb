# frozen_string_literal: true

require 'fileutils'
require 'open-uri'
require 'open_uri_redirections'
require 'zip'

# 郵便番号データファイルを扱うクラス
class KenAll
  attr_reader :csv_path

  def initialize
    @uri = 'https://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip'
    @folder_path = 'data'
    @csv_file_name = 'KEN_ALL.CSV'
    @csv_path = File.expand_path("../#{@folder_path}/#{@csv_file_name}", __dir__)
  end

  # zip ファイルをダウンロード
  def file_download
    puts 'zip ファイルをダウンロードします'
    zip_name = @uri.split('/').last
    zip_path = File.expand_path("../#{@folder_path}/#{zip_name}", __dir__)

    # ファイルをローカルに保存
    URI.parse(@uri).open(allow_redirections: :all) do |file|
      File.open(zip_path, 'w+b') do |out|
        out.write(file.read)
      end
    end
    zip_path
  end

  # zip ファイルを解凍
  def unzip(zip_path)
    Zip::File.open(zip_path) do |zip|
      zip.each do |entry|
        # 特定ファイルのみ解凍
        next if entry == @csv_file_name

        # { true } は展開先に同名ファイルが存在する場合に上書きする指定
        zip.extract(entry, @csv_path) { true }
      end
    end
    FileUtils.rm_r(zip_path)
  end

  # CSV ファイル取得
  def read
    # CSV ファイルが存在しない場合は作成
    unzip(file_download) unless FileTest.exist?(@csv_path)
    @csv_path
  end
end
