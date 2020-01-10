platform :ios, '10.0'
workspace 'MentorzWorkSpace.xcworkspace'
project 'abcd/abcd.xcodeproj'
project 'MentorzPostViewer/MentorzPostViewer.xcodeproj'

def shared_pods
pod 'SVProgressHUD'
pod 'TTTAttributedLabel'
pod "ExpandableLabel"
pod 'ObjectMapper', '~> 3.4'
pod 'Moya', '~> 13.0'
pod 'SDWebImage', '~> 5.0'
pod "PagingTableView"
pod "LinkPreviewKit"
pod 'IQKeyboardManager'
pod 'moa', '~> 12.0'


end

abstract_target 'Mentorz' do
  
  target 'abcd' do
    use_frameworks!
    project 'abcd/abcd.xcodeproj'
    shared_pods
  end
  
  target 'MentorzPostViewer' do
    use_frameworks!
    project 'MentorzPostViewer/MentorzPostViewer.xcodeproj'
    shared_pods
  end
end
