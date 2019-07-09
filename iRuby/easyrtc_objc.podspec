Pod::Spec.new do |spec|
  spec.name                  = 'easyrtc_objc'
  spec.version               = '283.0.0'
  spec.author                = 'X'
  spec.license               = { :type => 'https://webrtc.org/license/software/',
                                 :text => <<-LICENSEEOF
Copyright (c) 2011, The WebRTC project authors. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

  * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.

  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.

  * Neither the name of Google nor the names of its contributors may
    be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
LICENSEEOF
                               }
  spec.homepage              = 'https://github.com/NewSachsen/easyrtc'
  spec.summary               = 'A wrapper of WebRTC native API'
  spec.source                = { :http => 'http://10.0.1.112:8081/artifactory/yijian-easyrtc/libs-release-local/easyrtc/283.0.0/libeasyrtc_objc.tar.gz' }
  spec.public_header_files   = "Easyrtc/*.h"
  spec.source_files          = "Easyrtc/*.h"
  spec.requires_arc          = true
  spec.ios.frameworks        = 'AVFoundation', 'AudioToolbox', 'CoreGraphics', 'CoreMedia', 'GLKit', 'UIKit', 'VideoToolbox'
  spec.ios.deployment_target = '8.0'
  spec.ios.libraries         = 'm', 'stdc++'
  spec.ios.preserve_paths    = 'libeasyrtc_objc_fat.a', 'version'
  spec.ios.vendored_library  = 'libeasyrtc_objc_fat.a'
end
