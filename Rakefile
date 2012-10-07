require "bundler/gem_tasks"
#require "jquery/datatables/asset_fixer"
require "jquery/datatables/extra"

# desc "Fixes css image paths in scss files."
# task :fix_css do
#   files = Dir.glob(File.join("vendor/assets/stylesheets/dataTables", "*.css.scss"))
#   Jquery::Datatables::CssFixer.fix(files) do |path|
#     path.sub("../images", "dataTables")
#   end
#   print "Done.\n"
# end


namespace :extras do
	task :update do
    yml = File.read("extras.yml")
    extras = YAML.load(yml)
    print extras.inspect
    extras.each do |name, conf|
      extra = Jquery::Datatables::Extra.new(name, conf.merge("verbose" => true))
      extra.install!
    end
  end
end

