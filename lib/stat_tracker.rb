require 'csv'
require_relative './stat_tracker'
require_relative './game'
require_relative './team'
require_relative './game_team'

class StatTracker
   def self.from_csv(location_path)

      StatTracker.new(location_path)
   end

   def initialize(locations_path)
      @data_games = read_games_csv(locations_path[:games])
      @data_teams = read_teams_csv(locations_path[:teams])
      @data_game_teams = read_game_teams_csv(locations_path[:game_teams])
   end

   def read_games_csv(location_path)
      games_data = []
      CSV.foreach(location_path, headers: true, header_converters: :symbol) do |row|
         game_details = {
            game_id: row[:game_id],
            season: row[:season],
            away_team_id: row[:away_team_id],
            home_team_id: row[:home_team_id],
            away_goals: row[:away_goals],
            home_goals: row[:home_goals]
         }
         games_data << Game.new(game_details)
      end
      games_data
   end

   def read_teams_csv(location_path)
      teams_data = []
      CSV.foreach(location_path, headers: true, header_converters: :symbol) do |row|
         team_id = row[:team_id]
         team_name = row[:team_name]
         teams_data << Team.new(team_id, team_name)
      end
      teams_data
   end

   def read_game_teams_csv(location_path)
      game_team_data = []
      CSV.foreach(location_path, headers: true, header_converters: :symbol) do |row|
         game_team_details = {
            game_id: row[:game_id],
            team_id: row[:team_id],
            hoa: row[:hoa],
            result: row[:result],
            head_coach: row[:head_coach],
            goals: row[:goals],
            shots: row[:shots],
            tackles: row[:tackles]
         }
         game_team_data << GameTeam.new(game_team_details)
      end
      game_team_data
   end

# league_statistics
   def count_of_teams
      @data_teams.count  
      # GameStats.count_of_teams(@data_teams)  
   end

   def best_offense
      convert_team_id_to_name(highest_average_team_id(team_stats))
   end

   def worst_offense
      convert_team_id_to_name(lowest_average_team_id(team_stats))
   end

   def highest_scoring_visitor
      convert_team_id_to_name(highest_average_team_id(team_stats_hoa("away")))
   end

   def highest_scoring_home_team
      convert_team_id_to_name(highest_average_team_id(team_stats_hoa("home")))
   end

   def lowest_scoring_visitor
      convert_team_id_to_name(lowest_average_team_id(team_stats_hoa("away")))
   end

   def lowest_scoring_home_team
      convert_team_id_to_name(lowest_average_team_id(team_stats_hoa("home")))
   end
  
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

   def winingest_coach(season_id)
      best_coach = coach_game_stats(season_id).max_by do |coach, stats|
         win_percentage = stats[:games_won].to_f / stats[:number_of_games]
         win_percentage 
      end
      best_coach[0]
   end

   def worst_coach(season_id)
      worst_coach = coach_game_stats(season_id).min_by do |coach, stats|
         lose_percentage = stats[:games_won].to_f / stats[:number_of_games]
         lose_percentage 
      end
      worst_coach[0]
   end

   def most_accurate_team(season)
      most_accurate_team = team_accuracy.max_by { |game_team, accuracy| accuracy }.first
      most_accurate_team_by_season = season_games(season).filter_map do |game|
         most_accurate_team.team_id if game.game_id == most_accurate_team.game_id
      end
      convert_team_id_to_name(most_accurate_team_by_season[0])
   end

   def least_accurate_team(season)
      least_accurate_team = team_accuracy.min_by { |game_team, accuracy| accuracy }.first
      least_accurate_team_by_season = season_games(season).filter_map do |game|
         least_accurate_team.team_id if game.game_id == least_accurate_team.game_id
      end
      convert_team_id_to_name(least_accurate_team_by_season[0])
   end
   
   def most_tackles(season_id)
      
   end

#Helper Method
   def calculate_percentage(num1 , num2)
      ((num1.to_f / num2)).round(2)
   end

   def convert_team_id_to_name(team_id)
      team = @data_teams.find do |team|
         team.team_id == team_id
      end
      team.team_name
   end

   def lowest_average_team_id(team_stats)
      team_averages = team_stats.transform_values do |stats|
         stats[:goals].to_f / stats[:games_played]
      end
      lowest_average_team_id = team_averages.min_by {|_team_id, average| average}.first
   end

   def highest_average_team_id(team_stats)
      team_averages = team_stats.transform_values do |stats|
         stats[:goals].to_f / stats[:games_played]
      end
      highest_average_team_id = team_averages.max_by {|_team_id, average| average}.first
   end

   def team_stats
      team_stats = Hash.new {|hash, key| hash[key] = {goals: 0, games_played: 0 }}
      @data_game_teams.each do |game_team|
         team_stats[game_team.team_id][:goals] += game_team.goals
         team_stats[game_team.team_id][:games_played] += 1
      end
      team_stats
   end

   def coach_game_stats(season_id)
      game_stats = Hash.new {|hash, key| hash[key] = {number_of_games: 0, games_won: 0 }}
      @data_game_teams.each do |game_team|
         if game_team.game_id == convert_season_id_to_game_id(season_id)
            game_stats[game_team.head_coach][:number_of_games] += 1
            if game_team.result == "WIN"
               game_stats[game_team.head_coach][:games_won] += 1
            end
         end
      end
      game_stats
   end
  
   def team_stats_hoa(hoa)
      team_stats = Hash.new {|hash, key| hash[key] = {goals: 0, games_played: 0 }}
      @data_game_teams.each do |game_team|
         if game_team.hoa == hoa
            team_stats[game_team.team_id][:goals] += game_team.goals
            team_stats[game_team.team_id][:games_played] += 1
         end
      end
      team_stats
   end

   def games_goals_and_shots
      games_goals_and_shots = Hash.new { |hash, key| hash[key] = {total_shots: 0, total_goals: 0}}
      @data_game_teams.each do |data_game_team|
         games_goals_and_shots[data_game_team][:total_shots] += data_game_team.shots
         games_goals_and_shots[data_game_team][:total_goals] += data_game_team.goals
      end
      games_goals_and_shots
   end

   def team_accuracy
      team_accuracy = Hash.new { |hash, key| hash[key] = {accuracy: 0} }
      games_goals_and_shots.each do |game_team, goals_and_shots|
         team_accuracy[game_team] = ((goals_and_shots[:total_goals]).to_f / (goals_and_shots[:total_shots])).round(2)
      end
      team_accuracy
   end

   def season_games(season)
      season_games = @data_games.find_all do |game| 
         game.season == season
      end
      #require 'pry' ; binding.pry
   end

   def convert_season_id_to_game_id(season_id)
      game_id_by_season = @data_games.find do |game|
         game.season == season_id
      end
      game_id_by_season.game_id
   end

   def season_game_id(season_id)
      season_games = Hash.new { |h_obj, k| h_obj[k] = [] }
      @data_games.each do |game|
         season_games[game.season] = season_games[game.season] << game.game_id
         #if season_games.include? ___ do team_tackles
      end
      season_games
   end
   #Name of the Team with the most tackles in the season
   
   def team_tackles
      teams_tackles = Hash.new{ |hash, key| hash[key] = {total_tackles: 0, game_id: 0} }
      @data_game_teams.each do |game_team|
         teams_tackles[game_team.team_id].each do |total_tackles, game_id| 
            teams_tackles[game_team.team_id][:total_tackles] = game_team.tackles
            teams_tackles[game_team.team_id][:game_id] = game_id
         end
         teams_tackles
         require 'pry' ; binding.pry
      end
   end

   def fewest_tackles

   end
end
