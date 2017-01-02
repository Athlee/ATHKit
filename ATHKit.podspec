Pod::Spec.new do |s|

s.name                  = "ATHKit"
s.version               = "0.0.2"
s.summary               = "ATHKit is a collection of customizable UI components such as ImagePickerController and more."
s.homepage              = "https://github.com/Athlee/ATHKit"
s.license               = { :type => "MIT", :file => "LICENSE" }
s.author                = { "Eugene Mozharovsky" => "mozharovsky@live.com" }
s.social_media_url      = "http://twitter.com/dottieyottie"
s.platform              = :ios, "9.0"
s.ios.deployment_target = "9.0"
s.source                = { :git => "https://github.com/Athlee/ATHKit.git", :tag => s.version }
s.source_files          = "Source/*.swift"
#s.resources             = "Source/*.{lproj,storyboard,xcassets}"

s.resource_bundle = {
'Paramount' => ['Sources/Paramount.bundle/*.png']
}

s.requires_arc          = true

s.dependency "Material"
s.dependency "ImagePickerKit"

end
