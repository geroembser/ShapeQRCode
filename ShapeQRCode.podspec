Pod::Spec.new do |s|
s.name = 'ShapeQRCode'
s.version = '0.9.1'
s.author = 'Gero Embser'
s.homepage = 'https://github.com/geroembser/ShapeQRCode'
s.license = { :type => 'MIT', :file => 'LICENSE' }

s.summary = 'Swift QR code generator where the black squares can be replaced by shapes and images can be included in the QRCode'

s.source = { :git => 'https://github.com/geroembser/ShapeQRCode.git',
             :tag => s.version,
             :submodules => true
            }

s.ios.deployment_target = '12.0'
s.swift_version = '4.2'

#define the source files
s.source_files = 'Source/*.{swift,h,m}', 'nayuki-QR-Code-Generator/c/qrcodegen.{h,c}'
s.private_header_files = 'Source/QRCode.h', 'nayuki-QR-Code-Generator/c/qrcodegen.h'

#define build config stuff
s.pod_target_xcconfig  = { 'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/**' }
s.preserve_paths = 'module.modulemap'
s.compiler_flags = '-w' #turn off warnings...

end
