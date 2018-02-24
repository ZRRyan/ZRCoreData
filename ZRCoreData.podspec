Pod::Spec.new do |s|
s.name         = "ZRCoreData"
s.version      = "1.0.2"
s.ios.deployment_target = '7.0'
s.summary      = "A delightful setting interface framework."
s.homepage     = "https://github.com/ZRRyan/ZRCoreData"
s.license              = { :type => "MIT", :file => "LICENSE" }
s.author             = { "ZRRyan" => "ruizhang1314@gmail.com" }
s.source       = { :git => "https://github.com/ZRRyan/ZRCoreData.git", :tag => s.version }
s.source_files  = "ZRCoreData/*"
s.requires_arc = true
end