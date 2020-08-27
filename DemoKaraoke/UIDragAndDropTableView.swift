//
//  UIDragAndDropTableView.swift
//  DemoKaraoke
//
//  Created by Réjean Caron on 17-11-14.
//  Copyright © 2017 Productions Redge. All rights reserved.
//

import UIKit

@available(iOS 11.0, *)
class UIDragAndDropTableView: UITableView {

    /*

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return model.dragItems(for: indexPath)
    }

    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        let placeName = placeNames[indexPath.row]
        
        let data = placeName.data(using: .utf8)
        let itemProvider = NSItemProvider()
        
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
            completion(data, nil)
            return nil
        }
        
        return [
            UIDragItem(itemProvider: itemProvider)
        ]
    }
    @available(iOS 11.0, *)
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        let touchedPoint = session.location(in: self)
        let index = self.indexPathForRow(at: touchedPoint)!
        print(index.row)

        let testCell = self.hitTest(touchedPoint, with: nil) as? UIView
//        let itemProvider = NSItemProvider(object: testCell as! NSItemProviderWriting)
//        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = testCell
        return []
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        return UITargetedDragPreview(view: item.localObject as! UIView)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        for dragItem in session.items {
            print(dragItem);
            dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (obj, err) in
                if let err = err {
                    print("An error occured while dropping image")
                }
                guard let image = obj as? UIImage else { return };
                
            })
        }
    }
 */
}
