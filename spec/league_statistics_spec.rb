require 'spec_helper'

RSpec.describe LeagueStats do
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
      league_stats = LeagueStats.new

      expect(league_stats).to be_a LeagueStats
   end

   describe '#count_of_teams' do
      it 'can count teams' do
         expect(@stat_tracker.count_of_teams).to eq(20)
      end
   end

   describe '#best_offense' do
      it 'can identify the best offense' do
         expect(@stat_tracker.best_offense).to eq("FC Dallas")
      end
   end

   describe '#worst_offense' do
      it 'can identify the worst offense' do
         expect(@stat_tracker.worst_offense).to eq("Sporting Kansas City")
      end
   end

   describe '#highest_scoring_visitor' do
      it 'can identify highest scoring visitor' do
        expect(@stat_tracker.highest_scoring_visitor).to eq("FC Dallas")
      end
   end
   
   describe '#highest_scoring_home_team' do
      it  'can identify highest scoring home team' do
         expect(@stat_tracker.highest_scoring_home_team).to eq("FC Dallas")
      end
   end
   
   describe '#lowest_scoring_visitor' do
      it  'can identify lowest scoring visitor' do
         expect(@stat_tracker.lowest_scoring_visitor).to eq("Sporting Kansas City")
      end
   end

   describe '#lowest_scoring_home_team' do
      it  'can identify lowest scoring home team' do
         expect(@stat_tracker.lowest_scoring_home_team).to eq("Sporting Kansas City")
      end
   end
end