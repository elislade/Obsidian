
import UIKit

struct UserAgent {
    
    static let main: String = {
        let bundleDict = Bundle.main.infoDictionary!
        let appName = bundleDict["CFBundleName"] as! String
        let appVersion = bundleDict["CFBundleShortVersionString"] as! String
        let appDescriptor = appName + "/" + appVersion
        let osDescriptor = "iOS/" + UIDevice.current.systemVersion
        
        return appDescriptor + " " + osDescriptor + " (" + hardwareString + ")"
    }()
    
    static let hardwareString: String = {
        var name: [Int32] = [CTL_HW, HW_MACHINE]
        var localName = name
        var size: Int = 2
        sysctl(&localName, 2, nil, &size, &name, 0)
        var hw_machine = [CChar](repeating: 0, count: Int(size))
        sysctl(&localName, 2, &hw_machine, &size, &name, 0)
        let hardware = String(cString: hw_machine)
        
        return hardware
    }()
}
