require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'

def is_barber_exists? db, name
	db.execute('select * from Barbers where name=?', [name]).length > 0
end

def seed_db db, barbers
	barbers.each do |barber|
		if !is_barber_exists? db, barber
			db.execute 'insert into Barbers (name) values (?)',[barber]
		end
	end

end

def get_db
  @db = SQLite3::Database.new 'barbershop.db'
  @db.results_as_hash = true
  return @db
end

configure do
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS 
	"Users" 
		(
		"Id" INTEGER PRIMARY KEY AUTOINCREMENT, 
		"User_name" TEXT, 
		"Phone" TEXT, 
		"Date_Stamp" TEXT, 
		"Master" TEXT, 
		"Color" TEXT
		)'
   

  
	db.execute 'CREATE TABLE IF NOT EXISTS 
	"Barbers" 
	(
		"id" INTEGER PRIMARY KEY AUTOINCREMENT, 
		"name" TEXT
		
	)'
	
	seed_db db, ['Jessie Pinkman', 'Walter White', 'Gus Frink', 'Mike Etherman']
end

before do
	db = get_db
 	@barbers = db.execute 'SELECT * FROM Barbers'
  	
end

get '/' do

	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do

	erb :about
end

get '/visit' do

	
	erb :visit
end

get '/feedback' do
	erb :feedback
end

get '/admin' do
	erb :adminlogin
end

get '/gdgsdggsgsdsg87sdf78sfy78sdfy87sdfsf' do
	erb :admin_page
end

get '/showusers' do
  	get_db

 	 @results = @db.execute 'SELECT * FROM Users ORDER BY id DESC'
  	 @db.close
	erb :showusers
end



post '/visit' do
	@user_name=params[:username]
	@phone = params[:phone]
	@date = params[:datetime]
	@master = params[:master]
	@color =params[:color]
	


	

	f = File.open './public/users1.txt', 'a'
	f.write "<tr><td>#{@user_name}</td><td>#{@phone}</td><td>#{@date}</td><td>#{@master}</td><td>#{@color}</td></tr>\n"

	f.close

	# хеш
		hh = { 	:username => 'Введите ваше имя',
				:phone => 'Введите ваш телефон',
				:datetime => 'Введите дату и время' }

		@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

		if @error != ''
			return erb :visit
		end

		db = get_db
		db.execute 'insert into 
		Users
		(
			User_name, 
			Phone, 
			Date_Stamp, 
			Master, 
			Color
		)
		values (?, ?, ?, ?, ?)', [@user_name, @phone, @date, @master, @color]
		db.close		
			erb "<h1>Спасибо!</h1><h3>Уважаемый <b>#{@user_name}</b>, мы будем ждать вас <b>#{@date}</b>.<br>Ваш мастер: <b>#{@master}</b>."
	

end

post '/feedback' do
	
	@user_name=params[:username]
	@email = params[:email]
	@massage_user = params[:massage_user]



	@title = 'Спасибо!'
	@message = "Уважаемый #{@user_name}, спасибо за ваше обращение! В ближайшее время мы с вами свяжемся."

	f = File.open './public/feedback.txt', 'a'
	f.write "Клиент: #{@user_name}, Email: #{@email}, Сообщение: #{@massage_user}<br>\n"

	f.close

	# хеш
		hh = { 	:username => 'Введите ваше имя',
				:email => 'Введите ваш Email адрес',
				:massage_user => 'Введите текст обращения' }

		@error = hh.select {|key,_| params[key] == ""}.values.join(", ")

		if @error != ''
			return erb :feedback
		end
				
			erb :message

		Pony.mail(
   	:name => params[:username],
  	:mail => params[:email],
 	 :body => params[:massage_user],
  	:to => 'anisvan@mail.ru',
  	:subject => params[:username] + " has contacted you",
  	:body => params[:message],
  	:port => '587',
  	:via => :smtp,
  	:via_options => { 
    :address              => 'smtp.gmail.com', 
    :port                 => '587', 
    :enable_starttls_auto => true, 
    :user_name            => 'Anisimov06', 
    :password             => 'sqservice95', 
    :authentication       => :plain, 
    :domain               => 'localhost.localdomain'
  })

end

post '/admin' do

    @logfile = File.read("./public/users.txt")
	@login=params[:login]
	@password = params[:password]

	if @login=='admin' && @password=='admin'
		erb :admin_page
	else erb :adminlogin
	end	




end

post '/admin_page' do

    @logfile1 = File.read("./public/users.txt")
    @logfile2 = File.read("./public/feedback.txt")
	@choose=params[:choose]


	if @choose=='Посмотреть список клиентов'
		@logfile=@logfile1
		@title = 'Список клиентов:'
		erb :admin_views
	elsif @choose=='Посмотреть обращения клиентов'
		@logfile=@logfile2
		@title = 'Обращения клиентов:'
		erb :admin_views
	end	




end

