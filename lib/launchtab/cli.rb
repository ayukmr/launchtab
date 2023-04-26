module LaunchTab
  # launchtab cli
  module CLI
    class << self
      # run cli with argv
      def run(argv)
        help if argv.empty?

        # ensure files exists
        argv.each do |file|
          error "file `#{file.tilde}` does not exist" unless File.exist?(file)
          puts file.tilde.magenta.bold

          # create services
          LaunchTab::Parser
            .parse(File.read(file).lines)
            .map(&:generate_plist)

          puts
        end
      end

      # show help and exit
      def help
        puts <<~HELP
          #{'usage'.magenta.bold}:
            #{'ltab'.blue} #{'<file>'.yellow}

          #{'examples'.magenta.bold}:
            #{'ltab'.blue} #{'services.ltab'.yellow}  add services from services.ltab
        HELP

        exit 0
      end
    end
  end
end
