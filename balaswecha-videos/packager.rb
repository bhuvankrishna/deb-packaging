#!/usr/bin/env ruby

require 'fileutils'

video_meta_data = "../videos/videos.rb"
require video_meta_data

def get_dependency_videos()
  return $videos.map { |video| video["name"].split('.').first }.join(', ')
end

video = 'balaswecha-videos'

def generate_meta_files(video, version, dependency_str)
  puts "Generating Deb files ..."
  Dir.mkdir('debian')
  Dir.chdir('debian') do
    generate_changelog(video)
    generate_control(video, dependency_str)
    generate_compat()
    generate_copyright()
    generate_rules()
    generate_format()
  end
end

def generate_copyright()
  contents = <<-FILE.gsub(/^ {4}/, '')
    GPL V3
  FILE
  File.write('copyright', contents)
end

def generate_rules()
  contents = <<-FILE.gsub(/^ {4}/, '')
    #!/usr/bin/make -f
    %:
    	dh $@
    override_dh_usrlocal:
  FILE
  File.write("rules", contents)
end

def generate_format()
  Dir.mkdir('source')
  Dir.chdir('source') do
    contents = <<-FILE.gsub(/^ {6}/, '')
      3.0 (quilt)
    FILE
    File.write('format', contents)
  end
end

def generate_control(video, dependency_str)
  contents = <<-FILE.gsub(/^ {4}/, '')
    Source: #{video}
    Maintainer: Balaswecha Team<balaswecha-dev-team@thoughtworks.com>
    Section: misc
    Priority: optional
    Standards-Version: 3.9.2
    Build-Depends: debhelper (>= 9)

    Package: #{video}
    Architecture: all
    Depends: ${shlibs:Depends}, ${misc:Depends}, #{dependency_str}
    Description: Meta-package for all BalaSwecha video packages
  FILE
  File.write('control', contents)
end

def generate_changelog(video)
  contents = <<-FILE.gsub(/^ {4}/, '')
#{video} (1.0-1) UNRELEASED; urgency=low

      * Initial release. (Closes: #XXXXX)

     -- Balaswecha Team <balaswecha-dev-team@thoughtworks.com>  #{Time.now.strftime '%a, %-d %b %Y %H:%M:%S %z'}
  FILE
  File.write('changelog', contents)
end

def generate_compat()
  File.write('compat', "9\n")
end

def generate_deb
  `debuild -i -us -uc -b`
  puts "Done!"
end

FileUtils.rm_rf 'dist'
Dir.mkdir('dist')
Dir.chdir('dist') do
  version = "1.0"
  Dir.mkdir("#{video}-#{version}")
  Dir.chdir("#{video}-#{version}") do
    dependency_str = get_dependency_videos()
    puts dependency_str
    generate_meta_files(video, version, dependency_str)
    generate_deb
  end
end
