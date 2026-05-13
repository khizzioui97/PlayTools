//
//  AKPluginLoader.swift
//  PlayTools
//
//  Created by Isaac Marovitz on 13/09/2022.
//

import CoreGraphics
import Foundation

class AKInterface {
    public static var shared: Plugin?

    public static func initialize() {
        if let plugin = loadPlugin() {
            shared = plugin
            return
        }

        NSLog("PlayTools: failed to load AKInterface.bundle; using fallback plugin")
        shared = FallbackPlugin()
    }

    private static func loadPlugin() -> Plugin? {
        for bundleURL in candidateBundleURLs() {
            guard let bundle = Bundle(url: bundleURL) else {
                continue
            }

            if !bundle.isLoaded && !bundle.load() {
                continue
            }

            guard let pluginClass = bundle.principalClass as? Plugin.Type else {
                continue
            }

            return pluginClass.init()
        }

        return nil
    }

    private static func candidateBundleURLs() -> [URL] {
        let bundleName = "AKInterface.bundle"
        let frameworkBundle = Bundle(for: AKInterface.self)

        return [
            Bundle.main.builtInPlugInsURL?.appendingPathComponent(bundleName),
            Bundle.main.resourceURL?
                .appendingPathComponent("PlugIns")
                .appendingPathComponent(bundleName),
            frameworkBundle.builtInPlugInsURL?.appendingPathComponent(bundleName),
            frameworkBundle.resourceURL?
                .appendingPathComponent("PlugIns")
                .appendingPathComponent(bundleName),
            Bundle.main.privateFrameworksURL?
                .appendingPathComponent("PlayTools.framework")
                .appendingPathComponent("PlugIns")
                .appendingPathComponent(bundleName),
            frameworkBundle.bundleURL
                .appendingPathComponent("PlugIns")
                .appendingPathComponent(bundleName)
        ].compactMap { $0 }
    }
}

private final class FallbackPlugin: NSObject, Plugin {
    var screenCount: Int { 1 }
    var mousePoint: CGPoint { .zero }
    var windowFrame: CGRect { .zero }
    var mainScreenFrame: CGRect { .zero }
    var isMainScreenEqualToFirst: Bool { true }
    var isFullscreen: Bool { false }
    var cmdPressed: Bool { false }

    override init() {
        super.init()
    }

    func hideCursor() {}

    func hideCursorMove() {}

    func warpCursor() {}

    func unhideCursor() {}

    func terminateApplication() {}

    func setupKeyboard(keyboard: @escaping (UInt16, Bool, Bool, Bool) -> Bool,
                       swapMode: @escaping () -> Bool) {}

    func setupMouseMoved(_ mouseMoved: @escaping (CGFloat, CGFloat) -> Bool) {}

    func setupMouseButton(left: Bool, right: Bool, _ consumed: @escaping (Int, Bool) -> Bool) {}

    func setupScrollWheel(_ onMoved: @escaping (CGFloat, CGFloat) -> Bool) {}

    func urlForApplicationWithBundleIdentifier(_ value: String) -> URL? { nil }

    func setMenuBarVisible(_ value: Bool) {}
}
