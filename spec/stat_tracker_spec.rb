require 'spec_helper'

RSpec.describe StatTracker do
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
      expect(@stat_tracker).to be_a StatTracker
   end

   describe '#read_games_csv' do
      it 'create game objects' do
         location = './data/games_fixture.csv'

         expect(stat_tracker.read_games_csv(location)[0]).to be_a Game
      end
   end
end