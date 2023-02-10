require "toml"
require "xdg_basedir"
require "./lib/libminiflux.cr"
require "./lib/rendering.cr"

module Cliflux
  VERSION = "0.1.0"

  class Main
    @config : TOML::Table

    def initialize
      @config = get_config()
    end

    def get_config() : TOML::Table
      config_path = XDGBasedir.full_path("cliflux/config.toml", :config, :read)
      if !(config_path) || !(File.exists?(config_path))
        puts "You need to provide a configuration file in your XDG base configuration directory (try something like ~/.config/cliflux/config.toml)"
        exit 1
      end
      raw_contents = File.read(config_path)
      return TOML.parse(raw_contents)
    end

    def run()
      client = LibMiniflux::Client.new(@config["url"].as(String), @config["api_key"].as(String))
      window = Rendering::MainWindow.setup
      window.on(Rendering::MainWindow::QuitProgram) do
        exit 0
      end
      spawn do
        window.render_feed_entries(client.get_unread_entries(10, 0))
      end
      window.start
    end
  end

end

app = Cliflux::Main.new()
app.run()
