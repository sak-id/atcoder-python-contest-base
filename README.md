# atcoder-python-base

AtCoder競技プログラミング用のPythonテンプレートリポジトリ

## 使い方

### 1. このテンプレートを使用
GitHubで「Use this template」をクリックして新しいリポジトリを作成

### 2. コンテスト環境のセットアップ
```bash
./contest.py abc123  # abc123コンテスト用のディレクトリを作成
cd abc123
```

### 3. 問題を解く
- `a/code_a.py` に解法を実装
- `a/sample_a.txt` にサンプルケースをコピー
- `./test.sh a` でテスト実行

### 4. 複数問題の並行テスト
```bash
./test.sh a b c  # 複数問題を同時にテスト
```

## 機能

- **自動セットアップ**: a〜hの問題ディレクトリを一括作成
- **並行テスト**: 複数問題のサンプルケースを同時実行
- **URL自動生成**: AtCoderの問題URLを自動設定
- **テンプレート**: よく使うimportをコメントで準備

## ファイル構成

```
contest_name/
├── test.sh          # テスト実行スクリプト
├── a/
│   ├── code_a.py    # 解法コード
│   └── sample_a.txt # サンプルケース(JSON)
├── b/
│   ├── code_b.py
│   └── sample_b.txt
└── ... (c〜hまで)
```