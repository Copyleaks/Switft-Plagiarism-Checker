/*
 * The MIT License(MIT)
 *
 * Copyright(c) 2016 Copyleaks LTD (https://copyleaks.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

import Foundation

private let copyleaksToken = "copyleaksToken"

class CopyleaksToken: NSObject, NSCoding {
    
    var accessToken: String?
    var issued: String?
    var expires: String?

    private let copyleaksTokenKey = "copyleaksTokenKey"
    private let copyleaksTokenIssued = "copyleaksTokenIssued"
    private let copyleaksTokenExpired = "copyleaksTokenExpired"
    
    init(response: CopyleaksResponse<AnyObject, NSError>) {
        accessToken = response.result.value?["access_token"] as? String
        issued = response.result.value?[".issued"] as? String
        expires = response.result.value?[".expires"] as? String
    }
    
    required init(coder aDecoder: NSCoder) {
        accessToken = aDecoder.decodeObjectForKey(copyleaksTokenKey) as? String
        issued = aDecoder.decodeObjectForKey(copyleaksTokenIssued) as? String
        expires = aDecoder.decodeObjectForKey(copyleaksTokenExpired) as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(accessToken, forKey: copyleaksTokenKey)
        aCoder.encodeObject(issued, forKey: copyleaksTokenIssued)
        aCoder.encodeObject(expires, forKey: copyleaksTokenExpired)
    } 

    func save() {
        let data  = NSKeyedArchiver.archivedDataWithRootObject(self)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(data, forKey:copyleaksToken )
    }
    
    
    func isValid() -> Bool {
        
        guard let
            _ = accessToken,
            _ = issued,
            expiresVal = expires else {
                return false
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = CopyleaksConst.dateTimeFormat
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        
        let expiresDate = dateFormatter.dateFromString(expiresVal)

        if NSDate().compare(expiresDate!) == .OrderedAscending {
            return true
        }
        return false
    }
    
    func generateAccessToken() -> String {
        guard let accessTokenVal = accessToken else {
            return ""
        }
        return "Bearer " + accessTokenVal
    }
    
    class func hasAccessToken() -> Bool {
        guard let _ = getAccessToken() else {
            return false
        }
        return true
    }

    class func getAccessToken() -> CopyleaksToken? {
        guard let data = NSUserDefaults.standardUserDefaults().objectForKey(copyleaksToken) as? NSData else {
            return nil
        }
        return (NSKeyedUnarchiver.unarchiveObjectWithData(data) as? CopyleaksToken)!
    }
    

    class func clear() {
         NSUserDefaults.standardUserDefaults().removeObjectForKey(copyleaksToken)
    }


}
