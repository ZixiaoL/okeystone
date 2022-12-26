//
//  ChooseModeViewController.swift
//  okeystone
//
//  Created by Zixiao Li on 2022/12/11.
//  Copyright © 2022 Zixiao Li. All rights reserved.
//

import UIKit
import Network

class ChooseModeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {

    var scanResult: ScanResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        instructions.delegate = self
        instructions.dataSource = self
    }
    
    @IBOutlet weak var instructions: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = "placeHolder"
        switch indexPath.section {
        case 0:
            identifier = "instruction1"
        case 1:
            identifier = "instruction2"
        case 2:
            identifier = "instruction3"
        case 3:
            identifier = "instruction4"
        default:
            break
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        // Configure content.
        cell.detailTextLabel?.text = "placeholder"
        return cell;
    }
    
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "popOverChooseMode") {
            if let destination = segue.destination as? ChooseModePopOverViewController {
                // if we're in a popover set ourselves as the delegate
                // so we can control the adaptation behavior to compact environments
//                    destination.delegate = self
                    // we could do other popover configuration here too
                
            }
        }
    }
}
