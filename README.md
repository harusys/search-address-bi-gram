# 概要 - Overview

日本郵便の郵便番号データ [ken_all](https://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip)（CSV 形式）を用いて、<br>
bi-gram インデックス方式の住所検索を行うコンソールアプリケーションです。

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

### インデックスについて

- インデックスファイルは住所全体（都道府県 + 市区町村 + 町域）を bi-gram で索引ワードを key、行番号を value で作成している。

例）
`"東京都", "千代田区", "飯田橋"` -> `"東京", "京都", "都千", "千代", "代田", "田区", "区飯", "飯田", "田橋"`

- インデックスファイル名: data/address_indexes.csv

例）

```
町刑,36907,84361
府里,36909
小榎,36910,92521
町皿,36912,113273,117570
皿木,36912
立鳥,36915
代丸,36916,114089
```

### 検索について

- 数字が検索項目に入った場合、検索対象はすべて全角のため、半角であれば全角に自動変換して検索している。

例）
`"2丁目"` -> `"２丁目"`

- スペース（空白）が検索項目に入った場合、自動でスペース排除して検索している。

例）
`"千代田区 飯田橋"` -> `"千代田区飯田橋"`
