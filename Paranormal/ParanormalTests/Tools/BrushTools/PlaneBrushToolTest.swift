import Cocoa
import Quick
import Nimble
import Paranormal

class PlaneToolTest: QuickSpec {
    override func spec() {
        describe("PlaneTool") {
            var editorViewController : EditorViewController!
            var document : Document?
            var editorView : EditorView?
            var planeTool : PlaneTool!

            beforeEach {
                editorViewController = EditorViewController(nibName: "Editor", bundle: nil)
                editorView = editorViewController.view as? EditorView
                let documentController = DocumentController()
                for doc in documentController.documents {
                    documentController.removeDocument(doc as NSDocument)
                }

                documentController.createDocumentFromUrl(nil)
                document = documentController.documents[0] as? Document

                editorViewController.document = document

                editorViewController?.activeEditorTool = PlaneTool()
                planeTool = editorViewController.activeEditorTool! as PlaneTool
                expect(ThreadUtils.doneProcessingGPUImage()).toEventually(beTrue())
            }

            describe("Drawing lays down plane at correct angle") {
                it("Without opacity") {
                    document?.toolSettings.setColorAsNSColor(
                        NSColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0))
                    document?.toolSettings.size = 5.0;
                    document?.toolSettings.strength = 1.0;

                    planeTool.mouseDownAtPoint(NSPoint(x: 20, y: 20),
                        editorViewController: editorViewController)

                    planeTool.mouseDraggedAtPoint(NSPoint(x: 60, y: 60),
                        editorViewController: editorViewController)

                    planeTool.mouseUpAtPoint(NSPoint(x: 40, y: 40),
                        editorViewController: editorViewController)
                    expect(planeTool.drawingKernel?.doneDrawing()).toEventually(beTrue())

                    // kick the editor and document into updating
                    document?.computeDerivedData()
                    expect(ThreadUtils.doneProcessingGPUImage()).toEventually(beTrue())
                    let image = document?.computedExportImage

                    var color = NSImageHelper.getPixelColor(image!,
                        pos: NSPoint(x: 0, y:0))
                    expect(color).to(beNearColor(127, 127, 255, 255, tolerance: 1))

                    color = NSImageHelper.getPixelColor(image!,
                        pos: NSPoint(x: 40, y:40))
                    expect(color).to(beNearColor(255, 128, 128, 255, tolerance: 1))

                    color = NSImageHelper.getPixelColor(image!,
                        pos: NSPoint(x: 40, y:41))
                    expect(color).to(beNearColor(255, 128, 128, 255, tolerance: 1))

                    color = NSImageHelper.getPixelColor(image!,
                        pos: NSPoint(x: 40, y:46))
                    expect(color).to(beNearColor(127, 127, 255, 255, tolerance: 1))
                }
            }

            it("With opacity") {
                document?.toolSettings.setColorAsNSColor(NSColor(red: 1.0, green: 127.0 / 255.0,
                    blue: 127.0 / 255.0, alpha: 1.0))
                document?.toolSettings.size = 5.0;
                document?.toolSettings.strength = 0.5;

                planeTool.mouseDownAtPoint(NSPoint(x: 20, y: 20),
                    editorViewController: editorViewController)

                planeTool.mouseDraggedAtPoint(NSPoint(x: 60, y: 60),
                    editorViewController: editorViewController)

                planeTool.mouseUpAtPoint(NSPoint(x: 40, y: 40),
                    editorViewController: editorViewController)
                planeTool.stopUsingTool()
                expect(planeTool.drawingKernel?.doneDrawing()).toEventually(beTrue())

                // kick the editor and document into updating
                document?.computeDerivedData()
                expect(ThreadUtils.doneProcessingGPUImage()).toEventually(beTrue())
                let image = document?.computedExportImage

                var color = NSImageHelper.getPixelColor(image!,
                    pos: NSPoint(x: 0, y:0))
                expect(color).to(beColor(127, 127, 255, 255))

                color = NSImageHelper.getPixelColor(image!,
                    pos: NSPoint(x: 40, y:40))
                expect(color).to(beColor(218, 127, 218, 255))
            }
        }
    }
}
