
Pod::Spec.new do |s|
  s.name         = "Lingonberry"
  s.version      = "0.1.0"
  s.summary      = "Custom UISlider with nodes to show discrete values."
  s.homepage     = "https://github.com/tflhyl/Lingonberry"
  s.license      = { :type => "MIT" }
  s.author       = { "tflhyl" => "tflhyl@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/tflhyl/Lingonberry.git", :tag => "v0.1.0" }
  s.source_files = "Sources"
  s.requires_arc = true
end
