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

### will_paginate gemの変更

これまた4.1の変更点っぽい

列車本サンプル
~~~ruby
  def index
    @orders = Order.paginate :page=>params[:page], :order=>'created_at desc',
      :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orders }
    end
  end
~~~

俺の直したソース
~~~ruby
  def index
    @orders = Order.all.
                order('created_at desc').  #ここのorderは並び順という意味
                paginate(page:params[:page], per_page: PER_PAGE)
  end
~~~

### password_digestを持ったユーザモデルとhas_secure_password

gemの追加はまぁいい

`Gemfile`
~~~
gem 'bcrypt', '~> 3.1.7'
~~~

ここが一番ハマった恐らくrails4になって変わったstrong parametersの影響だと思う
modelにhas_secure_password書いたあとrails3なら素直に書けばいいんだろうけど
rails4ではそうはいかないらしい

今後もActiveRecordのカラムに存在しないformデータを追加する場合は注意しようとおもう。

newのviewにpassword,password_confirmationを作ってやってもどうもうまく値が読めてないらしくて
ブランクにしてんじゃねーよってエラーを吐く
解決策としてはcontrollerにポイントがあった

ポイントは２つ
* `user_params`で:password, :password_confirmationをちゃんと追加してやること(scaffoldしただけだと生成されないのがポイント)
* User.new(user_params)では存在しないカラムには値が入らないっぽいので手動で入れてやること

controller

~~~
  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.password = user_params[:password]
    @user.password_confirmation = user_params[:password_confirmation]

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_url, notice: "ユーザ#{@user.name}を作成しました。" }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  #...

  private
    
    #...
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :password, :password_confirmation)
    end

~~~

### paramsの型

ActiveRecord使ってると勝手にparamをいいかんじの型にしてくれてるが

* paramsの中身は必ずstring

何らかの理由でparamsの中身を単純に比較すると悲しい感じになる なった。
