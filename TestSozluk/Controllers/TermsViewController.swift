//
//  TermsViewController.swift
//  TestSozluk
//
//  Created by Olgu Sırman on 10.07.2019.
//  Copyright © 2019 MesutGunes. All rights reserved.
//

import UIKit

final class TermsViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    // MARK: Outlets
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    // MARK: Properties
    private let networkManager = NetworkManager()

    var filteredTerms: [Term]? = []
    var wholeTerms: [Term]? = []

    var isSearchBarEmpty: Bool {
      return searchBar.text?.isEmpty ?? true
    }

    
    private var terms: [Term]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        networkManager.getTerms { [weak self] (terms, errorMessage) in
            DispatchQueue.main.async {
                self?.terms = terms
                self?.wholeTerms = terms
            }
        }
        searcBarSetup()
    }

    func searcBarSetup() {
        searchBar.delegate = self
    }

    // MARK: - search bar delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText, terms: self.terms)
    }

    func filterContentForSearchText(_ searchText: String, terms: [Term]?  = nil) {

        if isSearchBarEmpty {
            self.terms = self.wholeTerms
        } else {
            self.terms = (self.wholeTerms?.filter { (term: Term) -> Bool in
                return term.term.lowercased()
                    .contains(searchText.lowercased())
            })
        }
    }
}



extension TermsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return terms?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TermsCell.self)) as! TermsCell

        cell.backgroundColor = indexPath.row % 2 == 0 ? hexStringToUIColor(hex: "#F3F0EF") : .white
        
        if let term = terms?[indexPath.row] {
            cell.termLabel.text = term.term
            cell.meaningLabel.text = term.meaning
        }
        
        return cell
    }
    
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
