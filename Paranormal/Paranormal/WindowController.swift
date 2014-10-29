import Foundation
import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {
    @IBOutlet weak var previewSettingsView: NSView!
    @IBOutlet weak var glView: CCGLView!
    var cgContext : CGContextRef?
    var previewSettings : PreviewSettings?

    override init(window: NSWindow?) {
        super.init(window:window)
    }

    func setUpCocos() {
        let director = CCDirector.sharedDirector() as CCDirector!
        director.setView(glView)

        let scene = TestScene()
        director.runWithScene(scene)
    }

    func tearDownCocos() {
        let director = CCDirector.sharedDirector() as CCDirector!
        // TODO correctly shutdown cocos2D
        //director.end()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func updatePreviewSettings() {
        previewSettings = PreviewSettings(context: document?.managedObjectContext)

        if let preview = previewSettings?.view {
            for sub in previewSettingsView.subviews {
                sub.removeFromSuperview()
            }
            previewSettingsView.addSubview(preview)

            // Place the view at the top
            let rect : NSRect! = preview.frame
            let container : NSRect! = previewSettingsView?.frame
            preview.frame = NSRect(x: 0,
                y: container.height - rect.height,
                width: rect.width,
                height: rect.height)
        }
    }

    override func windowDidLoad() {
        setUpCocos()
        updatePreviewSettings()
        
    }

    required init?(coder:NSCoder) {
        super.init(coder: coder)
    }

    override init() {
        super.init()
    }

    override var document : AnyObject? {
        // TODO this needs to now hold an array or something as
        // we are using a single window
        set(document) {
            super.document = document
            if (previewSettingsView != nil) {
                updatePreviewSettings()
            }
        }

        get {
            return super.document
        }
    }

    func windowWillClose(notification: NSNotification) {
        document?.close()
        tearDownCocos()
    }

    func windowWillReturnUndoManager(window: NSWindow) -> NSUndoManager? {
        let doc = document as Document?
        return doc?.undoManager
    }
}
