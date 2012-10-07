module Jquery
  module Datatables
    class AssetFixer
      def self.fix(files, options, &block)
        files.each do |file_path|
          content = File.read(file_path)

          if options["replacements"]
            options["replacements"].each do |reg, sub|
              reg = Regexp.new(reg)
              sub.respond_to?(:call) ? content.gsub!(reg, &sub) : content.gsub!(reg, sub)
            end
          end

          File.open(file_path, 'w') { |f| f << content }
          File.rename(file_path, "#{file_path}.#{options["extension"]}") if options[:extension]

          print "Fixed asset URLs in #{file_path}.\n" if options[:verbose]
        end
      end
    end
  end
end