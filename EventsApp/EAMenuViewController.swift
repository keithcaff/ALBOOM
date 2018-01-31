//
//  MenuViewController.swift
//  EventsApp
//
//  Created by Keith Caffrey on 26/05/2016.
//  Copyright © 2016 KC. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2

class EAMenuViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource  {
    
    fileprivate let service = GTLServiceDrive()
    
    private let menuItemCellIReuseIdentifier = "EAMenuItemCell"
    private let menuItemLabelTag = 101
    
    public enum MenuOptions: Int {
        case CreateEvent = 0
        case ViewEvents
        case ShareEvents
        case AboutApp
        
        static var count: Int{ return 4 }//UPDATE IF ADDING NEW ENUM VALUES!!!!
        
        static func enumFromInt(int:Int) -> MenuOptions? {
            return MenuOptions(rawValue:int)
        }
        
        static func enumFromString(string:String) -> MenuOptions? {
            var i = 0
            while let item = MenuOptions(rawValue: i) {
                if String(describing: item) == string {
                    return item
                }
                i += 1
            }
            return nil
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var logOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        logOutButton.setTitle(MenuItemLabels.LOG_OUT, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selected = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selected, animated: true)
        }
    }
    
    //MARK: UITableViewDelegate delegate methods
    @IBAction func logOutButtonTapped(_ sender: Any) {
        print("Log out button tapped!")
        GIDSignIn.sharedInstance().signOut()
        EAEvent.didSwitchEvent(nil)
        var loginVC:EALoginViewController?
        
        if let nav = revealViewController().frontViewController.navigationController {
            nav.viewControllers.forEach { viewController in
                if viewController is EALoginViewController {
                    loginVC = viewController as? EALoginViewController
                }
            }
            revealViewController().revealToggle(animated: false)
            nav.popToViewController(loginVC!, animated: false)
        }
        
        EADeviceDataManager.sharedInstance.cleanupStoredData()
    }
    
    @IBAction func unWindToMenu(_ sender: UIStoryboardSegue) {
        print("unWindToMenu")
        if (sender.identifier == SegueIdentifiers.CREATE_EVENT_UNWIND_SEGUE) {
            let source: EACreateEventViewController
            source = sender.source as! EACreateEventViewController
            if let event = source.event {
                EAGoogleAPIManager.sharedInstance.createEventFolder(event)
            }
        }
        if (sender.identifier == SegueIdentifiers.EXIT_VIEW_EVENTS_UNWIND_SEGUE) {
            print("exitViewEventsUnwindSegue")
            let source: EAViewEventsViewController
            
            // Clear current files on home vc here..
            let homeTabBarController:EAHomeTabBarController = (revealViewController().frontViewController as! EAHomeTabBarController)
            var contentVC:UIViewController = homeTabBarController.viewControllers!.first!
            if(contentVC.isKind(of: UINavigationController.self)) {
                contentVC = (contentVC as! UINavigationController).viewControllers[0]
            }
            print("content vc is \(contentVC)")
            source = sender.source as! EAViewEventsViewController
            if let event = source.selectedEvent {
                if let contentVC = contentVC as? EAEventUpdateDelegate {
                    contentVC.didSwitchEvent(event)
                }
                EAGoogleAPIManager.sharedInstance.switchEventFolder(event)
            }
        }
    }
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == SegueIdentifiers.VIEW_EVENTS_SEGUE) {
            if let destinationNav = segue.destination as? UINavigationController, let destination = destinationNav.viewControllers.first as? EAViewEventsViewController, let mode : Int = sender as? Int {
                    destination.mode = MenuOptions.enumFromInt(int:mode)
            }
        }
    }
    
    //MARK: UITableViewDelegate delegate methods
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuOption:MenuOptions = MenuOptions(rawValue: indexPath.row)!
        switch menuOption {
            case .CreateEvent:
                print("segue to create event")
                self.performSegue(withIdentifier: SegueIdentifiers.CREATE_EVENT_SEGUE,sender:self)
            case .ViewEvents:
                self.performSegue(withIdentifier: SegueIdentifiers.VIEW_EVENTS_SEGUE,sender:MenuOptions.ViewEvents.rawValue)
            case .ShareEvents:
                self.performSegue(withIdentifier: SegueIdentifiers.VIEW_EVENTS_SEGUE,sender:MenuOptions.ShareEvents.rawValue)
            case .AboutApp:
                self.performSegue(withIdentifier: SegueIdentifiers.VIEW_ABOUT_APP_SEGUE,sender:self)
        }
    }
    
    //MARK: UITableViewDataSource delegate methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOptions.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuItemCell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: menuItemCellIReuseIdentifier)
        let menuItemLabel:UILabel = menuItemCell?.viewWithTag(menuItemLabelTag) as! UILabel
        var labelText:String;
        
        let menuOption:MenuOptions = MenuOptions(rawValue: indexPath.row)!
        switch menuOption {
            case .CreateEvent:
                labelText = MenuItemLabels.CREATE_EVENT
            case .ViewEvents:
                labelText = MenuItemLabels.VIEW_EVENTS
            case .ShareEvents:
                labelText = MenuItemLabels.SHARE_EVENTS
            case .AboutApp:
                labelText = MenuItemLabels.ABOUT_APP
        }
        menuItemLabel.text = labelText
        return menuItemCell
    }
    
    func hideMenu() {
        revealViewController().revealToggle(animated: false)
    }
    
}
