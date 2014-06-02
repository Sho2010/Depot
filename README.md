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

主にrails4で動かした時に変更が必要だった部分を追記していく。

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

### jqueryに関して

これもおそらくrails3 > 4の変更でjqueryのgemがjqueryとjquery-uiで分割されたらしく
単純に`application.js`に`//= require jquery-ui`を追加するだけではダメっぽい

`Gemfile`に以下を追記
~~~
gem 'jquery-ui-rails'
~~~

`app/assets/javascripts/application.js`に以下を追記
~~~
//= require jquery.ui.all
~~~

`app/assets/stylesheets/application.css`に以下を追記
~~~
 *= require jquery.ui.all
~~~

で、サーバを再起動　これでうまく行った


### 数を減らすボタンがうまく動かなかった

route
~~~ruby
  resources :line_items do
    member do
      post 'decrement'
    end
  end
~~~

controller
~~~ruby
  # PATCH/PUT /line_items/1/decrement
  # PATCH/PUT /line_items/1/decrement.json
  def decrement
    @line_item = LineItem.find(params[:id])
    @line_item.quantity -= 1
    respond_to do |format|
      if @line_item.update(line_item_params)
        format.html { redirect_to @line_item, notice: 'Line item was successfully decrement.' }
        format.json { render :show, status: :ok, location: @line_item }
      else
        format.html { render :edit }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end
~~~

view 
~~~
    <td><%= button_to '減らす',decrement_line_item_path(line_item), method: :post %></td>
~~~
