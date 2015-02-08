//
//  AppDelegate.swift
//  Icon for File
//
//  Created by Christian Mittendorf on 07/02/15.
//  Copyright (c) 2015 Christian Mittendorf. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var imageWell: NSImageView!
    @IBOutlet weak var textField: NSTextField!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }

    @IBAction func updateImageForFileExtension(sender: AnyObject) {
        let fileType = textField!.stringValue
        let workspace = NSWorkspace.sharedWorkspace()
        let image = workspace.iconForFileType(fileType)
        imageWell!.image = image
    }
    
}

class DraggableImageView: NSImageView, NSDraggingSource, NSPasteboardItemDataProvider {

    override func acceptsFirstMouse(theEvent: NSEvent) -> Bool {
        return true
    }
    
    override func mouseDown(theEvent: NSEvent) {
        if image == nil {
            return
        }

        var pbItem = NSPasteboardItem()
        pbItem.setDataProvider(self, forTypes:[NSPasteboardTypeTIFF, NSPasteboardTypePNG, NSPasteboardTypePDF])
        // let data = image!.pngData()
        // pbItem.setData(data, forType: NSPasteboardTypePNG)

        var dragItem = NSDraggingItem(pasteboardWriter: pbItem)
        
        // create an image from the size of this view to show while dragging
        let side = min(self.frame.size.width, self.frame.size.height)
        let dragImage = NSImage(size: NSMakeSize(side, side))
        dragImage.lockFocus()
        image!.drawInRect(NSMakeRect(0, 0, side, side))
        dragImage.unlockFocus()

        // calc the size of rect for dragging according to the image size
        let x = self.bounds.origin.x + ((self.bounds.size.width - side)/2)
        let y = self.bounds.origin.y + ((self.bounds.size.height - side)/2)
        let draggingRect = NSMakeRect(x, y, side, side)
        
        dragItem.setDraggingFrame(draggingRect, contents: dragImage)
        
        let dragSession = self.beginDraggingSessionWithItems([dragItem], event: theEvent, source: self)
        dragSession.animatesToStartingPositionsOnCancelOrFail = true
        dragSession.draggingFormation = NSDraggingFormation.None
    }

    func draggingSession(session: NSDraggingSession, willBeginAtPoint screenPoint: NSPoint) {
        println("draggingSession: \(session), willBeginAtPoint: \(screenPoint)")
    }

    func draggingSession(session: NSDraggingSession, movedToPoint screenPoint: NSPoint) {
        println("draggingSession: \(session), movedToPoint: \(screenPoint)")
    }

    func draggingSession(session: NSDraggingSession, endedAtPoint screenPoint: NSPoint, operation: NSDragOperation) {
        println("draggingSession: \(session), endedAtPoint: \(screenPoint), operation: \(operation)")
    }

    override func updateDraggingItemsForDrag(sender: NSDraggingInfo?) {
        println("\(updateDraggingItemsForDrag)")
    }

    override func namesOfPromisedFilesDroppedAtDestination(dropDestination: NSURL) -> ([AnyObject]!) {
        return ["icon.png"]
    }
    
    func draggingSession(session: NSDraggingSession, sourceOperationMaskForDraggingContext context: NSDraggingContext) -> NSDragOperation {
        if context == NSDraggingContext.OutsideApplication {
            return NSDragOperation.Copy
        } else {
            return NSDragOperation.None
        }
    }
    
    func pasteboard(pasteboard: NSPasteboard!, item: NSPasteboardItem!, provideDataForType type: String!) {
        if image == nil {
            return
        }
        switch type {
        case NSPasteboardTypeTIFF:
            pasteboard.setData(image!.TIFFRepresentation!, forType: NSPasteboardTypeTIFF)
        case NSPasteboardTypePDF:
            pasteboard.setData(self.dataWithPDFInsideRect(self.bounds), forType: NSPasteboardTypePDF)
        case NSPasteboardTypePNG:
            if let data = image!.pngData() {
                pasteboard.setData(data, forType: NSPasteboardTypePNG)
            }
        default:
            return
        }
    }

}

extension NSImage {
    func pngData() -> NSData? {
        let scaleImage = NSImage(size: self.size, flipped: false) { (dstRect) -> Bool in
            self.drawAtPoint(NSMakePoint(0, 0), fromRect: dstRect, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1.0)
            return true
        }
        
        // http://stackoverflow.com/questions/17507170/how-to-save-png-file-from-nsimage-retina-issues
//        let colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB)
//        let context = CGBitmapContextCreate(nil, scaleImage.size.width, scaleImage.size.width, 8, 4 * scaleImage.size.width, colorSpace, kCGBitmapByteOrderDefault|kCGImageAlphaPremultipliedLast)
        
        return nil
        
        
//        var rep: NSImageRep?
//        for representation in self.representations {
//            if representation.isKindOfClass(NSImageRep) {
//                if rep == nil {
//                    rep = representation as? NSImageRep
//                }
//                let imgRep = representation as NSImageRep
//                if rep?.size.width < imgRep.size.width && rep?.size.height < imgRep.size.height {
//                    rep = imgRep
//                }
//            }
//        }
//
////        let cgRef = self.CGImageForProposedRect(nil, context: nil, hints: nil)
////        let newRep = NSBitmapImageRep(CGImage: cgRef)
//        
//        let size = NSMakeSize(CGFloat(rep!.size.width), CGFloat(rep!.size.width))
//        let image = NSImage(size: size)
//        image.lockFocus()
//        rep?.drawAtPoint(NSMakePoint(0, 0))
//        image.unlockFocus()
//        return image.representations[0].representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
    }
}
