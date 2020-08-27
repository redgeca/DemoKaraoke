////
//  ViewController.swift
//  DemoKaraoke
//
//  Created by Réjean Caron on 17-11-05.
//  Copyright © 2017 Productions Redge. All rights reserved.
//

import UIKit

import SwiftSignalRClient


@available(iOS 11.0, *)
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITableViewDropDelegate, HubConnectionDelegate {
    

    @IBOutlet weak var options: UIButton!
    @IBOutlet var optionsCollection: [UIButton]!
    var dragging: Bool = false;
    var karaokeState: State!;
    
    var requestTimer: Timer!;
    
    var hubConnection: HubConnection?
    var chatHubConnectionDelegate: ChatHubConnectionDelegate?
    
    @IBOutlet weak var karaokeStateButton: UIButton!
    @IBOutlet weak var deleteRequests: UIButton!
    @IBOutlet weak var deletePlaylist: UIButton!
    @IBOutlet weak var deleteAll: UIButton!
    @IBOutlet weak var numberInPlaylist: UILabel!
    
    @IBAction func refresh(_ sender: Any) {
        sendGetSongRequest()
        sendGetPlaylist()
    }
    
    func connectionDidOpen(hubConnection: HubConnection!) {
        print("Connection did open");
    }
    
    public func getUrlConnection(path: String) -> URLComponents {
        var url = URLComponents()
        url.scheme = "http"
        url.host = "drague.karaoke"
        url.port = 81;
        url.path = path

        return url;
    }
    
    func connectionDidFailToOpen(error: Error) {
        print("Connection failed to  open");
        let alertController = UIAlertController(title: "Erreur", message:
            error.localizedDescription +
            "\nVerifiez la connection réseau", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Fermer", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            exit(0);
        }))

        self.present(alertController, animated: true, completion: nil);//{
            //exit(0); //fatalError("Erreur de connection"); //NSApp.shared.terminate(self);
        //})
        //exit(0);

    }
    
    func connectionDidClose(error: Error?) {
        print("Connection did close");
        hubConnection!.start()

    }

    
    @IBAction func optionsClicked(_ sender: Any) {
        switch(self.karaokeState.value) {
        case "RUNNING" : self.karaokeStateButton.setTitle("Arrêter le karaoké", for: .normal); break;
        case "STOPPED" :self.karaokeStateButton.setTitle("Démarrer le karaoké", for: .normal); break;
        default:
            print("Invalid option");
            
        }

        optionsCollection.forEach { (button) in
            UIView.animate(withDuration: 0.3, animations: {
                 button.isHidden = !button.isHidden;
              self.view.layoutIfNeeded()
                

            });
        }
    }
    
    @IBAction func karaokeStateChange(_ sender: UIButton) {
        print("Change state : " + karaokeState.value);
        switch(karaokeState.value) {
        case "RUNNING" : setKaraokeState(value: "\"STOPPED\"");
        default: setKaraokeState(value: "\"RUNNING\"");
        }
        optionsClicked(sender)
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        switch(sender) {
        case deleteRequests: print("Delete Reqquests");
        break;
            
        case deletePlaylist:print("Delete Playlist");
        break;
            
        case deleteAll:print("Delete All");
        break;
            
        default:
            print("Do nothing");
        }
        optionsClicked(sender)
    }
    
    public func sendGetState() {
        let sessionConfiguration = URLSessionConfiguration.default
        
        let url = getUrlConnection(path: "/api/KaraokeState");
        
        if let queryUrl = url.url {
            var request = URLRequest(url:queryUrl)
            request.httpMethod = "GET"
            let urlSession = URLSession(configuration:sessionConfiguration,
                                        delegate: nil, delegateQueue: nil)
            
            let sessionTask = urlSession.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
                DispatchQueue.main.async {
                    
                    if let error = error {
                        print (error)
                        return
                    }
                    
                    if let data = data {
                        let jsonDecoder = JSONDecoder();
                        jsonDecoder.dateDecodingStrategy = .iso8601;
                        do {
                            self.karaokeState = try JSONDecoder().decode(State.self, from: data)
                            switch(self.karaokeState.value) {
                            case "RUNNING" : self.karaokeStateButton.setTitle("Arrêter le karaoké", for: .normal); break;
                            case "STOPPED" :self.karaokeStateButton.setTitle("Démarrer le karaoké", for: .normal); break;
                            default:
                                print("Invalid option");
                                
                            }

                            print(self.karaokeState!)
                            
                        } catch let error {
                            print(error)
                        }
                        
                    }
                }
            })
            sessionTask.resume()
            
        }
    }
    
    public func setKaraokeState(value: String) {
        let sessionConfiguration = URLSessionConfiguration.default
        
        let url = getUrlConnection(path: "/api/KaraokeState")
        
        if let queryUrl = url.url {
            var request = URLRequest(url:queryUrl)
            request.httpMethod = "PUT"
            request.httpBody = value.data(using: .utf8);
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            print(request)
            print(value)
            let urlSession = URLSession(configuration:sessionConfiguration,
                                        delegate: nil, delegateQueue: nil)
            
            let sessionTask = urlSession.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
                DispatchQueue.main.async {
                    
                    print(response.debugDescription);
                    if let error = error {
                        print (error)
                        return
                    }
                    self.sendGetState();
                    switch(self.karaokeState.value) {
                    case "RUNNING" : self.karaokeStateButton.setTitle("Arrêter le karaoké", for: .normal); break;
                    case "STOPPED" :self.karaokeStateButton.setTitle("Démarrer le karaoké", for: .normal); break;
                    default:
                        print("Invalid option");
                        
                    }


                    self.sendGetSongRequest()
                    self.sendGetPlaylist()
                }
            })
            sessionTask.resume()
        }
    }


    
    @IBOutlet weak var numberOfRequests: UILabel!
    var songRequests : [SongRequest] = [];
    var playlistRequests : [PlaylistSong] = [];
    
    public func addToPlayList(id: Int, row: Int) {
        let sessionConfiguration = URLSessionConfiguration.default
        
        var url = getUrlConnection(path: "/api/Playlist")
        let queryItemToken = URLQueryItem(name: "id", value: id.description)
        url.queryItems = [queryItemToken]
        
        
        if let queryUrl = url.url {
            var request = URLRequest(url:queryUrl)
            request.httpMethod = "POST"
            request.httpBody = row.description.data(using: .utf8);
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let urlSession = URLSession(configuration:sessionConfiguration,
                                        delegate: nil, delegateQueue: nil)
            
            let sessionTask = urlSession.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
                DispatchQueue.main.async {
                    
                    if let error = error {
                        print (error)
                        return
                    }
                    //self.sendGetSongRequest()
                    //self.sendGetPlaylist()
                }
            })
            sessionTask.resume()
        }
    }
    
    public func reorderPlayList(id: Int, row: Int) {
        let sessionConfiguration = URLSessionConfiguration.default
        
        var url = getUrlConnection(path: "/api/Playlist");
        let queryItemToken = URLQueryItem(name: "id", value: id.description)
        url.queryItems = [queryItemToken]
        
        
        if let queryUrl = url.url {
            var request = URLRequest(url:queryUrl)
            request.httpMethod = "PUT"
            request.httpBody = row.description.data(using: .utf8);
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let urlSession = URLSession(configuration:sessionConfiguration,
                                        delegate: nil, delegateQueue: nil)
            
            let sessionTask = urlSession.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
                DispatchQueue.main.async {
                    
                    if let error = error {
                        print (error)
                        return
                    }
                    //self.sendGetSongRequest()
                    //self.sendGetPlaylist()
                }
            })
            sessionTask.resume()
        }
    }
    
    public func removeFromPlaylist(id: Int) {
        let sessionConfiguration = URLSessionConfiguration.default
        
        var url = getUrlConnection(path: "/api/Playlist");
        let queryItemToken = URLQueryItem(name: "id", value: id.description)
        url.queryItems = [queryItemToken]
        
        
        if let queryUrl = url.url {
            var request = URLRequest(url:queryUrl)
            request.httpMethod = "DELETE"
            //request.httpBody = row.description.data(using: .utf8);
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let urlSession = URLSession(configuration:sessionConfiguration,
                                        delegate: nil, delegateQueue: nil)
            
            let sessionTask = urlSession.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
                DispatchQueue.main.async {
                    
                    if let error = error {
                        print (error)
                        return
                    }
                    //self.sendGetPlaylist()
                    //self.sendGetSongRequest()

                    
                }
            })
            
            sessionTask.resume()
        }
        
    }
    
    public func removeFromRequests(id: Int) {
        let sessionConfiguration = URLSessionConfiguration.default
        
        var url = getUrlConnection(path: "/api/Requests")

        let queryItemToken = URLQueryItem(name: "id", value: id.description)
        url.queryItems = [queryItemToken]
        
        
        if let queryUrl = url.url {
            var request = URLRequest(url:queryUrl)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let urlSession = URLSession(configuration:sessionConfiguration,
                                        delegate: nil, delegateQueue: nil)
            
            let sessionTask = urlSession.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
                DispatchQueue.main.async {
                    
                    if let error = error {
                        print (error)
                        return
                    }
                    //self.sendGetSongRequest()
                    //self.sendGetPlaylist()

                    
                }
            })
            
            sessionTask.resume()
        }
        
    }
    
    public func deleteFromPlaylist(id: Int) {
        let sessionConfiguration = URLSessionConfiguration.default
        
        var url = getUrlConnection(path: "/api/Playlist")
        let queryItemToken = URLQueryItem(name: "id", value: id.description)
        let deleteOption = URLQueryItem(name: "delete", value: "DELETE")
        url.queryItems = [queryItemToken, deleteOption]
        
        
        if let queryUrl = url.url {
            var request = URLRequest(url:queryUrl)
            request.httpMethod = "DELETE"
            request.httpBody = "DELETE".data(using: .utf8);
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let urlSession = URLSession(configuration:sessionConfiguration,
                                        delegate: nil, delegateQueue: nil)
            
            let sessionTask = urlSession.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
                DispatchQueue.main.async {
                    
                    if let error = error {
                        print (error)
                        return
                    }
                    //self.sendGetPlaylist()
                    //self.sendGetSongRequest()
                }
            })
            
            sessionTask.resume()
        }

    }
    
    public func sendGetPlaylist() {
        let sessionConfiguration = URLSessionConfiguration.default
        
        let url = getUrlConnection(path: "/api/Playlist")
        
        if let queryUrl = url.url {
            var request = URLRequest(url:queryUrl)
            request.httpMethod = "GET"
            let urlSession = URLSession(configuration:sessionConfiguration,
                                        delegate: nil, delegateQueue: nil)
            
            let sessionTask = urlSession.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
                DispatchQueue.main.async {
                    
                    if let error = error {
                        print (error)
                        return
                    }
                    
                    if let data = data {
                        let jsonDecoder = JSONDecoder();
                        jsonDecoder.dateDecodingStrategy = .iso8601;
                        do {
                            self.playlistRequests = try JSONDecoder().decode([PlaylistSong].self, from: data)
                            self.playlistTable.reloadData()
                            
                        } catch let error {
                            print(error)
                        }
                        
                    }
                }
            })
            sessionTask.resume()

        }
    }
    
    public func sendGetSongRequest () {
        
        let sessionConfiguration = URLSessionConfiguration.default
        
        let url = getUrlConnection(path: "/api/Requests")

        if let queryUrl = url.url {
            var request = URLRequest(url:queryUrl)
            request.httpMethod = "GET"
            let urlSession = URLSession(configuration:sessionConfiguration,
                                        delegate: nil, delegateQueue: nil)
            
            let sessionTask = urlSession.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
                
                DispatchQueue.main.async {
                    
                    if let error = error {
                        print (error)
                        return
                    }
                    
                    if let data = data {
                        let jsonDecoder = JSONDecoder();
                        jsonDecoder.dateDecodingStrategy = .iso8601;
                        do {
                            self.songRequests = try JSONDecoder().decode([SongRequest].self, from: data)
                            self.requestTable.reloadData()
                            
                        } catch let error {
                            print(error)
                        }
                        
                    }
                }
            })
            sessionTask.resume()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == requestTable) {
            numberOfRequests.text = songRequests.count.description
            return songRequests.count;
        } else {
            numberInPlaylist.text = playlistRequests.count.description
            return playlistRequests.count;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : RequestTableViewCell
        var request: SongRequest
        if (tableView == requestTable) {
            cell = requestTable.dequeueReusableCell(withIdentifier: "requestTableCell") as! RequestTableViewCell;
            request = songRequests[indexPath.row]
        } else {
            cell = playlistTable.dequeueReusableCell(withIdentifier: "playlistTableCell") as! RequestTableViewCell;
            request = playlistRequests[indexPath.row].request

        }
        cell.isUserInteractionEnabled = true;
        cell.songLabel.text = request.song.title + " de " + (request.song.artist?.name)!
        cell.singerLabel.text = request.singerName
        cell.notesLabel.text = (request.notes == nil || request.notes == "null") ? "" : request.notes
        if (request.notes == nil) {
            print("NULL")
        } else if (request.notes == "null") {
            print("On avait null comme note")
        }
        
//        if (tableView == requestTable) {
            let indexStart = request.requestTime.index(request.requestTime.startIndex, offsetBy: 11)
            let indexEnd = request.requestTime.index(request.requestTime.startIndex, offsetBy: 19)
            cell.requestTimeLabel.text = String(request.requestTime[indexStart..<indexEnd]);
//        } else {
//            cell.requestTimeLabel.text = "";
//        }
        
        return cell;
    }

    @IBOutlet weak var playlistTable: UIDragAndDropTableView!
    @IBOutlet weak var requestTable: UIDragAndDropTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                
        playlistTable.layer.cornerRadius = 10;
        requestTable.layer.cornerRadius = 10;
        
        requestTable.delegate = self;
        playlistTable.delegate = self;
        
        requestTable.dataSource = self;
        playlistTable.dataSource = self;
        
        requestTable.setEditing(true, animated: true)
        playlistTable.setEditing(true, animated: true)
        
        playlistTable.dragDelegate = self
        playlistTable.dropDelegate = self
        
        requestTable.dragDelegate = self
        requestTable.dropDelegate = self
        
        sendGetState()
        sendGetSongRequest()
        sendGetPlaylist()
        
        requestTable.allowsMultipleSelectionDuringEditing = false;
        
        hubConnection = HubConnection(url: URL(string:"http://drague.karaoke:81/message")!)
        chatHubConnectionDelegate = ChatHubConnectionDelegate(app: self)
        hubConnection!.delegate = chatHubConnectionDelegate
        
