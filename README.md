# Agile Outcome Canvas

顧客価値の仮説、検証方法、検証結果、学び、次のアクションを Sprint ごとに記録する Rails アプリケーションです。プロジェクト単位で Sprint を整理し、仮説検証の履歴を振り返れます。

## 主な機能

- プロジェクトの作成・閲覧・編集・削除
- プロジェクトごとの Sprint の作成・閲覧・編集・削除
- Sprint ごとの顧客価値仮説、検証方法、検証結果、学び、次のアクションの記録

## 技術スタック

- Ruby 3.3.11
- Ruby on Rails 8.1.3
- SQLite 3
- Hotwire（Turbo / Stimulus）
- Importmap
- Minitest / Capybara / Selenium

JavaScript の依存関係は Importmap で管理しているため、通常の開発では Node.js や npm は不要です。

## セットアップ

### 必要なもの

- Git
- Ruby 3.3.11
- Bundler 4.0.16
- SQLite 3
- libvips（画像処理機能で使用）

システムテストを実行する場合は、Chrome または Chromium も必要です。

### 一括セットアップ

リポジトリを取得して、アプリケーションのディレクトリへ移動します。

```sh
git clone https://github.com/itogakuto/ruby_sample.git sample_app
cd sample_app
```

依存 Gem のインストールとデータベースの準備を行います。

```sh
bin/setup --skip-server
```

開発サーバーを起動します。

```sh
bin/dev
```

ブラウザで <http://localhost:3000> を開いてください。サーバーは `Ctrl+C` で終了できます。

`bin/setup` をオプションなしで実行すると、セットアップ完了後に開発サーバーも続けて起動します。

### 手動でセットアップする場合

```sh
bundle install
bin/rails db:prepare
bin/rails server
```

ローカル開発ではデータベースに SQLite を使用します。外部の DB サーバーや、追加の環境変数を設定する必要はありません。

## 開発でよく使うコマンド

### サーバーとコンソール

```sh
# 開発サーバーを起動
bin/dev

# Rails コンソールを起動
bin/rails console

# 定義済みのルートを確認
bin/rails routes
```

別のポートで起動する場合は、次のように指定します。

```sh
bin/dev -p 3001
```

### データベース

```sh
# DB がなければ作成し、未適用のマイグレーションを実行
bin/rails db:prepare

# 未適用のマイグレーションを実行
bin/rails db:migrate

# seed データを投入
bin/rails db:seed
```

開発用 DB は `storage/development.sqlite3`、テスト用 DB は `storage/test.sqlite3` に作成されます。どちらも Git の管理対象外です。

DB を作り直す場合は次のコマンドを使用します。保存済みの開発データが削除されるため注意してください。

```sh
bin/setup --reset --skip-server
```

## テストと品質チェック

```sh
# 単体テスト・コントローラーテストを実行
bin/rails test

# ブラウザを使用するシステムテストを実行
bin/rails test:system

# コードスタイルを確認
bin/rubocop

# Rails コードの脆弱性を検査
bin/brakeman --quiet --no-pager

# Gem の既知の脆弱性を検査
bin/bundler-audit

# Importmap で参照する JavaScript の脆弱性を検査
bin/importmap audit
```

システムテストを除く主要なセットアップ・テスト・静的解析・セキュリティ検査は、まとめて実行できます。

```sh
bin/ci
```

GitHub Actions では、通常のテストに加えてシステムテストも実行されます。

## ディレクトリ構成

```text
app/
  controllers/  リクエスト処理
  models/       Project、Sprint のモデル
  views/        画面テンプレート
  assets/       CSS や画像
  javascript/   Stimulus と JavaScript のエントリーポイント
config/         ルーティング、DB、環境別設定
db/             マイグレーション、スキーマ、seed
test/           単体・コントローラー・システムテスト
```

## トラブルシューティング

### Ruby のバージョンが異なる

利用中のバージョンを確認し、3.3.11 に切り替えてから再度セットアップしてください。

```sh
ruby -v
```

### Gem の読み込みでエラーになる

```sh
bundle install
bin/rails tmp:clear
```

### DB のマイグレーションエラーが発生する

まず、未適用のマイグレーションを反映します。

```sh
bin/rails db:prepare
```

開発データを破棄してよい場合は、`bin/setup --reset --skip-server` で DB を再作成できます。

## 本番環境について

本番用の Dockerfile と Kamal の設定が含まれています。ただし、`config/deploy.yml` のサーバーやコンテナレジストリはサンプル値です。デプロイ前に環境に合わせて変更し、`RAILS_MASTER_KEY` を安全な方法で設定してください。
