require 'csv'
require_relative './stat_tracker'
require_relative './game'
require_relative './team'
require_relative './game_team'
require_relative './league_statistics'
require_relative './season_statistics'

class GameStats < LeagueStats 
   def highest_total_score
      highest_score_game = @data_games.max_by do |game|
          game.away_goals + game.home_goals
      end
      highest_score_game.away_goals + highest_score_game.home_goals
   end

   def lowest_total_score
      lowest_score_game = @data_games.min_by do |game|
         game.away_goals + game.home_goals
      end
      lowest_score_game.away_goals + lowest_score_game.home_goals
   end

   def percentage_home_wins
      home_wins = @data_games.find_all do |game|
         game.home_goals > game.away_goals
      end
      calculate_percentage(home_wins.count , @data_games.count)
   end

   def percentage_visitor_wins
      away_wins = @data_games.find_all do |game|
         game.away_goals > game.home_goals
      end
      calculate_percentage(away_wins.count , @data_games.count)
   end

   def percentage_ties
      ties = @data_games.find_all do |game|
         game.away_goals == game.home_goals
      end
      calculate_percentage(ties.count , @data_games.count)
   end

   def count_of_games_by_season
      @data_games.each_with_object(Hash.new(0)) {|game , hash| hash[game.season] += 1}
   end

   def average_goals_per_game
      total_goals = 0
      @data_games.each do |game|
         total_goals += (game.away_goals + game.home_goals)
      end
      (total_goals.to_f / @data_games.count).round(2)
   end

   def average_goals_by_season
      goals_by_season = {}
      @data_games.each do |game|
         total_goals = game.away_goals + game.home_goals
         if goals_by_season.key?(game.season)
            goals_by_season[game.season] += total_goals
         else
            goals_by_season[game.season] = total_goals
         end
      end
      avg_goals_by_season = {}
      goals_by_season.each do |season , total_goals|
         avg_goals_by_season[season] = (total_goals.to_f / count_of_games_by_season[season]).round(2)
      end
      avg_goals_by_season
   end
end