//        hubConnection.delegate = self
        hubConnection!.on(method: "reloadRequests", callback: {_,_  in
            print("Reloading Requests")
            self.sendGetSongRequest()
        })
        hubConnection!.on(method: "reloadPlaylist", callback: {_,_  in
            print("Reloading Playlist")
            self.sendGetPlaylist()
        })
        hubConnection!.start()
        
        print("Hub Connection started");
        
        /*
        requestTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: {_ in
            print ("Timer1 triggered")
            if self.dragging {
                print("Timer1 while dragging - Returning")
                return
            } else {
                self.sendGetSongRequest()
                self.sendGetPlaylist()
            }
        })
 */
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        requestTimer.invalidate()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        dragging = true
        if tableView == requestTable {
            let delete = UITableViewRowAction(style: .destructive, title: "Effacer") { (action, indexPath) in
                let id = self.songRequests[indexPath.row].id
                self.removeFromRequests(id: id)
                //self.sendGetSongRequest()
                self.dragging = false
            }
            return [delete]
        } else {
            let delete = UITableViewRowAction(style: .destructive, title: "Effacer") { (action, indexPath) in
                let id = self.playlistRequests[indexPath.row].id
                self.deleteFromPlaylist(id: id)
                //self.sendGetPlaylist()
                self.dragging = false
             }

            return [delete]

        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if (tableView == requestTable) {
            return false;
        }
        return true;
    }
 
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if tableView == playlistTable {
            if (sourceIndexPath.row != destinationIndexPath.row) {
                reorderPlayList(id: playlistRequests[sourceIndexPath.row].id, row: destinationIndexPath.row);
                //self.sendGetPlaylist()
            }
        }
        dragging = false
    }
 
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        var placeName:SongRequest
        dragging = false

        if tableView == requestTable {
            placeName = songRequests[indexPath.row]
        } else {
            placeName = playlistRequests[indexPath.row].request
        }
        
        do {
            let data = try JSONEncoder().encode(placeName)
            let itemProvider = NSItemProvider()
            
            itemProvider.registerDataRepresentation(forTypeIdentifier: "SongRequest", visibility: .ownProcess) { completion in
                completion(data, nil)
                return nil
            }
            let dragItem = UIDragItem(itemProvider: itemProvider);
            dragItem.localObject = TableViewInformation(fromTableView: tableView, indexPath:indexPath);
            dragging = true
            return [dragItem]
        }
        catch { /* Nothing to do*/ }
        
        return [];
    }
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: ["SongRequest"]) && session.items.count == 1
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        // The .move operation is available only for dragging within a single app.
        
        dragging = false
        if session.localDragSession != nil {
            let oldView = session.items[0].localObject as? TableViewInformation
            if oldView?.fromTableView == requestTable && tableView == requestTable {
                return UITableViewDropProposal(operation: .cancel)
            }
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UITableViewDropProposal(operation: .cancel)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        print(destinationIndexPath.section.description)
        
        for item: UIDragItem in coordinator.session.items {
            print(destinationIndexPath.section.description)
            item.itemProvider.loadDataRepresentation(forTypeIdentifier: "SongRequest", completionHandler: { (data, error) in
                print(destinationIndexPath.section.description)
                if let data = data {
                    do {
                        print(destinationIndexPath.section.description)
                        let newRequest = try JSONDecoder().decode(SongRequest.self, from:data);//try CNContactVCardSerialization.contacts(with: data)
                        
                        let viewInformation = item.localObject as? TableViewInformation
                        let oldRow = viewInformation?.indexPath.row
                        
                        print(destinationIndexPath.row);
                        
                        // It is not permitted to move items in the request list
                        if viewInformation?.fromTableView == self.requestTable && tableView == self.requestTable {
                            print("Unable to drag a request in its own list");
                            return
                        }
                        
                        if viewInformation?.fromTableView == self.playlistTable && tableView == self.playlistTable {
                            return
                        }

                        if (viewInformation?.fromTableView == self.playlistTable && tableView == self.requestTable) {
                            print((oldRow?.description)! + " : " + newRequest.id.description)
                            let id = self.playlistRequests[oldRow!].id
                            self.removeFromPlaylist(id: id)
                        } else if viewInformation?.fromTableView == self.requestTable && tableView == self.playlistTable {
                            self.addToPlayList(id: newRequest.id, row: destinationIndexPath.row);
                        }
                        
                    } catch  {
                        print(error);
                            
                    }
                }
            })
            
        }
        //sendGetSongRequest()
        //sendGetPlaylist()
        dragging = false

   }
    
    

}

@available(iOS 11.0, *)
class ChatHubConnectionDelegate: HubConnectionDelegate {
    weak var app: ViewController?
    
    init(app: ViewController) {
        self.app = app
    }
    
    func connectionDidOpen(hubConnection: HubConnection!) {
        app?.connectionDidOpen(hubConnection: nil)
    }
    
    func connectionDidFailToOpen(error: Error) {
        app?.connectionDidFailToOpen(error: error)
    }
    
    func connectionDidClose(error: Error?) {
        app?.connectionDidClose(error: error)
    }
}
