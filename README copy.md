# C2班創造ものづくり

Travel APP using Flutter, Python and SQLITE3

## Getting Started (作業を始める前に、これをやっておく必要がある)

1. ローカル・ワークスペースがmain branchと最新であることを確認する。
```
git checkout main   # main branchに切り替える
git pull origin main  # main branchから最新のアップデートを取り込む
(自分のbranchがあったなら, 切り替える) git checkout <your-branch-name>
(# 新しいbranchを作成し、切り替える) git checkout -b <your-branch-name> 
git pull origin main
```

2. 働きながら： 新しいbranchに変更を加える。変更を追加、コミット、プッシュする
```
git add .  # Stage changes (このコマンドは、行ったすべての作成、削除、調整を検索、チェックする。)
git commit -m "仕事内容"  # Commit changes (Stage changesした後)
git push origin <your-branch-name>  # Push changes (最後は, <your-branch-name>にプッシュする)
```

3. github webで
```
ブランチのPRを作成する通知が表示される。
Compare & pull request をクリックする。
意味のあるタイトルと説明を追加する。
```

## 

RUN EMULATOR
```
-- Gpuを使ってエミュレータを動かす
emulator -avd android33 -gpu host
--もしemulatorが上手く実行できないとき (-no-snapshot-load)
emulator -avd android33 -no-snapshot-load -gpu host
-- emulatorがインターネットに接続できない (-netdelay none -netspeed full -dns-server 8.8. 8.8)
emulator -avd android33 -netdelay none -netspeed full -dns-server 8.8. 8.8
-- emulatorのサイズ変更 (-skin 720x1280)
emulator -avd android33 -no-snapshot-load -gpu host -netdelay none -netspeed full -dns-server 8.8.8.8

-- FULL COMMAND


```

RUN FLUTTER
```
-- 
flutter run
-- DBに新しいデータがある場合(エミュレータでDB内のデータを更新する) ( 
-- 
adb uninstall com.example.c2monozukuri
```

##

dart fileの説明

1. inside back_end folder
   
   1. configs.dart

   アプリ全体で使用される定数、環境変数、APIキー、デフォルト設定など、コンフィギュレーション関連のデータが含まれている.

     a. Class ConfigService

   - このクラスはmain.dartで実行され（アプリを開いたときに最初に実行される）、assetsフォルダからデータベース、コンフィグ、アセットをロードする。
      
     b. Class LocalizationManager

     -このクラスは、アプリの言語データをロードするために、main.dartで実行される。

    2. page_controller.dart
      ファイル名と同じで、このファイルにはアプリ内のページを変更／管理するためのクラスと関数が含まれている。

       a. Class PageControllerClass
      - 気にしなくてもいい、
          
