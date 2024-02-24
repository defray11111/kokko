
require 'bundler/setup'
require 'sinatra/activerecord'
Bundler.require
require './models'
require 'sinatra/reloader' if development?

require 'net/http'
require 'uri'
require 'nokogiri'
require 'time'
require 'date'


enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

before '/tasks' do
  if current_user.nil?
    redirect '/'
  end
end

get '/signup' do
  erb :sign_up
end

post '/signup' do
  puts"-------------------------------"
  user = User.create(
    name: params[:name],
    password: params[:password],
    password_confirmation: params[:password_confirmation]
  )
  if user.persisted?
    session[:user] = user.id
  end
  redirect '/'
end

get '/signin' do
  erb :sign_in
end

post '/signin' do
  user = User.find_by(name: params[:name])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
  end
  redirect '/'
end

get '/signout' do
  session[:user] = nil
  redirect '/'
end



get '/aik' do
  erb :aik
end

post '/aik' do
  if Schedule.nil?
    print("^^^^^^^^^^^^^^^^^^^^^^^^^")
    redirect '/'
  else
  schedules = Schedule.all

  schedules.each do |schedule|
    schedule.destroy if schedules
  end
  end

  redirect '/'
end
  


get 'nodata' do
  erb:nodata
end

get '/' do
  #データがない時 false
  if current_user.nil?
    redirect '/signin'
  else
    subjectCheck #関数呼び出してる(app.rbの一番下にあるよ)
  end
end

get '/nodata' do
  erb :nodata
end


get '/test' do
  erb :test
end

post '/input' do
  #ここから時間帯によってのif文
  if params[:time] == "1st" #一限目
    time = Time.local(2024,2,18,8,40,0)
    time2 = Time.local(2024,2,18,9,30,0)
  elsif params[:time] == "2nd" #二限目
    time = Time.local(2024,2,18,9,40,0)
    time2 = Time.local(2024,2,18,10,30,0)
  elsif params[:time] == "3rd" #三限目
    time = Time.local(2024,2,18,10,40,0)
    time2 = Time.local(2024,2,18,11,30,0)
  elsif params[:time] == "4th" #四限目
    time = Time.local(2024,2,18,11,40,0)
    time2 = Time.local(2024,2,18,12,30,0)
  elsif params[:time] == "5th" #五限目
    time = Time.local(2024,2,18,12,40,0)
    time2 = Time.local(2024,2,18,13,30,0)
  elsif params[:time] == "6th" #六限目
    time = Time.local(2024,2,18,13,40,0)
    time2 = Time.local(2024,2,18,14,30,0)
  elsif params[:time] == "7th" #七限目
    time = Time.local(2024,2,18,14,40,0)
    time2 = Time.local(2024,2,18,15,30,0)
  elsif params[:time] == "8th" #八限目
    time = Time.local(2024,2,18,15,40,0)
    time2 = Time.local(2024,2,18,16,30,0)
  end
  
  #DBに入れるための値を用意してる
  startHour = time.hour+9
  startMin = time.min
  startTime = startHour.to_s + startMin.to_s
  endHour = time2.hour+9
  endMin = time2.min
  endTime = endHour.to_s + endMin.to_s
  
  #DBに実際に入れてる
  schedule = Schedule.create(
    user_id: current_user.id,
    subject: params[:subject],
    week: params[:week],
    startTime: startTime,
    endTime: endTime
  )
  redirect '/'
end


# 科目のチェックをしてくれる関数↓
def subjectCheck()
  if !Schedule.exists? #ヌルと時
    @flag = false
  else #ヌルじゃない時
    @flag = true
    weekList = ["mon","tue","wed","thur","fri","sat","sun"]
    today = Time.now
    week = today.wday
    baseData = Schedule.all #Scheduleの全てのデータを持ってくる
    baseData.each do |eachData| #全てのデータをeachで回す
      if eachData.user_id.to_i == current_user.id.to_i
        if eachData.week == weekList[week] #データの曜日が今日と一致してるかのチェック
        #一致してたらそのデータの授業が始まる時間と終わる時間を変数に入れる↓
          startTime = eachData.startTime.to_i
          endTime = eachData.endTime.to_i
          if (startTime..endTime).include?((today.hour + 9) * 100 + today.min) #現在の時間がデータの時間内の時間かチェック
            @subject = eachData.subject #そうだった場合は今はその授業の時間だから変数に入れる
            break
          else #データがなかった場合は空きコマなので空きコマと入れる！
            @subject = "空きコマ"
          end
        else #データがなかった場合は空きコマなので空きコマと入れる！
            @subject = "空きコマ"
        end
      else
        @subject = "空きコマ"
      end
        
      # テスト用
      if eachData.user_id.to_i == current_user.id.to_i
        if eachData.week == "mon" #ここで曜日のチェックをしてる
          startTime = eachData.startTime.to_i 
          endTime = eachData.endTime.to_i
          if (startTime..endTime).include?(2140) #ここで時間のチェックをしてる
            @subject = eachData.subject
            break
          else
            @subject = "空きコマ"
          end
        else
          @subject = "空きコマ"
        end
      else
        @subject = "空きコマ"
      end
    end
  end
  erb :index
end