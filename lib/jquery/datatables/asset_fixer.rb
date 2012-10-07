module Jquery
  module Datatables
    class AssetFixer
      def self.fix(files, options, &block)
        files.each do |file_path|
          content = File.read(file_path)
          options["replacements"].each { |pat, sub| content.gsub!(pat, sub) } if options["replacements"]

          File.open(file_path, 'w') { |f| f << content }
          File.rename(file_path, "#{file_path}.#{options["extension"]}") if options[:extension]

          print "Fixed asset URLs in #{file_path}.\n" if options[:verbose]
        end
      end
    end
  end
end