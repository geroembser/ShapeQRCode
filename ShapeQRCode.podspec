Pod::Spec.new do |s|
s.name = 'ShapeQRCode'
s.version = '1.0.0'
s.author = 'Gero Embser'
s.homepage = 'https://github.com/geroembser/ShapeQRCode'
s.license = { :type => 'MIT', :file => 'LICENSE' }

s.summary = 'Swift QR code generator where the black squares can be replaced by shapes and images can be included in the QRCode'

s.source = { :git => 'https://github.com/geroembser/ShapeQRCode.git', :tag => s.version }

s.ios.deployment_target = '12.0'
s.swift_version = '4.2'

#define the source files
s.source_files = 'Source/*.swift'

end
