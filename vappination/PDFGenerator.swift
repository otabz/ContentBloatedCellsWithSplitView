//
//  PDFGenerator.swift
//  vappination
//
//  Created by Waseel ASP Ltd. on 8/27/16.
//  Copyright © 2016 Waseel ASP Ltd. All rights reserved.
//

import Foundation
import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PDFGenerator {
    
    var pageSize:CGSize!
    var pdfHeight = CGFloat(1024.0) //This is configurable
    var pdfWidth = CGFloat(768.0)
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    let headSeparatorStr = "\n______________________________________________________________________\n"
    let subHeadSeparatorStr = "\n_______________________________\n"
    let fieldSeparatorStr = "\n"
    let sectionSeparatorStr = "\n\n"
    let attributeSeparatorStr = "       "
    
    func generate(_ id: Int) ->  String{
        
        pageSize = CGSize (width: 850, height: 1100)
        
        let fileName: NSString = "Card.pdf"
        
        let path:NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        
        let documentDirectory: AnyObject = path.object(at: 0) as AnyObject
        
        let pdfPathWithFileName = documentDirectory.appendingPathComponent(fileName as String)
        
        self.generatePDFs(pdfPathWithFileName, id: id)
        
        //lines written to get the document directory path for the generated pdf file.
        
        return pdfPathWithFileName
    }
    
    func generatePDFs(_ filePath: String, id: Int) {
        
        UIGraphicsBeginPDFContextToFile(filePath, CGRect.zero, nil)
        
        let pdfString : PDFString = coreDataToStringForm(id)
        let currentText: CFAttributedString  = CFAttributedStringCreate(nil, pdfString.str as CFString!, nil)
        let framesetter: CTFramesetter = CTFramesetterCreateWithAttributedString(currentText);
        
        var done = false
        var currentRange : CFRange  = CFRangeMake(0, 0);
        var currentPage : Int  = 0;
        //var imagesDone = false
        
        
        repeat {
            // Mark the beginning of a new page.
            UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: 612, height: 792), nil);
            
            // Draw a page number at the bottom of each page.
            currentPage += 1;
            self.drawPageNumber(currentPage)
            
            currentRange = self.renderPageWithTextRange(currentRange, framesetter: framesetter)
            //print(currentRange)
            if currentRange.location == CFAttributedStringGetLength(currentText) {
                done = true;
            }
            
        } while !done
        
        
        UIGraphicsEndPDFContext()
        
    }
    
    func renderPageWithTextRange(_ currentRange: CFRange, framesetter: CTFramesetter) -> CFRange {
        var currentRange = currentRange
        // Get the graphics context.
        let currentContext : CGContext = UIGraphicsGetCurrentContext()!;
        
        // Put the text matrix into a known state. This ensures
        // that no old scaling factors are left in place.
        currentContext.textMatrix = CGAffineTransform.identity;
        
        // Create a path object to enclose the text. Use 72 point
        // margins all around the text.
        let frameRect : CGRect  = CGRect(x: 72, y: 72, width: 468, height: 648);
        let framePath : CGMutablePath  = CGMutablePath();
        CGPathAddRect(framePath, nil, frameRect);
        
        // Get the frame that will do the rendering.
        // The currentRange variable specifies only the starting point. The framesetter
        // lays out as much text as will fit into the frame.
        let frameRef : CTFrame = CTFramesetterCreateFrame(framesetter, currentRange, framePath, nil);
        //print(CFArrayGetCount(CTFrameGetLines(frameRef)))
        //CGPathRelease(framePath);
        
        // Core Text draws from the bottom-left corner up, so flip
        // the current transform prior to drawing.
        currentContext.translateBy(x: 0, y: 792);
        currentContext.scaleBy(x: 1.0, y: -1.0);
        
        // Draw the frame.
        CTFrameDraw(frameRef, currentContext);
        
        // Update the current range based on what was drawn.
        currentRange = CTFrameGetVisibleStringRange(frameRef);
        currentRange.location += currentRange.length;
        currentRange.length = 0;
        //CFRelease(frameRef);
        
        return currentRange;
    }

    
    func drawPageNumber(_ pageNum: Int)
    {
        let pageString : NSString = NSString(format: "Page %d", pageNum)
        let theFont = UIFont.init(name: "Helvetica Bold", size: 12)
        
        let textFontAttributes : [String:AnyObject] = [
            NSFontAttributeName : theFont!
        ]
        
        let _ : CGSize = CGSize(width: 612, height: 72);
        let textAttributes = [NSFontAttributeName: theFont!]
        
        let pageStringSizeRect : CGRect  = pageString.boundingRect(with: CGSize(width: 320, height: 2000), options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil)
        
        let pageStringSize: CGSize = pageStringSizeRect.size
        
        
        let stringRect : CGRect  = CGRect(x: ((612.0 - pageStringSize.width) / 2.0),
                                              y: 720.0 + ((72.0 - pageStringSize.height) / 2.0),
                                              width: pageStringSize.width,
                                              height: pageStringSize.height)
        
        //let parameters: NSDictionary = [ NSFontAttributeName:theFont!]
        pageString.draw(in: stringRect, withAttributes: textFontAttributes)
        //pageString.drawInRect(stringRect, withAttributes: parameters as? [String : AnyObject])
        
    }

    func coreDataToStringForm(_ id: Int) -> PDFString {
        let rs = PDFString()
        var bigStr = ""
        // select child
        let query = NSFetchRequest<NSFetchRequestResult>(entityName: "Child")
        query.predicate = NSPredicate(format: "id = %@", NSNumber(value: id as Int))
        
        do {
            let children = try self.Context.fetch(query) as? [Child]
            if children?.count > 0 {
                let child = children![0]
                // name
                bigStr = bigStr + child.name! + fieldSeparatorStr
                // dob
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.full
                let dateString = dateFormatter.string(from: child.dob! as Date)
                bigStr = bigStr + "Date of birth: " + dateString + fieldSeparatorStr
                // gender
                bigStr = bigStr + "Gender: " + child.gender! + sectionSeparatorStr
                
                // vaccinations
                let vaccinations = (child.vaccinations?.allObjects as? [Vaccination])?.sorted {
                    $0.stage_id!.localizedCaseInsensitiveCompare($1.stage_id!) == ComparisonResult.orderedAscending
                }
                
                bigStr = bigStr + subHeadSeparatorStr
                var i = 0
                for vaccination in vaccinations! {
                    // name
                    var name = (Vaccinations.stages()[Int(vaccination.stage_id!)!]).descEn
                    if name.length < 9 {
                        var till  = 9 - name.length
                        while(!(till==0)) {
                            name = name + " "
                            till = till - 1
                        }
                    }
                    bigStr = bigStr + name  + attributeSeparatorStr
                    // due date
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = DateFormatter.Style.medium
                    let dueDate = dateFormatter.string(from: vaccination.due_on! as Date)
                    bigStr = bigStr + dueDate + fieldSeparatorStr
                    // status
                    bigStr = bigStr + vaccination.status! + attributeSeparatorStr + fieldSeparatorStr
                    // vaccine
                    let vaccines = (vaccination.vaccines?.allObjects as? [Vaccine])?.sorted{
                        $0.vaccine_id!.localizedCaseInsensitiveCompare($1.vaccine_id!) == ComparisonResult.orderedAscending
                    }
                    for vaccine in vaccines! {
                    let status: VaccinationStatus = VaccinationStatus(rawValue: vaccine.status!)!
                        
                        if let doneDate = vaccine.performed_on {
                            bigStr = bigStr + (status == VaccinationStatus.Complete ? "✓" : " ") + dateFormatter.string(from: doneDate as Date) + attributeSeparatorStr
                        }
                        
                        bigStr = bigStr + Vaccinations.stages()[Int(vaccination.stage_id!)!].vaccines[Int(vaccine.vaccine_id!)!].nameEn
                        
                        bigStr = bigStr + fieldSeparatorStr
                    }
                    i = i + 1
                    if i < vaccinations?.count {
                    bigStr = bigStr + subHeadSeparatorStr
                    }
                    //i = i + 1
                }

            }
            rs.str = bigStr
        } catch {
            print(error)
        }
        return rs
    }
    
    func load(_ id: Int) -> Child? {
        // select child
        let query = NSFetchRequest<NSFetchRequestResult>(entityName: "Child")
        query.predicate = NSPredicate(format: "id = %@", NSNumber(value: id as Int))
        
        do {
            let children = try self.Context.fetch(query) as? [Child]
            return children![0]
        } catch {
            print(error)
            return nil
        }
    }
    
    class PDFString {
        var str: String = ""
        var numberOfPhotoSeparators: Int = 0
        var numberOfCharacters: Int = 0
    }
 
}

extension String {
    var length: Int {
        return characters.count
    }
}

