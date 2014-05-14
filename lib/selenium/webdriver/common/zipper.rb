require 'tempfile'
require 'zipruby'
require 'find'

module Selenium
  module WebDriver
    #
    # @api private
    #

    module Zipper

      EXTENSIONS = %w[.zip .xpi]

      class << self

        def unzip(path)
          destination = Dir.mktmpdir("webdriver-unzip")
          FileReaper << destination

          Zip::Archive.open(path) do |ar|
            ar.each do |zf|
              file = File.join(destination, zf.name)

              if zf.directory?
                FileUtils.mkdir_p(file)
              else
                dirname = File.dirname(file)
                FileUtils.mkdir_p(dirname) unless File.exist?(dirname)

                open(file, 'wb') do |f|
                  f << zf.read
                end
              end
            end
          end

          destination
        end

        def zip(path)
          with_tmp_file do |zip|
            ::Find.find(path) do |file|
              unless File.directory?(file)
                zip.add_file path
              end
            end

            File.open(path, "rb") { |io| Base64.strict_encode64 io.read }
          end
        end

        def zip_file(path)
          with_tmp_file do |zip|
            zip.add_file path

            File.open(path, "rb") { |io| Base64.strict_encode64 io.read }
          end
        end

        private

        def with_tmp_file
          tmp_dir = Dir.mktmpdir
          zip_path = File.join(tmp_dir, "webdriver-zip")

          Zip::Archive.open(zip_path, Zip::CREATE) do |zip|
            yield zip
          end

          FileUtils.rm_rf tmp_dir
          FileUtils.rm_rf zip_path
        end

      end
    end # Zipper
  end # WebDriver
end # Selenium
