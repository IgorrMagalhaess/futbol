require 'csv'
require_relative './stat_tracker'
require_relative './game'
require_relative './team'
require_relative './game_team'

class SeasonStats
   def winningest_coach(season_id)
      games_this_season = season_games_by_id(season_id)
      coaches = coaches_by_season(season_id)
      coaches.uniq.max_by do |coach|
         coach_wins = @data_game_teams.find_all {|game_team| (game_team.head_coach == coach) && (games_this_season.include?(game_team.game_id)) && (game_team.result == "WIN")}.count
         coach_games = @data_game_teams.find_all {|game_team| (game_team.head_coach == coach) && (games_this_season.include?(game_team.game_id))}.count
         calculate_percentage(coach_wins, coach_games)
      end
   end

   def worst_coach(season_id)
      games_this_season = season_games_by_id(season_id)
      coaches = coaches_by_season(season_id)
      coaches.min_by do |coach|
         coach_wins = @data_game_teams.find_all {|game_team| (game_team.head_coach == coach) && (games_this_season.include?(game_team.game_id)) && (game_team.result == "WIN")}.count
         coach_games = @data_game_teams.find_all {|game_team| (game_team.head_coach == coach) && (games_this_season.include?(game_team.game_id))}.count
         calculate_percentage(coach_wins, coach_games)
      end
   end

   def most_accurate_team(season_id)
      most_accurate_team_by_season = highest_team_accuracy(season_id)
      convert_team_id_to_name(most_accurate_team_by_season[0])
   end

   def least_accurate_team(season_id)
      least_accurate_team_by_season = lowest_team_accuracy(season_id)
      convert_team_id_to_name(least_accurate_team_by_season[0])
   end

   def most_tackles(season)
      games_this_season = season_games_by_id(season)
      tackles = Hash.new(0)
      @data_game_teams.each do |data_game_team|
         tackles[data_game_team.team_id] += data_game_team.tackles if games_this_season.include?(data_game_team.game_id)
      end
 
      most_tackles = tackles.max_by {|data_game_team , total_tackles| total_tackles}.first
      
      convert_team_id_to_name(most_tackles)
   end
   
   def fewest_tackles(season)
      games_this_season = season_games_by_id(season)
      tackles = Hash.new(0)
      @data_game_teams.each do |data_game_team|
         tackles[data_game_team.team_id] += data_game_team.tackles if games_this_season.include?(data_game_team.game_id)
      end
      
      least_tackles = tackles.min_by {|data_game_team , total_tackles| total_tackles}.first

      convert_team_id_to_name(least_tackles)
   end


#Helper Methods
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

   def highest_team_accuracy(season)
      team_stats_this_season = team_stats_by_season(season)

      total_goals = total_goals_by_team(team_stats_this_season)
      
      total_shots = total_shots_by_team(team_stats_this_season)
      
      most_accurate_team = find_average(total_goals, total_shots).max_by {|team, avg_goals| avg_goals}
   end

   def lowest_team_accuracy(season)
      team_stats_this_season = team_stats_by_season(season)

      total_goals = total_goals_by_team(team_stats_this_season)
      
      total_shots = total_shots_by_team(team_stats_this_season)
      
      least_accurate_team = find_average(total_goals, total_shots).min_by {|team, avg_goals| avg_goals}
   end

   def team_stats_by_season(season)
      games_this_season = season_games_by_id(season)
      
      team_stats_this_season = []
      @data_game_teams.find_all do |game_team| 
         team_stats_this_season << game_team if games_this_season.include?(game_team.game_id)
      end
      team_stats_this_season
   end

   def total_goals_by_team(team_stats_by_season)
      total_goals = team_stats_by_season.each_with_object(Hash.new(0)) do |game_team, team_hash|
         team_hash[game_team.team_id] += game_team.goals
      end
   end

   def total_shots_by_team(team_stats_by_season)
      total_shots_by_team = team_stats_by_season.each_with_object(Hash.new(0)) do |game_team, team_hash|
         team_hash[game_team.team_id] += game_team.shots
      end
   end

   def find_average(smaller_hash, bigger_hash)
      average = Hash.new(0)
      smaller_hash.each do |key1, value_1|
         bigger_hash.each do |key2, value_2|
            average[key1] = (value_1.to_f / value_2.to_f).round(4) if key1 == key2
         end
      end
      average
   end

   def season_games_by_id(season)
      season_games = []
      @data_games.find_all do |game| 
         season_games << game.game_id if game.season == season
      end
      season_games
   end

   def coaches_by_season(season_id)
      games_this_season = season_games_by_id(season_id)

      coaches = []
      @data_game_teams.find_all do |game_team|
         coaches << game_team.head_coach if games_this_season.include?(game_team.game_id)
      end
      coaches.uniq
   end
end