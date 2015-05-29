require "sinatra"
require 'pg'
require "csv"
require "pry"

fields = ["", "", ""]

def db_connection
  begin
    connection = PG.connect(dbname: "news_aggregator_development")
    yield(connection)
  ensure
    connection.close
  end
end

get '/articles' do
  articles = db_connection { |conn| conn.exec("SELECT * FROM articles") }
  erb :articleslist, locals: { articles: articles }
end

post '/articles' do
  submission = [params["article"], params["url"], params["description"]]
  if good_url?(params["url"]) == true
    db_connection do |conn|
      conn.exec_params("INSERT INTO articles (name, url, description) VALUES ($1, $2, $3)", submission)
    end
    redirect '/articles'
  elsif params["article"].length < 1
    erb :articlesubmit, locals: {
      fields: submission,
      nameerror: "You must provide a title. Please try again.",
      urlerror: "",
      lengtherror: ""
      }
  elsif params["description"].length < 20
    erb :articlesubmit, locals: {
      fields: submission,
      nameerror: "",
      urlerror: "",
      lengtherror: "That description is too short. Please try again."
      }
  else
    erb :articlesubmit, locals: {
      fields: submission,
      nameerror: "",
      urlerror: "That URL is invalid. Please try again.",
      lengtherror: ""
      }
  end
end

get '/articles/new' do
  erb :articlesubmit, locals: {
    fields: fields,
    nameerror: "",
    urlerror: "",
    lengtherror: ""
    }
end

def good_url?(url)
  if url.include?("http://") || url.include?("https://")
    true
  else
    false
  end
end
