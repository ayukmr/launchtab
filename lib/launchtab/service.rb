module LaunchTab
  # service from file
  class Service
    attr_accessor :mins, :hours, :days, :months, :wdays

    # create service
    def initialize(values, program)
      @id = SecureRandom.hex(6)

      @mins, @hours, @days, @months, @wdays = values
      @program = program
    end

    # generate plist
    def generate_plist
      template = Haml::Template.new(asset_path('service.haml'), format: :xhtml)
      rendered = template.render(self)

      # write plist file
      File.write(File.expand_path(
        File.join('~/Library/LaunchAgents', "launchtab-#{@id}.plist")
      ), rendered)

      # show message
      puts "generated service `launchtab-#{@id}.plist`".cyan
    end
  end
end
