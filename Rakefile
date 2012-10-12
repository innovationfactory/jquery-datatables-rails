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
namespace :dt do
  desc "Download DataTables source files and place them in the correct locations."
  task :install

  namespace :extras do
    desc "Installs all extras as specified in /install.yml."
    task :install do
      yml = File.read("extras.yml")
      extras = YAML.load(yml)
      extras.each do |name, conf|
        extra = Jquery::Datatables::Extra.new(name, conf.merge("verbose" => true))
        extra.install!
      end
    end
    namespace :install do
      # Catch-all task for `rake extras:install:[ExtraName]`
      rule "" do |t|
        extra_name = t.name.split(":").last
      end
    end
  end
end