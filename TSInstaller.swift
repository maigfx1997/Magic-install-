import Foundation
import UIKit
import Darwin

class TrollLikeInstaller {
    static let shared = TrollLikeInstaller()
    private let systemAppPath = "/var/containers/Bundle/Application/"
    
    func install(ipaURL: URL) throws -> Bool {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        // فك الضغط عبر أوامر النظام المباشرة لـ iOS
        let unzipCmd = "/usr/bin/unzip -q \(ipaURL.path) -d \(tempDir.path)"
        system(unzipCmd)
        
        let payloadDir = tempDir.appendingPathComponent("Payload")
        guard let appFolder = try? FileManager.default.contentsOfDirectory(atPath: payloadDir.path).first(where: { $0.hasSuffix(".app") }) else { return false }
        
        let appBundleURL = payloadDir.appendingPathComponent(appFolder)
        
        let finalPath = URL(fileURLWithPath: systemAppPath).appendingPathComponent(appFolder)
        if FileManager.default.fileExists(atPath: finalPath.path) {
            try? FileManager.default.removeItem(at: finalPath)
        }
        try FileManager.default.moveItem(at: appBundleURL, to: finalPath)
        
        // التسجيل في النظام
        let uicacheCmd = "/usr/bin/uicache -p \(finalPath.path)"
        system(uicacheCmd)
        
        return true
    }
}
