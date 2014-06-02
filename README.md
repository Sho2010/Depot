# README
- - -

# RailsによるアジャイルWebアプリケーション開発を動かしてみる

rails3ベースの本だけど色々触って動かしてみる

http://immense-plains-2748.herokuapp.com/

## 環境

* Rails 4.1.1
* ruby 2.1.2p95 (2014-05-08 revision 45877) [x86_64-linux]

## heroku deploy memo

~~~sh
#ここで追加されたファイルをgit commitすること
$ rake assets:precompile


#その後にheroku側のmigrateを実行
$ git push heroku master
$ heroku run rake db:migrate
~~~


## メモ雑多なこと

### show,editの変更点

おそらくrails3 > 4で
set_xxxがscoffoldで自動生成されるようになって、before_actionでこいつが呼ばれるようになってる。

だからエラーページ出したくない時とかの処理を上書きする場合
set_xxxの内容を書き換えてやる。（と、思ったんだけどこれじゃダメかもしれない）

追記：
http://stackoverflow.com/questions/17541931/template-is-missing-error-even-if-i-have-done-a-redirect-to-in-the-controller

ActiveRecord::RecordNotFoundをset_xxxの中でレスポンスを返しちゃうと
どうもうまくない事が起きるよと、これどうするのがいいんだろ？
showの中に書いちゃうのは冗長な気がするし、before_actionから外すのが成功法なのかな？
