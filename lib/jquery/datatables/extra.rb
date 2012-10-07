require 'jquery/datatables/asset_fixer'

module Jquery
  module Datatables
    class Extra
      ROOT = File.expand_path("../../..", File.dirname(__FILE__))

      # NOTE Prefixed with /tmp for testing. Remove when ready.
      ASSET_PATH = File.join(ROOT, "tmp/vendor/assets")

      # Target paths per media type. Relative to ASSET_PATH.
      # These placeholders will be replaced:
      #
      # [:extra] Name of the plugin.
      # [:type]  Media type (eg. 'js', 'css', 'images', ...)
      #
      DEFAULT_MEDIA_TARGETS = {
        "js"     => "javascripts/dataTables/extras",
        "css"    => "stylesheets/dataTables/extras",
        "images" => "images/dataTables/extras/:extra",
        "other"  => "media/dataTables/extras/:extra/:type"
      }

      # Home of images on the web; for SCSS's image-url().
      IMAGE_URL_PREFIX = "dataTables/extras/:extra"

      # Location where downloaded source code is kept.
      SOURCE_PATH = File.join(ROOT, "/tmp/extras")

      def initialize(name, options)
        @name    = name
        @source  = options["source"]
        unless @source
          @url = options["url"] || begin
            version = options["version"] || raise("Version is required.")
            tag = "RELEASE_#{version.gsub(".", "_")}"
            "https://github.com/DataTables/#{@name}/tarball/#{tag}"
          end
        end
        @verbose = options["verbose"]
        @targets = DEFAULT_MEDIA_TARGETS.tap do |targets|
          targets.merge!(options["media"]) if options["media"]
        end
        @fixes = [
          # Default fix for replacing url() with image-url() in stylesheets:
          {
            "pattern" => "stylesheets/**/*.css",
            "extension" => "scss",
            "replacements" => [
              [ /url\(["']?\.\.\/images\/([A-Za-z0-9_\.\/]+)['"]?\)/, 'image-url(\'blabla/\1\')' ]#->(m) { print m.inspect; "image-url('" + "".sub("../images", IMAGE_URL_PREFIX.gsub(/:extra/, @name)) + "')" } ]
            ]
          }
        ]
        @fixes += options["fixes"] if options[:fixes]
      end

      def self.remove(name)
        # ...
      end

      def install
        @source ? copy_source : download_source
        copy_media
        fix_assets
      ensure
        cleanup
      end

      def install!
        self.class.remove(@name)
        install
      end

      protected

      def verbose?
        !!@verbose
      end

      def cleanup
        FileUtils.rm_rf SOURCE_PATH
      end

      def copy_source
        FileUtils.mkdir_p SOURCE_PATH
        FileUtils.cp_r @source, SOURCE_PATH
      end

      def download_source
        FileUtils.mkdir_p SOURCE_PATH
        system("curl -L #{@url} | tar xz -C '#{SOURCE_PATH}'")
      end

      def media_dirs
        Dir.glob(File.join(SOURCE_PATH, "*/media/**"))
      end

      def copy_media
        media_dirs.each do |dir|
          type   = dir.split("/").last
          target = target_for_media_type(type)
          FileUtils.mkdir_p(target)
          FileUtils.cp_r "#{dir}/.", target
          print "Copied #{type} files.\n" if verbose?
          if index = index_for_media_type(type)
            File.open(File.join(target, "index.#{type}"),  "w") { |f| f << index }
            print "Created index file in #{target}\n" if verbose?
          end
        end
      end

      def target_for_media_type(type)
        target = @targets[type] || @targets["other"]
        target = target["target"] if target.is_a?(Hash)
        target = target.gsub(/:extra/, @name).gsub(/:type/, type)
        File.join(ASSET_PATH, target)
      end

      def index_for_media_type(type)
        case type
          when "js"  then index_for_js
          when "css" then index_for_css
          else false
        end
      end

      def index_for_css
        target = @targets["css"]
        return false unless target.is_a?(Hash) && target["index"].is_a?(Array) && target["index"].any?
        "/*\n" << target["index"].map{ |f| "*= require #{f}\n" }.join << "*/"
      end

      def index_for_js
        target = @targets["js"]
        return false unless target.is_a?(Hash) && target["index"].is_a?(Array) && target["index"].any?
        target["index"].map{ |f| "//= require #{f}" }.join("\n")
      end

      def fix_assets
        @fixes.each do |options|
          files = Dir.glob(File.join(ASSET_PATH, options.delete("pattern")))
          AssetFixer.fix(files, options)
        end
      end
    end
  end
end