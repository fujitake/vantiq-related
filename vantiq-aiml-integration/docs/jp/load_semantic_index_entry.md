# Semantic Index への Entry 追加方法

## 概要

Semantic Index Entry は、IDE上で作成することも可能ですが、CLIを使用すればバッチやシェルスクリプトを使用して一括で作成することも可能です。ここではその方法を解説します。

## 前提

- [Vantiq CLI](https://dev.vantiq.com/docs/system/cli/index.html) がインストールされていること
- [profile](https://dev.vantiq.com/docs/system/cli/index.html#profile) が設定されていて、対象のVantiq環境に接続できること
- 対象のVantiq環境にSemantic Indexが作成されていること

## CLI Command
`vantiq help` コマンドで、CLIのヘルプを確認することができます。Semantic Index Entry に関するコマンドは、以下の通りです。

``` bash
    semanticindexentries
        find: not supported
        load: loads the given file or directory of files into the semantic index.  If the target is a directory,
                  then the contents will be zipped prior to creation of the index entry.  If the target is a URL, then
                  a URL based entry will be created.  For file and directory targets, the contents will be uploaded
                  via the TUS protocol, unless they are less than 8K in size.  The optional -id option can be used to
                  specify the "id" of the entry. If this refers to an existing entry, then the entry will be updated.
                  If the -metadata option is given, the given file is used to provide metadata for the entries being
                  loaded.  The optional -exclude option can be used to specify the name of a file and/or directory
                  to exclude when loading a directory.  The name must be specified relative to the directory being
                  loaded.  This option can be specified more than once to exclude multiple files/directories.
```

`vantiq load semanticindexentries <Semantic Index Name> <filename>` で、Semantic Index にファイルを追加することができます。ファイルは、ローカルファイル、URL、ディレクトリのいずれかを指定することができます。ディレクトリを指定した場合、ディレクトリ内のファイルはzip圧縮されてSemantic Index に追加されます。ドキュメントの更新などを個別に管理したい場合、ディレクトリではなくスクリプトを使用して個々に追加することが望ましいです。

`-id` オプションで、Semantic Index Entry のIDを指定することができます。IDが指定された場合、既存のEntryがあれば更新されます。
`vantiq load semanticindexentries <Semantic Index Name> <filename> -id <Entry ID>`

`-metadata` オプションで、Semantic Index Entry のメタデータを指定することができます。メタデータは、JSONファイルで指定します。
`vantiq load semanticindexentries <Semantic Index Name> <filename> -metadata <metadata json filename>`

## Shell Script

Shell Scriptを使用して、ディレクトリ内のファイルを一括でSemantic Indexに追加するサンプルを以下に示します。引数で与えられたディレクトリ内の.mdファイルを一括でSemantic Indexに追加します。

``` bash:load_semantic_index_entry.sh
#!/bin/bash
    
# 引数からディレクトリパスを取得
directory=$1

# 引数が不足している場合はエラーメッセージを表示
if [ -z "$directory" ]; then
    echo "エラー: ディレクトリが指定されていません。"
    echo "使用法: $0 <ディレクトリパス>"
    exit 1
fi

# 指定されたディレクトリが存在しない場合はエラーメッセージを表示
if [ ! -d "$directory" ]; then
    echo "エラー: ディレクトリが存在しません: $directory"
    exit 1
fi

# 指定されたディレクトリ以下の.mdファイルを取得
find "$directory" -type f -name "*.md" | while read file; do
    # vantiq コマンドを実行
    vantiq load semanticindexentries <Semantic Index Name> "$file"
done

```
