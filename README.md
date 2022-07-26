# 概要 - Overview

日本郵便の郵便番号データ [ken_all](https://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip)（CSV 形式）を用いて、<br>
N-Gram インデックス方式の住所検索を行うコンソールアプリケーションです。

# 環境 - Requirement

### 例１: Codespaces

- Nothing（Browser only）

参考）[Quickstart for GitHub Codespaces](https://docs.github.com/ja/codespaces/getting-started/quickstart)

### 例 2: Visual Studio Code Dev Container

Local / Remote Host:

- Windows: Docker Desktop 2.0+ on Windows 10 Pro/Enterprise. Windows 10 Home (2004+) requires Docker Desktop 2.3+ and the WSL 2 back-end. (Docker Toolbox is not supported. Windows container images are not supported.)
- macOS: Docker Desktop 2.0+.

Containers:

- x86_64 / ARMv7l (AArch32) / ARMv8l (AArch64) Debian 9+, Ubuntu 16.04+, CentOS / RHEL 7+
- x86_64 Alpine Linux 3.9+

参考）[Developing inside a Container](https://code.visualstudio.com/docs/remote/containers)

### 例 3: Visual Studio Code (only)

Install:

- ruby 3.1.2
- gem install bundler ; bundler install

# 実行方法 - Usage / Features

### 機能 1：インデックスファイルの作成

実行コマンド）

```ruby
ruby main.rb
```

- ken_all（CSV 形式）ファイルが見つからない場合、CSV ファイルダウンロードから実行します。

出力例）

```
特になし
```

> **Note** <br>
> 実行後、data フォルダ配下にインデックスファイル（addres_indexes.csv）が作成されます。

### 機能２：作成したインデックスファイルを元に住所レコードの検索

実行コマンド）

```ruby
ruby main.rb {検索したい文字列}
```

- main.rb の実行引数に検索したい文字列を渡してください。
- インデックスファイルが見つからない場合は、インデックスファイルの作成（機能 1）から実行します。

出力例）

```
13101,"100  ","1000000","ﾄｳｷｮｳﾄ","ﾁﾖﾀﾞｸ","ｲｶﾆｹｲｻｲｶﾞﾅｲﾊﾞｱｲ","東京都","千代田区","以下に掲載がない場合",0,0,0,0,0,0
26105,"605  ","6050074","ｷｮｳﾄﾌ","ｷｮｳﾄｼﾋｶﾞｼﾔﾏｸ","ｷﾞｵﾝﾏﾁﾐﾅﾐｶﾞﾜ","京都府","京都市東山区","祇園町南側",0,0,0,0,0,0
...(略)
```

# 補足 - Note

-
