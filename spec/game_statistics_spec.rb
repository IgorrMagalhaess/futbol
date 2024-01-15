require 'spec_helper'

RSpec.describe GameStats do
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
      game_stats = GameStats.new

      expect(game_stats).to be_a GameStats
   end

   describe '#highest_total_score' do
      it 'returns highest sum of winning and losing team score' do
         expect(@stat_tracker.highest_total_score).to eq(5)
      end
   end

   describe '#lowest_total_score' do
      it 'returns lowest sum of winning and losing team score' do
         expect(@stat_tracker.lowest_total_score).to eq(1)
      end
   end

   describe '#percentage_home_wins' do
      it 'returns percentage of games that a home team has won' do
         expect(@stat_tracker.percentage_home_wins).to eq(0.7)
      end
   end

   describe '#percentage_visitor_wins' do
      it 'returns percentage of games that a visitor has won' do
         expect(@stat_tracker.percentage_visitor_wins).to eq(0.25)
      end
   end

   describe '#percentage_ties' do
      it 'returns percentage of games that has resulted in a tie' do
         expect(@stat_tracker.percentage_ties).to eq(0.05)
      end
   end

   describe '#count_of_games_by_season' do
      it 'returns hash with season names as keys and counts of games as values' do
            expect(@stat_tracker.count_of_games_by_season).to eq({
               "20122013" => 20
            })
      end
   end

   describe '#average_goals_per_game' do
      it 'average of goals scored in a game across all seasons including both home and away goals' do
         expect(@stat_tracker.average_goals_per_game).to eq (3.75)
      end
   end

   describe '#average_goals_by_season' do
      it 'returns avg number of goals in a game across all season' do
         expect(@stat_tracker.average_goals_by_season).to eq({
               "20122013" => 3.75
            })
      end
   end
end