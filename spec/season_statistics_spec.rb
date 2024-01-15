require 'spec_helper'

RSpec.describe SeasonStats do
   before(:each) do
      game_path = './data/games_fixture.csv'
      team_path = './data/teams_fixture.csv'
      game_teams_path = './data/game_teams_fixture.csv'

      locations = {
         games: game_path,
         teams: team_path,
         game_teams: game_teams_path
      }

      @stat_tracker = StatTracker.from_csv(locations)
   end

   it 'exists' do
      season_stats = SeasonStats.new

      expect(season_stats).to be_a SeasonStats
   end

   describe '#winningest_coach(season)' do
      it 'can identify coach with most percentage of wins' do
         expect(@stat_tracker.winningest_coach("20122013")).to eq("Claude Julien")
      end
   end

   describe '#worst_coach(season)' do
      it 'can identify coach with least percentage of wins' do
         expect(@stat_tracker.worst_coach("20122013")).to eq("John Tortorella")
      end
   end

   describe '#most_accurate_team(season)' do
      it 'returns the name of the Team with the best ratio of shots to goals for the season' do
         expect(@stat_tracker.most_accurate_team("20122013")).to eq("FC Dallas")
      end
   end

   describe '#least_accurate_team(season)' do
      it 'returns the name of the Team with the worst ratio of shots to goals for the season' do
         expect(@stat_tracker.least_accurate_team("20122013")).to eq("Sporting Kansas City")
      end
   end

   describe '#most_tackles(season)' do
      it 'returns a team with most tackles in a season' do
         expect(@stat_tracker.most_tackles("20122013")).to eq("FC Dallas")
      end

   describe '#fewest_tackles(season)'
      it 'returns a team with least tackles in a season' do
         expect(@stat_tracker.fewest_tackles("20122013")).to eq("New England Revolution")
      end
   end

   # Helper Methods

   describe '#calculate_percentage' do
      it 'calculates percentages' do
         expect(@stat_tracker.calculate_percentage(20 , 30)).to eq(0.67)
      end
   end

   describe '#convert_team_id_to_name' do
      it 'converts id to name' do
         expect(@stat_tracker.convert_team_id_to_name(1)).to eq('Atlanta United')
      end
   end

   describe '#lowest_average_team_id(team_stats)' do
      it 'returns the team_id with the lowest average goals to games' do
         team_stats = {
            3=>{:goals=>8, :games_played=>5},
            6=>{:goals=>24, :games_played=>9},
            5=>{:goals=>2, :games_played=>4},
            17=>{:goals=>1, :games_played=>1},
            16=>{:goals=>2, :games_played=>1}
         }

         expect(@stat_tracker.lowest_average_team_id(team_stats)).to eq(5)
      end
   end

   describe '#highest_average_team_id(team_stats)' do
      it 'returns the team_id with the highest average goals to games' do
         team_stats = {
            3=>{:goals=>8, :games_played=>5},
            6=>{:goals=>24, :games_played=>9},
            5=>{:goals=>2, :games_played=>4},
            17=>{:goals=>1, :games_played=>1},
            16=>{:goals=>2, :games_played=>1}
         }

         expect(@stat_tracker.highest_average_team_id(team_stats)).to eq(6)
      end
   end

   describe '#team_stats' do
      it 'returns a hash with team_ids as keys, and a hash as value with goals and games_played key-value pairs' do
         expect(@stat_tracker.team_stats).to eq({
            3=>{:goals=>8, :games_played=>5},
            6=>{:goals=>24, :games_played=>9},
            5=>{:goals=>2, :games_played=>4},
            17=>{:goals=>1, :games_played=>1},
            16=>{:goals=>2, :games_played=>1}
         })
      end
   end

   describe '#team_stats_hoa' do
      it 'returns hash with team_id as keys and a hash as value with goals and games that match the argument passed key-value pairs' do
         expect(@stat_tracker.team_stats_hoa("away")).to eq({
            3=>{:games_played=>3, :goals=>5}, 
            6=>{:games_played=>4, :goals=>12}, 
            5=>{:games_played=>2, :goals=>1}, 
            17=>{:games_played=>1, :goals=>1}
         })
      end
   end

   describe '#highest_team_accuracy(season)' do
      it 'retuns an array with the team_id as first element and the best accuracy as second element' do
         expect(@stat_tracker.highest_team_accuracy("20122013")).to eq([6, 0.3158])
      end
   end

   describe '#lowest_team_accuracy(season)' do
      it 'retuns an array with the team_id as first element and the worst accuracy as second element' do
         expect(@stat_tracker.lowest_team_accuracy("20122013")).to eq([5, 0.0625])
      end
   end

   describe '#team_stats_by_season(season)' do
      it 'returns an array of game_team objects with only games that happened this season' do
         expect(@stat_tracker.team_stats_by_season("20122013")).to be_an Array
         expect(@stat_tracker.team_stats_by_season("20122013").first).to be_a GameTeam
         expect(@stat_tracker.team_stats_by_season("20122013").last).to be_a GameTeam
      end
   end

   describe '#total_goals_by_team(team_stats_by_season)' do
      it 'returns the total amount of goals a team scored in a season by team' do
         team_stats_season = @stat_tracker.team_stats_by_season("20122013")

         expect(@stat_tracker.total_goals_by_team(team_stats_season)).to eq({
            3=>8, 
            6=>24, 
            5=>2, 
            17=>1, 
            16=>2
         })
      end
   end

   describe '#total_shots_by_team(team_stats_by_season)' do
      it 'returns the total amount of shots a team scored in a season by team' do
         team_stats_season = @stat_tracker.team_stats_by_season("20122013")

         expect(@stat_tracker.total_shots_by_team(team_stats_season)).to eq({
            3=>38, 
            6=>76, 
            5=>32, 
            17=>5, 
            16=>10
         })
      end
   end

   describe '#find_average(smal_hash, big_hash)' do
      it 'returns a hash with the average of the values of two hashes' do
         hash1 = {3=>8, 6=>24, 5=>2, 17=>1, 16=>2}
         hash2 = {3=>38, 6=>76, 5=>32, 17=>5, 16=>10}

         expect(@stat_tracker.find_average(hash1, hash2)).to eq({
            3=>0.2105, 
            6=>0.3158, 
            5=>0.0625, 
            17=>0.2, 
            16=>0.2
         })
      end
   end

   describe '#season_games_by_id(season)' do
      it 'returns an array of games for the season' do
         expect(@stat_tracker.season_games_by_id("20122013")).to be_a Array 
         expect(@stat_tracker.season_games_by_id("20122013")[0]).to be_a String
      end
   end

   describe '#coaches_by_season(season)' do
      it 'returns an array of coaches that played this season' do
         expect(@stat_tracker.coaches_by_season("20122013")).to eq([
            "John Tortorella", 
            "Claude Julien", 
            "Dan Bylsma", 
            "Mike Babcock", 
            "Joel Quenneville"
         ])
      end
   end
end