module Lorenz
  module Node
    %w{base path file directory package gem service ln git execute deploy cron collector}.each do |f|
      # puts "lorenz/node/#{f}"
      require "lorenz/node/#{f}"
    end
  end
end