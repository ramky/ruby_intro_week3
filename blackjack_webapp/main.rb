require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
	def calculate_total(cards) # cards is [['H','3'], ['D', 'J']]
		array = cards.map{|element| element[1]}

		total = 0
		array.each do |a|
			if a == "A"
				total += 11
			else
				total += (a.to_i == 0 ? 10 : a.to_i)
			end
		end

		# Correct for Aces
		array.select{|element| element == "A"}.count.times do
			break if total <= 21
			total -= 10
		end

		total
	end

	def card_image(card) # cards is ['H','3']
		suit = case card[0]
						when 'H' then 'hearts'
						when 'D' then 'diamonds'
						when 'S' then 'spades'
						when 'C' then 'clubs'
					end
		
		value = card[1]
		if %w[J Q K A].include?(value)
			value = case card[1]
								when 'J' then 'jack'
								when 'Q' then 'queen'
								when 'K' then 'king'
								when 'A' then 'ace'
							end
		end
		"<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>"		
	end # card_image
end #helpers

before do
	@show_hit_and_stay_buttons = true
end

get '/' do
	if session[:player_name]

	else
		redirect '/new_player'
	end
end

get '/new_player' do
	erb :new_player
end

post '/new_player' do
	if params[:player_name].empty?
		@error = "Name is required"
		halt erb(:new_player)
	end
	session[:player_name] = params[:player_name]
	redirect '/game'
end

get '/game' do
	suits = %w[H D C S]
	values = %w[2 3 4 5 6 7 8 9 10 J Q K A]
	session[:deck] = suits.product(values).shuffle!

	session[:dealer_cards] = []
	session[:player_cards] = []
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop

	erb :game
end

post '/game/player/hit' do
	session[:player_cards] << session[:deck].pop
	player_total = calculate_total(session[:player_cards])
	if player_total == 21
		@success = "Congratulations, #{session[:player_name]} hit blackjack!"
		@show_hit_and_stay_buttons = false
	elsif player_total > 21
		@error = "Sorry, it looks like #{session[:player_name]} busted!"
		@show_hit_and_stay_buttons = false
	end

	erb :game
end

post '/game/player/stay' do
	@success = "#{session[:player_name]} has chosen to stay."
	@show_hit_and_stay_buttons = false
	
	redirect '/game/dealer'
end

get '/game/dealer' do
	@show_hit_and_stay_buttons = false

	# decision tree
	dealer_total = calculate_total(session[:dealer_cards])
	if dealer_total == 21
		@error = 'Sorry, dealer hit blackjack!'
	elsif dealer_total > 21
		@success = "Congratulations, dealer busted. #{session[:player_name]} wins!"
	elsif dealer_total >= 17
		# dealer stays
		redirect '/game/compare'
	else
		# dealer hits
		@show_dealer_hit_button = true
	end

	erb :game		
end

post '/game/dealer/hit' do
	session[:dealer_cards] << session[:deck].pop
	redirect '/game/dealer'
end

get '/game/compare' do
	@show_hit_and_stay_buttons = false

	player_total = calculate_total(session[:player_cards])
	dealer_total = calculate_total(session[:dealer_cards])

	if player_total < dealer_total
		@error = "Sorry, #{session[:player_name]} lost!"
	elsif player_total > dealer_total
		@error = "Congratulations, #{session[:player_name]} wins!"
	else
		@succes = "It's a tie"
	end

	erb :game
end
