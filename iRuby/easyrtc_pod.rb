
def pingable?(host, timeout=5)
  # 10.0.1.112 not pingable 
  #system "ping -c 1 -t #{timeout} #{host} >/dev/null"
  return true
end

def logerror(msg)
  red = "\033[0;31m"
  nc = "\033[0m" # No Color
  STDERR.puts "#{red}#{msg}#{nc}"
end

def loginfo(msg)
  green = "\033[0;32m"
  nc = "\033[0m" # No Color
  STDERR.puts "#{green}#{msg}#{nc}"
end

module EasyrtcPod
  EASYRTC_PODSPEC_URL = ENV['EASYRTC_PODSPEC_URL']
  EASYRTC_DEFAULT_PODSPEC_URL_BASE = 'http://10.0.1.112:8081/artifactory/yijian-easyrtc/libs-release-local/easyrtc'
  EASYRTC_DEFAULT_PODSPEC_NAME = 'easyrtc_objc.podspec'
  EASYRTC_DEV_ROOT = ENV['EASYRTC_DEV_ROOT']
  EASYRTC_OBJC_DEV_CONFIGURATION = ENV['EASYRTC_OBJC_DEV_CONFIGURATION'] || 'Debug'
  EASYRTC_DIST_PATH = File.expand_path("../../out_dist/#{EASYRTC_OBJC_DEV_CONFIGURATION}", EASYRTC_DEV_ROOT)
  EASYRTC_DIST_BUILD_PATH = File.expand_path("../Build#{EASYRTC_OBJC_DEV_CONFIGURATION}", EASYRTC_DIST_PATH)

  def easyrtc_pod(version, options={})
    if !EASYRTC_DEV_ROOT
      require 'net/http'
      podspec_url = EASYRTC_PODSPEC_URL || "#{EASYRTC_DEFAULT_PODSPEC_URL_BASE}/#{version}/#{EASYRTC_DEFAULT_PODSPEC_NAME}"
      if pingable? URI.parse(podspec_url).host
        opts = options.dup
        opts[:podspec] = podspec_url
        pod 'easyrtc_objc', opts
      else
        logerror "Warning: pod 'easyrtc_objc' isn't in used, because \"#{podspec_url}\" is inaccessible.\nPlease check your network environment and then retry."
      end
    else
      easyrtc_objc_dev_path = File.expand_path("../../out_dist/#{EASYRTC_OBJC_DEV_CONFIGURATION}", EASYRTC_DEV_ROOT)
      if File.directory?(EASYRTC_DIST_PATH)
        opts = options.dup
        opts[:path] = EASYRTC_DIST_PATH
        pod 'easyrtc_objc_dev', opts
        using_easyrtc_objc_dev!
      else
        generate_cmd = "CONFIGURATION=#{EASYRTC_OBJC_DEV_CONFIGURATION} #{File.expand_path('build/dist_ios.sh', EASYRTC_DEV_ROOT)}"
        logerror "Error: \"#{easyrtc_objc_dev_path}\" isn't a directory!\nPlease make sure you had run `#{generate_cmd}` successfully."
        exit 1
      end
    end
  end

  def using_easyrtc_objc_dev!
    @_using_easyrtc_objc_dev = true
  end

  def is_using_easyrtc_objc_dev?
    return !!@_using_easyrtc_objc_dev
  end

  def add_easyrtc_sources_xcodeproj_to_workspace
    return if !EASYRTC_DEV_ROOT
    sources_project_name = 'sources.xcodeproj'
    xcodeproj_path = File.expand_path(sources_project_name, EASYRTC_DIST_BUILD_PATH)
    if !File.directory?(xcodeproj_path)
      generate_cmd = "CONFIGURATION=#{EASYRTC_OBJC_DEV_CONFIGURATION} #{File.expand_path('build/dist_ios.sh', EASYRTC_DEV_ROOT)}"
      logerror "Error: \"#{xcodeproj_path}\" doesn't exist!\nPlease run `#{generate_cmd}` first."
      return
    end

    workspace_path = Private.find_workspace_in(Pathname.pwd)
    if !workspace_path
      logerror "Error: No xcode workspace found"
      return
    end
    workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)
    project_file_reference = Xcodeproj::Workspace::FileReference.new(xcodeproj_path)
    if !workspace.include?(project_file_reference)
      workspace << xcodeproj_path
      workspace.save_as(workspace_path)
      loginfo "Added #{xcodeproj_path} to workspace"
    end
    workspace.file_references.each do |ref|
      if ref.path.end_with?(sources_project_name) && ref != project_file_reference
        logerror "Error: Detected multiply #{sources_project_name} in the workspace, you should remove the unrelated one manually."
        break
      end
    end
  end

  def add_build_phase_for_easyrtc_objc_dev(pods_project)
    aggregate_target = pods_project.new_aggregate_target("easyrtc_objc_dev")
    shell_phase = aggregate_target.new_shell_script_build_phase("Compile easyrtc_objc_dev")
    shell_phase.shell_script = "#{`which ninja`.strip} -C #{EASYRTC_DIST_BUILD_PATH} dist_easyrtc_objc"
    pods_project.targets.each do |target|
      if target.name.start_with? 'Pods'
        target.add_dependency(aggregate_target)
        loginfo "Added target \"easyrtc_objc_dev\" as a dependency of #{target.name}"
      end
    end
  end

  def integrate_xcode_project(installer)
    if is_using_easyrtc_objc_dev?
      self.add_easyrtc_sources_xcodeproj_to_workspace
      self.add_build_phase_for_easyrtc_objc_dev(installer.pods_project)
    end
  end

  module Private
    def self.find_workspace_in(path)
      path.children.find {|fn| fn.extname == '.xcworkspace'} || find_workspace_in_parent(path)
    end

    def self.find_workspace_in_parent(path)
      find_workspace_in(path.parent) unless path.root?
    end
  end

  def self.extended(klass_or_obj)
    if klass_or_obj.kind_of?(Pod::Podfile)
      podfile = klass_or_obj
      # Monkey patch the post_install method to allow installing multi hooks
      podfile.post_install do |installer|
          podfile._invoke_my_post_install_hooks(installer)
      end
      podfile.define_singleton_method(:post_install) do |&block|
          @_my_post_install_hooks ||= []
          @_my_post_install_hooks << block
      end
      podfile.define_singleton_method(:_invoke_my_post_install_hooks) do |installer|
          (@_my_post_install_hooks || []).each {|x| x.call(installer)}
      end
      # Install hook for modifying the xcode workspace
      podfile.post_install do |installer|
        installer.podfile.integrate_xcode_project(installer)
      end
    else
      logerror 'Waterloo hack...'
    end
  end
end
