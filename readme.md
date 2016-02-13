Native Swift project supporting nickel-elements.

Usage :
- create a single view application
- create a pod file and add the NickelSwift dependency

```
# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'CircuitTraining' do
   pod 'NickelSwift', :git => 'https://github.com/riana/NickelSwift'
end

target 'CircuitTrainingTests' do

end
```
- Copy the vulcanized Polymer app into the project folder
- Make the main view controller extend NickelWebViewController and the MainPage

```
import NickelSwift

class ViewController: NickelWebViewController {
   override func viewDidLoad() {
          super.viewDidLoad()
          // Do any additional setup after loading the view, typically from a nib.
          setMainPage("www/index")
   }
}
```
