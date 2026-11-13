import Foundation
import UIKit

class TrollLikeInstaller {
    static let shared = TrollLikeInstaller()
    private let systemAppPath = "/var/containers/Bundle/Application/"
    
    func install(ipaURL: URL) throws -> Bool {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        let unzipTask = Process()
        unzipTask.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        unzipTask.arguments = ["-q", ipaURL.path, "-d", tempDir.path]
        try? unzipTask.run()
        unzipTask.waitUntilExit()
        
        let payloadDir = tempDir.appendingPathComponent("Payload")
        guard let appFolder = try? FileManager.default.contentsOfDirectory(atPath: payloadDir.path).first(where: { $0.hasSuffix(".app") }) else { return false }
        
        let appBundleURL = payloadDir.appendingPathComponent(appFolder)
        
        // النقل إلى مسار النظام والتسجيل
        let finalPath = URL(fileURLWithPath: systemAppPath).appendingPathComponent(appFolder)
        if FileManager.default.fileExists(atPath: finalPath.path) {
            try? FileManager.default.removeItem(at: finalPath)
        }
        try FileManager.default.moveItem(at: appBundleURL, to: finalPath)
        
        let uicache = Process()
        uicache.executableURL = URL(fileURLWithPath: "/usr/bin/uicache")
        uicache.arguments = ["-p", finalPath.path]
        try? uicache.run()
        uicache.waitUntilExit()
        
        return true
    }
}
